import json
import os
from datetime import datetime, timezone

DATA_DIR = os.path.join(os.path.dirname(__file__), "..", "..", "data")


class RegistroEventos:
    def __init__(self, nome_agencia):
        self.nome_agencia = nome_agencia
        self.caminho_arquivo = os.path.join(DATA_DIR, f"eventos-{nome_agencia}.jsonl")
        os.makedirs(DATA_DIR, exist_ok=True)

    def registrar(self, tipo, timestamp_lamport, detalhes):
        evento = {
            "agencia": self.nome_agencia,
            "tipo": tipo,
            "timestampLamport": timestamp_lamport,
            "horaParede": datetime.now(timezone.utc).isoformat(),
            "detalhes": detalhes,
        }
        with open(self.caminho_arquivo, "a", encoding="utf-8") as f:
            f.write(json.dumps(evento) + "\n")
        print(f"[Lamport {timestamp_lamport}] {tipo}", detalhes)
        return evento
