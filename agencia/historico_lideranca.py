import glob
import json
import os
import sys
from datetime import datetime

PASTA_DADOS = os.path.join(os.path.dirname(os.path.abspath(__file__)), "data")
TIPOS_BULLY = ["ELEICAO_INICIADA", "ELEICAO_RECEBIDA", "TORNOU_LIDER", "LIDER_ANUNCIADO", "LIDER_NAO_RESPONDEU"]

padrao = "auditoria.jsonl" if "--central" in sys.argv else "eventos-*.jsonl"
eventos = []
for arquivo in glob.glob(os.path.join(PASTA_DADOS, padrao)):
    with open(arquivo, encoding="utf-8") as f:
        for linha in f:
            linha = linha.strip()
            if linha:
                evento = json.loads(linha)
                if evento["tipo"] in TIPOS_BULLY:
                    eventos.append(evento)

eventos.sort(key=lambda e: e["horaParede"])


def hora(texto):
    return datetime.fromisoformat(texto).astimezone().strftime("%H:%M:%S.%f")[:-3]


print("=== Histórico de eventos de eleição ===")
for e in eventos:
    print(f"({hora(e['horaParede'])}) [{e['agencia']}] vetor={e['timestampVetorial']} {e['tipo']} {json.dumps(e['detalhes'], ensure_ascii=False)}")

print("\n=== Linha do tempo de líderes ===")
lideres = [e for e in eventos if e["tipo"] == "TORNOU_LIDER"]
for e in lideres:
    print(f"A partir de {hora(e['horaParede'])}: Agência {e['detalhes']['idAgencia']} é a líder")

print(f"\nTrocas de liderança registradas: {len(lideres)}")
print(f"Mensagens de eleição recebidas: {sum(1 for e in eventos if e['tipo'] == 'ELEICAO_RECEBIDA')}")
