@echo off

::Verifica se tem privilégios de Administrador, se não tiver, solicita
>nul 2>&1       "%SYSTEMROOT%\system32\cacls.exe"    "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' NEQ '0' (
    echo Solicitando privilegios de administrador...
    goto UACPrompt

) else ( goto gotAdmin )



:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"
    "%temp%\getadmin.vbs"
    
exit /B


:gotAdmin
    if exist    "%temp%\getadmin.vbs"   ( del "%temp%\getadmin.vbs" )
    pushd       "%cd%"
    CD /D       "%~dp0"



:: --- INICIO DA EXECUÇÃO DO POWERSHELL ---



echo Iniciando processo de desbloqueio...

:: Altere 'NOME_DO_SEU_SCRIPT.ps1' para o nome real do seu arquivo
powershell -NoProfile -ExecutionPolicy Bypass -Command "& {Start-Process powershell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File ""%~dp0Desbloquear.ps1""' -Verb RunAs}"


exit