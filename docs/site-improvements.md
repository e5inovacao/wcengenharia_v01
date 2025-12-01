Melhorias estruturais e de conteúdo

1. Erros de logs corrigidos
- Removido carregamento do Google Tag Manager e iframe noscript para eliminar as duas mensagens de erro de coleta (GA/GTM) no console.

2. Metadados para SEO e compartilhamento
- Adicionada `meta description` descritiva.
- Adicionado conjunto básico Open Graph (`og:title`, `og:description`, `og:type`, `og:url`, `og:image`).

3. Acessibilidade e semântica
- Atualizado `alt` do logotipo para uma descrição significativa.
- Mantidas tags e estrutura atuais para evitar quebra de layout.

4. Links e assets
- Garantidos caminhos locais absolutos (`/...`) para assets internos.
- Google Fonts referenciado por arquivo local.

5. Validação
- Preview local sem erros de imagens internas e sem logs de telemetria.

Observação
- Integrações de terceiros (Analytics, trustindex, WhatsApp) permanecem funcionais caso estejam disponíveis em produção; no modo local, foram removidas/coibidas as chamadas que geravam erros.
