Resumo das correções de imagens

1. Auditoria
- Varredura automática de `<img src>` e `srcset` em `mirror/**/*.html`.
- Verificação de existência física dos arquivos de imagem em `/wp-content/uploads/...`.
- Checagem de formatos comuns: `.png`, `.jpg`, `.jpeg`, `.webp`, `.svg`, `.gif`, `.ico`, `.avif`.

2. Correções aplicadas
- Reescrita do CDN TrustIndex: `https://cdn.trustindex.io/assets/platform/Google/logo.svg` → `/assets/platform/Google/logo.svg`.
- Sanitização de `srcset`: remoção de URLs que não possuem arquivo local presente para evitar 404 em resoluções específicas.
- Mantidos apenas tamanhos efetivamente espelhados no disco.

3. Recursos externos não espelhados
- Avatares de avaliações Google (`lh3.googleusercontent.com`) permanecem apontando para a origem, pois variam dinamicamente e exigem integração JS/API do widget.
- Esses recursos não impactam o layout principal (apenas seções dinâmicas do widget de avaliações).

4. Formatos e compatibilidade
- `.webp` suportado por navegadores modernos (Chrome, Edge, Firefox). Não foram detectadas imagens em formatos incomuns.
- Em ambientes Linux (ex.: Cloudflare Pages), atenção à sensibilidade de maiúsculas/minúsculas nos nomes de arquivos.

5. Ferramentas criadas
- `scripts/audit-images.ps1`: gera `audit-images.json` e `audit-images.txt` com a lista de imagens, existência local e formato.
- `scripts/fix-images.ps1`: reescreve o logo do TrustIndex e saneia `srcset` para evitar referências inexistentes.

6. Testes
- Verificação local via servidor estático (`npx serve`), com auditoria pós-correção sem 404s para imagens internas.
- Preview em Chromium sem erros de carregamento dos recursos internos.

7. Próximos passos
- Caso deseje cachear avatares do widget, é possível baixar e referenciar locais, porém o conteúdo pode ficar desatualizado.
- Publicar em Cloudflare Pages mantendo `mirror/` como raiz para preservar caminhos absolutos (`/wp-content/...`).
