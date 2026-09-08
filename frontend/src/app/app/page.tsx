"use client";

import { useBanco } from "@/hooks/useBanco";
import { Login } from "@/components/app/Login";
import { Painel } from "@/components/app/Painel";

export default function AppPage() {
  const b = useBanco();

  if (!b.pronto) return null;

  return b.autenticado ? (
    <Painel {...b} />
  ) : (
    <Login
      agenciaId={b.agenciaId}
      aviso={b.aviso}
      ocupado={b.carregando === "entrar"}
      onTrocarAgencia={b.trocarAgencia}
      onEntrar={b.entrar}
    />
  );
}
