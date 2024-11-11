---@class CraftSim
local CraftSim = select(2, ...)

CraftSim.LOCAL_IT = {}

function CraftSim.LOCAL_IT:GetData()
    local f = CraftSim.GUTIL:GetFormatter()
    local cm = function(i, s) return CraftSim.MEDIA:GetAsTextIcon(i, s) end
    return {
        -- REQUIRED:
        [CraftSim.CONST.TEXT.STAT_MULTICRAFT] = "Creazione multipla",
        [CraftSim.CONST.TEXT.STAT_RESOURCEFULNESS] = "Parsimonia",
        [CraftSim.CONST.TEXT.STAT_CRAFTINGSPEED] = "Velocità di creazione",
        [CraftSim.CONST.TEXT.EQUIP_MATCH_STRING] = "Equipaggia:",
        [CraftSim.CONST.TEXT.ENCHANTED_MATCH_STRING] = "Incantato:",

        -- OPTIONAL (Defaulting to EN if not available):
        -- Other Statnames

        [CraftSim.CONST.TEXT.STAT_SKILL] = "Competenza",
        [CraftSim.CONST.TEXT.STAT_MULTICRAFT_BONUS] = "Moltiplicatore oggetti aggiuntivi",
        [CraftSim.CONST.TEXT.STAT_RESOURCEFULNESS_BONUS] = "Molt. reagenti risparmiati", -- Ideally, it should be "Moltiplicatore reagenti risparmiati" but there is not enough space for it.
        [CraftSim.CONST.TEXT.STAT_CRAFTINGSPEED_BONUS] = "Velocità di creazione",
        [CraftSim.CONST.TEXT.STAT_PHIAL_EXPERIMENTATION] = "Scoperta Fiala",
        [CraftSim.CONST.TEXT.STAT_POTION_EXPERIMENTATION] = "Scoperta Pozione",

        -- Profit Breakdown Tooltips
        [CraftSim.CONST.TEXT.RESOURCEFULNESS_EXPLANATION_TOOLTIP] =
        "Parsimonia si attiva separatamente per ogni tipo di reagente, permettendo di risparmiarne il 30% della quantità.\n\nIl risparmio medio è uguale alla somma del costo dei reagenti\nmoltiplicata per la probabilità che si attivi Parsimonia e per la percentuale di risparmio.\nParsimonia si può anche attivare per tutti i reagenti contemporaneamente, permettendo di risparmiare molto in rare occasioni.",
        [CraftSim.CONST.TEXT.RECIPE_DIFFICULTY_EXPLANATION_TOOLTIP] =
        "La Difficoltà ricetta determina quali sono le soglie di Competenza necessaria per le varie qualità.\n\nPer ricette con 5 qualità, le soglie di Competenza sono 20%, 50%, 80% e 100% della Difficoltà ricetta.\nPer ricette con 3 qualità, le soglie di Competenza sono 50% e 100% della Difficoltà ricetta.",
        [CraftSim.CONST.TEXT.MULTICRAFT_EXPLANATION_TOOLTIP] =
        "Creazione multipla ti permette di creare occasionalmente più oggetti del solito.\n\nLa quantità aggiuntiva è stimata tra 1 e 2.5y,\ndove y è la quantità che si ottiene normalmente con una singola operazione di crezione.",
        [CraftSim.CONST.TEXT.REAGENTSKILL_EXPLANATION_TOOLTIP] =
        "La qualità dei reagenti utilizzati può aumentare la Competenza fino a 40% della Difficoltà ricetta di base.\n\nSolo reagenti di Grado 1: bonus dello 0%\nSolo reagenti di Grado 2: bonus del 20%\nSolo reagenti di Grado 3: bonus del 40%\n\nLa Competenza bonus è uguale alla quantità di reagenti di ogni qualità moltiplicata per le rispettive qualità\ne per un punteggio specifico per ogni tipo di reagente.\n\nNel caso di una ricreazione, invece, la Competenza bonus ottenibile dipende anche dai reagenti utilizzati per la creazione originale e per le ricreazioni precedenti.\nIl funzionamento esatto non è conosciuto.\nComunque, CraftSim confronta internamente la Competenza raggiunta con tutti i reagenti di Grado 3 e usa quei valori per calcolare la Competenza bonus reagenti massima.",
        [CraftSim.CONST.TEXT.REAGENTFACTOR_EXPLANATION_TOOLTIP] =
        "La qualità dei reagenti utilizzati può aumentare la Competenza fino a 40% della Difficoltà ricetta di base.\n\nNel caso di una ricreazione, però, questo valore può variare in base alla qualità dei reagenti utilizzati per la creazione originale e per le ricreazioni precedenti.",

        -- Simulation Mode
        [CraftSim.CONST.TEXT.SIMULATION_MODE_NONE] = "Nessuno",
        [CraftSim.CONST.TEXT.SIMULATION_MODE_LABEL] = "Modalità Simulazione",
        [CraftSim.CONST.TEXT.SIMULATION_MODE_TITLE] = "Modalità Simulazione di CraftSim",
        [CraftSim.CONST.TEXT.SIMULATION_MODE_TOOLTIP] =
        "La Modalità Simulazione di CraftSim ti permette di sperimentare con una ricetta senza restrizioni",
        [CraftSim.CONST.TEXT.SIMULATION_MODE_OPTIONAL] = "Facoltativo #",
        [CraftSim.CONST.TEXT.SIMULATION_MODE_FINISHING] = "Finitura #",

        -- Details Frame
        [CraftSim.CONST.TEXT.RECIPE_DIFFICULTY_LABEL] = "Difficoltà ricetta: ",
        [CraftSim.CONST.TEXT.MULTICRAFT_LABEL] = "Creazione multipla: ",
        [CraftSim.CONST.TEXT.RESOURCEFULNESS_LABEL] = "Parsimonia: ",
        [CraftSim.CONST.TEXT.RESOURCEFULNESS_BONUS_LABEL] = "Moltiplicatore reagenti risparmiati: ",
        [CraftSim.CONST.TEXT.REAGENT_QUALITY_BONUS_LABEL] = "Competenza bonus reagenti: ",
        [CraftSim.CONST.TEXT.REAGENT_QUALITY_MAXIMUM_LABEL] = "Competenza bonus reagenti massima: ",
        [CraftSim.CONST.TEXT.EXPECTED_QUALITY_LABEL] = "Qualità garantita: ",
        [CraftSim.CONST.TEXT.NEXT_QUALITY_LABEL] = "Qualità superiore: ",
        [CraftSim.CONST.TEXT.MISSING_SKILL_LABEL] = "Competenza mancante: ",
        [CraftSim.CONST.TEXT.SKILL_LABEL] = "Competenza: ",
        [CraftSim.CONST.TEXT.MULTICRAFT_BONUS_LABEL] = "Moltiplicatore oggetti aggiuntivi: ",

        -- Statistics
        [CraftSim.CONST.TEXT.STATISTICS_CDF_EXPLANATION] =
            "Questo viene calcolato usando l'approssimazione di 'abramowitz e stegun' (1985) della Funziona di Distribuzione Cumulata (CDF)\n\n" ..
            "Noterai che questo valore è sempre attorno al 50% per una singola creazione.\n" ..
            "Questo perché la maggior parte delle volte 0 è vicino al profitto medio.\n" ..
            "E la probabilità di ottenere il valore medio della CDF è sempre 50%.\n\n" ..
            "Comunque, the rate of change può essere molto diverso tra le ricette.\n" ..
            "Se è più probabile avere un profitto positivo rispetto a uno negativo, crescerà in maniera costante.\n" ..
            "Questo è ovviamente vero anche in direzione opposta.",
        [CraftSim.CONST.TEXT.EXPLANATIONS_PROFIT_CALCULATION_EXPLANATION] =
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
        [CraftSim.CONST.TEXT.POPUP_NO_PRICE_SOURCE_SYSTEM] = "Nessuna Sorgente dei Prezzi Disponibile!",
        [CraftSim.CONST.TEXT.POPUP_NO_PRICE_SOURCE_TITLE] = "Avviso di CraftSim sulle Sorgenti dei Prezzi",
        [CraftSim.CONST.TEXT.POPUP_NO_PRICE_SOURCE_WARNING] =
        "Nessuna sorgente dei prezzi trovata!\n\nDevi installare almeno uno dei seguenti\naddon per le sorgenti dei prezzi da utilizzare\nnei calcoli di profitto di CraftSim:\n\n\n",
        [CraftSim.CONST.TEXT.POPUP_NO_PRICE_SOURCE_WARNING_SUPPRESS] = "Non mostrare di nuovo l'avviso",

        -- Reagents Frame
        [CraftSim.CONST.TEXT.REAGENT_OPTIMIZATION_TITLE] = "Ottimizzazione Materiali",
        [CraftSim.CONST.TEXT.REAGENTS_REACHABLE_QUALITY] = "Qualità raggiungibile: ",
        [CraftSim.CONST.TEXT.REAGENTS_MISSING] = "Materiali mancanti",
        [CraftSim.CONST.TEXT.REAGENTS_AVAILABLE] = "Materiali disponibioli",
        [CraftSim.CONST.TEXT.REAGENTS_CHEAPER] = "Materiali più economici",
        [CraftSim.CONST.TEXT.REAGENTS_BEST_COMBINATION] = "Miglior combinazione assegnata",
        [CraftSim.CONST.TEXT.REAGENTS_NO_COMBINATION] = "Nessuna combinazione trovata\nper incrementare la qualità",
        [CraftSim.CONST.TEXT.REAGENTS_ASSIGN] = "Assegna",

        -- Specialization Info Frame
        [CraftSim.CONST.TEXT.SPEC_INFO_TITLE] = "Info Specializzazioni di CraftSim",
        [CraftSim.CONST.TEXT.SPEC_INFO_SIMULATE_KNOWLEDGE_DISTRIBUTION] = "Simula Distribuzione Conoscenza",
        [CraftSim.CONST.TEXT.SPEC_INFO_NODE_TOOLTIP] =
        "Questa specializzazione ti fornisce le seguenti statistiche per questa ricetta:",
        [CraftSim.CONST.TEXT.SPEC_INFO_WORK_IN_PROGRESS] = "Specializzazioni non ancora ultimate",

        -- Crafting Results Frame
        [CraftSim.CONST.TEXT.CRAFT_LOG_TITLE] = "Risultati d'Artigianato di CraftSim",
        [CraftSim.CONST.TEXT.CRAFT_LOG_LOG] = "Resoconto prodotto finale",
        [CraftSim.CONST.TEXT.CRAFT_LOG_LOG_1] = "Profitto: ",
        [CraftSim.CONST.TEXT.CRAFT_LOG_LOG_2] = "Ispirazione!",
        [CraftSim.CONST.TEXT.CRAFT_LOG_LOG_3] = "Creazione multipla: ",
        [CraftSim.CONST.TEXT.CRAFT_LOG_LOG_4] = "Risorse risparmiate!: ",
        [CraftSim.CONST.TEXT.CRAFT_LOG_LOG_5] = "Possibilità: ",
        [CraftSim.CONST.TEXT.CRAFT_LOG_CRAFTED_ITEMS] = "Oggetti creati",
        [CraftSim.CONST.TEXT.CRAFT_LOG_SESSION_PROFIT] = "Profitto di sessione",
        [CraftSim.CONST.TEXT.CRAFT_LOG_RESET_DATA] = "Resetta dati",
        [CraftSim.CONST.TEXT.CRAFT_LOG_EXPORT_JSON] = "Esporta JSON",
        [CraftSim.CONST.TEXT.CRAFT_LOG_RECIPE_STATISTICS] = "Statistiche Ricetta",
        [CraftSim.CONST.TEXT.CRAFT_LOG_NOTHING] = "Nessuna creazione al momento!",
        [CraftSim.CONST.TEXT.CRAFT_LOG_CALCULATION_COMPARISON_NUM_CRAFTS_PREFIX] = "Creazioni: ",
        [CraftSim.CONST.TEXT.CRAFT_LOG_STATISTICS_2] = "Profitto Ø Previsto: ",
        [CraftSim.CONST.TEXT.CRAFT_LOG_STATISTICS_3] = "Profitto Ø Reale: ",
        [CraftSim.CONST.TEXT.CRAFT_LOG_STATISTICS_4] = "Profitto Reale: ",
        [CraftSim.CONST.TEXT.CRAFT_LOG_STATISTICS_5] = "Attivazioni - Reali/Previste: ",
        [CraftSim.CONST.TEXT.CRAFT_LOG_STATISTICS_6] = "Ispirazione: ",
        [CraftSim.CONST.TEXT.CRAFT_LOG_STATISTICS_7] = "Creazione Multipla: ",
        [CraftSim.CONST.TEXT.CRAFT_LOG_STATISTICS_8] = "- Ø Oggetti aggiuntivi: ",
        [CraftSim.CONST.TEXT.CRAFT_LOG_STATISTICS_9] = "Attivazioni Parsimonia: ",
        [CraftSim.CONST.TEXT.CRAFT_LOG_CALCULATION_COMPARISON_NUM_CRAFTS_PREFIX0] = "- Ø Risparmio: ",
        [CraftSim.CONST.TEXT.CRAFT_LOG_CALCULATION_COMPARISON_NUM_CRAFTS_PREFIX1] = "Profitto: ",
        [CraftSim.CONST.TEXT.CRAFT_LOG_SAVED_REAGENTS] = "Reagenti risparmiati",

        -- Stats Weight Frame
        [CraftSim.CONST.TEXT.STAT_WEIGHTS_TITLE] = "Profitto Medio di CraftSim",
        [CraftSim.CONST.TEXT.EXPLANATIONS_TITLE] = "Spiegazioni del Profitto Medio di CraftSim",
        [CraftSim.CONST.TEXT.STAT_WEIGHTS_SHOW_EXPLANATION_BUTTON] = "Mostra Spiegazioni",
        [CraftSim.CONST.TEXT.STAT_WEIGHTS_HIDE_EXPLANATION_BUTTON] = "Chiudi Spiegazioni",
        [CraftSim.CONST.TEXT.STAT_WEIGHTS_SHOW_STATISTICS_BUTTON] = "Mostra Statistiche",
        [CraftSim.CONST.TEXT.STAT_WEIGHTS_HIDE_STATISTICS_BUTTON] = "Chiudi Statistiche",
        [CraftSim.CONST.TEXT.STAT_WEIGHTS_PROFIT_CRAFT] = "Ø Profitto/Creazione: ",
        [CraftSim.CONST.TEXT.EXPLANATIONS_BASIC_PROFIT_TAB] = "Basi del calcolo del Profitto",

        -- Cost Details Frame
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_TITLE] = "Dettaglio Costi di CraftSim",
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_EXPLANATION] =
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
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_CRAFTING_COSTS] = "Costi di creazione: ",
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_ITEM_HEADER] = "Oggetto",
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_AH_PRICE_HEADER] = "Prezzo AH",
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_OVERRIDE_HEADER] = "Prezzo Personalizzato",
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_CRAFTING_HEADER] = "Dati Salvati",
        [CraftSim.CONST.TEXT.COST_OPTIMIZATION_USED_SOURCE] = "Sorgente",

        -- Statistics Frame
        [CraftSim.CONST.TEXT.STATISTICS_TITLE] = "Statistiche di CraftSim",
        [CraftSim.CONST.TEXT.STATISTICS_EXPECTED_PROFIT] = "Profitto previsto (μ)",
        [CraftSim.CONST.TEXT.STATISTICS_CHANCE_OF] = "Probabilità di ",
        [CraftSim.CONST.TEXT.STATISTICS_PROFIT] = "Profitto",
        [CraftSim.CONST.TEXT.STATISTICS_AFTER] = " dopo",
        [CraftSim.CONST.TEXT.STATISTICS_CRAFTS] = "Creazioni: ",
        [CraftSim.CONST.TEXT.STATISTICS_QUALITY_HEADER] = "Qualità",
        [CraftSim.CONST.TEXT.STATISTICS_CHANCE_HEADER] = "Probabilità",
        [CraftSim.CONST.TEXT.STATISTICS_EXPECTED_CRAFTS_HEADER] = "Creazioni previste",
        [CraftSim.CONST.TEXT.STATISTICS_MULTICRAFT_HEADER] = "Creazioni multiple",
        [CraftSim.CONST.TEXT.STATISTICS_RESOURCEFULNESS_HEADER] = "Parsimonia",
        [CraftSim.CONST.TEXT.STATISTICS_HSV_NEXT] = "HSV Succ.",
        [CraftSim.CONST.TEXT.STATISTICS_HSV_SKIP] = "HSV Salto",
        [CraftSim.CONST.TEXT.STATISTICS_EXPECTED_PROFIT_HEADER] = "Profitto previsto",
        [CraftSim.CONST.TEXT.PROBABILITY_TABLE_TITLE] = "Tabella delle Probabilità della Ricetta",
        [CraftSim.CONST.TEXT.STATISTICS_EXPECTED_COSTS_HEADER] = "Ø Costo Previsto per Oggetto",
        [CraftSim.CONST.TEXT.STATISTICS_EXPECTED_COSTS_WITH_RETURN_HEADER] = "Con Ø di Reso",

        -- Price Details Frame
        [CraftSim.CONST.TEXT.COST_OVERVIEW_TITLE] = "Dettaglio Prezzi di CraftSim",
        [CraftSim.CONST.TEXT.PRICE_DETAILS_INV_AH] = "Inv/AH",
        [CraftSim.CONST.TEXT.PRICE_DETAILS_ITEM] = "Oggetto",
        [CraftSim.CONST.TEXT.PRICE_DETAILS_PRICE_ITEM] = "Prezzo/Oggetto",
        [CraftSim.CONST.TEXT.PRICE_DETAILS_PROFIT_ITEM] = "Profitto/Oggetto",

        -- Price Override Frame
        [CraftSim.CONST.TEXT.PRICE_OVERRIDE_TITLE] = "Prezzi Personalizzati di CraftSim",
        [CraftSim.CONST.TEXT.PRICE_OVERRIDE_REQUIRED_REAGENTS] = "Reagenti Obbligatori",
        [CraftSim.CONST.TEXT.PRICE_OVERRIDE_OPTIONAL_REAGENTS] = "Reagenti Facoltativi",
        [CraftSim.CONST.TEXT.PRICE_OVERRIDE_FINISHING_REAGENTS] = "Reagenti di Finitura",
        [CraftSim.CONST.TEXT.PRICE_OVERRIDE_RESULT_ITEMS] = "Oggetti Risultanti",
        [CraftSim.CONST.TEXT.PRICE_OVERRIDE_ACTIVE_OVERRIDES] = "Prezzi Personalizzati Attivi",
        [CraftSim.CONST.TEXT.PRICE_OVERRIDE_ACTIVE_OVERRIDES_TOOLTIP] =
        "'(come risultato)' -> Prezzi Personalizzati considerati solamente quando l'oggetto è il risultato di una ricetta.",
        [CraftSim.CONST.TEXT.PRICE_OVERRIDE_CLEAR_ALL] = "Cancella Tutti",
        [CraftSim.CONST.TEXT.PRICE_OVERRIDE_SAVE] = "Salva",
        [CraftSim.CONST.TEXT.PRICE_OVERRIDE_SAVED] = "Salvato",
        [CraftSim.CONST.TEXT.PRICE_OVERRIDE_REMOVE] = "Rimuovi",

        -- Recipe Scan Frame
        [CraftSim.CONST.TEXT.RECIPE_SCAN_TITLE] = "Scansione Ricette di CraftSim",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_MODE] = "Modalità Scansione",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_SCAN_RECIPIES] = "Scansiona Ricette",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_SCAN_CANCEL] = "Annulla",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_SCANNING] = "Scansione",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_INCLUDE_NOT_LEARNED] = "Includi non apprese",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_INCLUDE_NOT_LEARNED_TOOLTIP] =
        "Include le ricette che non hai appreso nella scansione.",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_INCLUDE_SOULBOUND] = "Includi vincolate",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_INCLUDE_SOULBOUND_TOOLTIP] =
        "Include le ricette vincolate nella scansione.\n\nE' consigliato modificare il prezzo (es. per simulare una commissione) nel modulo di Modifica Prezzi per gli oggetti creati con questa ricetta.",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_INCLUDE_GEAR] = "Includi equipaggiamento",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_INCLUDE_GEAR_TOOLTIP] =
        "Include le ricette di ogni forma di equipaggiamento nella scansione",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_OPTIMIZE_TOOLS] = "Ottimizza strumenti professioni",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_OPTIMIZE_TOOLS_TOOLTIP] =
        "Per ogni ricetta ottimizza i tuoi strumenti per il miglior profitto\n\n",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_OPTIMIZE_TOOLS_WARNING] =
        "Potrebbe diminuire le prestazioni durante la scansione se hai molti strumenti nell'inventario.",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_CRAFTER_HEADER] = "Artigiano",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_RECIPE_HEADER] = "Ricetta",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_LEARNED_HEADER] = "Appresa",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_AVERAGE_PROFIT_HEADER] = "Profitto medio",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_TOP_GEAR_HEADER] = "Strumenti",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_INV_AH_HEADER] = "Inv/AH",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_SORT_BY_MARGIN] = "Ordina per % di profitto",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_SORT_BY_MARGIN_TOOLTIP] =
        "Ordina la lisa dei profitti per profitto relativo al costo di creazione.\n(Richiede una nuova scansione)",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_USE_INSIGHT_CHECKBOX] = "Usa " .. f.bb("Consapevolezza Illustre"),
        [CraftSim.CONST.TEXT.RECIPE_SCAN_USE_INSIGHT_CHECKBOX_TOOLTIP] = "Usa " ..
            f.bb("Consapevolezza Illustre") ..
            " o\n" ..
            f.bb("Consapevolezza Illustre Minore") .. " come reagente opzionale per le ricette che lo permettono",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_ONLY_FAVORITES_CHECKBOX] = "Solo preferiti",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_ONLY_FAVORITES_CHECKBOX_TOOLTIP] = "Scansiona solo le tue ricette preferite",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_EQUIPPED] = "Equipaggiato",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_MODE_OPTIMIZE] = "Ottimizza",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_EXPANSION_FILTER_BUTTON] = "Filtri espansione",

        -- Recipe Top Gear
        [CraftSim.CONST.TEXT.TOP_GEAR_TITLE] = "Ottimizzazione Strumenti",
        [CraftSim.CONST.TEXT.TOP_GEAR_AUTOMATIC] = "Automatico",
        [CraftSim.CONST.TEXT.TOP_GEAR_AUTOMATIC_TOOLTIP] =
        "Simula automaticamente i migliori strumenti in base alla modalità selezionata ogni volta che si cambia ricetta.\n\nDisabilitando questa impostazione possono aumentare le prestazioni.",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIMULATE] = "Simula",
        [CraftSim.CONST.TEXT.TOP_GEAR_EQUIP] = "Equipaggia",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIMULATE_QUALITY] = "Qualità",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIMULATE_EQUIPPED] = "Strumenti migliori equipaggiati",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIMULATE_PROFIT_DIFFERENCE] = "Ø Differenza Profitto\n",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIMULATE_NEW_MUTLICRAFT] = "Nuova Creazione Multipla\n",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIMULATE_NEW_CRAFTING_SPEED] = "Nuova Velocità di Creazione\n",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIMULATE_NEW_RESOURCEFULNESS] = "Nuova Parsimonia\n",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIMULATE_NEW_SKILL] = "Nuova Competenza\n",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIMULATE_UNHANDLED] = "Simulazione non gestita",

        [CraftSim.CONST.TEXT.TOP_GEAR_SIM_MODES_PROFIT] = "Max Profitto",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIM_MODES_SKILL] = "Max Competenza",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIM_MODES_MULTICRAFT] = "Max Creazione Multipla",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIM_MODES_RESOURCEFULNESS] = "Max Parsimonia",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIM_MODES_CRAFTING_SPEED] = "Max Velocità Creazione",

        -- Options
        [CraftSim.CONST.TEXT.OPTIONS_TITLE] = "Opzioni di CraftSim",
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_TAB] = "Generale",
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_PRICE_SOURCE] = "Sorgenti dei Prezzi",
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_CURRENT_PRICE_SOURCE] = "Attuale Sorgente dei Prezzi: ",
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_NO_PRICE_SOURCE] = "Nessun addon supportato di Sorgente Prezzi caricato!",
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_SHOW_PROFIT] = "Mostra Percentuale di Profitto",
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_SHOW_PROFIT_TOOLTIP] =
        "Mostra anche la percentuale di profitto sul costo di creazione di fianco al profitto in Oro",
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_REMEMBER_LAST_RECIPE] = "Ricorda ultima ricetta",
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_REMEMBER_LAST_RECIPE_TOOLTIP] =
        "Riapre l'ultima ricetta selezionata quando si riapre la finestra della professione",
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_SUPPORTED_PRICE_SOURCES] = "Sorgenti dei Prezzi supportate:",
        [CraftSim.CONST.TEXT.OPTIONS_PERFORMANCE_RAM] = "Abilita pulizia RAM durante la creazione",
        [CraftSim.CONST.TEXT.OPTIONS_PERFORMANCE_RAM_TOOLTIP] =
        "Quando abilitato, CraftSim eliminerà dalla RAM i dati inutilizzati ogni numero di oggetti creati specificato per prevenire l'aumento della memoria occupata.\nL'aumento di memoria occupata può anche avvenire a causa di altri addon diversi da CraftSim.\nLa pulizia riguarda tutta la RAM utilizzata dagli addon di WOW.",
        [CraftSim.CONST.TEXT.OPTIONS_MODULES_TAB] = "Moduli",
        [CraftSim.CONST.TEXT.OPTIONS_PROFIT_CALCULATION_TAB] = "Calcolo del Profitto",
        [CraftSim.CONST.TEXT.OPTIONS_CRAFTING_TAB] = "Ottimizzazione",
        [CraftSim.CONST.TEXT.OPTIONS_TSM_RESET] = "Resetta",
        [CraftSim.CONST.TEXT.OPTIONS_TSM_INVALID_EXPRESSION] = "Espressione non valida",
        [CraftSim.CONST.TEXT.OPTIONS_TSM_VALID_EXPRESSION] = "Espressione valida",
        [CraftSim.CONST.TEXT.OPTIONS_MODULES_REAGENT_OPTIMIZATION] = "Modulo Ottimizzazione Materiali",
        [CraftSim.CONST.TEXT.OPTIONS_MODULES_AVERAGE_PROFIT] = "Modulo Profitto Medio",
        [CraftSim.CONST.TEXT.OPTIONS_MODULES_TOP_GEAR] = "Modulo Ottimizzazione Strumenti",
        [CraftSim.CONST.TEXT.OPTIONS_MODULES_COST_OVERVIEW] = "Modulo Dettaglio Prezzi",
        [CraftSim.CONST.TEXT.OPTIONS_MODULES_SPECIALIZATION_INFO] = "Modulo Info Specializzazioni",
        [CraftSim.CONST.TEXT.OPTIONS_MODULES_CUSTOMER_HISTORY_SIZE] = "Massimo numero di messaggi\nnello Storico Clienti",
        [CraftSim.CONST.TEXT.OPTIONS_PROFIT_CALCULATION_OFFSET] = "Aggiungi 1 alla soglia di Competenza",
        [CraftSim.CONST.TEXT.OPTIONS_PROFIT_CALCULATION_OFFSET_TOOLTIP] =
        "Il suggerimento dei migliori materiali proverà a raggiungere la soglia di competenza +1 invece di cercare di raggiungere la competenza esatta richiesta",
        [CraftSim.CONST.TEXT.OPTIONS_PROFIT_CALCULATION_MULTICRAFT_CONSTANT] = "Costante Creazione Multipla",
        [CraftSim.CONST.TEXT.OPTIONS_PROFIT_CALCULATION_MULTICRAFT_CONSTANT_EXPLANATION] =
        "Default: 2.5\n\nInformazioni sulle professioni raccolte da diversi giocatori durante la beta e all'inizio di Dragonflight suggeriscono che\nil numero massimo di oggetti aggiuntivi che si possono ricevere dall'attivazione di Creazione Multipla sia 1+C*y.\nDove y è la quantità base di oggetti generati in un processo di creazione e C è 2.5.\nE' comunque possibile modificare questo valore in questa sezione.",
        [CraftSim.CONST.TEXT.OPTIONS_PROFIT_CALCULATION_RESOURCEFULNESS_CONSTANT] = "Costante Parsimonia",
        [CraftSim.CONST.TEXT.OPTIONS_PROFIT_CALCULATION_RESOURCEFULNESS_CONSTANT_EXPLANATION] =
        "Default: 0.3\n\nInformazioni sulle professioni raccolte da diversi giocatori durante la beta e all'inizio di Dragonflight suggeriscono che\nla quantità media di oggetti risparmiati con Parsimonia sia il 30% della quantità richiesta.\nE' comunque possibile modificare questo valore in questa sezione.",
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_SHOW_NEWS_CHECKBOX] = "Mostra finestra con le " .. f.bb("Novità"),
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_SHOW_NEWS_CHECKBOX_TOOLTIP] = "Mostra la finestra con le ultime " ..
            f.bb("Novità") .. " di " .. f.l("CraftSim") .. " quando entri in gioco",
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_HIDE_MINIMAP_BUTTON_CHECKBOX] = "Nascondi bottone sulla minimappa",
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_HIDE_MINIMAP_BUTTON_TOOLTIP] =
            "Abilita per nascondere il bottone della minimappa di " .. f.l("CraftSim"),

        -- Control Panel
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_CRAFT_QUEUE_LABEL] = "Coda Artigianato",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_CRAFT_QUEUE_TOOLTIP] =
        "Metti in coda le tue ricette e creale tutte assieme!",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_TOP_GEAR_LABEL] = "Ottimizzazione Strumenti",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_TOP_GEAR_TOOLTIP] =
        "Mostra la miglior combinazione di strumenti per le professioni disponibile in base alla modalità scelta.",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_COST_OVERVIEW_LABEL] = "Dettaglio Prezzi",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_COST_OVERVIEW_TOOLTIP] =
        "Mostra una panoramica di prezzi e profitti in base alla qualità risultante degli oggetti.",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_AVERAGE_PROFIT_LABEL] = "Profitto Medio",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_AVERAGE_PROFIT_TOOLTIP] =
        "Mostra il profitto medio in base alle tue statistiche delle professioni e il peso in profitto delle statistiche come oro per punto.",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_REAGENT_OPTIMIZATION_LABEL] = "Ottimizzazione Materiali",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_REAGENT_OPTIMIZATION_TOOLTIP] =
        "Suggerisce i materiali più economici per raggiungere la più alta soglia di qualità/ispirazione.",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_PRICE_OVERRIDES_LABEL] = "Prezzi Personalizzati",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_PRICE_OVERRIDES_TOOLTIP] =
        "Personalizza i prezzi di qualunque materiale, materiale opzionale e risultati di creazione per tutte le ricette o per una ricetta in particolare. Puoi anche scegliere di usare i dati della sezione 'Dati Salvati' come prezzo di un oggetto.",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_SPECIALIZATION_INFO_LABEL] = "Info Specializzazioni",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_SPECIALIZATION_INFO_TOOLTIP] =
        "Mostra come le specializzazioni della tua professione influenzano questa ricetta e permette di simulare ogni possibile configurazione!",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_CRAFT_LOG_LABEL] = "Risultati Artigianato",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_CRAFT_LOG_TOOLTIP] =
        "Mostra rapporti e statistiche dei tuoi oggetti creati!",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_COST_OPTIMIZATION_LABEL] = "Dettaglio Costi",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_COST_OPTIMIZATION_TOOLTIP] =
        "Modulo che mostra dettagliate informazioni sui costi di creazione",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_RECIPE_SCAN_LABEL] = "Scansione Ricette",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_RECIPE_SCAN_TOOLTIP] =
        "Modulo che scansiona la tua lista di ricette in base a varie opzioni",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_CUSTOMER_HISTORY_LABEL] = "Storico Clienti",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_CUSTOMER_HISTORY_TOOLTIP] =
        "Modulo che mostra uno storico delle conversazioni con i clienti, gli oggetti creati e le commissioni",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_CRAFT_BUFFS_LABEL] = "Benefici Artigianato",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_CRAFT_BUFFS_TOOLTIP] =
        "Modulo che mostra i benefici di creazione attivi e quelli mancanti",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_RESET_FRAMES] = "Resetta posizioni finestre",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_OPTIONS] = "Opzioni",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_NEWS] = "Novità",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_EASYCRAFT_EXPORT] = "Esporta per " .. f.l("Easycraft"),
        [CraftSim.CONST.TEXT.CONTROL_PANEL_EASYCRAFT_EXPORTING] = "Esportazione",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_EASYCRAFT_EXPORT_NO_RECIPE_FOUND] =
        "Nessuna ricetta da esportare per l'espansione The War Within",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_FORGEFINDER_EXPORT] = "Esporta per " .. f.l("ForgeFinder"),
        [CraftSim.CONST.TEXT.CONTROL_PANEL_FORGEFINDER_EXPORTING] = "Esportazione",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_EXPORT_EXPLANATION] = f.l("wowforgefinder.com") ..
            " & " .. f.l("easycraft.io") ..
            "\nè un sito per la ricerca e l'offerta di " .. f.bb("Ordini d'Artigianato di WoW"),
        [CraftSim.CONST.TEXT.CONTROL_PANEL_DEBUG] = "Debug",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_TITLE] = "Pannello di Controllo",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_SUPPORTERS_BUTTON] = f.patreon("Sostenitori"),

        -- Supporters
        [CraftSim.CONST.TEXT.SUPPORTERS_DESCRIPTION] = f.l("Grazie a tutte queste persone eccezionali!"),
        [CraftSim.CONST.TEXT.SUPPORTERS_DESCRIPTION_2] = f.l(
            "Vuoi sostenere CraftSim e essere elencato qui con il tuo messaggio?\nConsidera una donazione <3"),
        [CraftSim.CONST.TEXT.SUPPORTERS_DATE] = "Data",
        [CraftSim.CONST.TEXT.SUPPORTERS_SUPPORTER] = "Sostenitore",
        [CraftSim.CONST.TEXT.SUPPORTERS_MESSAGE] = "Messaggio",

        -- Customer History
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_TITLE] = "Storico Clienti di CraftSim",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_DROPDOWN_LABEL] = "Scegli un cliente",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_TOTAL_TIP] = "Guadagno totale: ",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_FROM] = "Da",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_TO] = "A",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_FOR] = "Per",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_CRAFT_FORMAT] = "Creati %s per %s",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_DELETE_BUTTON] = "Rimuovi cliente",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_WHISPER_BUTTON_LABEL] = "Sussurra..",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_PURGE_NO_TIP_LABEL] = "Rimuove clienti con 0 pagamenti",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_PURGE_ZERO_TIPS_CONFIRMATION_POPUP] =
        "Sei sicuro di voler cancellare tutti i dati\ndei client con un totale di 0 pagamenti?",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_DELETE_CUSTOMER_CONFIRMATION_POPUP] =
        "Sei sicuro di voler cancellare tutti i dati\n per %s?",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_PURGE_DAYS_INPUT_LABEL] = "Intervallo di auto-cancellazione (Giorni)",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_PURGE_DAYS_INPUT_TOOLTIP] =
        "CraftSim cancellerà tutti i clienti con 0 pagamenti quando entrerai in gioco dopo X giorni dall'ultima cancellazione.\nSe impostato a 0, CraftSim non cancellerà mai automaticamente.",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_CUSTOMER_HEADER] = "Cliente",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_TOTAL_TIP_HEADER] = "Totale pagamenti",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_CRAFT_HISTORY_DATE_HEADER] = "Data",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_CRAFT_HISTORY_RESULT_HEADER] = "Risultato",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_CRAFT_HISTORY_TIP_HEADER] = "Pagamento",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_CRAFT_HISTORY_CUSTOMER_REAGENTS_HEADER] = "Reagenti cliente",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_CRAFT_HISTORY_CUSTOMER_NOTE_HEADER] = "Note",


        -- Craft Queue
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_TITLE] = "Coda d'Artigianato di CraftSim",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_AMOUNT_LEFT_HEADER] = "In coda",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_PROFESSION_GEAR_HEADER] = "Equip professioni",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFTING_COSTS_HEADER] = "Costi creazione",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL] = "Crea",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL_WRONG_GEAR] = "Strumenti sbagliati",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL_NO_REAGENTS] = "Nessun materiale",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_ADD_OPEN_RECIPE_BUTTON_LABEL] = "Aggiungi ricetta selezionata",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_CLEAR_ALL_BUTTON_LABEL] = "Cancella tutto",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_FAVORITES_BUTTON_LABEL] = "Rifornimento da Scansione Ricette",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL_WRONG_PROFESSION] = "Professione sbagliata",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL_ON_COOLDOWN] = "In cooldown",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL_WRONG_CRAFTER] = "Artigiano sbagliato",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_NEXT_BUTTON_LABEL] = "Crea successivo",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_AVAILABLE_AMOUNT] = "Creabile",
        [CraftSim.CONST.TEXT.CRAFTQUEUE_AUCTIONATOR_SHOPPING_LIST_BUTTON_LABEL] = "Crea lista della spesa in Auctionator",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_QUEUE_TAB_LABEL] = "Coda d'Artigianato",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_TAB_LABEL] = "Opzioni di rifornimento",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_GENERAL_PROFIT_THRESHOLD_LABEL] = "Soglia di profitto:",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_SALE_RATE_INPUT_LABEL] = "Soglia tasso di vendità:",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_TSM_SALE_RATE_TOOLTIP] = string.format(
            [[
Disponibile solo quando %s è caricato!

Verrà controllato se una %s delle qualità dell'oggetto scelto ha un tasso di vendita
maggiore o uguale alla soglia configurata.
]], f.bb("TSM"), f.bb("qualunque")),
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_TSM_SALE_RATE_TOOLTIP_GENERAL] = string.format(
            [[
Disponibile solo quando %s è caricato!

Verrà controllato se una %s delle qualità dell'oggetto scelto ha un tasso di vendita
maggiore o uguale alla soglia configurata.
]], f.bb("TSM"), f.bb("qualunque")),
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_AMOUNT_LABEL] = "Quantità di rifornimento:",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_RESTOCK_TOOLTIP] = "E' la " ..
            f.bb("quantità di creazioni") ..
            " che sarà messa in coda per la ricetta.\n\nLa quantità di oggetti della qualità selezionata presenti nel tuo inventario e in banca sarà sottratta dalla quantità da rifornire",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_ENABLE_RECIPE_LABEL] = "Abilita:",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_GENERAL_OPTIONS_LABEL] = "Opzioni generali (Tutte le ricette)",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_RESTOCK_OPTIONS_ENABLE_RECIPE_TOOLTIP] =
        "Se viene deselezionato, la ricetta sarà rifornita in base alle opzioni generali",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_TOTAL_PROFIT_LABEL] = "Profitto totale:",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_TOTAL_CRAFTING_COSTS_LABEL] = "Costi di creazione totali:",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_EDIT_RECIPE_TITLE] = "Modifica ricetta",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_EDIT_RECIPE_NAME_LABEL] = "Nome Ricetta",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_EDIT_RECIPE_REAGENTS_SELECT_LABEL] = "Seleziona",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_EDIT_RECIPE_OPTIONAL_REAGENTS_LABEL] = "Reagenti Opzionali",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_EDIT_RECIPE_FINISHING_REAGENTS_LABEL] = "Reagenti di Finitura",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_EDIT_RECIPE_PROFESSION_GEAR_LABEL] = "Equip Professione",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_EDIT_RECIPE_OPTIMIZE_PROFIT_BUTTON] = "Ottimizza Profitto",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_EDIT_RECIPE_CRAFTING_COSTS_LABEL] = "Costi di creazione: ",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_EDIT_RECIPE_AVERAGE_PROFIT_LABEL] = "Profitto medio: ",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_EDIT_RECIPE_RESULTS_LABEL] = "Risultati",

        -- craft buffs

        [CraftSim.CONST.TEXT.CRAFT_BUFFS_TITLE] = "Benefici d'Artigianato di CraftSim",
        [CraftSim.CONST.TEXT.CRAFT_BUFFS_SIMULATE_BUTTON] = "Simula Benefici",
        [CraftSim.CONST.TEXT.CRAFT_BUFF_CHEFS_HAT_TOOLTIP] = f.bb("Giocattolo di Wrath of the Lich King.") ..
            "\nRichiede l'abilità di cucina di Northrend\nImposta la velocità di creazione a " .. f.g("0.5 secondi"),

        -- static popups
        [CraftSim.CONST.TEXT.STATIC_POPUPS_YES] = "Si",
        [CraftSim.CONST.TEXT.STATIC_POPUPS_NO] = "No",
    }
end
