---@class CraftSim
local CraftSim = select(2, ...)

CraftSim.LOCAL_IT = {}

---@return table<CraftSim.LOCALIZATION_IDS, string>
function CraftSim.LOCAL_IT:GetData()
    local f = CraftSim.GUTIL:GetFormatter()
    local cm = function(i, s) return CraftSim.MEDIA:GetAsTextIcon(i, s) end
    return {
        -- REQUIRED:
        STAT_MULTICRAFT = "Creazione multipla",
        STAT_RESOURCEFULNESS = "Parsimonia",
        STAT_CRAFTINGSPEED = "Velocità di creazione",
        EQUIP_MATCH_STRING = "Equipaggia:",
        ENCHANTED_MATCH_STRING = "Incantato:",

        -- OPTIONAL (Defaulting to EN if not available):
        -- Other Statnames

        STAT_SKILL = "Competenza",
        STAT_MULTICRAFT_BONUS = "Moltiplicatore oggetti aggiuntivi",
        STAT_RESOURCEFULNESS_BONUS = "Molt. reagenti risparmiati", -- Ideally, it should be "Moltiplicatore reagenti risparmiati" but there is not enough space for it.
        STAT_CRAFTINGSPEED_BONUS = "Velocità di creazione",
        STAT_PHIAL_EXPERIMENTATION = "Scoperta Fiala",
        STAT_POTION_EXPERIMENTATION = "Scoperta Pozione",

        -- Profit Breakdown Tooltips
        RESOURCEFULNESS_EXPLANATION_TOOLTIP =
        "Parsimonia si attiva separatamente per ogni tipo di reagente, permettendo di risparmiarne il 30% della quantità.\n\nIl risparmio medio è uguale alla somma del costo dei reagenti\nmoltiplicata per la probabilità che si attivi Parsimonia e per la percentuale di risparmio.\nParsimonia si può anche attivare per tutti i reagenti contemporaneamente, permettendo di risparmiare molto in rare occasioni.",
        RECIPE_DIFFICULTY_EXPLANATION_TOOLTIP =
        "La Difficoltà ricetta determina quali sono le soglie di Competenza necessaria per le varie qualità.\n\nPer ricette con 5 qualità, le soglie di Competenza sono 20%, 50%, 80% e 100% della Difficoltà ricetta.\nPer ricette con 3 qualità, le soglie di Competenza sono 50% e 100% della Difficoltà ricetta.",
        MULTICRAFT_EXPLANATION_TOOLTIP =
        "Creazione multipla ti permette di creare occasionalmente più oggetti del solito.\n\nLa quantità aggiuntiva è stimata tra 1 e 2.5y,\ndove y è la quantità che si ottiene normalmente con una singola operazione di crezione.",
        REAGENTSKILL_EXPLANATION_TOOLTIP =
        "La qualità dei reagenti utilizzati può aumentare la Competenza fino a 40% della Difficoltà ricetta di base.\n\nSolo reagenti di Grado 1: bonus dello 0%\nSolo reagenti di Grado 2: bonus del 20%\nSolo reagenti di Grado 3: bonus del 40%\n\nLa Competenza bonus è uguale alla quantità di reagenti di ogni qualità moltiplicata per le rispettive qualità\ne per un punteggio specifico per ogni tipo di reagente.\n\nNel caso di una ricreazione, invece, la Competenza bonus ottenibile dipende anche dai reagenti utilizzati per la creazione originale e per le ricreazioni precedenti.\nIl funzionamento esatto non è conosciuto.\nComunque, CraftSim confronta internamente la Competenza raggiunta con tutti i reagenti di Grado 3 e usa quei valori per calcolare la Competenza bonus reagenti massima.",
        REAGENTFACTOR_EXPLANATION_TOOLTIP =
        "La qualità dei reagenti utilizzati può aumentare la Competenza fino a 40% della Difficoltà ricetta di base.\n\nNel caso di una ricreazione, però, questo valore può variare in base alla qualità dei reagenti utilizzati per la creazione originale e per le ricreazioni precedenti.",

        -- Simulation Mode
        SIMULATION_MODE_NONE = "Nessuno",
        SIMULATION_MODE_LABEL = "Modalità Simulazione",
        SIMULATION_MODE_TITLE = "Modalità Simulazione di CraftSim",
        SIMULATION_MODE_TOOLTIP =
        "La Modalità Simulazione di CraftSim ti permette di sperimentare con una ricetta senza restrizioni",
        SIMULATION_MODE_OPTIONAL = "Facoltativo #",
        SIMULATION_MODE_FINISHING = "Finitura #",

        -- Details Frame
        RECIPE_DIFFICULTY_LABEL = "Difficoltà ricetta: ",
        MULTICRAFT_LABEL = "Creazione multipla: ",
        RESOURCEFULNESS_LABEL = "Parsimonia: ",
        RESOURCEFULNESS_BONUS_LABEL = "Moltiplicatore reagenti risparmiati: ",
        REAGENT_QUALITY_BONUS_LABEL = "Competenza bonus reagenti: ",
        REAGENT_QUALITY_MAXIMUM_LABEL = "Competenza bonus reagenti massima: ",
        EXPECTED_QUALITY_LABEL = "Qualità garantita: ",
        NEXT_QUALITY_LABEL = "Qualità superiore: ",
        MISSING_SKILL_LABEL = "Competenza mancante: ",
        SKILL_LABEL = "Competenza: ",
        MULTICRAFT_BONUS_LABEL = "Moltiplicatore oggetti aggiuntivi: ",

        -- Statistics
        STATISTICS_CDF_EXPLANATION =
            "Questo viene calcolato usando l'approssimazione di 'abramowitz e stegun' (1985) della Funziona di Distribuzione Cumulata (CDF)\n\n" ..
            "Noterai che questo valore è sempre attorno al 50% per una singola creazione.\n" ..
            "Questo perché la maggior parte delle volte 0 è vicino al profitto medio.\n" ..
            "E la probabilità di ottenere il valore medio della CDF è sempre 50%.\n\n" ..
            "Comunque, the rate of change può essere molto diverso tra le ricette.\n" ..
            "Se è più probabile avere un profitto positivo rispetto a uno negativo, crescerà in maniera costante.\n" ..
            "Questo è ovviamente vero anche in direzione opposta.",
        EXPLANATIONS_PROFIT_CALCULATION_EXPLANATION =
            f.r("Attenzione: ") .. " Un po' di matematica!!\n\n" ..
            "Quando crei qualcosa ci sono diverse probabilità di avere risultati diversi in base alle tue statistiche di creazione.\n" ..
            "E in statistica questa viene chiamata " .. f.l("Distribuzione di Probabilità.\n") ..
            "Comunque, noterai che le diverse probabilità delle tue attivazioni non si sommano a uno\n" ..
            "(Il che è richiesto per questo tipo di distrubuzione e significa che puoi avere il 100% di probabilità che possa accadere qualunque cosa)\n\n" ..
            "Questo perché le attivazioni come " ..
            f.bb("Ispirazione") ..
            " e " .. f.bb("Multicreazione") .. " possono avvenire " .. f.g("nello stesso momento.") .. "\n" ..
            "Quindi per prima cosa dobbiamo convertire le nostre probabilità di attivazione in una " ..
            f.l("Distribuzione di Probabilità") .. " con le probabilità\n" ..
            "che si sommano al 100% (Che significa che ogni caso è gestito)\n" ..
            "E per questo dovremmo calcolare " .. f.l("ogni") .. " possibile risultato di una creazione.\n\n" ..
            "Ad esempio: \n" ..
            f.p .. "Cosa succede se " .. f.bb("niente") .. " si attiva?" ..
            f.p .. "Cosa succede se " .. f.bb("tutto") .. " si attiva?" ..
            f.p ..
            "Cosa succede se solo " .. f.bb("Ispirazione") .. " e " .. f.bb("Multicreazione") .. " si attivano?" ..
            f.p .. "E così via..\n\n" ..
            "Per una ricetta che considera tutte e tre le attivazioni, sono 2^3 possibilità di risultati, cioè 8.\n" ..
            "Per ottenere la probabilità che solo " ..
            f.bb("Ispirazione") .. " si attivi, dobbiamo considerare tutte le altre attivazioni!\n" ..
            "La probabilità che si attivi " ..
            f.l("solo") ..
            " " ..
            f.bb("Ispirazione") ..
            " è la probabilità che si attivi " ..
            f.bb("Ispirazione") ..
            "Ma " .. f.l("non") .. " si attivi " .. f.bb("Multicreazione") .. " o " .. f.bb("Parsimonia") .. "\n" ..
            "e la matematica ci dice che la probabilità che qualcosa non avvenga è 1 meno la probabilità che avvenga.\n" ..
            "Quindi la probabilità che si attivi solo " ..
            f.bb("Ispirazione") ..
            " è " ..
            f.g("ProbabilitàIspirazione * (1-ProbabilitàMulticreazione) * (1-ProbabilitàParsimonia)") .. "\n\n" ..
            "Dopo aver calcolato ogni possibilità in questo modo le probabilità individuali sommano a uno!\n" ..
            "Questo significa che ora possiamo applicare le formule statistiche. La più interessante nel nostro caso è il " ..
            f.bb("Valore Atteso") .. " che è\n" ..
            "come suggerisce il nome, il valore che ci possiamo aspettare di ottenere in media, o nel nostro caso, il " ..
            f.bb(" profitto atteso per una creazione!") .. "\n" ..
            "\n" .. cm(CraftSim.MEDIA.IMAGES.EXPECTED_VALUE) .. "\n\n" ..
            "Questo ci dice che il valore atteso " ..
            f.l("E") ..
            " di una distribuzione di probabilità " ..
            f.l("X") .. " è la somma di tutti i suoi valori moltiplicati per le loro probabilità.\n" ..
            "Quindi se abbiamo un " ..
            f.bb("caso A con probabilità 30%") ..
            " e profitto " ..
            f.m(-100 * 10000) ..
            " e un " ..
            f.bb("caso B con probabilità 70%") .. " e profitto " .. f.m(300 * 10000) ..
            " allora il profitto atteso è\n" ..
            f.bb("\nE(X) = -100*0.3 + 300*0.7") .. " che è " .. f.m((-100 * 0.3 + 300 * 0.7) * 10000) .. "\n\n" ..
            "Puoi vedere tutti questi casi per le tue ricette correnti nella finestra delle " ..
            f.bb("Statistiche") .. "!",

        --- Popups
        POPUP_NO_PRICE_SOURCE_SYSTEM = "Nessuna Sorgente dei Prezzi Disponibile!",
        POPUP_NO_PRICE_SOURCE_TITLE = "Avviso di CraftSim sulle Sorgenti dei Prezzi",
        POPUP_NO_PRICE_SOURCE_WARNING =
        "Nessuna sorgente dei prezzi trovata!\n\nDevi installare almeno uno dei seguenti\naddon per le sorgenti dei prezzi da utilizzare\nnei calcoli di profitto di CraftSim:\n\n\n",
        POPUP_NO_PRICE_SOURCE_WARNING_SUPPRESS = "Non mostrare di nuovo l'avviso",

        -- Reagents Frame
        REAGENT_OPTIMIZATION_TITLE = "Ottimizzazione Materiali",
        REAGENTS_REACHABLE_QUALITY = "Qualità raggiungibile: ",
        REAGENTS_MISSING = "Materiali mancanti",
        REAGENTS_AVAILABLE = "Materiali disponibioli",
        REAGENTS_CHEAPER = "Materiali più economici",
        REAGENTS_BEST_COMBINATION = "Miglior combinazione assegnata",
        REAGENTS_NO_COMBINATION = "Nessuna combinazione trovata\nper incrementare la qualità",
        REAGENTS_ASSIGN = "Assegna",

        -- Specialization Info Frame
        SPEC_INFO_TITLE = "Info Specializzazioni di CraftSim",
        SPEC_INFO_SIMULATE_KNOWLEDGE_DISTRIBUTION = "Simula Distribuzione Conoscenza",
        SPEC_INFO_NODE_TOOLTIP =
        "Questa specializzazione ti fornisce le seguenti statistiche per questa ricetta:",
        SPEC_INFO_WORK_IN_PROGRESS = "Specializzazioni non ancora ultimate",

        -- Crafting Results Frame
        CRAFT_LOG_TITLE = "Risultati d'Artigianato di CraftSim",
        CRAFT_LOG_LOG = "Resoconto prodotto finale",
        CRAFT_LOG_LOG_1 = "Profitto: ",
        CRAFT_LOG_LOG_2 = "Ispirazione!",
        CRAFT_LOG_LOG_3 = "Creazione multipla: ",
        CRAFT_LOG_LOG_4 = "Risorse risparmiate!: ",
        CRAFT_LOG_LOG_5 = "Possibilità: ",
        CRAFT_LOG_CRAFTED_ITEMS = "Oggetti creati",
        CRAFT_LOG_SESSION_PROFIT = "Profitto di sessione",
        CRAFT_LOG_RESET_DATA = "Resetta dati",
        CRAFT_LOG_EXPORT_JSON = "Esporta JSON",
        CRAFT_LOG_RECIPE_STATISTICS = "Statistiche Ricetta",
        CRAFT_LOG_NOTHING = "Nessuna creazione al momento!",
        CRAFT_LOG_CALCULATION_COMPARISON_NUM_CRAFTS_PREFIX = "Creazioni: ",
        CRAFT_LOG_STATISTICS_2 = "Profitto Ø Previsto: ",
        CRAFT_LOG_STATISTICS_3 = "Profitto Ø Reale: ",
        CRAFT_LOG_STATISTICS_4 = "Profitto Reale: ",
        CRAFT_LOG_STATISTICS_5 = "Attivazioni - Reali/Previste: ",
        CRAFT_LOG_STATISTICS_6 = "Ispirazione: ",
        CRAFT_LOG_STATISTICS_7 = "Creazione Multipla: ",
        CRAFT_LOG_STATISTICS_8 = "- Ø Oggetti aggiuntivi: ",
        CRAFT_LOG_STATISTICS_9 = "Attivazioni Parsimonia: ",
        CRAFT_LOG_CALCULATION_COMPARISON_NUM_CRAFTS_PREFIX0 = "- Ø Risparmio: ",
        CRAFT_LOG_CALCULATION_COMPARISON_NUM_CRAFTS_PREFIX1 = "Profitto: ",
        CRAFT_LOG_SAVED_REAGENTS = "Reagenti risparmiati",

        -- Stats Weight Frame
        STAT_WEIGHTS_TITLE = "Profitto Medio di CraftSim",
        EXPLANATIONS_TITLE = "Spiegazioni del Profitto Medio di CraftSim",
        STAT_WEIGHTS_SHOW_EXPLANATION_BUTTON = "Mostra Spiegazioni",
        STAT_WEIGHTS_HIDE_EXPLANATION_BUTTON = "Chiudi Spiegazioni",
        STAT_WEIGHTS_SHOW_STATISTICS_BUTTON = "Mostra Statistiche",
        STAT_WEIGHTS_HIDE_STATISTICS_BUTTON = "Chiudi Statistiche",
        STAT_WEIGHTS_PROFIT_CRAFT = "Ø Profitto/Creazione: ",
        EXPLANATIONS_BASIC_PROFIT_TAB = "Basi del calcolo del Profitto",

        -- Cost Details Frame
        PRICING_TITLE = "Dettaglio Costi di CraftSim",
        PRICING_EXPLANATION =
            "In questa sezione puoi vedere una panoramica di tutti i possibili prezzi dei materiali utilizzati.\nLa colonna " ..
            f.bb("'Sorgente'") ..
            " indica quale dei prezzi è utilizzato.\n\n" ..
            f.g("AH") ..
            " .. Prezzo dell'Asta\n" ..
            f.l("OR") ..
            " .. Prezzo Personalizzato\n" ..
            f.bb("Nome") ..
            " .. Costi Previsti dai Dati Salvati dell'Artigiano\n\n" ..
            f.l("OR") ..
            " verrà sempre preferito se è stato impostato. " ..
            f.bb("Dati Salvati") .. " saranno utilizzati solo se inferiori a " .. f.g("AH"),
        PRICING_CRAFTING_COSTS = "Costi di creazione: ",
        PRICING_ITEM_HEADER = "Oggetto",
        COST_OPTIMIZATION_CRAFTING_HEADER = "Dati Salvati",
        COST_OPTIMIZATION_USED_SOURCE = "Sorgente",

        -- Statistics Frame
        STATISTICS_TITLE = "Statistiche di CraftSim",
        STATISTICS_EXPECTED_PROFIT = "Profitto previsto (μ)",
        STATISTICS_CHANCE_OF = "Probabilità di ",
        STATISTICS_PROFIT = "Profitto",
        STATISTICS_AFTER = " dopo",
        STATISTICS_CRAFTS = "Creazioni: ",
        STATISTICS_QUALITY_HEADER = "Qualità",
        STATISTICS_CHANCE_HEADER = "Probabilità",
        STATISTICS_EXPECTED_CRAFTS_HEADER = "Creazioni previste",
        STATISTICS_MULTICRAFT_HEADER = "Creazioni multiple",
        STATISTICS_RESOURCEFULNESS_HEADER = "Parsimonia",
        STATISTICS_HSV_NEXT = "HSV Succ.",
        STATISTICS_HSV_SKIP = "HSV Salto",
        STATISTICS_EXPECTED_PROFIT_HEADER = "Profitto previsto",
        PROBABILITY_TABLE_TITLE = "Tabella delle Probabilità della Ricetta",
        STATISTICS_EXPECTED_COSTS_HEADER = "Ø Costo Previsto per Oggetto",
        STATISTICS_EXPECTED_COSTS_WITH_RETURN_HEADER = "Con Ø di Reso",

        -- Price Details Frame
        COST_OVERVIEW_TITLE = "Dettaglio Prezzi di CraftSim",
        PRICE_DETAILS_INV_AH = "Inv/AH",
        PRICE_DETAILS_ITEM = "Oggetto",
        PRICE_DETAILS_PRICE_ITEM = "Prezzo/Oggetto",
        PRICE_DETAILS_PROFIT_ITEM = "Profitto/Oggetto",

        -- Price Override Frame
        PRICE_OVERRIDE_TITLE = "Prezzi Personalizzati di CraftSim",
        PRICE_OVERRIDE_REQUIRED_REAGENTS = "Reagenti Obbligatori",
        PRICE_OVERRIDE_OPTIONAL_REAGENTS = "Reagenti Facoltativi",
        PRICE_OVERRIDE_FINISHING_REAGENTS = "Reagenti di Finitura",
        PRICE_OVERRIDE_RESULT_ITEMS = "Oggetti Risultanti",
        PRICE_OVERRIDE_ACTIVE_OVERRIDES = "Prezzi Personalizzati Attivi",
        PRICE_OVERRIDE_ACTIVE_OVERRIDES_TOOLTIP =
        "'(come risultato)' -> Prezzi Personalizzati considerati solamente quando l'oggetto è il risultato di una ricetta.",
        PRICE_OVERRIDE_CLEAR_ALL = "Cancella Tutti",
        PRICE_OVERRIDE_SAVE = "Salva",
        PRICE_OVERRIDE_SAVED = "Salvato",
        PRICE_OVERRIDE_REMOVE = "Rimuovi",

        -- Recipe Scan Frame
        RECIPE_SCAN_TITLE = "Scansione Ricette di CraftSim",
        RECIPE_SCAN_MODE = "Modalità Scansione",
        RECIPE_SCAN_SCAN_RECIPIES = "Scansiona Ricette",
        RECIPE_SCAN_SCAN_CANCEL = "Annulla",
        RECIPE_SCAN_SCANNING = "Scansione",
        RECIPE_SCAN_INCLUDE_NOT_LEARNED = "Includi non apprese",
        RECIPE_SCAN_INCLUDE_NOT_LEARNED_TOOLTIP =
        "Include le ricette che non hai appreso nella scansione.",
        RECIPE_SCAN_INCLUDE_SOULBOUND = "Includi vincolate",
        RECIPE_SCAN_INCLUDE_SOULBOUND_TOOLTIP =
        "Include le ricette vincolate nella scansione.\n\nE' consigliato modificare il prezzo (es. per simulare una commissione) nel modulo di Modifica Prezzi per gli oggetti creati con questa ricetta.",
        RECIPE_SCAN_INCLUDE_GEAR = "Includi equipaggiamento",
        RECIPE_SCAN_INCLUDE_GEAR_TOOLTIP =
        "Include le ricette di ogni forma di equipaggiamento nella scansione",
        RECIPE_SCAN_OPTIMIZE_TOOLS = "Ottimizza strumenti professioni",
        RECIPE_SCAN_OPTIMIZE_TOOLS_TOOLTIP =
        "Per ogni ricetta ottimizza i tuoi strumenti per il miglior profitto\n\n",
        RECIPE_SCAN_OPTIMIZE_TOOLS_WARNING =
        "Potrebbe diminuire le prestazioni durante la scansione se hai molti strumenti nell'inventario.",
        RECIPE_SCAN_CRAFTER_HEADER = "Artigiano",
        RECIPE_SCAN_RECIPE_HEADER = "Ricetta",
        RECIPE_SCAN_LEARNED_HEADER = "Appresa",
        RECIPE_SCAN_AVERAGE_PROFIT_HEADER = "Profitto medio",
        RECIPE_SCAN_TOP_GEAR_HEADER = "Strumenti",
        RECIPE_SCAN_INV_AH_HEADER = "Inv/AH",
        RECIPE_SCAN_SORT_BY_MARGIN = "Ordina per % di profitto",
        RECIPE_SCAN_SORT_BY_MARGIN_TOOLTIP =
        "Ordina la lisa dei profitti per profitto relativo al costo di creazione.\n(Richiede una nuova scansione)",
        RECIPE_SCAN_USE_INSIGHT_CHECKBOX = "Usa " .. f.bb("Consapevolezza Illustre"),
        RECIPE_SCAN_USE_INSIGHT_CHECKBOX_TOOLTIP = "Usa " ..
            f.bb("Consapevolezza Illustre") ..
            " o\n" ..
            f.bb("Consapevolezza Illustre Minore") .. " come reagente opzionale per le ricette che lo permettono",
        RECIPE_SCAN_ONLY_FAVORITES_CHECKBOX = "Solo preferiti",
        RECIPE_SCAN_ONLY_FAVORITES_CHECKBOX_TOOLTIP = "Scansiona solo le tue ricette preferite",
        RECIPE_SCAN_EQUIPPED = "Equipaggiato",
        RECIPE_SCAN_MODE_OPTIMIZE = "Ottimizza",
        RECIPE_SCAN_EXPANSION_FILTER_BUTTON = "Filtri espansione",
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
        RECIPE_SCAN_AUTOSELECT_OPEN_PROFESSION = "Autoselect Open Profession",

        -- Recipe Top Gear
        TOP_GEAR_TITLE = "Ottimizzazione Strumenti",
        TOP_GEAR_AUTOMATIC = "Automatico",
        TOP_GEAR_AUTOMATIC_TOOLTIP =
        "Simula automaticamente i migliori strumenti in base alla modalità selezionata ogni volta che si cambia ricetta.\n\nDisabilitando questa impostazione possono aumentare le prestazioni.",
        TOP_GEAR_SIMULATE = "Simula",
        TOP_GEAR_EQUIP = "Equipaggia",
        TOP_GEAR_SIMULATE_QUALITY = "Qualità",
        TOP_GEAR_SIMULATE_EQUIPPED = "Strumenti migliori equipaggiati",
        TOP_GEAR_SIMULATE_PROFIT_DIFFERENCE = "Ø Differenza Profitto\n",
        TOP_GEAR_SIMULATE_NEW_MUTLICRAFT = "Nuova Creazione Multipla\n",
        TOP_GEAR_SIMULATE_NEW_CRAFTING_SPEED = "Nuova Velocità di Creazione\n",
        TOP_GEAR_SIMULATE_NEW_RESOURCEFULNESS = "Nuova Parsimonia\n",
        TOP_GEAR_SIMULATE_NEW_SKILL = "Nuova Competenza\n",
        TOP_GEAR_SIMULATE_UNHANDLED = "Simulazione non gestita",

        TOP_GEAR_SIM_MODES_PROFIT = "Max Profitto",
        TOP_GEAR_SIM_MODES_SKILL = "Max Competenza",
        TOP_GEAR_SIM_MODES_MULTICRAFT = "Max Creazione Multipla",
        TOP_GEAR_SIM_MODES_RESOURCEFULNESS = "Max Parsimonia",
        TOP_GEAR_SIM_MODES_CRAFTING_SPEED = "Max Velocità Creazione",

        -- Options
        OPTIONS_TITLE = "CraftSim",
        OPTIONS_GENERAL_TAB = "Generale",
        OPTIONS_GENERAL_PRICE_SOURCE = "Sorgenti dei Prezzi",
        OPTIONS_GENERAL_CURRENT_PRICE_SOURCE = "Attuale Sorgente dei Prezzi: ",
        OPTIONS_GENERAL_NO_PRICE_SOURCE = "Nessun addon supportato di Sorgente Prezzi caricato!",
        OPTIONS_GENERAL_SHOW_PROFIT = "Mostra Percentuale di Profitto",
        OPTIONS_GENERAL_SHOW_PROFIT_TOOLTIP =
        "Mostra anche la percentuale di profitto sul costo di creazione di fianco al profitto in Oro",
        OPTIONS_GENERAL_REMEMBER_LAST_RECIPE = "Ricorda ultima ricetta",
        OPTIONS_GENERAL_REMEMBER_LAST_RECIPE_TOOLTIP =
        "Riapre l'ultima ricetta selezionata quando si riapre la finestra della professione",
        OPTIONS_GENERAL_SUPPORTED_PRICE_SOURCES = "Sorgenti dei Prezzi supportate:",
        OPTIONS_PERFORMANCE_RAM = "Abilita pulizia RAM durante la creazione",
        OPTIONS_PERFORMANCE_RAM_TOOLTIP =
        "Quando abilitato, CraftSim eliminerà dalla RAM i dati inutilizzati ogni numero di oggetti creati specificato per prevenire l'aumento della memoria occupata.\nL'aumento di memoria occupata può anche avvenire a causa di altri addon diversi da CraftSim.\nLa pulizia riguarda tutta la RAM utilizzata dagli addon di WOW.",
        OPTIONS_MODULES_TAB = "Moduli",
        OPTIONS_PROFIT_CALCULATION_TAB = "Calcolo del Profitto",
        OPTIONS_CRAFTING_TAB = "Ottimizzazione",
        OPTIONS_TSM_RESET = "Resetta",
        OPTIONS_TSM_INVALID_EXPRESSION = "Espressione non valida",
        OPTIONS_TSM_VALID_EXPRESSION = "Espressione valida",
        OPTIONS_MODULES_REAGENT_OPTIMIZATION = "Modulo Ottimizzazione Materiali",
        OPTIONS_MODULES_AVERAGE_PROFIT = "Modulo Profitto Medio",
        OPTIONS_MODULES_TOP_GEAR = "Modulo Ottimizzazione Strumenti",
        OPTIONS_MODULES_COST_OVERVIEW = "Modulo Dettaglio Prezzi",
        OPTIONS_MODULES_SPECIALIZATION_INFO = "Modulo Info Specializzazioni",
        OPTIONS_MODULES_CUSTOMER_HISTORY_SIZE = "Massimo numero di messaggi\nnello Storico Clienti",
        OPTIONS_PROFIT_CALCULATION_OFFSET = "Aggiungi 1 alla soglia di Competenza",
        OPTIONS_PROFIT_CALCULATION_OFFSET_TOOLTIP =
        "Il suggerimento dei migliori materiali proverà a raggiungere la soglia di competenza +1 invece di cercare di raggiungere la competenza esatta richiesta",
        OPTIONS_PROFIT_CALCULATION_MULTICRAFT_CONSTANT = "Costante Creazione Multipla",
        OPTIONS_PROFIT_CALCULATION_MULTICRAFT_CONSTANT_EXPLANATION =
        "Default: 2.5\n\nInformazioni sulle professioni raccolte da diversi giocatori durante la beta e all'inizio di Dragonflight suggeriscono che\nil numero massimo di oggetti aggiuntivi che si possono ricevere dall'attivazione di Creazione Multipla sia 1+C*y.\nDove y è la quantità base di oggetti generati in un processo di creazione e C è 2.5.\nE' comunque possibile modificare questo valore in questa sezione.",
        OPTIONS_PROFIT_CALCULATION_RESOURCEFULNESS_CONSTANT = "Costante Parsimonia",
        OPTIONS_PROFIT_CALCULATION_RESOURCEFULNESS_CONSTANT_EXPLANATION =
        "Default: 0.3\n\nInformazioni sulle professioni raccolte da diversi giocatori durante la beta e all'inizio di Dragonflight suggeriscono che\nla quantità media di oggetti risparmiati con Parsimonia sia il 30% della quantità richiesta.\nE' comunque possibile modificare questo valore in questa sezione.",
        OPTIONS_GENERAL_SHOW_NEWS_CHECKBOX = "Mostra finestra con le " .. f.bb("Novità"),
        OPTIONS_GENERAL_SHOW_NEWS_CHECKBOX_TOOLTIP = "Mostra la finestra con le ultime " ..
            f.bb("Novità") .. " di " .. f.l("CraftSim") .. " quando entri in gioco",
        OPTIONS_GENERAL_HIDE_MINIMAP_BUTTON_CHECKBOX = "Nascondi bottone sulla minimappa",
        OPTIONS_GENERAL_HIDE_MINIMAP_BUTTON_TOOLTIP =
            "Abilita per nascondere il bottone della minimappa di " .. f.l("CraftSim"),

        -- Control Panel
        CONTROL_PANEL_MODULES_CRAFT_QUEUE_LABEL = "Coda Artigianato",
        CONTROL_PANEL_MODULES_CRAFT_QUEUE_TOOLTIP =
        "Metti in coda le tue ricette e creale tutte assieme!",
        CONTROL_PANEL_MODULES_TOP_GEAR_LABEL = "Ottimizzazione Strumenti",
        CONTROL_PANEL_MODULES_TOP_GEAR_TOOLTIP =
        "Mostra la miglior combinazione di strumenti per le professioni disponibile in base alla modalità scelta.",
        CONTROL_PANEL_MODULES_COST_OVERVIEW_LABEL = "Dettaglio Prezzi",
        CONTROL_PANEL_MODULES_COST_OVERVIEW_TOOLTIP =
        "Mostra una panoramica di prezzi e profitti in base alla qualità risultante degli oggetti.",
        CONTROL_PANEL_MODULES_AVERAGE_PROFIT_LABEL = "Profitto Medio",
        CONTROL_PANEL_MODULES_AVERAGE_PROFIT_TOOLTIP =
        "Mostra il profitto medio in base alle tue statistiche delle professioni e il peso in profitto delle statistiche come oro per punto.",
        CONTROL_PANEL_MODULES_REAGENT_OPTIMIZATION_LABEL = "Ottimizzazione Materiali",
        CONTROL_PANEL_MODULES_REAGENT_OPTIMIZATION_TOOLTIP =
        "Suggerisce i materiali più economici per raggiungere la più alta soglia di qualità/ispirazione.",
        CONTROL_PANEL_MODULES_PRICE_OVERRIDES_LABEL = "Prezzi Personalizzati",
        CONTROL_PANEL_MODULES_PRICE_OVERRIDES_TOOLTIP =
        "Personalizza i prezzi di qualunque materiale, materiale opzionale e risultati di creazione per tutte le ricette o per una ricetta in particolare. Puoi anche scegliere di usare i dati della sezione 'Dati Salvati' come prezzo di un oggetto.",
        CONTROL_PANEL_MODULES_SPECIALIZATION_INFO_LABEL = "Info Specializzazioni",
        CONTROL_PANEL_MODULES_SPECIALIZATION_INFO_TOOLTIP =
        "Mostra come le specializzazioni della tua professione influenzano questa ricetta e permette di simulare ogni possibile configurazione!",
        CONTROL_PANEL_MODULES_CRAFT_LOG_LABEL = "Risultati Artigianato",
        CONTROL_PANEL_MODULES_CRAFT_LOG_TOOLTIP =
        "Mostra rapporti e statistiche dei tuoi oggetti creati!",
        CONTROL_PANEL_MODULES_COST_OPTIMIZATION_LABEL = "Dettaglio Costi",
        CONTROL_PANEL_MODULES_COST_OPTIMIZATION_TOOLTIP =
        "Modulo che mostra dettagliate informazioni sui costi di creazione",
        CONTROL_PANEL_MODULES_RECIPE_SCAN_LABEL = "Scansione Ricette",
        CONTROL_PANEL_MODULES_RECIPE_SCAN_TOOLTIP =
        "Modulo che scansiona la tua lista di ricette in base a varie opzioni",
        CONTROL_PANEL_MODULES_CUSTOMER_HISTORY_LABEL = "Storico Clienti",
        CONTROL_PANEL_MODULES_CUSTOMER_HISTORY_TOOLTIP =
        "Modulo che mostra uno storico delle conversazioni con i clienti, gli oggetti creati e le commissioni",
        CONTROL_PANEL_MODULES_CRAFT_BUFFS_LABEL = "Benefici Artigianato",
        CONTROL_PANEL_MODULES_CRAFT_BUFFS_TOOLTIP =
        "Modulo che mostra i benefici di creazione attivi e quelli mancanti",
        CONTROL_PANEL_RESET_FRAMES = "Resetta posizioni finestre",
        CONTROL_PANEL_OPTIONS = "Opzioni",
        CONTROL_PANEL_PATCH_NOTES = "Patch Notes",
        CONTROL_PANEL_EASYCRAFT_EXPORT = "Esporta per " .. f.l("Easycraft"),
        CONTROL_PANEL_EASYCRAFT_EXPORTING = "Esportazione",
        CONTROL_PANEL_EASYCRAFT_EXPORT_NO_RECIPE_FOUND =
        "Nessuna ricetta da esportare per l'espansione The War Within",
        CONTROL_PANEL_FORGEFINDER_EXPORT = "Esporta per " .. f.l("ForgeFinder"),
        CONTROL_PANEL_FORGEFINDER_EXPORTING = "Esportazione",
        CONTROL_PANEL_EXPORT_EXPLANATION = f.l("wowforgefinder.com") ..
            " & " .. f.l("easycraft.io") ..
            "\nè un sito per la ricerca e l'offerta di " .. f.bb("Ordini d'Artigianato di WoW"),
        CONTROL_PANEL_DEBUG = "Debug",
        CONTROL_PANEL_TITLE = "Pannello di Controllo",
        CONTROL_PANEL_SUPPORTERS_BUTTON = f.patreon("Sostenitori"),

        -- Supporters
        SUPPORTERS_DESCRIPTION = f.l("Grazie a tutte queste persone eccezionali!"),
        SUPPORTERS_DESCRIPTION_2 = f.l(
            "Vuoi sostenere CraftSim e essere elencato qui con il tuo messaggio?\nConsidera una donazione <3"),
        SUPPORTERS_DATE = "Data",
        SUPPORTERS_SUPPORTER = "Sostenitore",
        SUPPORTERS_MESSAGE = "Messaggio",

        -- Customer History
        CUSTOMER_HISTORY_TITLE = "Storico Clienti di CraftSim",
        CUSTOMER_HISTORY_DROPDOWN_LABEL = "Scegli un cliente",
        CUSTOMER_HISTORY_TOTAL_TIP = "Guadagno totale: ",
        CUSTOMER_HISTORY_FROM = "Da",
        CUSTOMER_HISTORY_TO = "A",
        CUSTOMER_HISTORY_FOR = "Per",
        CUSTOMER_HISTORY_CRAFT_FORMAT = "Creati %s per %s",
        CUSTOMER_HISTORY_DELETE_BUTTON = "Rimuovi cliente",
        CUSTOMER_HISTORY_WHISPER_BUTTON_LABEL = "Sussurra..",
        CUSTOMER_HISTORY_PURGE_NO_TIP_LABEL = "Rimuove clienti con 0 pagamenti",
        CUSTOMER_HISTORY_PURGE_ZERO_TIPS_CONFIRMATION_POPUP =
        "Sei sicuro di voler cancellare tutti i dati\ndei client con un totale di 0 pagamenti?",
        CUSTOMER_HISTORY_DELETE_CUSTOMER_CONFIRMATION_POPUP =
        "Sei sicuro di voler cancellare tutti i dati\n per %s?",
        CUSTOMER_HISTORY_PURGE_DAYS_INPUT_LABEL = "Intervallo di auto-cancellazione (Giorni)",
        CUSTOMER_HISTORY_PURGE_DAYS_INPUT_TOOLTIP =
        "CraftSim cancellerà tutti i clienti con 0 pagamenti quando entrerai in gioco dopo X giorni dall'ultima cancellazione.\nSe impostato a 0, CraftSim non cancellerà mai automaticamente.",
        CUSTOMER_HISTORY_CUSTOMER_HEADER = "Cliente",
        CUSTOMER_HISTORY_TOTAL_TIP_HEADER = "Totale pagamenti",
        CUSTOMER_HISTORY_CRAFT_HISTORY_DATE_HEADER = "Data",
        CUSTOMER_HISTORY_CRAFT_HISTORY_RESULT_HEADER = "Risultato",
        CUSTOMER_HISTORY_CRAFT_HISTORY_TIP_HEADER = "Pagamento",
        CUSTOMER_HISTORY_CRAFT_HISTORY_CUSTOMER_REAGENTS_HEADER = "Reagenti cliente",
        CUSTOMER_HISTORY_CRAFT_HISTORY_CUSTOMER_NOTE_HEADER = "Note",


        -- Craft Queue
        CRAFT_QUEUE_TITLE = "Coda d'Artigianato di CraftSim",
        CRAFT_QUEUE_CRAFT_AMOUNT_LEFT_HEADER = "In coda",
        CRAFT_QUEUE_CRAFT_PROFESSION_GEAR_HEADER = "Equip professioni",
        CRAFT_QUEUE_CRAFTING_COSTS_HEADER = "Costi creazione",
        CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL = "Crea",
        CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL_WRONG_GEAR = "Strumenti sbagliati",
        CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL_NO_REAGENTS = "Nessun materiale",
        CRAFT_QUEUE_ADD_OPEN_RECIPE_BUTTON_LABEL = "Aggiungi ricetta selezionata",
        CRAFT_QUEUE_CLEAR_ALL_BUTTON_LABEL = "Cancella tutto",
        CRAFT_QUEUE_RESTOCK_FAVORITES_BUTTON_LABEL = "Rifornimento da Scansione Ricette",
        CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL_WRONG_PROFESSION = "Professione sbagliata",
        CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL_ON_COOLDOWN = "In cooldown",
        CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL_WRONG_CRAFTER = "Artigiano sbagliato",
        CRAFT_QUEUE_CRAFT_NEXT_BUTTON_LABEL = "Crea successivo",
        CRAFT_QUEUE_CRAFT_AVAILABLE_AMOUNT = "Creabile",
        CRAFTQUEUE_AUCTIONATOR_SHOPPING_LIST_BUTTON_LABEL = "Crea lista della spesa in Auctionator",
        CRAFT_QUEUE_QUEUE_TAB_LABEL = "Coda d'Artigianato",
        CRAFT_QUEUE_RESTOCK_OPTIONS_TAB_LABEL = "Opzioni di rifornimento",
        CRAFT_QUEUE_RESTOCK_OPTIONS_GENERAL_PROFIT_THRESHOLD_LABEL = "Soglia di profitto:",
        CRAFT_QUEUE_RESTOCK_OPTIONS_SALE_RATE_INPUT_LABEL = "Soglia tasso di vendità:",
        CRAFT_QUEUE_RESTOCK_OPTIONS_TSM_SALE_RATE_TOOLTIP = string.format(
            [[
Disponibile solo quando %s è caricato!

Verrà controllato se una %s delle qualità dell'oggetto scelto ha un tasso di vendita
maggiore o uguale alla soglia configurata.
]], f.bb("TSM"), f.bb("qualunque")),
        CRAFT_QUEUE_RESTOCK_OPTIONS_TSM_SALE_RATE_TOOLTIP_GENERAL = string.format(
            [[
Disponibile solo quando %s è caricato!

Verrà controllato se una %s delle qualità dell'oggetto scelto ha un tasso di vendita
maggiore o uguale alla soglia configurata.
]], f.bb("TSM"), f.bb("qualunque")),
        CRAFT_QUEUE_RESTOCK_OPTIONS_AMOUNT_LABEL = "Quantità di rifornimento:",
        CRAFT_QUEUE_RESTOCK_OPTIONS_RESTOCK_TOOLTIP = "E' la " ..
            f.bb("quantità di creazioni") ..
            " che sarà messa in coda per la ricetta.\n\nLa quantità di oggetti della qualità selezionata presenti nel tuo inventario e in banca sarà sottratta dalla quantità da rifornire",
        CRAFT_QUEUE_RESTOCK_OPTIONS_ENABLE_RECIPE_LABEL = "Abilita:",
        CRAFT_QUEUE_RESTOCK_OPTIONS_GENERAL_OPTIONS_LABEL = "Opzioni generali (Tutte le ricette)",
        CRAFT_QUEUE_RESTOCK_OPTIONS_ENABLE_RECIPE_TOOLTIP =
        "Se viene deselezionato, la ricetta sarà rifornita in base alle opzioni generali",
        CRAFT_QUEUE_TOTAL_PROFIT_LABEL = "Profitto totale:",
        CRAFT_QUEUE_TOTAL_CRAFTING_COSTS_LABEL = "Costi di creazione totali:",
        CRAFT_QUEUE_EDIT_RECIPE_TITLE = "Modifica ricetta",
        CRAFT_QUEUE_EDIT_RECIPE_NAME_LABEL = "Nome Ricetta",
        CRAFT_QUEUE_EDIT_RECIPE_REAGENTS_SELECT_LABEL = "Seleziona",
        CRAFT_QUEUE_EDIT_RECIPE_OPTIONAL_REAGENTS_LABEL = "Reagenti Opzionali",
        CRAFT_QUEUE_EDIT_RECIPE_FINISHING_REAGENTS_LABEL = "Reagenti di Finitura",
        CRAFT_QUEUE_EDIT_RECIPE_PROFESSION_GEAR_LABEL = "Equip Professione",
        CRAFT_QUEUE_EDIT_RECIPE_OPTIMIZE_PROFIT_BUTTON = "Ottimizza Profitto",
        CRAFT_QUEUE_EDIT_RECIPE_CRAFTING_COSTS_LABEL = "Costi di creazione: ",
        CRAFT_QUEUE_EDIT_RECIPE_AVERAGE_PROFIT_LABEL = "Profitto medio: ",
        CRAFT_QUEUE_EDIT_RECIPE_RESULTS_LABEL = "Risultati",

        -- craft buffs

        CRAFT_BUFFS_TITLE = "Benefici d'Artigianato di CraftSim",
        CRAFT_BUFFS_SIMULATE_BUTTON = "Simula Benefici",
        CRAFT_BUFF_CHEFS_HAT_TOOLTIP = f.bb("Giocattolo di Wrath of the Lich King.") ..
            "\nRichiede l'abilità di cucina di Northrend\nImposta la velocità di creazione a " .. f.g("0.5 secondi"),

        -- static popups
        STATIC_POPUPS_YES = "Si",
        STATIC_POPUPS_NO = "No",
        PATCH_NOTES_TITLE = "Note della patch di CraftSim",
    }
end
