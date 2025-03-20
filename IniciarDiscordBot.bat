@echo off
title Bot de Convites Discord
color 0A

echo ===================================================
echo        BOT DE CONVITES DISCORD - GERENCIADOR
echo ===================================================
echo.

:menu
cls
echo ===================================================
echo        BOT DE CONVITES DISCORD - GERENCIADOR
echo ===================================================
echo.
echo [1] Iniciar Bot
echo [2] Editar Configuracoes
echo [3] Ver Logs
echo [4] Ver Contatos Convidados
echo [5] Limpar Logs
echo [6] Zerar Lista de Contatos Convidados
echo [7] Sair
echo.
echo ===================================================
echo.

set /p opcao="Escolha uma opcao: "

if "%opcao%"=="1" goto iniciar
if "%opcao%"=="2" goto editar
if "%opcao%"=="3" goto logs
if "%opcao%"=="4" goto convidados
if "%opcao%"=="5" goto limpar
if "%opcao%"=="6" goto zerar_lista
if "%opcao%"=="7" goto sair

echo Opcao invalida! Tente novamente.
timeout /t 2 >nul
goto menu

:iniciar
cls
echo ===================================================
echo               INICIANDO BOT DE CONVITES
echo ===================================================
echo.
echo O bot esta sendo iniciado...
echo Pressione Ctrl+C para parar o bot e voltar ao menu.
echo.
echo ===================================================
echo.
powershell -NoProfile -ExecutionPolicy Bypass -Command "& {[Console]::OutputEncoding = [System.Text.Encoding]::UTF8; & '%~dp0DiscordConvite.ps1'}"
goto menu

:editar
cls
echo ===================================================
echo                EDITANDO CONFIGURACOES
echo ===================================================
echo.
echo Abrindo arquivo de configuracao...
echo Feche o editor para voltar ao menu.
echo.
echo ===================================================
echo.
start notepad config.json
goto menu

:logs
cls
echo ===================================================
echo                  VISUALIZANDO LOGS
echo ===================================================
echo.
echo Pressione qualquer tecla para voltar ao menu.
echo.
echo ===================================================
echo.
if exist log.txt (
  type log.txt | more
) else (
  echo Nenhum log encontrado.
  timeout /t 2 >nul
)
pause >nul
goto menu

:convidados
cls
echo ===================================================
echo            VISUALIZANDO CONTATOS CONVIDADOS
echo ===================================================
echo.
echo Pressione qualquer tecla para voltar ao menu.
echo.
echo ===================================================
echo.
if exist contatos_convidados.txt (
  echo Lista de IDs dos contatos ja convidados:
  echo.
  type contatos_convidados.txt
  echo.
  powershell -NoProfile -ExecutionPolicy Bypass -Command "$content = Get-Content -Encoding UTF8 'contatos_convidados.txt' -ErrorAction SilentlyContinue; if ($content) { Write-Host ('Total de contatos convidados: ' + $content.Count) } else { Write-Host 'Nenhum contato foi convidado ainda.' }"
) else (
  echo Nenhum contato foi convidado ainda.
)
echo.
pause >nul
goto menu

:limpar
cls
echo ===================================================
echo                    LIMPAR LOGS
echo ===================================================
echo.
echo Tem certeza que deseja limpar os logs?
echo Esta acao nao pode ser desfeita.
echo.
set /p confirmacao="Digite 'SIM' para confirmar: "
if /i "%confirmacao%"=="SIM" (
  if exist log.txt (
    del log.txt
    echo Logs limpos com sucesso!
  ) else (
    echo Nenhum arquivo de log encontrado.
  )
) else (
  echo Operacao cancelada.
)
timeout /t 2 >nul
goto menu

:zerar_lista
cls
echo ===================================================
echo           ZERAR LISTA DE CONTATOS CONVIDADOS
echo ===================================================
echo.
echo Esta acao ira limpar a lista de todos os contatos 
echo que ja receberam convites, permitindo que o bot 
echo envie convites para todos os contatos novamente.
echo.
echo ATENCAO: Use esta opcao com cuidado para evitar spam
echo e possiveis bloqueios por parte do Discord.
echo.
set /p confirmacao="Digite 'ZERAR' para confirmar: "
if /i "%confirmacao%"=="ZERAR" (
  if exist contatos_convidados.txt (
    del contatos_convidados.txt
    echo "" > contatos_convidados.txt
    echo Lista de contatos convidados zerada com sucesso!
    echo O bot ira enviar convites para todos os contatos na proxima execucao.
  ) else (
    echo "" > contatos_convidados.txt
    echo Arquivo de contatos convidados criado com sucesso!
  )
) else (
  echo Operacao cancelada.
)
timeout /t 3 >nul
goto menu

:sair
cls
echo ===================================================
echo                   SAINDO DO BOT
echo ===================================================
echo.
echo Obrigado por usar o Bot de Convites Discord!
echo.
echo ===================================================
timeout /t 2 >nul
exit 