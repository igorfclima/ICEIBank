export const PORTA_BASE = Number(process.env.NEXT_PUBLIC_PORTA_BASE ?? 4063);

export const AGENCIAS = [0, 1, 2].map((id) => ({
  id,
  rotulo: `Agência ${id}`,
  url: `http://localhost:${PORTA_BASE + id}`,
}));

export function urlDaAgencia(id: number): string {
  return AGENCIAS.find((a) => a.id === Number(id))?.url ?? AGENCIAS[0].url;
}
