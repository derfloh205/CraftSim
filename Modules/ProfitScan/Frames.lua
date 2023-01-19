addonName, CraftSim = ...

CraftSim.PROFIT_SCAN.FRAMES = {}

function CraftSim.PROFIT_SCAN.FRAMES:Init()
    local frameNO_WO = CraftSim.FRAME:CreateCraftSimFrame(
        "CraftSimProfitScan", 
        "CraftSim Profit Scan", 
        ProfessionsFrame.CraftingPage.SchematicForm, 
        ProfessionsFrame.CraftingPage.SchematicForm, 
        "CENTER", 
        "CENTER", 
        0, 
        0, 
        350, 
        300,
        CraftSim.CONST.FRAMES.PROFIT_SCAN, false, true, "DIALOG", "modulesProfitScan")

    local function createContent(frame)
        frame:Hide()

        frame.content.scanMode = CraftSim.FRAME:initDropdownMenu(nil, frame.content, frame.title, "Scan Mode", 0, -30, 150, 
        CraftSim.UTIL:Map(CraftSim.PROFIT_SCAN.SCAN_MODES, function(e) return e end), function(arg1) 
            frame.content.scanMode.currentMode = arg1
        end, CraftSim.PROFIT_SCAN.SCAN_MODES.Q1)
        frame.content.scanMode.currentMode = CraftSim.PROFIT_SCAN.SCAN_MODES.Q1

        frame.content.scanButton = CraftSim.FRAME:CreateButton("Scan Recipes", frame.content, frame.content.scanMode, "TOP", "TOP", 0, -30, 15, 25, true, function() 
            CraftSim.PROFIT_SCAN:StartScan()
        end)
    end

    createContent(frameNO_WO)
end