from flask import current_app, g, jsonify, request

import config
from services.auth import pode_acessar

CAMPO_DA_CONTA = {
    "CRIAR_CONTA": "id",
    "DEPOSITO": "id",
    "SAQUE": "id",
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
    conta = current_app.config["ESTADO"]["contas"].get(id_conta)
    if not conta:
        return jsonify({"erro": "Conta não encontrada nesta agência."}), 404
    if not pode_acessar(conta):
        return _negado()
    return jsonify(conta)


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
        return jsonify(conta)


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
        return jsonify(conta)


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
    return jsonify({"idConta": id_conta, "eventos": list(reversed(da_conta[-limite:]))})
