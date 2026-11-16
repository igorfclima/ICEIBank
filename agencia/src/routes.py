from flask import Blueprint

from controllers import auth_controller, bully_controller, contas_controller, transferencias_controller
from services.auth import requer_autenticacao

router = Blueprint("router", __name__)

router.add_url_rule("/auth/login", view_func=auth_controller.login, methods=["POST"])

router.add_url_rule("/contas", view_func=requer_autenticacao(contas_controller.criar_conta), methods=["POST"])
router.add_url_rule("/contas/<int:id_conta>", view_func=requer_autenticacao(contas_controller.consultar_saldo), methods=["GET"])
router.add_url_rule("/contas/<int:id_conta>/historico", view_func=requer_autenticacao(contas_controller.historico), methods=["GET"])
router.add_url_rule("/contas/<int:id_conta>/depositar", view_func=requer_autenticacao(contas_controller.depositar), methods=["POST"])
router.add_url_rule("/contas/<int:id_conta>/sacar", view_func=requer_autenticacao(contas_controller.sacar), methods=["POST"])

router.add_url_rule("/transferencias", view_func=requer_autenticacao(transferencias_controller.transferir), methods=["POST"])

router.add_url_rule("/contas/<int:id_conta>/sincronizar", view_func=requer_autenticacao(contas_controller.sincronizar_operacao_pendente), methods=["POST"])

router.add_url_rule("/bully/eleicao", view_func=bully_controller.eleicao, methods=["POST"])
router.add_url_rule("/bully/coordenador", view_func=bully_controller.coordenador, methods=["POST"])
router.add_url_rule("/bully/lider", view_func=bully_controller.lider, methods=["GET"])
router.add_url_rule("/bully/eleicao/forcar", view_func=requer_autenticacao(bully_controller.forcar_eleicao), methods=["POST"])
