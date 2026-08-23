--[[
    theme.lua
    ---------
    Cores e fontes usadas em todo o jogo. Centraliza a paleta visual
    pra facilitar trocar o estilo sem mexer nos arquivos de desenho.
]]

local Theme = {}

Theme.colors = {
    sidebar   = {108 / 255, 92 / 255, 231 / 255},
    boardBg   = {0.98, 0.96, 0.94},
    border    = {0.20, 0.55, 0.90},
    white     = {1, 1, 1},
    textDark  = {0.15, 0.15, 0.15},
    woodPost  = {0.72, 0.53, 0.04},
    woodBase  = {0.50, 0.32, 0.16},
    warn      = {0.85, 0.45, 0.05},
}

-- Cor de cada tamanho de disco (1 = menor ... 5 = maior)
Theme.diskColors = {
    [1] = {0.90, 0.15, 0.15}, -- vermelho
    [2] = {0.95, 0.85, 0.10}, -- amarelo
    [3] = {0.30, 0.80, 0.30}, -- verde
    [4] = {0.10, 0.35, 0.85}, -- azul
    [5] = {0.55, 0.20, 0.70}, -- roxo
}

-- As fontes só podem ser criadas depois que o LÖVE inicializa, então
-- ficam vazias aqui e são preenchidas em Theme.loadFonts(), chamada
-- dentro de love.load().
Theme.fonts = {
    title  = nil,
    label  = nil,
    small  = nil,
    button = nil,
}

function Theme.loadFonts()
    Theme.fonts.title  = love.graphics.newFont(24)
    Theme.fonts.label  = love.graphics.newFont(16)
    Theme.fonts.small  = love.graphics.newFont(13)
    Theme.fonts.button = love.graphics.newFont(17)
end

return Theme