--[[
    ui/tutorial.lua
    ----------------
    Desenha o modal de tutorial (só aparece quando Game.state.showTutorial
    for true). Fechar o modal é tratado em src/input.lua.
]]

local Tutorial = {}

function Tutorial.draw(theme, layout, Game)
    if not Game.state.showTutorial then return end

    local W = layout.window
    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.rectangle("fill", 0, 0, W.w, W.h)

    local T = layout.tutorial
    love.graphics.setColor(unpack(theme.colors.white))
    love.graphics.rectangle("fill", T.x, T.y, T.w, T.h, 14, 14)
    love.graphics.setColor(unpack(theme.colors.border))
    love.graphics.setLineWidth(3)
    love.graphics.rectangle("line", T.x, T.y, T.w, T.h, 14, 14)
    love.graphics.setLineWidth(1)

    love.graphics.setColor(unpack(theme.colors.textDark))
    love.graphics.setFont(theme.fonts.title)
    love.graphics.printf("Tutorial", T.x, T.y + 20, T.w, "center")

    love.graphics.setFont(theme.fonts.label)
    local text = "O objetivo é mover toda a pilha da haste A para a haste C, "
        .. "seguindo duas regras simples: mexer apenas um disco por vez e "
        .. "nunca colocar um disco maior em cima de um menor.\n\n"
        .. "Clique em uma haste para selecionar o disco do topo, depois "
        .. "clique na haste de destino para movê-lo. Use 'Auto-resolver' "
        .. "para ver a solução ótima sendo calculada de forma recursiva."
    love.graphics.printf(text, T.x + 24, T.y + 60, T.w - 48, "left")

    love.graphics.setFont(theme.fonts.small)
    love.graphics.printf("(clique fora da caixa para fechar)", T.x, T.y + T.h - 30, T.w, "center")
end

return Tutorial