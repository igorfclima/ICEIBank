import { Nav } from "@/components/landing/Nav";
import { Hero } from "@/components/landing/Hero";
import { Faixa } from "@/components/landing/Faixa";
import { Recursos } from "@/components/landing/Recursos";
import { Seguranca } from "@/components/landing/Seguranca";
import { Agencias } from "@/components/landing/Agencias";
import { LinhaDoTempo } from "@/components/landing/LinhaDoTempo";
import { Depoimentos } from "@/components/landing/Depoimentos";
import { ChamadaFinal } from "@/components/landing/ChamadaFinal";
import { Rodape } from "@/components/landing/Rodape";

export default function Home() {
  return (
    <main>
      <Nav />
      <Hero />
      <Faixa />
      <Recursos />
      <Seguranca />
      <Agencias />
      <LinhaDoTempo />
      <Depoimentos />
      <ChamadaFinal />
      <Rodape />
    </main>
  );
}
