-- ==========================================
-- SCRIPT PRINCIPAL (LOADER)
-- ==========================================
-- Reemplaza los enlaces a continuación por los enlaces "Raw" de tus archivos en GitHub.

local urlPart1 = "URL_AQUI_PARTE_1_RAW"
local urlPart2 = "URL_AQUI_PARTE_2_RAW"
local urlPart3 = "URL_AQUI_PARTE_3_RAW"
local urlPart4 = "URL_AQUI_PARTE_4_RAW"

-- Descarga y une todas las partes en un solo script continuo
local scriptCompleto = game:HttpGet(urlPart1) .. "\n" .. 
                       game:HttpGet(urlPart2) .. "\n" .. 
                       game:HttpGet(urlPart3) .. "\n" .. 
                       game:HttpGet(urlPart4)

-- Ejecuta el código ensamblado
loadstring(scriptCompleto)()
