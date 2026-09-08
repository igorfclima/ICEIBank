class RelogioLamport:
    def __init__(self):
        self.contador = 0

    def evento_local(self):
        self.contador += 1
        return self.contador

    def ao_enviar(self):
        self.contador += 1
        return self.contador

    def ao_receber(self, timestamp_recebido):
        self.contador = max(self.contador, timestamp_recebido) + 1
        return self.contador
