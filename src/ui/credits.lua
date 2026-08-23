--[[
    ui/credits.lua
    ---------------
    Desenha o card de créditos (equipe + tecnologias). Os dados vêm de
    src/credits_data.lua; aqui só cuidamos do desenho.
]]

local Credits = {}

-- Desenha uma "pílula" (retângulo bem arredondado) com borda opcional,
-- usada no botão de topo e nos blocos cinza do card.
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

function Credits.draw(theme, layout, Game, CreditsData)
    if not Game.state.showCredits then return end

    local W = layout.window
    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.rectangle("fill", 0, 0, W.w, W.h)

    local C = layout.credits
    local boxX, boxY, boxW, boxH = C.x, C.y, C.w, C.h

    love.graphics.setColor(unpack(theme.colors.white))
    love.graphics.rectangle("fill", boxX, boxY, boxW, boxH, 22, 22)
    love.graphics.setColor(0.15, 0.15, 0.15)
    love.graphics.setLineWidth(3)
    love.graphics.rectangle("line", boxX, boxY, boxW, boxH, 22, 22)
    love.graphics.setLineWidth(1)

    -- seta de voltar (topo esquerdo)
    love.graphics.setColor(0.1, 0.1, 0.1)
    love.graphics.setFont(theme.fonts.title)
    love.graphics.print("<-", boxX + 20, boxY + 16)

    -- pílula "Créditos"
    drawPill(boxX + 70, boxY + 16, boxW - 140, 38, {0.85, 0.85, 0.85}, {0.2, 0.55, 0.9})
    love.graphics.setColor(0.1, 0.2, 0.8)
    love.graphics.setFont(theme.fonts.label)
    love.graphics.printf("Créditos", boxX + 70, boxY + 26, boxW - 140, "center")

    local y = boxY + 80

    -- ----- pessoas -----
    for _, person in ipairs(CreditsData.people) do
        local avatarCx, avatarCy, avatarR = boxX + 55, y + 35, 32
        drawAvatarCircle(person.avatarImage, avatarCx, avatarCy, avatarR)

        love.graphics.setColor(0.1, 0.2, 0.8)
        love.graphics.setFont(theme.fonts.label)
        love.graphics.printf(person.name, boxX + 100, y, boxW - 130, "left")

        -- pílula com o link do github
        local pillX, pillY, pillW, pillH = boxX + 100, y + 24, boxW - 130, 46
        drawPill(pillX, pillY, pillW, pillH, {0.85, 0.85, 0.85}, nil)
        love.graphics.setColor(0.1, 0.2, 0.8)
        love.graphics.setFont(theme.fonts.small)
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
    local techBoxH = 30 + (#CreditsData.tech * 42)
    drawPill(boxX + 20, y, boxW - 40, techBoxH, {0.88, 0.88, 0.88}, nil)

    love.graphics.setColor(0.1, 0.2, 0.8)
    love.graphics.setFont(theme.fonts.label)
    love.graphics.print("tecnologias usadas", boxX + 40, y + 10)

    local techY = y + 44
    for _, tech in ipairs(CreditsData.tech) do
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
        love.graphics.setFont(theme.fonts.label)
        love.graphics.print(tech.name, boxX + 76, techY)
        love.graphics.setColor(0.6, 0.6, 0.6)
        love.graphics.line(boxX + 40, techY + 30, boxX + boxW - 40, techY + 30)
        techY = techY + 42
    end
end

return Credits