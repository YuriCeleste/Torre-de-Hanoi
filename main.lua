--[[
    TORRE DE HANÓI - LÖVE2D
    -----------------------
    Jogo da Torre de Hanói com hastes A, B e C.
    Regras: mover toda a pilha de A até C, movendo um disco por vez
    e nunca colocando um disco maior sobre um menor.

    O núcleo do trabalho (recursividade) está na função `hanoiSolve`,
    que gera a sequência ótima de movimentos usando o algoritmo
    clássico de recursão da Torre de Hanói. Essa lista é usada pelo
    botão "Auto-resolver" para animar a solução na tela.
]]

-- ======================= CORES =======================
local COLOR_SIDEBAR   = {108/255, 92/255, 231/255}
local COLOR_BOARD_BG  = {0.98, 0.96, 0.94}
local COLOR_BORDER    = {0.20, 0.55, 0.90}
local COLOR_WHITE     = {1, 1, 1}
local COLOR_TEXT_DARK = {0.15, 0.15, 0.15}
local COLOR_WOOD_POST = {0.72, 0.53, 0.04}
local COLOR_WOOD_BASE = {0.50, 0.32, 0.16}
local COLOR_WARN      = {0.85, 0.45, 0.05}

-- Cor de cada tamanho de disco (1 = menor ... 5 = maior)
local DISK_COLORS = {
    [1] = {0.90, 0.15, 0.15}, -- vermelho
    [2] = {0.95, 0.85, 0.10}, -- amarelo
    [3] = {0.30, 0.80, 0.30}, -- verde
    [4] = {0.10, 0.35, 0.85}, -- azul
    [5] = {0.55, 0.20, 0.70}, -- roxo
}

-- ======================= DADOS DA TELA DE CRÉDITOS =======================
-- Troque `avatar` pelo caminho da imagem de cada pessoa (ex: "assets/dayvson.png").
-- Se `avatar` for nil, um círculo cinza é desenhado no lugar (placeholder).
local CREDITS_PEOPLE = {
    {
        name   = "Dayvson Lacerda Pessoa Filho",
        github = "https://github.com/Devs097518",
        avatar = "assets/dayvson.png",
    },
    {
        name   = "Yuri William Ferreira Calixto",
        github = "https://github.com/YuriCeleste",
        avatar = "assets/yuri.png",
    },
}

-- Troque `icon` pelo caminho do ícone de cada tecnologia (ex: "assets/lua-icon.png").
local CREDITS_TECH = {
    { name = "Lua",    icon = "assets/lua-icon.png" },
    { name = "Love2d", icon = "assets/love2d-icon.png" },
}

-- ======================= ESTADO =======================
local state = {
    numDisks     = 4,
    pegs         = { A = {}, B = {}, C = {} },
    pegOrder     = { "A", "B", "C" },
    pegX         = { A = 465, B = 630, C = 795 },
    selectedPeg  = nil,
    moveCount    = 0,
    minMoves     = 0,
    solved       = false,
    showTutorial = false,
    showCredits  = false,

    -- auto-resolver (animação da solução recursiva)
    autoSolving  = false,
    autoMoves    = {},
    autoIndex    = 1,
    autoTimer    = 0,
    autoInterval = 0.5,
}

local BASE_Y      = 420
local POST_TOP_Y  = 130
local DISK_HEIGHT = 26

local fontTitle, fontLabel, fontSmall, fontButton

-- ======================= LÓGICA DO JOGO =======================

-- Reinicia o jogo com n discos, todos empilhados na haste A
-- (do maior, em baixo, ao menor, em cima)
local function resetGame(n)
    state.numDisks = n
    state.pegs = { A = {}, B = {}, C = {} }
    for size = n, 1, -1 do
        table.insert(state.pegs.A, size)
    end
    state.selectedPeg  = nil
    state.moveCount    = 0
    state.minMoves     = (2 ^ n) - 1
    state.solved       = false
    state.autoSolving  = false
    state.autoMoves    = {}
    state.autoIndex    = 1
    state.autoTimer    = 0
end

