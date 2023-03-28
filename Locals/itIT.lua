AddonName, CraftSim = ...

CraftSim.LOCAL_IT = {}

function CraftSim.LOCAL_IT:GetData()
    local f = CraftSim.UTIL:GetFormatter()
    return {
        -- REQUIRED:
        [CraftSim.CONST.TEXT.STAT_INSPIRATION] = "Ispirazione",
        [CraftSim.CONST.TEXT.STAT_MULTICRAFT] = "Creazione multipla",
        [CraftSim.CONST.TEXT.STAT_RESOURCEFULNESS] = "Parsimonia",
        [CraftSim.CONST.TEXT.STAT_CRAFTINGSPEED] = "Velocità di creazione",
        [CraftSim.CONST.TEXT.EQUIP_MATCH_STRING] = "Equipaggia:",
        [CraftSim.CONST.TEXT.ENCHANTED_MATCH_STRING] = "Incantato:",

        -- OPTIONAL (Defaulting to EN if not available):
        -- Other Statnames

        [CraftSim.CONST.TEXT.STAT_SKILL] = "Competenza",
        [CraftSim.CONST.TEXT.STAT_MULTICRAFT_BONUS] = "Moltiplicatore oggetti aggiuntivi",
        [CraftSim.CONST.TEXT.STAT_RESOURCEFULNESS_BONUS] = "Moltiplicatore reagenti risparmiati",
        [CraftSim.CONST.TEXT.STAT_INSPIRATION_BONUS] = "Competenza bonus Ispirazione",
        [CraftSim.CONST.TEXT.STAT_CRAFTINGSPEED_BONUS] = "Velocità di creazione",
        [CraftSim.CONST.TEXT.STAT_PHIAL_EXPERIMENTATION] = "Scoperta Fiala",
        [CraftSim.CONST.TEXT.STAT_POTION_EXPERIMENTATION] = "Scoperta Pozione",

        -- Profit Breakdown Tooltips
        [CraftSim.CONST.TEXT.RESOURCEFULNESS_EXPLANATION_TOOLTIP] = "Parsimonia si attiva separatamente per ogni tipo di reagente, permettendo di risparmiarne il 30% della quantità.\n\nIl risparmio medio è uguale alla somma del costo dei reagenti\nmoltiplicata per la probabilità che si attivi Parsimonia e per la percentuale di risparmio.\nParsimonia si può anche attivare per tutti i reagenti contemporaneamente, permettendo di risparmiare molto in rare occasioni.",
        [CraftSim.CONST.TEXT.MULTICRAFT_ADDITIONAL_ITEMS_EXPLANATION_TOOLTIP] = "Questo numero indica la quantità media di oggetti aggiuntivi creati via Creazione multipla.\n\nCiò tiene in considerazione la probabilità di Creazione multipla e presuppone che (1-2.5y)*x oggetti aggiuntivi siano creati,\ndove x è qualsiasi bonus ottenuto dalle Specializzazioni mentre y è la media base di oggetti creati\ncon una singola operazione di creazione.",
        [CraftSim.CONST.TEXT.MULTICRAFT_ADDITIONAL_ITEMS_VALUE_EXPLANATION_TOOLTIP] = "Questo numero indica la quantità media di oggetti aggiuntivi creati via Creazione multipla\nmoltiplicato per il prezzo di vendita dell'oggetto creato di qualità garantita.",
        [CraftSim.CONST.TEXT.MULTICRAFT_ADDITIONAL_ITEMS_HIGHER_VALUE_EXPLANATION_TOOLTIP] = "Questo numero indica la quantità media di oggetti aggiuntivi creati via Creazione multipla\nquando si attiva Ispirazione moltiplicato per il prezzo di vendita dell'oggetto creato di qualità superiore, raggiunta via Ispirazione.",
        [CraftSim.CONST.TEXT.MULTICRAFT_ADDITIONAL_ITEMS_HIGHER_QUALITY_EXPLANATION_TOOLTIP] = "Questo numero indica la quantità media di oggetti aggiuntivi creati via Creazione multipla\nquando si attiva Ispirazione.\n\nCiò tiene in considerazione sia Creazione multipla sia Ispirazione e riflette\nla quantità di oggetti aggiuntivi creati quando si attivano entrambe contemporaneamente.",
        [CraftSim.CONST.TEXT.INSPIRATION_ADDITIONAL_ITEMS_EXPLANATION_TOOLTIP] = "Questo numero indica la quantità media di oggetti creati di qualità garantita senza Ispirazione.",
        [CraftSim.CONST.TEXT.INSPIRATION_ADDITIONAL_ITEMS_HIGHER_QUALITY_EXPLANATION_TOOLTIP] = "Questo numero indica la quantità media di oggetti creati di qualità superiore via Ispirazione.",
        [CraftSim.CONST.TEXT.INSPIRATION_ADDITIONAL_ITEMS_VALUE_EXPLANATION_TOOLTIP] = "Questo numero indica la quantità media di oggetti creati di qualità garantita\nmoltiplicata per il prezzo di vendita dell'oggetto creato di qualità garantita.",
        [CraftSim.CONST.TEXT.INSPIRATION_ADDITIONAL_ITEMS_HIGHER_VALUE_EXPLANATION_TOOLTIP] = "Questo numero indica la quantità media di ogetti creati di qualità superiore via Ispirazione\nmoltiplicata per il prezzo di vendita dell'oggetto creato di qualità superiore.",

        [CraftSim.CONST.TEXT.RECIPE_DIFFICULTY_EXPLANATION_TOOLTIP] = "La Difficoltà ricetta determina quali sono le soglie di Competenza necessaria per le varie qualità.\n\nPer ricette con 5 qualità, le soglie di Competenza sono 20%, 50%, 80% e 100% della Difficoltà ricetta.\nPer ricette con 3 qualità, le soglie di Competenza sono 50% e 100% della Difficoltà ricetta.",
        [CraftSim.CONST.TEXT.INSPIRATION_EXPLANATION_TOOLTIP] = "L'Ispirazione ti permette di ottenere occasionalmente Competenza bonus quando si crea.\n\nQuando la Competenza bonus ottenuta via Ispirazione permette di andare oltre la soglia per la qualità successiva,\nsi possono ottenere creazioni di qualità superiore.\nPer ricette con 5 qualità, la Competenza bonus è pari a un sesto (16.67%) della Difficoltà ricetta di base.\nPer ricette con 3 qualità, la Competenza bonus è pari a un terzo (33.33%) della Difficoltà ricetta di base.",
        [CraftSim.CONST.TEXT.INSPIRATION_SKILL_EXPLANATION_TOOLTIP] = "Questa è la Competenza bonus che ottieni quando si attiva Ispirazione.\n\nSe la somma tra la Competenza attuale e la Competenza bonus raggiungono la soglia\ndella qualità successiva, riuscirai a creare un oggetto di qualità superiore.",
        [CraftSim.CONST.TEXT.MULTICRAFT_EXPLANATION_TOOLTIP] = "Creazione multipla ti permette di creare occasionalmente più oggetti del solito.\n\nLa quantità aggiuntiva è stimata tra 1 e 2.5y,\ndove y è la quantità che si ottiene normalmente con una singola operazione di crezione.",
        [CraftSim.CONST.TEXT.REAGENTSKILL_EXPLANATION_TOOLTIP] = "La qualità dei reagenti utilizzati può aumentare la Competenza fino a 25% della Difficoltà ricetta di base.\n\nSolo reagenti di Grado 1: bonus dello 0%\nSolo reagenti di Grado 2: bonus del 12.5%\nSolo reagenti di Grado 3: bonus del 25%\n\nLa Competenza bonus è uguale alla quantità di reagenti di ogni qualità moltiplicata per le rispettive qualità\ne per un punteggio specifico per ogni tipo di reagente.\n\nNel caso di una ricreazione, invece, la Competenza bonus ottenibile dipende anche dai reagenti utilizzati per la creazione originale e per le ricreazioni precedenti.\nIl funzionamento esatto non è conosciuto.\nComunque, CraftSim confronta internamente la Competenza raggiunta con tutti i reagenti di Grado 3 e usa quei valori per calcolare la Competenza bonus reagenti massima.",
        [CraftSim.CONST.TEXT.REAGENTFACTOR_EXPLANATION_TOOLTIP] = "La qualità dei reagenti utilizzati può aumentare la Competenza fino a 25% della Difficoltà ricetta di base.\n\nNel caso di una ricreazione, però, questo valore può variare in base alla qualità dei reagenti utilizzati per la creazione originale e per le ricreazioni precedenti.",

        -- Simulation Mode
        [CraftSim.CONST.TEXT.SIMULATION_MODE_LABEL] = "Modalità Simulazione",
        [CraftSim.CONST.TEXT.SIMULATION_MODE_TITLE] = "Modalità Simulazione di CraftSim",
        [CraftSim.CONST.TEXT.SIMULATION_MODE_TOOLTIP] = "La Modalità Simulazione di CraftSim ti permette di sperimentare con una ricetta senza restrizioni",

        -- Details Frame
        [CraftSim.CONST.TEXT.RECIPE_DIFFICULTY_LABEL] = "Difficoltà ricetta: ",
        [CraftSim.CONST.TEXT.INSPIRATION_LABEL] = "Ispirazione: ",
        [CraftSim.CONST.TEXT.INSPIRATION_SKILL_LABEL] = "Competenza bonus: ",  -- Ideally, it should be "Competenza bonus Ispirazione" but there is not enough space for it.
        [CraftSim.CONST.TEXT.MULTICRAFT_LABEL] = "Creazione multipla: ",
        [CraftSim.CONST.TEXT.RESOURCEFULNESS_LABEL] = "Parsimonia: ",
        [CraftSim.CONST.TEXT.RESOURCEFULNESS_BONUS_LABEL] = "Moltiplicatore reagenti risparmiati: ",
        [CraftSim.CONST.TEXT.MATERIAL_QUALITY_BONUS_LABEL] = "Competenza bonus reagenti: ",
        [CraftSim.CONST.TEXT.MATERIAL_QUALITY_MAXIMUM_LABEL] = "Competenza bonus reagenti massima: ",
        [CraftSim.CONST.TEXT.EXPECTED_QUALITY_LABEL] = "Qualità garantita: ",
        [CraftSim.CONST.TEXT.NEXT_QUALITY_LABEL] = "Qualità superiore: ",
        [CraftSim.CONST.TEXT.MISSING_SKILL_LABEL] = "Competenza mancante: ",
        [CraftSim.CONST.TEXT.MISSING_SKILL_INSPIRATION_LABEL] = "Competenza mancante (Ispirazione): ",
        [CraftSim.CONST.TEXT.SKILL_LABEL] = "Competenza: ",
        [CraftSim.CONST.TEXT.MULTICRAFT_BONUS_LABEL] = "Moltiplicatore oggetti aggiuntivi: ",

        -- Materials Frame
        [CraftSim.CONST.TEXT.MATERIALS_TITLE] = "Ottimizzazione Materiali",
        [CraftSim.CONST.TEXT.MATERIALS_INSPIRATION_BREAKPOINT] = "Raggiungi soglia Ispirazione",
        [CraftSim.CONST.TEXT.MATERIALS_INSPIRATION_BREAKPOINT_TOOLTIP] = "Prova a raggiungere la soglia di competenza per cui l'attivazione di ispirazione porta l'oggetto alla qualità superiore con la combinazione di materiali più economica",
        [CraftSim.CONST.TEXT.MATERIALS_REACHABLE_QUALITY] = "Qualità raggiungibile: ",
        [CraftSim.CONST.TEXT.MATERIALS_MISSING] = "Materiali mancanti",
        [CraftSim.CONST.TEXT.MATERIALS_AVAILABLE] = "Materiali disponibioli",
        [CraftSim.CONST.TEXT.MATERIALS_CHEAPER] = "Materiali più economici",
        [CraftSim.CONST.TEXT.MATERIALS_BEST_COMBINATION] = "Miglior combinazione assegnata",
        [CraftSim.CONST.TEXT.MATERIALS_NO_COMBINATION] = "Nessuna combinazione trovata\nper incrementare la qualità",

        -- Specialization Info Frame
        [CraftSim.CONST.TEXT.SPEC_INFO_TITLE] = "Info Specializzazioni di CraftSim",
        [CraftSim.CONST.TEXT.SPEC_INFO_SIMULATE_KNOWLEDGE_DISTRIBUTION] = "Simula Distribuzione Conoscenza",
        [CraftSim.CONST.TEXT.SPEC_INFO_NODE_TOOLTIP] = "Questa specializzazione ti fornisce le seguenti statistiche per questa ricetta:",
        [CraftSim.CONST.TEXT.SPEC_INFO_WORK_IN_PROGRESS] = "Specializzazioni non ancora ultimate",

        -- Crafting Results Frame
        [CraftSim.CONST.TEXT.CRAFT_RESULTS_TITLE] = "Risultati Creazione di CraftSim",
        [CraftSim.CONST.TEXT.CRAFT_RESULTS_LOG] = "Resoconto di creazione",
        [CraftSim.CONST.TEXT.CRAFT_RESULTS_LOG_1] = "Profitto: ",
        [CraftSim.CONST.TEXT.CRAFT_RESULTS_LOG_2] = "Ispirazione!",
        [CraftSim.CONST.TEXT.CRAFT_RESULTS_LOG_3] = "Creazione multipla: ",
        [CraftSim.CONST.TEXT.CRAFT_RESULTS_LOG_4] = "Risorse risparmiate!: ",
        [CraftSim.CONST.TEXT.CRAFT_RESULTS_LOG_5] = "Possibilità: ",
        [CraftSim.CONST.TEXT.CRAFT_RESULTS_CRAFTED_ITEMS] = "Oggetti creati",
        [CraftSim.CONST.TEXT.CRAFT_RESULTS_SESSION_PROFIT] = "Profitto di sessione",
        [CraftSim.CONST.TEXT.CRAFT_RESULTS_RESET_DATA] = "Resetta dati",
        [CraftSim.CONST.TEXT.CRAFT_RESULTS_EXPORT_JSON] = "Esporta JSON",
        [CraftSim.CONST.TEXT.CRAFT_RESULTS_RECIPE_STATISTICS] = "Statistiche Ricetta",
        [CraftSim.CONST.TEXT.CRAFT_RESULTS_NOTHING] = "Nessuna creazione al momento!",
        [CraftSim.CONST.TEXT.CRAFT_RESULTS_STATISTICS_1] = "Creazioni: ",
        [CraftSim.CONST.TEXT.CRAFT_RESULTS_STATISTICS_2] = "Profitto Ø Previsto: ",
        [CraftSim.CONST.TEXT.CRAFT_RESULTS_STATISTICS_3] = "Profitto Ø Reale: ",
        [CraftSim.CONST.TEXT.CRAFT_RESULTS_STATISTICS_4] = "Profitto Reale: ",
        [CraftSim.CONST.TEXT.CRAFT_RESULTS_STATISTICS_5] = "Attivazioni - Reali/Previste: ",
        [CraftSim.CONST.TEXT.CRAFT_RESULTS_STATISTICS_6] = "Ispirazione: ",
        [CraftSim.CONST.TEXT.CRAFT_RESULTS_STATISTICS_7] = "Creazione Multipla: ",
        [CraftSim.CONST.TEXT.CRAFT_RESULTS_STATISTICS_8] = "- Ø Oggetti aggiuntivi: ",
        [CraftSim.CONST.TEXT.CRAFT_RESULTS_STATISTICS_9] = "Attivazioni Parsimonia: ",
        [CraftSim.CONST.TEXT.CRAFT_RESULTS_STATISTICS_10] = "- Ø Risparmio: ",
        [CraftSim.CONST.TEXT.CRAFT_RESULTS_STATISTICS_11] = "Profitto: ",

        -- Stats Weight Frame
        [CraftSim.CONST.TEXT.STAT_WEIGHTS_TITLE] = "Profitto Medio di CraftSim",
        [CraftSim.CONST.TEXT.STAT_WEIGHTS_EXPLANATION_TITLE] = "Spiegazioni del Profitto Medio di CraftSim",
        [CraftSim.CONST.TEXT.STAT_WEIGHTS_SHOW_EXPLANATION_BUTTON] = "Mostra Spiegazioni",
        [CraftSim.CONST.TEXT.STAT_WEIGHTS_HIDE_EXPLANATION_BUTTON] = "Chiudi Spiegazioni",
        [CraftSim.CONST.TEXT.STAT_WEIGHTS_SHOW_STATISTICS_BUTTON] = "Mostra Statistiche",
        [CraftSim.CONST.TEXT.STAT_WEIGHTS_HIDE_STATISTICS_BUTTON] = "Chiudi Statistiche",
        [CraftSim.CONST.TEXT.STAT_WEIGHTS_PROFIT_CRAFT] = "Ø Profitto/Creazione: ",
        [CraftSim.CONST.TEXT.STAT_WEIGHTS_PROFIT_EXPLANATION_TAB] = "Basi del calcolo del Profitto",
        [CraftSim.CONST.TEXT.STAT_WEIGHTS_PROFIT_EXPLANATION_HSV_TAB] = "Considerazioni su HSV",

        -- Cost Details Frame
        [CraftSim.CONST.TEXT.COST_DETAILS_TITLE] = "Dettaglio Costi di CraftSim",
        [CraftSim.CONST.TEXT.COST_DETAILS_CRAFTING_COSTS] = "Costi di creazione: ",
        [CraftSim.CONST.TEXT.COST_DETAILS_ITEM_HEADER] = "Oggetto",
        [CraftSim.CONST.TEXT.COST_DETAILS_AH_PRICE_HEADER] = "Prezzo AH",
        [CraftSim.CONST.TEXT.COST_DETAILS_OVERRIDE_HEADER] = "Modifica Prezzo",
        [CraftSim.CONST.TEXT.COST_DETAILS_CRAFT_DATA_HEADER] = "Craft Data",
        [CraftSim.CONST.TEXT.COST_DETAILS_USED_SOURCE] = "Sorgente",

        -- Craft Data Frame
        [CraftSim.CONST.TEXT.CRAFT_DATA_TITLE] = "CraftSim Craft Data",

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
        [CraftSim.CONST.TEXT.STATISTICS_INSPIRATION_HEADER] = "Ispirazione",
        [CraftSim.CONST.TEXT.STATISTICS_MULTICRAFT_HEADER] = "Creazioni multiple",
        [CraftSim.CONST.TEXT.STATISTICS_RESOURCEFULNESS_HEADER] = "Parsimonia",
        [CraftSim.CONST.TEXT.STATISTICS_HSV_NEXT] = "HSV Succ.",
        [CraftSim.CONST.TEXT.STATISTICS_HSV_SKIP] = "HSV Salto",
        [CraftSim.CONST.TEXT.STATISTICS_EXPECTED_PROFIT_HEADER] = "Profitto previsto",
        [CraftSim.CONST.TEXT.PROBABILITY_TABLE_TITLE] = "Tabella delle Probabilità della Ricetta",
        [CraftSim.CONST.TEXT.PROBABILITY_TABLE_EXPLANATION] = "Questa tabella mostra tutte le possibili combinazioni di attivazioni per la ricetta corrente.\n\n" .. f.l("HSV Succ.") ..  " .. Probabilità HSV per la qualità successiva\n\n" .. f.l("HSV Salto") .. " .. Probabilità HSV di saltare una qualità grazie all'ispirazione",

        -- Customer Service Frame
        [CraftSim.CONST.TEXT.CUSTOMER_SERVICE_TITLE] = "Servizio Clienti di CraftSim",
        [CraftSim.CONST.TEXT.CUSTOMER_SERVICE_RECIPE_WHISPER] = "Sussurra Ricetta",
        [CraftSim.CONST.TEXT.CUSTOMER_SERVICE_LIVE_PREVIEW] = "Anteprima Live",
        [CraftSim.CONST.TEXT.CUSTOMER_SERVICE_WHISPER] = "Sussurra",
        [CraftSim.CONST.TEXT.CUSTOMER_SERVICE_MESSAGE_FORMAT] = "Formato Messaggio",
        [CraftSim.CONST.TEXT.CUSTOMER_SERVICE_RESET_TO_DEFAULT] = "Resetta al Default",
        [CraftSim.CONST.TEXT.CUSTOMER_SERVICE_ALLOW_CONNECTIONS] = "Permetti Connessioni",
        [CraftSim.CONST.TEXT.CUSTOMER_SERVICE_SEND_INVITE] = "Manda Invito",

        -- Price Details Frame
        [CraftSim.CONST.TEXT.PRICE_DETAILS_TITLE] = "Dettaglio Prezzi di CraftSim",
        [CraftSim.CONST.TEXT.PRICE_DETAILS_INV_AH] = "Inv/AH",
        [CraftSim.CONST.TEXT.PRICE_DETAILS_ITEM] = "Oggetto",
        [CraftSim.CONST.TEXT.PRICE_DETAILS_PRICE_ITEM] = "Prezzo/Oggetto",
        [CraftSim.CONST.TEXT.PRICE_DETAILS_PROFIT_ITEM] = "Profitto/Oggetto",

        -- Price Override Frame
        [CraftSim.CONST.TEXT.PRICE_OVERRIDE_TITLE] = "Modifica Prezzi di CraftSim",

        -- Recipe Scan Frame
        [CraftSim.CONST.TEXT.RECIPE_SCAN_TITLE] = "Scansione Ricette di CraftSim",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_MODE] = "Modalità Scansione",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_SCAN_RECIPIES] = "Scansiona Ricette",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_SCANNING] = "Scansione",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_INCLUDE_NOT_LEARNED] = "Includi non apprese",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_INCLUDE_NOT_LEARNED_TOOLTIP] = "Include le ricette che non hai appreso nella scansione.", 
        [CraftSim.CONST.TEXT.RECIPE_SCAN_INCLUDE_SOULBOUND] = "Includi vincolate",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_INCLUDE_SOULBOUND_TOOLTIP] = "Include le ricette vincolate nella scansione.\n\nE' consigliato modificare il prezzo (es. per simulare una commissione) nel modulo di Modifica Prezzi per gli oggetti creati con questa ricetta.", 
        [CraftSim.CONST.TEXT.RECIPE_SCAN_INCLUDE_GEAR] = "Includi equipaggiamento",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_INCLUDE_GEAR_TOOLTIP] = "Include le ricette di ogni forma di equipaggiamento nella scansione.", 
        [CraftSim.CONST.TEXT.RECIPE_SCAN_OPTIMIZE_TOOLS] = "Ottimizza Strumenti Professioni", 
        [CraftSim.CONST.TEXT.RECIPE_SCAN_OPTIMIZE_TOOLS_TOOLTIP] = "Per ogni ricetta ottimizza i tuoi strumenti per il miglior profitto\n\n",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_OPTIMIZE_TOOLS_WARNING] = "Potrebbe diminuire le prestazioni durante la scansione se hai molti strumenti nell'inventario.",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_RECIPE_HEADER] = "Ricetta",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_LEARNED_HEADER] = "Appresa",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_GUARANTEED_HEADER] = "Garantito",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_HIGHEST_RESULT_HEADER] = "Risultato migliore",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_AVERAGE_PROFIT_HEADER] = "Profitto medio",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_TOP_GEAR_HEADER] = "Strumenti",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_INV_AH_HEADER] = "Inv/AH",

        -- Recipe Top Gear
        [CraftSim.CONST.TEXT.TOP_GEAR_TITLE] = "Ottimizzazione Strumenti",
        [CraftSim.CONST.TEXT.TOP_GEAR_AUTOMATIC] = "Automatico",
        [CraftSim.CONST.TEXT.TOP_GEAR_AUTOMATIC_TOOLTIP] = "Simula automaticamente i migliori strumenti in base alla modalità selezionata ogni volta che si cambia ricetta.\n\nDisabilitando questa impostazione possono aumentare le prestazioni.",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIMULATE] = "Simula",
        [CraftSim.CONST.TEXT.TOP_GEAR_EQUIP] = "Equipaggia",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIMULATE_QUALITY] = "Qualità: ",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIMULATE_EQUIPPED] = "Strumenti migliori equipaggiati",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIMULATE_PROFIT_DIFFERENCE] = "Ø Differenza Profitto\n",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIMULATE_NEW_MUTLICRAFT] = "Nuova Creazione Multipla\n",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIMULATE_NEW_CRAFTING_SPEED] = "Nuova Velocità di Creazione\n",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIMULATE_NEW_RESOURCEFULNESS] = "Nuova Parsimonia\n",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIMULATE_NEW_INSPIRATION] = "Nuova Ispirazione\n",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIMULATE_NEW_SKILL] = "Nuova Competenza\n",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIMULATE_UNHANDLED] = "Simulazione non gestita",

        [CraftSim.CONST.TEXT.TOP_GEAR_SIM_MODES_PROFIT] = "Max Profitto",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIM_MODES_SKILL] = "Max Competenza",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIM_MODES_INSPIRATION] = "Max Ispirazione",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIM_MODES_MULTICRAFT] = "Max Creazione Multipla",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIM_MODES_RESOURCEFULNESS] = "Max Parsimonia",
        [CraftSim.CONST.TEXT.TOP_GEAR_SIM_MODES_CRAFTING_SPEED] = "Max Velocità Creazione",

        -- Nodes
        [CraftSim.JEWELCRAFTING_DATA.NODE_IDS.TOOLSET_MASTERY] = "Maestria col Set di Attrezzi", -- Ideally, it should be "Maestria col Set di Attrezzi da Gioielliere" but there is not enough space for it.
        [CraftSim.JEWELCRAFTING_DATA.NODE_IDS.SAVING_SLIVERS] = "Risparmio di Scheggie",
        [CraftSim.JEWELCRAFTING_DATA.NODE_IDS.BRILLIANT_BAUBLING] = "Ninnoli Brillanti",
        [CraftSim.JEWELCRAFTING_DATA.NODE_IDS.FACETING] = "Sfaccettatura",
        [CraftSim.JEWELCRAFTING_DATA.NODE_IDS.AIR] = "Aria",
        [CraftSim.JEWELCRAFTING_DATA.NODE_IDS.EARTH] = "Terra",
        [CraftSim.JEWELCRAFTING_DATA.NODE_IDS.FIRE] = "Fuoco",
        [CraftSim.JEWELCRAFTING_DATA.NODE_IDS.FROST] = "Gelo",
        [CraftSim.JEWELCRAFTING_DATA.NODE_IDS.SETTING] = "Montaggio",
        [CraftSim.JEWELCRAFTING_DATA.NODE_IDS.JEWELRY] = "Gioielli",
        [CraftSim.JEWELCRAFTING_DATA.NODE_IDS.CARVING] = "Intaglio",
        [CraftSim.JEWELCRAFTING_DATA.NODE_IDS.NECKLACES] = "Collane",
        [CraftSim.JEWELCRAFTING_DATA.NODE_IDS.RINGS] = "Anelli",
        [CraftSim.JEWELCRAFTING_DATA.NODE_IDS.IDOLS] = "Idoli",
        [CraftSim.JEWELCRAFTING_DATA.NODE_IDS.STONE] = "Pietra",
        [CraftSim.JEWELCRAFTING_DATA.NODE_IDS.ENTERPRISING] = "Intraprendenza",
        [CraftSim.JEWELCRAFTING_DATA.NODE_IDS.PROSPECTING] = "Prospezione",
        [CraftSim.JEWELCRAFTING_DATA.NODE_IDS.EXTRAVAGANCIES] = "Stravaganze",
        [CraftSim.JEWELCRAFTING_DATA.NODE_IDS.GLASSWARE] = "Vetreria",
        
        [CraftSim.TAILORING_DATA.NODE_IDS.TAILORING_MASTERY] = "Maestria del Sarto",
        [CraftSim.TAILORING_DATA.NODE_IDS.CLOTH_COLLECTION] = "Collezione di Stoffe",
        [CraftSim.TAILORING_DATA.NODE_IDS.SPARING_SEWING] = "Cucito Accorto",
        [CraftSim.TAILORING_DATA.NODE_IDS.SHREWD_STITCHERY] = "Sartoria Parsimoniosa",
        [CraftSim.TAILORING_DATA.NODE_IDS.TEXTILES] = "Tessuti",
        [CraftSim.TAILORING_DATA.NODE_IDS.SPINNING] = "Filatura",
        [CraftSim.TAILORING_DATA.NODE_IDS.WEAVING] = "Tessitura",
        [CraftSim.TAILORING_DATA.NODE_IDS.EMBROIDERY] = "Ricami",
        [CraftSim.TAILORING_DATA.NODE_IDS.DRACONIC_NEEDLEWORK] = "Cucitura Draconica",
        [CraftSim.TAILORING_DATA.NODE_IDS.AZUREWEAVE_TAILORING] = "Sartoria con Telazzurra",
        [CraftSim.TAILORING_DATA.NODE_IDS.AZUREWEAVING] = "Tessitura di Telazzurra",
        [CraftSim.TAILORING_DATA.NODE_IDS.CRONOCLOTH_TAILORING] = "Sartoria con Cronostoffa",
        [CraftSim.TAILORING_DATA.NODE_IDS.TIMEWEAVING] = "Tessitura del Tempo",
        [CraftSim.TAILORING_DATA.NODE_IDS.GARMENTCRAFTING] = "Produzione di Vestiti",
        [CraftSim.TAILORING_DATA.NODE_IDS.OUTERWEAR] = "Abbigliamenti da Esterno",
        [CraftSim.TAILORING_DATA.NODE_IDS.GLOVES] = "Guanti",
        [CraftSim.TAILORING_DATA.NODE_IDS.FOOTWEAR] = "Calzature",
        [CraftSim.TAILORING_DATA.NODE_IDS.HATS] = "Cappelli",
        [CraftSim.TAILORING_DATA.NODE_IDS.CLOAKS] = "Mantelli",
        [CraftSim.TAILORING_DATA.NODE_IDS.OUTFITS] = "Completi",
        [CraftSim.TAILORING_DATA.NODE_IDS.ROBES] = "Vesti",
        [CraftSim.TAILORING_DATA.NODE_IDS.LEGGINGS] = "Gambiere",
        [CraftSim.TAILORING_DATA.NODE_IDS.EMBELLISHMENTS] = "Abbellimenti",
        [CraftSim.TAILORING_DATA.NODE_IDS.MANTLES] = "Coprispalle",
        [CraftSim.TAILORING_DATA.NODE_IDS.ARMBANDS] = "Antibracci",
        [CraftSim.TAILORING_DATA.NODE_IDS.BELTS] = "Cinture",

        [CraftSim.ENGINEERING_DATA.NODE_IDS.OPTIMIZED_EFFICIENCY] = "Efficienza Ottimizzata",
        [CraftSim.ENGINEERING_DATA.NODE_IDS.PIECES_PARTS] = "Pezzi di Ricambio",
        [CraftSim.ENGINEERING_DATA.NODE_IDS.SCRAPPER] = "Riciclatore",
        [CraftSim.ENGINEERING_DATA.NODE_IDS.GENERALIST] = "Generalista",
        [CraftSim.ENGINEERING_DATA.NODE_IDS.EXPLOSIVES] = "Explosivi",
        [CraftSim.ENGINEERING_DATA.NODE_IDS.CREATION] = "Creazione",
        [CraftSim.ENGINEERING_DATA.NODE_IDS.SHORT_FUSE] = "Miccia Corta",
        [CraftSim.ENGINEERING_DATA.NODE_IDS.EZ_THRO] = "Maneggevolezza",
        [CraftSim.ENGINEERING_DATA.NODE_IDS.FUNCTION_OVER_FORM] = "Funziona prima della Forma",
        [CraftSim.ENGINEERING_DATA.NODE_IDS.GEAR] = "Equipaggiamento",
        [CraftSim.ENGINEERING_DATA.NODE_IDS.GEARS_FOR_GEAR] = "Ingranaggi per equipaggiamento",
        [CraftSim.ENGINEERING_DATA.NODE_IDS.UTILITY] = "Utilità",
        [CraftSim.ENGINEERING_DATA.NODE_IDS.MECHANICAL_MIND] = "Mente Meccanica",
        [CraftSim.ENGINEERING_DATA.NODE_IDS.INVENTIONS] = "Invenzioni",
        [CraftSim.ENGINEERING_DATA.NODE_IDS.NOVELTIES] = "Amenità",

        [CraftSim.BLACKSMITHING_DATA.NODE_IDS.HAMMER_CONTROL] = "Controllo del Martello",
        [CraftSim.BLACKSMITHING_DATA.NODE_IDS.SAFETY_SMITHING] = "Forgiatura in Sicurezza",
        [CraftSim.BLACKSMITHING_DATA.NODE_IDS.POIGNANT_PLANS] = "Progetti Toccanti",
        [CraftSim.BLACKSMITHING_DATA.NODE_IDS.SPECIALITY_SMITHING] = "Forgiatura Speciale",
        [CraftSim.BLACKSMITHING_DATA.NODE_IDS.TOOLSMITHING] = "Creazione di Attrezzi",
        [CraftSim.BLACKSMITHING_DATA.NODE_IDS.STONEWORK] = "Lavorazione della Pietra",
        [CraftSim.BLACKSMITHING_DATA.NODE_IDS.SMELTING] = "Fonditura",
        [CraftSim.BLACKSMITHING_DATA.NODE_IDS.WEAPON_SMITHING] = "Forgiatura di Armi",
        [CraftSim.BLACKSMITHING_DATA.NODE_IDS.BLADES] = "Lame",
        [CraftSim.BLACKSMITHING_DATA.NODE_IDS.HAFTED] = "Impugnatura",
        [CraftSim.BLACKSMITHING_DATA.NODE_IDS.SHORT_BLADES] = "Lame Corte",
        [CraftSim.BLACKSMITHING_DATA.NODE_IDS.LONG_BLADES] = "Lame Lunghe",
        [CraftSim.BLACKSMITHING_DATA.NODE_IDS.MACES_AND_HAMMERS] = "Mazze e Martelli",
        [CraftSim.BLACKSMITHING_DATA.NODE_IDS.AXES_PICKS_AND_POLEARMS] = "Asce, Picconi e Armi ad Asta",
        [CraftSim.BLACKSMITHING_DATA.NODE_IDS.ARMOR_SMITHING] = "Forgiatura d'Armature",
        [CraftSim.BLACKSMITHING_DATA.NODE_IDS.BELTS] = "Cinture",
        [CraftSim.BLACKSMITHING_DATA.NODE_IDS.BREASTPLATES] = "Pettorali Corazzati",
        [CraftSim.BLACKSMITHING_DATA.NODE_IDS.FINE_ARMOR] = "Armature di Qualità",
        [CraftSim.BLACKSMITHING_DATA.NODE_IDS.GAUNTLETS] = "Guanti Lunghi",
        [CraftSim.BLACKSMITHING_DATA.NODE_IDS.GREAVES] = "Gambiere Rinforzate",
        [CraftSim.BLACKSMITHING_DATA.NODE_IDS.HELMS] = "Elmi",
        [CraftSim.BLACKSMITHING_DATA.NODE_IDS.LARGE_PLATE_ARMOR] = "Armature a Piastre Grandi",
        [CraftSim.BLACKSMITHING_DATA.NODE_IDS.PAULDRONS] = "Paraspalle",
        [CraftSim.BLACKSMITHING_DATA.NODE_IDS.SABATONS] = "Calzari",
        [CraftSim.BLACKSMITHING_DATA.NODE_IDS.SCULPED_ARMOR] = "Armature Scolpite",
        [CraftSim.BLACKSMITHING_DATA.NODE_IDS.SHIELDS] = "Scudi",
        [CraftSim.BLACKSMITHING_DATA.NODE_IDS.VAMBRACES] = "Avambracci",

        [CraftSim.INSCRIPTION_DATA.NODE_IDS.RUNE_MASTERY] = "Maestria delle Rune",
        [CraftSim.INSCRIPTION_DATA.NODE_IDS.PERFECT_PRACTICE] = "Pratica Perfetta",
        [CraftSim.INSCRIPTION_DATA.NODE_IDS.INFINITE_DISCOVERY] = "Scoperta Infinita",
        [CraftSim.INSCRIPTION_DATA.NODE_IDS.UNDERSTANDING_FLORA] = "Comprensione Floreale",
        [CraftSim.INSCRIPTION_DATA.NODE_IDS.FLAWLESS_INKS] = "Inchiostri Impeccabili",
        [CraftSim.INSCRIPTION_DATA.NODE_IDS.ARCHIVING] = "Archiviazione",
        [CraftSim.INSCRIPTION_DATA.NODE_IDS.DARKMOON_MYSTERIES] = "Misteri di Lunacupa",
        [CraftSim.INSCRIPTION_DATA.NODE_IDS.FIRE] = "Fuoco",
        [CraftSim.INSCRIPTION_DATA.NODE_IDS.FROST] = "Gelo",
        [CraftSim.INSCRIPTION_DATA.NODE_IDS.AIR] = "Aria",
        [CraftSim.INSCRIPTION_DATA.NODE_IDS.EARTH] = "Terra",
        [CraftSim.INSCRIPTION_DATA.NODE_IDS.SHARED_KNOWLEDGE] = "Conoscenza Condivisa",
        [CraftSim.INSCRIPTION_DATA.NODE_IDS.CONTRACTS_AND_MISSIVES] = "Contratti e Missive",
        [CraftSim.INSCRIPTION_DATA.NODE_IDS.DRACONIC_TREATISES] = "Trattati Draconici",
        [CraftSim.INSCRIPTION_DATA.NODE_IDS.SCALE_SIGILS] = "Sigilli della Scaglia",
        [CraftSim.INSCRIPTION_DATA.NODE_IDS.AZURSCALE_SIGIL] = "Sigillo di Scaglie Azzurre", 
        [CraftSim.INSCRIPTION_DATA.NODE_IDS.EMBERSCALE_SIGIL] = "Sigillo di Scaglie Ardenti",
        [CraftSim.INSCRIPTION_DATA.NODE_IDS.SAGESCALE_SIGIL] = "Sigillo di Scaglie Sagge",
        [CraftSim.INSCRIPTION_DATA.NODE_IDS.BRONZESCALE_SIGIL] = "Sigillo di Scaglie di Bronzo",
        [CraftSim.INSCRIPTION_DATA.NODE_IDS.JETSCALE_SIGIL] = "Sigillo di Scaglie Travolgenti",
        [CraftSim.INSCRIPTION_DATA.NODE_IDS.RUNEBINDING] = "Vincoli Runici",
        [CraftSim.INSCRIPTION_DATA.NODE_IDS.WOODCARVING] = "Intaglio del Legno",
        [CraftSim.INSCRIPTION_DATA.NODE_IDS.PROFESSION_TOOLS] = "Attrezzi della Professione",
        [CraftSim.INSCRIPTION_DATA.NODE_IDS.STAVES] = "Bastoni",
        [CraftSim.INSCRIPTION_DATA.NODE_IDS.RUNIC_SCRIPTURE] = "Scrittura Runica",
        [CraftSim.INSCRIPTION_DATA.NODE_IDS.CODEXES] = "Codici",
        [CraftSim.INSCRIPTION_DATA.NODE_IDS.VANTUS_RUNES] = "Rune Vantus",
        [CraftSim.INSCRIPTION_DATA.NODE_IDS.FAUNA_RUNES] = "Rune Fauna",

        [CraftSim.ENCHANTING_DATA.NODE_IDS.ENCHANTMENT] = "Incantamento",
        [CraftSim.ENCHANTING_DATA.NODE_IDS.PRIMAL] = "Primordiale",
        [CraftSim.ENCHANTING_DATA.NODE_IDS.MATERIAL_MANIPULATION] = "Manipolazione della Materia",
        [CraftSim.ENCHANTING_DATA.NODE_IDS.BURNING] = "Bruciante",
        [CraftSim.ENCHANTING_DATA.NODE_IDS.EARTHEN] = "Terrigeno",
        [CraftSim.ENCHANTING_DATA.NODE_IDS.SOPHIC] = "Sofico",
        [CraftSim.ENCHANTING_DATA.NODE_IDS.FROZEN] = "Gelido",
        [CraftSim.ENCHANTING_DATA.NODE_IDS.WAFTING] = "Aleggiante",
        [CraftSim.ENCHANTING_DATA.NODE_IDS.ADAPTIVE] = "Adattivo",
        [CraftSim.ENCHANTING_DATA.NODE_IDS.ARTISTRY] = "Artisticità",
        [CraftSim.ENCHANTING_DATA.NODE_IDS.MAGICAL_REINFORCEMENT] = "Rinforzo Magico",
        [CraftSim.ENCHANTING_DATA.NODE_IDS.INSIGHT_OF_THE_BLUE] = "Consapevolezza del Blu",
        [CraftSim.ENCHANTING_DATA.NODE_IDS.DRACONIC_DISENCHANTMENT] = "Disincanto Draconico",
        [CraftSim.ENCHANTING_DATA.NODE_IDS.PRIMAL_EXTRACTION] = "Estrazione Primordiale",
        [CraftSim.ENCHANTING_DATA.NODE_IDS.RODS_RUNES_AND_RUSES] = "Verghe, Rune e Stratagemmi",
        [CraftSim.ENCHANTING_DATA.NODE_IDS.RODS_AND_WANDS] = "Verghe e Bacchette",
        [CraftSim.ENCHANTING_DATA.NODE_IDS.ILLUSORY_GOODS] = "Prodotti Illusori",
        [CraftSim.ENCHANTING_DATA.NODE_IDS.RESOURCEFUL_WRIT] = "Encomi Parsimoniosi",
        [CraftSim.ENCHANTING_DATA.NODE_IDS.INSPIRED_DEVOTION] = "Devozione Ispirata",

        [CraftSim.ALCHEMY_DATA.NODE_IDS.ALCHEMICAL_THEORY] = "Teoria Alchemica",
        [CraftSim.ALCHEMY_DATA.NODE_IDS.TRANSMUTATION] = "Trasmutazione",
        [CraftSim.ALCHEMY_DATA.NODE_IDS.CHEMICAL_SYNTHESIS] = "Sintesi Chimica",
        [CraftSim.ALCHEMY_DATA.NODE_IDS.DECAYOLOGY] = "Studio del Decadimento",
        [CraftSim.ALCHEMY_DATA.NODE_IDS.RESOURCEFUL_ROUTINES] = "Routine Parsimoniose",
        [CraftSim.ALCHEMY_DATA.NODE_IDS.INSPIRING_AMBIENCE] = "Atmosfera Ispiratrice",
        [CraftSim.ALCHEMY_DATA.NODE_IDS.PHIAL_MASTERY] = "Maestria nelle Fiale",
        [CraftSim.ALCHEMY_DATA.NODE_IDS.FROST_FORMULATED_PHIALS] = "Fiale del Gelo",
        [CraftSim.ALCHEMY_DATA.NODE_IDS.AIR_FORMULATED_PHIALS] = "Fiale dell'Aria",
        [CraftSim.ALCHEMY_DATA.NODE_IDS.PHIAL_LORE] = "Conoscenza delle Fiale",
        [CraftSim.ALCHEMY_DATA.NODE_IDS.PHIAL_EXPERIMENTATION] = "Fiala Sperimentale",
        [CraftSim.ALCHEMY_DATA.NODE_IDS.PHIAL_BATCH_PRODUCTION] = "Produzione in Lotto",
        [CraftSim.ALCHEMY_DATA.NODE_IDS.POTION_MASTERY] = "Maestria nelle Pozioni",
        [CraftSim.ALCHEMY_DATA.NODE_IDS.FROST_FORMULATED_POTIONS] = "Pozioni del Gelo",
        [CraftSim.ALCHEMY_DATA.NODE_IDS.AIR_FORMULATED_POTIONS] = "Pozioni dell'Aria",
        [CraftSim.ALCHEMY_DATA.NODE_IDS.POTION_LORE] = "Conoscenza delle Pozioni",
        [CraftSim.ALCHEMY_DATA.NODE_IDS.POTION_EXPERIMENTATION] = "Pozione Sperimentale",
        [CraftSim.ALCHEMY_DATA.NODE_IDS.POTION_BATCH_PRODUCTION] = "Produzione in Lotto",

        [CraftSim.LEATHERWORKING_DATA.NODE_IDS.LEATHERWORKING_DISCIPLINE] = "Disciplina di Conciatura",
        [CraftSim.LEATHERWORKING_DATA.NODE_IDS.SHEAR_MASTERY_OF_LEATHER] = "Maestria del Cuoio Inaudita",
        [CraftSim.LEATHERWORKING_DATA.NODE_IDS.AWL_INSPIRING_WORKS] = "Lavori Puntigliosi",
        [CraftSim.LEATHERWORKING_DATA.NODE_IDS.BONDING_AND_STITCHING] = "Legatura e Cucitura",
        [CraftSim.LEATHERWORKING_DATA.NODE_IDS.CURING_AND_TANNING] = "Indurimento e Tannatura",
        [CraftSim.LEATHERWORKING_DATA.NODE_IDS.LEATHER_ARMOR_CRAFTING] = "Creazione di Armature di Cuoio",
        [CraftSim.LEATHERWORKING_DATA.NODE_IDS.SHAPED_LEATHER_ARMOR] = "Armature di Cuoio Plasmato",
        [CraftSim.LEATHERWORKING_DATA.NODE_IDS.EMBROIDERED_LEATHER_ARMOR] = "Armatura di Cuoio Ricamato",
        [CraftSim.LEATHERWORKING_DATA.NODE_IDS.CHESTPIECES] = "Corazze",
        [CraftSim.LEATHERWORKING_DATA.NODE_IDS.HELMS] = "Elmi",
        [CraftSim.LEATHERWORKING_DATA.NODE_IDS.SHOULDERPADS] = "Spalletti",
        [CraftSim.LEATHERWORKING_DATA.NODE_IDS.WRISTWRAPS] = "Bracciali Leggeri",
        [CraftSim.LEATHERWORKING_DATA.NODE_IDS.LEGGUARDS] = "Gambali Foderati",
        [CraftSim.LEATHERWORKING_DATA.NODE_IDS.GLOVES] = "Guanti",
        [CraftSim.LEATHERWORKING_DATA.NODE_IDS.LEATHER_BELTS] = "Cinture",
        [CraftSim.LEATHERWORKING_DATA.NODE_IDS.LEATHER_BOOTS] = "Stivali",
        [CraftSim.LEATHERWORKING_DATA.NODE_IDS.MAIL_ARMOR_CRAFTING] = "Creazione di Armature di Maglia",
        [CraftSim.LEATHERWORKING_DATA.NODE_IDS.LARGE_MAIL] = "Maglia Grande",
        [CraftSim.LEATHERWORKING_DATA.NODE_IDS.INTRICATE_MAIL] = "Maglia Intricata",
        [CraftSim.LEATHERWORKING_DATA.NODE_IDS.MAIL_SHIRTS] = "Camicie di Maglia",
        [CraftSim.LEATHERWORKING_DATA.NODE_IDS.MAIL_HELMS] = "Elmi di Maglia",
        [CraftSim.LEATHERWORKING_DATA.NODE_IDS.SHOULDERGUARDS] = "Spallacci Foderati",
        [CraftSim.LEATHERWORKING_DATA.NODE_IDS.BRACES] = "Bracciali",
        [CraftSim.LEATHERWORKING_DATA.NODE_IDS.GREAVES] = "Gambiere Rinforzate",
        [CraftSim.LEATHERWORKING_DATA.NODE_IDS.GAUNTLETS] = "Guanti Lunghi",
        [CraftSim.LEATHERWORKING_DATA.NODE_IDS.MAIL_BELTS] = "Cinture",
        [CraftSim.LEATHERWORKING_DATA.NODE_IDS.MAIL_BOOTS] = "Stivali",
        [CraftSim.LEATHERWORKING_DATA.NODE_IDS.PRIMORDIAL_LEATHERWORKING] = "Conciatura Primordiale",
        [CraftSim.LEATHERWORKING_DATA.NODE_IDS.ELEMENTAL_MASTERY] = "Maestria Elementale",
        [CraftSim.LEATHERWORKING_DATA.NODE_IDS.BESTIAL_PRIMACY] = "Supremazia Bestiale",
        [CraftSim.LEATHERWORKING_DATA.NODE_IDS.DECAYING_GRASPS] = "Stretta Decadente",

        -- Control Panel
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_TOP_GEAR_LABEL] = "Ottimizzazione Strumenti",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_TOP_GEAR_TOOLTIP] = "Mostra la miglior combinazione di strumenti per le professioni disponibile in base alla modalità scelta.",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_PRICE_DETAILS_LABEL] = "Dettaglio Prezzi",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_PRICE_DETAILS_TOOLTIP] = "Mostra una panoramica di prezzi e profitti in base alla qualità risultante degli oggetti.",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_AVERAGE_PROFIT_LABEL] = "Profitto Medio",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_AVERAGE_PROFIT_TOOLTIP] = "Shows the average profit based on your profession stats and the profit stat weights as gold per point.",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_MATERIAL_OPTIMIZATION_LABEL] = "Ottimizzazione Materiali",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_MATERIAL_OPTIMIZATION_TOOLTIP] = "Suggerisce i materiali più economici per raggiungere la più alta soglia di qualità/ispirazione.",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_PRICE_OVERRIDES_LABEL] = "Modifica Prezzi",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_PRICE_OVERRIDES_TOOLTIP] = "Modifica i prezzi di qualunque materiale, materiale opzionale e risultati di creazione per tutte le ricette o per una ricetta in particolare. Puoi anche scegliere di usare di dati del 'Craft Data' come prezzo di un oggetto.",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_CRAFT_DATA_LABEL] = "Craft Data",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_CRAFT_DATA_TOOLTIP] = "Edit the saved configurations for crafting commodities of different qualities to show in tooltips and to calculate crafting costs",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_SPECIALIZATION_INFO_LABEL] = "Info Specializzazioni",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_SPECIALIZATION_INFO_TOOLTIP] = "Mostra come le specializzazioni della tua professione influenzano questa ricetta e permette di simulare ogni possibile configurazione!",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_CRAFT_RESULTS_LABEL] = "Risultati Creazione",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_CRAFT_RESULTS_TOOLTIP] = "Mostra rapporti e statistiche dei tuoi oggetti creati!",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_COST_DETAILS_LABEL] = "Dettaglio Costi",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_COST_DETAILS_TOOLTIP] = "Modulo che mostra dettagliate informazioni sui costi di creazione.",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_RECIPE_SCAN_LABEL] = "Scansione Ricette",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_RECIPE_SCAN_TOOLTIP] = "Modulo che scansiona la tua lista di ricette in base a varie opzioni.",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_CUSTOMER_SERVICE_LABEL] = "Servizio Clienti",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_CUSTOMER_SERVICE_TOOLTIP] = "Modulo che offre varie opzioni per interagire con i potenziali clienti.",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_RESET_FRAMES] = "Resetta posizioni finestre",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_OPTIONS] = "Opzioni",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_NEWS] = "Novità",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_FORGEFINDER_EXPORT] = "Export",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_DEBUG] = "Debug",
    }
end
