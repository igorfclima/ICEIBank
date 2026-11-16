param(
    [Parameter(Position = 0)][string]$Acao = 'ajuda',
    [Parameter(Position = 1)][int]$Agencia = -1
)

$raiz = Split-Path $PSScriptRoot -Parent
$agenciaDir = Join-Path $raiz 'agencia'
$portaBase = 4063
$portas = 0..2 | ForEach-Object { $portaBase + $_ }

$arquivoEnv = Join-Path $raiz '.env'
if (-not $env:RABBITMQ_URL -and (Test-Path $arquivoEnv)) {
    Get-Content $arquivoEnv | ForEach-Object {
        if ($_ -match '^\s*RABBITMQ_URL\s*=\s*(.+?)\s*$') { $env:RABBITMQ_URL = $Matches[1].Trim('"', "'", '<', '>') }
    }
}

function Url($i) { "http://127.0.0.1:$($portaBase + $i)" }

function Token($agencia, $usuario, $senha) {
    $corpo = @{ usuario = $usuario; senha = $senha } | ConvertTo-Json
    (Invoke-RestMethod "$(Url $agencia)/auth/login" -Method Post -ContentType 'application/json' -Body $corpo).token
}

function Cab($agencia, $usuario, $senha) { @{ Authorization = "Bearer $(Token $agencia $usuario $senha)" } }

function Chamar($metodo, $url, $cab, $corpo) {
    try {
        $p = @{ Uri = $url; Method = $metodo; Headers = $cab; ContentType = 'application/json' }
        if ($corpo) { $p.Body = ($corpo | ConvertTo-Json -Compress) }
        Invoke-RestMethod @p
    } catch {
        if ($_.ErrorDetails.Message) { $_.ErrorDetails.Message | ConvertFrom-Json } else { Write-Host $_.Exception.Message -ForegroundColor Red }
    }
}

function PidDaPorta($porta) {
    Get-NetTCPConnection -State Listen -LocalPort $porta -ErrorAction SilentlyContinue |
        Select-Object -ExpandProperty OwningProcess -Unique
}

function SubirAgencia($i, $extra) {
    $url = if ($env:RABBITMQ_URL) { $env:RABBITMQ_URL.Trim('<', '>') } else { 'amqp://x:x@127.0.0.1:1/' }
    $cmd = "`$host.UI.RawUI.WindowTitle = 'Agencia $i'; Set-Location '$agenciaDir'; `$env:AGENCIA_ID = $i; `$env:RABBITMQ_URL = '$url'; $extra python src/app.py"
    Start-Process powershell -ArgumentList '-NoExit', '-Command', $cmd | Out-Null
}

