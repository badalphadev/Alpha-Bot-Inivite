# Discord Convite Bot v2.1
# Autor: AlphaDev
# Data: $(Get-Date -Format "dd/MM/yyyy")
# Sistema de automação para envio de convites via API Discord com proteções antiban

# Configurando codificação UTF-8 para evitar problemas com caracteres especiais
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Configurações
$configFile = "config.json"
$logFile = "log.txt"
$convidadosFile = "contatos_convidados.txt"
$convidadosDetailFile = "contatos_convidados_detalhes.json"

# Função para registro de log
function Write-Log {
    param (
        [string]$Message
    )
    
    $timestamp = Get-Date -Format "dd/MM/yyyy HH:mm:ss"
    "$timestamp - $Message" | Out-File -Append -FilePath $logFile -Encoding utf8
    Write-Host "$timestamp - $Message"
}

# Verifica se o arquivo de configuração existe
if (-not (Test-Path $configFile)) {
    Write-Log "Arquivo de configuração não encontrado. Criando arquivo padrão..."
    
    $defaultConfig = @{
        "token" = "SEU_TOKEN_AQUI"
        "link_convite" = "SEU_LINK_CONVITE_AQUI"
        "mensagem" = "Olá! Gostaria de convidar você para o nosso servidor."
        "intervalo_minimo" = 60  # segundos
        "intervalo_maximo" = 180  # segundos
        "maximo_convites_por_hora" = 10
        "maximo_convites_por_dia" = 50
        "horario_inicial" = "08:00"
        "horario_final" = "20:00"
        "pausa_aleatoria" = $true
    }
    
    $defaultConfig | ConvertTo-Json | Out-File -FilePath $configFile -Encoding utf8
    Write-Log "Arquivo de configuração criado. Por favor, edite o arquivo $configFile com suas informações."
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

# Função para gerenciar contatos já convidados
function Get-ContatosConvidados {
    # Verifica se o arquivo de contatos detalhados existe e o carrega
    if (Test-Path $convidadosDetailFile) {
        try {
            $contatosDetalhes = Get-Content $convidadosDetailFile -Encoding utf8 | ConvertFrom-Json
            Write-Log "Arquivo de detalhes de contatos convidados carregado com sucesso."
        } catch {
            Write-Log "Erro ao carregar arquivo de detalhes. Criando novo arquivo: $_"
            $contatosDetalhes = @{}
        }
    } else {
        $contatosDetalhes = @{}
    }
    
    # Verifica se o arquivo simples de contatos existe
    if (Test-Path $convidadosFile) {
        $contatosIds = Get-Content $convidadosFile -Encoding utf8
        
        # Se o arquivo simples existe mas o detalhado não tem todos os registros, atualiza o arquivo detalhado
        foreach ($id in $contatosIds) {
            if (-not [string]::IsNullOrWhiteSpace($id) -and -not $contatosDetalhes.$id) {
                $contatosDetalhes.$id = @{
                    "data_convite" = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
                    "status" = "convidado"
                }
            }
        }
        
        # Salva o arquivo detalhado atualizado
        $contatosDetalhes | ConvertTo-Json | Out-File -FilePath $convidadosDetailFile -Encoding utf8
        
        Write-Log "Carregados $($contatosIds.Count) contatos já convidados."
        return $contatosIds
    } else {
        Write-Log "Arquivo de contatos convidados não encontrado. Criando arquivo vazio."
        "" | Out-File -FilePath $convidadosFile -Encoding utf8
        $contatosDetalhes | ConvertTo-Json | Out-File -FilePath $convidadosDetailFile -Encoding utf8
        return @()
    }
}

# Função para adicionar contato à lista de convidados
function Add-ContatoConvidado {
    param (
        [string]$ContatoId,
        [string]$ContatoUsername
    )
    
    # Adiciona ao arquivo simples
    $ContatoId | Out-File -Append -FilePath $convidadosFile -Encoding utf8
    
    # Carrega o arquivo detalhado, se existir
    if (Test-Path $convidadosDetailFile) {
        try {
            $contatosDetalhes = Get-Content $convidadosDetailFile -Encoding utf8 | ConvertFrom-Json -AsHashtable
        } catch {
            $contatosDetalhes = @{}
        }
    } else {
        $contatosDetalhes = @{}
    }
    
    # Adiciona ou atualiza os detalhes do contato
    $contatosDetalhes[$ContatoId] = @{
        "username" = $ContatoUsername
        "data_convite" = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
        "status" = "convidado"
    }
    
    # Salva o arquivo detalhado
    $contatosDetalhes | ConvertTo-Json | Out-File -FilePath $convidadosDetailFile -Encoding utf8
    
    Write-Log "Contato $ContatoUsername (ID: $ContatoId) adicionado à lista de convidados."
}

# Função para verificar se o horário atual está dentro do período permitido
function Is-HorarioPermitido {
    $horaAtual = Get-Date
    $horaInicial = [DateTime]::ParseExact($config.horario_inicial, "HH:mm", $null)
    $horaFinal = [DateTime]::ParseExact($config.horario_final, "HH:mm", $null)
    
    $horaAtualComparar = New-Object DateTime($horaAtual.Year, $horaAtual.Month, $horaAtual.Day, $horaAtual.Hour, $horaAtual.Minute, 0)
    $horaInicialComparar = New-Object DateTime($horaAtual.Year, $horaAtual.Month, $horaAtual.Day, $horaInicial.Hour, $horaInicial.Minute, 0)
    $horaFinalComparar = New-Object DateTime($horaAtual.Year, $horaAtual.Month, $horaAtual.Day, $horaFinal.Hour, $horaFinal.Minute, 0)
    
    return $horaAtualComparar -ge $horaInicialComparar -and $horaAtualComparar -le $horaFinalComparar
}

# Função para obter todos os contatos (IDs de usuários) do Discord
function Get-DiscordContatos {
    param (
        [string]$Token
    )
    
    try {
        $headers = @{
            "Authorization" = $Token
            "Content-Type" = "application/json"
        }
        
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
        
        return $contatos
    } catch {
        Write-Log "Erro ao obter contatos: $_"
        return @()
    }
}

# Função para enviar convite para um contato
function Send-Convite {
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
        
        # Corrigindo a formatação do JSON para evitar caracteres especiais problemáticos
        $conteudo = "$Mensagem $LinkConvite"
        $bodyObj = @{
            "content" = $conteudo
        }
        
        # Convertendo para JSON com codificação UTF-8 e sem caracteres especiais escapados
        $bodyJson = ConvertTo-Json -InputObject $bodyObj -Depth 1 -Compress
        
        Write-Log "Enviando mensagem: $conteudo"
        Write-Log "JSON sendo enviado: $bodyJson"
        
        $response = Invoke-RestMethod -Uri "https://discord.com/api/v9/channels/$ChannelId/messages" -Headers $headers -Method Post -Body $bodyJson -ContentType "application/json; charset=utf-8"
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
        
        Write-Log "Erro ao enviar convite: $_"
        return $false
    }
}

