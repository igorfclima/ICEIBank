import json
import os
import sys

BASE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(BASE, "src"))

from services import mensageria

CAMINHO = os.path.join(BASE, "data", "auditoria.jsonl")

if not mensageria.url_configurada():
    print("Defina a variável de ambiente RABBITMQ_URL com a URL AMQP da instância CloudAMQP.")
    sys.exit(1)

os.makedirs(os.path.dirname(CAMINHO), exist_ok=True)

vistos = set()
if os.path.exists(CAMINHO):
    with open(CAMINHO, encoding="utf-8") as f:
        vistos = {json.loads(linha).get("idEvento") for linha in f if linha.strip()}


def registrar(envelope):
    evento = mensageria.verificar(envelope)
    if evento is None:
        print("[auditoria] evento com assinatura inválida descartado")
        return False
    if evento.get("idEvento") in vistos:
        return True
    with open(CAMINHO, "a", encoding="utf-8") as f:
        f.write(json.dumps(evento, ensure_ascii=False) + "\n")
    vistos.add(evento.get("idEvento"))
    print(f"[auditoria] {evento['agencia']} vetor={evento['timestampVetorial']} {evento['tipo']}")
    return True


print("[auditoria] aguardando eventos")
mensageria.consumir_auditoria(registrar)
