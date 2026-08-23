--[[
    TORRE DE HANÓI - LÖVE2D
    -----------------------
    Ponto de entrada do jogo. Este arquivo só conecta os módulos aos
    callbacks do LÖVE (load/update/draw/mousepressed) — a lógica e o
    desenho ficam cada um no seu próprio arquivo dentro de src/:

      src/theme.lua         cores e fontes
      src/layout.lua         posições/tamanhos (botões, hastes, caixas)
      src/game.lua           estado do jogo, regras e o algoritmo
                              recursivo hanoiSolve (o núcleo do trabalho)
      src/credits_data.lua    dados da tela de créditos + carregamento
                               de imagens
      src/input.lua          o que cada clique do mouse faz
      src/screen.lua          escala a tela virtual (960x480) para caber
                               na janela real, seja qual for o tamanho
                               (inclusive tela cheia)
      src/ui/sidebar.lua      desenho da barra lateral
      src/ui/board.lua        desenho do tabuleiro e das hastes
      src/ui/tutorial.lua     desenho do modal de tutorial
      src/ui/credits.lua      desenho do card de créditos
]]

local Theme       = require("src.theme")
local Layout      = require("src.layout")
local Game        = require("src.game")
local CreditsData = require("src.credits_data")
local Screen      = require("src.screen")

local Sidebar  = require("src.ui.sidebar")
local Board    = require("src.ui.board")
local Tutorial = require("src.ui.tutorial")
local Credits  = require("src.ui.credits")
local Input    = require("src.input")

function love.load()
    love.graphics.setBackgroundColor(1, 1, 1)
    Theme.loadFonts()
    CreditsData.loadImages()
    Game.reset(Game.state.numDisks)
end

function love.update(dt)
    Game.update(dt)
end

function love.draw()
    Screen.applyTransform()

    Sidebar.draw(Theme, Layout, Game)
    Board.draw(Theme, Layout, Game)
    Tutorial.draw(Theme, Layout, Game)
    Credits.draw(Theme, Layout, Game, CreditsData)

    Screen.clearTransform()
end

function love.mousepressed(x, y, button)
    local vx, vy = Screen.toVirtual(x, y)
    Input.mousepressed(vx, vy, button, Game, Layout)
end

-- F11 alterna tela cheia. O jogo continua no tamanho 960x480 "virtual"
-- e o src/screen.lua se encarrega de escalar/centralizar automaticamente.
function love.keypressed(key)
    if key == "f11" then
        love.window.setFullscreen(not love.window.getFullscreen(), "desktop")
    end
end