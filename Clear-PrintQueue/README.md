
# Print Queue Cleaner (Windows Server)

Esvazia, de forma **simples e eficiente**, as filas de impressão do **servidor de impressão** (apenas as filas que possuem jobs) e gera um **log por execução** com data/hora.

> **Cenário**: ambientes com muitas impressoras e filas onde jobs ficam parados, gerando bloqueios.  
> **Solução**: remover os jobs via API de impressão (PowerShell `Remove-PrintJob`) e registrar o que foi removido.

---

## 📦 Arquivos

- `Clear-PrintQueues_Diario.ps1` — Script PowerShell que:
  - Varre todas as impressoras do servidor.
  - **Só** remove jobs das filas que tenham jobs.
  - Gera um **log por execução** em `C:\Scripts\Logs\QueueClear_YYYYMMDD_HHMMSS.log`.

---

## ✅ Requisitos

- Windows Server com módulo **PrintManagement** (PowerShell).
- Permissões administrativas para executar o script e agendar tarefa.
- **Servidor de impressão** com impressoras instaladas (filas visíveis via `Get-Printer`).

> Dica: Se quiser auditoria de impressão (quem, quando, quantas páginas e nome do documento), ative o log `PrintService/Operational` no Event Viewer e a política de grupo **Allow job name in event logs**. (Passos gerais: Event Viewer → `Microsoft-Windows-PrintService/Operational` → Enable; GPO `Printers → Allow job name in event logs`).

---

## 🛠 Instalação

1. Crie a pasta:
-  C:\Scripts
2. Salve:
- `C:\Scripts\Clear-PrintQueues_Diario.ps1`
3. Na primeira execução interativa:
```powershell
Set-ExecutionPolicy RemoteSigned -Scope Process
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\Scripts\Clear-PrintQueues_Diario.ps1"
```powershell

4. Verifique o log gerado em:
C:\Scripts\Logs\QueueClear_YYYYMMDD_HHMMSS.log
5. Crie a tarefa no agendador de tarefas
```powershell
$taskName = 'LimparFilas_Diario'
$script   = 'C:\Scripts\Clear-PrintQueues_Diario.ps1'

$action   = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$script`""
$trigger  = New-ScheduledTaskTrigger -Daily -At 01:00
$principal= New-ScheduledTaskPrincipal -UserId 'SYSTEM' -LogonType ServiceAccount -RunLevel Highest

Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Principal $principal -Description 'Limpa filas de impressão e gera log diário por execução'
``
