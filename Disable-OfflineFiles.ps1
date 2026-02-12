#############################################################
# GUIA DE REFERÊNCIA – DESATIVAR OFFLINE FILES (CSC)        #
#############################################################

<#
Autor: Paulo Henrique da Silva Motta Rodrigues
Sistema: Windows (Desktop / Server)
Recurso: Offline Files (Client Side Caching - CSC)
Data do teste: 08/01/2026

Uso:
- Script para desativar completamente o recurso Offline Files
- Aplica configurações via WMI, Registro e Serviço
- Pode ser usado em troubleshooting ou padronização de ambiente

Observações:
- Executar como Administrador
- Requer reinicialização para aplicar todas as mudanças
- Script pode ser usado como referência (copiar/colar conforme necessidade) ou pode salvar como ps1 e executar completo.
#>


# 1) Desativar via WMI
([WmiClass]'Win32_OfflineFilesCache').Enable($false)

# 2) Política/Registro para manter desativado
New-Item -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows' -Name 'NetCache' -Force | Out-Null
New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\NetCache' -Name 'Enabled' -PropertyType DWord -Value 0 -Force | Out-Null

# 3) Desabilitar e parar o serviço
sc.exe config CscService start= disabled
sc.exe stop CscService

# 4) (Opcional) agendar limpeza da base CSC no próximo boot
New-Item -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\CSC' -Name 'Parameters' -Force | Out-Null
New-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\CSC\Parameters' -Name 'FormatDatabase' -PropertyType DWord -Value 1 -Force | Out-Null

Write-Host "Concluído. Reinicie o computador para aplicar todas as mudanças."
