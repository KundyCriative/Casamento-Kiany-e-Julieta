# Preparação de acessos — Kiany & Julieta

Esta aplicação usa dois perfis simples no Supabase Auth, sem tabelas de utilizadores adicionais.

## Perfis
- `admin`: acesso individual ao painel e gestão de convidados.
- `gate`: conta operacional partilhada pelos dispositivos da portaria; pode consultar convidados e executar apenas a RPC de check-in.

## Criar contas
1. No Supabase Dashboard, abrir Authentication → Users.
2. Criar uma conta por administrador com e-mail e palavra-passe fortes.
3. Criar uma única conta operacional para a portaria (não reutilizar a conta pessoal de um administrador).
4. Em cada utilizador, definir `app_metadata.role` como `admin` ou `gate`, respectivamente. Não usar `user_metadata` para este papel.
5. Não ativar registo público de utilizadores.

## Migração
1. Fazer backup da base de dados.
2. Rever `supabase/migrations/20261120_secure_event_access.sql`.
3. Executar a migração uma única vez no SQL Editor do projecto.
4. Confirmar que as políticas permissivas anteriores foram removidas, que anon não tem acesso às tabelas e que as funções RPC só são executáveis por authenticated.
5. Confirmar um check-in real com um convite de teste controlado e validar o histórico.

## Atenção
A migração não elimina convidados nem logs. Adiciona duas colunas ao histórico e substitui políticas/função. Não executar em produção sem backup e confirmação de que os utilizadores admin/gate já foram criados.

### Atribuir o papel seguro (SQL Editor)

Depois de criar cada utilizador em Authentication → Users, executar uma instrução por conta, substituindo o e-mail:

```sql
update auth.users
set raw_app_meta_data = coalesce(raw_app_meta_data, '{}'::jsonb)
  || jsonb_build_object('role', 'admin')
where email = 'administrador@exemplo.com';
```

Para a conta partilhada da portaria, usar `'gate'` no valor de `role`. Confirmar que cada UPDATE afectou exactamente uma conta. O papel fica em `app_metadata` (não em `user_metadata`), para que o próprio utilizador não o possa alterar pelo cliente. Depois de atribuir o papel, terminar e iniciar sessão novamente para renovar o JWT.

