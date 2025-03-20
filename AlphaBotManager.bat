@echo off
setlocal enabledelayedexpansion
chcp 65001 > nul
color 0A
title ALPHA BOT INVITE - Gerenciador

set "REPO_URL=https://github.com/badalphadev/Alpha-Bot-Inivite.git"
set "CONFIG_FILE=config.json"
set "CONFIG_EXAMPLE=config.example.json"
set "LOG_FILE=log.txt"
set "CONTATOS_FILE=contatos_convidados.txt"
set "CONTATOS_DETAIL=contatos_convidados_detalhes.json"

rem Remove arquivos antigos
if exist "verificar-git.ps1" del /q "verificar-git.ps1"
if exist "forcar-arquivos.ps1" del /q "forcar-arquivos.ps1"
if exist "comitar-github.ps1" del /q "comitar-github.ps1"
if exist "baixar-git.ps1" del /q "baixar-git.ps1"
if exist "ComitarParaGitHub.bat" del /q "ComitarParaGitHub.bat"
if exist "CorrigirGitHub.bat" del /q "CorrigirGitHub.bat"
if exist "ForcarEnvioGitHub.bat" del /q "ForcarEnvioGitHub.bat"
if exist "TestarSintaxe.bat" del /q "TestarSintaxe.bat"

:menu
cls
echo =====================================================
echo          ALPHA BOT INVITE - GERENCIADOR
echo =====================================================
echo.
echo GERENCIAMENTO DE AUTOMAÇÃO:
echo [1] Iniciar Bot Discord
echo [2] Testar Envio de Mensagens
echo [3] Editar Configurações
echo [4] Ver Logs
echo [5] Zerar Lista de Contatos Convidados
echo.
echo GERENCIAMENTO DE ARQUIVOS:
echo [6] Verificar Arquivos
echo [7] Enviar para GitHub
echo [8] Instalar/Atualizar Git
echo.
echo [0] Sair
echo.
echo =====================================================
echo.

set /p opcao="Escolha uma opção: "

if "%opcao%"=="1" goto iniciar_bot
if "%opcao%"=="2" goto testar_mensagens
if "%opcao%"=="3" goto editar_config
if "%opcao%"=="4" goto ver_logs
if "%opcao%"=="5" goto zerar_contatos
if "%opcao%"=="6" goto verificar_arquivos
if "%opcao%"=="7" goto github
if "%opcao%"=="8" goto instalar_git
if "%opcao%"=="0" goto sair

echo Opção inválida. Tente novamente.
timeout /t 2 > nul
goto menu

:iniciar_bot
cls
echo Iniciando o bot Discord...
echo.
call IniciarDiscordBot.bat
goto menu

:testar_mensagens
cls
echo Iniciando teste de envio de mensagens...
echo.
call TestarEnvioDiscord.bat
goto menu

:editar_config
cls
echo Abrindo arquivo de configuração...
echo.

if exist %CONFIG_FILE% (
    start notepad %CONFIG_FILE%
) else (
    echo Arquivo de configuração não encontrado. Criando modelo...
    
    if exist %CONFIG_EXAMPLE% (
        copy %CONFIG_EXAMPLE% %CONFIG_FILE% > nul
    ) else (
        echo {> %CONFIG_FILE%
        echo     "token": "SEU_TOKEN_DO_DISCORD_AQUI",>> %CONFIG_FILE%
        echo     "link_convite": "https://discord.gg/seu-link-de-convite",>> %CONFIG_FILE%
        echo     "mensagem": "🔥 **Bem-vindo à Alpha Store!** 🔥\n\nOs melhores **scripts para League of Legends** com **preços competitivos** estão aqui! 🏆 Aproveite agora e resgate sua **key trial gratuita por tempo limitado**! ⏳\n\n💻 **Garanta sua vantagem no jogo hoje mesmo!** 🚀\n\n🔗 Acesse agora: [Alpha Store]",>> %CONFIG_FILE%
        echo     "intervalo_minimo": 50,>> %CONFIG_FILE%
        echo     "intervalo_maximo": 60,>> %CONFIG_FILE%
        echo     "maximo_convites_por_hora": 50,>> %CONFIG_FILE%
        echo     "maximo_convites_por_dia": 50,>> %CONFIG_FILE%
        echo     "horario_inicial": "08:00",>> %CONFIG_FILE%
        echo     "horario_final": "20:00",>> %CONFIG_FILE%
        echo     "pausa_aleatoria": true>> %CONFIG_FILE%
        echo }>> %CONFIG_FILE%
    )
    
    start notepad %CONFIG_FILE%
)

echo.
echo Pressione qualquer tecla para voltar ao menu principal...
pause > nul
goto menu

:ver_logs
cls
echo Exibindo logs...
echo.

