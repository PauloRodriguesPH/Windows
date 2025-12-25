@echo off
@color 0A

echo -------------------------------------

echo Excluindo arquivos com mais de 7 dias...

forfiles -p "B:\" -s -d -7 -m *.dmp -c "cmd /c del /f /q @path"
forfiles -p "B:\LOGS" -s -d -7 -m *.txt -c "cmd /c del /f /q @path"
echo -------------------------------------

@title Backup em andamento. Por favor, aguarde...
echo Iniciando o backup...

echo -------------------------------------

set ftime=%time:~0,2%
set ftime=0%ftime: =%
set ftime=%ftime:~-2%
set data_hora=%date:~6,4%-%date:~3,2%-%date:~0,2%_%ftime%-%time:~3,2%


EXP CIGAM_GERENCIAL/GERENCIAL@CIGAM FILE=B:\CIGAM_GERENCIAL_%data_hora%.dmp STATISTICS=NONE CONSISTENT=YES log=B:\logs\EXPLOG_GERENCIAL_%data_hora%.txt

echo -------------------------------------
pause
echo Backup concluido
@title Backup concluido
exit
echo -------------------------------------
