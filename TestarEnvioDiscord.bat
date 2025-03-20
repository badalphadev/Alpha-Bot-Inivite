@echo off
setlocal enabledelayedexpansion
chcp 65001 > nul
color 0B
title ALPHA BOT INVITE - Teste de Envio

:menu
cls
echo =====================================================
echo          TESTE DE ENVIO DE MENSAGENS DISCORD
echo =====================================================
echo.
echo [1] Testar Envio de Mensagem
echo [2] Ver Contatos Convidados
echo [3] Ver Estatísticas
echo [4] Voltar ao Menu Principal
echo.
echo =====================================================
echo.

set /p opcao="Escolha uma opção: "

if "%opcao%"=="1" goto testar_envio
if "%opcao%"=="2" goto ver_contatos
if "%opcao%"=="3" goto ver_estatisticas
if "%opcao%"=="4" goto sair

echo Opção inválida. Tente novamente.
timeout /t 2 > nul
goto menu

:testar_envio
cls
echo =====================================================
echo              TESTE DE ENVIO DE MENSAGEM
echo =====================================================
echo.
echo Este teste enviará uma mensagem para um usuário específico
echo usando as configurações atuais em config.json.
echo.

set /p usuario="Digite o nome de usuário para enviar o teste (ex: usuario#1234): "

if "%usuario%"=="" (
    echo Nenhum usuário especificado. Voltando ao menu...
    timeout /t 2 > nul
    goto menu
)

echo.
echo Enviando mensagem de teste para: %usuario%
echo.

powershell -ExecutionPolicy Bypass -Command "& { param($user) & '%~dp0DiscordConvite.ps1' -TestarEnvio -UsuarioTeste $user }" "%usuario%"

echo.
echo Teste concluído. Verifique o log para mais detalhes.
echo.
echo Pressione qualquer tecla para voltar ao menu...
pause > nul
goto menu

:ver_contatos
cls
echo =====================================================
echo              CONTATOS JÁ CONVIDADOS
echo =====================================================
echo.

set "CONTATOS_FILE=contatos_convidados.txt"

if exist %CONTATOS_FILE% (
    echo Lista de contatos convidados:
    echo.
    powershell -Command "Get-Content '%CONTATOS_FILE%' | ForEach-Object { Write-Host (' - ' + $_) }"
    
    for /f %%C in ('powershell -Command "if (Test-Path '%CONTATOS_FILE%') { (Get-Content '%CONTATOS_FILE%' | Measure-Object -Line).Lines } else { 0 }"') do set CONTATOS_COUNT=%%C
    
    echo.
    echo Total: !CONTATOS_COUNT! contatos já convidados.
) else (
    echo Nenhum contato convidado encontrado.
)

echo.
echo Pressione qualquer tecla para voltar ao menu...
pause > nul
goto menu

:ver_estatisticas
cls
echo =====================================================
echo              ESTATÍSTICAS DE CONVITES
echo =====================================================
echo.

set "CONTATOS_DETAIL=contatos_convidados_detalhes.json"

if exist %CONTATOS_DETAIL% (
    powershell -ExecutionPolicy Bypass -Command "& { $stats = Get-Content '%CONTATOS_DETAIL%' -Raw | ConvertFrom-Json; $today = Get-Date -Format 'yyyy-MM-dd'; $totalInvites = if ($stats.PSObject.Properties.Name.Count -gt 0) { $stats.PSObject.Properties.Name.Count } else { 0 }; $todayInvites = 0; foreach ($prop in $stats.PSObject.Properties) { $date = $prop.Value.data.Substring(0, 10); if ($date -eq $today) { $todayInvites++ } }; Write-Host ('Total de convites enviados: ' + $totalInvites); Write-Host ('Convites enviados hoje: ' + $todayInvites) }"
) else (
    echo Arquivo de estatísticas não encontrado.
    echo Nenhum convite foi enviado ainda.
)

echo.
echo Pressione qualquer tecla para voltar ao menu...
pause > nul
goto menu

:sair
exit /b 