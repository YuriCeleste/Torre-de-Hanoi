--[[
    screen.lua
    ----------
    Todo o jogo é desenhado numa resolução "virtual" fixa de 960x480
    (o tamanho original do design). Este módulo calcula a escala e o
    deslocamento necessários pra essa tela virtual caber, centralizada,
    dentro da janela real — que pode ser maior (tela cheia, janela
    maximizada) ou menor.

    Mantém a proporção (não distorce): sobra uma faixa da cor de fundo
    nas bordas quando a proporção da janela não é exatamente 2:1.

    Uso em main.lua:
        Screen.applyTransform()   -- antes de desenhar
        ... desenhos ...
        Screen.clearTransform()   -- depois de desenhar
        local vx, vy = Screen.toVirtual(mouseX, mouseY)  -- em mousepressed
]]

local Screen = {}

Screen.VIRTUAL_W = 960
Screen.VIRTUAL_H = 480

-- Calcula escala (mantendo proporção) e o deslocamento pra centralizar
-- a tela virtual dentro da janela real atual.
function Screen.getTransform()
    local screenW, screenH = love.graphics.getDimensions()
    local scale = math.min(screenW / Screen.VIRTUAL_W, screenH / Screen.VIRTUAL_H)
    local offsetX = (screenW - Screen.VIRTUAL_W * scale) / 2
    local offsetY = (screenH - Screen.VIRTUAL_H * scale) / 2
    return scale, offsetX, offsetY
end

-- Chamar no início de love.draw(), antes de desenhar qualquer coisa.
function Screen.applyTransform()
    local scale, offsetX, offsetY = Screen.getTransform()
    love.graphics.push()
    love.graphics.translate(offsetX, offsetY)
    love.graphics.scale(scale, scale)
end

-- Chamar no fim de love.draw(), depois de desenhar tudo.
function Screen.clearTransform()
    love.graphics.pop()
end

-- Converte uma coordenada de tela real (ex: posição do mouse) para a
-- coordenada correspondente na tela virtual 960x480. Usar dentro de
-- love.mousepressed antes de repassar x,y para o resto do jogo.
function Screen.toVirtual(screenX, screenY)
    local scale, offsetX, offsetY = Screen.getTransform()
    local vx = (screenX - offsetX) / scale
    local vy = (screenY - offsetY) / scale
    return vx, vy
end

return Screen