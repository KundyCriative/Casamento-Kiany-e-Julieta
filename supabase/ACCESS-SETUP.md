# Acesso à aplicação — Kiany & Julieta

## Estado actual

O projecto utiliza uma única conta para o responsável, tanto no painel administrativo como na portaria:

- Email: `adnilsonsalvador21@gmail.com`
- Papel em `app_metadata.role`: `admin`
- Autenticação: email e palavra-passe.
- Convite aceite, email confirmado e primeiro início de sessão confirmado.

A conta `admin` tem acesso ao painel e à portaria. Não é necessário criar uma segunda conta de portaria para a operação actual.

## Modelo de permissões

- `admin`: gestão do painel, leitura dos registos e acesso à portaria.
- `gate`: acesso operacional limitado à portaria, caso venha a ser necessária uma conta separada no futuro.
- Os papéis são lidos de `app_metadata`, não de `user_metadata`.

## Segurança

As migrações de segurança foram aplicadas ao Supabase. As tabelas protegidas exigem sessão autenticada com o papel correcto.

Não:
- actualizar directamente `auth.users` com SQL;
- conceder novamente acesso público a `anon` nas tabelas;
- colocar uma chave `service_role` no browser ou no repositório;
- publicar funções administrativas temporárias sem validação e limpeza.

A recuperação excepcional do perfil proprietário foi concluída e a Edge Function temporária `restore-owner-admin-once` foi removida após a validação. O painel mantém a autenticação normal por email e palavra-passe e só concede acesso quando `app_metadata.role` é `admin`. Não existe dependência de funções temporárias para iniciar sessão.

## Migrações aplicadas

- `20261120_secure_event_access`
- `20261120_revoke_rls_auto_enable_api_access`

Última contagem confirmada: 36 convidados e 0 check-ins. Preservar estes dados.

## Operação

1. Usar o mesmo email e palavra-passe no painel e na portaria.
2. Confirmar que a sessão apresenta o papel `admin`.
3. Não efectuar check-ins de teste com convites reais.
4. Se for necessária uma conta separada de portaria, criá-la apenas com aprovação e atribuir o papel `gate` através da Admin API oficial do Supabase.
