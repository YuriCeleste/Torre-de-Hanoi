--[[
    layout.lua
    ----------
    Todas as posições e tamanhos (retângulos de botões, caixas, hastes
    etc.) num só lugar. Tanto os módulos de desenho (src/ui/*) quanto o
    módulo de clique (src/input.lua) usam esta tabela, então mover um
    botão na tela é só mudar o número aqui uma vez.
]]

local Layout = {}

Layout.window = { w = 960, h = 480 }

Layout.sidebar = {
    width    = 300,
    title    = { x = 24, y = 30 },
    radioBox = { x = 20, y = 90, w = 260, h = 100 },
    radioLabel = { x = 34, y = 100 },

    -- cada radio: círculo desenhado em (x, y) com raio 8
    radios = {
        { value = 3, x = 45,  y = 140 },
        { value = 4, x = 115, y = 140 },
        { value = 5, x = 185, y = 140 },
    },

    warnText = { x = 34, y = 165, w = 230 },

    buttons = {
        tutorial  = { x = 20, y = 208, w = 260, h = 38, label = "Tutorial" },
        restart   = { x = 20, y = 250, w = 260, h = 38, label = "Reiniciar" },
        autoSolve = { x = 20, y = 292, w = 260, h = 38, label = "Auto-resolver" },
        credits   = { x = 20, y = 334, w = 260, h = 38, label = "Créditos" },
    },

    info       = { x = 20, y = 384, w = 260 },
    solvedText = { x = 20, y = 408, w = 260 },
}

Layout.board = {
    x = 300, y = 0, w = 660, h = 480,
    baseY      = 420,
    postTopY   = 130,
    diskHeight = 26,
    pegOrder   = { "A", "B", "C" },
    pegX       = { A = 465, B = 630, C = 795 },
}

Layout.tutorial = { x = 280, y = 90, w = 400, h = 300 }

Layout.credits = {
    x = 260, y = 20, w = 440, h = 440,
    -- retângulo da seta de voltar, relativo ao canto da caixa (boxX/boxY)
    backButton = { x = 15, y = 10, w = 40, h = 30 },
}

return Layout