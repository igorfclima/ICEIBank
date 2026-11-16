"use client";

import { useCallback, useEffect, useRef, useState } from "react";
import { api, ErroApi } from "@/lib/api";
import { sessao, type Conta, type Evento } from "@/lib/session";

const TITULOS_TRANSFERENCIA = {
  concluida: "Transferência concluída",
  publicada: "Transferência enviada",
  pendente: "Transferência aceita",
};

const INTERVALO_LIDERANCA_MS = 5000;

export type Aviso = { tipo: "erro" | "ok"; texto: string } | null;
export type Resultado = { tipo: "erro" | "ok"; titulo: string; texto: string } | null;

export type EstadoLideranca =
  | { estado: "carregando"; ativas: Record<number, boolean> }
  | { estado: "sem-resposta"; ultimoLider: number | null; ativas: Record<number, boolean> }
  | { estado: "eleicao"; ativas: Record<number, boolean> }
  | { estado: "lider"; lider: number; desde: number | null; ativas: Record<number, boolean> };

export function useBanco() {
  const [pronto, setPronto] = useState(false);
  const [autenticado, setAutenticado] = useState(false);
  const [agenciaId, setAgenciaId] = useState(0);
  const [conta, setConta] = useState<Conta | null>(null);
  const [historico, setHistorico] = useState<Evento[]>([]);
  const [aviso, setAviso] = useState<Aviso>(null);
  const [resultado, setResultado] = useState<Resultado>(null);
  const [carregando, setCarregando] = useState<string | null>(null);
  const [lideranca, setLideranca] = useState<EstadoLideranca>({ estado: "carregando", ativas: {} });
  const ultimoLider = useRef<number | null>(null);

  useEffect(() => {
    setAgenciaId(sessao.lerAgencia());
    setAutenticado(Boolean(sessao.lerToken()));
    setPronto(true);
  }, []);

  useEffect(() => {
    document.documentElement.dataset.ag = String(agenciaId);
  }, [agenciaId]);

  useEffect(() => {
    if (!autenticado) return;
    let ativo = true;

    async function consultar() {
      if (document.hidden) return;
      const { respostas, ativas } = await api.lideranca();
      if (!ativo) return;
      if (respostas.length === 0) {
        setLideranca({ estado: "sem-resposta", ultimoLider: ultimoLider.current, ativas });
        return;
      }
      const lideres = Array.from(new Set(respostas.map((r) => r.liderAtual).filter((l): l is number => l !== null)));
      if (lideres.length !== 1) {
        setLideranca({ estado: "eleicao", ativas });
        return;
      }
      const lider = lideres[0];
      const registroDoLider = respostas.find((r) => r.idAgencia === lider);
      const desde = registroDoLider?.desde ?? respostas.find((r) => r.liderAtual === lider)?.desde ?? null;
      ultimoLider.current = lider;
      setLideranca({ estado: "lider", lider, desde, ativas });
    }

    consultar();
    const timer = setInterval(consultar, INTERVALO_LIDERANCA_MS);
    return () => {
      ativo = false;
      clearInterval(timer);
    };
  }, [autenticado]);

  const encerrar = useCallback((motivo?: string) => {
    sessao.limparToken();
    setAutenticado(false);
    setConta(null);
    setHistorico([]);
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
    setHistorico([]);
    setAviso({ tipo: "ok", texto: `Agência de entrada: ${id}.` });
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

  const carregarHistorico = useCallback(
    async (id: number) => {
      try {
        setHistorico((await api.historico(agenciaId, id)).eventos);
      } catch {
        setHistorico([]);
      }
    },
    [agenciaId],
  );

  const consultar = useCallback(
    async (id: number) => {
      setCarregando("consultar");
      setAviso(null);
      try {
        setConta(await api.consultarConta(agenciaId, id));
        await carregarHistorico(id);
      } catch (erro) {
        setConta(null);
        setHistorico([]);
        tratar(erro, setAviso);
      } finally {
        setCarregando(null);
      }
    },
    [agenciaId, carregarHistorico, tratar],
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
        await carregarHistorico(id);
        setAviso({ tipo: "ok", texto: `${tipo === "deposito" ? "Depósito" : "Saque"} aplicado.` });
      } catch (erro) {
        tratar(erro, setAviso);
      } finally {
        setCarregando(null);
      }
    },
    [agenciaId, carregarHistorico, tratar],
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
          texto: `${r.mensagem} Origem ${origem}, destino ${destino}, valor ${valor}.`,
        });
        if (conta?.id === origem) await consultar(origem);
      } catch (erro) {
        if (erro instanceof ErroApi && erro.status === 401 && sessao.lerToken()) {
          tratar(erro, setAviso);
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
    historico,
    aviso,
    resultado,
    carregando,
    lideranca,
    trocarAgencia,
    entrar,
    consultar,
    movimentar,
    transferir,
    sair: () => encerrar(),
  };
}
