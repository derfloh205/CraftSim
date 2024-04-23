---@class CraftSim
local CraftSim = select(2, ...)

CraftSim.LOCAL_IT = {}

function CraftSim.LOCAL_IT:GetData()
    local f = CraftSim.GUTIL:GetFormatter()
    local cm = function(i, s) return CraftSim.MEDIA:GetAsTextIcon(i, s) end
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
        [CraftSim.CONST.TEXT.STAT_RESOURCEFULNESS_BONUS] = "Molt. reagenti risparmiati", -- Ideally, it should be "Moltiplicatore reagenti risparmiati" but there is not enough space for it.
        [CraftSim.CONST.TEXT.STAT_INSPIRATION_BONUS] = "Comp. bonus ispirazione",        -- Ideally, it should be "Competenza bonus Ispirazione" but there is not enough space for it.
        [CraftSim.CONST.TEXT.STAT_CRAFTINGSPEED_BONUS] = "Velocità di creazione",
        [CraftSim.CONST.TEXT.STAT_PHIAL_EXPERIMENTATION] = "Scoperta Fiala",
        [CraftSim.CONST.TEXT.STAT_POTION_EXPERIMENTATION] = "Scoperta Pozione",

        -- Profit Breakdown Tooltips
        [CraftSim.CONST.TEXT.RESOURCEFULNESS_EXPLANATION_TOOLTIP] =
        "Parsimonia si attiva separatamente per ogni tipo di reagente, permettendo di risparmiarne il 30% della quantità.\n\nIl risparmio medio è uguale alla somma del costo dei reagenti\nmoltiplicata per la probabilità che si attivi Parsimonia e per la percentuale di risparmio.\nParsimonia si può anche attivare per tutti i reagenti contemporaneamente, permettendo di risparmiare molto in rare occasioni.",
        [CraftSim.CONST.TEXT.MULTICRAFT_ADDITIONAL_ITEMS_EXPLANATION_TOOLTIP] =
        "Questo numero indica la quantità media di oggetti aggiuntivi creati via Creazione multipla.\n\nCiò tiene in considerazione la probabilità di Creazione multipla e presuppone che (1-2.5y)*x oggetti aggiuntivi siano creati,\ndove x è qualsiasi bonus ottenuto dalle Specializzazioni mentre y è la media base di oggetti creati\ncon una singola operazione di creazione.",
        [CraftSim.CONST.TEXT.MULTICRAFT_ADDITIONAL_ITEMS_VALUE_EXPLANATION_TOOLTIP] =
        "Questo numero indica la quantità media di oggetti aggiuntivi creati via Creazione multipla\nmoltiplicato per il prezzo di vendita dell'oggetto creato di qualità garantita.",
        [CraftSim.CONST.TEXT.MULTICRAFT_ADDITIONAL_ITEMS_HIGHER_VALUE_EXPLANATION_TOOLTIP] =
        "Questo numero indica la quantità media di oggetti aggiuntivi creati via Creazione multipla\nquando si attiva Ispirazione moltiplicato per il prezzo di vendita dell'oggetto creato di qualità superiore, raggiunta via Ispirazione.",
        [CraftSim.CONST.TEXT.MULTICRAFT_ADDITIONAL_ITEMS_HIGHER_QUALITY_EXPLANATION_TOOLTIP] =
        "Questo numero indica la quantità media di oggetti aggiuntivi creati via Creazione multipla\nquando si attiva Ispirazione.\n\nCiò tiene in considerazione sia Creazione multipla sia Ispirazione e riflette\nla quantità di oggetti aggiuntivi creati quando si attivano entrambe contemporaneamente.",
        [CraftSim.CONST.TEXT.INSPIRATION_ADDITIONAL_ITEMS_EXPLANATION_TOOLTIP] =
        "Questo numero indica la quantità media di oggetti creati di qualità garantita senza Ispirazione.",
        [CraftSim.CONST.TEXT.INSPIRATION_ADDITIONAL_ITEMS_HIGHER_QUALITY_EXPLANATION_TOOLTIP] =
        "Questo numero indica la quantità media di oggetti creati di qualità superiore via Ispirazione.",
        [CraftSim.CONST.TEXT.INSPIRATION_ADDITIONAL_ITEMS_VALUE_EXPLANATION_TOOLTIP] =
        "Questo numero indica la quantità media di oggetti creati di qualità garantita\nmoltiplicata per il prezzo di vendita dell'oggetto creato di qualità garantita.",
        [CraftSim.CONST.TEXT.INSPIRATION_ADDITIONAL_ITEMS_HIGHER_VALUE_EXPLANATION_TOOLTIP] =
        "Questo numero indica la quantità media di ogetti creati di qualità superiore via Ispirazione\nmoltiplicata per il prezzo di vendita dell'oggetto creato di qualità superiore.",

        [CraftSim.CONST.TEXT.RECIPE_DIFFICULTY_EXPLANATION_TOOLTIP] =
        "La Difficoltà ricetta determina quali sono le soglie di Competenza necessaria per le varie qualità.\n\nPer ricette con 5 qualità, le soglie di Competenza sono 20%, 50%, 80% e 100% della Difficoltà ricetta.\nPer ricette con 3 qualità, le soglie di Competenza sono 50% e 100% della Difficoltà ricetta.",
        [CraftSim.CONST.TEXT.INSPIRATION_EXPLANATION_TOOLTIP] =
        "L'Ispirazione ti permette di ottenere occasionalmente Competenza bonus quando si crea.\n\nQuando la Competenza bonus ottenuta via Ispirazione permette di andare oltre la soglia per la qualità successiva,\nsi possono ottenere creazioni di qualità superiore.\nPer ricette con 5 qualità, la Competenza bonus è pari a un sesto (16.67%) della Difficoltà ricetta di base.\nPer ricette con 3 qualità, la Competenza bonus è pari a un terzo (33.33%) della Difficoltà ricetta di base.",
        [CraftSim.CONST.TEXT.INSPIRATION_SKILL_EXPLANATION_TOOLTIP] =
        "Questa è la Competenza bonus che ottieni quando si attiva Ispirazione.\n\nSe la somma tra la Competenza attuale e la Competenza bonus raggiungono la soglia\ndella qualità successiva, riuscirai a creare un oggetto di qualità superiore.",
        [CraftSim.CONST.TEXT.MULTICRAFT_EXPLANATION_TOOLTIP] =
        "Creazione multipla ti permette di creare occasionalmente più oggetti del solito.\n\nLa quantità aggiuntiva è stimata tra 1 e 2.5y,\ndove y è la quantità che si ottiene normalmente con una singola operazione di crezione.",
        [CraftSim.CONST.TEXT.REAGENTSKILL_EXPLANATION_TOOLTIP] =
        "La qualità dei reagenti utilizzati può aumentare la Competenza fino a 25% della Difficoltà ricetta di base.\n\nSolo reagenti di Grado 1: bonus dello 0%\nSolo reagenti di Grado 2: bonus del 12.5%\nSolo reagenti di Grado 3: bonus del 25%\n\nLa Competenza bonus è uguale alla quantità di reagenti di ogni qualità moltiplicata per le rispettive qualità\ne per un punteggio specifico per ogni tipo di reagente.\n\nNel caso di una ricreazione, invece, la Competenza bonus ottenibile dipende anche dai reagenti utilizzati per la creazione originale e per le ricreazioni precedenti.\nIl funzionamento esatto non è conosciuto.\nComunque, CraftSim confronta internamente la Competenza raggiunta con tutti i reagenti di Grado 3 e usa quei valori per calcolare la Competenza bonus reagenti massima.",
        [CraftSim.CONST.TEXT.REAGENTFACTOR_EXPLANATION_TOOLTIP] =
        "La qualità dei reagenti utilizzati può aumentare la Competenza fino a 25% della Difficoltà ricetta di base.\n\nNel caso di una ricreazione, però, questo valore può variare in base alla qualità dei reagenti utilizzati per la creazione originale e per le ricreazioni precedenti.",

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
        [CraftSim.CONST.TEXT.INSPIRATION_LABEL] = "Ispirazione: ",
        [CraftSim.CONST.TEXT.INSPIRATION_SKILL_LABEL] = "Competenza bonus: ", -- Ideally, it should be "Competenza bonus Ispirazione" but there is not enough space for it.
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

        -- Customer Service Module
        [CraftSim.CONST.TEXT.HSV_EXPLANATION] =
        "HSV è l'acronimo inglese di 'Valore di competenza nascosto' ed è un aumento di difficoltà nascosto tra lo 0 e il 5% della difficoltà della tua ricetta ogni volta che crei qualcosa.\n\nQuesto valore nascosto ti può portare al livello successivo di qualità in maniera simile all'ispirazione.\n\nComunque, più vicino sei alla successiva qualità più alta è la possibilità!",

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

        [CraftSim.CONST.TEXT.EXPLANATIONS_HSV_EXPLANATION] =
            "Il " ..
            f.l("Valore di competenza nascosto (HSV)") ..
            " è un fattore casuale aggiuntivo che si presenta ogni volta che crei qualcosa.\n" ..
            "E' qualcosa che non è menzionato da nessuna parte nel gioco.\n" ..
            "Possiamo notare l'attivazione di questo valore in questo modo: Quando crei qualcosa l'" ..
            f.bb("Indicatore della qualità") ..
            "si riempie fino a un certo punto.\nQuesto può andare leggermente oltre il valore di competenza mostrato.\n " ..
            "\n" .. cm(CraftSim.MEDIA.IMAGES.HSV_EXAMPLE) .. "\n\n" ..
            "Questo valore di compentenza aggiuntivo è sempre tra lo 0% e il 5% della tua " ..
            f.bb("Difficoltà base della ricetta") ..
            ".\nQuesto significa che se una ricetta ha una difficoltà di 400 puoi ottenere fino a 20 punti competenza aggiuntivi.\n" ..
            "Varie prove ci portano a dire che questo valore sia " ..
            f.bb("unifermemente distribuito") ..
            ". Questo significa che ogni valore percentuale ha la stessa probabilità.\n" ..
            "L'" ..
            f.l("HSV") ..
            " può influenzare il profitto in maniera importante quando si è vicici a un salto di qualità!\n" ..
            "In CraftSim questo viene trattato come una attivazione addizionale, come " ..
            f.bb("Ispirazione") .. " o " .. f.bb("Multicreazione") .. ".\n" ..
            "Comunque, il suo effetto dipende dalla tuo attuale valore di competenza, la difficoltà della ricetta e\nla competenza di cui hai bisongo per raggiunere il successivo grado di qualità.\n" ..
            "Quindi CraftSim calcola la " ..
            f.bb("competenza mancante") ..
            " per raggiungere la qualità successiva e la converte in " ..
            f.bb("percentuale relativa alla difficoltà della ricetta") .. "\n\n" ..
            "Quindi per una ricetta con difficoltà 400: se hai 190 di competenza, e hai bisogno di 200 per raggiungere la qualità successiva, la competenza mancante sarà 10\n" ..
            "Per ottenere questo valore come percentuale relativa della difficoltà si può calcolare come segue: " ..
            f.bb("10 / (400 / 100)") .. " che corrisponde a " .. f.bb("2.5%") .. "\n\n" ..
            "Dobbiamo poi ricordare che l'" ..
            f.l("HSV") ..
            " può fornirci un punteggio tra lo 0% e il 5%. Quindi dobbiamo calcolare la " ..
            f.bb("probabilità di ottenere 2.5 o più") .. "\n" ..
            "quando prendiamo un numero casuale tra 0 e 5. per conoscere la probabilità che l'" ..
            f.l("HSV") .. " ci faccia raggiungere una qualità superiore.\n\n" ..
            "La statistica ci dice che la probabilità uniforme di ricevere qualcosa tra due limiti è chiamata " ..
            f.l("Distribuzione Continua Uniforme di Probabilità") .. "\n" ..
            "E questo ci porta alla formula che ci fa ottenere esattamente quanto ci serve:\n\n" ..
            f.bb("(LimiteSuperiore - X) / (LimiteSuperiore - LimiteInferiore)") .. "\n\n" ..
            "dove: " ..
            f.bb("LimiteSuperiore") ..
            " è 5, " ..
            f.bb("LimiteInferiore") ..
            " è 0, " ..
            f.bb("X") .. " è il valore uguale o superiore che desideriamo ottenere. In questo caso 2.5.\n\n" ..
            "In questo caso siamo esattamente a metà dell'" ..
            f.l("Area HSV") .. " quindi abbiamo una probabilità di:\n" ..
            f.bb("(5 - 2.5) / (5 - 0) = 0.5") ..
            "\ncioè il 50% di ottenere una qualità superiore solo grazie all'" .. f.l("HSV") .. ".\n" ..
            "Se avessimo un maggiore valore di competenza mancante avremmo meno probabilità e viceversa!\n" ..
            "Inoltre, se mancasse più del 5% la probabilità sarebbe 0 o negativa, cioè non è possibile che l'" ..
            f.l("HSV") .. " da solo possa portare a un miglioramento di qualità.\n\n" ..
            "Comunque, è possibile che tu possa raggiungere la qualità successiva quando " ..
            f.bb("Ispirazione") .. " e l'" .. f.l("HSV") .. " si attivano insieme e\n" ..
            "la competenza da " ..
            f.bb("Ispirazione") ..
            " più la competenza dall'" ..
            f.l("HSV") ..
            " ti forniscono competenza a sufficienza per raggiungere il successivo livello di qualità!.\n" ..
            "Tutto questo viene preso in considerazione da CraftSim.",

        -- Popups
        [CraftSim.CONST.TEXT.POPUP_NO_PRICE_SOURCE_SYSTEM] = "Nessuna Sorgente dei Prezzi Disponibile!",
        [CraftSim.CONST.TEXT.POPUP_NO_PRICE_SOURCE_TITLE] = "Avviso di CraftSim sulle Sorgenti dei Prezzi",
        [CraftSim.CONST.TEXT.POPUP_NO_PRICE_SOURCE_WARNING] =
        "Nessuna sorgente dei prezzi trovata!\n\nDevi installare almeno uno dei seguenti\naddon per le sorgenti dei prezzi da utilizzare\nnei calcoli di profitto di CraftSim:\n\n\n",
        [CraftSim.CONST.TEXT.POPUP_NO_PRICE_SOURCE_WARNING_SUPPRESS] = "Non mostrare di nuovo l'avviso",

        -- Materials Frame
        [CraftSim.CONST.TEXT.REAGENT_OPTIMIZATION_TITLE] = "Ottimizzazione Materiali",
        [CraftSim.CONST.TEXT.MATERIALS_INSPIRATION_BREAKPOINT] = "Raggiungi soglia Ispirazione",
        [CraftSim.CONST.TEXT.MATERIALS_INSPIRATION_BREAKPOINT_TOOLTIP] =
        "Prova a raggiungere la soglia di competenza per cui l'attivazione di ispirazione porta l'oggetto alla qualità superiore con la combinazione di materiali più economica",
        [CraftSim.CONST.TEXT.MATERIALS_REACHABLE_QUALITY] = "Qualità raggiungibile: ",
        [CraftSim.CONST.TEXT.MATERIALS_MISSING] = "Materiali mancanti",
        [CraftSim.CONST.TEXT.MATERIALS_AVAILABLE] = "Materiali disponibioli",
        [CraftSim.CONST.TEXT.MATERIALS_CHEAPER] = "Materiali più economici",
        [CraftSim.CONST.TEXT.MATERIALS_BEST_COMBINATION] = "Miglior combinazione assegnata",
        [CraftSim.CONST.TEXT.MATERIALS_NO_COMBINATION] = "Nessuna combinazione trovata\nper incrementare la qualità",
        [CraftSim.CONST.TEXT.MATERIALS_ASSIGN] = "Assegna",

        -- Specialization Info Frame
        [CraftSim.CONST.TEXT.SPEC_INFO_TITLE] = "Info Specializzazioni di CraftSim",
        [CraftSim.CONST.TEXT.SPEC_INFO_SIMULATE_KNOWLEDGE_DISTRIBUTION] = "Simula Distribuzione Conoscenza",
        [CraftSim.CONST.TEXT.SPEC_INFO_NODE_TOOLTIP] =
        "Questa specializzazione ti fornisce le seguenti statistiche per questa ricetta:",
        [CraftSim.CONST.TEXT.SPEC_INFO_WORK_IN_PROGRESS] = "Specializzazioni non ancora ultimate",

        -- Crafting Results Frame
        [CraftSim.CONST.TEXT.CRAFT_RESULTS_TITLE] = "Risultati d'Artigianato di CraftSim",
        [CraftSim.CONST.TEXT.CRAFT_RESULTS_LOG] = "Resoconto prodotto finale",
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
        [CraftSim.CONST.TEXT.CRAFT_RESULTS_SAVED_REAGENTS] = "Reagenti risparmiati",
        [CraftSim.CONST.TEXT.CRAFT_RESULTS_DISABLE_CHECKBOX] = f.l("Disabilita Registrazione Oggetti Creati"),
        [CraftSim.CONST.TEXT.CRAFT_RESULTS_DISABLE_CHECKBOX_TOOLTIP] =
            "Abilitandolo si ferma la registrazione di tutti i risultati delle creazioni e può " ..
            f.g("migliorare le performance"),

        -- Stats Weight Frame
        [CraftSim.CONST.TEXT.STAT_WEIGHTS_TITLE] = "Profitto Medio di CraftSim",
        [CraftSim.CONST.TEXT.EXPLANATIONS_TITLE] = "Spiegazioni del Profitto Medio di CraftSim",
        [CraftSim.CONST.TEXT.STAT_WEIGHTS_SHOW_EXPLANATION_BUTTON] = "Mostra Spiegazioni",
        [CraftSim.CONST.TEXT.STAT_WEIGHTS_HIDE_EXPLANATION_BUTTON] = "Chiudi Spiegazioni",
        [CraftSim.CONST.TEXT.STAT_WEIGHTS_SHOW_STATISTICS_BUTTON] = "Mostra Statistiche",
        [CraftSim.CONST.TEXT.STAT_WEIGHTS_HIDE_STATISTICS_BUTTON] = "Chiudi Statistiche",
        [CraftSim.CONST.TEXT.STAT_WEIGHTS_PROFIT_CRAFT] = "Ø Profitto/Creazione: ",
        [CraftSim.CONST.TEXT.EXPLANATIONS_BASIC_PROFIT_TAB] = "Basi del calcolo del Profitto",
        [CraftSim.CONST.TEXT.EXPLANATIONS_HSV_TAB] = "Considerazioni su HSV",

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
        [CraftSim.CONST.TEXT.STATISTICS_INSPIRATION_HEADER] = "Ispirazione",
        [CraftSim.CONST.TEXT.STATISTICS_MULTICRAFT_HEADER] = "Creazioni multiple",
        [CraftSim.CONST.TEXT.STATISTICS_RESOURCEFULNESS_HEADER] = "Parsimonia",
        [CraftSim.CONST.TEXT.STATISTICS_HSV_NEXT] = "HSV Succ.",
        [CraftSim.CONST.TEXT.STATISTICS_HSV_SKIP] = "HSV Salto",
        [CraftSim.CONST.TEXT.STATISTICS_EXPECTED_PROFIT_HEADER] = "Profitto previsto",
        [CraftSim.CONST.TEXT.PROBABILITY_TABLE_TITLE] = "Tabella delle Probabilità della Ricetta",
        [CraftSim.CONST.TEXT.PROBABILITY_TABLE_EXPLANATION] =
            "Questa tabella mostra tutte le possibili combinazioni di attivazioni per la ricetta corrente.\n\n" ..
            f.l("HSV Succ.") ..
            " .. Probabilità HSV per la qualità successiva\n\n" ..
            f.l("HSV Salto") .. " .. Probabilità HSV di saltare una qualità grazie all'ispirazione",
        [CraftSim.CONST.TEXT.STATISTICS_EXPECTED_COSTS_HEADER] = "Ø Costo Previsto per Oggetto",
        [CraftSim.CONST.TEXT.STATISTICS_EXPECTED_COSTS_WITH_RETURN_HEADER] = "Con Ø di Reso",
        [CraftSim.CONST.TEXT.STATISTICS_EXPLANATION_ICON] =
            "Questa tabella mostra il numero di oggetti medi creati (Ø) e il costo per qualità.\n\n" ..
            f.g("Probabilità") ..
            " è la probabilità di creare questo oggetto considerando la tua " ..
            f.bb("Ispirazione") ..
            " e l'" ..
            f.l("HSV") ..
            "\n\n" ..
            f.g("Creazioni Previste") ..
            " ti dice quante volte, in media, dovrai creare questa ricetta per raggiungere questa qualità\n\n" ..
            f.g("Costo Previsto per Oggetto") ..
            " ti dice, in media, il costo di un oggetto di questa qualità (questo può essere al di sotto dei costi di creazione visto che viene valutato per oggetto e considera statistiche come " ..
            f.bb("Multicreazione") ..
            "\n\n" ..
            f.g("Con Reso") ..
            " sottrae il valore di vendita (considerando un taglio dell'asta) del (numero medio) di oggetti creati di qualità inferiore fin quando non si raggiunge la qualità desiderata",


        -- Customer Service Frame
        [CraftSim.CONST.TEXT.CUSTOMER_SERVICE_TITLE] = "Servizio Clienti di CraftSim",
        [CraftSim.CONST.TEXT.CUSTOMER_SERVICE_RECIPE_WHISPER] = "Sussurra Ricetta",
        [CraftSim.CONST.TEXT.CUSTOMER_SERVICE_LIVE_PREVIEW] = "Anteprima Live",
        [CraftSim.CONST.TEXT.CUSTOMER_SERVICE_WHISPER] = "Sussurra",
        [CraftSim.CONST.TEXT.CUSTOMER_SERVICE_MESSAGE_FORMAT] = "Formato Messaggio",
        [CraftSim.CONST.TEXT.CUSTOMER_SERVICE_RESET_TO_DEFAULT] = "Resetta Messaggio",
        [CraftSim.CONST.TEXT.CUSTOMER_SERVICE_ALLOW_CONNECTIONS] = "Permetti Connessioni",
        [CraftSim.CONST.TEXT.CUSTOMER_SERVICE_SEND_INVITE] = "Manda Invito",
        [CraftSim.CONST.TEXT.CUSTOMER_SERVICE_AUTO_REPLY_EXPLANATION] =
        "Abilita la risposta automatica con i risultato più alti possibili e i costi dei materiali quando qualcuno ti sussurra il comando e il link ad un oggetto che puoi creare!",
        [CraftSim.CONST.TEXT.CUSTOMER_SERVICE_AUTO_REPLY_FORMAT_EXPLANATION] =
        "Ogni linea è un messaggio separato nella chat dei sussurri.\n\nPuoi usare le seguenti etichette per inserire informazioni sulla ricetta:\n%gc .. collegamento alla qualità garantita\n%ic .. collegamento alla qualità raggiungibile con l'ispirazione\n%insp .. la tua percentuale di ispirazione es. 18%\n%mc .. la tua percentuale di creazione multipla\n%res .. la tua percentuale di parsimonia\n%cc .. i costi di creazione\n%ccd .. i costi dettagliati per reagente utilizzato (preferibilmente in una linea separata)\n%orl .. una lista semplice di tutti i reagenti opzionali utilizzati\n%rl .. una lista semplice di tutti i reagenti obbligatori",
        [CraftSim.CONST.TEXT.CUSTOMER_SERVICE_LIVE_PREVIEW_EXPLANATION] =
        "Abilita le connessioni all'anteprima live del processo d'artigianato attraverso i 'Collegamenti di Anteprima di CraftSim'.\nChiunque abbia CraftSim e clicchi sul collegamento condiviso può connettersi in tempo reale alle tue informazioni per controllare le tue abilità d'artigianato",
        [CraftSim.CONST.TEXT.CUSTOMER_SERVICE_HIGHEST_GUARANTEED_CHECKBOX] = "Qualità garantita",
        [CraftSim.CONST.TEXT.CUSTOMER_SERVICE_HIGHEST_GUARANTEED_CHECKBOX_EXPLANATION] =
        "Controlla la più alta qualità garantita che l'artigiano può fornire con questa ricetta e ottimizza al meglio i costi di creazione.\n\nSe disabilitato, la più alta qualità raggiungibile con l'ispirazione sarà ottimizzata in base ai costi di creazione.",
        [CraftSim.CONST.TEXT.CUSTOMER_SERVICE_LIVE_PREVIEW_TITLE] = "Anteprima Live di CraftSim",
        [CraftSim.CONST.TEXT.CUSTOMER_SERVICE_CRAFTER_PROFESSION] = "Professione dell'Artigiano",
        [CraftSim.CONST.TEXT.CUSTOMER_SERVICE_LEARNED_RECIPES] = "Ricette imparate",
        [CraftSim.CONST.TEXT.CUSTOMER_SERVICE_LEARNED_RECIPES_INITIAL] = "Seleziona una ricetta",
        [CraftSim.CONST.TEXT.CUSTOMER_SERVICE_REQUESTING_UPDATE] = "Richiesta di aggiornamento",
        [CraftSim.CONST.TEXT.CUSTOMER_SERVICE_TIMEOUT] = "Timeout (Giocatore Offline?)",
        [CraftSim.CONST.TEXT.CUSTOMER_SERVICE_REAGENT_OPTIONAL] = "Opzionale",
        [CraftSim.CONST.TEXT.CUSTOMER_SERVICE_REAGENT_FINISHING] = "Finitura",
        [CraftSim.CONST.TEXT.CUSTOMER_SERVICE_CRAFTING_COSTS] = "Costi di creazione",
        [CraftSim.CONST.TEXT.CUSTOMER_SERVICE_EXPECTED_RESULTS] = "Risultati previsti",
        [CraftSim.CONST.TEXT.CUSTOMER_SERVICE_EXPECTED_INSPIRATION] = "di probabilità di ispirazione",
        [CraftSim.CONST.TEXT.CUSTOMER_SERVICE_REQUIRED_MATERIALS] = "Materiali richiesti",
        [CraftSim.CONST.TEXT.CUSTOMER_SERVICE_REAGENTS_NONE] = "Nessuno",
        [CraftSim.CONST.TEXT.CUSTOMER_SERVICE_REAGENTS_LOCKED] = "Bloccato",

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
        [CraftSim.CONST.TEXT.RECIPE_SCAN_GUARANTEED_HEADER] = "Garantito",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_HIGHEST_RESULT_HEADER] = "Risultato migliore",
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
        [CraftSim.CONST.TEXT.RECIPE_SCAN_MODE_Q1] = "Qualità materiali 1",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_MODE_Q2] = "Qualità materiali 2",
        [CraftSim.CONST.TEXT.RECIPE_SCAN_MODE_Q3] = "Qualità materiali 3",
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
        [CraftSim.TAILORING_DATA.NODE_IDS.SPARING_SEWING] = "Sartoria Parsimoniosa",
        [CraftSim.TAILORING_DATA.NODE_IDS.SHREWD_STITCHERY] = "Cucito Accorto",
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
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_DETAILED_TOOLTIP] = "Informazioni dettagliate sull'ultima creazione",
        [CraftSim.CONST.TEXT.OPTIONS_GENERAL_DETAILED_TOOLTIP_TOOLTIP] =
        "Mostra un resoconto completo dell'ultima combinazione di materiali utilizzata nel tooltip di un oggetto",
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
        [CraftSim.CONST.TEXT.OPTIONS_MODULES_MATERIALS] = "Modulo Ottimizzazione Materiali",
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
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_CRAFT_DATA_LABEL] = "Dati Salvati",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_CRAFT_DATA_TOOLTIP] =
        "Modifica le configurazioni salvate dei vari oggetti delle differenti difficoltà da mostrare nei tooltip e per calcolare i costi di creazione",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_SPECIALIZATION_INFO_LABEL] = "Info Specializzazioni",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_SPECIALIZATION_INFO_TOOLTIP] =
        "Mostra come le specializzazioni della tua professione influenzano questa ricetta e permette di simulare ogni possibile configurazione!",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_CRAFT_RESULTS_LABEL] = "Risultati Artigianato",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_CRAFT_RESULTS_TOOLTIP] =
        "Mostra rapporti e statistiche dei tuoi oggetti creati!",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_COST_OPTIMIZATION_LABEL] = "Dettaglio Costi",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_COST_OPTIMIZATION_TOOLTIP] =
        "Modulo che mostra dettagliate informazioni sui costi di creazione",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_RECIPE_SCAN_LABEL] = "Scansione Ricette",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_RECIPE_SCAN_TOOLTIP] =
        "Modulo che scansiona la tua lista di ricette in base a varie opzioni",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_CUSTOMER_SERVICE_LABEL] = "Servizio Clienti",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_CUSTOMER_SERVICE_TOOLTIP] =
        "Modulo che offre varie opzioni per interagire con i potenziali clienti",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_CUSTOMER_HISTORY_LABEL] = "Storico Clienti",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_CUSTOMER_HISTORY_TOOLTIP] =
        "Modulo che mostra uno storico delle conversazioni con i clienti, gli oggetti creati e le commissioni",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_CRAFT_BUFFS_LABEL] = "Benefici Artigianato",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_MODULES_CRAFT_BUFFS_TOOLTIP] =
        "Modulo che mostra i benefici di creazione attivi e quelli mancanti",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_RESET_FRAMES] = "Resetta posizioni finestre",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_OPTIONS] = "Opzioni",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_NEWS] = "Novità",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_FORGEFINDER_EXPORT] = "Esporta per " .. f.l("ForgeFinder"),
        [CraftSim.CONST.TEXT.CONTROL_PANEL_FORGEFINDER_EXPORTING] = "Esportazione",
        [CraftSim.CONST.TEXT.CONTROL_PANEL_FORGEFINDER_EXPLANATION] = f.l("www.wowforgefinder.com") ..
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
        [CraftSim.CONST.TEXT.SUPPORTERS_TYPE] = "Tipo",
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
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_DELETE_CUSTOMER_POPUP_TITLE] = "Cancella Storico Cliente",
        [CraftSim.CONST.TEXT.CUSTOMER_HISTORY_PURGE_ZERO_TIPS_CONFIRMATION_POPUP_TITLE] =
        "Cancella Storico Clienti con 0 pagamenti",
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
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_CRAFT_BUTTON_ROW_LABEL_NO_MATS] = "Nessun materiale",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_ADD_OPEN_RECIPE_BUTTON_LABEL] = "Aggiungi ricetta selezionata",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_CLEAR_ALL_BUTTON_LABEL] = "Cancella tutto",
        [CraftSim.CONST.TEXT.CRAFT_QUEUE_IMPORT_RECIPE_SCAN_BUTTON_LABEL] = "Rifornimento da Scansione Ricette",
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
