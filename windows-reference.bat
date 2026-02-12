##############################################
# GUIA DE REFERÊNCIA DE COMANDOS WINDOWS CMD #
##############################################

<#
# Autor: Paulo Henrique da Silva Motta Rodrigues
# Testado em: Windows Server
# Data do teste: 06/01/2026
# Uso: este arquivo é um catálogo; copie e rode os comandos conforme necessidade.
#>

REM Desabilita a interface de rede
wmic path win32_networkadapter where NetConnectionID="NIC_LAN" call disable

REM Habilita a interface de rede
wmic path win32_networkadapter where NetConnectionID="NIC_LAN" call enable
