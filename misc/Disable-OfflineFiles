# Salvar script em .ps1 e executar como administrador
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
