# Torre de Hanói — LÖVE2D

Jogo da Torre de Hanói feito em Lua com o framework [LÖVE2D](https://love2d.org/).

## Como rodar

1. Baixe e instale o LÖVE2D (versão 11.x): https://love2d.org/
2. Duas formas de executar:
   - **Arrastar e soltar**: arraste a pasta `torre-hanoi-love` inteira sobre o
     executável `love.exe` (Windows) ou o app LÖVE (Mac).
   - **Terminal**: dentro da pasta do projeto, rode:
     ```
     love .
     ```
     (no Windows, se `love` não estiver no PATH, use o caminho completo do
     `love.exe`)
3. Para rodar no navegador (love.js), basta compactar o conteúdo da pasta
   em um `.zip` (sem a pasta em si, só os arquivos dentro) e usar o
   compilador love.js: https://schellingb.github.io/love.js/

## Estrutura

- `conf.lua` — configuração da janela (título, tamanho).
- `main.lua` — todo o jogo: estado, desenho, interação do mouse e o
  algoritmo recursivo da Torre de Hanói (`hanoiSolve`).

## Como jogar

- Clique em uma haste para selecionar o disco do topo.
- Clique em outra haste para mover o disco selecionado até ela.
- Clique na mesma haste novamente para cancelar a seleção.
- Use os botões na barra lateral para trocar a quantidade de discos (3/4/5),
  reiniciar, ver o tutorial ou acionar o **Auto-resolver**, que usa o
  algoritmo recursivo para gerar e animar a sequência ótima de movimentos.

## Adicionando as imagens dos créditos

O botão **"Créditos"** na barra lateral abre um card com sua foto, a do
Yuri e os ícones das tecnologias. Pra colocar as imagens:

1. Coloque os arquivos dentro da pasta `images/` (já criada), por exemplo:
   - `images/dayvson.png`
   - `images/yuri.png`
   - `images/lua-icon.png`
   - `images/love2d-icon.png`
2. Abra `main.lua` e procure o bloco `CREDITS_PEOPLE` e `CREDITS_TECH`
   (perto do topo do arquivo, logo após `DISK_COLORS`). Preencha os
   campos `avatar` e `icon` com o caminho de cada arquivo:

   ```lua
   local CREDITS_PEOPLE = {
       {
           name   = "Dayvson Lacerda Pessoa Filho",
           github = "https://github.com/Devs097518",
           avatar = "images/dayvson.png",
       },
       {
           name   = "Yuri William Ferreira Calixto",
           github = "https://github.com/YuriCeleste",
           avatar = "images/yuri.png",
       },
   }

   local CREDITS_TECH = {
       { name = "Lua",    icon = "images/lua-icon.png" },
       { name = "Love2d", icon = "images/love2d-icon.png" },
   }
   ```

Se um caminho estiver errado ou o arquivo não existir, o jogo não trava —
ele simplesmente desenha um círculo cinza no lugar da imagem, então dá
pra testar antes de ter todos os images prontos.

## A recursão

O núcleo do trabalho está na função `hanoiSolve(n, from, to, via, moves)`
em `main.lua`:

```lua
local function hanoiSolve(n, from, to, via, moves)
    if n == 0 then return end
    hanoiSolve(n - 1, from, via, to, moves)
    table.insert(moves, { from = from, to = to })
    hanoiSolve(n - 1, via, to, from, moves)
end
```

Ideia: para mover `n` discos de `from` até `to` usando `via` como haste
auxiliar, primeiro move os `n-1` discos de cima para a haste auxiliar,
depois move o disco restante (o maior) para o destino, e por fim move os
`n-1` discos da auxiliar para o destino. O caso base é `n == 0` (nada a
fazer). O número mínimo de movimentos gerado é sempre `2^n - 1`.