const ONDAS = Array.from({ length: 22 }, (_, i) => i);

export function Cedula() {
  return (
    <figure className="m-0">
      <svg
        viewBox="0 0 560 260"
        role="img"
        aria-label="Ilustração de uma cédula do ICEIBank com número de série e assinatura da líder"
        className="h-auto w-full"
      >
        <rect x="1" y="1" width="558" height="258" fill="#157a89" />
        <g fill="none" stroke="#fff" strokeOpacity="0.28" strokeWidth="1">
          {ONDAS.map((i) => (
            <path key={i} d={`M0 ${20 + i * 11} C 120 ${i * 11 - 10}, 200 ${60 + i * 11}, 320 ${20 + i * 11} S 500 ${i * 11}, 560 ${30 + i * 11}`} />
          ))}
        </g>
        <rect x="18" y="18" width="524" height="224" fill="none" stroke="#fff" strokeOpacity="0.9" strokeWidth="1" />
        <rect x="28" y="28" width="504" height="204" fill="none" stroke="#fff" strokeOpacity="0.45" strokeWidth="1" />
        <text x="44" y="62" fill="#fff" fontSize="14" fontWeight="600" letterSpacing="2" style={{ fontStretch: "75%" }}>
          ICEIBANK · AGÊNCIA 0
        </text>
        <text x="44" y="170" fill="#fff" fontSize="96" fontWeight="700" style={{ fontStretch: "112%" }}>
          0042
        </text>
        <rect x="372" y="84" width="150" height="92" fill="#fff" fillOpacity="0.14" stroke="#fff" strokeOpacity="0.8" />
        <text x="384" y="108" fill="#fff" fontSize="11" letterSpacing="1.5" style={{ fontStretch: "75%" }}>
          SÉRIE
        </text>
        <text x="384" y="136" fill="#fff" fontSize="18" fontFamily="var(--font-serie)">
          [7 · 2 · 0]
        </text>
        <text x="384" y="160" fill="#fff" fontSize="10" fontFamily="var(--font-serie)" fillOpacity="0.85">
          vetor da agência
        </text>
        <line x1="44" y1="212" x2="250" y2="212" stroke="#fff" strokeOpacity="0.9" />
        <text x="44" y="226" fill="#fff" fontSize="11" fontFamily="var(--font-serie)">
          Assina: Agência 2
        </text>
      </svg>
      <figcaption className="mt-2 text-xs text-tinta-2">Ilustração. O número e a série são de exemplo.</figcaption>
    </figure>
  );
}
