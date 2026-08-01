# REATOUCH

Painel de Touch Bar para um MacBook Pro com Touch Bar e REAPER, pensado para alternar rapidamente entre os projetos de uma apresentação. É um app nativo para macOS Ventura, escrito em Swift/AppKit; não usa Electron, Node ou Python.

## O que faz

- Fica somente na barra de menus (não abre janela ou ícone no Dock).
- Mostra REAPER, Kontakt, Keyscape, Chrome e AnyDesk na Touch Bar.
- Abre um app fechado ou o traz para frente quando ele já está aberto.
- Na página REAPER, lista os projetos atualmente abertos e solicita a troca pelo toque.
- Atualiza a lista em tempo real enquanto o bridge do REAPER está ativo: abertura, fechamento e renomeação de projetos são detectados.

## Requisitos

- macOS Ventura ou mais recente.
- Xcode 15 ou mais recente (Swift 5).
- Um MacBook Pro com Touch Bar. Macs sem Touch Bar continuam exibindo o item de menu, mas não têm a superfície de hardware para o painel.
- REAPER instalado e a ação `ReaTouch_ProjectBridge.lua` em execução durante a apresentação.

## Compilar e instalar

1. Abra `ReaTouch.xcodeproj` no Xcode.
2. Em **Signing & Capabilities**, escolha sua equipe de desenvolvimento e, se necessário, use um identificador de pacote próprio.
3. Escolha o esquema **ReaTouch** e **My Mac** como destino; use Product > Build.
4. Em Products, revele `ReaTouch.app` no Finder e mova-o para `/Applications`.
5. Abra o app. Ele aparecerá como o ícone de sliders na barra de menus.

Para desenvolvimento, executar pelo Xcode já inicia o app como agente de menu.

## Configurar a ligação com o REAPER

O REAPER possui API ReaScript para enumerar projetos e selecionar uma instância de projeto (`EnumProjects` e `SelectProjectInstance`), mas não fornece uma API pública de eventos que um aplicativo externo possa assinar. Por isso o projeto inclui um bridge Lua com `reaper.defer`, que é a alternativa oficial e suportada pelo REAPER para manter uma ação rodando.

1. No REAPER, abra Actions > Show action list.
2. Clique em **ReaScript: Load...** e selecione `Resources/ReaTouch_ProjectBridge.lua` neste projeto.
3. Filtre por `ReaTouch_ProjectBridge` e execute-o uma vez antes da apresentação. Deixe a ação em execução; ela não mostra janela nem altera projetos por conta própria.
4. Abra o ReaTouch, toque em **REAPER** e os projetos abertos aparecerão. Toque em um nome para alternar imediatamente.

O script publica apenas o caminho e o nome dos projetos em `~/Library/Application Support/ReaTouch/open_projects.tsv`. Para uma seleção, o app grava um comando local de uso único no mesmo diretório; o script o remove depois de consumi-lo. Não há rede, telemetria ou automação remota.

### Inicialização de show

Como o REAPER não tem um mecanismo público de “autorun ReaScript” universal, a ação precisa ser iniciada uma vez a cada sessão do REAPER. Se desejar, atribua-a a um atalho ou use uma extensão/fluxo de inicialização já adotado no seu ambiente REAPER para executá-la ao abrir o REAPER.

## Permissões

O app não é sandboxed para conseguir comunicar-se com o bridge local do REAPER. Na primeira ativação de um aplicativo pelo painel, o macOS pode pedir permissão em **Ajustes do Sistema > Privacidade e Segurança > Automação**. Autorize ReaTouch a controlar o app solicitado.

Se o macOS bloquear um app não assinado baixado ou compilado fora do Xcode, abra-o uma vez pelo Finder com Control-clique > **Abrir**, ou assine-o conforme a próxima seção.

## Assinatura e distribuição

Para uso local, a assinatura automática do Xcode é suficiente. Para distribuir fora do seu Mac, use um certificado **Developer ID Application** e um perfil de notarização:

```sh
codesign --force --options runtime --timestamp --sign "Developer ID Application: Seu Nome (TEAMID)" /caminho/ReaTouch.app
xcrun notarytool submit /caminho/ReaTouch.zip --keychain-profile "AC_NOTARY" --wait
xcrun stapler staple /caminho/ReaTouch.app
```

Compacte o `.app` antes do envio para o serviço de notarização. Ajuste os caminhos, a identidade e o perfil `AC_NOTARY` para sua conta Apple Developer.

## Limitação importante da Touch Bar

O macOS não oferece API pública para um aplicativo de barra de menus substituir de forma permanente a Touch Bar de outro aplicativo que está em primeiro plano. `NSTouchBar` pertence à cadeia de resposta do aplicativo ativo. Assim, o ReaTouch instala seu painel quando ele é ativado pelo item **Mostrar Touch Bar** (e na sua inicialização); ao trazer o REAPER ou outro aplicativo ao primeiro plano, o sistema pode voltar a mostrar a Touch Bar desse aplicativo.

Essa é uma limitação de arquitetura e segurança do macOS, não uma API ausente do projeto. O app implementa a melhor alternativa pública possível: painel `NSTouchBar` nativo, residente, sem janelas, acessível pela barra de menus, com a integração de projetos do REAPER funcional. Não utiliza hacks privados ou APIs não documentadas que comprometeriam assinatura, estabilidade ou compatibilidade.

## Estrutura

```
ReaTouch.xcodeproj/      Projeto Xcode
ReaTouch/                AppDelegate, controladores e lançador de apps
Resources/               Bridge Lua do REAPER
Assets/Assets.xcassets/  Catálogo de recursos
Icons/                   Orientação do ícone do pacote
README.md                Esta documentação
```