-- Retorna o disco do topo de uma haste (ou nil se vazia)
local function topDisk(pegKey)
    local peg = state.pegs[pegKey]
    return peg[#peg]
end

-- Verifica se é permitido mover o disco do topo de `from` para `to`
local function canMove(from, to)
    if from == to then return false end
    local fromTop = topDisk(from)
    if not fromTop then return false end
    local toTop = topDisk(to)
    if not toTop then return true end
    return fromTop < toTop
end

-- Executa o movimento (assume que já foi validado)
local function doMove(from, to)
    local fromPeg = state.pegs[from]
    local disk = table.remove(fromPeg)
    table.insert(state.pegs[to], disk)
    state.moveCount = state.moveCount + 1
    if #state.pegs.C == state.numDisks then
        state.solved = true
    end
end

--[[
    ALGORITMO RECURSIVO DA TORRE DE HANÓI
    --------------------------------------
    Ideia: para mover n discos de `from` até `to` usando `via` como
    auxiliar:
      1) mover os (n-1) discos de cima de `from` para `via`
      2) mover o maior disco (o que sobrou) de `from` para `to`
      3) mover os (n-1) discos de `via` para `to`

    Caso base: n == 0 -> não há nada a mover, a recursão para.

    A cada chamada, o problema "de n discos" vira dois subproblemas de
    "n-1 discos", até chegar em 0. As jogadas são guardadas, em ordem,
    na tabela `moves`.
]]
local function hanoiSolve(n, from, to, via, moves)
    if n == 0 then return end
    hanoiSolve(n - 1, from, via, to, moves)
    table.insert(moves, { from = from, to = to })
    hanoiSolve(n - 1, via, to, from, moves)
end

-- Prepara e inicia a animação do auto-resolver
local function startAutoSolve()
    resetGame(state.numDisks)
    local moves = {}
    hanoiSolve(state.numDisks, "A", "C", "B", moves)
    state.autoMoves   = moves
    state.autoIndex   = 1
    state.autoTimer   = 0
    state.autoSolving = true
end

-- ======================= LÖVE CALLBACKS =======================

-- Tenta carregar uma imagem; se o arquivo não existir ainda, retorna nil
-- em vez de travar o jogo (assim dá pra rodar antes de colocar os assets).
local function tryLoadImage(path)
    if not path then return nil end
    local ok, img = pcall(love.graphics.newImage, path)
    if ok then return img end
    return nil
end

function love.load()
    love.graphics.setBackgroundColor(1, 1, 1)
    fontTitle  = love.graphics.newFont(24)
    fontLabel  = love.graphics.newFont(16)
    fontSmall  = love.graphics.newFont(13)
    fontButton = love.graphics.newFont(17)

    -- Carrega as imagens de avatar/ícones definidas em CREDITS_PEOPLE e
    -- CREDITS_TECH. Basta colocar o caminho do arquivo nos campos
    -- `avatar` / `icon` lá em cima que elas aparecem aqui automaticamente.
    for _, person in ipairs(CREDITS_PEOPLE) do
        person.avatarImage = tryLoadImage(person.avatar)
    end
    for _, tech in ipairs(CREDITS_TECH) do
        tech.iconImage = tryLoadImage(tech.icon)
    end

    resetGame(state.numDisks)
end

function love.update(dt)
    if state.autoSolving then
        state.autoTimer = state.autoTimer + dt
        if state.autoTimer >= state.autoInterval then
            state.autoTimer = 0
            if state.autoIndex <= #state.autoMoves then
                local mv = state.autoMoves[state.autoIndex]
                doMove(mv.from, mv.to)
                state.autoIndex = state.autoIndex + 1
            else
                state.autoSolving = false
            end
        end
    end
end

-- ------------------- DESENHO -------------------

local function drawRadio(x, y, selected, label)
    love.graphics.setColor(0.3, 0.3, 0.3)
    love.graphics.circle("line", x, y, 8)
    if selected then
        love.graphics.setColor(unpack(COLOR_SIDEBAR))
        love.graphics.circle("fill", x, y, 4.5)
    end
    love.graphics.setColor(unpack(COLOR_TEXT_DARK))
    love.graphics.setFont(fontLabel)
    love.graphics.print(label, x + 14, y - 10)
end

local function drawButton(x, y, w, h, label, enabled)
    if enabled == false then
        love.graphics.setColor(0.85, 0.85, 0.85)
    else
        love.graphics.setColor(unpack(COLOR_WHITE))
    end
    love.graphics.rectangle("fill", x, y, w, h, 10, 10)
    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.rectangle("line", x, y, w, h, 10, 10)
    love.graphics.setFont(fontButton)
    love.graphics.printf(label, x, y + h / 2 - 10, w, "center")
end

