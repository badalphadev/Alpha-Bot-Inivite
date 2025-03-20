# Discord Convite Bot v2.1
# Autor: AlphaDev
# Data: $(Get-Date -Format "dd/MM/yyyy")
# Sistema de automação para envio de convites via API Discord com proteções antiban

# Parâmetros para testes
param (
    [switch]$TestarEnvio,
    [string]$UsuarioTeste
)

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

# Função para carregar contatos já convidados
function Get-ContatosConvidados {
    if (Test-Path $convidadosFile) {
        $contatosIds = Get-Content $convidadosFile -Encoding utf8
        Write-Log "Carregados $($contatosIds.Count) contatos já convidados."
        return $contatosIds
    } else {
        Write-Log "Arquivo de contatos convidados não encontrado. Criando arquivo vazio."
        "" | Out-File -FilePath $convidadosFile -Encoding utf8
        return @()
    }
}

# Função para obter detalhes dos contatos convidados
function Get-ContatosDetalhes {
    if (Test-Path $convidadosDetailFile) {
        try {
            $detalhes = Get-Content $convidadosDetailFile -Raw | ConvertFrom-Json
            return $detalhes
        } catch {
            Write-Log "Erro ao carregar detalhes de contatos: $_"
            return $null
        }
    } else {
        $detalhes = [PSCustomObject]@{}
        $detalhes | ConvertTo-Json | Out-File -FilePath $convidadosDetailFile -Encoding utf8
        return $detalhes
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
    $detalhes = Get-ContatosDetalhes
    
    # Cria um objeto temporário para o contato
    $novoContato = [PSCustomObject]@{
        username = $ContatoUsername
        data_convite = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
        status = "convidado"
    }
    
    # Adiciona o novo contato ao objeto de detalhes
    Add-Member -InputObject $detalhes -MemberType NoteProperty -Name $ContatoId -Value $novoContato -Force
    
    # Salva o arquivo detalhado
    $detalhes | ConvertTo-Json | Out-File -FilePath $convidadosDetailFile -Encoding utf8
    
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

# Função para obter contatos do Discord (simulada para teste)
function Get-DiscordContatos {
    param (
        [string]$Token
    )
    
    Write-Log "Conectando ao Discord e buscando contatos..."
    
    # Esta é uma função simulada para testes
    # Em um ambiente real, aqui seria a chamada à API do Discord
    
    $contatos = @(
        [PSCustomObject]@{ Id = "user1"; Username = "Usuario1#1234" },
        [PSCustomObject]@{ Id = "user2"; Username = "Usuario2#5678" },
        [PSCustomObject]@{ Id = "user3"; Username = "Usuario3#9012" }
    )
    
    Write-Log "Encontrados $($contatos.Count) contatos."
    return $contatos
}

# Função para enviar convite para um contato (simulada para teste)
function Send-DiscordConvite {
    param (
        [string]$Token,
        [string]$ContatoId,
        [string]$ContatoUsername,
        [string]$Mensagem
    )
    
    Write-Log "Enviando convite para $ContatoUsername (ID: $ContatoId)..."
    
    # Esta é uma função simulada para testes
    # Em um ambiente real, aqui seria a chamada à API do Discord
    
    # Simula uma pequena chance de falha (~5%)
    $random = Get-Random -Minimum 1 -Maximum 100
    if ($random -le 5) {
        Write-Log "Falha ao enviar convite para $ContatoUsername. Erro de conexão simulado."
        return $false
    }
    
    # Registra o convite como enviado
    Add-ContatoConvidado -ContatoId $ContatoId -ContatoUsername $ContatoUsername
    
    Write-Log "Convite enviado com sucesso para $ContatoUsername!"
    return $true
}

# Função para enviar uma mensagem para um usuário de teste
function Test-EnvioMensagem {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Usuario
    )
    
    Write-Log "Iniciando teste de envio para usuário: $Usuario"
    
    try {
        # Verifica se o usuário já foi convidado
        $convidados = Get-ContatosConvidados
        $jaConvidado = $convidados -contains $Usuario
        if ($jaConvidado) {
            Write-Log "AVISO: Usuário $Usuario já foi convidado anteriormente"
            Write-Host "AVISO: Este usuário já recebeu um convite anteriormente!" -ForegroundColor Yellow
        }
        
        # Envia a mensagem
        Write-Log "Enviando mensagem para $Usuario..."
        
        # Preparando a mensagem com o link
        $mensagemCompleta = $config.mensagem
        if ($mensagemCompleta -match "\[Alpha Store\]") {
            $mensagemCompleta = $mensagemCompleta -replace "\[Alpha Store\]", "[$($config.link_convite)]"
        } else {
            $mensagemCompleta += "`n`n$($config.link_convite)"
        }
        
        # Aqui seria a chamada à API do Discord, que está simulada para teste
        Write-Log "Mensagem enviada com sucesso para $Usuario"
        Write-Log "Conteúdo da mensagem: $mensagemCompleta"
        
        # Registra o usuário como convidado
        Add-ContatoConvidado -ContatoId $Usuario -ContatoUsername $Usuario
        
        Write-Log "Teste de envio concluído com sucesso!"
        Write-Host "Mensagem enviada com sucesso para $Usuario!" -ForegroundColor Green
        
        return $true
    }
    catch {
        $erro = $Error[0]
        Write-Log "ERRO ao enviar mensagem para $Usuario. Detalhes: Erro interno."
        Write-Host "ERRO ao enviar mensagem. Detalhes: Erro interno." -ForegroundColor Red
        return $false
    }
}

# Função para obter estatísticas de envio
function Get-EstatisticasConvites {
    $convidados = Get-ContatosConvidados
    $totalConvidados = $convidados.Count
    
    $hoje = Get-Date -Format "yyyy-MM-dd"
    $convidadosHoje = 0
    
    $detalhes = Get-ContatosDetalhes
    if ($detalhes -ne $null) {
        foreach ($prop in $detalhes.PSObject.Properties) {
            $dataConvite = $prop.Value.data_convite
            if ($dataConvite -match $hoje) {
                $convidadosHoje++
            }
        }
    }
    
    return @{
        Total = $totalConvidados
        Hoje = $convidadosHoje
    }
}

# Função principal para iniciar o envio de convites
function Start-EnvioConvites {
    Write-Log "Iniciando processo de envio de convites..."
    
    # Carrega lista de contatos já convidados
    $contatosConvidados = Get-ContatosConvidados
    
    # Exibe estatísticas
    $stats = Get-EstatisticasConvites
    Write-Log "Total de contatos já convidados: $($stats.Total)"
    Write-Log "Contatos convidados hoje: $($stats.Hoje)"
    
    # Verifica limites diários
    if ($stats.Hoje -ge $config.maximo_convites_por_dia) {
        Write-Log "Limite diário de convites atingido ($($stats.Hoje)/$($config.maximo_convites_por_dia)). Aguardando próximo dia."
        Start-Sleep -Seconds 3600  # Espera 1 hora antes de verificar novamente
        return
    }
    
    # Busca contatos do Discord
    $contatos = Get-DiscordContatos -Token $config.token
    
    # Contador de convites enviados na hora atual
    $convitesEnviadosHora = 0
    $convitesEnviadosHoje = $stats.Hoje
    $horaInicio = Get-Date
    
    foreach ($contato in $contatos) {
        # Verifica se atingiu o limite de convites por hora
        if ($convitesEnviadosHora -ge $config.maximo_convites_por_hora) {
            Write-Log "Limite de convites por hora atingido ($($convitesEnviadosHora)/$($config.maximo_convites_por_hora)). Aguardando próxima hora."
            Start-Sleep -Seconds 3600  # Espera 1 hora
            $convitesEnviadosHora = 0
            $horaInicio = Get-Date
        }
        
        # Verifica se atingiu o limite diário
        if ($convitesEnviadosHoje -ge $config.maximo_convites_por_dia) {
            Write-Log "Limite diário de convites atingido ($($convitesEnviadosHoje)/$($config.maximo_convites_por_dia)). Aguardando próximo dia."
            return
        }
        
        # Verifica se o contato já foi convidado
        if ($contatosConvidados -contains $contato.Id) {
            Write-Log "Contato $($contato.Username) já foi convidado anteriormente. Pulando."
            continue
        }
        
        # Preparando a mensagem com o link
        $mensagemCompleta = $config.mensagem
        if ($mensagemCompleta -match "\[Alpha Store\]") {
            $mensagemCompleta = $mensagemCompleta -replace "\[Alpha Store\]", "[$($config.link_convite)]"
        } else {
            $mensagemCompleta += "`n`n$($config.link_convite)"
        }
        
        # Envia o convite
        $enviado = Send-DiscordConvite -Token $config.token -ContatoId $contato.Id -ContatoUsername $contato.Username -Mensagem $mensagemCompleta
        
        if ($enviado) {
            $convitesEnviadosHora++
            $convitesEnviadosHoje++
            Write-Log "Convite enviado com sucesso para $($contato.Username) ($($convitesEnviadosHoje)/$($config.maximo_convites_por_dia) hoje)"
            
            # Adiciona pausa aleatória entre mensagens
            $tempoEspera = Get-Random -Minimum $config.intervalo_minimo -Maximum $config.intervalo_maximo
            Write-Log "Aguardando $tempoEspera segundos antes do próximo envio..."
            Start-Sleep -Seconds $tempoEspera
            
            # Adiciona pausas aleatórias extras para evitar detecção
            if ($config.pausa_aleatoria -eq $true -and (Get-Random -Minimum 1 -Maximum 10) -eq 1) {
                $pausaAleatoria = Get-Random -Minimum 120 -Maximum 300
                Write-Log "Adicionando pausa aleatória de $pausaAleatoria segundos para evitar detecção..."
                Start-Sleep -Seconds $pausaAleatoria
            }
        } else {
            Write-Log "Falha ao enviar convite para $($contato.Username). Tentando próximo contato."
            Start-Sleep -Seconds 30  # Espera 30 segundos antes de tentar o próximo
        }
    }
    
    Write-Log "Processo de envio de convites concluído. Total enviado hoje: $convitesEnviadosHoje"
}

# Inicia o processo
Write-Log "Script iniciado. Verificando configurações..."

# Verifica se é um teste de envio
if ($TestarEnvio) {
    if ([string]::IsNullOrEmpty($UsuarioTeste)) {
        Write-Log "ERRO: Para testar o envio, é necessário informar um usuário com -UsuarioTeste"
        Write-Host "ERRO: Para testar o envio, é necessário informar um usuário" -ForegroundColor Red
        exit 1
    }
    
    Test-EnvioMensagem -Usuario $UsuarioTeste
    exit 0
}

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