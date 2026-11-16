import os
import threading
import time

import requests

import config
from services import mensageria

TIMEOUT_S = int(os.environ.get("BULLY_TIMEOUT_MS", "1000")) / 1000
HEARTBEAT_S = int(os.environ.get("HEARTBEAT_MS", "3000")) / 1000


class ServicoBully:
    def __init__(self, id_agencia, relogio, registro, trava):
        self.id_agencia = id_agencia
        self.relogio = relogio
        self.registro = registro
        self.trava = trava
        self.lider = None
        self.desde = None
        self.ativas = {a["id"]: a["id"] == id_agencia for a in config.AGENCIAS}
        self._em_andamento = False
        self._guarda = threading.Lock()

    def _registrar(self, tipo, detalhes, receber=None):
        with self.trava:
            if receber is not None:
                vetor = self.relogio.ao_receber(receber)
            else:
                vetor = self.relogio.evento_local()
            self.registro.registrar(tipo, vetor, detalhes)
            return vetor

    def _vetor_envio(self):
        with self.trava:
            return self.relogio.ao_enviar()

    def _post(self, agencia, caminho, corpo):
        envelope = mensageria.envelope_assinado(corpo)
        return requests.post(f"{agencia['url']}{caminho}", json=envelope, timeout=TIMEOUT_S)

    def _maiores(self):
        return [a for a in config.AGENCIAS if a["id"] > self.id_agencia]

    def iniciar_eleicao(self):
        with self._guarda:
            if self._em_andamento:
                return
            self._em_andamento = True
        alguem_respondeu = False
        try:
            self._registrar("ELEICAO_INICIADA", {"idAgencia": self.id_agencia})
            for agencia in self._maiores():
                try:
                    resposta = self._post(agencia, "/bully/eleicao", {"origemId": self.id_agencia, "vetorEnvio": self._vetor_envio()})
                    if resposta.ok:
                        alguem_respondeu = True
                except requests.RequestException:
                    pass
        finally:
            with self._guarda:
                self._em_andamento = False
        if not alguem_respondeu:
            self.tornar_me_lider()

    def tornar_me_lider(self):
        self.lider = self.id_agencia
        self.desde = time.time()
        self._registrar("TORNOU_LIDER", {"idAgencia": self.id_agencia})
        for agencia in config.AGENCIAS:
            if agencia["id"] == self.id_agencia:
                continue
            try:
                self._post(agencia, "/bully/coordenador", {"liderId": self.id_agencia, "vetorEnvio": self._vetor_envio()})
            except requests.RequestException:
                pass

    def receber_eleicao(self, origem_id, vetor_recebido):
        self._registrar("ELEICAO_RECEBIDA", {"de": origem_id, "minhaId": self.id_agencia}, receber=vetor_recebido)
        threading.Thread(target=self.iniciar_eleicao, daemon=True).start()

    def receber_coordenador(self, lider_id, vetor_recebido):
        self.lider = lider_id
        self.desde = time.time()
        self._registrar("LIDER_ANUNCIADO", {"liderId": lider_id, "agencia": self.id_agencia}, receber=vetor_recebido)

    def estado_publico(self):
        return {
            "idAgencia": self.id_agencia,
            "liderAtual": self.lider,
            "desde": self.desde,
            "ativas": {str(i): ativa for i, ativa in self.ativas.items()},
        }

    def _sondar(self):
        for agencia in config.AGENCIAS:
            if agencia["id"] == self.id_agencia:
                self.ativas[agencia["id"]] = True
                continue
            try:
                requests.get(f"{agencia['url']}/bully/lider", timeout=TIMEOUT_S).raise_for_status()
                self.ativas[agencia["id"]] = True
            except requests.RequestException:
                self.ativas[agencia["id"]] = False

    def verificar_lider(self):
        self._sondar()
        if self.lider is None:
            self.iniciar_eleicao()
            return
        if self.lider == self.id_agencia:
            return
        if not self.ativas.get(self.lider, False):
            self._registrar("LIDER_NAO_RESPONDEU", {"liderAtual": self.lider, "agencia": self.id_agencia})
            self.lider = None
            self.desde = None
            self.iniciar_eleicao()

    def iniciar(self, atraso_inicial_s=1.5):
        def executar():
            time.sleep(atraso_inicial_s)
            self.iniciar_eleicao()
            while True:
                time.sleep(HEARTBEAT_S)
                try:
                    self.verificar_lider()
                except Exception as erro:
                    print(f"[bully] erro no heartbeat: {erro}")

        threading.Thread(target=executar, daemon=True).start()
