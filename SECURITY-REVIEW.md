# Revisão profissional — Kiany & Julieta

## Estado confirmado em 20/11/2026

- Branch de trabalho: `improvement/professional-hardening`.
- PR #1 permanece Draft e não foi integrada na `main`.
- Duas migrações de segurança foram aplicadas ao projecto Supabase após backup confirmado: `secure_event_access` e `revoke_rls_auto_enable_api_access`.
- A base contém 36 convidados e 0 registos em `checkin_logs` na última verificação.
- As contas Auth `admin1@example.com`, `admin2@example.com` e `portaria@example.com` foram criadas, mas os respectivos papéis `app_metadata.role` continuam NULL.
- Não foi criado nem publicado qualquer Edge Function para atribuir papéis.
- Não foi efectuado merge nem deploy de produção nesta fase.

## Melhorias implementadas na branch

- Check-in só é confirmado após resposta positiva da RPC `process_checkin`.
- Falha de rede não simula sucesso nem incrementa contadores locais.
- Identificadores de check-in usam UUID criptográfico.
- Conteúdo dinâmico proveniente de convites e respostas é escapado antes de ser inserido em HTML.
- Cache PWA limitado ao shell estático da mesma origem; endpoints de API não são guardados.
- Cache versionada e limpeza de versões antigas.
- Melhorias de layout mobile e respeito por `prefers-reduced-motion`.
- Login Supabase Auth preparado no painel e na portaria, condicionado a papéis em `app_metadata`.

## Situação de acesso — bloqueio funcional conhecido

As políticas RLS actuais exigem utilizadores autenticados com papel adequado:
- `admin` para gestão do painel e leitura dos logs;
- `gate` ou `admin` para leitura de convidados e execução da RPC de check-in.

Como os três utilizadores ainda não têm papel, o login não permite utilizar as interfaces protegidas. Não remover o login do frontend nem reabrir permissões para `anon` como atalho: isso contrariaria as protecções aplicadas à base de dados e poderia expor dados pessoais dos convidados.

A decisão actual é suspender a configuração das contas e continuar apenas com melhorias que não dependam de novas credenciais. As contas existentes não foram apagadas.

## Verificações recentes

- RLS está activa nas tabelas `guests` e `checkin_logs`.
- A função `process_checkin` está disponível para `authenticated` e é SECURITY DEFINER, com verificação do papel dentro da função.
- O advisor de segurança ainda alerta para a função SECURITY DEFINER executável por utilizadores autenticados; esta execução é intencional para a RPC de check-in, mas deve continuar sob revisão.
- O advisor também assinala a protecção contra palavras-passe comprometidas desactivada.
- O advisor de desempenho assinala chamadas de auth repetidas nas políticas RLS e ausência de índice na chave estrangeira de `checkin_logs`. São optimizações futuras, não alterações urgentes.
- Não foi realizado teste browser de login/check-in ponta a ponta.

## Regras de segurança e operação

1. Nunca colocar a chave `service_role` ou secret key no frontend, no repositório ou nesta conversa.
2. Não alterar directamente `auth.users` por SQL para atribuir papéis. Usar apenas mecanismos administrativos oficiais do Supabase.
3. Não conceder acesso público às tabelas nem à RPC para contornar o bloqueio de autenticação.
4. Não executar novas migrações de produção, fazer merge ou publicar deploy sem revisão e autorização explícita.
5. Preservar os convidados e o histórico existentes.

## Próximas melhorias de baixo risco

- Rever acessibilidade, mensagens de erro e estados de carregamento.
- Melhorar validações de formulários e experiência mobile.
- Rever a lista de contingência e instruções operacionais.
- Corrigir documentação e preparar testes estáticos sem tocar nos dados de produção.
- Deixar a activação do fluxo de autenticação/check-in para uma fase própria, com teste controlado.