# Inicializa contadores
$convitesEnviadosHoje = 0
$convitesEnviadosUltimaHora = 0
$ultimaHoraVerificada = Get-Date

# Função para atualizar contadores por tempo
function Update-Contadores {
    $horaAtual = Get-Date
    
    # Verifica se é um novo dia
    if ($horaAtual.Date -gt $ultimaHoraVerificada.Date) {
        $script:convitesEnviadosHoje = 0
        Write-Log "Novo dia iniciado. Contador diário zerado."
    }
    
    # Verifica se passou uma hora
    if ($horaAtual -gt $ultimaHoraVerificada.AddHours(1)) {
        $script:convitesEnviadosUltimaHora = 0
        $script:ultimaHoraVerificada = $horaAtual
        Write-Log "Nova hora iniciada. Contador por hora zerado."
    }
}

# Função para estatísticas de convites
function Get-EstatisticasConvites {
    if (Test-Path $convidadosDetailFile) {
        try {
            $contatosDetalhes = Get-Content $convidadosDetailFile -Encoding utf8 | ConvertFrom-Json
            $total = ($contatosDetalhes | Get-Member -MemberType NoteProperty).Count
            
            Write-Log "Estatísticas de Convites:"
            Write-Log "- Total de contatos convidados: $total"
            
            # Convites enviados hoje
            $hoje = Get-Date -Format "yyyy-MM-dd"
            $convitesHoje = 0
            
            foreach ($prop in ($contatosDetalhes | Get-Member -MemberType NoteProperty)) {
                $contato = $contatosDetalhes.($prop.Name)
                $dataConvite = [DateTime]::ParseExact($contato.data_convite.Substring(0, 10), "yyyy-MM-dd", $null)
                
                if ($dataConvite.ToString("yyyy-MM-dd") -eq $hoje) {
                    $convitesHoje++
                }
            }
            
            Write-Log "- Convites enviados hoje: $convitesHoje"
            
        } catch {
            Write-Log "Erro ao calcular estatísticas: $_"
        }
    } else {
        Write-Log "Nenhum registro de convites encontrado."
    }
}