if exist %LOG_FILE% (
    powershell -Command "Get-Content '%LOG_FILE%' -Tail 50 | ForEach-Object { if ($_ -match 'erro|falha|error') { Write-Host $_ -ForegroundColor Red } else { Write-Host $_ } }"
) else (
    echo Arquivo de log não encontrado.
)

echo.
echo Pressione qualquer tecla para voltar ao menu principal...
pause > nul
goto menu

:zerar_contatos
cls
echo Zerar lista de contatos convidados
echo =====================================================
echo ATENÇÃO: Esta ação vai apagar TODOS os registros de 
echo contatos já convidados.
echo O bot irá enviar convites para TODOS os contatos novamente.
echo Isso pode resultar em spam e possível banimento pelo Discord.
echo =====================================================
echo.
set /p confirmacao="Tem certeza que deseja continuar? (S/N): "

if /i "%confirmacao%"=="S" (
    echo Removendo arquivos de contatos convidados...
    
    if exist %CONTATOS_FILE% (
        del /q %CONTATOS_FILE%
        echo. > %CONTATOS_FILE%
        echo Arquivo de contatos convidados limpo.
    )
    
    if exist %CONTATOS_DETAIL% (
        del /q %CONTATOS_DETAIL%
        echo {} > %CONTATOS_DETAIL%
        echo Arquivo de detalhes de contatos convidados limpo.
    )
    
    echo Lista de contatos zerada com sucesso!
) else (
    echo Operação cancelada pelo usuário.
)

echo.
echo Pressione qualquer tecla para voltar ao menu principal...
pause > nul
goto menu

:verificar_arquivos
cls
echo Verificando arquivos do projeto...
echo.

set "ARQUIVOS=DiscordConvite.ps1 TestarEnvioDiscord.ps1 IniciarDiscordBot.bat TestarEnvioDiscord.bat config.example.json README.txt AlphaBotManager.bat"
set "FALTANDO="
set "TOTAL_ARQUIVOS=0"
set "ARQUIVOS_ENCONTRADOS=0"

for %%f in (%ARQUIVOS%) do (
    set /a TOTAL_ARQUIVOS+=1
    if exist "%%f" (
        set /a ARQUIVOS_ENCONTRADOS+=1
        for /f %%a in ('powershell -Command "'{0:N0}' -f (Get-Item '%%f').Length"') do set tamanho=%%a
        for /f %%l in ('powershell -Command "(Get-Content '%%f').Count"') do set linhas=%%l
        echo [OK] %%f ^(Tamanho: !tamanho! bytes, !linhas! linhas^)
    ) else (
        echo [X] %%f ^(não encontrado^)
        set "FALTANDO=!FALTANDO! %%f"
    )
)

echo.
if "!FALTANDO!" NEQ "" (
    echo Arquivos faltando:!FALTANDO!
) else (
    echo Todos os arquivos importantes estão presentes!
)
echo Total: !ARQUIVOS_ENCONTRADOS!/!TOTAL_ARQUIVOS! arquivos encontrados.

echo.
echo Pressione qualquer tecla para voltar ao menu principal...
pause > nul
goto menu

:verificar_git
cls
echo Verificando instalação do Git...
git --version > nul 2>&1
if %ERRORLEVEL% EQU 0 (
    for /f "tokens=*" %%i in ('git --version') do set GIT_VERSION=%%i
    echo Git encontrado: !GIT_VERSION!
    set GIT_INSTALADO=1
    goto :eof
) else (
    echo Git não está instalado ou não está no PATH.
    set GIT_INSTALADO=0
    goto :eof
)

:instalar_git
cls
echo Instalando/Atualizando Git...
echo.

call :verificar_git

if "!GIT_INSTALADO!"=="1" (
    echo Git já está instalado no sistema.
) else (
    echo Baixando o instalador do Git para Windows...
    
    powershell -Command "& { $url = 'https://github.com/git-for-windows/git/releases/download/v2.42.0.windows.2/Git-2.42.0.2-64-bit.exe'; $output = Join-Path $pwd 'Git-Installer.exe'; (New-Object System.Net.WebClient).DownloadFile($url, $output); Write-Host 'Download concluído. Arquivo salvo em:' $output }"
    
    if exist "Git-Installer.exe" (
        echo Instalando Git...
        echo O instalador será aberto. Siga as instruções na tela para instalar o Git.
        start /wait Git-Installer.exe
        
        call :verificar_git
        if "!GIT_INSTALADO!"=="1" (
            echo Git instalado com sucesso!
        ) else (
            echo Falha ao instalar o Git. Tente instalar manualmente.
        )
    ) else (
        echo Erro ao baixar o instalador do Git.
    )
)

echo.
echo Pressione qualquer tecla para voltar ao menu principal...
pause > nul
goto menu

:github
cls
echo Enviando arquivos para o GitHub...
echo =====================================================
echo.

