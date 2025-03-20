# Script de teste para envio de mensagens Discord
# Autor: AlphaDev
# Data: $(Get-Date -Format "dd/MM/yyyy")

param (
    [string]$Usuario
)

# Se o usuário foi especificado como parâmetro, chama o script principal para testar
if (-not [string]::IsNullOrEmpty($Usuario)) {
    # Chamando o script principal com os parâmetros adequados
    & "$PSScriptRoot\DiscordConvite.ps1" -TestarEnvio -UsuarioTeste $Usuario
    exit
}

# Configurando codificação UTF-8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Funções utilitárias
function Show-Menu {
    Clear-Host
    Write-Host "==============================================" -ForegroundColor Cyan
    Write-Host "          TESTE DE ENVIO DE MENSAGENS         " -ForegroundColor Yellow
    Write-Host "==============================================" -ForegroundColor Cyan
    Write-Host
    Write-Host "  [1] Enviar mensagem de teste"
    Write-Host "  [2] Ver contatos convidados"
    Write-Host "  [3] Ver estatísticas"
    Write-Host "  [4] Voltar ao menu principal"
    Write-Host
    Write-Host "==============================================" -ForegroundColor Cyan
    Write-Host
}

function Send-TestMessage {
    Clear-Host
    Write-Host "==============================================" -ForegroundColor Cyan
    Write-Host "             ENVIO DE MENSAGEM TESTE          " -ForegroundColor Yellow
    Write-Host "==============================================" -ForegroundColor Cyan
    Write-Host
    
    $usuario = Read-Host "Digite o nome de usuário para enviar o teste (ex: usuario#1234)"
    
    if ([string]::IsNullOrEmpty($usuario)) {
        Write-Host "Nenhum usuário especificado. Voltando ao menu..." -ForegroundColor Red
        Start-Sleep -Seconds 2
        return
    }
    
    Write-Host
    Write-Host "Enviando mensagem de teste para: $usuario" -ForegroundColor Green
    Write-Host
    
    # Chama o script principal com os parâmetros necessários
    & "$PSScriptRoot\DiscordConvite.ps1" -TestarEnvio -UsuarioTeste $usuario
    
    Write-Host
    Write-Host "Pressione qualquer tecla para voltar ao menu..." -ForegroundColor Cyan
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

function Show-InvitedContacts {
    Clear-Host
    Write-Host "==============================================" -ForegroundColor Cyan
    Write-Host "             CONTATOS CONVIDADOS              " -ForegroundColor Yellow
    Write-Host "==============================================" -ForegroundColor Cyan
    Write-Host
    
    $contatosFile = "contatos_convidados.txt"
    
    if (Test-Path $contatosFile) {
        $conteudo = Get-Content $contatosFile
        if ($conteudo.Count -gt 0) {
            foreach ($linha in $conteudo) {
                if (-not [string]::IsNullOrWhiteSpace($linha)) {
                    Write-Host " - $linha" -ForegroundColor White
                }
            }
            Write-Host
            Write-Host "Total: $($conteudo.Count) contatos convidados." -ForegroundColor Green
        } else {
            Write-Host "Nenhum contato convidado encontrado no arquivo." -ForegroundColor Yellow
        }
    } else {
        Write-Host "Arquivo de contatos convidados não encontrado." -ForegroundColor Red
    }
    
    Write-Host
    Write-Host "Pressione qualquer tecla para voltar ao menu..." -ForegroundColor Cyan
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

function Show-Statistics {
    Clear-Host
    Write-Host "==============================================" -ForegroundColor Cyan
    Write-Host "             ESTATÍSTICAS DE ENVIO            " -ForegroundColor Yellow
    Write-Host "==============================================" -ForegroundColor Cyan
    Write-Host
    
    $detailFile = "contatos_convidados_detalhes.json"
    
    if (Test-Path $detailFile) {
        try {
            $stats = Get-Content $detailFile -Raw | ConvertFrom-Json
            $today = Get-Date -Format 'yyyy-MM-dd'
            
            # Conta o número total de convites enviados
            $totalInvites = 0
            if ($stats.PSObject.Properties.Name.Count -gt 0) {
                $totalInvites = $stats.PSObject.Properties.Name.Count
            }
            
            # Conta os convites enviados hoje
            $todayInvites = 0
            foreach ($prop in $stats.PSObject.Properties) {
                $date = $prop.Value.data_convite.Substring(0, 10)
                if ($date -eq $today) {
                    $todayInvites++
                }
            }
            
            Write-Host "Total de convites enviados: $totalInvites" -ForegroundColor Green
            Write-Host "Convites enviados hoje: $todayInvites" -ForegroundColor Green
        } catch {
            $erro = $Error[0]
            Write-Host "Erro ao processar estatísticas. Detalhes: Erro interno." -ForegroundColor Red
        }
    } else {
        Write-Host "Arquivo de estatísticas não encontrado." -ForegroundColor Red
        Write-Host "Nenhum convite foi enviado ainda." -ForegroundColor Yellow
    }
    
    Write-Host
    Write-Host "Pressione qualquer tecla para voltar ao menu..." -ForegroundColor Cyan
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

# Menu principal
$running = $true
while ($running) {
    Show-Menu
    $choice = Read-Host "Escolha uma opção"
    
    switch ($choice) {
        "1" { Send-TestMessage }
        "2" { Show-InvitedContacts }
        "3" { Show-Statistics }
        "4" { $running = $false }
        default { 
            Write-Host "Opção inválida. Tente novamente." -ForegroundColor Red
            Start-Sleep -Seconds 1
        }
    }
}

# Sai do script
exit 0 