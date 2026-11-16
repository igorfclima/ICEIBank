export function Pontos({ className = "" }: { className?: string }) {
  return (
    <span className={`inline-flex items-center gap-1 ${className}`} aria-hidden="true">
      <span className="h-2 w-2 rounded-full bg-ag0" />
      <span className="h-2 w-2 rounded-full bg-ag1" />
      <span className="h-2 w-2 rounded-full bg-ag2" />
    </span>
  );
}

export function Marca({ className = "", pontos = true }: { className?: string; pontos?: boolean }) {
  return (
    <span
      className={`inline-flex items-center gap-2 font-bold tracking-tight ${className}`}
      style={{ fontStretch: "112%" }}
    >
      ICEIBank
      {pontos && <Pontos />}
    </span>
  );
}