# Função principal
function Start-EnvioConvites {
    Write-Log "Iniciando processo de envio de convites..."
    
    # Obter lista de contatos
    Write-Log "Obtendo lista de contatos..."
    $contatos = Get-DiscordContatos -Token $config.token
    
    if ($contatos.Count -eq 0) {
        Write-Log "Nenhum contato encontrado. Verifique seu token ou suas mensagens diretas."
        return
    }
    
    Write-Log "Encontrados $($contatos.Count) contatos."
    
    # Carrega lista de contatos já convidados
    $contatosConvidados = Get-ContatosConvidados
    
    # Exibe estatísticas
    Get-EstatisticasConvites
    
    foreach ($contato in $contatos) {
        # Atualiza contadores
        Update-Contadores
        
        # Verifica se pode enviar mais convites hoje
        if ($convitesEnviadosHoje -ge $config.maximo_convites_por_dia) {
            Write-Log "Limite diário de convites atingido ($($config.maximo_convites_por_dia)). Parando por hoje."
            break
        }
        
        # Verifica se pode enviar mais convites nesta hora
        if ($convitesEnviadosUltimaHora -ge $config.maximo_convites_por_hora) {
            Write-Log "Limite de convites por hora atingido ($($config.maximo_convites_por_hora)). Esperando até a próxima hora."
            $minutosEspera = 60 - (Get-Date).Minute
            Write-Log "Esperando $minutosEspera minutos..."
            Start-Sleep -Seconds ($minutosEspera * 60)
            $convitesEnviadosUltimaHora = 0
        }
        
        # Verifica se está no horário permitido
        if (-not (Is-HorarioPermitido)) {
            $horaAtual = Get-Date -Format "HH:mm"
            Write-Log "Fora do horário permitido ($horaAtual). Horário permitido: $($config.horario_inicial) até $($config.horario_final). Pausando..."
            
            # Calcula tempo até o próximo horário permitido
            $horaAtual = Get-Date
            $horaInicial = [DateTime]::ParseExact($config.horario_inicial, "HH:mm", $null)
            $proximoHorario = New-Object DateTime($horaAtual.Year, $horaAtual.Month, $horaAtual.Day, $horaInicial.Hour, $horaInicial.Minute, 0)
            
            if ($proximoHorario -lt $horaAtual) {
                $proximoHorario = $proximoHorario.AddDays(1)
            }
            
            $tempoEspera = ($proximoHorario - $horaAtual).TotalSeconds
            Write-Log "Esperando até o próximo horário permitido ($($proximoHorario.ToString("dd/MM/yyyy HH:mm"))). Tempo de espera: $([math]::Round($tempoEspera/60)) minutos."
            Start-Sleep -Seconds $tempoEspera
            $convitesEnviadosHoje = 0
            $convitesEnviadosUltimaHora = 0
            continue
        }
        
        # Verifica se o contato já foi convidado
        if ($contatosConvidados -contains $contato.Id) {
            Write-Log "Contato $($contato.Username) já foi convidado anteriormente. Pulando."
            continue
        }
        
        # Envia convite
        Write-Log "Enviando convite para $($contato.Username) (ID: $($contato.Id))..."
        $sucesso = Send-Convite -Token $config.token -ChannelId $contato.ChannelId -Mensagem $config.mensagem -LinkConvite $config.link_convite
        
        if ($sucesso) {
            Write-Log "Convite enviado com sucesso para $($contato.Username)!"
            
            # Atualiza contadores
            $convitesEnviadosHoje++
            $convitesEnviadosUltimaHora++
            
            # Adiciona contato à lista de convidados com detalhes
            Add-ContatoConvidado -ContatoId $contato.Id -ContatoUsername $contato.Username
            
            # Adiciona pausa para evitar detecção
            $tempoEspera = Get-Random -Minimum $config.intervalo_minimo -Maximum $config.intervalo_maximo
            Write-Log "Esperando $tempoEspera segundos antes do próximo envio..."
            Start-Sleep -Seconds $tempoEspera
            
            # Se configurado, adiciona pausas aleatórias para comportamento mais humano
            if ($config.pausa_aleatoria -and (Get-Random -Minimum 1 -Maximum 10) -eq 1) {
                $pausaLonga = Get-Random -Minimum 300 -Maximum 900  # 5-15 minutos
                Write-Log "Adicionando pausa aleatória de $([math]::Round($pausaLonga/60)) minutos para simular comportamento humano..."
                Start-Sleep -Seconds $pausaLonga
            }
        } else {
            Write-Log "Falha ao enviar convite para $($contato.Username). Tentando novamente mais tarde."
            # Espera um tempo maior em caso de falha para evitar bloqueios
            Start-Sleep -Seconds (Get-Random -Minimum 300 -Maximum 600)
        }
    }
    
    Write-Log "Processo de envio de convites concluído. Total enviado hoje: $convitesEnviadosHoje"
}

# Inicia o processo
Write-Log "Script iniciado. Verificando configurações..."

# Loop principal
while ($true) {
    if (Is-HorarioPermitido) {
        Start-EnvioConvites
    } else {
        $horaAtual = Get-Date -Format "HH:mm"
        Write-Log "Fora do horário permitido ($horaAtual). Horário permitido: $($config.horario_inicial) até $($config.horario_final). Esperando..."
        
        # Calcula tempo até o próximo horário permitido
        $horaAtual = Get-Date
        $horaInicial = [DateTime]::ParseExact($config.horario_inicial, "HH:mm", $null)
        $proximoHorario = New-Object DateTime($horaAtual.Year, $horaAtual.Month, $horaAtual.Day, $horaInicial.Hour, $horaInicial.Minute, 0)
        
        if ($proximoHorario -lt $horaAtual) {
            $proximoHorario = $proximoHorario.AddDays(1)
        }
        
        $tempoEspera = ($proximoHorario - $horaAtual).TotalSeconds
        Write-Log "Esperando até o próximo horário permitido ($($proximoHorario.ToString("dd/MM/yyyy HH:mm"))). Tempo de espera: $([math]::Round($tempoEspera/60)) minutos."
        Start-Sleep -Seconds $tempoEspera
    }
} 