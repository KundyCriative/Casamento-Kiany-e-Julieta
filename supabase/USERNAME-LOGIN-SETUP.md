# Nota de configuração — autenticação por email

A opção anterior de login por nomes de utilizador internos foi abandonada. O responsável decidiu utilizar uma única conta, com email e palavra-passe, tanto no painel como na portaria.

## Configuração actual

- Identificador de login: email.
- Papel da conta: `admin`.
- O papel é validado em `app_metadata.role`.
- O painel aceita apenas `admin`.
- A portaria aceita `gate` ou `admin`.

Não utilizar os mapeamentos antigos `admin1`, `admin2` ou `portaria`. Não criar contas adicionais para este evento sem necessidade e autorização.

## Segurança

Os papéis devem ser atribuídos exclusivamente através de mecanismos administrativos oficiais do Supabase. Não executar `UPDATE auth.users` para alterar `raw_app_meta_data`, nem colocar chaves secretas no frontend ou no GitHub.
