
<#
.SYNOPSIS
  Esvazia todas as filas de impressão do servidor local e gera um log diário.
.DESCRIPTION
  - Remove jobs via API (Remove-PrintJob)
  - Cria log em C:\Scripts\Logs\QueueClear_YYYYMMDD_HHMMSS.log
#>

# ===== Configurações =====
$BaseDir  = 'C:\Scripts'
$LogDir   = Join-Path $BaseDir 'Logs'
$RunStamp = (Get-Date).ToString('yyyyMMdd_HHmmss')
$RunLog   = Join-Path $LogDir ("QueueClear_{0}.log" -f $RunStamp)

# Cria pastas se não existirem
New-Item -ItemType Directory -Path $BaseDir -Force | Out-Null
New-Item -ItemType Directory -Path $LogDir  -Force | Out-Null

function Write-RunLog {
    param([string]$Message)
    $line = "[{0}] {1}" -f (Get-Date).ToString('yyyy-MM-dd HH:mm:ss'), $Message
    Add-Content -Path $RunLog -Value $line
    Write-Host $line
}

Write-RunLog "==== Início da execução no servidor ($env:COMPUTERNAME) ===="

# Mostrar resumo antes de remover
$filas = Get-Printer
$totalRemovidos = 0

foreach ($fila in $filas) {
    $jobs = Get-PrintJob -PrinterName $fila.Name -ErrorAction SilentlyContinue
    $count = ($jobs | Measure-Object).Count
    Write-RunLog ("Fila: {0} | Jobs na fila: {1}" -f $fila.Name, $count)

    if ($count -gt 0) {
        try {
            $jobs | Remove-PrintJob -Confirm:$false
            $totalRemovidos += $count
            Write-RunLog ("Removidos {0} job(s) da fila '{1}'" -f $count, $fila.Name)
        } catch {
            Write-RunLog ("Falha ao remover jobs da fila '{0}': {1}" -f $fila.Name, $_.Exception.Message)
        }
    }
}

Write-RunLog ("Total de jobs removidos nesta execução: {0}" -f $totalRemovidos)
Write-RunLog "Log salvo em: $RunLog"
Write-RunLog "==== Fim da execução ===="
