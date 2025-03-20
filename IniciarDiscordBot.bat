@echo off
setlocal enabledelayedexpansion
chcp 65001 > nul
color 0A
title ALPHA BOT INVITE - Bot Iniciado

echo =====================================================
echo          INICIANDO BOT DE CONVITES DISCORD
echo =====================================================
echo.
echo  Data: %date%
echo  Hora: %time%
echo.
echo  Bot será iniciado com as configurações em config.json
echo  Certifique-se que o arquivo está configurado corretamente.
echo.
echo  Para parar o bot, pressione CTRL+C e confirme com S.
echo.
echo =====================================================
echo.

timeout /t 3 > nul

echo Iniciando o bot Discord...
echo Este processo continuará rodando até ser interrompido.
echo.

powershell -ExecutionPolicy Bypass -File "DiscordConvite.ps1"

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo [ERRO] Ocorreu um problema ao iniciar o bot.
    echo Verifique o arquivo de log para mais detalhes.
) else (
    echo.
    echo Bot finalizado.
)

echo.
echo Pressione qualquer tecla para voltar ao menu...
pause > nul
exit /b 