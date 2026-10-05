import os
import sys
import threading
from datetime import datetime, timezone
from urllib.parse import urlparse

sys.path.insert(0, os.path.dirname(__file__))

from flask import Flask
from flask_cors import CORS

import config
from controllers.transferencias_controller import processar_credito_remoto, reenviar_pendentes
from routes import router
from services import mensageria
from services.event_log import DATA_DIR, RegistroEventos
from services.persistencia import TravaPersistente
from services.vector_clock import RelogioVetorial

id_agencia = int(os.environ.get("AGENCIA_ID", "0"))
agencia_config = next((a for a in config.AGENCIAS if a["id"] == id_agencia), None)

if not agencia_config:
    print(f"Agência {id_agencia} não configurada em config.py")
    sys.exit(1)

if not mensageria.url_configurada():
    print("Defina a variável de ambiente RABBITMQ_URL com a URL AMQP da instância CloudAMQP.")
    sys.exit(1)

persistencia = os.environ.get("PERSISTENCIA", "1") != "0"

app = Flask(__name__)
CORS(app)
estado = {
    "id_agencia": id_agencia,
    "relogio": RelogioVetorial(id_agencia, config.NUMERO_AGENCIAS),
    "registro": RegistroEventos(f"agencia-{id_agencia}", ao_registrar=mensageria.publicar_evento),
    "contas": {},
    "processadas": set(),
    "pendentes": {},
    "em_envio": set(),
    "historico_desde": "" if persistencia else datetime.now(timezone.utc).isoformat(),
}
estado["trava"] = TravaPersistente(estado, os.path.join(DATA_DIR, f"estado-agencia-{id_agencia}.json"), persistencia)
estado["trava"].carregar()
app.config["ESTADO"] = estado
app.register_blueprint(router)

if __name__ == "__main__":
    porta = urlparse(agencia_config["url"]).port
    mensageria.assinar(id_agencia, lambda mensagem: processar_credito_remoto(estado, mensagem))
    mensageria.iniciar_publicador_eventos(
        estado["registro"].listar(),
        os.path.join(DATA_DIR, f"auditoria-cursor-agencia-{id_agencia}.txt"),
    )
    threading.Thread(target=reenviar_pendentes, args=(estado,), daemon=True).start()
    situacao = "ligada" if persistencia else "desligada"
    print(f"[Agência {id_agencia}] persistência {situacao}, ouvindo na porta {porta}")
    app.run(port=porta)
