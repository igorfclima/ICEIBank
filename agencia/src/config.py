import os

OFFSET = int(os.environ.get("OFFSET", "63"))

NUMERO_AGENCIAS = 3
PORTA_BASE = 4000 + OFFSET

AGENCIAS = [
    {"id": 0, "url": f"http://localhost:{PORTA_BASE}"},
    {"id": 1, "url": f"http://localhost:{PORTA_BASE + 1}"},
    {"id": 2, "url": f"http://localhost:{PORTA_BASE + 2}"},
]

JWT_SECRET = os.environ.get("JWT_SECRET", "iceibank-segredo-de-assinatura-jwt-2026")
JWT_EXPIRACAO_SEGUNDOS = int(os.environ.get("JWT_EXP", "3600"))

SEGREDO_MENSAGENS = os.environ.get("SEGREDO_MENSAGENS", "iceibank-segredo-de-assinatura-das-mensagens-2026")

USUARIOS = {
    os.environ.get("USUARIO", "admin"): {"senha": os.environ.get("SENHA", "admin"), "papel": "operador"},
    "ana": {"senha": "ana123", "papel": "cliente"},
    "beto": {"senha": "beto123", "papel": "cliente"},
    "caio": {"senha": "caio123", "papel": "cliente"},
}


def agencia_responsavel(id_conta):
    return id_conta % NUMERO_AGENCIAS
