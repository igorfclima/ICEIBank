import time
import uuid

from flask import current_app, jsonify, request

import config
from services import mensageria
from services.auth import pode_acessar


def transferir():
    estado = current_app.config["ESTADO"]
    contas = estado["contas"]
    dados = request.get_json(silent=True) or {}
    id_origem = dados.get("idOrigem")
    id_destino = dados.get("idDestino")
    valor = dados.get("valor")
    id_transferencia = str(uuid.uuid4())

    with estado["trava"]:
        conta_origem = contas.get(id_origem)
        if not conta_origem:
            return jsonify({"erro": "Conta de origem não encontrada nesta agência."}), 404
        if not pode_acessar(conta_origem):
            return jsonify({"erro": "Sem permissão para esta conta."}), 403
        if not isinstance(valor, (int, float)) or valor <= 0:
            return jsonify({"erro": "Valor inválido."}), 400
        if conta_origem["saldo"] < valor:
            return jsonify({"erro": "Saldo insuficiente."}), 400

        agencia_destino = config.agencia_responsavel(id_destino)

        vetor_debito = estado["relogio"].evento_local()
        conta_origem["saldo"] -= valor
        estado["registro"].registrar("TRANSFERENCIA_DEBITO", vetor_debito, {"idTransferencia": id_transferencia, "idOrigem": id_origem, "idDestino": id_destino, "valor": valor})

        if agencia_destino == estado["id_agencia"]:
            conta_destino = contas.get(id_destino)
            if not conta_destino:
                conta_origem["saldo"] += valor
                return jsonify({"erro": "Conta de destino não encontrada."}), 404
            vetor_credito = estado["relogio"].evento_local()
            conta_destino["saldo"] += valor
            estado["registro"].registrar("TRANSFERENCIA_CREDITO", vetor_credito, {"idTransferencia": id_transferencia, "idOrigem": id_origem, "idDestino": id_destino, "valor": valor})
            return jsonify({"mensagem": "Transferência concluída (mesma agência).", "status": "concluida", "idTransferencia": id_transferencia})

        estado["pendentes"][id_transferencia] = {
            "agenciaDestino": agencia_destino,
            "mensagem": {
                "idTransferencia": id_transferencia,
                "idConta": id_destino,
                "idOrigem": id_origem,
                "valor": valor,
                "vetorEnvio": estado["relogio"].ao_enviar(),
                "origemAgencia": estado["id_agencia"],
            },
        }
        estado["em_envio"].add(id_transferencia)

    if enviar_pendente(estado, id_transferencia, reservada=True):
        return jsonify({"mensagem": "Transferência publicada para a agência de destino (entrega assíncrona).", "status": "publicada", "idTransferencia": id_transferencia})

    with estado["trava"]:
        estado["registro"].registrar("TRANSFERENCIA_PENDENTE", estado["relogio"].evento_local(), {"idTransferencia": id_transferencia, "idOrigem": id_origem, "idDestino": id_destino, "valor": valor})
    return jsonify({"mensagem": "Broker indisponível. Transferência aceita e será publicada assim que o broker voltar.", "status": "pendente", "idTransferencia": id_transferencia}), 202


def enviar_pendente(estado, id_transferencia, reservada=False):
    with estado["trava"]:
        item = estado["pendentes"].get(id_transferencia)
        if item is None:
            return True
        if not reservada:
            if id_transferencia in estado["em_envio"]:
                return False
            estado["em_envio"].add(id_transferencia)

    try:
        mensageria.publicar(item["agenciaDestino"], item["mensagem"])
        publicada = True
    except Exception:
        publicada = False

    with estado["trava"]:
        estado["em_envio"].discard(id_transferencia)
        if publicada and estado["pendentes"].pop(id_transferencia, None) is not None:
            mensagem = item["mensagem"]
            estado["registro"].registrar("TRANSFERENCIA_PUBLICADA", mensagem["vetorEnvio"], {
                "idTransferencia": id_transferencia,
                "idOrigem": mensagem["idOrigem"],
                "idDestino": mensagem["idConta"],
                "valor": mensagem["valor"],
                "agenciaDestino": item["agenciaDestino"],
            })
    return publicada


def reenviar_pendentes(estado):
    while True:
        time.sleep(3)
        with estado["trava"]:
            ids = list(estado["pendentes"])
        for id_transferencia in ids:
            enviar_pendente(estado, id_transferencia)


def processar_credito_remoto(estado, envelope):
    mensagem = mensageria.verificar(envelope)
    if mensagem is None:
        with estado["trava"]:
            estado["registro"].registrar("MENSAGEM_INVALIDA", estado["relogio"].evento_local(), {"motivo": "assinatura invalida"})
        return False

    id_transferencia = mensagem.get("idTransferencia")
    id_conta = mensagem["idConta"]
    valor = mensagem["valor"]
    origem = mensagem["origemAgencia"]
    detalhes = {"idTransferencia": id_transferencia, "idConta": id_conta, "valor": valor, "origemAgencia": origem}

    with estado["trava"]:
        vetor = estado["relogio"].ao_receber(mensagem["vetorEnvio"])
        if id_transferencia is not None and id_transferencia in estado["processadas"]:
            estado["registro"].registrar("CREDITO_REMOTO_DUPLICADO", vetor, detalhes)
            return True
        conta = estado["contas"].get(id_conta)
        if not conta:
            estado["registro"].registrar("CREDITO_REMOTO_FALHOU", vetor, {**detalhes, "motivo": "conta nao encontrada"})
            return False
        conta["saldo"] += valor
        if id_transferencia is not None:
            estado["processadas"].add(id_transferencia)
        estado["registro"].registrar("TRANSFERENCIA_CREDITO_REMOTO", vetor, detalhes)
        return True
