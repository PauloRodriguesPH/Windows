@echo off
REM =============================================================
REM  Nome:    backup_oracle_exp_cleanup.bat
REM  Autor:   Paulo Henrique da Silva Motta Rodrigues
REM  Testado: Windows Server 2016, Oracle exp (11g)
REM  Data:    08/01/2026
REM  Uso:     Script para:
REM           1) Excluir arquivos antigos (dumps .dmp e logs .txt) com mais de 7 dias.
REM           2) Executar export (EXP) do schema Oracle com log e dump datados.
REM           3) Retornar código de saída adequado para agendador de tarefas.
REM  Observ.: Pensado para rodar no Agendador de Tarefas (Task Scheduler).
REM           Ajuste as variáveis abaixo conforme seu ambiente.
REM =============================================================

REM ---------- Configurações ----------
set "BACKUP_DRIVE=B:"
set "DUMP_DIR=%BACKUP_DRIVE%"            
set "LOG_DIR=%BACKUP_DRIVE%\logs"
set "RETENTION_DAYS=7"                     

REM  Credenciais/target Oracle (FORMATO: usuario/senha@TNS)
set "ORACLE_TARGET=CIGAM_GERENCIAL/GERENCIAL@CIGAM"

REM  Parâmetros de export
set "EXP_OPTIONS=STATISTICS=NONE CONSISTENT=YES"

REM  Caminho da ferramenta EXP (se necessário)
REM  Se o exp.exe estiver no PATH, deixe como está; senão configure abaixo.
set "EXP_CMD=EXP"

REM ---------- Preparação (evitar problemas com locale/espacos) ----------
setlocal ENABLEDELAYEDEXPANSION

REM  Cria pastas se não existirem
if not exist "%DUMP_DIR%" mkdir "%DUMP_DIR%"
if not exist "%LOG_DIR%"  mkdir "%LOG_DIR%"

REM ---------- Carimbo de data/hora (AAAA-MM-DD_HH-MM) ----------
REM  Usa %date% e %time% independentemente de locale, normalizando hora com zero à esquerda
for /f "tokens=1-4 delims=/-. " %%a in ("%date%") do (
    REM Tenta mapear data como DD MM AAAA; ajustar conforme locale
    set "DD=%%a"
    set "MM=%%b"
    set "YYYY=%%c"
    if not defined YYYY set "YYYY=%%d"
)
set "HH=%time:~0,2%"
set "HH=0%HH: =%"
set "HH=%HH:~-2%"
set "MIN=%time:~3,2%"
set "STAMP=%YYYY%-%MM%-%DD%_%HH%-%MIN%"

REM ---------- Limpeza de arquivos antigos ----------
color 0A
Title Limpeza e Backup – em andamento

echo -------------------------------------
echo Excluindo arquivos com mais de %RETENTION_DAYS% dias...
forfiles -p "%DUMP_DIR%" -s -d -%RETENTION_DAYS% -m *.dmp -c "cmd /c del /f /q @path"
forfiles -p "%LOG_DIR%"  -s -d -%RETENTION_DAYS% -m *.txt -c "cmd /c del /f /q @path"
if errorlevel 1 (
    echo Aviso: ocorreu falha na limpeza (verifique permissões/pastas). Continuando...
)

echo -------------------------------------
echo Iniciando o backup Oracle EXP...

REM  Monta nomes de arquivos
set "DUMP_FILE=%DUMP_DIR%\CIGAM_GERENCIAL_%STAMP%.dmp"
set "LOG_FILE=%LOG_DIR%\EXPLOG_GERENCIAL_%STAMP%.txt"

REM  Executa EXP
"%EXP_CMD%" %ORACLE_TARGET% FILE="%DUMP_FILE%" %EXP_OPTIONS% LOG="%LOG_FILE%"
set "EXP_RC=%ERRORLEVEL%"

echo -------------------------------------
if "%EXP_RC%"=="0" (
    echo Backup concluido com sucesso.
    Title Backup concluido
) else (
    echo ERRO: EXP retornou codigo %EXP_RC%.
    echo Verifique o log: %LOG_FILE%
)

REM ---------- Código de saída para o Agendador ----------
endlocal & exit /b %EXP_RC%
