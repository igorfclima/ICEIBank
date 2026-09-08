import requests
from flask import current_app, jsonify, request

import config


def transferir():
    estado = current_app.config["ESTADO"]
    contas = estado["contas"]
    dados = request.get_json(silent=True) or {}
    id_origem = dados.get("idOrigem")
    id_destino = dados.get("idDestino")
    valor = dados.get("valor")

    conta_origem = contas.get(id_origem)
    if not conta_origem:
        return jsonify({"erro": "Conta de origem não encontrada nesta agência."}), 404
    if not isinstance(valor, (int, float)) or valor <= 0:
        return jsonify({"erro": "Valor inválido."}), 400
    if conta_origem["saldo"] < valor:
        return jsonify({"erro": "Saldo insuficiente."}), 400

    agencia_destino = config.agencia_responsavel(id_destino)

    ts_debito = estado["relogio"].evento_local()
    conta_origem["saldo"] -= valor
    estado["registro"].registrar("TRANSFERENCIA_DEBITO", ts_debito, {"idOrigem": id_origem, "idDestino": id_destino, "valor": valor})

    if agencia_destino == estado["id_agencia"]:
        conta_destino = contas.get(id_destino)
        if not conta_destino:
            conta_origem["saldo"] += valor
            return jsonify({"erro": "Conta de destino não encontrada."}), 404
        ts_credito = estado["relogio"].evento_local()
        conta_destino["saldo"] += valor
        estado["registro"].registrar("TRANSFERENCIA_CREDITO", ts_credito, {"idOrigem": id_origem, "idDestino": id_destino, "valor": valor})
        return jsonify({"mensagem": "Transferência concluída (mesma agência)."})

    ts_envio = estado["relogio"].ao_enviar()
    url_destino = next(a["url"] for a in config.AGENCIAS if a["id"] == agencia_destino)

    try:
        resp = requests.post(
            f"{url_destino}/contas/{id_destino}/creditar-remoto",
            json={"valor": valor, "timestampLamport": ts_envio, "origemAgencia": estado["id_agencia"]},
            timeout=5,
        )
        resp.raise_for_status()
        return jsonify({"mensagem": "Transferência concluída (entre agências)."})
    except requests.RequestException as erro:
        estado["registro"].registrar("TRANSFERENCIA_FALHOU", estado["relogio"].evento_local(), {
            "idOrigem": id_origem, "idDestino": id_destino, "valor": valor, "erro": str(erro),
        })
        return jsonify({
            "erro": "Falha ao contatar agência de destino. Débito já aplicado - inconsistência conhecida (ver Sprint 4).",
        }), 502


def creditar_remoto(id_conta):
    estado = current_app.config["ESTADO"]
    dados = request.get_json(silent=True) or {}
    valor = dados.get("valor")
    timestamp_lamport = dados.get("timestampLamport", 0)
    origem_agencia = dados.get("origemAgencia")

    ts = estado["relogio"].ao_receber(timestamp_lamport)

    conta = estado["contas"].get(id_conta)
    if not conta:
        return jsonify({"erro": "Conta não encontrada nesta agência."}), 404

    conta["saldo"] += valor
    estado["registro"].registrar("TRANSFERENCIA_CREDITO_REMOTO", ts, {"idConta": id_conta, "valor": valor, "origemAgencia": origem_agencia})

    return jsonify({"mensagem": "Crédito remoto aplicado.", "saldoAtual": conta["saldo"]})
