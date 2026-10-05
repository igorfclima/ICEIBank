import json
import os
import threading
import time


class TravaPersistente:
    def __init__(self, estado, caminho, ativa):
        self._trava = threading.RLock()
        self._profundidade = 0
        self._estado = estado
        self._caminho = caminho
        self._ativa = ativa
        self._ultimo = None

    def __enter__(self):
        self._trava.acquire()
        self._profundidade += 1
        return self

    def __exit__(self, tipo, valor, rastro):
        try:
            self._profundidade -= 1
            if self._ativa and self._profundidade == 0 and tipo is None:
                self._salvar()
        finally:
            self._trava.release()

    def _instantaneo(self):
        e = self._estado
        return json.dumps({
            "contas": {str(i): c for i, c in e["contas"].items()},
            "processadas": sorted(e["processadas"]),
            "pendentes": e["pendentes"],
            "vetor": list(e["relogio"].vetor),
        })

    def _salvar(self):
        texto = self._instantaneo()
        if texto == self._ultimo:
            return
        temporario = self._caminho + ".tmp"
        for tentativa in range(5):
            try:
                with open(temporario, "w", encoding="utf-8") as f:
                    f.write(texto)
                    f.flush()
                    os.fsync(f.fileno())
                os.replace(temporario, self._caminho)
                self._ultimo = texto
                return
            except OSError:
                time.sleep(0.05)
        print("[persistencia] falha ao gravar o estado, nova tentativa na proxima operacao")

    def carregar(self):
        if not self._ativa or not os.path.exists(self._caminho):
            return
        with open(self._caminho, encoding="utf-8") as f:
            dados = json.load(f)
        e = self._estado
        e["contas"].update({int(i): c for i, c in dados["contas"].items()})
        e["processadas"].update(dados["processadas"])
        e["pendentes"].update(dados["pendentes"])
        if len(dados["vetor"]) == len(e["relogio"].vetor):
            e["relogio"].vetor[:] = dados["vetor"]
        self._ultimo = self._instantaneo()
