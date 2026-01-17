## Objetivo

* Eliminar falhas do “Workers Builds” em Cloudflare e publicar o site estático a partir de `mirror/`.

* Garantir localhost funcionando.

* Reenviar as correções ao GitHub.

## Root Cause

* O pipeline está rodando `npx wrangler deploy` sem um entry-point de Worker nem configuração de assets, gerando “Missing entry-point…”.

* Para um site estático, o caminho correto é Cloudflare Pages (Build command vazio, Output `mirror`) ou Wrangler com `[assets]` configurado.

## Plano de Correção

1. Repositório

   * Adicionar/validar `wrangler.toml` na raiz com:

     * `compatibility_date = "2025-12-01"`

     * `[assets] directory = "./mirror"`

     * `send_metrics = false` (telemetria desativada)

   * Garantir que `package-lock.json` não exista (evita instalação npm em projeto estático).

   * Opcional: adicionar `DEPLOY.md` com instruções Cloudflare Pages.

2. Cloudflare Pages (recomendado)

   * Conectar o repo `e5inovacao/wcengenharia_v01` no Pages.

   * Build command: vazio.

   * Output directory: `mirror`.

   * Publicar e validar a URL gerada.

3. Alternativa: Cloudflare Workers (Wrangler)

   * Manter “Workers Builds”, mas alterar o comando para:

     * `npx wrangler deploy --assets=./mirror`

     * Ou confiar no `wrangler.toml` recém adicionado e usar simples `npx wrangler deploy`.

   * Isso cria um Worker Assets no domínio `<worker>.workers.dev` (não Pages).

4. Localhost

   * Subir servidor estático local: `npx serve c:\Users\eduardosouza\Desktop\Site_WC_copia\mirror -l 5500`.

   * Caso porta em uso, tentar `-l 5501`.

5. Telemetria (opcional)

   * Desativar telemetria do Wrangler via `wrangler.toml` (`send_metrics=false`) ou env `WRANGLER_SEND_METRICS=false`.

6. Reenvio ao GitHub

   * Commit: `wrangler.toml` e docs.

   * Push para `main`.

## Validação

* Localhost acessível.

* Build em Cloudflare concluído sem erro e site publicado a partir de `mirror`.

* Sem logos “Trae” (não presentes no código; se for overlay do preview, não aparece em produção).

## Entregáveis

* `wrangler.toml` na raiz.

* `DEPLOY.md` com instruções Pages/Workers.

* Commits no GitHub e confirmação de publicação em Cloudflare Pages.

