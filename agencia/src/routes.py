from flask import Blueprint

from controllers import auth_controller, contas_controller, transferencias_controller
from services.auth import requer_autenticacao

router = Blueprint("router", __name__)

router.add_url_rule("/auth/login", view_func=auth_controller.login, methods=["POST"])

router.add_url_rule("/contas", view_func=requer_autenticacao(contas_controller.criar_conta), methods=["POST"])
router.add_url_rule("/contas/<int:id_conta>", view_func=requer_autenticacao(contas_controller.consultar_saldo), methods=["GET"])
router.add_url_rule("/contas/<int:id_conta>/depositar", view_func=requer_autenticacao(contas_controller.depositar), methods=["POST"])
router.add_url_rule("/contas/<int:id_conta>/sacar", view_func=requer_autenticacao(contas_controller.sacar), methods=["POST"])

router.add_url_rule("/transferencias", view_func=requer_autenticacao(transferencias_controller.transferir), methods=["POST"])
router.add_url_rule("/contas/<int:id_conta>/creditar-remoto", view_func=requer_autenticacao(transferencias_controller.creditar_remoto), methods=["POST"])
