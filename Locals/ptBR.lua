---@class CraftSim
local CraftSim = select(2, ...)

CraftSim.LOCAL_PT = {}

function CraftSim.LOCAL_PT:GetData()
  local f = CraftSim.GUTIL:GetFormatter()
  local cm = function(i, s) return CraftSim.MEDIA:GetAsTextIcon(i, s) end
  return {
    -- REQUIRED:
    [CraftSim.CONST.TEXT.STAT_MULTICRAFT] = "Multicriação",
    [CraftSim.CONST.TEXT.STAT_RESOURCEFULNESS] = "Devolução de recursos",
    [CraftSim.CONST.TEXT.STAT_INGENUITY] = "Engenhosidade",
    [CraftSim.CONST.TEXT.STAT_CRAFTINGSPEED] = "Velocidade de criação",
    [CraftSim.CONST.TEXT.EQUIP_MATCH_STRING] = "Equipado:",
    [CraftSim.CONST.TEXT.ENCHANTED_MATCH_STRING] = "Encantado:",

    -- OPTIONAL (Defaulting to EN if not available):

    -- professions

    [CraftSim.CONST.TEXT.PROFESSIONS_BLACKSMITHING] = "Ferraria",
    [CraftSim.CONST.TEXT.PROFESSIONS_LEATHERWORKING] = "Couraria",
    [CraftSim.CONST.TEXT.PROFESSIONS_ALCHEMY] = "Alquimia",
    [CraftSim.CONST.TEXT.PROFESSIONS_HERBALISM] = "Herbalismo",
    [CraftSim.CONST.TEXT.PROFESSIONS_COOKING] = "Cozinheiro",
    [CraftSim.CONST.TEXT.PROFESSIONS_MINING] = "Mineração",
    [CraftSim.CONST.TEXT.PROFESSIONS_TAILORING] = "Alfaiataria",
    [CraftSim.CONST.TEXT.PROFESSIONS_ENGINEERING] = "Engenharia",
    [CraftSim.CONST.TEXT.PROFESSIONS_ENCHANTING] = "Encantamento",
    [CraftSim.CONST.TEXT.PROFESSIONS_FISHING] = "Pesca",
    [CraftSim.CONST.TEXT.PROFESSIONS_SKINNING] = "Esfolamento",
    [CraftSim.CONST.TEXT.PROFESSIONS_JEWELCRAFTING] = "Joalheria",
    [CraftSim.CONST.TEXT.PROFESSIONS_INSCRIPTION] = "Escrivaninha",

    -- Profit Breakdown Tooltips
    [CraftSim.CONST.TEXT.RESOURCEFULNESS_EXPLANATION_TOOLTIP] =
    "A Devolução de recursos proca para cada reagente individualmente e então economiza cerca de 30% da quantidade.\n\nO valor médio economizado é o valor médio de TODAS as combinações e suas chances.\n(Procar todos os reagentes ao mesmo tempo é muito improvável, mas economiza bastante).\n\nO custo total médio de reagentes economizados é a soma dos custos economizados de todos os reagentes, ponderados pela chance de proc.",

    [CraftSim.CONST.TEXT.RECIPE_DIFFICULTY_EXPLANATION_TOOLTIP] =
    "A dificuldade da receita determina quanta perícia é necessária para fabricar a receita em cada nível de qualidade.\n\nPara receitas com cinco níveis de qualidade é 20%, 50%, 80% e 100% da dificuldade da receita como perícia.\nPara receitas com três níveis de qualidade é 50% e 100%",
    [CraftSim.CONST.TEXT.MULTICRAFT_EXPLANATION_TOOLTIP] =
    "Multicriação dá uma probabildade de fabricar mais objetos do que uma receita normalmente fabricaria.\n\nA quantidade adicional está entre 1 e 2.5y\nonde y = quantidade normal que uma criação fornece.",
    [CraftSim.CONST.TEXT.REAGENTSKILL_EXPLANATION_TOOLTIP] =
    "A qualidade dos seus reagentes podem dar até um máximo de 40% de perícia adicional da receita base.\n\nTodos os Reagentes de Q1: 0% Bônus\nTodos os Reagentes de Q2: 20% Bônus\nTodos os Reagentes de Q3: 40% Bônus\n\nA habilidade é calculada pela quantidade de reagentes de cada qualidade, ponderada de acordo com sua qualidade \ne um valor de peso específico que é único para cada item de reagente de criação com qualidade.\n\nNo entando, é diferente quando se trata de Recraft (Recriação). No Recraft, o máximo que os reagentes podem aumentar a qualidade\ndepende da qualidade dos reagentes com os quais o item foi originalmente criado.\nO funcionamento exato disso, é desconhecido.\nTodavia, o CraftSim compara, internamente, a perícia alcançada com todos os de qualidade 3 (Q3) e calcula\no aumento máximo de perícia com base nisso.",
    [CraftSim.CONST.TEXT.REAGENTFACTOR_EXPLANATION_TOOLTIP] =
    "O máximo que os reagentes podem contribuir para uma receita é, na maioria das vezes, 40% da dificuldade base da receita.\n\nMas, no caso de Recraft (Recriação), esse valor pode variar com base nas criações anteriores\n e na qualidade dos reagentes que foram utilizados.",

    -- Simulation Mode
    [CraftSim.CONST.TEXT.SIMULATION_MODE_NONE] = "Nenhum",
    [CraftSim.CONST.TEXT.SIMULATION_MODE_LABEL] = "Modo Simulação",
    [CraftSim.CONST.TEXT.SIMULATION_MODE_TITLE] = "Modo de Simulação CraftSim",
    [CraftSim.CONST.TEXT.SIMULATION_MODE_TOOLTIP] =
    "O Modo de Simulação CraftSim torna possível testar combinações de uma receita sem restrições",
    [CraftSim.CONST.TEXT.SIMULATION_MODE_OPTIONAL] = "Opcional #",
    [CraftSim.CONST.TEXT.SIMULATION_MODE_FINISHING] = "Acabamento #",
    [CraftSim.CONST.TEXT.SIMULATION_MODE_QUALITY_BUTTON_TOOLTIP] = "Maximizar Todos Reagentes de Qualidade ",
    [CraftSim.CONST.TEXT.SIMULATION_MODE_CLEAR_BUTTON] = "Limpar",
    [CraftSim.CONST.TEXT.SIMULATION_MODE_CONCENTRATION] = " Concentração",
    [CraftSim.CONST.TEXT.SIMULATION_MODE_CONCENTRATION_COST] = "Custo de Concentração: ",

    -- Details Frame
    [CraftSim.CONST.TEXT.RECIPE_DIFFICULTY_LABEL] = "Dificuldade da receita: ",
    [CraftSim.CONST.TEXT.MULTICRAFT_LABEL] = "Multicriação: ",
    [CraftSim.CONST.TEXT.RESOURCEFULNESS_LABEL] = "Devolução de recursos: ",
    [CraftSim.CONST.TEXT.RESOURCEFULNESS_BONUS_LABEL] = "Bonus de item de Devolução de recursos: ",
    [CraftSim.CONST.TEXT.CONCENTRATION_LABEL] = "Concentração: ",
    [CraftSim.CONST.TEXT.REAGENT_QUALITY_BONUS_LABEL] = "Bonus de qualidade do Reagente: ",
    [CraftSim.CONST.TEXT.REAGENT_QUALITY_MAXIMUM_LABEL] = "Máxima Qualidade do Reagente %: ",
    [CraftSim.CONST.TEXT.EXPECTED_QUALITY_LABEL] = "Qualidade Esperada: ",
    [CraftSim.CONST.TEXT.NEXT_QUALITY_LABEL] = "Próxima Qualidade: ",
    [CraftSim.CONST.TEXT.MISSING_SKILL_LABEL] = "Perícia faltante: ",
    [CraftSim.CONST.TEXT.SKILL_LABEL] = "Perícia: ",
    [CraftSim.CONST.TEXT.MULTICRAFT_BONUS_LABEL] = "Bonus de item de Multicriação: ",
  }
end
