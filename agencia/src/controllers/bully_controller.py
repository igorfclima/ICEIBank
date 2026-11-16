import threading

from flask import current_app, g, jsonify, request

from services import mensageria


def _bully():
    return current_app.config["ESTADO"]["bully"]


def _corpo_verificado():
    corpo = mensageria.verificar(request.get_json(silent=True) or {})
    if corpo is None:
        return None, (jsonify({"erro": "Assinatura inválida."}), 403)
    return corpo, None


def eleicao():
    corpo, erro = _corpo_verificado()
    if erro:
        return erro
    _bully().receber_eleicao(corpo["origemId"], corpo["vetorEnvio"])
    return jsonify({"ok": True})


def coordenador():
    corpo, erro = _corpo_verificado()
    if erro:
        return erro
    _bully().receber_coordenador(corpo["liderId"], corpo["vetorEnvio"])
    return jsonify({"ok": True})


def lider():
    return jsonify(_bully().estado_publico())


def forcar_eleicao():
    if g.papel != "operador":
        return jsonify({"erro": "Apenas operadores forçam eleições."}), 403
    threading.Thread(target=_bully().iniciar_eleicao, daemon=True).start()
    return jsonify({"ok": True})
