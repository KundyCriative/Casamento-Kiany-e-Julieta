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
