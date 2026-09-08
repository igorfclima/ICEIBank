from datetime import datetime, timedelta, timezone
from functools import wraps

import jwt
from flask import jsonify, request

import config


def gerar_token(usuario):
    agora = datetime.now(timezone.utc)
    payload = {
        "sub": usuario,
        "iat": agora,
        "exp": agora + timedelta(seconds=config.JWT_EXPIRACAO_SEGUNDOS),
    }
    return jwt.encode(payload, config.JWT_SECRET, algorithm="HS256")


def validar_token(token):
    return jwt.decode(token, config.JWT_SECRET, algorithms=["HS256"])


def requer_autenticacao(view):
    @wraps(view)
    def wrapper(*args, **kwargs):
        cabecalho = request.headers.get("Authorization", "")
        if not cabecalho.startswith("Bearer "):
            return jsonify({"erro": "Token ausente."}), 401
        try:
            validar_token(cabecalho[7:])
        except jwt.PyJWTError:
            return jsonify({"erro": "Token inválido ou expirado."}), 401
        return view(*args, **kwargs)

    return wrapper
