import hmac

from flask import jsonify, request

import config
from services.auth import gerar_token


def login():
    dados = request.get_json(silent=True) or {}
    usuario = dados.get("usuario")
    senha = dados.get("senha")

    cadastro = config.USUARIOS.get(usuario) if isinstance(usuario, str) else None
    if not cadastro or not isinstance(senha, str) or not hmac.compare_digest(cadastro["senha"].encode(), senha.encode()):
        return jsonify({"erro": "Credenciais inválidas."}), 401

    return jsonify({"token": gerar_token(usuario, cadastro["papel"])})
