import glob
import json
import os
import sys

BASE = os.path.dirname(os.path.abspath(__file__))
PASTA_DADOS = os.path.join(BASE, "data")
sys.path.insert(0, os.path.join(BASE, "src"))

from services.comparar_vetores import comparar_vetores


padrao = "auditoria.jsonl" if "--central" in sys.argv else "eventos-*.jsonl"
todos_eventos = []
for arquivo in glob.glob(os.path.join(PASTA_DADOS, padrao)):
    with open(arquivo, encoding="utf-8") as f:
        for linha in f:
            linha = linha.strip()
            if linha:
                evento = json.loads(linha)
                if "timestampVetorial" in evento:
                    todos_eventos.append(evento)

todos_eventos.sort(key=lambda e: e["horaParede"])

print("=== Linha do tempo (ordenada por hora de parede) ===")
for evento in todos_eventos:
    print(
        f"[{evento['agencia']}] vetor={evento['timestampVetorial']} {evento['tipo']} "
        f"{json.dumps(evento['detalhes'], ensure_ascii=False)}"
    )

print("\n=== Pares de eventos CONCORRENTES entre agências diferentes ===")
encontrou = False
for i, e1 in enumerate(todos_eventos):
    for e2 in todos_eventos[i + 1:]:
        if e1["agencia"] == e2["agencia"]:
            continue
        if comparar_vetores(e1["timestampVetorial"], e2["timestampVetorial"]) == "CONCORRENTES":
            encontrou = True
            print(
                f"[{e1['agencia']}] {e1['tipo']} ({e1['timestampVetorial']}) x "
                f"[{e2['agencia']}] {e2['tipo']} ({e2['timestampVetorial']})"
            )

if not encontrou:
    print("(nenhum par concorrente encontrado nesta execução - gere mais eventos em paralelo e rode de novo)")
