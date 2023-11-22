CraftSimAddonName, CraftSim = ...

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

        -- Options
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_SHOW_NEWS_CHECKBOX] = "Zeige das " .. f.bb("News") .. " Fenster",
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_SHOW_NEWS_CHECKBOX_TOOLTIP] = "Zeige das " .. f.bb("News") .. " Fenster für neue " .. f.l("CraftSim") .. " Updates beim Einloggen",

        -- Recipe Scan
        [CraftSim.CONST.TEXT.RECIPE_SCAN_SORT_BY_MARGIN] = "Nach Profit % sortieren",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_SORT_BY_MARGIN_TOOLTIP] = "Sortiere die Profitliste nach Profit relativ zu den Herstellungskosten.\n(Rezepte müssen erneut gescannt werden)",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_USE_INSIGHT_CHECKBOX] = "Benutze " .. f.bb("Einsicht") .. " falls möglich",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_USE_INSIGHT_CHECKBOX_TOOLTIP] = "Benutze " .. f.bb("Glorreiche Einsicht") .. " oder\n" .. f.bb("Geringe glorreiche Einsicht") .. " als optionales Material falls es ein Rezept zulässt.",

        -- Craft Results
        [CraftSim.CONST.TEXT.CRAFT_RESULTS_DISABLE_CHECKBOX] = f.l("Aufzeichnen deaktivieren"),
        [CraftSim.CONST.TEXT.CRAFT_RESULTS_DISABLE_CHECKBOX_TOOLTIP] = "Das Ausschalten der Herstellungsaufzeichnungen könnte die " .. f.g("Spielperformance beim Herstellen verbessern"),

    }
end