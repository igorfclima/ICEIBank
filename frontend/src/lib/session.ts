const CHAVE_TOKEN = "iceibank.token";
const CHAVE_AGENCIA = "iceibank.agencia";

export type Conta = { id: number; nomeAluno: string | null; saldo: number; dono?: string | null };

export const sessao = {
  lerToken(): string | null {
    if (typeof window === "undefined") return null;
    return window.localStorage.getItem(CHAVE_TOKEN);
  },
  gravarToken(token: string) {
    window.localStorage.setItem(CHAVE_TOKEN, token);
  },
  limparToken() {
    window.localStorage.removeItem(CHAVE_TOKEN);
  },
  lerAgencia(): number {
    if (typeof window === "undefined") return 0;
    return Number(window.localStorage.getItem(CHAVE_AGENCIA) ?? 0);
  },
  gravarAgencia(id: number) {
    window.localStorage.setItem(CHAVE_AGENCIA, String(id));
  },
};
