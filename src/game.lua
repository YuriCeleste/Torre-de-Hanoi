--[[
    game.lua
    --------
    Toda a lógica da Torre de Hanói, sem nenhuma chamada de desenho:
    estado das hastes, regras de movimento e o algoritmo recursivo que
    resolve o quebra-cabeça (`Game.hanoiSolve`). Os módulos de UI (em
    src/ui/) só leem `Game.state` para desenhar; quem muda o estado é
    sempre este arquivo.
]]

local Game = {}

Game.state = {
    numDisks     = 4,
    pegs         = { A = {}, B = {}, C = {} },
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

-- Reinicia o jogo com n discos, todos empilhados na haste A
-- (do maior, em baixo, ao menor, em cima)
function Game.reset(n)
    local state = Game.state
    state.numDisks = n
    state.pegs = { A = {}, B = {}, C = {} }
    for size = n, 1, -1 do
        table.insert(state.pegs.A, size)
    end
    state.selectedPeg = nil
    state.moveCount   = 0
    state.minMoves    = (2 ^ n) - 1
    state.solved      = false
    state.autoSolving = false
    state.autoMoves   = {}
    state.autoIndex   = 1
    state.autoTimer   = 0
end

-- Retorna o disco do topo de uma haste (ou nil se vazia)
function Game.topDisk(pegKey)
    local peg = Game.state.pegs[pegKey]
    return peg[#peg]
end

-- Verifica se é permitido mover o disco do topo de `from` para `to`
function Game.canMove(from, to)
    if from == to then return false end
    local fromTop = Game.topDisk(from)
    if not fromTop then return false end
    local toTop = Game.topDisk(to)
    if not toTop then return true end
    return fromTop < toTop
end

-- Executa o movimento (assume que já foi validado com Game.canMove)
function Game.doMove(from, to)
    local state = Game.state
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
function Game.hanoiSolve(n, from, to, via, moves)
    if n == 0 then return end
    Game.hanoiSolve(n - 1, from, via, to, moves)
    table.insert(moves, { from = from, to = to })
    Game.hanoiSolve(n - 1, via, to, from, moves)
end

-- Prepara e inicia a animação do auto-resolver
function Game.startAutoSolve()
    Game.reset(Game.state.numDisks)
    local moves = {}
    Game.hanoiSolve(Game.state.numDisks, "A", "C", "B", moves)
    local state = Game.state
    state.autoMoves   = moves
    state.autoIndex   = 1
    state.autoTimer   = 0
    state.autoSolving = true
end

-- Chamada a cada frame (love.update) para animar o auto-resolver
function Game.update(dt)
    local state = Game.state
    if not state.autoSolving then return end

    state.autoTimer = state.autoTimer + dt
    if state.autoTimer >= state.autoInterval then
        state.autoTimer = 0
        if state.autoIndex <= #state.autoMoves then
            local mv = state.autoMoves[state.autoIndex]
            Game.doMove(mv.from, mv.to)
            state.autoIndex = state.autoIndex + 1
        else
            state.autoSolving = false
        end
    end
end

return Game