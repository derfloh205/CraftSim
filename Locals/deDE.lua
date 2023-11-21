AddonName, CraftSim = ...

CraftSim.LOCAL_DE = {}

function CraftSim.LOCAL_DE:GetData()
    local f = CraftSim.UTIL:GetFormatter()
    return {
        -- REQUIRED:
        [CraftSim.CONST.TEXT.STAT_INSPIRATION] = "Inspiration",
        [CraftSim.CONST.TEXT.STAT_MULTICRAFT] = "Mehrfachherstellung",
        [CraftSim.CONST.TEXT.STAT_RESOURCEFULNESS] = "Einfallsreichtum",
        [CraftSim.CONST.TEXT.STAT_CRAFTINGSPEED] = "Herstellungsgeschwindigkeit",
        [CraftSim.CONST.TEXT.EQUIP_MATCH_STRING] = "Anlegen:",
        [CraftSim.CONST.TEXT.ENCHANTED_MATCH_STRING] = "Verzaubert:",

        -- OPTIONAL:

        -- Recipe Scan
        [CraftSim.CONST.TEXT.RECIPE_SCAN_SORT_BY_MARGIN] = "Nach Profit % sortieren",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_SORT_BY_MARGIN_TOOLTIP] = "Sortiere die Profitliste nach Profit relativ zu den Herstellungskosten.\n(Rezepte müssen erneut gescannt werden)",

        -- Craft Results
        [CraftSim.CONST.TEXT.CRAFT_RESULTS_DISABLE_CHECKBOX] = f.l("Aufzeichnen deaktivieren"),
        [CraftSim.CONST.TEXT.CRAFT_RESULTS_DISABLE_CHECKBOX_TOOLTIP] = "Das Ausschalten der Herstellungsaufzeichnungen könnte die " .. f.g("Spielperformance beim Herstellen verbessern"),

    }
end