switch ($Acao) {
    'subir' {
        if (-not $env:RABBITMQ_URL) {
            Write-Host 'RABBITMQ_URL nao definida: usando broker falso. Eleicao, failover e sincronizacao funcionam; transferencia entre agencias nao.' -ForegroundColor Yellow
        }
        $alvos = if ($Agencia -ge 0) { @($Agencia) } else { 0..2 }
        foreach ($i in $alvos) {
            if (PidDaPorta ($portaBase + $i)) { Write-Host "Agencia $i ja esta no ar." -ForegroundColor Yellow; continue }
            SubirAgencia $i ''
            Write-Host "Agencia $i subindo em uma janela nova (porta $($portaBase + $i))."
        }
    }
    'subir-sem-persistencia' {
        if ($Agencia -lt 0) { Write-Host 'Use: .\demo-sprint3.ps1 subir-sem-persistencia <agencia>'; break }
        SubirAgencia $Agencia '$env:PERSISTENCIA = "0";'
        Write-Host "Agencia $Agencia subindo sem persistencia."
    }
    'parar' {
        if ($Agencia -lt 0) { Write-Host 'Use: .\demo-sprint3.ps1 parar <agencia>'; break }
        $p = PidDaPorta ($portaBase + $Agencia)
        if (-not $p) { Write-Host "Agencia $Agencia ja esta fora do ar."; break }
        Stop-Process -Id $p -Force
        Write-Host "Agencia $Agencia derrubada (processo $p)." -ForegroundColor Yellow
    }
    'lideres' {
        Write-Host (Get-Date -Format 'dd/MM/yyyy HH:mm:ss') -ForegroundColor Cyan
        foreach ($i in 0..2) {
            try {
                $r = Invoke-RestMethod "$(Url $i)/bully/lider" -TimeoutSec 4
                $quando = if ($r.desde) { [DateTimeOffset]::FromUnixTimeSeconds([long]$r.desde).LocalDateTime.ToString('HH:mm:ss') } else { '-' }
                Write-Host ("Agencia {0} (porta {1}): lider = {2}  desde {3}  ativas = {4}" -f $i, ($portaBase + $i), $r.liderAtual, $quando, (($r.ativas.PSObject.Properties | ForEach-Object { "$($_.Name):$($_.Value)" }) -join ' '))
            } catch {
                Write-Host ("Agencia {0} (porta {1}): FORA DO AR" -f $i, ($portaBase + $i)) -ForegroundColor Red
            }
        }
    }
    'contas' {
        $adm = Cab 0 'admin' 'admin'
        $dados = @(
            @{ id = 0; nome = 'Ana Souza'; saldo = 500; dono = 'ana' },
            @{ id = 1; nome = 'Beto Dias'; saldo = 50; dono = 'beto' },
            @{ id = 2; nome = 'Caio Lima'; saldo = 80; dono = 'caio' }
        )
        foreach ($d in $dados) {
            $corpo = @{ id = $d.id; nomeAluno = $d.nome; saldoInicial = $d.saldo; dono = $d.dono }
            $r = Chamar 'Post' "$(Url ($d.id % 3))/contas" $adm $corpo
            Write-Host ("Conta {0}: {1} saldo {2} (agencia {3})" -f $r.id, $r.nomeAluno, $r.saldo, ($d.id % 3))
        }
    }
    'conflito' {
        $ana = Cab 0 'ana' 'ana123'
        Write-Host (Get-Date -Format 'dd/MM/yyyy HH:mm:ss') -ForegroundColor Cyan
        $c = Chamar 'Get' "$(Url 0)/contas/0" $ana
        Write-Host "1. App le a conta: saldo $($c.saldo), vetorAtual = [$($c.vetorAtual -join ', ')]"
        $d = Chamar 'Post' "$(Url 0)/contas/0/depositar" $ana @{ valor = 10 }
        Write-Host "2. Enquanto o app esta offline, alguem deposita 10: vetorAtual = [$($d.vetorAtual -join ', ')]"
        $id = "demo-$([guid]::NewGuid().ToString('N').Substring(0, 8))"
        $corpo = @{ tipo = 'DEPOSITO'; valor = 5; vetorConhecido = $c.vetorAtual; idOperacao = $id }
        Write-Host "3. App sincroniza com o vetor antigo [$($c.vetorAtual -join ', ')]:"
        $r = Chamar 'Post' "$(Url 0)/contas/0/sincronizar" $ana $corpo
        $r | ConvertTo-Json -Depth 5
        if ($r.vetorAtual) {
            $corpo.vetorConhecido = $r.vetorAtual
            Write-Host "4. App sincroniza de novo com o vetorAtual devolvido [$($r.vetorAtual -join ', ')]:"
            Chamar 'Post' "$(Url 0)/contas/0/sincronizar" $ana $corpo | ConvertTo-Json -Depth 5
        }
    }
    'historico' {
        Write-Host (Get-Date -Format 'dd/MM/yyyy HH:mm:ss') -ForegroundColor Cyan
        Push-Location $agenciaDir
        try { python historico_lideranca.py } finally { Pop-Location }
    }
    'alterar-saldo' {
        $ana = Cab 0 'ana' 'ana123'
        $d = Chamar 'Post' "$(Url 0)/contas/0/depositar" $ana @{ valor = 100 }
        Write-Host "Deposito de 100 feito direto na agencia 0. Saldo agora: $($d.saldo)  vetorAtual = [$($d.vetorAtual -join ', ')]"
    }
    'limpar' {
        foreach ($i in 0..2) { if (PidDaPorta ($portaBase + $i)) { Write-Host "Derrube as agencias antes (parar $i)." -ForegroundColor Yellow; return } }
        $dados = Join-Path $agenciaDir 'data'
        Get-ChildItem $dados -File | Where-Object { $_.Extension -in '.jsonl', '.json', '.tmp', '.txt' } | Remove-Item -Force
        Write-Host 'Logs e estado das agencias apagados.'
    }
    default {
        @'
Uso: .\scripts\demo-sprint3.ps1 <acao> [agencia]

  subir [N]                    sobe as 3 agencias (ou so a N) em janelas novas
  subir-sem-persistencia N     sobe a agencia N sem persistencia
  contas                       cria as contas 0, 1 e 2 (precisa das agencias no ar)
  lideres                      mostra quem e o lider em cada agencia, com data e hora
  parar N                      derruba a agencia N
  conflito                     mostra o 409 de sincronizacao e depois o 200
  alterar-saldo                deposita 100 na conta 0 direto (para provocar conflito no app)
  historico                    roda historico_lideranca.py com data e hora
  limpar                       apaga logs e estado (com as agencias paradas)
'@ | Write-Host
    }
}
