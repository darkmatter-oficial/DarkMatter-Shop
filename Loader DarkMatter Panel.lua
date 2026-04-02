-- ==========================================
-- SCRIPT PRINCIPAL (LOADER)
-- ==========================================
-- Reemplaza los enlaces a continuación por los enlaces "Raw" de tus archivos en GitHub.

local urlPart1 = "https://raw.githubusercontent.com/darkmatter-oficial/DarkMatter-Shop/refs/heads/main/Variables%20y%20Estado.lua"
local urlPart2 = "https://raw.githubusercontent.com/darkmatter-oficial/DarkMatter-Shop/refs/heads/main/Interfaz%20de%20Usuario.lua"
local urlPart3 = "https://raw.githubusercontent.com/darkmatter-oficial/DarkMatter-Shop/refs/heads/main/Configuraci%C3%B3n%20de%20Men%C3%BA.lua"
local urlPart4 = "https://raw.githubusercontent.com/darkmatter-oficial/DarkMatter-Shop/refs/heads/main/Sistema%20Visuales%20y%20De%20Bucle%20Principal.lua"

-- Descarga y une todas las partes en un solo script continuo
local scriptCompleto = game:HttpGet(urlPart1) .. "\n" .. 
                       game:HttpGet(urlPart2) .. "\n" .. 
                       game:HttpGet(urlPart3) .. "\n" .. 
                       game:HttpGet(urlPart4)

-- Ejecuta el código ensamblado
loadstring(scriptCompleto)()
