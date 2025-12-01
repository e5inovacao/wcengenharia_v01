Projeto: Cópia estática 1:1 de `https://wcengenharia.eng.br/`

Como executar localmente:
- Instale Node.js (se necessário) e rode `npx serve c:\Users\eduardosouza\Desktop\Site_WC_copia\mirror -l 5500`
- Abra `http://localhost:5500/`

Estrutura:
- `mirror/` contém páginas e assets (CSS, JS, imagens, fontes)
- `scripts/` utilitários PowerShell usados no espelhamento

Observações:
- Integrações externas (Google Tag Manager/Analytics, WhatsApp `joinchat`) continuam apontando para serviços remotos
- Formulários não foram detectados nesta página; se houver em outras rotas, dependerão do backend original

Publicação:
- Sirva a pasta `mirror/` na raiz do seu servidor (links foram normalizados para caminhos absolutos `/`)
- Caso hospede em subpasta, configure o servidor para tratar `/` como raiz da `mirror/`

Legal:
- Conteúdo destinado a backup/homologação; respeite direitos do titular do site original
