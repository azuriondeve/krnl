local jogosSuportados = {
    [18667984660] = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/azuriondeve/krnl/refs/heads/main/games/flexyourfps.lua"))()
        
        -- Sua lógica aqui
    end,

    [1234567890] = function()
        print("Rodando lógica para outro jogo")
        
        -- Outra lógica
    end
}

local placeId = game.PlaceId

if jogosSuportados[placeId] then
    jogosSuportados[placeId]()
else
    warn("Jogo não suportado:", placeId)
end
