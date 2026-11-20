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
