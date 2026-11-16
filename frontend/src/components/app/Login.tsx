"use client";

import { useState } from "react";
import Link from "next/link";
import { AGENCIAS } from "@/lib/config";
import { Marca } from "@/components/Marca";
import { Banner, Botao, Campo } from "@/components/compartilhado/ui";
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
  const [usuario, setUsuario] = useState("");
  const [senha, setSenha] = useState("");

  return (
    <div className="mx-auto flex min-h-screen max-w-md flex-col justify-center px-4 py-12">
      <Link href="/" className="mb-8 self-start text-sm text-tinta-2 underline underline-offset-4">
        Voltar ao site
      </Link>
      <div className="border border-regua">
        <div className="bg-ativa px-6 py-4 text-sobre-ativa">
          <Marca className="text-xl" pontos={false} />
        </div>
        <form
          className="p-6"
          onSubmit={(e) => {
            e.preventDefault();
            onEntrar(usuario, senha);
          }}
        >
          <h1 className="manchete mb-6">Entrar</h1>

          <label className="mb-4 flex flex-col gap-1">
            <span className="rotulo">Agência de entrada</span>
            <select
              value={agenciaId}
              onChange={(e) => onTrocarAgencia(Number(e.target.value))}
              className="min-h-12 w-full rounded-xs border border-tinta-2 bg-papel px-3 text-base"
            >
              {AGENCIAS.map((a) => (
                <option key={a.id} value={a.id}>
                  {a.rotulo}
                </option>
              ))}
            </select>
          </label>

          <Campo rotulo="Usuário" value={usuario} onChange={(e) => setUsuario(e.target.value)} autoComplete="username" />
          <Campo rotulo="Senha" type="password" value={senha} onChange={(e) => setSenha(e.target.value)} autoComplete="current-password" />

          <Botao type="submit" disabled={ocupado || usuario === "" || senha === ""}>
            {ocupado ? "Entrando…" : "Entrar"}
          </Botao>

          {aviso && (
            <div className="mt-4">
              <Banner tipo={aviso.tipo}>{aviso.texto}</Banner>
            </div>
          )}
        </form>
      </div>
    </div>
  );
}
