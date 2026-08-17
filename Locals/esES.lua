---@class CraftSim
local CraftSim = select(2, ...)

CraftSim.LOCAL_ES = {}

---@return table<CraftSim.LOCALIZATION_IDS, string>
function CraftSim.LOCAL_ES:GetData()
    local f = CraftSim.GUTIL:GetFormatter()
    return {
        -- REQUIRED:
        STAT_MULTICRAFT = "Multifabricación",
        STAT_RESOURCEFULNESS = "Inventiva",
        STAT_INGENUITY = "Ingenio",
        STAT_CRAFTINGSPEED = "Velocidad de fabricación",
        EQUIP_MATCH_STRING = "Equipar:",
        ENCHANTED_MATCH_STRING = "Encantado:",

        -- OPTIONAL (Defaulting to EN if not available):
        -- Profit Breakdown Tooltips

        RECIPE_DIFFICULTY_EXPLANATION_TOOLTIP =
        "Dificultad de la receta determina cuanta Habilidad es necesaria para fabricar la receta en cada calidad.\n\nPara recetas con cinco calidades es 20%, 50%, 80% y 100% de la Dificultad de la receta como Habilidad\nPara recetas con tres calidades es 50% y 100%",
        MULTICRAFT_EXPLANATION_TOOLTIP =
        "Multifabricación da una probabilidad de fabricar mas objetos de los que normalmente fabricaría la receta.\n\nLa cantidad adicional es entre 1 y 2.5y\ndonde y = es la cantidad normal que da la fabricación.",
        RESOURCEFULNESS_EXPLANATION_TOOLTIP =
        "Ingenio da una probabilidad POR MATERIAL de ahorrar de media un 30% de su cantidad.\n\nComo la probabilidad puede suceder por cada material individualmente hay muchas combinaciones posibles a considerar\ncomo que suceda en todos los materiales a la vez (la probabilidad de esto es muy muy baja)",
        REAGENTSKILL_EXPLANATION_TOOLTIP =
        "La calidad de los componentes de fabricación puede otorgar hasta un maximo de un 25% de la Dificultad de la receta como Habilidad.\n\nTodos los componentes C1: 0% Bonus\nTodos los componentes C2: 12.5% Bonus\nTodos los componentes C3: 25% Bonus\n\nLa Habilidad es calculada en base a la cantidad, calidad y un peso extra que es unico de cada componente de fabricación de Dragonflight",

        -- Details Frame
        RECIPE_DIFFICULTY_LABEL = "Dificultad de la receta: ",
        MULTICRAFT_LABEL = "Multifabricación: ",
        RESOURCEFULNESS_LABEL = "Inventiva: ",
        PATCH_NOTES_TITLE = "Notas del parche de CraftSim",
    }
end
