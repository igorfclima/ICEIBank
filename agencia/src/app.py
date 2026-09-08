import os
import sys
from urllib.parse import urlparse

sys.path.insert(0, os.path.dirname(__file__))

from flask import Flask

import config
from routes import router
from services.event_log import RegistroEventos
from services.lamport_clock import RelogioLamport

id_agencia = int(os.environ.get("AGENCIA_ID", "0"))
agencia_config = next((a for a in config.AGENCIAS if a["id"] == id_agencia), None)

if not agencia_config:
    print(f"Agência {id_agencia} não configurada em config.py")
    sys.exit(1)

app = Flask(__name__)
app.config["ESTADO"] = {
    "id_agencia": id_agencia,
    "relogio": RelogioLamport(),
    "registro": RegistroEventos(f"agencia-{id_agencia}"),
    "contas": {},
}
app.register_blueprint(router)

if __name__ == "__main__":
    porta = urlparse(agencia_config["url"]).port
    print(f"[Agência {id_agencia}] ouvindo na porta {porta}")
    app.run(port=porta)
