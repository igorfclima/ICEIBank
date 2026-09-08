import os

OFFSET = int(os.environ.get("OFFSET", "63"))

NUMERO_AGENCIAS = 3
PORTA_BASE = 4000 + OFFSET

AGENCIAS = [
    {"id": 0, "url": f"http://localhost:{PORTA_BASE}"},
    {"id": 1, "url": f"http://localhost:{PORTA_BASE + 1}"},
    {"id": 2, "url": f"http://localhost:{PORTA_BASE + 2}"},
]

JWT_SECRET = os.environ.get("JWT_SECRET", "iceibank-sprint1-segredo")
JWT_EXPIRACAO_SEGUNDOS = int(os.environ.get("JWT_EXP", "3600"))

USUARIOS = {
    os.environ.get("USUARIO", "admin"): os.environ.get("SENHA", "admin"),
}


def agencia_responsavel(id_conta):
    return id_conta % NUMERO_AGENCIAS