local function drawSidebar()
    love.graphics.setColor(unpack(COLOR_SIDEBAR))
    love.graphics.rectangle("fill", 0, 0, 300, 480)

    love.graphics.setColor(unpack(COLOR_WHITE))
    love.graphics.setFont(fontTitle)
    love.graphics.print("Torre de Hanói", 24, 30)

    -- Caixa "Quantidade de arcos"
    love.graphics.setColor(unpack(COLOR_WHITE))
    love.graphics.rectangle("fill", 20, 90, 260, 100, 10, 10)
    love.graphics.setColor(unpack(COLOR_TEXT_DARK))
    love.graphics.setFont(fontLabel)
    love.graphics.print("Quantidade de discos", 34, 100)

    drawRadio(45, 140, state.numDisks == 3, "3")
    drawRadio(115, 140, state.numDisks == 4, "4")
    drawRadio(185, 140, state.numDisks == 5, "5")

    love.graphics.setColor(unpack(COLOR_WARN))
    love.graphics.setFont(fontSmall)
    love.graphics.printf("Ao trocar de opção o jogo reinicia", 34, 165, 230, "left")

    -- Botões
    drawButton(20, 208, 260, 38, "Tutorial")
    drawButton(20, 250, 260, 38, "Reiniciar")
    drawButton(20, 292, 260, 38, "Auto-resolver", not state.autoSolving)
    drawButton(20, 334, 260, 38, "Créditos")

    -- Info de movimentos mínimos
    love.graphics.setColor(unpack(COLOR_WHITE))
    love.graphics.setFont(fontSmall)
    love.graphics.printf(
        "Mínimo possível: " .. state.minMoves .. " movimentos",
        20, 384, 260, "left"
    )

    if state.solved then
        love.graphics.setColor(0.6, 1, 0.6)
        love.graphics.setFont(fontLabel)
        love.graphics.printf("Resolvido! 🎉", 20, 408, 260, "left")
    end
end

local function drawPeg(pegKey)
    local x = state.pegX[pegKey]
    local disks = state.pegs[pegKey]

    -- Poste de madeira
    love.graphics.setColor(unpack(COLOR_WOOD_POST))
    love.graphics.rectangle("fill", x - 6, POST_TOP_Y, 12, BASE_Y - POST_TOP_Y)

    -- Discos (de baixo para cima)
    for i, size in ipairs(disks) do
        local w = 40 + size * 26
        local y = BASE_Y - i * DISK_HEIGHT
        love.graphics.setColor(unpack(DISK_COLORS[size]))
        love.graphics.rectangle("fill", x - w / 2, y, w, DISK_HEIGHT - 4, 6, 6)
        love.graphics.setColor(0, 0, 0, 0.25)
        love.graphics.rectangle("line", x - w / 2, y, w, DISK_HEIGHT - 4, 6, 6)
    end

    -- Destaque se a haste estiver selecionada
    if state.selectedPeg == pegKey then
        love.graphics.setColor(unpack(COLOR_SIDEBAR))
        love.graphics.setLineWidth(3)
        love.graphics.rectangle("line", x - 100, POST_TOP_Y - 20, 200, BASE_Y - POST_TOP_Y + 40, 8, 8)
        love.graphics.setLineWidth(1)
    end

    -- Rótulo da haste
    love.graphics.setColor(unpack(COLOR_TEXT_DARK))
    love.graphics.setFont(fontTitle)
    love.graphics.printf(pegKey, x - 20, POST_TOP_Y - 45, 40, "center")
end

local function drawBoard()
    love.graphics.setColor(unpack(COLOR_BOARD_BG))
    love.graphics.rectangle("fill", 300, 0, 660, 480)
    love.graphics.setColor(unpack(COLOR_BORDER))
    love.graphics.setLineWidth(3)
    love.graphics.rectangle("line", 306, 6, 648, 468, 6, 6)
    love.graphics.setLineWidth(1)

    love.graphics.setColor(unpack(COLOR_TEXT_DARK))
    love.graphics.setFont(fontLabel)
    love.graphics.printf("movimentos totais: " .. state.moveCount, 300, 30, 660, "center")

    -- Base de madeira
    love.graphics.setColor(unpack(COLOR_WOOD_BASE))
    love.graphics.rectangle("fill", 360, BASE_Y, 540, 20)

    for _, key in ipairs(state.pegOrder) do
        drawPeg(key)
    end
end

