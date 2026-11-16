from flask import current_app, g, jsonify, request

import config
from controllers.transferencias_controller import executar_transferencia
from services.auth import pode_acessar
from services.comparar_vetores import comparar_vetores

CAMPO_DA_CONTA = {
    "CRIAR_CONTA": "id",
    "DEPOSITO": "id",
    "SAQUE": "id",
    "SINCRONIZACAO_OFFLINE": "id",
    "TRANSFERENCIA_DEBITO": "idOrigem",
    "TRANSFERENCIA_PENDENTE": "idOrigem",
    "TRANSFERENCIA_PUBLICADA": "idOrigem",
    "TRANSFERENCIA_CREDITO": "idDestino",
    "TRANSFERENCIA_CREDITO_REMOTO": "idConta",
    "CREDITO_REMOTO_FALHOU": "idConta",
    "CREDITO_REMOTO_DUPLICADO": "idConta",
}


def _negado():
    return jsonify({"erro": "Sem permissão para esta conta."}), 403


def _com_vetor(estado, conta):
    return {**conta, "vetorAtual": estado["relogio"].obter_vetor_atual()}


def _valor(req):
    return (req.get_json(silent=True) or {}).get("valor")


def criar_conta():
    dados = request.get_json(silent=True) or {}
    id_conta = dados.get("id")
    nome_aluno = dados.get("nomeAluno")
    saldo_inicial = dados.get("saldoInicial", 0)
    dono = dados.get("dono") or g.usuario

    estado = current_app.config["ESTADO"]
    contas = estado["contas"]

    if id_conta is None:
        return jsonify({"erro": "Campo 'id' obrigatório."}), 400
    if config.agencia_responsavel(id_conta) != estado["id_agencia"]:
        return jsonify({"erro": f"Conta {id_conta} não pertence a esta agência."}), 400
    if g.papel != "operador" and dono != g.usuario:
        return jsonify({"erro": "Apenas operadores criam contas para outros usuários."}), 403
    if dono not in config.USUARIOS:
        return jsonify({"erro": "Dono inexistente."}), 400

    with estado["trava"]:
        if id_conta in contas:
            return jsonify({"erro": "Conta já existe."}), 409
        ts = estado["relogio"].evento_local()
        contas[id_conta] = {"id": id_conta, "nomeAluno": nome_aluno, "saldo": saldo_inicial or 0, "dono": dono}
        estado["registro"].registrar("CRIAR_CONTA", ts, {"id": id_conta, "nomeAluno": nome_aluno, "saldoInicial": saldo_inicial, "dono": dono})
        return jsonify(contas[id_conta]), 201


def consultar_saldo(id_conta):
    estado = current_app.config["ESTADO"]
    conta = estado["contas"].get(id_conta)
    if not conta:
        return jsonify({"erro": "Conta não encontrada nesta agência."}), 404
    if not pode_acessar(conta):
        return _negado()
    return jsonify(_com_vetor(estado, conta))


def depositar(id_conta):
    estado = current_app.config["ESTADO"]
    valor = _valor(request)

    with estado["trava"]:
        conta = estado["contas"].get(id_conta)
        if not conta:
            return jsonify({"erro": "Conta não encontrada nesta agência."}), 404
        if not pode_acessar(conta):
            return _negado()
        if not isinstance(valor, (int, float)) or valor <= 0:
            return jsonify({"erro": "Valor inválido."}), 400
        ts = estado["relogio"].evento_local()
        conta["saldo"] += valor
        estado["registro"].registrar("DEPOSITO", ts, {"id": id_conta, "valor": valor, "novoSaldo": conta["saldo"]})
        return jsonify(_com_vetor(estado, conta))


def sacar(id_conta):
    estado = current_app.config["ESTADO"]
    valor = _valor(request)

    with estado["trava"]:
        conta = estado["contas"].get(id_conta)
        if not conta:
            return jsonify({"erro": "Conta não encontrada nesta agência."}), 404
        if not pode_acessar(conta):
            return _negado()
        if not isinstance(valor, (int, float)) or valor <= 0:
            return jsonify({"erro": "Valor inválido."}), 400
        if conta["saldo"] < valor:
            return jsonify({"erro": "Saldo insuficiente."}), 400
        ts = estado["relogio"].evento_local()
        conta["saldo"] -= valor
        estado["registro"].registrar("SAQUE", ts, {"id": id_conta, "valor": valor, "novoSaldo": conta["saldo"]})
        return jsonify(_com_vetor(estado, conta))


