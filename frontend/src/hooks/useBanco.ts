"use client";

import { useCallback, useEffect, useState } from "react";
import { api, ErroApi } from "@/lib/api";
import { sessao, type Conta } from "@/lib/session";

const TITULOS_TRANSFERENCIA = {
  concluida: "Transferência concluída",
  publicada: "Transferência enviada",
  pendente: "Transferência aceita",
};

export type Aviso = { tipo: "erro" | "ok"; texto: string } | null;
export type Resultado = { tipo: "erro" | "ok"; titulo: string; texto: string } | null;

export function useBanco() {
  const [pronto, setPronto] = useState(false);
  const [autenticado, setAutenticado] = useState(false);
  const [agenciaId, setAgenciaId] = useState(0);
  const [conta, setConta] = useState<Conta | null>(null);
  const [aviso, setAviso] = useState<Aviso>(null);
  const [resultado, setResultado] = useState<Resultado>(null);
  const [carregando, setCarregando] = useState<string | null>(null);

  useEffect(() => {
    setAgenciaId(sessao.lerAgencia());
    setAutenticado(Boolean(sessao.lerToken()));
    setPronto(true);
  }, []);

  const encerrar = useCallback((motivo?: string) => {
    sessao.limparToken();
    setAutenticado(false);
    setConta(null);
    setResultado(null);
    setAviso(motivo ? { tipo: "erro", texto: motivo } : null);
  }, []);

  const tratar = useCallback(
    (erro: unknown, ondeMostrar: (a: Aviso) => void) => {
      if (erro instanceof ErroApi && erro.status === 401 && sessao.lerToken()) {
        encerrar("Sua sessão expirou. Entre novamente.");
        return;
      }
      const texto = erro instanceof Error ? erro.message : "Erro inesperado.";
      ondeMostrar({ tipo: "erro", texto });
    },
    [encerrar],
  );

  const trocarAgencia = useCallback((id: number) => {
    setAgenciaId(id);
    sessao.gravarAgencia(id);
    setConta(null);
    setAviso({ tipo: "ok", texto: `Porta de entrada: Agência ${id}.` });
  }, []);

  const entrar = useCallback(
    async (usuario: string, senha: string) => {
      setCarregando("entrar");
      setAviso(null);
      try {
        const { token } = await api.login(agenciaId, usuario.trim(), senha);
        sessao.gravarToken(token);
        setAutenticado(true);
        setConta(null);
        setResultado(null);
      } catch (erro) {
        tratar(erro, setAviso);
      } finally {
        setCarregando(null);
      }
    },
    [agenciaId, tratar],
  );

  const consultar = useCallback(
    async (id: number) => {
      setCarregando("consultar");
      setAviso(null);
      try {
        setConta(await api.consultarConta(agenciaId, id));
      } catch (erro) {
        setConta(null);
        tratar(erro, setAviso);
      } finally {
        setCarregando(null);
      }
    },
    [agenciaId, tratar],
  );

  const movimentar = useCallback(
    async (tipo: "deposito" | "saque", id: number, valor: number) => {
      setCarregando(tipo);
      setAviso(null);
      try {
        const atualizada =
          tipo === "deposito"
            ? await api.depositar(agenciaId, id, valor)
            : await api.sacar(agenciaId, id, valor);
        setConta(atualizada);
        setAviso({ tipo: "ok", texto: `${tipo === "deposito" ? "Depósito" : "Saque"} aplicado.` });
      } catch (erro) {
        tratar(erro, setAviso);
      } finally {
        setCarregando(null);
      }
    },
    [agenciaId, tratar],
  );

  const transferir = useCallback(
    async (origem: number, destino: number, valor: number) => {
      setCarregando("transferir");
      setAviso(null);
      setResultado(null);
      try {
        const r = await api.transferir(agenciaId, origem, destino, valor);
        setResultado({
          tipo: "ok",
          titulo: TITULOS_TRANSFERENCIA[r.status],
          texto: `${r.mensagem} (origem ${origem} → destino ${destino}, ${valor})`,
        });
        if (conta?.id === origem) await consultar(origem);
      } catch (erro) {
        if (erro instanceof ErroApi && erro.status === 401 && sessao.lerToken()) {
          tratar(erro, setAviso);
        } else if (erro instanceof ErroApi && erro.status === 502) {
          setResultado({ tipo: "erro", titulo: "Falha entre agências", texto: (erro as Error).message });
        } else {
          const texto = erro instanceof Error ? erro.message : "Erro inesperado.";
          setResultado({ tipo: "erro", titulo: "Transferência não realizada", texto });
        }
      } finally {
        setCarregando(null);
      }
    },
    [agenciaId, conta, consultar, tratar],
  );

  return {
    pronto,
    autenticado,
    agenciaId,
    conta,
    aviso,
    resultado,
    carregando,
    trocarAgencia,
    entrar,
    consultar,
    movimentar,
    transferir,
    sair: () => encerrar(),
  };
}
