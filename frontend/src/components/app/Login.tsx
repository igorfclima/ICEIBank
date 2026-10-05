"use client";

import { useState } from "react";
import Link from "next/link";
import { AGENCIAS } from "@/lib/config";
import { Marca } from "@/components/Marca";
import { Banner, Botao, Campo } from "./ui";
import type { Aviso } from "@/hooks/useBanco";

export function Login({
  agenciaId,
  aviso,
  ocupado,
  onTrocarAgencia,
  onEntrar,
}: {
  agenciaId: number;
  aviso: Aviso;
  ocupado: boolean;
  onTrocarAgencia: (id: number) => void;
  onEntrar: (usuario: string, senha: string) => void;
}) {
  const [usuario, setUsuario] = useState("admin");
  const [senha, setSenha] = useState("");

  return (
    <div className="mx-auto flex min-h-screen max-w-md flex-col justify-center px-5 py-16">
      <Link href="/" className="mb-8 self-start text-sm text-texto-fraco hover:text-texto">
        ← voltar ao site
      </Link>
      <div className="rounded-xl2 border border-borda bg-superficie p-8 shadow-2xl">
        <Marca className="text-xl" />
        <p className="mt-1 mb-7 text-sm text-texto-fraco">Acesso à agência</p>

        <label className="mb-4 flex flex-col gap-1.5 text-xs text-texto-fraco">
          Agência
          <select
            value={agenciaId}
            onChange={(e) => onTrocarAgencia(Number(e.target.value))}
            className="w-full rounded-xl border border-borda bg-white/[0.03] px-3.5 py-3 text-[15px] text-texto outline-none focus:border-roxo"
          >
            {AGENCIAS.map((a) => (
              <option key={a.id} value={a.id}>
                {a.rotulo}
              </option>
            ))}
          </select>
        </label>

        <Campo
          rotulo="Usuário"
          value={usuario}
          onChange={(e) => setUsuario(e.target.value)}
          autoComplete="username"
        />
        <Campo
          rotulo="Senha"
          type="password"
          value={senha}
          onChange={(e) => setSenha(e.target.value)}
          onKeyDown={(e) => e.key === "Enter" && onEntrar(usuario, senha)}
          autoComplete="current-password"
          placeholder="••••••"
        />

        <Botao disabled={ocupado} onClick={() => onEntrar(usuario, senha)}>
          {ocupado ? "Entrando…" : "Entrar"}
        </Botao>

        {aviso && (
          <div className="mt-4">
            <Banner tipo={aviso.tipo}>{aviso.texto}</Banner>
          </div>
        )}
      </div>
    </div>
  );
}
