# Revisão profissional — Kiany & Julieta

## Melhorias implementadas nesta branch
- Check-in só é confirmado após resposta positiva da RPC `process_checkin`.
- Check-in offline deixa de incrementar o contador local; a portaria apresenta aviso explícito e não simula sucesso.
- Identificadores de check-in usam UUID criptográfico; não se usa timestamp como identificador de contingência.
- Conteúdo proveniente do convite e da resposta do servidor é escapado antes de ser inserido em HTML dinâmico.
- Cache do PWA passa a guardar apenas o shell estático da mesma origem; endpoints de API não são colocados no Cache Storage.
- Cache tem versão nova e limpeza de versões antigas.
- Melhorias de layout para ecrãs pequenos e respeito por `prefers-reduced-motion`.
- O painel informa que o PIN frontend não equivale a autenticação.

## Riscos que continuam pendentes (exigem backend)
1. O PIN administrativo continua validado no browser e pode ser contornado por alguém com acesso ao código/devtools.
2. As políticas RLS das tabelas `guests` e as permissões da RPC `process_checkin` não foram auditadas nem alteradas nesta branch.
3. A função RPC deve garantir atomicamente: token válido, contagem positiva, limite de lotação, idempotência de `p_checkin_uuid` e autorização de execução.
4. O modo offline permite consulta à última lista em cache, mas não regista entradas. Uma fila offline confiável precisa de suporte idempotente e validação no servidor.
5. A chave Supabase `anon` no frontend é pública por concepção. Nunca substituir por uma chave `service_role` no cliente.

## Dados e produção
Nenhuma tabela, registo, migração, configuração de produção ou branch principal foi alterada. Não foram apagados dados.
A data predefinida do evento foi preservada e deve ser confirmada antes de reutilizar o painel.

## Validação necessária antes do merge
- Testar scanner real em Android/iOS e permissões de câmara.
- Testar RPC com token válido, token inválido, lotação esgotada, duplicação de UUID e falha de rede.
- Confirmar as políticas RLS e o código SQL de `process_checkin`.
- Validar o PWA num deployment de Preview, incluindo instalação e carregamento offline.


## Auditoria read-only do Supabase (20/11/2026)

Projeto identificado: `Evento Check-in` (`twrpzyopfcftxnthrqzl`). Foram feitas apenas consultas de leitura; nenhum registo foi consultado individualmente, alterado ou apagado.

### Achados críticos — não corrigidos nesta branch

**CRÍTICO — RLS permite acesso público total**
- `public.guests` tem RLS ligado, mas as políticas `Acesso Publico` e `Acesso Total Guests` usam `USING (true)` e `WITH CHECK (true)`, sem restringir a operação por utilizador/role.
- `public.checkin_logs` tem a política `Acesso Total Logs` com `USING (true)` e `WITH CHECK (true)`.
- Os arrays de roles das políticas estão vazios, o que representa o papel implícito PUBLIC.
- A função `process_checkin` está executável por `anon`, `authenticated` e `PUBLIC`.
- Como resultado, a camada de base de dados não está a isolar operações públicas de leitura/escrita. Isto pode permitir consultar dados dos convidados e manipular registos diretamente pela API, dependendo dos grants da tabela.

**CRÍTICO — RPC de check-in não coincide com o schema**
- A versão de `process_checkin` com cinco argumentos consulta `checkin_logs.checkin_uuid` e insere também em `is_offline_sync`.
- A estrutura real de `public.checkin_logs` não contém nenhuma dessas duas colunas.
- O frontend envia `p_checkin_uuid`, o que encaminha a chamada para essa sobrecarga; a execução deverá falhar ao tentar usar as colunas inexistentes.
- Isto explica o fallback local que existia anteriormente: a entrada podia parecer registada no dispositivo sem ter sido gravada na base central.

**ALTO — validação insuficiente no backend**
- As versões de `process_checkin` não validam explicitamente `p_count > 0`. A validação no browser não protege chamadas diretas à RPC.
- As duas sobrecargas coexistem, aumentando a ambiguidade e o risco de divergência de regras.

**ALTO — função administrativa SECURITY DEFINER**
- O advisor de segurança sinaliza `public.rls_auto_enable()` como SECURITY DEFINER executável por anon/authenticated e com search_path definido.
- A definição consultada mostra que é uma função de evento DDL (`RETURNS event_trigger`); não é uma RPC comum invocável pelo browser. Ainda assim, a exposição/grants devem ser revistos e limitados ao necessário.

### Recomendação para uma fase seguinte
Antes de reabrir a confirmação central de entradas:
1. Desenhar e aplicar políticas RLS por operação e papel, com acesso administrativo autenticado e leitura mínima necessária à portaria.
2. Corrigir o schema/log idempotente e consolidar `process_checkin` numa única assinatura.
3. Validar `p_count` como inteiro positivo e garantir atomicidade, limites de lotação e idempotência com restrição UNIQUE.
4. Testar SELECT/INSERT/UPDATE/DELETE com anon e authenticated, além de cenários de check-in concorrente.
5. Fazer backup e preparar migração reversível; só executar depois de autorização explícita para alterar a base de produção.

**Importante:** estes riscos já existiam na base consultada. Esta branch não os introduz. A correção frontend agora bloqueia o falso sucesso local, mas o check-in online continuará a falhar até a RPC/schema serem reconciliados.
