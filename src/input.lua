--[[
    input.lua
    ---------
    Traduz cliques do mouse em ações no jogo (Game) ou na interface
    (abrir/fechar tutorial e créditos). Usa os mesmos retângulos de
    src/layout.lua que os módulos de desenho usam, então um clique
    sempre acerta exatamente o que está desenhado na tela.
]]

local Input = {}

local function pointInRect(px, py, x, y, w, h)
    return px >= x and px <= x + w and py >= y and py <= y + h
end

local function hitButton(x, y, btn)
    return pointInRect(x, y, btn.x, btn.y, btn.w, btn.h)
end

function Input.mousepressed(x, y, button, Game, layout)
    if button ~= 1 then return end
    local state = Game.state

    -- Tela de créditos aberta: só a seta de voltar (ou clicar fora do
    -- card) fecha. Bloqueia o resto do jogo enquanto estiver aberta.
    if state.showCredits then
        local C = layout.credits
        local backBtn = C.backButton
        if pointInRect(x, y, C.x + backBtn.x, C.y + backBtn.y, backBtn.w, backBtn.h) then
            state.showCredits = false
            return
        end
        if not pointInRect(x, y, C.x, C.y, C.w, C.h) then
            state.showCredits = false
        end
        return
    end

    -- Tutorial aberto: qualquer clique fecha
    if state.showTutorial then
        state.showTutorial = false
        return
    end

    -- Radios "quantidade de discos"
    if not state.autoSolving then
        for _, radio in ipairs(layout.sidebar.radios) do
            if pointInRect(x, y, radio.x - 8, radio.y - 8, 16, 16) then
                Game.reset(radio.value)
                return
            end
        end
    end

    -- Botões da sidebar
    local b = layout.sidebar.buttons
    if hitButton(x, y, b.tutorial) then
        state.showTutorial = true
        return
    end
    if hitButton(x, y, b.restart) then
        Game.reset(state.numDisks)
        return
    end
    if hitButton(x, y, b.autoSolve) and not state.autoSolving then
        Game.startAutoSolve()
        return
    end
    if hitButton(x, y, b.credits) then
        state.showCredits = true
        return
    end

    -- Clique nas hastes (bloqueado durante auto-resolver ou jogo resolvido)
    if state.autoSolving or state.solved then return end

    local B = layout.board
    for _, key in ipairs(B.pegOrder) do
        local px = B.pegX[key]
        if pointInRect(x, y, px - 100, B.postTopY - 20, 200, B.baseY - B.postTopY + 40) then
            if state.selectedPeg == nil then
                if Game.topDisk(key) then
                    state.selectedPeg = key
                end
            elseif state.selectedPeg == key then
                state.selectedPeg = nil
            else
                if Game.canMove(state.selectedPeg, key) then
                    Game.doMove(state.selectedPeg, key)
                end
                state.selectedPeg = nil
            end
            return
        end
    end
end

return Input