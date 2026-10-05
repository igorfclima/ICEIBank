import threading


class RelogioVetorial:
    def __init__(self, id_agencia, numero_agencias):
        self.id_agencia = id_agencia
        self.vetor = [0] * numero_agencias
        self._trava = threading.Lock()

    def evento_local(self):
        with self._trava:
            self.vetor[self.id_agencia] += 1
            return list(self.vetor)

    def ao_enviar(self):
        with self._trava:
            self.vetor[self.id_agencia] += 1
            return list(self.vetor)

    def ao_receber(self, vetor_recebido):
        with self._trava:
            for i in range(len(self.vetor)):
                self.vetor[i] = max(self.vetor[i], vetor_recebido[i])
            self.vetor[self.id_agencia] += 1
            return list(self.vetor)
