AddonName, CraftSim = ...

CraftSim.LOCAL_IT = {}

function CraftSim.LOCAL_IT:GetData()
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
        [CraftSim.CONST.TEXT.MISSING_SKILL_INSPIRATION_LABEL] = "Competenza mancante (Ispirazione):",
        [CraftSim.CONST.TEXT.SKILL_LABEL] = "Competenza: ",
        [CraftSim.CONST.TEXT.MULTICRAFT_BONUS_LABEL] = "Moltiplicatore oggetti aggiuntivi: "
    }
end
