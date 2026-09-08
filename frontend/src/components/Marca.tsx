export function Glifo({ className = "h-8 w-8" }: { className?: string }) {
  return (
    <svg viewBox="0 0 40 40" className={className} aria-hidden="true">
      <defs>
        <linearGradient id="g-marca" x1="0" y1="0" x2="1" y2="1">
          <stop offset="0" stopColor="#c9c0ff" />
          <stop offset="1" stopColor="#8a7cf0" />
        </linearGradient>
      </defs>
      <path
        fill="url(#g-marca)"
        d="M20 3c-8.8 0-16 7-16 15.7V35c0 1.3 1.6 2 2.6 1.1l3-2.7c.7-.6 1.7-.6 2.4 0l2.9 2.6c.7.6 1.7.6 2.4 0l2.9-2.6c.7-.6 1.7-.6 2.4 0l3 2.7c1 .9 2.6.2 2.6-1.1V18.7C36 10 28.8 3 20 3Z"
      />
      <circle cx="15" cy="19" r="2.6" fill="#14121c" />
      <circle cx="25" cy="19" r="2.6" fill="#14121c" />
    </svg>
  );
}

export function Marca({ className = "" }: { className?: string }) {
  return (
    <span className={`inline-flex items-center gap-2 font-bold tracking-tight ${className}`}>
      <Glifo className="h-7 w-7" />
      ICEIBank
    </span>
  );
}
