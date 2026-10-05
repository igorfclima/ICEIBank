import json
import os
import uuid
from datetime import datetime, timezone

DATA_DIR = os.path.join(os.path.dirname(__file__), "..", "..", "data")


class RegistroEventos:
    def __init__(self, nome_agencia, ao_registrar=None):
        self.nome_agencia = nome_agencia
        self.ao_registrar = ao_registrar
        self.caminho_arquivo = os.path.join(DATA_DIR, f"eventos-{nome_agencia}.jsonl")
        os.makedirs(DATA_DIR, exist_ok=True)

    def registrar(self, tipo, timestamp_vetorial, detalhes):
        evento = {
            "idEvento": uuid.uuid4().hex,
            "agencia": self.nome_agencia,
            "tipo": tipo,
            "timestampVetorial": timestamp_vetorial,
            "horaParede": datetime.now(timezone.utc).isoformat(),
            "detalhes": detalhes,
        }
        with open(self.caminho_arquivo, "a", encoding="utf-8") as f:
            f.write(json.dumps(evento, ensure_ascii=False) + "\n")
        print(f"[Vetor {timestamp_vetorial}] {tipo} {detalhes}")
        if self.ao_registrar:
            self.ao_registrar(evento)
        return evento

    def listar(self):
        if not os.path.exists(self.caminho_arquivo):
            return []
        with open(self.caminho_arquivo, encoding="utf-8") as f:
            return [json.loads(linha) for linha in f if linha.strip()]
