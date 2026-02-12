REM Desabilita a interface de rede
wmic path win32_networkadapter where NetConnectionID="NIC_LAN" call disable

REM Habilita a interface de rede
wmic path win32_networkadapter where NetConnectionID="NIC_LAN" call enable
