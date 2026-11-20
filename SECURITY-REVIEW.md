# Revisão profissional — Kiany & Julieta

## Estado confirmado em 20/11/2026

- Branch de trabalho: `improvement/professional-hardening`.
- PR #1 permanece Draft e não foi integrada na `main`.
- As migrações `secure_event_access` e `revoke_rls_auto_enable_api_access` foram aplicadas ao Supabase após backup confirmado.
- Última contagem verificada: 36 convidados, 0 registos em `checkin_logs` e 1 conta Auth.
- A conta `adnilsonsalvador21@gmail.com` tem `app_metadata.role = admin`, email confirmado e primeiro início de sessão confirmado.
- A função temporária de bootstrap foi removida; o utilizador confirmou também a remoção do segredo temporário.
- Não foi efectuado merge nem publicação de produção nesta fase.

## Melhorias na branch

- Painel e portaria usam Supabase Auth por email e palavra-passe.
- A conta com papel `admin` pode aceder ao painel e à portaria; não é necessária uma segunda conta `gate` para este evento.
- O painel exige papel `admin`; a portaria aceita `gate` ou `admin`.
- Check-in só é confirmado após resposta positiva da RPC `process_checkin`.
- Falha de rede não simula sucesso nem incrementa contadores locais.
- O painel bloqueia criação, edição e eliminação quando não há ligação à base central; evita alterações locais que não seriam sincronizadas.
- A pesquisa e a validação da portaria escapam os nomes e mesas dos convidados antes de os inserir em HTML.
- Identificadores de check-in usam UUID criptográfico.
- Conteúdo dinâmico proveniente de convites e respostas é escapado antes de ser inserido em HTML.
- Cache PWA limitado ao shell da aplicação; endpoints Auth e REST não são guardados.
- Cache versionada e limpeza de versões antigas.
- Melhorias de layout mobile e respeito por `prefers-reduced-motion`.

## Segurança e dados

- As políticas RLS restringem gestão de convidados ao papel `admin`.
- A leitura de convidados na portaria aceita `gate` ou `admin`.
- A leitura de `checkin_logs` está restrita a `admin`.
- A RPC `process_checkin` valida o papel dentro da função, valida quantidade/token, bloqueia concorrência por convidado e usa identificador idempotente.
- A chave `service_role` não deve ser colocada no frontend, no repositório ou em mensagens.
- Não alterar directamente `auth.users` por SQL para atribuir papéis.
- Não reabrir permissões públicas `anon` como atalho.

## Auditoria adicional em 20/11/2026

- Consulta às FKs e colunas `user_id`: não foram encontradas relações activas com `auth.users` nem FKs em colunas chamadas `user_id` no esquema consultado. Não há migração de autoria por utilizador a fazer neste modelo actual de conta única.
- Relação existente relevante: `checkin_logs.guest_id` referencia convidados; o advisor recomenda índice de cobertura nessa FK.
- RLS está activo em `guests` e `checkin_logs`; o papel `anon` não tem SELECT nas duas tabelas. O papel `authenticated` tem privilégios SQL, mas as políticas RLS limitam as linhas por papel.
- Políticas observadas: administração de convidados apenas para `admin`; leitura de convidados para `gate` ou `admin`; leitura de logs apenas para `admin`.
- A RPC `process_checkin` está em `SECURITY DEFINER`, com validação interna de `app_metadata.role` para `gate/admin`, tabelas qualificadas pelo schema e execução concedida a `authenticated` e `service_role`. O advisor continua a sinalizar a função porque é executável por utilizadores autenticados; esta é uma excepção deliberada para manter a operação atómica, mas merece revisão específica antes de ampliar o sistema.
- Advisors de segurança: protecção contra palavras-passe comprometidas desactivada; aviso da RPC SECURITY DEFINER.
- Advisors de desempenho: índice em falta na FK `checkin_logs.guest_id`; três avisos de initplan nas políticas RLS; políticas SELECT permissivas sobrepostas em `guests`; dois índices de convidados ainda sem uso observado. Com apenas 36 convidados, não justifica introduzir alterações de esquema arriscadas antes do evento.
- A branch foi actualizada com escape HTML na portaria e bloqueio de mutações administrativas offline. Ainda falta executar validação sintáctica automatizada e testes funcionais autenticados; estes não foram simulados contra convidados reais.

## Limitações ainda por fechar

- A validação funcional foi confirmada pelo responsável do projecto; não existe nesta revisão evidência independente de um teste browser automatizado com sessão autenticada.
- O advisor Supabase assinalou anteriormente a função SECURITY DEFINER (intencional na RPC, com validação de papel), protecção contra palavras-passe comprometidas desactivada e optimizações de índices/políticas RLS.
- A aplicação publicada a partir de `main` continua incompatível com as políticas de segurança aplicadas à base até que a branch seja revista e integrada. Não usar a versão antiga para operações protegidas.

## Regras de operação

1. Preservar os 36 convidados e o histórico.
2. Não publicar deploy nem alterar produção sem autorização explícita.
3. Não fazer merge na `main` sem autorização explícita.
4. Não executar check-ins de teste com convidados reais; usar apenas um registo de teste isolado e aprovado, se necessário.
5. Manter a solução simples para o evento e evitar serviços pagos desnecessários.
