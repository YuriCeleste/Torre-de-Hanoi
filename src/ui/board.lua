--[[
    ui/board.lua
    ------------
    Desenha a área do tabuleiro: fundo, contador de movimentos, base
    de madeira e as três hastes com seus discos.
]]

local Board = {}

local function drawPeg(theme, layout, Game, pegKey)
    local B = layout.board
    local x = B.pegX[pegKey]
    local disks = Game.state.pegs[pegKey]

    -- Poste de madeira
    love.graphics.setColor(unpack(theme.colors.woodPost))
    love.graphics.rectangle("fill", x - 6, B.postTopY, 12, B.baseY - B.postTopY)

    -- Discos (de baixo para cima)
    for i, size in ipairs(disks) do
        local w = 40 + size * 26
        local y = B.baseY - i * B.diskHeight
        love.graphics.setColor(unpack(theme.diskColors[size]))
        love.graphics.rectangle("fill", x - w / 2, y, w, B.diskHeight - 4, 6, 6)
        love.graphics.setColor(0, 0, 0, 0.25)
        love.graphics.rectangle("line", x - w / 2, y, w, B.diskHeight - 4, 6, 6)
    end

    -- Destaque se a haste estiver selecionada
    if Game.state.selectedPeg == pegKey then
        love.graphics.setColor(unpack(theme.colors.sidebar))
        love.graphics.setLineWidth(3)
        love.graphics.rectangle("line", x - 100, B.postTopY - 20, 200, B.baseY - B.postTopY + 40, 8, 8)
        love.graphics.setLineWidth(1)
    end

    -- Rótulo da haste
    love.graphics.setColor(unpack(theme.colors.textDark))
    love.graphics.setFont(theme.fonts.title)
    love.graphics.printf(pegKey, x - 20, B.postTopY - 45, 40, "center")
end

function Board.draw(theme, layout, Game)
    local B = layout.board

    love.graphics.setColor(unpack(theme.colors.boardBg))
    love.graphics.rectangle("fill", B.x, B.y, B.w, B.h)
    love.graphics.setColor(unpack(theme.colors.border))
    love.graphics.setLineWidth(3)
    love.graphics.rectangle("line", B.x + 6, B.y + 6, B.w - 12, B.h - 12, 6, 6)
    love.graphics.setLineWidth(1)

    love.graphics.setColor(unpack(theme.colors.textDark))
    love.graphics.setFont(theme.fonts.label)
    love.graphics.printf("movimentos totais: " .. Game.state.moveCount, B.x, 30, B.w, "center")

    -- Base de madeira
    love.graphics.setColor(unpack(theme.colors.woodBase))
    love.graphics.rectangle("fill", 360, B.baseY, 540, 20)

    for _, key in ipairs(B.pegOrder) do
        drawPeg(theme, layout, Game, key)
    end
end

return Board