def historico(id_conta):
    estado = current_app.config["ESTADO"]
    try:
        limite = min(max(int(request.args.get("limite", 10)), 1), 100)
    except ValueError:
        return jsonify({"erro": "Limite inválido."}), 400

    with estado["trava"]:
        conta = estado["contas"].get(id_conta)
        if not conta:
            return jsonify({"erro": "Conta não encontrada nesta agência."}), 404
        if not pode_acessar(conta):
            return _negado()
        eventos = estado["registro"].listar()

    da_conta = [
        e for e in eventos
        if e["horaParede"] >= estado["historico_desde"]
        and e["detalhes"].get(CAMPO_DA_CONTA.get(e["tipo"])) == id_conta
    ]
    return jsonify({"idConta": id_conta, "vetorAtual": estado["relogio"].obter_vetor_atual(), "eventos": list(reversed(da_conta[-limite:]))})


def _vetor_valido(vetor, tamanho):
    return isinstance(vetor, list) and len(vetor) == tamanho and all(isinstance(n, int) and n >= 0 for n in vetor)


def sincronizar_operacao_pendente(id_conta):
    estado = current_app.config["ESTADO"]
    dados = request.get_json(silent=True) or {}
    tipo = dados.get("tipo")
    valor = dados.get("valor")
    vetor_conhecido = dados.get("vetorConhecido")
    id_operacao = dados.get("idOperacao")

    with estado["trava"]:
        conta = estado["contas"].get(id_conta)
        if not conta:
            return jsonify({"erro": "Conta não encontrada nesta agência."}), 404
        if not pode_acessar(conta):
            return _negado()
        if tipo not in ("DEPOSITO", "SAQUE", "TRANSFERENCIA"):
            return jsonify({"erro": "Tipo de operação pendente não suportado."}), 400
        if not isinstance(valor, (int, float)) or valor <= 0:
            return jsonify({"erro": "Valor inválido."}), 400
        if not _vetor_valido(vetor_conhecido, config.NUMERO_AGENCIAS):
            return jsonify({"erro": "vetorConhecido inválido."}), 400
        if not isinstance(id_operacao, str) or not id_operacao:
            return jsonify({"erro": "idOperacao obrigatório."}), 400

        if id_operacao in estado["processadas"]:
            return jsonify({**_com_vetor(estado, conta), "repetida": True})

        vetor_atual = estado["relogio"].obter_vetor_atual()
        relacao = comparar_vetores(vetor_conhecido, vetor_atual)
        if relacao != "IGUAIS":
            return jsonify({
                "erro": "Conflito detectado: o estado da agência mudou desde a última sincronização do app.",
                "relacao": relacao,
                "vetorConhecido": vetor_conhecido,
                "vetorAtual": vetor_atual,
                "contaAtual": conta,
            }), 409

        if tipo == "TRANSFERENCIA":
            corpo, codigo = executar_transferencia(estado, id_conta, dados.get("idDestino"), valor)
            if codigo >= 400:
                return jsonify(corpo), codigo
            estado["processadas"].add(id_operacao)
            estado["registro"].registrar("SINCRONIZACAO_OFFLINE", estado["relogio"].evento_local(), {"id": id_conta, "tipo": tipo, "valor": valor, "idOperacao": id_operacao, "idDestino": dados.get("idDestino")})
            return jsonify({**_com_vetor(estado, conta), "transferencia": corpo})

        if tipo == "SAQUE" and conta["saldo"] < valor:
            return jsonify({"erro": "Saldo insuficiente."}), 400

        ts = estado["relogio"].evento_local()
        conta["saldo"] += valor if tipo == "DEPOSITO" else -valor
        estado["processadas"].add(id_operacao)
        estado["registro"].registrar("SINCRONIZACAO_OFFLINE", ts, {"id": id_conta, "tipo": tipo, "valor": valor, "idOperacao": id_operacao, "novoSaldo": conta["saldo"]})
        return jsonify(_com_vetor(estado, conta))
