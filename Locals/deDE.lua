---@class CraftSim
local CraftSim = select(2, ...)

CraftSim.LOCAL_DE = {}

function CraftSim.LOCAL_DE:GetData()
    local f = CraftSim.GUTIL:GetFormatter()
    local cm = function(i, s) return CraftSim.MEDIA:GetAsTextIcon(i, s) end
    return {
        -- ERFORDERLICH:
        [CraftSim.CONST.TEXT.STAT_MULTICRAFT] = "Mehrfachherstellung",
        [CraftSim.CONST.TEXT.STAT_RESOURCEFULNESS] = "Einfallsreichtum",
        [CraftSim.CONST.TEXT.STAT_INGENUITY] = "Genialität",
        [CraftSim.CONST.TEXT.STAT_CRAFTINGSPEED] = "Herstellungsgeschwindigkeit",
        [CraftSim.CONST.TEXT.EQUIP_MATCH_STRING] = "Anlegen:",
        [CraftSim.CONST.TEXT.ENCHANTED_MATCH_STRING] = "Verzaubert:",

        -- OPTIONAL (Defaulting to EN if not available):

        -- gemeinsame Berufs-CDs
        [CraftSim.CONST.TEXT.DF_ALCHEMY_TRANSMUTATIONS] = "DF - Transmutationen",

        -- Erweiterungen

        [CraftSim.CONST.TEXT.EXPANSION_VANILLA] = "Classic",
        [CraftSim.CONST.TEXT.EXPANSION_THE_BURNING_CRUSADE] = "The Burning Crusade",
        [CraftSim.CONST.TEXT.EXPANSION_WRATH_OF_THE_LICH_KING] = "Wrath of the Lich King",
        [CraftSim.CONST.TEXT.EXPANSION_CATACLYSM] = "Cataclysm",
        [CraftSim.CONST.TEXT.EXPANSION_MISTS_OF_PANDARIA] = "Mists of Pandaria",
        [CraftSim.CONST.TEXT.EXPANSION_WARLORDS_OF_DRAENOR] = "Warlords of Draenor",
        [CraftSim.CONST.TEXT.EXPANSION_LEGION] = "Legion",
        [CraftSim.CONST.TEXT.EXPANSION_BATTLE_FOR_AZEROTH] = "Battle of Azeroth",
        [CraftSim.CONST.TEXT.EXPANSION_SHADOWLANDS] = "Shadowlands",
        [CraftSim.CONST.TEXT.EXPANSION_DRAGONFLIGHT] = "Dragonflight",
        [CraftSim.CONST.TEXT.EXPANSION_THE_WAR_WITHIN] = "The War Within",

        -- Berufe

        [CraftSim.CONST.TEXT.PROFESSIONS_BLACKSMITHING] = "Schmiedekunst",
        [CraftSim.CONST.TEXT.PROFESSIONS_LEATHERWORKING] = "Lederverarbeitung",
        [CraftSim.CONST.TEXT.PROFESSIONS_ALCHEMY] = "Alchemie",
        [CraftSim.CONST.TEXT.PROFESSIONS_HERBALISM] = "Kräuterkunde",
        [CraftSim.CONST.TEXT.PROFESSIONS_COOKING] = "Kochkunst",
        [CraftSim.CONST.TEXT.PROFESSIONS_MINING] = "Bergbau",
        [CraftSim.CONST.TEXT.PROFESSIONS_TAILORING] = "Schneiderei",
        [CraftSim.CONST.TEXT.PROFESSIONS_ENGINEERING] = "Ingenieurskunst",
        [CraftSim.CONST.TEXT.PROFESSIONS_ENCHANTING] = "Verzauberkunst",
        [CraftSim.CONST.TEXT.PROFESSIONS_FISHING] = "Angeln",
        [CraftSim.CONST.TEXT.PROFESSIONS_SKINNING] = "Kürschnerei",
        [CraftSim.CONST.TEXT.PROFESSIONS_JEWELCRAFTING] = "Juwelierskunst",
        [CraftSim.CONST.TEXT.PROFESSIONS_INSCRIPTION] = "Inschriftenkunde",

        -- Andere Statnamen

        [CraftSim.CONST.TEXT.STAT_SKILL] = "Fertigkeit",
        [CraftSim.CONST.TEXT.STAT_MULTICRAFT_BONUS] = "Mehrfachherstellung Extra-Gegenstände",
        [CraftSim.CONST.TEXT.STAT_RESOURCEFULNESS_BONUS] = "Einfallsreichtum Extra-Gegenstände",
        [CraftSim.CONST.TEXT.STAT_CRAFTINGSPEED_BONUS] = "Herstellungsgeschwindigkeit",
        [CraftSim.CONST.TEXT.STAT_INGENUITY_BONUS] = "Genialität spart Konzentration",
        [CraftSim.CONST.TEXT.STAT_INGENUITY_LESS_CONCENTRATION] = "Weniger Konzentrationsverbrauch",
        [CraftSim.CONST.TEXT.STAT_PHIAL_EXPERIMENTATION] = "Durchbruch bei Phiolen",
        [CraftSim.CONST.TEXT.STAT_POTION_EXPERIMENTATION] = "Durchbruch bei Tränken",

        -- Gewinnaufschlüsselung Tooltips
        [CraftSim.CONST.TEXT.RESOURCEFULNESS_EXPLANATION_TOOLTIP] =
        "Einfallsreichtum proct für jedes Reagenz einzeln und spart dann etwa 30 % der Menge.\n\nDer durchschnittliche Wert, den es spart, ist der durchschnittliche gesparte Wert aller Kombinationen und deren Chancen.\n(Dass alle Reagenzien gleichzeitig proccen, ist sehr unwahrscheinlich, spart aber viel.)\n\nDie durchschnittlichen Gesamtkosten der gesparten Reagenzien sind die Summe der gesparten Reagenzkosten aller Kombinationen, gewichtet nach deren Wahrscheinlichkeit.",
        [CraftSim.CONST.TEXT.RECIPE_DIFFICULTY_EXPLANATION_TOOLTIP] =
        "Die Rezeptschwierigkeit bestimmt, wo die Schwellenwerte der verschiedenen Qualitäten liegen.\n\nBei Rezepten mit fünf Qualitätsstufen liegen diese bei 20 %, 50 %, 80 % und 100 % der Rezeptschwierigkeit als Fertigkeit.\nBei Rezepten mit drei Qualitätsstufen liegen sie bei 50 % und 100 %.",
        [CraftSim.CONST.TEXT.MULTICRAFT_EXPLANATION_TOOLTIP] =
        "Mehrfachherstellung gibt dir eine Chance, mehr Gegenstände herzustellen, als du normalerweise mit einem Rezept produzieren würdest.\n\nDie zusätzliche Menge liegt normalerweise zwischen 1 und 2,5y,\nwobei y = die übliche Menge ist, die eine Herstellung ergibt.",
        [CraftSim.CONST.TEXT.REAGENTSKILL_EXPLANATION_TOOLTIP] =
        "Die Qualität deiner Reagenzien kann dir bis zu 40 % der Grundrezeptschwierigkeit als Bonusfertigkeit geben.\n\nAlle Q1-Reagenzien: 0% Bonus\nAlle Q2-Reagenzien: 20% Bonus\nAlle Q3-Reagenzien: 40% Bonus\n\nDie Fertigkeit wird durch die Menge der Reagenzien jeder Qualität berechnet, gewichtet nach ihrer Qualität\nund einem spezifischen Gewichtswert, der für jedes handwerkliche Reagenz mit Qualität einzigartig ist.\n\nDies ist jedoch bei Neuanfertigungen anders. Dort hängt die maximale Qualitätssteigerung durch die Reagenzien davon ab,\nmit welcher Reagenzienqualität der Gegenstand ursprünglich hergestellt wurde.\nDie genauen Mechanismen sind nicht bekannt.\nCraftSim vergleicht jedoch intern die erreichte Fertigkeit mit allen Q3-Reagenzien\nund berechnet den maximalen Fertigkeitsanstieg basierend darauf.",
        [CraftSim.CONST.TEXT.REAGENTFACTOR_EXPLANATION_TOOLTIP] =
        "Der maximale Beitrag der Reagenzien zu einem Rezept beträgt meistens 40 % der Grundrezept-Schwierigkeit.\n\nIm Falle einer Neuanfertigung kann dieser Wert jedoch je nach vorherigen Anfertigungen\nund der Qualität der verwendeten Reagenzien variieren.",

        -- Simulationsmodus
        [CraftSim.CONST.TEXT.SIMULATION_MODE_NONE] = "Keine",
        [CraftSim.CONST.TEXT.SIMULATION_MODE_LABEL] = "Simulationsmodus",
        [CraftSim.CONST.TEXT.SIMULATION_MODE_TITLE] = "CraftSim-Simulationsmodus",
        [CraftSim.CONST.TEXT.SIMULATION_MODE_TOOLTIP] =
        "Der CraftSim-Simulationsmodus ermöglicht es, ohne Einschränkungen mit einem Rezept herumzuspielen.",
        [CraftSim.CONST.TEXT.SIMULATION_MODE_OPTIONAL] = "Optional #",
        [CraftSim.CONST.TEXT.SIMULATION_MODE_FINISHING] = "Abschluss #",
        [CraftSim.CONST.TEXT.SIMULATION_MODE_QUALITY_BUTTON_TOOLTIP] = "Max Menge an Reagenzien der Qualität ",
        [CraftSim.CONST.TEXT.SIMULATION_MODE_CLEAR_BUTTON] = "Löschen",
        [CraftSim.CONST.TEXT.SIMULATION_MODE_CONCENTRATION] = " Konzentration",
        [CraftSim.CONST.TEXT.SIMULATION_MODE_CONCENTRATION_COST] = "Kosten der Konzentration: ",

        -- Detailfenster
        [CraftSim.CONST.TEXT.RECIPE_DIFFICULTY_LABEL] = "Rezeptschwierigkeit: ",
        [CraftSim.CONST.TEXT.MULTICRAFT_LABEL] = "Mehrfachherstellung: ",
        [CraftSim.CONST.TEXT.RESOURCEFULNESS_LABEL] = "Einfallsreichtum: ",
        [CraftSim.CONST.TEXT.RESOURCEFULNESS_BONUS_LABEL] = "Einfallsreichtum-Gegenstandsbonus: ",
        [CraftSim.CONST.TEXT.CONCENTRATION_LABEL] = "Konzentration: ",
        [CraftSim.CONST.TEXT.REAGENT_QUALITY_BONUS_LABEL] = "Qualitätsbonus für Reagenzien: ",
        [CraftSim.CONST.TEXT.REAGENT_QUALITY_MAXIMUM_LABEL] = "Reagenzienqualität Maximum %:: ",

        [CraftSim.CONST.TEXT.EXPECTED_QUALITY_LABEL] = "Erwartete Qualität: ",
        [CraftSim.CONST.TEXT.NEXT_QUALITY_LABEL] = "Nächste Qualität: ",
        [CraftSim.CONST.TEXT.MISSING_SKILL_LABEL] = "Fehlende Fertigkeit: ",
        [CraftSim.CONST.TEXT.SKILL_LABEL] = "Fertigkeit: ",
        [CraftSim.CONST.TEXT.MULTICRAFT_BONUS_LABEL] = "Gegenstandsbonus für Mehrfachherstellung: ",

        -- Statistiken
        [CraftSim.CONST.TEXT.STATISTICS_CDF_EXPLANATION] =
        "Dies wird durch die 'Abramowitz und Stegun' Näherung (1985) der CDF (Kumulative Verteilungsfunktion) berechnet.\n\nDu wirst feststellen, dass es bei einer Herstellung immer um die 50 % liegt.\nDas liegt daran, dass 0 meistens nahe am durchschnittlichen Gewinn liegt.\nUnd die Wahrscheinlichkeit, den Mittelwert der CDF zu erreichen, beträgt immer 50 %.\n\nAllerdings kann die Änderungsrate zwischen Rezepten sehr unterschiedlich sein.\nWenn es wahrscheinlicher ist, einen positiven Gewinn als einen negativen zu erzielen, wird sie stetig ansteigen.\nDies gilt natürlich auch für die entgegengesetzte Richtung.",
        [CraftSim.CONST.TEXT.EXPLANATIONS_PROFIT_CALCULATION_EXPLANATION] =
            f.r("Warnung: ") .. " Mathematik voraus!\n\n" ..
            "Wenn du etwas herstellst, hast du aufgrund deiner Herstellungsstatistiken unterschiedliche Chancen für unterschiedliche Ergebnisse.\n" ..
            "Und in der Statistik wird dies als " .. f.l("Wahrscheinlichkeitsverteilung.\n") ..
            "Allerdings wirst du feststellen, dass die unterschiedlichen Chancen deiner Procs sich nicht zu eins addieren\n" ..
            "(Was für eine solche Verteilung erforderlich ist, da es bedeutet, dass du eine 100%ige Chance hast, dass etwas passieren kann)\n\n" ..
            "Dies liegt daran, dass Procs wie " ..
            f.bb("Einfallsreichtum ") ..
            "und" ..
            f.bb(" Mehrfachherstellung") .. " gleichzeitig passieren können " .. f.g("gleichzeitig auftreten.\n") ..
            "Also müssen wir zuerst unsere Proc-Chancen in eine " ..
            f.l("Wahrscheinlichkeitsverteilung ") .. " mit Chancen\n" ..
            "umwandeln, die sich auf 100 % summieren (Was bedeuten würde, dass jeder Fall abgedeckt ist)\n" ..
            "Und dafür müssten wir " .. f.l("jeden") .. " möglichen Ausgang einer Herstellung berechnen\n\n" ..
            "Zum Beispiel: \n" ..
            f.p .. "Was, wenn " .. f.bb("nichts") .. " proct?\n" ..
            f.p ..
            "Was, wenn entweder " ..
            f.bb("Einfallsreichtum") .. " oder " .. f.bb("Mehrfachherstellung") .. " proct?\n" ..
            f.p ..
            "Was, wenn sowohl " ..
            f.bb("Einfallsreichtum") .. " als auch " .. f.bb("Mehrfachherstellung") .. " proct?\n" ..
            f.p .. "Und so weiter..\n\n" ..
            "Bei einem Rezept, das alle Procs berücksichtigt, wären das 2 hoch 2 Ausgangsmöglichkeiten, also ordentliche 4.\n" ..
            "Um die Chance zu berechnen, dass nur " ..
            f.bb("Mehrfachherstellung") .. " auftritt, müssen wir alle anderen Möglichkeiten berücksichtigen!\n" ..
            "Die Chance, dass nur " ..
            f.l("nur") ..
            f.bb(" Mehrfachherstellung ") ..
            " auftritt, ist tatsächlich die Chance, dass " .. f.bb("Mehrfachherstellung\n") ..
            "auftritt und " .. f.l("nicht ") .. " " .. f.bb("Einfallsreichtum\n") ..
            "Und die Mathematik sagt uns, dass die Wahrscheinlichkeit, dass etwas nicht passiert, 1 minus die Wahrscheinlichkeit ist, dass es passiert.\n" ..
            "Die Chance, dass nur " ..
            f.bb("Mehrfachherstellung ") ..
            "auftritt, beträgt tatsächlich " .. f.g("multicraftChance * (1-resourcefulnessChance)\n\n") ..
            "Nach der Berechnung jeder Möglichkeit summieren sich die einzelnen Chancen tatsächlich auf eins!\n" ..
            "Das bedeutet, dass wir jetzt statistische Formeln anwenden können. Die interessanteste in unserem Fall ist der " ..
            f.bb("Erwartungswert") .. "\n" ..
            "Der ist, wie der Name schon sagt, der Wert, den wir im Durchschnitt erwarten können, oder in unserem Fall, der " ..
            f.bb(" erwartete Gewinn für eine Herstellung!\n") ..
            "\n" .. cm(CraftSim.MEDIA.IMAGES.EXPECTED_VALUE) .. "\n\n" ..
            "Dies sagt uns, dass der Erwartungswert " ..
            f.l("E") ..
            " einer Wahrscheinlichkeitsverteilung " ..
            f.l("X") .. " die Summe aller ihrer Werte multipliziert mit ihrer Wahrscheinlichkeit ist.\n" ..
            "Wenn wir also einen " ..
            f.bb("Fall A mit einer Wahrscheinlichkeit von 30 %") ..
            " und einen Gewinn von " ..
            CraftSim.UTIL:FormatMoney(-100 * 10000, true) ..
            " und einen\n" ..
            f.bb("Fall B mit einer Wahrscheinlichkeit von 70 %") ..
            " und einen Gewinn von " ..
            CraftSim.UTIL:FormatMoney(300 * 10000, true) .. " haben, dann beträgt der erwartete Gewinn\n" ..
            f.bb("\nE(X) = -100*0,3 + 300*0,7  ") ..
            "was " .. CraftSim.UTIL:FormatMoney((-100 * 0.3 + 300 * 0.7) * 10000, true) .. " ergibt.\n" ..
            "Du kannst alle Fälle für dein aktuelles Rezept im " .. f.bb("Statistik") .. " Fenster anzeigen!"
        ,

        -- Popups
        [CraftSim.CONST.TEXT.POPUP_NO_PRICE_SOURCE_SYSTEM] = "Keine unterstützte Preisquelle verfügbar!",
        [CraftSim.CONST.TEXT.POPUP_NO_PRICE_SOURCE_TITLE] = "CraftSim Preisquellenwarnung",
        [CraftSim.CONST.TEXT.POPUP_NO_PRICE_SOURCE_WARNING] =
        "Keine Preisquelle gefunden!\n\nDu musst mindestens eines der\nfolgenden Preisquellen-Addons installiert haben, um\ndie Gewinnberechnungen von CraftSim zu nutzen:\n\n\n",
        [CraftSim.CONST.TEXT.POPUP_NO_PRICE_SOURCE_WARNING_SUPPRESS] = "Warnung nicht mehr anzeigen",
        [CraftSim.CONST.TEXT.POPUP_NO_PRICE_SOURCE_WARNING_ACCEPT] = "OK",

        -- Materialfenster
        [CraftSim.CONST.TEXT.REAGENT_OPTIMIZATION_TITLE] = "CraftSim Reagenzien Optimierung",
        [CraftSim.CONST.TEXT.REAGENTS_REACHABLE_QUALITY] = "Erreichbare Qualität: ",
        [CraftSim.CONST.TEXT.REAGENTS_MISSING] = "Reagenzien fehlen",
        [CraftSim.CONST.TEXT.REAGENTS_AVAILABLE] = "Reagenzien verfügbar",
        [CraftSim.CONST.TEXT.REAGENTS_CHEAPER] = "Günstigste Reagenzien",
        [CraftSim.CONST.TEXT.REAGENTS_BEST_COMBINATION] = "Beste Kombination zugewiesen",
        [CraftSim.CONST.TEXT.REAGENTS_NO_COMBINATION] = "Keine Kombination gefunden,\num die Qualität zu erhöhen",
        [CraftSim.CONST.TEXT.REAGENTS_ASSIGN] = "Zuweisen",
        [CraftSim.CONST.TEXT.REAGENTS_MAXIMUM_QUALITY] = "Maximale Qualität: ",
        [CraftSim.CONST.TEXT.REAGENTS_AVERAGE_PROFIT_LABEL] = "Ø Gewinn: ",
        [CraftSim.CONST.TEXT.REAGENTS_AVERAGE_PROFIT_TOOLTIP] =
            f.bb("Der durchschnittliche Gewinn pro Herstellung") ..
            " bei Verwendung von " .. f.l("dieser Reagenzienverteilung"),
        [CraftSim.CONST.TEXT.REAGENTS_OPTIMIZE_BEST_ASSIGNED] = "Beste Reagenzien zugewiesen",
        [CraftSim.CONST.TEXT.REAGENTS_CONCENTRATION_LABEL] = "Konzentration: ",
        [CraftSim.CONST.TEXT.REAGENTS_OPTIMIZE_INFO] =
        "Shift + LMT auf die Zahlen, um den Gegenstandslink in den Chat einzufügen",
        [CraftSim.CONST.TEXT.ADVANCED_OPTIMIZATION_BUTTON] = "Optimieren",
        [CraftSim.CONST.TEXT.REAGENTS_OPTIMIZE_TOOLTIP] =
            f.r("Experimentell: ") ..
            "Leistungsintensiv und wird bei Änderungen zurückgesetzt.\nOptimiert für den " ..
            f.gold("höchsten Goldwert") .. " pro Konzentrationspunkt",

        -- Spezialisierungs-Infofenster
        [CraftSim.CONST.TEXT.SPEC_INFO_TITLE] = "CraftSim Spezialisierungsinfo",
        [CraftSim.CONST.TEXT.SPEC_INFO_SIMULATE_KNOWLEDGE_DISTRIBUTION] = "Wissenverteilung simulieren",
        [CraftSim.CONST.TEXT.SPEC_INFO_NODE_TOOLTIP] = "Dieser Knoten gewährt dir folgende Werte für dieses Rezept:",
        [CraftSim.CONST.TEXT.SPEC_INFO_WORK_IN_PROGRESS] = "Spezialisierungsinfo\nIn Arbeit",

        -- Herstellungs-Ergebnisse-Fenster
        [CraftSim.CONST.TEXT.CRAFT_LOG_TITLE] = "CraftSim Herstellungsergebnisse",
        [CraftSim.CONST.TEXT.CRAFT_LOG_LOG] = "Herstellungsprotokoll",
        [CraftSim.CONST.TEXT.CRAFT_LOG_LOG_1] = "Gewinn: ",
        [CraftSim.CONST.TEXT.CRAFT_LOG_LOG_2] = "Inspiriert!",
        [CraftSim.CONST.TEXT.CRAFT_LOG_LOG_3] = "Mehrfachherstellung: ",
        [CraftSim.CONST.TEXT.CRAFT_LOG_LOG_4] = "Ressourcen gespart!: ",
        [CraftSim.CONST.TEXT.CRAFT_LOG_LOG_5] = "Chance: ",
        [CraftSim.CONST.TEXT.CRAFT_LOG_CRAFTED_ITEMS] = "Herstellte Gegenstände",
        [CraftSim.CONST.TEXT.CRAFT_LOG_SESSION_PROFIT] = "Sitzungsgewinn",
        [CraftSim.CONST.TEXT.CRAFT_LOG_RESET_DATA] = "Daten zurücksetzen",
        [CraftSim.CONST.TEXT.CRAFT_LOG_EXPORT_JSON] = "JSON exportieren",
        [CraftSim.CONST.TEXT.CRAFT_LOG_RECIPE_STATISTICS] = "Rezeptstatistiken",
        [CraftSim.CONST.TEXT.CRAFT_LOG_NOTHING] = "Noch nichts hergestellt!",
        [CraftSim.CONST.TEXT.CRAFT_LOG_CALCULATION_COMPARISON_NUM_CRAFTS_PREFIX] = "Herstellungen: ",
        [CraftSim.CONST.TEXT.CRAFT_LOG_STATISTICS_2] = "Erwarteter Ø Gewinn: ",
        [CraftSim.CONST.TEXT.CRAFT_LOG_STATISTICS_3] = "Realer Ø Gewinn: ",
        [CraftSim.CONST.TEXT.CRAFT_LOG_STATISTICS_4] = "Realer Gewinn: ",
        [CraftSim.CONST.TEXT.CRAFT_LOG_STATISTICS_5] = "Procs - Real / Erwartet: ",
        [CraftSim.CONST.TEXT.CRAFT_LOG_STATISTICS_7] = "Mehrfachherstellung: ",
        [CraftSim.CONST.TEXT.CRAFT_LOG_STATISTICS_8] = "- Ø Zusätzliche Gegenstände: ",
        [CraftSim.CONST.TEXT.CRAFT_LOG_STATISTICS_9] = "Einfallsreichtum Procs: ",
        [CraftSim.CONST.TEXT.CRAFT_LOG_CALCULATION_COMPARISON_NUM_CRAFTS_PREFIX0] = "- Ø Gesparte Kosten: ",
        [CraftSim.CONST.TEXT.CRAFT_LOG_CALCULATION_COMPARISON_NUM_CRAFTS_PREFIX1] = "Gewinn: ",
        [CraftSim.CONST.TEXT.CRAFT_LOG_SAVED_REAGENTS] = "Gespeicherte Reagenzien",
        [CraftSim.CONST.TEXT.CRAFT_LOG_DISABLE_CHECKBOX] = f.l(
            "Herstellungsergebnisse deaktivieren"),
        [CraftSim.CONST.TEXT.CRAFT_LOG_DISABLE_CHECKBOX_TOOLTIP] =
            "Wenn aktiviert, wird die Aufzeichnung von Herstellungsergebnissen beim Herstellen gestoppt und kann die " ..
            f.g("Leistung verbessern"),
        [CraftSim.CONST.TEXT.CRAFT_LOG_RESULT_ANALYSIS_TAB_DISTRIBUTION_LABEL] = "Ergebnisverteilung",
        [CraftSim.CONST.TEXT.CRAFT_LOG_RESULT_ANALYSIS_TAB_DISTRIBUTION_HELP] =
        "Relative Verteilung der hergestellten Gegenstandsergebnisse (Mehrfachherstellungs-Mengen werden ignoriert)",
        [CraftSim.CONST.TEXT.CRAFT_LOG_RESULT_ANALYSIS_TAB_MULTICRAFT] = "Mehrfachherstellung",
        [CraftSim.CONST.TEXT.CRAFT_LOG_RESULT_ANALYSIS_TAB_RESOURCEFULNESS] = "Einfallsreichtum",
        [CraftSim.CONST.TEXT.CRAFT_LOG_RESULT_ANALYSIS_TAB_YIELD_DDISTRIBUTION] = "Ertragsverteilung",

        -- Statgewichtungsfenster
        [CraftSim.CONST.TEXT.STAT_WEIGHTS_TITLE] = "CraftSim Durchschnittlicher Gewinn",
        [CraftSim.CONST.TEXT.EXPLANATIONS_TITLE] = "CraftSim Erklärung zum Durchschnittlichen Gewinn",
        [CraftSim.CONST.TEXT.STAT_WEIGHTS_SHOW_EXPLANATION_BUTTON] = "Erklärung anzeigen",
        [CraftSim.CONST.TEXT.STAT_WEIGHTS_HIDE_EXPLANATION_BUTTON] = "Erklärung verbergen",
        [CraftSim.CONST.TEXT.STAT_WEIGHTS_SHOW_STATISTICS_BUTTON] = "Statistiken anzeigen",
        [CraftSim.CONST.TEXT.STAT_WEIGHTS_HIDE_STATISTICS_BUTTON] = "Statistiken verbergen",
        [CraftSim.CONST.TEXT.STAT_WEIGHTS_PROFIT_CRAFT] = "Ø Gewinn / Herstellung: ",
        [CraftSim.CONST.TEXT.EXPLANATIONS_BASIC_PROFIT_TAB] = "Grundlegende Gewinnberechnung",

        -- Kostendetailsfenster
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_TITLE] = "CraftSim Kostenoptimierung",
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_EXPLANATION] =
            "Hier kannst du eine Übersicht über alle möglichen Preise der verwendeten Reagenzien sehen.\nDie " ..
            f.bb("'Verwendete Quelle'") ..
            " Spalte zeigt an, welche der Preise verwendet wird.\n\n" ..
            f.g("AH") ..
            " .. Auktionshauspreis\n" ..
            f.l("ODER") ..
            " .. Preisüberschreibung\n" ..
            f.bb("Jeder Name") ..
            " .. Erwartete Kosten für die eigene Herstellung\n" ..
            f.l("ODER") ..
            " wird immer verwendet, wenn gesetzt. " ..
            f.bb("Herstellungskosten") .. " werden nur verwendet, wenn sie niedriger sind als " .. f.g("AH"),
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_CRAFTING_COSTS] = "Herstellungskosten: ",
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_ITEM_HEADER] = "Item",

        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_AH_PRICE_HEADER] = "AH-Preis",
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_OVERRIDE_HEADER] = "Überschreibung",
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_CRAFTING_HEADER] = "Herstellung",
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_USED_SOURCE] = "Verwendete Quelle",
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_REAGENT_COSTS_TAB] = "Reagenzienkosten",
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_SUB_RECIPE_OPTIONS_TAB] = "Unterrezept Optionen",
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_SUB_RECIPE_OPTIMIZATION] = "Unterrezept Optimierung " ..
            f.bb("(experimentell)"),
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_SUB_RECIPE_OPTIMIZATION_TOOLTIP] = "Wenn aktiviert, berücksichtigt " ..
            f.l("CraftSim") .. " die " .. f.g("optimierten Herstellungskosten") ..
            " deines Charakters und deiner Twinks,\nwenn sie in der Lage sind, diesen Gegenstand herzustellen.\n\n" ..
            f.r("Dies könnte die Leistung etwas verringern, da viele zusätzliche Berechnungen durchgeführt werden."),
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_SUB_RECIPE_MAX_DEPTH_LABEL] = "Berechnungstiefe des Unterrezepts",
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_SUB_RECIPE_INCLUDE_CONCENTRATION] = "Konzentration aktivieren",
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_SUB_RECIPE_INCLUDE_CONCENTRATION_TOOLTIP] =
            "Wenn aktiviert, berücksichtigt " ..
            f.l("CraftSim") .. " die Reagenzienqualität, selbst wenn Konzentration erforderlich ist.",
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_SUB_RECIPE_INCLUDE_COOLDOWN_RECIPES] = "Abklingzeit Rezepte einbeziehen",
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_SUB_RECIPE_INCLUDE_COOLDOWN_RECIPES_TOOLTIP] =
            "Wenn aktiviert, ignoriert " ..
            f.l("CraftSim") .. " die Abklingzeiten von Rezepten bei der Berechnung selbst hergestellter Reagenzien.",

        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_SUB_RECIPE_SELECT_RECIPE_CRAFTER] = "Rezepthersteller auswählen",
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_REAGENT_LIST_AH_COLUMN_AUCTION_BUYOUT] = "Auktions Sofortkauf: ",
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_REAGENT_LIST_OVERRIDE] = "\n\nÜberschreiben",
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_REAGENT_LIST_EXPECTED_COSTS_TOOLTIP] = "\n\nHerstellung",
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_REAGENT_LIST_EXPECTED_COSTS_PRE_ITEM] =
        "\n- Erwartete Kosten pro Gegenstand: ",
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_REAGENT_LIST_CONCENTRATION_COST] = f.gold("Kosten der Konzentration: "),
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_REAGENT_LIST_CONCENTRATION] = "Konzentration: ",

        -- Statistikfenster
        [CraftSim.CONST.TEXT.STATISTICS_TITLE] = "CraftSim Statistiken",
        [CraftSim.CONST.TEXT.STATISTICS_EXPECTED_PROFIT] = "Erwarteter Gewinn (μ)",
        [CraftSim.CONST.TEXT.STATISTICS_CHANCE_OF] = "Chance auf ",
        [CraftSim.CONST.TEXT.STATISTICS_PROFIT] = "Gewinn",
        [CraftSim.CONST.TEXT.STATISTICS_AFTER] = " nach",
        [CraftSim.CONST.TEXT.STATISTICS_CRAFTS] = "Herstellungen: ",
        [CraftSim.CONST.TEXT.STATISTICS_QUALITY_HEADER] = "Qualität",
        [CraftSim.CONST.TEXT.STATISTICS_MULTICRAFT_HEADER] = "Mehrfach\nherstellung",

        [CraftSim.CONST.TEXT.STATISTICS_RESOURCEFULNESS_HEADER] = "Einfallsreichtum",
        [CraftSim.CONST.TEXT.STATISTICS_EXPECTED_PROFIT_HEADER] = "Erwarteter Gewinn",
        [CraftSim.CONST.TEXT.PROBABILITY_TABLE_TITLE] = "Rezeptwahrscheinlichkeitstabelle",
        [CraftSim.CONST.TEXT.STATISTICS_PROBABILITY_TABLE_TAB] = "Wahrscheinlichkeits-Tabelle",
        [CraftSim.CONST.TEXT.STATISTICS_CONCENTRATION_TAB] = "Konzentration",
        [CraftSim.CONST.TEXT.STATISTICS_CONCENTRATION_CURVE_GRAPH] = "Kostenkurve der Konzentration",
        [CraftSim.CONST.TEXT.STATISTICS_CONCENTRATION_CURVE_GRAPH_HELP] =
            "Konzentrationskosten basierend auf Spielerfertigkeit für das gegebene Rezept\n" ..
            f.bb("X Achse: ") .. " Spielerfertigkeit\n" ..
            f.bb("Y Achse: ") .. " Konzentrationskosten",

        -- Preisdetailsfenster
        [CraftSim.CONST.TEXT.COST_OVERVIEW_TITLE] = "CraftSim Preisdaten",
        [CraftSim.CONST.TEXT.PRICE_DETAILS_INV_AH] = "Inventar/AH",
        [CraftSim.CONST.TEXT.PRICE_DETAILS_ITEM] = "Gegen\nstand",
        [CraftSim.CONST.TEXT.PRICE_DETAILS_PRICE_ITEM] = "Preis/Gegenstand",
        [CraftSim.CONST.TEXT.PRICE_DETAILS_PROFIT_ITEM] = "Gewinn/Gegenstand",

        -- Preisüberschreibungsfenster
        [CraftSim.CONST.TEXT.PRICE_OVERRIDE_TITLE] = "CraftSim Preisüberschreibungen",
        [CraftSim.CONST.TEXT.PRICE_OVERRIDE_REQUIRED_REAGENTS] = "Erforderliche Reagenzien",
        [CraftSim.CONST.TEXT.PRICE_OVERRIDE_OPTIONAL_REAGENTS] = "Optionale Reagenzien",
        [CraftSim.CONST.TEXT.PRICE_OVERRIDE_FINISHING_REAGENTS] = "Abschlussreagenzien",
        [CraftSim.CONST.TEXT.PRICE_OVERRIDE_RESULT_ITEMS] = "Ergebnisgegenstände",
        [CraftSim.CONST.TEXT.PRICE_OVERRIDE_ACTIVE_OVERRIDES] = "Aktive Überschreibungen",
        [CraftSim.CONST.TEXT.PRICE_OVERRIDE_ACTIVE_OVERRIDES_TOOLTIP] =
        "'(als Ergebnis)' -> Preisüberschreibung wird nur berücksichtigt, wenn der Gegenstand das Ergebnis eines Rezepts ist",
        [CraftSim.CONST.TEXT.PRICE_OVERRIDE_CLEAR_ALL] = "Alles löschen",
        [CraftSim.CONST.TEXT.PRICE_OVERRIDE_SAVE] = "Speichern",
        [CraftSim.CONST.TEXT.PRICE_OVERRIDE_SAVED] = "Gespeichert",
        [CraftSim.CONST.TEXT.PRICE_OVERRIDE_REMOVE] = "Entfernen",

        -- Rezept-Scan-Fenster
        [CraftSim.CONST.TEXT.RECIPE_SCAN_TITLE] = "CraftSim Rezept-Scan",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_MODE] = "Scanmodus",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_SORT_MODE] = "Sortiermodus",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_SCAN_RECIPIES] = "Rezepte scannen",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_SCAN_CANCEL] = "Abbrechen",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_SCANNING] = "Scannen",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_INCLUDE_NOT_LEARNED] = "Nicht erlernte einbeziehen",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_INCLUDE_NOT_LEARNED_TOOLTIP] =
        "Füge nicht erlernte Rezepte in den Rezept-Scan ein",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_INCLUDE_SOULBOUND] = "Seelengebunden einbeziehen",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_INCLUDE_SOULBOUND_TOOLTIP] =
        "Seelengebundene Rezepte in den Rezept-Scan einbeziehen.\n\nEs wird empfohlen, eine Preisüberschreibung festzulegen (z.B. um eine Zielprovision zu simulieren)\nim Preisüberschreibungsmodul für die hergestellten Gegenstände dieses Rezepts",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_INCLUDE_GEAR] = "Ausrüstung einbeziehen",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_INCLUDE_GEAR_TOOLTIP] =
        "Alle Arten von Ausrüstungsrezepten in den Rezept-Scan einbeziehen",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_OPTIMIZE_TOOLS] = "Berufswerkzeuge optimieren",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_OPTIMIZE_TOOLS_TOOLTIP] =
        "Optimiere für jedes Rezept deine Berufswerkzeuge für den Gewinn\n\n",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_OPTIMIZE_TOOLS_WARNING] =
        "Könnte die Leistung während des Scans beeinträchtigen,\nwenn du viele Werkzeuge in deinem Inventar hast",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_CRAFTER_HEADER] = "Handwerker",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_RECIPE_HEADER] = "Rezept",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_LEARNED_HEADER] = "Erlernt",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_RESULT_HEADER] = "Ergeb\nnis",

        [CraftSim.CONST.TEXT.RECIPE_SCAN_AVERAGE_PROFIT_HEADER] = "Durchschnittlicher Gewinn",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_CONCENTRATION_VALUE_HEADER] = "Konz.-Wert",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_CONCENTRATION_COST_HEADER] = "Konz.-Kosten",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_TOP_GEAR_HEADER] = "Beste Ausrüstung",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_INV_AH_HEADER] = "Inventar/AH",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_SORT_BY_MARGIN] = "Nach Gewinn % sortieren",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_SORT_BY_MARGIN_TOOLTIP] =
        "Sortiere die Gewinnliste nach Gewinn relativ zu den Herstellungskosten.\n(Ein neuer Scan ist erforderlich)",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_USE_INSIGHT_CHECKBOX] = "Verwenden " .. f.bb("Erkenntnis") .. " wenn möglich",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_USE_INSIGHT_CHECKBOX_TOOLTIP] = "Verwende " ..
            f.bb("Illustre Erkenntnis") ..
            " oder\n" .. f.bb("Geringe illustre Erkenntnis") .. " als optionales Reagenz für Rezepte, die dies zulassen.",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_ONLY_FAVORITES_CHECKBOX] = "Nur Favoriten",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_ONLY_FAVORITES_CHECKBOX_TOOLTIP] = "Scanne nur deine Lieblingsrezepte",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_EQUIPPED] = "Ausgerüstet",

        [CraftSim.CONST.TEXT.RECIPE_SCAN_MODE_OPTIMIZE] = "Reagenzien optimieren",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_SORT_MODE_PROFIT] = "Gewinn",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_SORT_MODE_RELATIVE_PROFIT] = "Relativer Gewinn",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_SORT_MODE_CONCENTRATION_VALUE] = "Konzentrationswert",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_SORT_MODE_CONCENTRATION_COST] = "Konzentrationskosten",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_EXPANSION_FILTER_BUTTON] = "Erweiterungen",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_ALTPROFESSIONS_FILTER_BUTTON] = "Alt-Berufe",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_SCAN_ALL_BUTTON_READY] = "Berufe scannen",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_SCAN_ALL_BUTTON_SCANNING] = "Scannen...",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_TAB_LABEL_SCAN] = "Rezept-Scan",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_TAB_LABEL_OPTIONS] = "Scan-Optionen",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_IMPORT_ALL_PROFESSIONS_CHECKBOX_LABEL] = "Alle gescannten Berufe",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_IMPORT_ALL_PROFESSIONS_CHECKBOX_TOOLTIP] = f.g("Wahr: ") ..
            "Importiere Scan-Ergebnisse von allen aktivierten und gescannten Berufen\n\n" ..
            f.r("Falsch: ") .. "Importiere Scan-Ergebnisse nur vom aktuell ausgewählten Beruf",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_CACHED_RECIPES_TOOLTIP] =
            "Jedes Mal, wenn du ein Rezept auf einem Charakter öffnest oder scannst, " ..
            f.l("CraftSim") ..
            " merkt es sich.\n\nNur Rezepte deiner Alts, die " ..
            f.l("CraftSim") .. " sich merken kann, werden mit " .. f.bb("RecipeScan\n\n") ..
            "gescannt. Die tatsächliche Anzahl der gescannten Rezepte basiert dann auf deinen " ..
            f.e("Rezept-Scan-Optionen"),
        [CraftSim.CONST.TEXT.RECIPE_SCAN_CONCENTRATION_TOGGLE] = " Konzentration",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_CONCENTRATION_TOGGLE_TOOLTIP] = "Konzentration umschalten",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_OPTIMIZE_SUBRECIPES] = "Unterrezepte optimieren " .. f.bb("(experimentell)"),
        [CraftSim.CONST.TEXT.RECIPE_SCAN_OPTIMIZE_SUBRECIPES_TOOLTIP] = "Wenn aktiviert, optimiert " ..
            f.l("CraftSim") ..
            " auch die Herstellung von zwischengespeicherten Reagenz-Rezepten der gescannten Rezepte und verwendet ihre\n" ..
            f.bb("erwarteten Kosten") .. ", um die Herstellungskosten für das Endprodukt zu berechnen.\n\n" ..
            f.r("Warnung: Dies könnte die Scan-Leistung verringern"),
        [CraftSim.CONST.TEXT.RECIPE_SCAN_CACHED_RECIPES] = "Zwischengespeicherte Rezepte: ",


        -- Rezept-Beste Ausrüstung
        [CraftSim.CONST.TEXT.TOP_GEAR_TITLE] = "CraftSim Beste Ausrüstung",
        [CraftSim.CONST.TEXT.TOP_GEAR_AUTOMATIC] = "Automatisch",
        [CraftSim.CONST.TEXT.TOP_GEAR_AUTOMATIC_TOOLTIP] =
        "Simuliere automatisch die Beste Ausrüstung für deinen ausgewählten Modus, wann immer ein Rezept aktualisiert wird.\n\nDas Deaktivieren kann die Leistung verbessern.",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIMULATE] = "Beste Ausrüstung simulieren",
        [CraftSim.CONST.TEXT.TOP_GEAR_EQUIP] = "Anlegen",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIMULATE_QUALITY] = "Qualität: ",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIMULATE_EQUIPPED] = "Beste Ausrüstung angelegt",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIMULATE_PROFIT_DIFFERENCE] = "Ø Gewinnunterschied\n",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIMULATE_NEW_MUTLICRAFT] = "Neue Mehrfachherstellung\n",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIMULATE_NEW_CRAFTING_SPEED] = "Neue Herstellungsgeschwindigkeit\n",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIMULATE_NEW_RESOURCEFULNESS] = "Neuer Einfallsreichtum\n",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIMULATE_NEW_SKILL] = "Neue Fertigkeit\n",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIMULATE_UNHANDLED] = "Ungehandelter Simulationsmodus",

        [CraftSim.CONST.TEXT.TOP_GEAR_SIM_MODES_PROFIT] = "Höchster Gewinn",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIM_MODES_SKILL] = "Höchste Fertigkeit",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIM_MODES_MULTICRAFT] = "Beste Mehrfachherstellung",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIM_MODES_RESOURCEFULNESS] = "Bester Einfallsreichtum",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIM_MODES_CRAFTING_SPEED] = "Beste Herstellungsgeschwindigkeit",

        -- Optionen
        [CraftSim.CONST.TEXT.OPTIONS_TITLE] = "CraftSim Optionen",
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_TAB] = "Allgemein",
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_PRICE_SOURCE] = "Preisquelle",
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_CURRENT_PRICE_SOURCE] = "Aktuelle Preisquelle: ",
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_NO_PRICE_SOURCE] = "Kein unterstütztes Preisquellen-Addon geladen!",
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_SHOW_PROFIT] = "Gewinnprozentsatz anzeigen",
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_SHOW_PROFIT_TOOLTIP] =
        "Zeige den Prozentsatz des Gewinns zu den Herstellungskosten neben dem Goldwert an",
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_REMEMBER_LAST_RECIPE] = "Letztes Rezept merken",
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_REMEMBER_LAST_RECIPE_TOOLTIP] =
        "Öffne das zuletzt ausgewählte Rezept beim Öffnen des Herstellungsfensters erneut",
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_SUPPORTED_PRICE_SOURCES] = "Unterstützte Preisquellen:",
        [CraftSim.CONST.TEXT.OPTIONS_PERFORMANCE_RAM] = "RAM Bereinigung beim Herstellen aktivieren",
        [CraftSim.CONST.TEXT.OPTIONS_PERFORMANCE_RAM_CRAFTS] = "Herstellungen",

        [CraftSim.CONST.TEXT.OPTIONS_PERFORMANCE_RAM_TOOLTIP] =
        "Wenn aktiviert, wird CraftSim dein RAM nach einer bestimmten Anzahl von Herstellungen von ungenutzten Daten bereinigen, um zu verhindern, dass sich der Speicher ansammelt.\nSpeicheraufbau kann auch durch andere Addons verursacht werden und ist nicht CraftSim-spezifisch.\nEine Bereinigung betrifft die gesamte WoW-RAM-Nutzung.",
        [CraftSim.CONST.TEXT.OPTIONS_MODULES_TAB] = "Module",
        [CraftSim.CONST.TEXT.OPTIONS_PROFIT_CALCULATION_TAB] = "Gewinnberechnung",
        [CraftSim.CONST.TEXT.OPTIONS_CRAFTING_TAB] = "Herstellung",
        [CraftSim.CONST.TEXT.OPTIONS_TSM_RESET] = "Zurücksetzen auf Standard",
        [CraftSim.CONST.TEXT.OPTIONS_TSM_INVALID_EXPRESSION] = "Ungültiger Ausdruck",
        [CraftSim.CONST.TEXT.OPTIONS_TSM_VALID_EXPRESSION] = "Gültiger Ausdruck",
        [CraftSim.CONST.TEXT.OPTIONS_MODULES_REAGENT_OPTIMIZATION] = "Modul zur Reagenzien Optimierung",

        [CraftSim.CONST.TEXT.OPTIONS_MODULES_AVERAGE_PROFIT] = "Durchschnittsgewinnmodul",
        [CraftSim.CONST.TEXT.OPTIONS_MODULES_TOP_GEAR] = "Modul Beste Ausrüstung",
        [CraftSim.CONST.TEXT.OPTIONS_MODULES_COST_OVERVIEW] = "Kostenübersichtsmodul",
        [CraftSim.CONST.TEXT.OPTIONS_MODULES_SPECIALIZATION_INFO] = "Spezialisierungsinfo-Modul",
        [CraftSim.CONST.TEXT.OPTIONS_MODULES_CUSTOMER_HISTORY_SIZE] =
        "Maximale Nachrichtenanzahl pro Kunde in der Kundenhistorie",
        [CraftSim.CONST.TEXT.OPTIONS_MODULES_CUSTOMER_HISTORY_MAX_ENTRIES_PER_CLIENT] =
        "Maximale Verlaufseinträge pro Client",
        [CraftSim.CONST.TEXT.OPTIONS_PROFIT_CALCULATION_OFFSET] = "Fertigkeitsschwellenwerte um 1 verschieben",
        [CraftSim.CONST.TEXT.OPTIONS_PROFIT_CALCULATION_OFFSET_TOOLTIP] =
        "Die Vorschläge zur Reagenzienkombination versuchen, den Schwellenwert + 1 zu erreichen, anstatt die genau erforderliche Fertigkeit zu erreichen",

        [CraftSim.CONST.TEXT.OPTIONS_PROFIT_CALCULATION_MULTICRAFT_CONSTANT] = "Mehrfachherstellungskonstante",
        [CraftSim.CONST.TEXT.OPTIONS_PROFIT_CALCULATION_MULTICRAFT_CONSTANT_EXPLANATION] =
        "Standard: 2.5\n\nHerstellungsdaten von verschiedenen Datensammlern in der Beta und im frühen Dragonflight deuten darauf hin,\ndass die maximale Anzahl zusätzlicher Gegenstände, die man bei einem Mehrfachherstellungs-Proz erhalten kann, 1+C*y beträgt.\nWobei y die Basisgegenstandsmenge für eine Herstellung ist und C 2,5 beträgt.\nWenn du möchtest, kannst du diesen Wert hier ändern.",
        [CraftSim.CONST.TEXT.OPTIONS_PROFIT_CALCULATION_RESOURCEFULNESS_CONSTANT] = "Einfallsreichtumskonstante",
        [CraftSim.CONST.TEXT.OPTIONS_PROFIT_CALCULATION_RESOURCEFULNESS_CONSTANT_EXPLANATION] =
        "Standard: 0.3\n\nHerstellungsdaten von verschiedenen Datensammlern in der Beta und im frühen Dragonflight deuten darauf hin,\ndass die durchschnittlich eingesparte Menge an Gegenständen 30 % der erforderlichen Menge beträgt.\nWenn du möchtest, kannst du diesen Wert hier ändern.",
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_SHOW_NEWS_CHECKBOX] = "Zeige " .. f.bb("News") .. " Popup",
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_SHOW_NEWS_CHECKBOX_TOOLTIP] = "Zeige das " ..
            f.bb("News") .. " Popup für neue " .. f.l("CraftSim") .. " Update-Informationen beim Einloggen ins Spiel",
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_HIDE_MINIMAP_BUTTON_CHECKBOX] = "Minikarten-Symbol verbergen",
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_HIDE_MINIMAP_BUTTON_TOOLTIP] = "Aktiviere dies, um das " ..
            f.l("CraftSim") .. " Minikarten-Symbol zu verbergen",
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_COIN_MONEY_FORMAT_CHECKBOX] = "Münztexturen verwenden: ",
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_COIN_MONEY_FORMAT_TOOLTIP] =
        "Münzsymbole zur Formatierung von Geld verwenden",

        -- Steuerungsfeld
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_CRAFT_QUEUE_LABEL] = "Herstellungswarteschl.",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_CRAFT_QUEUE_TOOLTIP] =
        "Stelle deine Rezepte in eine Warteschlange und stelle sie alle an einem Ort her!",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_TOP_GEAR_LABEL] = "Beste Ausrüstung",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_TOP_GEAR_TOOLTIP] =
        "Zeigt die beste verfügbare Berufsausrüstungskombination basierend auf dem ausgewählten Modus an",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_COST_OVERVIEW_LABEL] = "Preisdaten",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_COST_OVERVIEW_TOOLTIP] =
        "Zeigt eine Übersicht über Verkaufspreis und Gewinn nach resultierender Gegenstandsqualität an",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_AVERAGE_PROFIT_LABEL] = "Ø Gewinn",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_AVERAGE_PROFIT_TOOLTIP] =
        "Zeigt den durchschnittlichen Gewinn basierend auf deinen Berufsstatistiken und den Gewinnstatistikwerten als Gold pro Punkt an.",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_REAGENT_OPTIMIZATION_LABEL] = "Reagenzien Optimierung",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_REAGENT_OPTIMIZATION_TOOLTIP] =
        "Schlägt die günstigsten Reagenzien vor, um die höchste Qualitätsschwelle zu erreichen.",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_PRICE_OVERRIDES_LABEL] = "Preisüberschr.",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_PRICE_OVERRIDES_TOOLTIP] =
        "Überschreibe Preise für beliebige Reagenzien, optionale Reagenzien und Herstellungsergebnisse für alle Rezepte oder für ein bestimmtes Rezept.",

        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_SPECIALIZATION_INFO_LABEL] = "Spezialisierungsinfo",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_SPECIALIZATION_INFO_TOOLTIP] =
        "Zeigt an, wie deine Berufsspezialisierungen dieses Rezept beeinflussen, und ermöglicht es, jede Konfiguration zu simulieren!",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_CRAFT_LOG_LABEL] = "Herstellungsergeb.",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_CRAFT_LOG_TOOLTIP] =
        "Zeige ein Herstellungsprotokoll und Statistiken über deine Herstellungen!",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_COST_OPTIMIZATION_LABEL] = "Kostenoptimierung",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_COST_OPTIMIZATION_TOOLTIP] =
        "Modul, das detaillierte Informationen anzeigt und bei der Optimierung der Herstellungskosten hilft",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_STATISTICS_LABEL] = "Statistiken",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_STATISTICS_TOOLTIP] =
        "Modul, das detaillierte Ergebnisstatistiken für das aktuell geöffnete Rezept anzeigt",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_RECIPE_SCAN_LABEL] = "Rezept-Scan",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_RECIPE_SCAN_TOOLTIP] =
        "Modul, das deine Rezeptliste basierend auf verschiedenen Optionen scannt",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_CUSTOMER_HISTORY_LABEL] = "Kundenhistorie",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_CUSTOMER_HISTORY_TOOLTIP] =
        "Modul, das eine Historie von Gesprächen mit Kunden, hergestellten Gegenständen und Aufträgen bereitstellt",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_CRAFT_BUFFS_LABEL] = "Herstellungs-Buffs",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_CRAFT_BUFFS_TOOLTIP] =
        "Modul, das dir deine aktiven und fehlenden Herstellungs-Buffs anzeigt",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_EXPLANATIONS_LABEL] = "Erklärungen",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_EXPLANATIONS_TOOLTIP] =
            "Modul, das dir verschiedene Erklärungen zeigt, wie" .. f.l(" CraftSim") .. " Dinge berechnet",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_RESET_FRAMES] = "Fensterpos. zurücksetzen",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_OPTIONS] = "Optionen",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_NEWS] = "News",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_EASYCRAFT_EXPORT] = f.l("Easycraft") .. " Export",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_EASYCRAFT_EXPORTING] = "Exportiere",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_EASYCRAFT_EXPORT_NO_RECIPE_FOUND] =
        "Kein Rezept zum Exportieren für die The War Within-Erweiterung gefunden",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_FORGEFINDER_EXPORT] = f.l("ForgeFinder") .. " Export",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_FORGEFINDER_EXPORTING] = "Exportiere",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_EXPORT_EXPLANATION] = f.l("wowforgefinder.com") ..
            " und " .. f.l("easycraft.io") ..
            "\nsind Websites, um " .. f.bb("WoW-Aufträge") .. " zu suchen und anzubieten",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_DEBUG] = "Debug",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_TITLE] = "Steuerungsfeld",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_SUPPORTERS_BUTTON] = f.patreon("Unterstützer"),

        -- Unterstützer
        [CraftSim.CONST.TEXT.SUPPORTERS_DESCRIPTION] = f.l("Danke an all diese großartigen Menschen!"),
        [CraftSim.CONST.TEXT.SUPPORTERS_DESCRIPTION_2] = f.l(
            "Willst du CraftSim unterstützen und auch hier mit deiner Nachricht aufgeführt werden?\nErwäge eine Spende <3"),
        [CraftSim.CONST.TEXT.SUPPORTERS_DATE] = "Datum",
        [CraftSim.CONST.TEXT.SUPPORTERS_SUPPORTER] = "Unterstützer",
        [CraftSim.CONST.TEXT.SUPPORTERS_MESSAGE] = "Nachricht",

        -- Kundenhistorie
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_TITLE] = "CraftSim Kundenhistorie",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_DROPDOWN_LABEL] = "Wähle einen Kunden",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_TOTAL_TIP] = "Gesamtes Trinkgeld: ",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_FROM] = "Von",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_TO] = "An",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_FOR] = "Für",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_CRAFT_FORMAT] = "Herstellte %s für %s",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_DELETE_BUTTON] = "Kunden entfernen",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_WHISPER_BUTTON_LABEL] = "Flüstern..",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_PURGE_NO_TIP_LABEL] = "Kunden mit 0 Trinkgeld entfernen",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_PURGE_ZERO_TIPS_CONFIRMATION_POPUP] =
        "Bist du sicher, dass du alle Daten\nvon Kunden mit insgesamt 0 Trinkgeld löschen möchtest?",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_DELETE_CUSTOMER_CONFIRMATION_POPUP] =
        "Bist du sicher, dass du alle Daten für %s löschen möchtest?",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_PURGE_DAYS_INPUT_LABEL] = "Automatisches Entfernen-Intervall (Tage)",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_PURGE_DAYS_INPUT_TOOLTIP] =
        "CraftSim wird alle 0-Trinkgeld-Kunden automatisch löschen, wenn du dich nach X Tagen seit der letzten Löschung einloggst.\nWenn auf 0 gesetzt, wird CraftSim nie automatisch löschen.",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_CUSTOMER_HEADER] = "Kunde",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_TOTAL_TIP_HEADER] = "Gesamtes Trinkgeld",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_CRAFT_HISTORY_DATE_HEADER] = "Datum",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_CRAFT_HISTORY_RESULT_HEADER] = "Ergebnis",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_CRAFT_HISTORY_TIP_HEADER] = "Trinkgeld",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_CRAFT_HISTORY_CUSTOMER_REAGENTS_HEADER] = "Kundenreagenzien",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_CRAFT_HISTORY_CUSTOMER_NOTE_HEADER] = "Notiz",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_CHAT_MESSAGE_TIMESTAMP] = "Zeitstempel",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_CHAT_MESSAGE_SENDER] = "Absender",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_CHAT_MESSAGE_MESSAGE] = "Nachricht",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_CHAT_MESSAGE_YOU] = "[Du]: ",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_CRAFT_LIST_TIMESTAMP] = "Zeitstempel",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_CRAFT_LIST_RESULTLINK] = "Ergebnislink",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_CRAFT_LIST_TIP] = "Trinkgeld",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_CRAFT_LIST_REAGENTS] = "Reagenzien",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_CRAFT_LIST_SOMENOTE] = "Eine Notiz",


        -- Herstellungswarteschlange
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_TITLE] = "CraftSim Herstellungswarteschlange",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_AMOUNT_LEFT_HEADER] = "Eingereiht",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_PROFESSION_GEAR_HEADER] = "Berufsausrüstung",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFTING_COSTS_HEADER] = "Herstellungskosten",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL] = "Herstellen",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL_WRONG_GEAR] = "Falsche Werkzeuge",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL_NO_REAGENTS] = "Keine Reagenzien",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_ADD_OPEN_RECIPE_BUTTON_LABEL] = "Offenes Rezept hinzufügen",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_ADD_FIRST_CRAFTS_BUTTON_LABEL] = "Erstherstellungen hinzufügen",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_ADD_WORK_ORDERS_BUTTON_LABEL] = "Aufträge von Kunden hinzufügen",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_ADD_WORK_ORDERS_ALLOW_CONCENTRATION_CHECKBOX] = "Konzentration erlauben",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_ADD_WORK_ORDERS_ALLOW_CONCENTRATION_TOOLTIP] =
            "Wenn die Mindestqualität nicht erreicht werden kann, verwende " .. f.l("Konzentration") .. " falls möglich",

        [CraftSim.CONST.TEXT.CRAFT_QUEUE_CLEAR_ALL_BUTTON_LABEL] = "Alles löschen",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_FAVORITES_BUTTON_LABEL] = "Aus Rezept-Scan auffüllen",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL_WRONG_PROFESSION] = "Falscher Beruf",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL_ON_COOLDOWN] = "Abklingzeit aktiv",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL_WRONG_CRAFTER] = "Falscher Handwerker",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_RECIPE_REQUIREMENTS_HEADER] = "Anforderungen",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_RECIPE_REQUIREMENTS_TOOLTIP] =
        "Alle Anforderungen müssen erfüllt sein, um ein Rezept herzustellen",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_NEXT_BUTTON_LABEL] = "Nächste herstellen",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_AVAILABLE_AMOUNT] = "Herstellbar",
        [CraftSim.CONST.TEXT.CRAFTQUEUE_AUCTIONATOR_SHOPPING_LIST_BUTTON_LABEL] = "Auctionator Einkaufsliste erstellen",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_QUEUE_TAB_LABEL] = "Herstellungswarteschlange",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_FLASH_TASKBAR_OPTION_LABEL] = "Taskleiste blinken bei " ..
            f.bb("Herstellungswarteschlange") .. " Herstellung beendet",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_FLASH_TASKBAR_OPTION_TOOLTIP] =
            "Wenn dein WoW-Spiel minimiert ist und ein Rezept in der " .. f.bb("Herstellungswarteschlange") ..
            "," .. f.l(" CraftSim") .. " fertiggestellt wurde, wird das WoW-Taskleistensymbol blinken",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_TAB_LABEL] = "Auffülloptionen",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_TAB_TOOLTIP] =
        "Konfiguriere das Auffüllverhalten beim Importieren aus dem Rezept Scan",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_GENERAL_PROFIT_THRESHOLD_LABEL] = "Gewinnschwelle:",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_SALE_RATE_INPUT_LABEL] = "Verkaufsrate Schwelle:",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_TSM_SALE_RATE_TOOLTIP] = string.format(
            [[
Nur verfügbar, wenn %s geladen ist!

Es wird geprüft, ob %s einer Gegenstandsqualität eine Verkaufsrate
hat, die größer oder gleich der konfigurierten Verkaufsraten-Schwelle ist.
]], f.bb("TSM"), f.bb("irgendeine")),
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_TSM_SALE_RATE_TOOLTIP_GENERAL] = string.format(
            [[
Nur verfügbar, wenn %s geladen ist!

Es wird geprüft, ob %s einer Gegenstandsqualität eine Verkaufsrate
hat, die größer oder gleich der konfigurierten Verkaufsraten-Schwelle ist.
]], f.bb("TSM"), f.bb("irgendeine")),
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_AMOUNT_LABEL] = "Auffüllmenge:",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_RESTOCK_TOOLTIP] = "Dies ist die " ..
            f.bb("Menge an Herstellungen") ..
            " die für dieses Rezept eingereiht wird.\n\nDie Menge der Gegenstände, die du in deinem Inventar und Bank der überprüften Qualitäten hast, wird von der Auffüllmenge abgezogen, wenn aufgefüllt wird",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_ENABLE_RECIPE_LABEL] = "Aktivieren:",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_GENERAL_OPTIONS_LABEL] = "Allgemeine Optionen (Alle Rezepte)",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_ENABLE_RECIPE_TOOLTIP] =
        "Wenn dies deaktiviert ist, wird das Rezept basierend auf den allgemeinen Optionen oben aufgefüllt",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_TOTAL_PROFIT_LABEL] = "Gesamter Ø Gewinn:",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_TOTAL_CRAFTING_COSTS_LABEL] = "Gesamte Herstellungskosten:",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_EDIT_RECIPE_TITLE] = "Rezept bearbeiten",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_EDIT_RECIPE_NAME_LABEL] = "Rezeptname",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_EDIT_RECIPE_REAGENTS_SELECT_LABEL] = "Auswählen",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_EDIT_RECIPE_OPTIONAL_REAGENTS_LABEL] = "Optionale Reagenzien",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_EDIT_RECIPE_FINISHING_REAGENTS_LABEL] = "Abschlussreagenzien",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_EDIT_RECIPE_PROFESSION_GEAR_LABEL] = "Berufsausrüstung",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_EDIT_RECIPE_OPTIMIZE_PROFIT_BUTTON] = "Gewinn optimieren",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_EDIT_RECIPE_CRAFTING_COSTS_LABEL] = "Herstellungskosten: ",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_EDIT_RECIPE_AVERAGE_PROFIT_LABEL] = "Durchschnittlicher Gewinn: ",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_EDIT_RECIPE_RESULTS_LABEL] = "Ergebnisse",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_EDIT_RECIPE_CONCENTRATION_CHECKBOX] = " Konzentration",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_AUCTIONATOR_SHOPPING_LIST_PER_CHARACTER_CHECKBOX] = "Pro Charakter",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_AUCTIONATOR_SHOPPING_LIST_PER_CHARACTER_CHECKBOX_TOOLTIP] = "Erstelle eine " ..
            f.bb("Auctionator Einkaufsliste") .. " für jeden Handwerkercharakter\nanstatt eine Einkaufsliste für alle",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_AUCTIONATOR_SHOPPING_LIST_TARGET_MODE_CHECKBOX] = "Nur Zielmodus",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_AUCTIONATOR_SHOPPING_LIST_TARGET_MODE_CHECKBOX_TOOLTIP] = "Erstelle eine " ..
            f.bb("Auctionator Einkaufsliste") .. " nur für Zielmodusrezepte",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_UNSAVED_CHANGES_TOOLTIP] = f.white(
            "Nicht gespeicherte Warteschlangenmenge.\nDrücke Enter, um zu speichern"),
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_STATUSBAR_LEARNED] = f.white("Rezept erlernt"),
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_STATUSBAR_COOLDOWN] = f.white("Keine Abklingzeit"),
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_STATUSBAR_REAGENTS] = f.white("Reagenzien verfügbar"),

        [CraftSim.CONST.TEXT.CRAFT_QUEUE_STATUSBAR_GEAR] = f.white("Berufsausrüstung angelegt"),
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_STATUSBAR_CRAFTER] = f.white("Richtiger Handwerkercharakter"),
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_STATUSBAR_PROFESSION] = f.white("Beruf geöffnet"),
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_BUTTON_EDIT] = "Bearbeiten",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_BUTTON_CRAFT] = "Herstellen",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_BUTTON_CLAIM] = "Anfordern",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_BUTTON_CLAIMED] = "Angefordert",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_BUTTON_NEXT] = "Nächstes: ",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_BUTTON_NOTHING_QUEUED] = "Nichts in der Warteschlange",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_BUTTON_ORDER] = "Bestellung",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_BUTTON_SUBMIT] = "Abschicken",

        [CraftSim.CONST.TEXT.CRAFT_QUEUE_IGNORE_ACUITY_RECIPES_CHECKBOX_LABEL] =
        "Händchen fürs Kunsthandwerk-Rezepte ignorieren",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_IGNORE_ACUITY_RECIPES_CHECKBOX_TOOLTIP] =
            "Erstherstellungen, die " ..
            f.bb("Händchen fürs Kunsthandwerk") .. " verwenden, nicht in die Warteschlange aufnehmen",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_AMOUNT_TOOLTIP] = "\n\nWartende Handwerke: ",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_ORDER_CUSTOMER] = "\n\nBestellung von Kunde: ",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_ORDER_MINIMUM_QUALITY] = "\nnMindestqualität: ",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_ORDER_REWARDS] = "\nBelohnungen:",


        -- Herstellungs-Buffs

        [CraftSim.CONST.TEXT.CRAFT_BUFFS_TITLE] = "CraftSim Herstellungs-Buffs",
        [CraftSim.CONST.TEXT.CRAFT_BUFFS_SIMULATE_BUTTON] = "Buffs simulieren",
        [CraftSim.CONST.TEXT.CRAFT_BUFF_CHEFS_HAT_TOOLTIP] = f.bb("Wrath of the Lich King Spielzeug.") ..
            "\nErfordert Nordend-Kochkunst\nSetzt Herstellungsgeschwindigkeit auf " .. f.g("0,5 Sekunden"),

        -- Abklingzeiten-Modul

        [CraftSim.CONST.TEXT.COOLDOWNS_TITLE] = "CraftSim Abklingzeiten",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_COOLDOWNS_LABEL] = "Abklingzeiten",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_COOLDOWNS_TOOLTIP] = "Übersicht über die " ..
            f.bb("Berufs-Abklingzeiten") .. " deines Accounts",
        [CraftSim.CONST.TEXT.COOLDOWNS_CRAFTER_HEADER] = "Handwerker",
        [CraftSim.CONST.TEXT.COOLDOWNS_RECIPE_HEADER] = "Rezept",
        [CraftSim.CONST.TEXT.COOLDOWNS_CHARGES_HEADER] = "Aufla\ndungen",

        [CraftSim.CONST.TEXT.COOLDOWNS_NEXT_HEADER] = "Nächste Aufladung",
        [CraftSim.CONST.TEXT.COOLDOWNS_ALL_HEADER] = "Aufladungen voll",
        [CraftSim.CONST.TEXT.COOLDOWNS_TAB_OVERVIEW] = "Übersicht",
        [CraftSim.CONST.TEXT.COOLDOWNS_TAB_OPTIONS] = "Optionen",
        [CraftSim.CONST.TEXT.COOLDOWNS_EXPANSION_FILTER_BUTTON] = "Erweiterungsfilter",
        [CraftSim.CONST.TEXT.COOLDOWNS_RECIPE_LIST_TEXT_TOOLTIP] = f.bb("\n\nRezepte, die diese Abklingzeit teilen:\n"),
        [CraftSim.CONST.TEXT.COOLDOWNS_RECIPE_READY] = f.g("Bereit"),

        -- Konzentrations-Modul

        [CraftSim.CONST.TEXT.CONCENTRATION_TRACKER_TITLE] = "CraftSim Konzentration",
        [CraftSim.CONST.TEXT.CONCENTRATION_TRACKER_LABEL_CRAFTER] = "Hersteller",
        [CraftSim.CONST.TEXT.CONCENTRATION_TRACKER_LABEL_CURRENT] = "Aktuell",
        [CraftSim.CONST.TEXT.CONCENTRATION_TRACKER_LABEL_MAX] = "Maximal",
        [CraftSim.CONST.TEXT.CONCENTRATION_TRACKER_MAX] = f.g("MAX"),
        [CraftSim.CONST.TEXT.CONCENTRATION_TRACKER_MAX_VALUE] = "Maximal: ",
        [CraftSim.CONST.TEXT.CONCENTRATION_TRACKER_FULL] = f.g("Konzentration voll"),
        [CraftSim.CONST.TEXT.CONCENTRATION_TRACKER_SORT_MODE_CHARACTER] = "Charakter",
        [CraftSim.CONST.TEXT.CONCENTRATION_TRACKER_SORT_MODE_CONCENTRATION] = "Konzentration",
        [CraftSim.CONST.TEXT.CONCENTRATION_TRACKER_SORT_MODE_PROFESSION] = "Beruf",
        [CraftSim.CONST.TEXT.CONCENTRATION_TRACKER_FORMAT_MODE_EUROPE_MAX_DATE] = "Europa - Max Datum",
        [CraftSim.CONST.TEXT.CONCENTRATION_TRACKER_FORMAT_MODE_AMERICA_MAX_DATE] = "Amerika - Max Datum",
        [CraftSim.CONST.TEXT.CONCENTRATION_TRACKER_FORMAT_MODE_HOURS_LEFT] = "Verbleibende Stunden",

        -- statische Popups
        [CraftSim.CONST.TEXT.STATIC_POPUPS_YES] = "Ja",
        [CraftSim.CONST.TEXT.STATIC_POPUPS_NO] = "Nein",

        -- frames
        [CraftSim.CONST.TEXT.FRAMES_RESETTING] = "Zurücksetzen von Frame-ID: ",
        [CraftSim.CONST.TEXT.FRAMES_WHATS_NEW] = "Was gibt's Neues bei CraftSim?",
        [CraftSim.CONST.TEXT.FRAMES_JOIN_DISCORD] = "Tritt dem Discord bei!",
        [CraftSim.CONST.TEXT.FRAMES_DONATE_KOFI] = "Besuche CraftSim auf Kofi",
        [CraftSim.CONST.TEXT.FRAMES_NO_INFO] = "Keine Informationen",

        -- node data
        [CraftSim.CONST.TEXT.NODE_DATA_RANK_TEXT] = "Rang ",
        [CraftSim.CONST.TEXT.NODE_DATA_TOOLTIP] = "\n\nGesamtwerte aus Talent:\n",

        -- columns
        [CraftSim.CONST.TEXT.SOURCE_COLUMN_AH] = "AH",
        [CraftSim.CONST.TEXT.SOURCE_COLUMN_OVERRIDE] = "ÜS",
        [CraftSim.CONST.TEXT.SOURCE_COLUMN_WO] = "WO",

    }
end
