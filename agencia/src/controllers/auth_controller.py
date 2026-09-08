from flask import jsonify, request

import config
from services.auth import gerar_token


def login():
    dados = request.get_json(silent=True) or {}
    usuario = dados.get("usuario")
    senha = dados.get("senha")

    if config.USUARIOS.get(usuario) != senha or senha is None:
        return jsonify({"erro": "Credenciais inválidas."}), 401

    return jsonify({"token": gerar_token(usuario)})
