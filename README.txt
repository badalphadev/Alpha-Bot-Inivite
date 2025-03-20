==========================================
BOT DE CONVITES DISCORD - INSTRUÇÕES
==========================================

Este bot foi projetado para automatizar o envio de convites para seus contatos no Discord,
utilizando padrões seguros para evitar banimento ou restrições na plataforma.
Desenvolvido por AlphaDev.

== CONFIGURAÇÃO INICIAL ==

1. Obtenha seu token do Discord:
   - Abra o Discord no navegador
   - Pressione F12 para abrir as ferramentas de desenvolvedor
   - Vá para a aba "Network"
   - Faça qualquer ação no Discord (enviar mensagem, trocar de canal, etc.)
   - Procure por requisições para "discord.com"
   - Encontre o cabeçalho "Authorization" nos detalhes da requisição
   - Copie o valor (este é seu token)

2. Obtenha um link de convite para seu servidor:
   - No Discord, clique com o botão direito no servidor
   - Selecione "Convidar pessoas"
   - Crie um link de convite
   - Copie o link completo

3. Edite o arquivo config.json:
   - Substitua "SEU_TOKEN_AQUI" pelo token obtido
   - Substitua "SEU_LINK_CONVITE_AQUI" pelo link de convite
   - Personalize as outras configurações conforme necessário:
     * mensagem: Texto que será enviado junto com o convite
     * intervalo_minimo/maximo: Tempo de espera entre convites (em segundos)
     * maximo_convites_por_hora/dia: Limites de envio para evitar banimento
     * horario_inicial/final: Horário permitido para envio de convites
     * pausa_aleatoria: Adiciona pausas aleatórias para simular comportamento humano

== EXECUTANDO O BOT ==

1. Execute o arquivo "IniciarDiscordBot.bat" com duplo clique
2. No menu principal, selecione "1" para iniciar o bot
3. O bot irá:
   - Verificar suas configurações
   - Obter a lista de seus contatos do Discord
   - Enviar convites automaticamente respeitando os limites configurados
   - Registrar todas as atividades no arquivo log.txt

== FUNCIONALIDADES DO MENU ==

[1] Iniciar Bot - Inicia o processo de envio automático de convites
[2] Editar Configurações - Abre o arquivo config.json para edição
[3] Ver Logs - Mostra o histórico de atividades do bot
[4] Ver Contatos Convidados - Lista os IDs dos contatos que já receberam convites
[5] Limpar Logs - Apaga o arquivo de logs
[6] Sair - Fecha o programa

== PRECAUÇÕES DE SEGURANÇA ==

Este bot foi projetado com várias medidas para evitar detecção e banimento:
- Limitação de convites por hora e por dia
- Intervalos aleatórios entre envios
- Pausas mais longas simulando comportamento humano
- Operação apenas em horários específicos
- Controle de contatos já convidados para evitar spam

IMPORTANTE: Mesmo com estas precauções, o uso de automação no Discord viola os
Termos de Serviço da plataforma. Use por sua conta e risco. Recomendamos configurar
limites baixos nas configurações para minimizar o risco de detecção.

== SOLUÇÃO DE PROBLEMAS ==

- Se o bot não iniciar: Verifique se o PowerShell está instalado e se a política de execução permite rodar scripts
- Se nenhum convite for enviado: Verifique se o token está correto e se você tem contatos no Discord
- Se o bot parar inesperadamente: Verifique os logs para identificar o problema

Para mais informações, consulte o arquivo log.txt após executar o bot.

========================================== 