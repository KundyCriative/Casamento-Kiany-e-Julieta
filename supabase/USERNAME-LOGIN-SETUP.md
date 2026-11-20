# Configuração do acesso por nome de utilizador

O painel e a portaria apresentam apenas os campos **Nome de utilizador** e **Palavra-passe**. Internamente, o frontend traduz o nome de utilizador para um identificador de email aceite pelo Supabase Auth.

## Identificadores internos

| Nome de utilizador | Email interno | `app_metadata.role` |
|---|---|---|
| `admin1` | `admin1@example.com` | `admin` |
| `admin2` | `admin2@example.com` | `admin` |
| `portaria` | `portaria@example.com` | `gate` |

Estes emails são aliases técnicos reservados para exemplos; não são caixas de correio. Não devem ser usados para receber mensagens.

## Configuração necessária no Supabase

1. Em **Authentication → Providers → Email**, desactivar a confirmação de email antes de criar estes utilizadores. Sem isso, aliases sem caixa de correio não conseguem concluir a confirmação.
2. Em **Authentication → Users**, criar os três utilizadores com os emails da tabela e definir uma palavra-passe forte e única para cada um.
3. Definir o papel em **app_metadata** de cada utilizador, nunca em `user_metadata`:
   - `admin1` e `admin2`: `{"role":"admin"}`
   - `portaria`: `{"role":"gate"}`
4. Confirmar que os utilizadores estão activos e testar primeiro o painel com um administrador e depois a portaria com a conta `portaria`.

## Segurança e limitações

- Não colocar palavras-passe, chaves `service_role` ou credenciais administrativas no repositório ou no frontend.
- Os papéis são lidos de `app_metadata`; as políticas RLS continuam a ser a autoridade efectiva no banco de dados.
- Como os aliases não recebem email, a recuperação por email não estará disponível. Guardar as palavras-passe num gestor de palavras-passe e manter um procedimento administrativo seguro para redefini-las.
- Esta alteração não cria utilizadores nem define palavras-passe. A criação das contas deve ser feita no painel seguro do Supabase.
- A confirmação de email desactivada reduz a verificação de posse de endereço; neste modelo, o controlo depende da criação administrativa das contas e de palavras-passe fortes.
