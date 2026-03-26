---@class CraftSim
local CraftSim = select(2, ...)

CraftSim.LOCAL_DE = {}

---@return table<CraftSim.LOCALIZATION_IDS, string>
function CraftSim.LOCAL_DE:GetData()
    local f = CraftSim.GUTIL:GetFormatter()
    local cm = function(i, s) return CraftSim.MEDIA:GetAsTextIcon(i, s) end
    return {
        -- ERFORDERLICH:
        STAT_MULTICRAFT = "Mehrfachherstellung",
        STAT_RESOURCEFULNESS = "Einfallsreichtum",
        STAT_INGENUITY = "Genialität",
        STAT_CRAFTINGSPEED = "Herstellungsgeschwindigkeit",
        EQUIP_MATCH_STRING = "Anlegen:",
        ENCHANTED_MATCH_STRING = "Verzaubert:",

        -- OPTIONAL (Defaulting to EN if not available):

        -- gemeinsame Berufs-CDs
        DF_ALCHEMY_TRANSMUTATIONS = "DF - Transmutationen",

        -- Erweiterungen

        EXPANSION_VANILLA = "Classic",
        EXPANSION_THE_BURNING_CRUSADE = "The Burning Crusade",
        EXPANSION_WRATH_OF_THE_LICH_KING = "Wrath of the Lich King",
        EXPANSION_CATACLYSM = "Cataclysm",
        EXPANSION_MISTS_OF_PANDARIA = "Mists of Pandaria",
        EXPANSION_WARLORDS_OF_DRAENOR = "Warlords of Draenor",
        EXPANSION_LEGION = "Legion",
        EXPANSION_BATTLE_FOR_AZEROTH = "Battle of Azeroth",
        EXPANSION_SHADOWLANDS = "Shadowlands",
        EXPANSION_DRAGONFLIGHT = "Dragonflight",
        EXPANSION_THE_WAR_WITHIN = "The War Within",

        -- Berufe

        PROFESSIONS_BLACKSMITHING = "Schmiedekunst",
        PROFESSIONS_LEATHERWORKING = "Lederverarbeitung",
        PROFESSIONS_ALCHEMY = "Alchemie",
        PROFESSIONS_HERBALISM = "Kräuterkunde",
        PROFESSIONS_COOKING = "Kochkunst",
        PROFESSIONS_MINING = "Bergbau",
        PROFESSIONS_TAILORING = "Schneiderei",
        PROFESSIONS_ENGINEERING = "Ingenieurskunst",
        PROFESSIONS_ENCHANTING = "Verzauberkunst",
        PROFESSIONS_FISHING = "Angeln",
        PROFESSIONS_SKINNING = "Kürschnerei",
        PROFESSIONS_JEWELCRAFTING = "Juwelierskunst",
        PROFESSIONS_INSCRIPTION = "Inschriftenkunde",

        -- Andere Statnamen

        STAT_SKILL = "Fertigkeit",
        STAT_MULTICRAFT_BONUS = "Mehrfachherstellung Extra-Gegenstände",
        STAT_RESOURCEFULNESS_BONUS = "Einfallsreichtum Extra-Gegenstände",
        STAT_CRAFTINGSPEED_BONUS = "Herstellungsgeschwindigkeit",
        STAT_INGENUITY_BONUS = "Genialität spart Konzentration",
        STAT_INGENUITY_LESS_CONCENTRATION = "Weniger Konzentrationsverbrauch",
        STAT_PHIAL_EXPERIMENTATION = "Durchbruch bei Phiolen",
        STAT_POTION_EXPERIMENTATION = "Durchbruch bei Tränken",

        -- Gewinnaufschlüsselung Tooltips
        RESOURCEFULNESS_EXPLANATION_TOOLTIP =
        "Einfallsreichtum proct für jedes Reagenz einzeln und spart dann etwa 30 % der Menge.\n\nDer durchschnittliche Wert, den es spart, ist der durchschnittliche gesparte Wert aller Kombinationen und deren Chancen.\n(Dass alle Reagenzien gleichzeitig proccen, ist sehr unwahrscheinlich, spart aber viel.)\n\nDie durchschnittlichen Gesamtkosten der gesparten Reagenzien sind die Summe der gesparten Reagenzkosten aller Kombinationen, gewichtet nach deren Wahrscheinlichkeit.",
        RECIPE_DIFFICULTY_EXPLANATION_TOOLTIP =
        "Die Rezeptschwierigkeit bestimmt, wo die Schwellenwerte der verschiedenen Qualitäten liegen.\n\nBei Rezepten mit fünf Qualitätsstufen liegen diese bei 20 %, 50 %, 80 % und 100 % der Rezeptschwierigkeit als Fertigkeit.\nBei Rezepten mit drei Qualitätsstufen liegen sie bei 50 % und 100 %.",
        MULTICRAFT_EXPLANATION_TOOLTIP =
        "Mehrfachherstellung gibt dir eine Chance, mehr Gegenstände herzustellen, als du normalerweise mit einem Rezept produzieren würdest.\n\nDie zusätzliche Menge liegt normalerweise zwischen 1 und 2,5y,\nwobei y = die übliche Menge ist, die eine Herstellung ergibt.",
        REAGENTSKILL_EXPLANATION_TOOLTIP =
        "Die Qualität deiner Reagenzien kann dir bis zu 40 % der Grundrezeptschwierigkeit als Bonusfertigkeit geben.\n\nAlle Q1-Reagenzien: 0% Bonus\nAlle Q2-Reagenzien: 20% Bonus\nAlle Q3-Reagenzien: 40% Bonus\n\nDie Fertigkeit wird durch die Menge der Reagenzien jeder Qualität berechnet, gewichtet nach ihrer Qualität\nund einem spezifischen Gewichtswert, der für jedes handwerkliche Reagenz mit Qualität einzigartig ist.\n\nDies ist jedoch bei Neuanfertigungen anders. Dort hängt die maximale Qualitätssteigerung durch die Reagenzien davon ab,\nmit welcher Reagenzienqualität der Gegenstand ursprünglich hergestellt wurde.\nDie genauen Mechanismen sind nicht bekannt.\nCraftSim vergleicht jedoch intern die erreichte Fertigkeit mit allen Q3-Reagenzien\nund berechnet den maximalen Fertigkeitsanstieg basierend darauf.",
        REAGENTFACTOR_EXPLANATION_TOOLTIP =
        "Der maximale Beitrag der Reagenzien zu einem Rezept beträgt meistens 40 % der Grundrezept-Schwierigkeit.\n\nIm Falle einer Neuanfertigung kann dieser Wert jedoch je nach vorherigen Anfertigungen\nund der Qualität der verwendeten Reagenzien variieren.",

        -- Simulationsmodus
        SIMULATION_MODE_NONE = "Keine",
        SIMULATION_MODE_LABEL = "Simulationsmodus",
        SIMULATION_MODE_TITLE = "CraftSim-Simulationsmodus",
        SIMULATION_MODE_TOOLTIP =
        "Der CraftSim-Simulationsmodus ermöglicht es, ohne Einschränkungen mit einem Rezept herumzuspielen.",
        SIMULATION_MODE_OPTIONAL = "Optional #",
        SIMULATION_MODE_FINISHING = "Abschluss #",
        SIMULATION_MODE_QUALITY_BUTTON_TOOLTIP = "Max Menge an Reagenzien der Qualität ",
        SIMULATION_MODE_CLEAR_BUTTON = "Löschen",
        SIMULATION_MODE_CONCENTRATION = " Konzentration",
        SIMULATION_MODE_CONCENTRATION_COST = "Kosten der Konzentration: ",
        CONCENTRATION_ESTIMATED_TIME_UNTIL = "Herstellbar um: %s",

        -- Detailfenster
        RECIPE_DIFFICULTY_LABEL = "Rezeptschwierigkeit: ",
        MULTICRAFT_LABEL = "Mehrfachherstellung: ",
        RESOURCEFULNESS_LABEL = "Einfallsreichtum: ",
        RESOURCEFULNESS_BONUS_LABEL = "Einfallsreichtum-Gegenstandsbonus: ",
        CONCENTRATION_LABEL = "Konzentration: ",
        REAGENT_QUALITY_BONUS_LABEL = "Qualitätsbonus für Reagenzien: ",
        REAGENT_QUALITY_MAXIMUM_LABEL = "Reagenzienqualität Maximum %:: ",

        EXPECTED_QUALITY_LABEL = "Erwartete Qualität: ",
        NEXT_QUALITY_LABEL = "Nächste Qualität: ",
        MISSING_SKILL_LABEL = "Fehlende Fertigkeit: ",
        SKILL_LABEL = "Fertigkeit: ",
        MULTICRAFT_BONUS_LABEL = "Gegenstandsbonus für Mehrfachherstellung: ",

        -- Statistiken
        STATISTICS_CDF_EXPLANATION =
        "Dies wird durch die 'Abramowitz und Stegun' Näherung (1985) der CDF (Kumulative Verteilungsfunktion) berechnet.\n\nDu wirst feststellen, dass es bei einer Herstellung immer um die 50 % liegt.\nDas liegt daran, dass 0 meistens nahe am durchschnittlichen Gewinn liegt.\nUnd die Wahrscheinlichkeit, den Mittelwert der CDF zu erreichen, beträgt immer 50 %.\n\nAllerdings kann die Änderungsrate zwischen Rezepten sehr unterschiedlich sein.\nWenn es wahrscheinlicher ist, einen positiven Gewinn als einen negativen zu erzielen, wird sie stetig ansteigen.\nDies gilt natürlich auch für die entgegengesetzte Richtung.",
        EXPLANATIONS_PROFIT_CALCULATION_EXPLANATION =
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
        POPUP_NO_PRICE_SOURCE_SYSTEM = "Keine unterstützte Preisquelle verfügbar!",
        POPUP_NO_PRICE_SOURCE_TITLE = "CraftSim Preisquellenwarnung",
        POPUP_NO_PRICE_SOURCE_WARNING =
        "Keine Preisquelle gefunden!\n\nDu musst mindestens eines der\nfolgenden Preisquellen-Addons installiert haben, um\ndie Gewinnberechnungen von CraftSim zu nutzen:\n\n\n",
        POPUP_NO_PRICE_SOURCE_WARNING_SUPPRESS = "Warnung nicht mehr anzeigen",
        POPUP_NO_PRICE_SOURCE_WARNING_ACCEPT = "OK",

        -- Materialfenster
        REAGENT_OPTIMIZATION_TITLE = "CraftSim Reagenzien Optimierung",
        REAGENTS_REACHABLE_QUALITY = "Erreichbare Qualität: ",
        REAGENTS_MISSING = "Reagenzien fehlen",
        REAGENTS_AVAILABLE = "Reagenzien verfügbar",
        REAGENTS_CHEAPER = "Günstigste Reagenzien",
        REAGENTS_BEST_COMBINATION = "Beste Kombination zugewiesen",
        REAGENTS_NO_COMBINATION = "Keine Kombination gefunden,\num die Qualität zu erhöhen",
        REAGENTS_ASSIGN = "Zuweisen",
        REAGENTS_MAXIMUM_QUALITY = "Maximale Qualität: ",
        REAGENTS_AVERAGE_PROFIT_LABEL = "Ø Gewinn: ",
        REAGENTS_AVERAGE_PROFIT_TOOLTIP =
            f.bb("Der durchschnittliche Gewinn pro Herstellung") ..
            " bei Verwendung von " .. f.l("dieser Reagenzienverteilung"),
        REAGENTS_OPTIMIZE_BEST_ASSIGNED = "Beste Reagenzien zugewiesen",
        REAGENTS_CONCENTRATION_LABEL = "Konzentration: ",
        REAGENTS_OPTIMIZE_INFO =
        "Shift + LMT auf die Zahlen, um den Gegenstandslink in den Chat einzufügen",
        ADVANCED_OPTIMIZATION_BUTTON = "Optimieren",
        REAGENTS_OPTIMIZE_TOOLTIP =
            f.r("Experimentell: ") ..
            "Leistungsintensiv und wird bei Änderungen zurückgesetzt.\nOptimiert für den " ..
            f.gold("höchsten Goldwert") .. " pro Konzentrationspunkt",

        -- Spezialisierungs-Infofenster
        SPEC_INFO_TITLE = "CraftSim Spezialisierungsinfo",
        SPEC_INFO_SIMULATE_KNOWLEDGE_DISTRIBUTION = "Wissenverteilung simulieren",
        SPEC_INFO_NODE_TOOLTIP = "Dieser Knoten gewährt dir folgende Werte für dieses Rezept:",
        SPEC_INFO_WORK_IN_PROGRESS = "Spezialisierungsinfo\nIn Arbeit",

        -- Herstellungs-Ergebnisse-Fenster
        CRAFT_LOG_TITLE = "CraftSim Herstellungsergebnisse",
        CRAFT_LOG_LOG = "Herstellungsprotokoll",
        CRAFT_LOG_LOG_1 = "Gewinn: ",
        CRAFT_LOG_LOG_2 = "Inspiriert!",
        CRAFT_LOG_LOG_3 = "Mehrfachherstellung: ",
        CRAFT_LOG_LOG_4 = "Ressourcen gespart!: ",
        CRAFT_LOG_LOG_5 = "Chance: ",
        CRAFT_LOG_CRAFTED_ITEMS = "Herstellte Gegenstände",
        CRAFT_LOG_SESSION_PROFIT = "Sitzungsgewinn",
        CRAFT_LOG_RESET_DATA = "Daten zurücksetzen",
        CRAFT_LOG_EXPORT_JSON = "JSON exportieren",
        CRAFT_LOG_RECIPE_STATISTICS = "Rezeptstatistiken",
        CRAFT_LOG_NOTHING = "Noch nichts hergestellt!",
        CRAFT_LOG_CALCULATION_COMPARISON_NUM_CRAFTS_PREFIX = "Herstellungen: ",
        CRAFT_LOG_STATISTICS_2 = "Erwarteter Ø Gewinn: ",
        CRAFT_LOG_STATISTICS_3 = "Realer Ø Gewinn: ",
        CRAFT_LOG_STATISTICS_4 = "Realer Gewinn: ",
        CRAFT_LOG_STATISTICS_5 = "Procs - Real / Erwartet: ",
        CRAFT_LOG_STATISTICS_7 = "Mehrfachherstellung: ",
        CRAFT_LOG_STATISTICS_8 = "- Ø Zusätzliche Gegenstände: ",
        CRAFT_LOG_STATISTICS_9 = "Einfallsreichtum Procs: ",
        CRAFT_LOG_CALCULATION_COMPARISON_NUM_CRAFTS_PREFIX0 = "- Ø Gesparte Kosten: ",
        CRAFT_LOG_CALCULATION_COMPARISON_NUM_CRAFTS_PREFIX1 = "Gewinn: ",
        CRAFT_LOG_SAVED_REAGENTS = "Gespeicherte Reagenzien",
        CRAFT_LOG_DISABLE_CHECKBOX = f.l(
            "Herstellungsergebnisse deaktivieren"),
        CRAFT_LOG_DISABLE_CHECKBOX_TOOLTIP =
            "Wenn aktiviert, wird die Aufzeichnung von Herstellungsergebnissen beim Herstellen gestoppt und kann die " ..
            f.g("Leistung verbessern"),
        CRAFT_LOG_RESULT_ANALYSIS_TAB_DISTRIBUTION_LABEL = "Ergebnisverteilung",
        CRAFT_LOG_RESULT_ANALYSIS_TAB_DISTRIBUTION_HELP =
        "Relative Verteilung der hergestellten Gegenstandsergebnisse (Mehrfachherstellungs-Mengen werden ignoriert)",
        CRAFT_LOG_RESULT_ANALYSIS_TAB_MULTICRAFT = "Mehrfachherstellung",
        CRAFT_LOG_RESULT_ANALYSIS_TAB_RESOURCEFULNESS = "Einfallsreichtum",
        CRAFT_LOG_RESULT_ANALYSIS_TAB_YIELD_DDISTRIBUTION = "Ertragsverteilung",

        -- Statgewichtungsfenster
        STAT_WEIGHTS_TITLE = "CraftSim Durchschnittlicher Gewinn",
        EXPLANATIONS_TITLE = "CraftSim Erklärung zum Durchschnittlichen Gewinn",
        STAT_WEIGHTS_SHOW_EXPLANATION_BUTTON = "Erklärung anzeigen",
        STAT_WEIGHTS_HIDE_EXPLANATION_BUTTON = "Erklärung verbergen",
        STAT_WEIGHTS_SHOW_STATISTICS_BUTTON = "Statistiken anzeigen",
        STAT_WEIGHTS_HIDE_STATISTICS_BUTTON = "Statistiken verbergen",
        STAT_WEIGHTS_PROFIT_CRAFT = "Ø Gewinn / Herstellung: ",
        EXPLANATIONS_BASIC_PROFIT_TAB = "Grundlegende Gewinnberechnung",

        -- Kostendetailsfenster
        COST_OPTIMIZATION_TITLE = "CraftSim Kostenoptimierung",
        COST_OPTIMIZATION_EXPLANATION =
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
        COST_OPTIMIZATION_CRAFTING_COSTS = "Herstellungskosten: ",
        COST_OPTIMIZATION_ITEM_HEADER = "Item",

        COST_OPTIMIZATION_AH_PRICE_HEADER = "AH-Preis",
        COST_OPTIMIZATION_OVERRIDE_HEADER = "Überschreibung",
        COST_OPTIMIZATION_CRAFTING_HEADER = "Herstellung",
        COST_OPTIMIZATION_USED_SOURCE = "Verwendete Quelle",
        COST_OPTIMIZATION_REAGENT_COSTS_TAB = "Reagenzienkosten",
        COST_OPTIMIZATION_SUB_RECIPE_OPTIONS_TAB = "Unterrezept Optionen",
        COST_OPTIMIZATION_SUB_RECIPE_OPTIMIZATION = "Unterrezept Optimierung " ..
            f.bb("(experimentell)"),
        COST_OPTIMIZATION_SUB_RECIPE_OPTIMIZATION_TOOLTIP = "Wenn aktiviert, berücksichtigt " ..
            f.l("CraftSim") .. " die " .. f.g("optimierten Herstellungskosten") ..
            " deines Charakters und deiner Twinks,\nwenn sie in der Lage sind, diesen Gegenstand herzustellen.\n\n" ..
            f.r("Dies könnte die Leistung etwas verringern, da viele zusätzliche Berechnungen durchgeführt werden."),
        COST_OPTIMIZATION_SUB_RECIPE_MAX_DEPTH_LABEL = "Berechnungstiefe des Unterrezepts",
        COST_OPTIMIZATION_SUB_RECIPE_INCLUDE_CONCENTRATION = "Konzentration aktivieren",
        COST_OPTIMIZATION_SUB_RECIPE_INCLUDE_CONCENTRATION_TOOLTIP =
            "Wenn aktiviert, berücksichtigt " ..
            f.l("CraftSim") .. " die Reagenzienqualität, selbst wenn Konzentration erforderlich ist.",
        COST_OPTIMIZATION_SUB_RECIPE_INCLUDE_COOLDOWN_RECIPES = "Abklingzeit Rezepte einbeziehen",
        COST_OPTIMIZATION_SUB_RECIPE_INCLUDE_COOLDOWN_RECIPES_TOOLTIP =
            "Wenn aktiviert, ignoriert " ..
            f.l("CraftSim") .. " die Abklingzeiten von Rezepten bei der Berechnung selbst hergestellter Reagenzien.",

        COST_OPTIMIZATION_SUB_RECIPE_SELECT_RECIPE_CRAFTER = "Rezepthersteller auswählen",
        COST_OPTIMIZATION_REAGENT_LIST_AH_COLUMN_AUCTION_BUYOUT = "Auktions Sofortkauf: ",
        COST_OPTIMIZATION_REAGENT_LIST_OVERRIDE = "\n\nÜberschreiben",
        COST_OPTIMIZATION_REAGENT_LIST_EXPECTED_COSTS_TOOLTIP = "\n\nHerstellung",
        COST_OPTIMIZATION_REAGENT_LIST_EXPECTED_COSTS_PRE_ITEM =
        "\n- Erwartete Kosten pro Gegenstand: ",
        COST_OPTIMIZATION_REAGENT_LIST_CONCENTRATION_COST = f.gold("Kosten der Konzentration: "),
        COST_OPTIMIZATION_REAGENT_LIST_CONCENTRATION = "Konzentration: ",

        -- Statistikfenster
        STATISTICS_TITLE = "CraftSim Statistiken",
        STATISTICS_EXPECTED_PROFIT = "Erwarteter Gewinn (μ)",
        STATISTICS_CHANCE_OF = "Chance auf ",
        STATISTICS_PROFIT = "Gewinn",
        STATISTICS_AFTER = " nach",
        STATISTICS_CRAFTS = "Herstellungen: ",
        STATISTICS_QUALITY_HEADER = "Qualität",
        STATISTICS_MULTICRAFT_HEADER = "Mehrfach\nherstellung",

        STATISTICS_RESOURCEFULNESS_HEADER = "Einfallsreichtum",
        STATISTICS_EXPECTED_PROFIT_HEADER = "Erwarteter Gewinn",
        PROBABILITY_TABLE_TITLE = "Rezeptwahrscheinlichkeitstabelle",
        STATISTICS_PROBABILITY_TABLE_TAB = "Wahrscheinlichkeits-Tabelle",
        STATISTICS_CONCENTRATION_TAB = "Konzentration",
        STATISTICS_CONCENTRATION_CURVE_GRAPH = "Kostenkurve der Konzentration",
        STATISTICS_CONCENTRATION_CURVE_GRAPH_HELP =
            "Konzentrationskosten basierend auf Spielerfertigkeit für das gegebene Rezept\n" ..
            f.bb("X Achse: ") .. " Spielerfertigkeit\n" ..
            f.bb("Y Achse: ") .. " Konzentrationskosten",

        -- Preisdetailsfenster
        COST_OVERVIEW_TITLE = "CraftSim Preisdaten",
        PRICE_DETAILS_INV_AH = "Inventar/AH",
        PRICE_DETAILS_ITEM = "Gegen\nstand",
        PRICE_DETAILS_PRICE_ITEM = "Preis/Gegenstand",
        PRICE_DETAILS_PROFIT_ITEM = "Gewinn/Gegenstand",

        -- Preisüberschreibungsfenster
        PRICE_OVERRIDE_TITLE = "CraftSim Preisüberschreibungen",
        PRICE_OVERRIDE_REQUIRED_REAGENTS = "Erforderliche Reagenzien",
        PRICE_OVERRIDE_OPTIONAL_REAGENTS = "Optionale Reagenzien",
        PRICE_OVERRIDE_FINISHING_REAGENTS = "Abschlussreagenzien",
        PRICE_OVERRIDE_RESULT_ITEMS = "Ergebnisgegenstände",
        PRICE_OVERRIDE_ACTIVE_OVERRIDES = "Aktive Überschreibungen",
        PRICE_OVERRIDE_ACTIVE_OVERRIDES_TOOLTIP =
        "'(als Ergebnis)' -> Preisüberschreibung wird nur berücksichtigt, wenn der Gegenstand das Ergebnis eines Rezepts ist",
        PRICE_OVERRIDE_CLEAR_ALL = "Alles löschen",
        PRICE_OVERRIDE_SAVE = "Speichern",
        PRICE_OVERRIDE_SAVED = "Gespeichert",
        PRICE_OVERRIDE_REMOVE = "Entfernen",

        -- Rezept-Scan-Fenster
        RECIPE_SCAN_TITLE = "CraftSim Rezept-Scan",
        RECIPE_SCAN_MODE = "Scanmodus",
        RECIPE_SCAN_SORT_MODE = "Sortiermodus",
        RECIPE_SCAN_SCAN_RECIPIES = "Rezepte scannen",
        RECIPE_SCAN_SCAN_CANCEL = "Abbrechen",
        RECIPE_SCAN_SCANNING = "Scannen",
        RECIPE_SCAN_INCLUDE_NOT_LEARNED = "Nicht erlernte einbeziehen",
        RECIPE_SCAN_INCLUDE_NOT_LEARNED_TOOLTIP =
        "Füge nicht erlernte Rezepte in den Rezept-Scan ein",
        RECIPE_SCAN_INCLUDE_SOULBOUND = "Seelengebunden einbeziehen",
        RECIPE_SCAN_INCLUDE_SOULBOUND_TOOLTIP =
        "Seelengebundene Rezepte in den Rezept-Scan einbeziehen.\n\nEs wird empfohlen, eine Preisüberschreibung festzulegen (z.B. um eine Zielprovision zu simulieren)\nim Preisüberschreibungsmodul für die hergestellten Gegenstände dieses Rezepts",
        RECIPE_SCAN_INCLUDE_GEAR = "Ausrüstung einbeziehen",
        RECIPE_SCAN_INCLUDE_GEAR_TOOLTIP =
        "Alle Arten von Ausrüstungsrezepten in den Rezept-Scan einbeziehen",
        RECIPE_SCAN_OPTIMIZE_TOOLS = "Berufswerkzeuge optimieren",
        RECIPE_SCAN_OPTIMIZE_TOOLS_TOOLTIP =
        "Optimiere für jedes Rezept deine Berufswerkzeuge für den Gewinn\n\n",
        RECIPE_SCAN_OPTIMIZE_TOOLS_WARNING =
        "Könnte die Leistung während des Scans beeinträchtigen,\nwenn du viele Werkzeuge in deinem Inventar hast",
        RECIPE_SCAN_CRAFTER_HEADER = "Handwerker",
        RECIPE_SCAN_RECIPE_HEADER = "Rezept",
        RECIPE_SCAN_LEARNED_HEADER = "Erlernt",
        RECIPE_SCAN_RESULT_HEADER = "Ergeb\nnis",

        RECIPE_SCAN_AVERAGE_PROFIT_HEADER = "Durchschnittlicher Gewinn",
        RECIPE_SCAN_CONCENTRATION_VALUE_HEADER = "Konz.-Wert",
        RECIPE_SCAN_CONCENTRATION_COST_HEADER = "Konz.-Kosten",
        RECIPE_SCAN_TOP_GEAR_HEADER = "Beste Ausrüstung",
        RECIPE_SCAN_INV_AH_HEADER = "Inventar/AH",
        RECIPE_SCAN_SORT_BY_MARGIN = "Nach Gewinn % sortieren",
        RECIPE_SCAN_SORT_BY_MARGIN_TOOLTIP =
        "Sortiere die Gewinnliste nach Gewinn relativ zu den Herstellungskosten.\n(Ein neuer Scan ist erforderlich)",
        RECIPE_SCAN_USE_INSIGHT_CHECKBOX = "Verwenden " .. f.bb("Erkenntnis") .. " wenn möglich",
        RECIPE_SCAN_USE_INSIGHT_CHECKBOX_TOOLTIP = "Verwende " ..
            f.bb("Illustre Erkenntnis") ..
            " oder\n" .. f.bb("Geringe illustre Erkenntnis") .. " als optionales Reagenz für Rezepte, die dies zulassen.",
        RECIPE_SCAN_ONLY_FAVORITES_CHECKBOX = "Nur Favoriten",
        RECIPE_SCAN_ONLY_FAVORITES_CHECKBOX_TOOLTIP = "Scanne nur deine Lieblingsrezepte",
        RECIPE_SCAN_EQUIPPED = "Ausgerüstet",

        RECIPE_SCAN_MODE_OPTIMIZE = "Reagenzien optimieren",
        RECIPE_SCAN_SORT_MODE_PROFIT = "Gewinn",
        RECIPE_SCAN_SORT_MODE_RELATIVE_PROFIT = "Relativer Gewinn",
        RECIPE_SCAN_SORT_MODE_CONCENTRATION_VALUE = "Konzentrationswert",
        RECIPE_SCAN_SORT_MODE_CONCENTRATION_COST = "Konzentrationskosten",
        RECIPE_SCAN_EXPANSION_FILTER_BUTTON = "Erweiterungen",
        RECIPE_SCAN_ALTPROFESSIONS_FILTER_BUTTON = "Alt-Berufe",
        RECIPE_SCAN_SCAN_ALL_BUTTON_READY = "Berufe scannen",
        RECIPE_SCAN_SCAN_ALL_BUTTON_SCANNING = "Scannen...",
        RECIPE_SCAN_TAB_LABEL_SCAN = "Rezept-Scan",
        RECIPE_SCAN_TAB_LABEL_OPTIONS = "Scan-Optionen",
        RECIPE_SCAN_IMPORT_ALL_PROFESSIONS_CHECKBOX_LABEL = "Alle gescannten Berufe",
        RECIPE_SCAN_IMPORT_ALL_PROFESSIONS_CHECKBOX_TOOLTIP = f.g("Wahr: ") ..
            "Importiere Scan-Ergebnisse von allen aktivierten und gescannten Berufen\n\n" ..
            f.r("Falsch: ") .. "Importiere Scan-Ergebnisse nur vom aktuell ausgewählten Beruf",
        RECIPE_SCAN_CACHED_RECIPES_TOOLTIP =
            "Jedes Mal, wenn du ein Rezept auf einem Charakter öffnest oder scannst, " ..
            f.l("CraftSim") ..
            " merkt es sich.\n\nNur Rezepte deiner Alts, die " ..
            f.l("CraftSim") .. " sich merken kann, werden mit " .. f.bb("RecipeScan\n\n") ..
            "gescannt. Die tatsächliche Anzahl der gescannten Rezepte basiert dann auf deinen " ..
            f.e("Rezept-Scan-Optionen"),
        RECIPE_SCAN_CONCENTRATION_TOGGLE = " Konzentration",
        RECIPE_SCAN_CONCENTRATION_TOGGLE_TOOLTIP = "Konzentration umschalten",
        RECIPE_SCAN_OPTIMIZE_SUBRECIPES = "Unterrezepte optimieren " .. f.bb("(experimentell)"),
        RECIPE_SCAN_OPTIMIZE_SUBRECIPES_TOOLTIP = "Wenn aktiviert, optimiert " ..
            f.l("CraftSim") ..
            " auch die Herstellung von zwischengespeicherten Reagenz-Rezepten der gescannten Rezepte und verwendet ihre\n" ..
            f.bb("erwarteten Kosten") .. ", um die Herstellungskosten für das Endprodukt zu berechnen.\n\n" ..
            f.r("Warnung: Dies könnte die Scan-Leistung verringern"),
        RECIPE_SCAN_CACHED_RECIPES = "Zwischengespeicherte Rezepte: ",
        RECIPE_SCAN_ENABLE_CONCENTRATION = "Enable Concentration",
        RECIPE_SCAN_ONLY_FAVORITES = "Only Favorites",
        RECIPE_SCAN_INCLUDE_SOULBOUND_ITEMS = "Include Soulbound Items",
        RECIPE_SCAN_INCLUDE_UNLEARNED_RECIPES = "Include Unlearned Recipes",
        RECIPE_SCAN_INCLUDE_GEAR_LABEL = "Include Gear",
        RECIPE_SCAN_REAGENT_ALLOCATION = "Reagent Allocation",
        RECIPE_SCAN_REAGENT_ALLOCATION_Q1 = "All Q1",
        RECIPE_SCAN_REAGENT_ALLOCATION_Q2 = "All Q2",
        RECIPE_SCAN_REAGENT_ALLOCATION_Q3 = "All Q3",
        RECIPE_SCAN_AUTOSELECT_TOP_PROFIT = "Autoselect Top Profit Quality",
        RECIPE_SCAN_OPTIMIZE_PROFESSION_GEAR = "Optimize Profession Gear",
        RECIPE_SCAN_OPTIMIZE_CONCENTRATION = "Optimize Concentration",
        RECIPE_SCAN_OPTIMIZE_FINISHING_REAGENTS = "Optimize Finishing Reagents",
        OPTIMIZATION_OPTIONS_OPTIMIZE_PROFESSION_TOOLS = "Optimize Profession Tools",
        OPTIMIZATION_OPTIONS_INCLUDE_SOULBOUND_FINISHING_REAGENTS = "Include Soulbound Finishing Reagents",
        RECIPE_SCAN_AUTOSELECT_OPEN_PROFESSION = "Autoselect Open Profession",


        -- Rezept-Beste Ausrüstung
        TOP_GEAR_TITLE = "CraftSim Beste Ausrüstung",
        TOP_GEAR_AUTOMATIC = "Automatisch",
        TOP_GEAR_AUTOMATIC_TOOLTIP =
        "Simuliere automatisch die Beste Ausrüstung für deinen ausgewählten Modus, wann immer ein Rezept aktualisiert wird.\n\nDas Deaktivieren kann die Leistung verbessern.",
        TOP_GEAR_SIMULATE = "Beste Ausrüstung simulieren",
        TOP_GEAR_EQUIP = "Anlegen",
        TOP_GEAR_SIMULATE_QUALITY = "Qualität: ",
        TOP_GEAR_SIMULATE_EQUIPPED = "Beste Ausrüstung angelegt",
        TOP_GEAR_SIMULATE_PROFIT_DIFFERENCE = "Ø Gewinnunterschied\n",
        TOP_GEAR_SIMULATE_NEW_MUTLICRAFT = "Neue Mehrfachherstellung\n",
        TOP_GEAR_SIMULATE_NEW_CRAFTING_SPEED = "Neue Herstellungsgeschwindigkeit\n",
        TOP_GEAR_SIMULATE_NEW_RESOURCEFULNESS = "Neuer Einfallsreichtum\n",
        TOP_GEAR_SIMULATE_NEW_SKILL = "Neue Fertigkeit\n",
        TOP_GEAR_SIMULATE_UNHANDLED = "Ungehandelter Simulationsmodus",

        TOP_GEAR_SIM_MODES_PROFIT = "Höchster Gewinn",
        TOP_GEAR_SIM_MODES_SKILL = "Höchste Fertigkeit",
        TOP_GEAR_SIM_MODES_MULTICRAFT = "Beste Mehrfachherstellung",
        TOP_GEAR_SIM_MODES_RESOURCEFULNESS = "Bester Einfallsreichtum",
        TOP_GEAR_SIM_MODES_CRAFTING_SPEED = "Beste Herstellungsgeschwindigkeit",

        -- Optionen
        OPTIONS_TITLE = "CraftSim Optionen",
        OPTIONS_GENERAL_TAB = "Allgemein",
        OPTIONS_GENERAL_PRICE_SOURCE = "Preisquelle",
        OPTIONS_GENERAL_CURRENT_PRICE_SOURCE = "Aktuelle Preisquelle: ",
        OPTIONS_GENERAL_NO_PRICE_SOURCE = "Kein unterstütztes Preisquellen-Addon geladen!",
        OPTIONS_GENERAL_SHOW_PROFIT = "Gewinnprozentsatz anzeigen",
        OPTIONS_GENERAL_SHOW_PROFIT_TOOLTIP =
        "Zeige den Prozentsatz des Gewinns zu den Herstellungskosten neben dem Goldwert an",
        OPTIONS_GENERAL_REMEMBER_LAST_RECIPE = "Letztes Rezept merken",
        OPTIONS_GENERAL_REMEMBER_LAST_RECIPE_TOOLTIP =
        "Öffne das zuletzt ausgewählte Rezept beim Öffnen des Herstellungsfensters erneut",
        OPTIONS_GENERAL_SUPPORTED_PRICE_SOURCES = "Unterstützte Preisquellen:",
        OPTIONS_PERFORMANCE_RAM = "RAM Bereinigung beim Herstellen aktivieren",
        OPTIONS_PERFORMANCE_RAM_CRAFTS = "Herstellungen",

        OPTIONS_PERFORMANCE_RAM_TOOLTIP =
        "Wenn aktiviert, wird CraftSim dein RAM nach einer bestimmten Anzahl von Herstellungen von ungenutzten Daten bereinigen, um zu verhindern, dass sich der Speicher ansammelt.\nSpeicheraufbau kann auch durch andere Addons verursacht werden und ist nicht CraftSim-spezifisch.\nEine Bereinigung betrifft die gesamte WoW-RAM-Nutzung.",
        OPTIONS_MODULES_TAB = "Module",
        OPTIONS_PROFIT_CALCULATION_TAB = "Gewinnberechnung",
        OPTIONS_CRAFTING_TAB = "Herstellung",
        OPTIONS_TSM_RESET = "Zurücksetzen auf Standard",
        OPTIONS_TSM_INVALID_EXPRESSION = "Ungültiger Ausdruck",
        OPTIONS_TSM_VALID_EXPRESSION = "Gültiger Ausdruck",
        OPTIONS_MODULES_REAGENT_OPTIMIZATION = "Modul zur Reagenzien Optimierung",

        OPTIONS_MODULES_AVERAGE_PROFIT = "Durchschnittsgewinnmodul",
        OPTIONS_MODULES_TOP_GEAR = "Modul Beste Ausrüstung",
        OPTIONS_MODULES_COST_OVERVIEW = "Kostenübersichtsmodul",
        OPTIONS_MODULES_SPECIALIZATION_INFO = "Spezialisierungsinfo-Modul",
        OPTIONS_MODULES_CUSTOMER_HISTORY_SIZE =
        "Maximale Nachrichtenanzahl pro Kunde in der Kundenhistorie",
        OPTIONS_MODULES_CUSTOMER_HISTORY_MAX_ENTRIES_PER_CLIENT =
        "Maximale Verlaufseinträge pro Client",
        OPTIONS_PROFIT_CALCULATION_OFFSET = "Fertigkeitsschwellenwerte um 1 verschieben",
        OPTIONS_PROFIT_CALCULATION_OFFSET_TOOLTIP =
        "Die Vorschläge zur Reagenzienkombination versuchen, den Schwellenwert + 1 zu erreichen, anstatt die genau erforderliche Fertigkeit zu erreichen",

        OPTIONS_PROFIT_CALCULATION_MULTICRAFT_CONSTANT = "Mehrfachherstellungskonstante",
        OPTIONS_PROFIT_CALCULATION_MULTICRAFT_CONSTANT_EXPLANATION =
        "Standard: 2.5\n\nHerstellungsdaten von verschiedenen Datensammlern in der Beta und im frühen Dragonflight deuten darauf hin,\ndass die maximale Anzahl zusätzlicher Gegenstände, die man bei einem Mehrfachherstellungs-Proz erhalten kann, 1+C*y beträgt.\nWobei y die Basisgegenstandsmenge für eine Herstellung ist und C 2,5 beträgt.\nWenn du möchtest, kannst du diesen Wert hier ändern.",
        OPTIONS_PROFIT_CALCULATION_RESOURCEFULNESS_CONSTANT = "Einfallsreichtumskonstante",
        OPTIONS_PROFIT_CALCULATION_RESOURCEFULNESS_CONSTANT_EXPLANATION =
        "Standard: 0.3\n\nHerstellungsdaten von verschiedenen Datensammlern in der Beta und im frühen Dragonflight deuten darauf hin,\ndass die durchschnittlich eingesparte Menge an Gegenständen 30 % der erforderlichen Menge beträgt.\nWenn du möchtest, kannst du diesen Wert hier ändern.",
        OPTIONS_GENERAL_SHOW_NEWS_CHECKBOX = "Zeige " .. f.bb("News") .. " Popup",
        OPTIONS_GENERAL_SHOW_NEWS_CHECKBOX_TOOLTIP = "Zeige das " ..
            f.bb("News") .. " Popup für neue " .. f.l("CraftSim") .. " Update-Informationen beim Einloggen ins Spiel",
        OPTIONS_GENERAL_HIDE_MINIMAP_BUTTON_CHECKBOX = "Minikarten-Symbol verbergen",
        OPTIONS_GENERAL_HIDE_MINIMAP_BUTTON_TOOLTIP = "Aktiviere dies, um das " ..
            f.l("CraftSim") .. " Minikarten-Symbol zu verbergen",
        OPTIONS_GENERAL_COIN_MONEY_FORMAT_CHECKBOX = "Münztexturen verwenden: ",
        OPTIONS_GENERAL_COIN_MONEY_FORMAT_TOOLTIP =
        "Münzsymbole zur Formatierung von Geld verwenden",

        -- Steuerungsfeld
        CONTROL_PANEL_MODULES_CRAFT_QUEUE_LABEL = "Herstellungswarteschl.",
        CONTROL_PANEL_MODULES_CRAFT_QUEUE_TOOLTIP =
        "Stelle deine Rezepte in eine Warteschlange und stelle sie alle an einem Ort her!",
        CONTROL_PANEL_MODULES_TOP_GEAR_LABEL = "Beste Ausrüstung",
        CONTROL_PANEL_MODULES_TOP_GEAR_TOOLTIP =
        "Zeigt die beste verfügbare Berufsausrüstungskombination basierend auf dem ausgewählten Modus an",
        CONTROL_PANEL_MODULES_COST_OVERVIEW_LABEL = "Preisdaten",
        CONTROL_PANEL_MODULES_COST_OVERVIEW_TOOLTIP =
        "Zeigt eine Übersicht über Verkaufspreis und Gewinn nach resultierender Gegenstandsqualität an",
        CONTROL_PANEL_MODULES_AVERAGE_PROFIT_LABEL = "Ø Gewinn",
        CONTROL_PANEL_MODULES_AVERAGE_PROFIT_TOOLTIP =
        "Zeigt den durchschnittlichen Gewinn basierend auf deinen Berufsstatistiken und den Gewinnstatistikwerten als Gold pro Punkt an.",
        CONTROL_PANEL_MODULES_REAGENT_OPTIMIZATION_LABEL = "Reagenzien Optimierung",
        CONTROL_PANEL_MODULES_REAGENT_OPTIMIZATION_TOOLTIP =
        "Schlägt die günstigsten Reagenzien vor, um die höchste Qualitätsschwelle zu erreichen.",
        CONTROL_PANEL_MODULES_PRICE_OVERRIDES_LABEL = "Preisüberschr.",
        CONTROL_PANEL_MODULES_PRICE_OVERRIDES_TOOLTIP =
        "Überschreibe Preise für beliebige Reagenzien, optionale Reagenzien und Herstellungsergebnisse für alle Rezepte oder für ein bestimmtes Rezept.",

        CONTROL_PANEL_MODULES_SPECIALIZATION_INFO_LABEL = "Spezialisierungsinfo",
        CONTROL_PANEL_MODULES_SPECIALIZATION_INFO_TOOLTIP =
        "Zeigt an, wie deine Berufsspezialisierungen dieses Rezept beeinflussen, und ermöglicht es, jede Konfiguration zu simulieren!",
        CONTROL_PANEL_MODULES_CRAFT_LOG_LABEL = "Herstellungsergeb.",
        CONTROL_PANEL_MODULES_CRAFT_LOG_TOOLTIP =
        "Zeige ein Herstellungsprotokoll und Statistiken über deine Herstellungen!",
        CONTROL_PANEL_MODULES_COST_OPTIMIZATION_LABEL = "Kostenoptimierung",
        CONTROL_PANEL_MODULES_COST_OPTIMIZATION_TOOLTIP =
        "Modul, das detaillierte Informationen anzeigt und bei der Optimierung der Herstellungskosten hilft",
        CONTROL_PANEL_MODULES_STATISTICS_LABEL = "Statistiken",
        CONTROL_PANEL_MODULES_STATISTICS_TOOLTIP =
        "Modul, das detaillierte Ergebnisstatistiken für das aktuell geöffnete Rezept anzeigt",
        CONTROL_PANEL_MODULES_RECIPE_SCAN_LABEL = "Rezept-Scan",
        CONTROL_PANEL_MODULES_RECIPE_SCAN_TOOLTIP =
        "Modul, das deine Rezeptliste basierend auf verschiedenen Optionen scannt",
        CONTROL_PANEL_MODULES_CUSTOMER_HISTORY_LABEL = "Kundenhistorie",
        CONTROL_PANEL_MODULES_CUSTOMER_HISTORY_TOOLTIP =
        "Modul, das eine Historie von Gesprächen mit Kunden, hergestellten Gegenständen und Aufträgen bereitstellt",
        CONTROL_PANEL_MODULES_CRAFT_BUFFS_LABEL = "Herstellungs-Buffs",
        CONTROL_PANEL_MODULES_CRAFT_BUFFS_TOOLTIP =
        "Modul, das dir deine aktiven und fehlenden Herstellungs-Buffs anzeigt",
        CONTROL_PANEL_MODULES_EXPLANATIONS_LABEL = "Erklärungen",
        CONTROL_PANEL_MODULES_EXPLANATIONS_TOOLTIP =
            "Modul, das dir verschiedene Erklärungen zeigt, wie" .. f.l(" CraftSim") .. " Dinge berechnet",
        CONTROL_PANEL_RESET_FRAMES = "Fensterpos. zurücksetzen",
        CONTROL_PANEL_OPTIONS = "Optionen",
        CONTROL_PANEL_NEWS = "News",
        CONTROL_PANEL_EASYCRAFT_EXPORT = f.l("Easycraft") .. " Export",
        CONTROL_PANEL_EASYCRAFT_EXPORTING = "Exportiere",
        CONTROL_PANEL_EASYCRAFT_EXPORT_NO_RECIPE_FOUND =
        "Kein Rezept zum Exportieren für die The War Within-Erweiterung gefunden",
        CONTROL_PANEL_FORGEFINDER_EXPORT = f.l("ForgeFinder") .. " Export",
        CONTROL_PANEL_FORGEFINDER_EXPORTING = "Exportiere",
        CONTROL_PANEL_EXPORT_EXPLANATION = f.l("wowforgefinder.com") ..
            " und " .. f.l("easycraft.io") ..
            "\nsind Websites, um " .. f.bb("WoW-Aufträge") .. " zu suchen und anzubieten",
        CONTROL_PANEL_DEBUG = "Debug",
        CONTROL_PANEL_TITLE = "Steuerungsfeld",
        CONTROL_PANEL_SUPPORTERS_BUTTON = f.patreon("Unterstützer"),

        -- Unterstützer
        SUPPORTERS_DESCRIPTION = f.l("Danke an all diese großartigen Menschen!"),
        SUPPORTERS_DESCRIPTION_2 = f.l(
            "Willst du CraftSim unterstützen und auch hier mit deiner Nachricht aufgeführt werden?\nErwäge eine Spende <3"),
        SUPPORTERS_DATE = "Datum",
        SUPPORTERS_SUPPORTER = "Unterstützer",
        SUPPORTERS_MESSAGE = "Nachricht",

        -- Kundenhistorie
        CUSTOMER_HISTORY_TITLE = "CraftSim Kundenhistorie",
        CUSTOMER_HISTORY_DROPDOWN_LABEL = "Wähle einen Kunden",
        CUSTOMER_HISTORY_TOTAL_TIP = "Gesamtes Trinkgeld: ",
        CUSTOMER_HISTORY_FROM = "Von",
        CUSTOMER_HISTORY_TO = "An",
        CUSTOMER_HISTORY_FOR = "Für",
        CUSTOMER_HISTORY_CRAFT_FORMAT = "Herstellte %s für %s",
        CUSTOMER_HISTORY_DELETE_BUTTON = "Kunden entfernen",
        CUSTOMER_HISTORY_WHISPER_BUTTON_LABEL = "Flüstern..",
        CUSTOMER_HISTORY_PURGE_NO_TIP_LABEL = "Kunden mit 0 Trinkgeld entfernen",
        CUSTOMER_HISTORY_PURGE_ZERO_TIPS_CONFIRMATION_POPUP =
        "Bist du sicher, dass du alle Daten\nvon Kunden mit insgesamt 0 Trinkgeld löschen möchtest?",
        CUSTOMER_HISTORY_DELETE_CUSTOMER_CONFIRMATION_POPUP =
        "Bist du sicher, dass du alle Daten für %s löschen möchtest?",
        CUSTOMER_HISTORY_PURGE_DAYS_INPUT_LABEL = "Automatisches Entfernen-Intervall (Tage)",
        CUSTOMER_HISTORY_PURGE_DAYS_INPUT_TOOLTIP =
        "CraftSim wird alle 0-Trinkgeld-Kunden automatisch löschen, wenn du dich nach X Tagen seit der letzten Löschung einloggst.\nWenn auf 0 gesetzt, wird CraftSim nie automatisch löschen.",
        CUSTOMER_HISTORY_CUSTOMER_HEADER = "Kunde",
        CUSTOMER_HISTORY_TOTAL_TIP_HEADER = "Gesamtes Trinkgeld",
        CUSTOMER_HISTORY_CRAFT_HISTORY_DATE_HEADER = "Datum",
        CUSTOMER_HISTORY_CRAFT_HISTORY_RESULT_HEADER = "Ergebnis",
        CUSTOMER_HISTORY_CRAFT_HISTORY_TIP_HEADER = "Trinkgeld",
        CUSTOMER_HISTORY_CRAFT_HISTORY_CUSTOMER_REAGENTS_HEADER = "Kundenreagenzien",
        CUSTOMER_HISTORY_CRAFT_HISTORY_CUSTOMER_NOTE_HEADER = "Notiz",
        CUSTOMER_HISTORY_CHAT_MESSAGE_TIMESTAMP = "Zeitstempel",
        CUSTOMER_HISTORY_CHAT_MESSAGE_SENDER = "Absender",
        CUSTOMER_HISTORY_CHAT_MESSAGE_MESSAGE = "Nachricht",
        CUSTOMER_HISTORY_CHAT_MESSAGE_YOU = "[Du]: ",
        CUSTOMER_HISTORY_CRAFT_LIST_TIMESTAMP = "Zeitstempel",
        CUSTOMER_HISTORY_CRAFT_LIST_RESULTLINK = "Ergebnislink",
        CUSTOMER_HISTORY_CRAFT_LIST_TIP = "Trinkgeld",
        CUSTOMER_HISTORY_CRAFT_LIST_REAGENTS = "Reagenzien",
        CUSTOMER_HISTORY_CRAFT_LIST_SOMENOTE = "Eine Notiz",


        -- Herstellungswarteschlange
        CRAFT_QUEUE_TITLE = "CraftSim Herstellungswarteschlange",
        CRAFT_QUEUE_CRAFT_AMOUNT_LEFT_HEADER = "Eingereiht",
        CRAFT_QUEUE_CRAFT_PROFESSION_GEAR_HEADER = "Berufsausrüstung",
        CRAFT_QUEUE_CRAFTING_COSTS_HEADER = "Herstellungskosten",
        CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL = "Herstellen",
        CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL_WRONG_GEAR = "Falsche Werkzeuge",
        CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL_NO_REAGENTS = "Keine Reagenzien",
        CRAFT_QUEUE_ADD_OPEN_RECIPE_BUTTON_LABEL = "Offenes Rezept hinzufügen",
        CRAFT_QUEUE_ADD_FIRST_CRAFTS_BUTTON_LABEL = "Erstherstellungen hinzufügen",
        CRAFT_QUEUE_ADD_WORK_ORDERS_BUTTON_LABEL = "Aufträge von Kunden hinzufügen",
        CRAFT_QUEUE_ADD_WORK_ORDERS_ALLOW_CONCENTRATION_CHECKBOX = "Konzentration erlauben",
        CRAFT_QUEUE_ADD_WORK_ORDERS_ALLOW_CONCENTRATION_TOOLTIP =
            "Wenn die Mindestqualität nicht erreicht werden kann, verwende " .. f.l("Konzentration") .. " falls möglich",

        CRAFT_QUEUE_CLEAR_ALL_BUTTON_LABEL = "Alles löschen",
        CRAFT_QUEUE_RESTOCK_FAVORITES_BUTTON_LABEL = "Aus Rezept-Scan auffüllen",
        CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL_WRONG_PROFESSION = "Falscher Beruf",
        CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL_ON_COOLDOWN = "Abklingzeit aktiv",
        CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL_WRONG_CRAFTER = "Falscher Handwerker",
        CRAFT_QUEUE_RECIPE_REQUIREMENTS_HEADER = "Anforderungen",
        CRAFT_QUEUE_RECIPE_REQUIREMENTS_TOOLTIP =
        "Alle Anforderungen müssen erfüllt sein, um ein Rezept herzustellen",
        CRAFT_QUEUE_CRAFT_NEXT_BUTTON_LABEL = "Nächste herstellen",
        CRAFT_QUEUE_CRAFT_AVAILABLE_AMOUNT = "Herstellbar",
        CRAFTQUEUE_AUCTIONATOR_SHOPPING_LIST_BUTTON_LABEL = "Auctionator Einkaufsliste erstellen",
        CRAFT_QUEUE_QUEUE_TAB_LABEL = "Herstellungswarteschlange",
        CRAFT_QUEUE_FLASH_TASKBAR_OPTION_LABEL = "Taskleiste blinken bei " ..
            f.bb("Herstellungswarteschlange") .. " Herstellung beendet",
        CRAFT_QUEUE_FLASH_TASKBAR_OPTION_TOOLTIP =
            "Wenn dein WoW-Spiel minimiert ist und ein Rezept in der " .. f.bb("Herstellungswarteschlange") ..
            "," .. f.l(" CraftSim") .. " fertiggestellt wurde, wird das WoW-Taskleistensymbol blinken",
        CRAFT_QUEUE_RESTOCK_OPTIONS_TAB_LABEL = "Auffülloptionen",
        CRAFT_QUEUE_RESTOCK_OPTIONS_TAB_TOOLTIP =
        "Konfiguriere das Auffüllverhalten beim Importieren aus dem Rezept Scan",
        CRAFT_QUEUE_RESTOCK_OPTIONS_GENERAL_PROFIT_THRESHOLD_LABEL = "Gewinnschwelle:",
        CRAFT_QUEUE_RESTOCK_OPTIONS_SALE_RATE_INPUT_LABEL = "Verkaufsrate Schwelle:",
        CRAFT_QUEUE_RESTOCK_OPTIONS_TSM_SALE_RATE_TOOLTIP = string.format(
            [[
Nur verfügbar, wenn %s geladen ist!

Es wird geprüft, ob %s einer Gegenstandsqualität eine Verkaufsrate
hat, die größer oder gleich der konfigurierten Verkaufsraten-Schwelle ist.
]], f.bb("TSM"), f.bb("irgendeine")),
        CRAFT_QUEUE_RESTOCK_OPTIONS_TSM_SALE_RATE_TOOLTIP_GENERAL = string.format(
            [[
Nur verfügbar, wenn %s geladen ist!

Es wird geprüft, ob %s einer Gegenstandsqualität eine Verkaufsrate
hat, die größer oder gleich der konfigurierten Verkaufsraten-Schwelle ist.
]], f.bb("TSM"), f.bb("irgendeine")),
        CRAFT_QUEUE_RESTOCK_OPTIONS_AMOUNT_LABEL = "Auffüllmenge:",
        CRAFT_QUEUE_RESTOCK_OPTIONS_RESTOCK_TOOLTIP = "Dies ist die " ..
            f.bb("Menge an Herstellungen") ..
            " die für dieses Rezept eingereiht wird.\n\nDie Menge der Gegenstände, die du in deinem Inventar und Bank der überprüften Qualitäten hast, wird von der Auffüllmenge abgezogen, wenn aufgefüllt wird",
        CRAFT_QUEUE_RESTOCK_OPTIONS_ENABLE_RECIPE_LABEL = "Aktivieren:",
        CRAFT_QUEUE_RESTOCK_OPTIONS_GENERAL_OPTIONS_LABEL = "Allgemeine Optionen (Alle Rezepte)",
        CRAFT_QUEUE_RESTOCK_OPTIONS_ENABLE_RECIPE_TOOLTIP =
        "Wenn dies deaktiviert ist, wird das Rezept basierend auf den allgemeinen Optionen oben aufgefüllt",
        CRAFT_QUEUE_TOTAL_PROFIT_LABEL = "Gesamter Ø Gewinn:",
        CRAFT_QUEUE_TOTAL_CRAFTING_COSTS_LABEL = "Gesamte Herstellungskosten:",
        CRAFT_QUEUE_EDIT_RECIPE_TITLE = "Rezept bearbeiten",
        CRAFT_QUEUE_EDIT_RECIPE_NAME_LABEL = "Rezeptname",
        CRAFT_QUEUE_EDIT_RECIPE_REAGENTS_SELECT_LABEL = "Auswählen",
        CRAFT_QUEUE_EDIT_RECIPE_OPTIONAL_REAGENTS_LABEL = "Optionale Reagenzien",
        CRAFT_QUEUE_EDIT_RECIPE_FINISHING_REAGENTS_LABEL = "Abschlussreagenzien",
        CRAFT_QUEUE_EDIT_RECIPE_PROFESSION_GEAR_LABEL = "Berufsausrüstung",
        CRAFT_QUEUE_EDIT_RECIPE_OPTIMIZE_PROFIT_BUTTON = "Gewinn optimieren",
        CRAFT_QUEUE_EDIT_RECIPE_CRAFTING_COSTS_LABEL = "Herstellungskosten: ",
        CRAFT_QUEUE_EDIT_RECIPE_AVERAGE_PROFIT_LABEL = "Durchschnittlicher Gewinn: ",
        CRAFT_QUEUE_EDIT_RECIPE_RESULTS_LABEL = "Ergebnisse",
        CRAFT_QUEUE_EDIT_RECIPE_CONCENTRATION_CHECKBOX = " Konzentration",
        CRAFT_QUEUE_AUCTIONATOR_SHOPPING_LIST_PER_CHARACTER_CHECKBOX = "Pro Charakter",
        CRAFT_QUEUE_AUCTIONATOR_SHOPPING_LIST_PER_CHARACTER_CHECKBOX_TOOLTIP = "Erstelle eine " ..
            f.bb("Auctionator Einkaufsliste") .. " für jeden Handwerkercharakter\nanstatt eine Einkaufsliste für alle",
        CRAFT_QUEUE_AUCTIONATOR_SHOPPING_LIST_TARGET_MODE_CHECKBOX = "Nur Zielmodus",
        CRAFT_QUEUE_AUCTIONATOR_SHOPPING_LIST_TARGET_MODE_CHECKBOX_TOOLTIP = "Erstelle eine " ..
            f.bb("Auctionator Einkaufsliste") .. " nur für Zielmodusrezepte",
        CRAFT_QUEUE_UNSAVED_CHANGES_TOOLTIP = f.white(
            "Nicht gespeicherte Warteschlangenmenge.\nDrücke Enter, um zu speichern"),
        CRAFT_QUEUE_STATUSBAR_LEARNED = f.white("Rezept erlernt"),
        CRAFT_QUEUE_STATUSBAR_COOLDOWN = f.white("Keine Abklingzeit"),
        CRAFT_QUEUE_STATUSBAR_REAGENTS = f.white("Reagenzien verfügbar"),

        CRAFT_QUEUE_STATUSBAR_GEAR = f.white("Berufsausrüstung angelegt"),
        CRAFT_QUEUE_STATUSBAR_CRAFTER = f.white("Richtiger Handwerkercharakter"),
        CRAFT_QUEUE_STATUSBAR_PROFESSION = f.white("Beruf geöffnet"),
        CRAFT_QUEUE_BUTTON_EDIT = "Bearbeiten",
        CRAFT_QUEUE_BUTTON_CRAFT = "Herstellen",
        CRAFT_QUEUE_BUTTON_CLAIM = "Anfordern",
        CRAFT_QUEUE_BUTTON_CLAIMED = "Angefordert",
        CRAFT_QUEUE_BUTTON_NEXT = "Nächstes: ",
        CRAFT_QUEUE_BUTTON_NOTHING_QUEUED = "Nichts in der Warteschlange",
        CRAFT_QUEUE_BUTTON_ORDER = "Bestellung",
        CRAFT_QUEUE_BUTTON_SUBMIT = "Abschicken",

        CRAFT_QUEUE_IGNORE_ACUITY_RECIPES_CHECKBOX_LABEL =
        "Händchen fürs Kunsthandwerk-Rezepte ignorieren",
        CRAFT_QUEUE_IGNORE_ACUITY_RECIPES_CHECKBOX_TOOLTIP =
            "Erstherstellungen, die " ..
            f.bb("Händchen fürs Kunsthandwerk") .. " verwenden, nicht in die Warteschlange aufnehmen",
        CRAFT_QUEUE_AMOUNT_TOOLTIP = "\n\nWartende Handwerke: ",
        CRAFT_QUEUE_ORDER_CUSTOMER = "\n\nBestellung von Kunde: ",
        CRAFT_QUEUE_ORDER_MINIMUM_QUALITY = "\nnMindestqualität: ",
        CRAFT_QUEUE_ORDER_REWARDS = "\nBelohnungen:",


        -- Herstellungs-Buffs

        CRAFT_BUFFS_TITLE = "CraftSim Herstellungs-Buffs",
        CRAFT_BUFFS_SIMULATE_BUTTON = "Buffs simulieren",
        CRAFT_BUFF_CHEFS_HAT_TOOLTIP = f.bb("Wrath of the Lich King Spielzeug.") ..
            "\nErfordert Nordend-Kochkunst\nSetzt Herstellungsgeschwindigkeit auf " .. f.g("0,5 Sekunden"),

        -- Abklingzeiten-Modul

        COOLDOWNS_TITLE = "CraftSim Abklingzeiten",
        CONTROL_PANEL_MODULES_COOLDOWNS_LABEL = "Abklingzeiten",
        CONTROL_PANEL_MODULES_COOLDOWNS_TOOLTIP = "Übersicht über die " ..
            f.bb("Berufs-Abklingzeiten") .. " deines Accounts",
        COOLDOWNS_CRAFTER_HEADER = "Handwerker",
        COOLDOWNS_RECIPE_HEADER = "Rezept",
        COOLDOWNS_CHARGES_HEADER = "Aufla\ndungen",

        COOLDOWNS_NEXT_HEADER = "Nächste Aufladung",
        COOLDOWNS_ALL_HEADER = "Aufladungen voll",
        COOLDOWNS_TAB_OVERVIEW = "Übersicht",
        COOLDOWNS_TAB_OPTIONS = "Optionen",
        COOLDOWNS_EXPANSION_FILTER_BUTTON = "Erweiterungsfilter",
        COOLDOWNS_RECIPE_LIST_TEXT_TOOLTIP = f.bb("\n\nRezepte, die diese Abklingzeit teilen:\n"),
        COOLDOWNS_RECIPE_READY = f.g("Bereit"),

        -- Konzentrations-Modul

        CONCENTRATION_TRACKER_TITLE = "CraftSim Konzentration",
        CONCENTRATION_TRACKER_LABEL_CRAFTER = "Hersteller",
        CONCENTRATION_TRACKER_LABEL_CURRENT = "Aktuell",
        CONCENTRATION_TRACKER_LABEL_MAX = "Maximal",
        CONCENTRATION_TRACKER_MAX = f.g("MAX"),
        CONCENTRATION_TRACKER_MAX_VALUE = "Maximal: ",
        CONCENTRATION_TRACKER_FULL = f.g("Konzentration voll"),
        CONCENTRATION_TRACKER_SORT_MODE_CHARACTER = "Charakter",
        CONCENTRATION_TRACKER_SORT_MODE_CONCENTRATION = "Konzentration",
        CONCENTRATION_TRACKER_SORT_MODE_PROFESSION = "Beruf",
        CONCENTRATION_TRACKER_FORMAT_MODE_EUROPE_MAX_DATE = "Europa - Max Datum",
        CONCENTRATION_TRACKER_FORMAT_MODE_AMERICA_MAX_DATE = "Amerika - Max Datum",
        CONCENTRATION_TRACKER_FORMAT_MODE_HOURS_LEFT = "Verbleibende Stunden",

        -- statische Popups
        STATIC_POPUPS_YES = "Ja",
        STATIC_POPUPS_NO = "Nein",

        -- frames
        FRAMES_RESETTING = "Zurücksetzen von Frame-ID: ",
        FRAMES_WHATS_NEW = "Was gibt's Neues bei CraftSim?",
        FRAMES_JOIN_DISCORD = "Tritt dem Discord bei!",
        FRAMES_DONATE_KOFI = "Besuche CraftSim auf Kofi",
        FRAMES_NO_INFO = "Keine Informationen",

        -- node data
        NODE_DATA_RANK_TEXT = "Rang ",
        NODE_DATA_TOOLTIP = "\n\nGesamtwerte aus Talent:\n",

        -- columns
        SOURCE_COLUMN_AH = "AH",
        SOURCE_COLUMN_OVERRIDE = "ÜS",
        SOURCE_COLUMN_WO = "WO",

    }
end
