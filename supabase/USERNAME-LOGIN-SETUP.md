# Acesso por nome de utilizador — configuração suspensa

Este documento regista uma opção técnica preparada para o projecto, mas cuja activação foi suspensa temporariamente.

## Mapeamento preparado

| Nome de utilizador | Email interno | Papel esperado |
|---|---|---|
| `admin1` | `admin1@example.com` | `admin` |
| `admin2` | `admin2@example.com` | `admin` |
| `portaria` | `portaria@example.com` | `gate` |

Os emails são identificadores técnicos internos e não caixas de correio.

## Estado

- As três contas foram criadas no Supabase Auth.
- Os campos `app_metadata.role` permanecem NULL.
- A atribuição de papéis foi suspensa.
- Nenhuma Edge Function administrativa foi publicada.
- Não foram apagadas contas nem alterados dados de convidados.

## Segurança

O Supabase Auth utiliza email ou telefone como identificador de autenticação; o frontend traduz os nomes de utilizador para os emails internos acima.

Os papéis devem ser atribuídos exclusivamente por um mecanismo administrativo oficial do Supabase. Não executar `UPDATE auth.users` para alterar `raw_app_meta_data`, nem colocar chaves secretas no frontend ou no GitHub.

A activação deste modelo exige atribuir os papéis, renovar as sessões e testar o fluxo completo antes de utilizar a aplicação no evento.