local function drawTutorial()
    if not state.showTutorial then return end
    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.rectangle("fill", 0, 0, 960, 480)

    local boxX, boxY, boxW, boxH = 280, 90, 400, 300
    love.graphics.setColor(unpack(COLOR_WHITE))
    love.graphics.rectangle("fill", boxX, boxY, boxW, boxH, 14, 14)
    love.graphics.setColor(unpack(COLOR_BORDER))
    love.graphics.setLineWidth(3)
    love.graphics.rectangle("line", boxX, boxY, boxW, boxH, 14, 14)
    love.graphics.setLineWidth(1)

    love.graphics.setColor(unpack(COLOR_TEXT_DARK))
    love.graphics.setFont(fontTitle)
    love.graphics.printf("Tutorial", boxX, boxY + 20, boxW, "center")

    love.graphics.setFont(fontLabel)
    local text = "O objetivo é mover toda a pilha da haste A para a haste C, "
        .. "seguindo duas regras simples: mexer apenas um disco por vez e "
        .. "nunca colocar um disco maior em cima de um menor.\n\n"
        .. "Clique em uma haste para selecionar o disco do topo, depois "
        .. "clique na haste de destino para movê-lo. Use 'Auto-resolver' "
        .. "para ver a solução ótima sendo calculada de forma recursiva."
    love.graphics.printf(text, boxX + 24, boxY + 60, boxW - 48, "left")

    love.graphics.setFont(fontSmall)
    love.graphics.printf("(clique fora da caixa para fechar)", boxX, boxY + boxH - 30, boxW, "center")
end

-- Desenha uma "pílula" (retângulo bem arredondado) com borda, usada no
-- botão de topo e nos blocos cinza do card de créditos.
local function drawPill(x, y, w, h, fillColor, borderColor)
    love.graphics.setColor(unpack(fillColor))
    love.graphics.rectangle("fill", x, y, w, h, h / 2, h / 2)
    if borderColor then
        love.graphics.setColor(unpack(borderColor))
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", x, y, w, h, h / 2, h / 2)
        love.graphics.setLineWidth(1)
    end
end

-- Desenha um avatar circular. Se `image` existir, recorta/escala a
-- imagem dentro do círculo; senão desenha um círculo cinza de placeholder.
local function drawAvatarCircle(image, cx, cy, radius)
    if image then
        local iw, ih = image:getDimensions()
        local scale = (radius * 2) / math.min(iw, ih)
        love.graphics.setColor(1, 1, 1)
        love.graphics.stencil(function()
            love.graphics.circle("fill", cx, cy, radius)
        end, "replace", 1)
        love.graphics.setStencilTest("greater", 0)
        love.graphics.draw(image, cx - (iw * scale) / 2, cy - (ih * scale) / 2, 0, scale, scale)
        love.graphics.setStencilTest()
    else
        love.graphics.setColor(0.85, 0.85, 0.88)
        love.graphics.circle("fill", cx, cy, radius)
        love.graphics.setColor(0.6, 0.6, 0.65)
        love.graphics.setLineWidth(2)
        love.graphics.circle("line", cx, cy, radius)
        love.graphics.setLineWidth(1)
    end
end