call :verificar_git
if "!GIT_INSTALADO!"=="0" (
    echo Git não está instalado. Por favor, instale o Git primeiro.
    echo.
    echo Pressione qualquer tecla para voltar ao menu principal...
    pause > nul
    goto menu
)

rem Configurar informações do usuário
set /p nome_usuario="Digite seu nome de usuário para o Git: "
set /p email_usuario="Digite seu email para o Git: "

echo Configurando Git...
git config --global user.name "!nome_usuario!"
git config --global user.email "!email_usuario!"

rem Verificar se é um repositório Git
if not exist ".git" (
    echo Inicializando repositório Git local...
    git init
)

rem Verificar .gitignore
if not exist ".gitignore" (
    echo Criando arquivo .gitignore...
    echo # Arquivos de instalação> .gitignore
    echo Git-Installer.exe>> .gitignore
    echo.>> .gitignore
    echo # Arquivos de log e dados sensíveis>> .gitignore
    echo log.txt>> .gitignore
    echo contatos_convidados.txt>> .gitignore
    echo contatos_convidados_detalhes.json>> .gitignore
    echo.>> .gitignore
    echo # Arquivos de configuração com tokens ou dados pessoais>> .gitignore
    echo config.json>> .gitignore
    echo.>> .gitignore
    echo # Arquivos temporários>> .gitignore
    echo *.tmp>> .gitignore
    echo *.bak>> .gitignore
    echo.>> .gitignore
    echo # Arquivos do sistema>> .gitignore
    echo Thumbs.db>> .gitignore
    echo .DS_Store>> .gitignore
)

rem Verificar README.md
if not exist "README.md" (
    echo Criando README.md para o GitHub...
    echo # Alpha Bot Invite> README.md
    echo.>> README.md
    echo Bot automatizado para envio de convites via Discord com proteções contra ban.>> README.md
    echo.>> README.md
    echo ## Configuração>> README.md
    echo.>> README.md
    echo 1. Copie o arquivo `config.example.json` para `config.json`>> README.md
    echo 2. Edite o arquivo `config.json` com suas configurações:>> README.md
    echo    - `token`: Token do seu bot Discord>> README.md
    echo    - `link_convite`: Link do convite do seu servidor>> README.md
    echo    - `mensagem`: Mensagem que será enviada para os usuários>> README.md
    echo    - `intervalo_minimo` e `intervalo_maximo`: Intervalo ^(em segundos^) entre mensagens>> README.md
    echo    - `maximo_convites_por_hora` e `maximo_convites_por_dia`: Limites de envio>> README.md
    echo    - `horario_inicial` e `horario_final`: Horário permitido para funcionamento>> README.md
    echo    - `pausa_aleatoria`: Se deve adicionar pausas aleatórias entre mensagens>> README.md
    echo.>> README.md
    echo ## Uso>> README.md
    echo.>> README.md
    echo Execute o arquivo `IniciarDiscordBot.bat` para iniciar o bot.>> README.md
    echo Execute o arquivo `TestarEnvioDiscord.bat` para testar envios individuais.>> README.md
    echo.>> README.md
    echo ## Desenvolvido por AlphaDev>> README.md
)

rem Forçar adição de arquivos importantes
echo Adicionando arquivos importantes ao Git...
set "ARQUIVOS_GIT=DiscordConvite.ps1 TestarEnvioDiscord.ps1 IniciarDiscordBot.bat TestarEnvioDiscord.bat config.example.json README.txt README.md AlphaBotManager.bat .gitignore"

for %%f in (%ARQUIVOS_GIT%) do (
    if exist "%%f" (
        git add -f "%%f"
        echo   + %%f adicionado
    )
)

rem Comitar alterações
echo Commitando alterações...
set /p mensagem_commit="Digite uma mensagem para o commit (ou pressione Enter para usar mensagem padrão): "

if "%mensagem_commit%"=="" (
    set "mensagem_commit=Atualização do Alpha Bot Invite"
)

git commit -m "%mensagem_commit%"

rem Verificar e configurar o repositório remoto
git remote -v | findstr "origin" > nul
if %ERRORLEVEL% EQU 0 (
    echo Removendo configuração remota atual...
    git remote remove origin
)

echo Configurando repositório remoto...
git remote add origin %REPO_URL%

rem Enviar para o GitHub
echo Enviando arquivos para o GitHub...
echo Você precisará fornecer suas credenciais do GitHub quando solicitado.

for /f "tokens=*" %%b in ('git branch --show-current') do set branch=%%b
if "!branch!"=="" (
    git checkout -b main
    set "branch=main"
)

git push -u origin !branch! --force

echo.
echo Processo de envio para o GitHub concluído!
echo.
echo Pressione qualquer tecla para voltar ao menu principal...
pause > nul
goto menu

:sair
cls
echo Saindo do gerenciador. Até logo!
timeout /t 2 > nul
exit 