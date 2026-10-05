import hashlib
import hmac
import json
import os
import queue
import threading
import time

import pika

import config

EXCHANGE = "iceibank.eventos"
EXCHANGE_MORTAS = "iceibank.mortas"
FILA_MORTAS = "fila-mortas"
FILA_AUDITORIA = "fila-auditoria"
PROPRIEDADES = pika.BasicProperties(delivery_mode=2, content_type="application/json")

_eventos = queue.Queue()


def url_configurada():
    return os.environ.get("RABBITMQ_URL")


def _conectar():
    return pika.BlockingConnection(pika.URLParameters(url_configurada()))


def _assinatura(corpo):
    texto = json.dumps(corpo, sort_keys=True, separators=(",", ":")).encode()
    return hmac.new(config.SEGREDO_MENSAGENS.encode(), texto, hashlib.sha256).hexdigest()


def _envelope(corpo):
    return json.dumps({"corpo": corpo, "assinatura": _assinatura(corpo)}).encode()


def verificar(envelope):
    try:
        corpo = envelope["corpo"]
        return corpo if hmac.compare_digest(_assinatura(corpo), envelope["assinatura"]) else None
    except Exception:
        return None


def _declarar_base(canal):
    canal.exchange_declare(EXCHANGE, exchange_type="topic", durable=True)
    canal.exchange_declare(EXCHANGE_MORTAS, exchange_type="fanout", durable=True)
    canal.queue_declare(FILA_MORTAS, durable=True)
    canal.queue_bind(FILA_MORTAS, EXCHANGE_MORTAS)


def _declarar_agencia(canal, id_agencia):
    _declarar_base(canal)
    fila = f"fila-agencia-{id_agencia}"
    canal.queue_declare(fila, durable=True, arguments={"x-dead-letter-exchange": EXCHANGE_MORTAS})
    canal.queue_bind(fila, EXCHANGE, f"agencia.{id_agencia}.creditar")
    return fila


def _declarar_auditoria(canal):
    _declarar_base(canal)
    canal.queue_declare(FILA_AUDITORIA, durable=True)
    canal.queue_bind(FILA_AUDITORIA, EXCHANGE, "evento.#")
    return FILA_AUDITORIA


def publicar(id_agencia_destino, mensagem):
    conexao = _conectar()
    try:
        canal = conexao.channel()
        _declarar_agencia(canal, id_agencia_destino)
        canal.confirm_delivery()
        canal.basic_publish(
            EXCHANGE,
            f"agencia.{id_agencia_destino}.creditar",
            _envelope(mensagem),
            PROPRIEDADES,
            mandatory=True,
        )
    finally:
        conexao.close()


def publicar_evento(evento):
    _eventos.put(evento)


def _gravar_cursor(caminho, id_evento):
    temporario = caminho + ".tmp"
    try:
        with open(temporario, "w", encoding="utf-8") as f:
            f.write(id_evento)
        os.replace(temporario, caminho)
    except OSError:
        pass


def iniciar_publicador_eventos(eventos_locais, caminho_cursor):
    ultimo = None
    if os.path.exists(caminho_cursor):
        with open(caminho_cursor, encoding="utf-8") as f:
            ultimo = f.read().strip()
    ids = [e.get("idEvento") for e in eventos_locais]
    inicio = ids.index(ultimo) + 1 if ultimo in ids else 0
    for evento in eventos_locais[inicio:]:
        if evento.get("idEvento"):
            _eventos.put(evento)

    def executar():
        conexao = canal = None
        while True:
            try:
                evento = _eventos.get(timeout=15)
            except queue.Empty:
                if conexao is not None:
                    try:
                        conexao.process_data_events(time_limit=0)
                    except Exception:
                        conexao = canal = None
                continue
            while True:
                try:
                    if conexao is None or conexao.is_closed:
                        conexao = _conectar()
                        canal = conexao.channel()
                        _declarar_auditoria(canal)
                        canal.confirm_delivery()
                    canal.basic_publish(
                        EXCHANGE,
                        f"evento.{evento['agencia']}",
                        _envelope(evento),
                        PROPRIEDADES,
                        mandatory=True,
                    )
                    _gravar_cursor(caminho_cursor, evento["idEvento"])
                    break
                except Exception:
                    conexao = canal = None
                    time.sleep(3)

    threading.Thread(target=executar, daemon=True).start()


def _consumir(declarar, ao_receber_mensagem):
    while True:
        try:
            conexao = _conectar()
            canal = conexao.channel()
            fila = declarar(canal)
            canal.basic_qos(prefetch_count=1)

            def callback(ch, metodo, propriedades, corpo):
                try:
                    aplicada = ao_receber_mensagem(json.loads(corpo))
                except Exception:
                    aplicada = False
                if aplicada:
                    ch.basic_ack(metodo.delivery_tag)
                else:
                    ch.basic_nack(metodo.delivery_tag, requeue=False)

            canal.basic_consume(fila, callback)
            print(f"[mensageria] consumindo {fila}")
            canal.start_consuming()
        except Exception as erro:
            print(f"[mensageria] consumidor reconectando: {erro}")
            time.sleep(3)


def assinar(id_agencia, ao_receber_mensagem):
    threading.Thread(
        target=_consumir,
        args=(lambda canal: _declarar_agencia(canal, id_agencia), ao_receber_mensagem),
        daemon=True,
    ).start()


def consumir_auditoria(ao_receber_mensagem):
    _consumir(_declarar_auditoria, ao_receber_mensagem)
