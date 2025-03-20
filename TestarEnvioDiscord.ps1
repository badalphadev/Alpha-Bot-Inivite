# Script para testar o envio de mensagens no Discord
# Este script verifica a conexão com a API do Discord e testa o envio de uma mensagem

# Configurações
$configFile = "config.json"
$logFile = "teste_log.txt"

# Função para registro de log
function Write-Log {
    param (
        [string]$Message
    )
    
    $timestamp = Get-Date -Format "dd/MM/yyyy HH:mm:ss"
    "$timestamp - $Message" | Out-File -Append -FilePath $logFile -Encoding utf8
    Write-Host "$timestamp - $Message"
}

# Limpa o arquivo de log de teste se existir
if (Test-Path $logFile) {
    Remove-Item $logFile -Force
}

Write-Log "Iniciando teste de envio de mensagens no Discord..."

# Verifica se o arquivo de configuração existe
if (-not (Test-Path $configFile)) {
    Write-Log "Arquivo de configuração não encontrado. Por favor, certifique-se de que o arquivo config.json existe."
    exit
}

# Carrega as configurações
try {
    $config = Get-Content $configFile -Encoding utf8 | ConvertFrom-Json
    Write-Log "Configurações carregadas com sucesso."
} catch {
    Write-Log "Erro ao carregar configurações: $_"
    exit
}

# Verifica token
if ($config.token -eq "SEU_TOKEN_AQUI" -or [string]::IsNullOrEmpty($config.token)) {
    Write-Log "Por favor, configure seu token no arquivo $configFile"
    exit
}

# Verifica link de convite
if ($config.link_convite -eq "SEU_LINK_CONVITE_AQUI" -or [string]::IsNullOrEmpty($config.link_convite)) {
    Write-Log "Por favor, configure o link de convite no arquivo $configFile"
    exit
}

# Função para testar a autenticação
function Test-Autenticacao {
    param (
        [string]$Token
    )
    
    try {
        $headers = @{
            "Authorization" = $Token
            "Content-Type" = "application/json"
        }
        
        Write-Log "Testando conexão com a API do Discord..."
        $response = Invoke-RestMethod -Uri "https://discord.com/api/v9/users/@me" -Headers $headers -Method Get
        Write-Log "Conexão bem-sucedida! Conectado como: $($response.username)#$($response.discriminator)"
        return $true
    } catch {
        Write-Log "Erro ao conectar com a API do Discord: $_"
        return $false
    }
}

# Função para obter contatos
function Get-DiscordContatos {
    param (
        [string]$Token
    )
    
    try {
        $headers = @{
            "Authorization" = $Token
            "Content-Type" = "application/json"
        }
        
        Write-Log "Obtendo lista de contatos..."
        $response = Invoke-RestMethod -Uri "https://discord.com/api/v9/users/@me/channels" -Headers $headers -Method Get
        
        $contatos = @()
        foreach ($channel in $response) {
            # Filtrar apenas mensagens diretas (DMs)
            if ($channel.type -eq 1) {
                $recipientId = $channel.recipients[0].id
                $recipientUsername = $channel.recipients[0].username
                
                $contatos += [PSCustomObject]@{
                    Id = $recipientId
                    Username = $recipientUsername
                    ChannelId = $channel.id
                }
            }
        }
        
        Write-Log "Encontrados $($contatos.Count) contatos."
        return $contatos
    } catch {
        Write-Log "Erro ao obter contatos: $_"
        return @()
    }
}

# Função para enviar mensagem de teste
function Send-MensagemTeste {
    param (
        [string]$Token,
        [string]$ChannelId,
        [string]$Mensagem,
        [string]$LinkConvite
    )
    
    try {
        $headers = @{
            "Authorization" = $Token
            "Content-Type" = "application/json"
        }
        
        # Preparando o corpo da requisição
        $conteudo = "$Mensagem $LinkConvite"
        $bodyObj = @{
            "content" = $conteudo
        }
        
        # Convertendo para JSON com codificação UTF-8
        $bodyJson = ConvertTo-Json -InputObject $bodyObj -Depth 1 -Compress
        
        Write-Log "Enviando mensagem: $conteudo"
        Write-Log "JSON sendo enviado: $bodyJson"
        
        # Enviando a requisição com charset UTF-8 explícito
        $response = Invoke-RestMethod -Uri "https://discord.com/api/v9/channels/$ChannelId/messages" -Headers $headers -Method Post -Body $bodyJson -ContentType "application/json; charset=utf-8"
        
        Write-Log "Mensagem enviada com sucesso! ID da mensagem: $($response.id)"
        return $true
    } catch {
        $errorDetails = $_.Exception.Response
        
        if ($errorDetails) {
            try {
                $reader = New-Object System.IO.StreamReader($errorDetails.GetResponseStream())
                $errorContent = $reader.ReadToEnd()
                Write-Log "Detalhes do erro: $errorContent"
            } catch {
                Write-Log "Não foi possível ler detalhes do erro."
            }
        }
        
        Write-Log "Erro ao enviar mensagem: $_"
        return $false
    }
}

# Inicia o processo de teste
$autenticado = Test-Autenticacao -Token $config.token

if ($autenticado) {
    $contatos = Get-DiscordContatos -Token $config.token
    
    if ($contatos.Count -eq 0) {
        Write-Log "Nenhum contato encontrado. Verifique se você tem mensagens diretas no Discord."
        exit
    }
    
    # Solicita ao usuário que selecione um contato para teste
    Write-Host "`nSelecione um contato para enviar uma mensagem de teste:`n"
    
    for ($i = 0; $i -lt [Math]::Min($contatos.Count, 10); $i++) {
        Write-Host "[$i] $($contatos[$i].Username) (ID: $($contatos[$i].Id))"
    }
    
    Write-Host ""
    $selecao = Read-Host "Digite o número do contato (0-$([Math]::Min($contatos.Count, 10) - 1))"
    
    if ($selecao -match '^\d+$' -and [int]$selecao -ge 0 -and [int]$selecao -lt $contatos.Count) {
        $contatoSelecionado = $contatos[[int]$selecao]
        
        Write-Log "Contato selecionado: $($contatoSelecionado.Username) (ID: $($contatoSelecionado.Id))"
        
        # Envia a mensagem de teste
        $mensagemTeste = "[TESTE] " + $config.mensagem
        $sucesso = Send-MensagemTeste -Token $config.token -ChannelId $contatoSelecionado.ChannelId -Mensagem $mensagemTeste -LinkConvite $config.link_convite
        
        if ($sucesso) {
            Write-Log "Teste concluído com sucesso! O envio de mensagens está funcionando corretamente."
        } else {
            Write-Log "Teste falhou. Verifique os detalhes do erro acima."
        }
    } else {
        Write-Log "Seleção inválida. Por favor, execute o teste novamente."
    }
} else {
    Write-Log "Não foi possível autenticar com o token fornecido. Verifique se o token está correto e tente novamente."
}

Write-Host "`nPressione qualquer tecla para sair..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") 