local function drawCredits()
    if not state.showCredits then return end

    -- fundo escurecido
    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.rectangle("fill", 0, 0, 960, 480)

    -- card branco (mesmas proporções do protótipo)
    local boxX, boxY, boxW, boxH = 260, 20, 440, 440
    love.graphics.setColor(unpack(COLOR_WHITE))
    love.graphics.rectangle("fill", boxX, boxY, boxW, boxH, 22, 22)
    love.graphics.setColor(0.15, 0.15, 0.15)
    love.graphics.setLineWidth(3)
    love.graphics.rectangle("line", boxX, boxY, boxW, boxH, 22, 22)
    love.graphics.setLineWidth(1)

    -- seta de voltar (topo esquerdo)
    love.graphics.setColor(0.1, 0.1, 0.1)
    love.graphics.setFont(fontTitle)
    love.graphics.print("<-", boxX + 20, boxY + 16)

    -- pílula "Créditos"
    drawPill(boxX + 70, boxY + 16, boxW - 140, 38, {0.85, 0.85, 0.85}, {0.2, 0.55, 0.9})
    love.graphics.setColor(0.1, 0.2, 0.8)
    love.graphics.setFont(fontLabel)
    love.graphics.printf("Créditos", boxX + 70, boxY + 26, boxW - 140, "center")

    local y = boxY + 80

    -- ----- pessoas -----
    for _, person in ipairs(CREDITS_PEOPLE) do
        local avatarCx, avatarCy, avatarR = boxX + 55, y + 35, 32
        drawAvatarCircle(person.avatarImage, avatarCx, avatarCy, avatarR)

        love.graphics.setColor(0.1, 0.2, 0.8)
        love.graphics.setFont(fontLabel)
        love.graphics.printf(person.name, boxX + 100, y, boxW - 130, "left")

        -- pílula com o link do github
        local pillX, pillY, pillW, pillH = boxX + 100, y + 24, boxW - 130, 46
        drawPill(pillX, pillY, pillW, pillH, {0.85, 0.85, 0.85}, nil)
        love.graphics.setColor(0.1, 0.2, 0.8)
        love.graphics.setFont(fontSmall)
        love.graphics.printf(person.github, pillX + 34, pillY + 6, pillW - 44, "left")
        -- "ícone" simples do github (círculo escuro) à esquerda da pílula
        love.graphics.setColor(0.15, 0.15, 0.15)
        love.graphics.circle("fill", pillX + 16, pillY + pillH / 2, 8)

        y = y + 90
        love.graphics.setColor(0.7, 0.7, 0.7)
        love.graphics.line(boxX + 20, y - 12, boxX + boxW - 20, y - 12)
    end

    y = y + 6

    -- ----- tecnologias usadas -----
    local techBoxH = 30 + (#CREDITS_TECH * 42)
    drawPill(boxX + 20, y, boxW - 40, techBoxH, {0.88, 0.88, 0.88}, nil)

    love.graphics.setColor(0.1, 0.2, 0.8)
    love.graphics.setFont(fontLabel)
    love.graphics.print("tecnologias usadas", boxX + 40, y + 10)

    local techY = y + 44
    for _, tech in ipairs(CREDITS_TECH) do
        local iconCx, iconCy = boxX + 55, techY + 12
        if tech.iconImage then
            local iw, ih = tech.iconImage:getDimensions()
            local scale = 26 / math.max(iw, ih)
            love.graphics.setColor(1, 1, 1)
            love.graphics.draw(tech.iconImage, iconCx - (iw * scale) / 2, iconCy - (ih * scale) / 2, 0, scale, scale)
        else
            love.graphics.setColor(0.6, 0.6, 0.9)
            love.graphics.circle("fill", iconCx, iconCy, 13)
        end
        love.graphics.setColor(0.1, 0.2, 0.8)
        love.graphics.setFont(fontLabel)
        love.graphics.print(tech.name, boxX + 76, techY)
        love.graphics.setColor(0.6, 0.6, 0.6)
        love.graphics.line(boxX + 40, techY + 30, boxX + boxW - 40, techY + 30)
        techY = techY + 42
    end
end

function love.draw()
    drawSidebar()
    drawBoard()
    drawTutorial()
    drawCredits()
end

-- ------------------- INTERAÇÃO (MOUSE) -------------------

local function pointInRect(px, py, x, y, w, h)
    return px >= x and px <= x + w and py >= y and py <= y + h
end

function love.mousepressed(x, y, button)
    if button ~= 1 then return end

    -- Se a tela de créditos estiver aberta: só a seta de voltar (ou
    -- clicar fora do card) fecha. Bloqueia o resto do jogo enquanto aberta.
    if state.showCredits then
        local boxX, boxY, boxW = 260, 20, 440
        if pointInRect(x, y, boxX + 15, boxY + 10, 40, 30) then
            state.showCredits = false
            return
        end
        if not pointInRect(x, y, boxX, boxY, boxW, 440) then
            state.showCredits = false
        end
        return
    end

    -- Se o tutorial estiver aberto, qualquer clique fecha
    if state.showTutorial then
        state.showTutorial = false
        return
    end

    -- Radios "quantidade de discos"
    if not state.autoSolving then
        if pointInRect(x, y, 37, 132, 16, 16) then resetGame(3); return end
        if pointInRect(x, y, 107, 132, 16, 16) then resetGame(4); return end
        if pointInRect(x, y, 177, 132, 16, 16) then resetGame(5); return end
    end

    -- Botões
    if pointInRect(x, y, 20, 208, 260, 38) then
        state.showTutorial = true
        return
    end
    if pointInRect(x, y, 20, 250, 260, 38) then
        resetGame(state.numDisks)
        return
    end
    if pointInRect(x, y, 20, 292, 260, 38) and not state.autoSolving then
        startAutoSolve()
        return
    end
    if pointInRect(x, y, 20, 334, 260, 38) then
        state.showCredits = true
        return
    end

    -- Clique nas hastes (bloqueado durante auto-resolver ou jogo resolvido)
    if state.autoSolving or state.solved then return end

    for _, key in ipairs(state.pegOrder) do
        local px = state.pegX[key]
        if pointInRect(x, y, px - 100, POST_TOP_Y - 20, 200, BASE_Y - POST_TOP_Y + 40) then
            if state.selectedPeg == nil then
                if topDisk(key) then
                    state.selectedPeg = key
                end
            elseif state.selectedPeg == key then
                state.selectedPeg = nil
            else
                if canMove(state.selectedPeg, key) then
                    doMove(state.selectedPeg, key)
                end
                state.selectedPeg = nil
            end
            return
        end
    end
end