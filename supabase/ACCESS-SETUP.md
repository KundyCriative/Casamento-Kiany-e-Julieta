# Preparação de acessos — Kiany & Julieta

## Estado actual

A configuração de utilizadores foi suspensa temporariamente por decisão do responsável pelo projecto.

As contas seguintes existem no Supabase Auth, mas ainda não têm papel atribuído em `app_metadata.role`:
- `admin1@example.com`
- `admin2@example.com`
- `portaria@example.com`

Não foram apagadas. Não foi publicada Edge Function para lhes atribuir papéis.

## Modelo de permissões preparado

- `admin`: acesso ao painel e gestão de convidados.
- `gate`: acesso operacional da portaria, leitura de convidados e execução da RPC de check-in.
- Os papéis são verificados em `app_metadata`, não em `user_metadata`.

## Importante — não contornar a segurança

As migrações de segurança já foram aplicadas ao projecto Supabase. Por isso, as interfaces protegidas exigem uma sessão autenticada com o papel correcto.

Não:
- actualizar directamente `auth.users` com SQL;
- conceder novamente acesso público a `anon` nas tabelas;
- colocar uma chave `service_role` no browser ou no repositório;
- publicar uma função administrativa sem autenticação e validação completas.

A atribuição futura dos papéis deverá ser feita pela Admin API oficial do Supabase, através de um processo administrativo seguro.

## Migrações aplicadas

- `20261120_secure_event_access`
- `20261120_revoke_rls_auto_enable_api_access`

As migrações preservaram os dados existentes. Última verificação: 36 convidados e 0 check-ins.

## Retoma futura

Quando houver disponibilidade para concluir a autenticação:
1. Atribuir `app_metadata.role = admin` às contas administrativas e `app_metadata.role = gate` à conta da portaria, através de mecanismo oficial.
2. Renovar as sessões Auth.
3. Testar painel, leitura de convidados e check-in com convite de teste.
4. Confirmar que o histórico é gravado uma única vez e que falhas de rede não simulam sucesso.

Até lá, manter a base protegida e não activar o check-in sem autenticação válida.
