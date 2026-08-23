--[[
    ui/sidebar.lua
    --------------
    Desenha a barra lateral: título, seletor de quantidade de discos,
    botões e informações de progresso. Não conhece as regras do jogo,
    só lê Game.state para saber o que mostrar.
]]

local Sidebar = {}

local function drawRadio(theme, x, y, selected, label)
    love.graphics.setColor(0.3, 0.3, 0.3)
    love.graphics.circle("line", x, y, 8)
    if selected then
        love.graphics.setColor(unpack(theme.colors.sidebar))
        love.graphics.circle("fill", x, y, 4.5)
    end
    love.graphics.setColor(unpack(theme.colors.textDark))
    love.graphics.setFont(theme.fonts.label)
    love.graphics.print(label, x + 14, y - 10)
end

local function drawButton(theme, x, y, w, h, label, enabled)
    if enabled == false then
        love.graphics.setColor(0.85, 0.85, 0.85)
    else
        love.graphics.setColor(unpack(theme.colors.white))
    end
    love.graphics.rectangle("fill", x, y, w, h, 10, 10)
    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.rectangle("line", x, y, w, h, 10, 10)
    love.graphics.setFont(theme.fonts.button)
    love.graphics.printf(label, x, y + h / 2 - 10, w, "center")
end

function Sidebar.draw(theme, layout, Game)
    local L = layout.sidebar
    local state = Game.state

    love.graphics.setColor(unpack(theme.colors.sidebar))
    love.graphics.rectangle("fill", 0, 0, L.width, layout.window.h)

    love.graphics.setColor(unpack(theme.colors.white))
    love.graphics.setFont(theme.fonts.title)
    love.graphics.print("Torre de Hanói", L.title.x, L.title.y)

    -- Caixa "Quantidade de discos"
    love.graphics.setColor(unpack(theme.colors.white))
    love.graphics.rectangle("fill", L.radioBox.x, L.radioBox.y, L.radioBox.w, L.radioBox.h, 10, 10)
    love.graphics.setColor(unpack(theme.colors.textDark))
    love.graphics.setFont(theme.fonts.label)
    love.graphics.print("Quantidade de discos", L.radioLabel.x, L.radioLabel.y)

    for _, radio in ipairs(L.radios) do
        drawRadio(theme, radio.x, radio.y, state.numDisks == radio.value, tostring(radio.value))
    end

    love.graphics.setColor(unpack(theme.colors.warn))
    love.graphics.setFont(theme.fonts.small)
    love.graphics.printf("Ao trocar de opção o jogo reinicia", L.warnText.x, L.warnText.y, L.warnText.w, "left")

    -- Botões
    local b = L.buttons
    drawButton(theme, b.tutorial.x, b.tutorial.y, b.tutorial.w, b.tutorial.h, b.tutorial.label)
    drawButton(theme, b.restart.x, b.restart.y, b.restart.w, b.restart.h, b.restart.label)
    drawButton(theme, b.autoSolve.x, b.autoSolve.y, b.autoSolve.w, b.autoSolve.h, b.autoSolve.label, not state.autoSolving)
    drawButton(theme, b.credits.x, b.credits.y, b.credits.w, b.credits.h, b.credits.label)

    -- Info de movimentos mínimos
    love.graphics.setColor(unpack(theme.colors.white))
    love.graphics.setFont(theme.fonts.small)
    love.graphics.printf(
        "Mínimo possível: " .. state.minMoves .. " movimentos",
        L.info.x, L.info.y, L.info.w, "left"
    )

    if state.solved then
        love.graphics.setColor(0.6, 1, 0.6)
        love.graphics.setFont(theme.fonts.label)
        love.graphics.printf("Resolvido! 🎉", L.solvedText.x, L.solvedText.y, L.solvedText.w, "left")
    end
end

return Sidebar