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
        [CraftSim.CONST.TEXT.INSPIRATIONBONUS_SKILL_ITEM_MATCH_STRING] = "aumenta la competenza aggiuntiva fornita da Ispirazione",

        -- OPTIONAL (Defaulting to EN if not available):
        -- Other Statnames

        [CraftSim.CONST.TEXT.STAT_SKILL] = "Competenza",
        [CraftSim.CONST.TEXT.STAT_MULTICRAFT_BONUS] = "Creazione multipla oggetti extra",
        [CraftSim.CONST.TEXT.STAT_RESOURCEFULNESS_BONUS] = "Parsimonia oggetti extra",
        [CraftSim.CONST.TEXT.STAT_INSPIRATION_BONUS] = "Bonus comp. ispirazione",
        [CraftSim.CONST.TEXT.STAT_CRAFTINGSPEED_BONUS] = "Velocità di creazione",
        [CraftSim.CONST.TEXT.STAT_PHIAL_EXPERIMENTATION] = "Scalino per fiale",
        [CraftSim.CONST.TEXT.STAT_POTION_EXPERIMENTATION] = "Scalino per pozioni",

        -- Profit Breakdown Tooltips
        [CraftSim.CONST.TEXT.RESOURCEFULNESS_EXPLANATION_TOOLTIP] = "Parsimonia agisce su ogni tipo di reagente individualmente e fa risparmiare circa il 30% della sua quantità.\n\nIl valore medio del risparmio è la media del valore di risparmio per OGNI combinazione e possibilità.\n(E' molto difficile che agisca su tutti i reagenti assieme ma fa risparmiare parecchio)\n\nIl costo della media totale dei reagenti risparmiati e la somma del costo dei reagenti risparmiati di tutte le combinazioni pesate sulle loro possibilità.",
        [CraftSim.CONST.TEXT.MULTICRAFT_ADDITIONAL_ITEMS_EXPLANATION_TOOLTIP] = "Questo numero mostra la quantità media di oggetti che sono creati in più dalla creazione multipla.\n\nQuesto tiene in considerazione la tua possibilità e assume per la creazione multipla che \n(1-2.5y)*qualunque_bonus_specializzazione oggetti aggiuntivi vengono creati dove y è la media base di oggetti creati per 1 creazione",
        [CraftSim.CONST.TEXT.MULTICRAFT_ADDITIONAL_ITEMS_VALUE_EXPLANATION_TOOLTIP] = "Questo è il numero medio di oggetti aggiuntivi creati da creazione multipla moltiplicato per il prezzo di vendità dell'oggetto risultante di questa qualità",
        [CraftSim.CONST.TEXT.MULTICRAFT_ADDITIONAL_ITEMS_HIGHER_VALUE_EXPLANATION_TOOLTIP] = "Questo è il numero medio di oggetti aggiuntivi creati da creazione multipla e ispirazione moltiplicato per il prezzo di vendita dell'oggetto risultante della qualità raggiunta dall'ispirazione",
        [CraftSim.CONST.TEXT.MULTICRAFT_ADDITIONAL_ITEMS_HIGHER_QUALITY_EXPLANATION_TOOLTIP] = "Questo numero mostra la quantità media di oggetti che sono creati in più da creazione multipla quando agisce assieme a ispirazione.\n\nQuesto tiene in considerazione la tua probabilità di creazione multipla e di ispirazione e riflette gli oggetti aggiuntivi creati quando entrambe agiscono insieme",
        [CraftSim.CONST.TEXT.INSPIRATION_ADDITIONAL_ITEMS_EXPLANATION_TOOLTIP] = "Questo numero mostra la quantità media di oggetti che sono creati alla tua attuale qualità garantita, quando ispirazione non agisce",
        [CraftSim.CONST.TEXT.INSPIRATION_ADDITIONAL_ITEMS_HIGHER_QUALITY_EXPLANATION_TOOLTIP] = "Questo numero mostra la quantità media di oggetti che sono creati per la successiva qualità raggiungibile con ispirazione",
        [CraftSim.CONST.TEXT.INSPIRATION_ADDITIONAL_ITEMS_VALUE_EXPLANATION_TOOLTIP] = "Questo numero è la media di oggetti creati alla qualità garantita moltiplicato il prezzo di vendita dell'oggetto risultante di questa qualità",
        [CraftSim.CONST.TEXT.INSPIRATION_ADDITIONAL_ITEMS_HIGHER_VALUE_EXPLANATION_TOOLTIP] = "Questo numero è la quantità media di oggetti creati alla qualità raggiunga da ispirazione moltiplicato il prezzo risultante dell'oggetto alla qualità raggiunta dall'ispirazione",

        [CraftSim.CONST.TEXT.RECIPE_DIFFICULTY_EXPLANATION_TOOLTIP] = "La difficoltà della ricetta determina dove si trovano i vari scalini delle diverse qualità.\n\nPer ricette con 5 qualità sono al 20%, 50%, 80% e 100% della difficoltà della ricetta come competenza.\nPer le ricette con 3 qualità sono al 50% e 100%",
        [CraftSim.CONST.TEXT.INSPIRATION_EXPLANATION_TOOLTIP] = "Ispirazione ti da la possibilità di aggiungere competenza alla tua creazione.\n\nQuesto può portare a una qualità di creazione superiore se i punti competenza aggiunti superano la soglia per la successiva qualità.\nPer ricette con 5 qualità il bonus base e un sesto (16.67%) della difficoltà base della ricetta.\nPer ricette con 3 qualità è un terzo (33.33%)",
        [CraftSim.CONST.TEXT.INSPIRATION_SKILL_EXPLANATION_TOOLTIP] = "Questa è la competenza che viene aggiunta alla tua competenza attuale se ispirazione agisce.\n\nSe i tuoi punti competenza più questi punti bonus raggiungono la soglia\ndella successiva qualità, creerai l'oggetto a questa qualità più alta",
        [CraftSim.CONST.TEXT.MULTICRAFT_EXPLANATION_TOOLTIP] = "Creazione multipla ti da la possibilità di creare più oggetti di quanti normalmente ne produrresti con la ricetta.\n\nLa quantità aggiuntiva è normalmente tra 1 e 2.5y\ndobe y = la quantità normale di oggetti che unna singola creazione fornisce",
        [CraftSim.CONST.TEXT.REAGENTSKILL_EXPLANATION_TOOLTIP] = "La qualità dei tuoi reagenti può fornire un massimo del 25% della difficoltà base della ricetta come bonus di competenza.\n\nTutti i reagenti di rank 1: 0% bonus\nTutti i reagenti di rank 2: 12.5% bonus\nTutti i reagenti di rank 3: 25% bonus\n\nLa competenza è calcolata dalla quantità di reagenti di ogni qualità pesata sulla loro qualità\ne uno specifico valore di peso che è unico per ogni reagente d'artigianato di dragonflight\n\nQuesto è comunque diverso in caso di ri-creazione. Il numero massimo di reagenti che può incrementare la qualità\nè dipendente dalla qualità dei reagenti con cui l'oggetto era stato inizialmente creato.\nIl modo esatto in cui questo funziona è ancora sconosciuto.\nComunque, CraftSim internamente confronta la competenza raggiunta con tutti reagenti di rank 3 e calcola\nil massimo aumento di competenza basato su di essa.",
        [CraftSim.CONST.TEXT.REAGENTFACTOR_EXPLANATION_TOOLTIP] = "Il massimo per cui i reagenti possono contribuire ad una ricetta è la maggior parte delle volte il 25% della difficoltà base della ricetta.\nComunque in caso di ri-creazione, questo valore può cambiare in base alla creazione precedente\ne la qualità di reagenti che erano stati usati",
		
        -- Details Frame
        [CraftSim.CONST.TEXT.RECIPE_DIFFICULTY_LABEL] = "Difficoltà ricetta: ",
        [CraftSim.CONST.TEXT.INSPIRATION_LABEL] = "Ispirazione: ",
        [CraftSim.CONST.TEXT.INSPIRATION_SKILL_LABEL] = "Ispirazione (comp.): ",
        [CraftSim.CONST.TEXT.MULTICRAFT_LABEL] = "Creazione multipla: ",
        [CraftSim.CONST.TEXT.RESOURCEFULNESS_LABEL] = "Parsimonia: ",
        [CraftSim.CONST.TEXT.RESOURCEFULNESS_BONUS_LABEL] = "Parsimonia oggetti bonus: ",
        [CraftSim.CONST.TEXT.MATERIAL_QUALITY_BONUS_LABEL] = "Bonus qualità materiali: ",
        [CraftSim.CONST.TEXT.MATERIAL_QUALITY_MAXIMUM_LABEL] = "Massimo bonus % qualità materiali: ",
        [CraftSim.CONST.TEXT.EXPECTED_QUALITY_LABEL] = "Qualità prevista: ",
        [CraftSim.CONST.TEXT.NEXT_QUALITY_LABEL] = "Qualità successiva: ",
        [CraftSim.CONST.TEXT.MISSING_SKILL_LABEL] = "Competenza mancante: ",
        [CraftSim.CONST.TEXT.MISSING_SKILL_INSPIRATION_LABEL] = "Competenza mancante (ispirazione)",
        [CraftSim.CONST.TEXT.SKILL_LABEL] = "Competenza: ",
        [CraftSim.CONST.TEXT.MULTICRAFT_BONUS_LABEL] = "Creazione multipla oggetti bonus: "
    }
end
