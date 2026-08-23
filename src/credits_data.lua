--[[
    credits_data.lua
    -----------------
    Dados exibidos na tela de créditos: integrantes da equipe e
    tecnologias usadas. Pra trocar foto/ícone, basta editar os campos
    `avatar` / `icon` abaixo com o caminho do arquivo dentro de assets/.

    Se um caminho estiver errado ou o arquivo não existir, o jogo não
    trava: CreditsData.loadImages() simplesmente deixa a imagem como
    nil e a tela de créditos desenha um círculo cinza no lugar.
]]

local CreditsData = {}

CreditsData.people = {
    {
        name   = "Dayvson Lacerda Pessoa Filho",
        github = "https://github.com/Devs097518",
        avatar = "assets/dayvson.png",
    },
    {
        name   = "Yuri William Ferreira Calixto",
        github = "https://github.com/YuriCeleste",
        avatar = "assets/yuri.png",
    },
}

CreditsData.tech = {
    { name = "Lua",    icon = "assets/lua-icon.png" },
    { name = "Love2d", icon = "assets/love2d-icon.png" },
}

-- Tenta carregar uma imagem; se o arquivo não existir ainda, retorna nil
-- em vez de travar o jogo (assim dá pra rodar antes de colocar os assets).
local function tryLoadImage(path)
    if not path then return nil end
    local ok, img = pcall(love.graphics.newImage, path)
    if ok then return img end
    return nil
end

-- Chamada uma vez em love.load(). Preenche `avatarImage` / `iconImage`
-- em cada entrada com a imagem já carregada (ou nil).
function CreditsData.loadImages()
    for _, person in ipairs(CreditsData.people) do
        person.avatarImage = tryLoadImage(person.avatar)
    end
    for _, tech in ipairs(CreditsData.tech) do
        tech.iconImage = tryLoadImage(tech.icon)
    end
end

return CreditsData