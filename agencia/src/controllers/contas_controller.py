from flask import current_app, jsonify, request

import config


def _valor(req):
    return (req.get_json(silent=True) or {}).get("valor")


def criar_conta():
    dados = request.get_json(silent=True) or {}
    id_conta = dados.get("id")
    nome_aluno = dados.get("nomeAluno")
    saldo_inicial = dados.get("saldoInicial", 0)

    estado = current_app.config["ESTADO"]
    contas = estado["contas"]

    if id_conta is None:
        return jsonify({"erro": "Campo 'id' obrigatório."}), 400
    if config.agencia_responsavel(id_conta) != estado["id_agencia"]:
        return jsonify({"erro": f"Conta {id_conta} não pertence a esta agência."}), 400
    if id_conta in contas:
        return jsonify({"erro": "Conta já existe."}), 409

    ts = estado["relogio"].evento_local()
    contas[id_conta] = {"id": id_conta, "nomeAluno": nome_aluno, "saldo": saldo_inicial or 0}
    estado["registro"].registrar("CRIAR_CONTA", ts, {"id": id_conta, "nomeAluno": nome_aluno, "saldoInicial": saldo_inicial})

    return jsonify(contas[id_conta]), 201


def consultar_saldo(id_conta):
    conta = current_app.config["ESTADO"]["contas"].get(id_conta)
    if not conta:
        return jsonify({"erro": "Conta não encontrada nesta agência."}), 404
    return jsonify(conta)


def depositar(id_conta):
    estado = current_app.config["ESTADO"]
    conta = estado["contas"].get(id_conta)
    valor = _valor(request)
    if not conta:
        return jsonify({"erro": "Conta não encontrada nesta agência."}), 404
    if not isinstance(valor, (int, float)) or valor <= 0:
        return jsonify({"erro": "Valor inválido."}), 400

    ts = estado["relogio"].evento_local()
    conta["saldo"] += valor
    estado["registro"].registrar("DEPOSITO", ts, {"id": id_conta, "valor": valor, "novoSaldo": conta["saldo"]})

    return jsonify(conta)


def sacar(id_conta):
    estado = current_app.config["ESTADO"]
    conta = estado["contas"].get(id_conta)
    valor = _valor(request)
    if not conta:
        return jsonify({"erro": "Conta não encontrada nesta agência."}), 404
    if not isinstance(valor, (int, float)) or valor <= 0:
        return jsonify({"erro": "Valor inválido."}), 400
    if conta["saldo"] < valor:
        return jsonify({"erro": "Saldo insuficiente."}), 400

    ts = estado["relogio"].evento_local()
    conta["saldo"] -= valor
    estado["registro"].registrar("SAQUE", ts, {"id": id_conta, "valor": valor, "novoSaldo": conta["saldo"]})

    return jsonify(conta)
