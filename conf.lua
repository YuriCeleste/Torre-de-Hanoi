function love.conf(t)
    t.title = "Torre de Hanói"
    t.window.width = 960
    t.window.height = 480

    -- Precisa ser redimensionável para a tela cheia (F11) e o
    -- maximizar da janela funcionarem. O jogo é desenhado numa
    -- resolução virtual fixa (veja src/screen.lua) e escalado
    -- automaticamente para caber em qualquer tamanho de janela.
    t.window.resizable = true
    t.window.minwidth = 480
    t.window.minheight = 240
end