## Objetivo

* Criar uma cópia estática 1:1 do site `https://wcengenharia.eng.br/`, preservando estrutura, layout, navegação, CSS, JS, imagens e fontes.

## Escopo

* Páginas públicas (ex.: “Nossos Serviços”, “Quem Somos”, NR-13, PMOC).

* Todos os assets: `CSS`, `JS`, imagens, fontes, ícones, vídeos.

* Links internos convertidos para caminhos locais.

* Observação: formulários e integrações externas continuarão apontando para o backend original e podem não funcionar offline sem implementação adicional.

## Abordagem Técnica

* Estratégia principal: “espelhamento” com um mirroring robusto (HTTrack) para capturar HTML, assets e reescrever links para uso local.

* Plano de contingência: uso de captura via navegador headless (Puppeteer) para páginas que dependem fortemente de renderização client-side.

## Etapas

1. Levantamento do mapa do site

   * Tentar `sitemap.xml` e crawling superficial para identificar rotas principais e secundárias.

   * Anotar padrões de URL, subdomínios e recursos externos (CDNs, fontes, mapas, players).

2. Espelhamento com HTTrack

   * Configurar opções de mirror: conversão de links para relativos, limite de profundidade adequado, inclusão de sub-recursos.

   * Baixar para `c:\Users\eduardosouza\Desktop\Site_WC_copia\mirror` mantendo a hierarquia.

3. Tratamento de recursos externos

   * Copiar fontes (`.woff2`, `.ttf`), CSS/JS de CDNs e imagens externas.

   * Reescrever referências (`href`/`src`) para caminhos locais quando possível.

4. Ajustes pós-download

   * Garantir que `index.html` e páginas internas tenham links relativos.

   * Corrigir `base`, `canonical` e referências absolutas que impeçam navegação offline.

   * Verificar carrosséis, menus, ícones, e comportamentos JS.

5. Formulários e integrações

   * Identificar `action` de formulários (contato, newsletter, etc.).

   * Manter comportamento original e documentar que o envio depende do endpoint remoto; opcionalmente, mockar localmente se necessário.

6. Validação local

   * Subir um servidor estático local para testar navegação, responsividade e carregamento de assets.

   * Comparar visualmente com o site original; checar console de erros.

7. Correções finais

   * Resolver 404s, ajustar caminhos quebrados, remover hotlinks bloqueados.

   * Garantir que todos os arquivos essenciais estão versionados na pasta de cópia.

8. Entregáveis

   * Pasta `mirror` pronta para uso/hospedagem.

   * `README` com instruções de execução local e publicação.

   * Opcional: pacote `.zip` da cópia para distribuição.

## Validações

* Testes manuais de navegação e funcionalidade client-side.

* Verificação de assets: fontes, ícones, imagens, CSS e JS carregando sem erros.

* Comparação visual (screenshots) entre original e cópia.

## Riscos e Considerações

* Conteúdos/integrações de terceiros (ex.: mapas, analytics, fontes em CDNs) podem exigir ajustes para funcionar offline.

* Formulários dependem de serviços remotos; para funcionamento completo é necessário backend.

* Direitos autorais: a cópia é para uso interno/homologação salvo autorização do titular do conteúdo.

## Próximos Passos

* Confirmar para iniciar a execução usando o método de espelhamento proposto (HTTrack) e aplicar as validações e correções descritas.

* Caso prefira, indicar se deseja também a opção de captura via Puppeteer para páginas altamente dinâmicas.

