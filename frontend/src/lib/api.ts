import { urlDaAgencia } from "./config";
import { sessao, type Conta } from "./session";

export class ErroApi extends Error {
  status: number;
  constructor(status: number, mensagem: string) {
    super(mensagem);
    this.status = status;
  }
}

async function requisitar<T>(
  agenciaId: number,
  caminho: string,
  opcoes: RequestInit = {},
): Promise<T> {
  const cabecalhos: Record<string, string> = { "Content-Type": "application/json" };
  const token = sessao.lerToken();
  if (token) cabecalhos["Authorization"] = `Bearer ${token}`;

  let resposta: Response;
  try {
    resposta = await fetch(urlDaAgencia(agenciaId) + caminho, { ...opcoes, headers: cabecalhos });
  } catch {
    throw new ErroApi(0, "Não foi possível contatar a agência. Ela está no ar?");
  }

  const corpo = await resposta.json().catch(() => ({}));
  if (!resposta.ok) {
    throw new ErroApi(resposta.status, corpo.erro ?? `Erro ${resposta.status}`);
  }
  return corpo as T;
}

export const api = {
  login(agenciaId: number, usuario: string, senha: string) {
    return requisitar<{ token: string }>(agenciaId, "/auth/login", {
      method: "POST",
      body: JSON.stringify({ usuario, senha }),
    });
  },
  consultarConta(agenciaId: number, id: number) {
    return requisitar<Conta>(agenciaId, `/contas/${id}`);
  },
  depositar(agenciaId: number, id: number, valor: number) {
    return requisitar<Conta>(agenciaId, `/contas/${id}/depositar`, {
      method: "POST",
      body: JSON.stringify({ valor }),
    });
  },
  sacar(agenciaId: number, id: number, valor: number) {
    return requisitar<Conta>(agenciaId, `/contas/${id}/sacar`, {
      method: "POST",
      body: JSON.stringify({ valor }),
    });
  },
  transferir(agenciaId: number, idOrigem: number, idDestino: number, valor: number) {
    return requisitar<{ mensagem: string; status: "concluida" | "publicada" | "pendente" }>(agenciaId, "/transferencias", {
      method: "POST",
      body: JSON.stringify({ idOrigem, idDestino, valor }),
    });
  },
};
