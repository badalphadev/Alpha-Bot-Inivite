@echo off
title Teste de Envio de Mensagens Discord
color 0B

:menu
cls
echo ===================================================
echo        TESTE DE ENVIO DE MENSAGENS DISCORD
echo ===================================================
echo.
echo [1] Testar Envio de Mensagem
echo [2] Ver Contatos Convidados
echo [3] Ver Estatisticas
echo [4] Voltar para o Menu Principal
echo.
echo ===================================================
echo.

set /p opcao="Escolha uma opcao: "

if "%opcao%"=="1" goto testar
if "%opcao%"=="2" goto convidados
if "%opcao%"=="3" goto estatisticas
if "%opcao%"=="4" goto sair

echo Opcao invalida! Tente novamente.
timeout /t 2 >nul
goto menu

:testar
cls
echo ===================================================
echo        TESTE DE ENVIO DE MENSAGEM DISCORD
echo ===================================================
echo.
echo Este teste verificara se e possivel enviar mensagens
echo para seus contatos no Discord usando o seu token.
echo.
echo Pressione qualquer tecla para iniciar o teste...
echo.
echo ===================================================
pause >nul

powershell -NoProfile -ExecutionPolicy Bypass -Command "& {[Console]::OutputEncoding = [System.Text.Encoding]::UTF8; & '%~dp0TestarEnvioDiscord.ps1'}"

echo.
echo ===================================================
echo            TESTE CONCLUIDO
echo ===================================================
echo.
echo Pressione qualquer tecla para voltar ao menu...
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

:estatisticas
cls
echo ===================================================
echo               ESTATISTICAS DE CONVITES
echo ===================================================
echo.
echo Pressione qualquer tecla para voltar ao menu.
echo.
echo ===================================================
echo.
powershell -NoProfile -ExecutionPolicy Bypass -Command "& {[Console]::OutputEncoding = [System.Text.Encoding]::UTF8; if (Test-Path 'contatos_convidados_detalhes.json') { $data = Get-Content -Encoding utf8 'contatos_convidados_detalhes.json' | ConvertFrom-Json; $count = ($data | Get-Member -MemberType NoteProperty).Count; Write-Host ('Total de contatos convidados: ' + $count); $hoje = Get-Date -Format 'yyyy-MM-dd'; $convitesHoje = 0; foreach ($prop in ($data | Get-Member -MemberType NoteProperty)) { $contato = $data.($prop.Name); if ($contato.data_convite -and $contato.data_convite.StartsWith($hoje)) { $convitesHoje++ } }; Write-Host ('Convites enviados hoje: ' + $convitesHoje) } else { Write-Host 'Nenhum registro de convites encontrado.' }}"
echo.
pause >nul
goto menu

:sair
exit 