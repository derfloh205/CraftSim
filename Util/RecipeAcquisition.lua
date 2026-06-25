---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL
local L = CraftSim.LOCAL:GetLocalizer()

---@class CraftSim.RECIPE_ACQUISITION
CraftSim.RECIPE_ACQUISITION = {}

GUTIL:RegisterCustomEvents(CraftSim.RECIPE_ACQUISITION, {
    "CRAFTSIM_OPEN_RECIPE_INFO_UPDATED",
})

CraftSim.RECIPE_ACQUISITION.KIND = {
    SPEC = "spec",
    VENDOR = "vendor",
    DROP = "drop",
    OTHER = "other",
}

---@type table<string, { tabID: number?, pathID: number? }|false>
local unlockPathCache = {}

---@type table<string, number|false>
local pathToTabCache = {}

---@param text string?
---@return string
local function StripColorCodes(text)
    if not text or text == "" then
        return ""
    end
    return text:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", ""):gsub("|n", " ")
end

---@param text string?
---@return string
local function NormalizeForMatch(text)
    return string.lower(StripColorCodes(text))
end

---@param sourceText string?
---@return string kind CraftSim.RECIPE_ACQUISITION.KIND
local function ClassifySourceKind(sourceText)
    local normalized = NormalizeForMatch(sourceText)
    if normalized == "" then
        return CraftSim.RECIPE_ACQUISITION.KIND.OTHER
    end
    if normalized:find("specialization", 1, true)
        or normalized:find("spec tree", 1, true)
        or normalized:find("profession tree", 1, true)
        or normalized:find("knowledge point", 1, true) then
        return CraftSim.RECIPE_ACQUISITION.KIND.SPEC
    end
    if normalized:find("sold by", 1, true)
        or normalized:find("vendor", 1, true)
        or normalized:find("purchase", 1, true)
        or normalized:find("buy from", 1, true)
        or normalized:find("trainer", 1, true) then
        return CraftSim.RECIPE_ACQUISITION.KIND.VENDOR
    end
    if normalized:find("drop", 1, true)
        or normalized:find("looted from", 1, true)
        or normalized:find("world drop", 1, true)
        or normalized:find("found in", 1, true)
        or normalized:find("treasure", 1, true)
        or normalized:find("reward from", 1, true) then
        return CraftSim.RECIPE_ACQUISITION.KIND.DROP
    end
    return CraftSim.RECIPE_ACQUISITION.KIND.OTHER
end

---@param skillLineID number
---@param pathID number
---@param visited table<number, boolean>
---@param visit fun(pathID: number)
local function WalkSpecPaths(skillLineID, pathID, visited, visit)
    if not pathID or visited[pathID] then
        return
    end
    visited[pathID] = true
    visit(pathID)
    local children = C_ProfSpecs.GetChildrenForPath(pathID)
    for _, childID in ipairs(children or {}) do
        WalkSpecPaths(skillLineID, childID, visited, visit)
    end
end

---@param skillLineID number
---@param pathID number
---@return number?
function CraftSim.RECIPE_ACQUISITION:FindSpecTabForPath(skillLineID, pathID)
    if not skillLineID or not pathID or not C_ProfSpecs.SkillLineHasSpecialization(skillLineID) then
        return nil
    end

    local cacheKey = tostring(skillLineID) .. ":" .. tostring(pathID)
    if pathToTabCache[cacheKey] ~= nil then
        local cached = pathToTabCache[cacheKey]
        return cached or nil
    end

    local tabIDs = C_ProfSpecs.GetSpecTabIDsForSkillLine(skillLineID) or {}
    for _, tabID in ipairs(tabIDs) do
        local rootPathID = C_ProfSpecs.GetRootPathForTab(tabID)
        if rootPathID then
            local found = false
            WalkSpecPaths(skillLineID, rootPathID, {}, function(visitedPathID)
                if visitedPathID == pathID then
                    found = true
                end
            end)
            if found then
                pathToTabCache[cacheKey] = tabID
                return tabID
            end
        end
    end

    pathToTabCache[cacheKey] = false
    return nil
end

---@param skillLineID number
---@param recipeID number
---@param recipeName string?
---@return number? tabID
---@return number? pathID
function CraftSim.RECIPE_ACQUISITION:FindRecipeUnlockSpecPath(skillLineID, recipeID, recipeName)
    if not skillLineID or not recipeID or not C_ProfSpecs.SkillLineHasSpecialization(skillLineID) then
        return nil, nil
    end

    local cacheKey = tostring(skillLineID) .. ":" .. tostring(recipeID)
    if unlockPathCache[cacheKey] ~= nil then
        local cached = unlockPathCache[cacheKey]
        if cached then
            return cached.tabID, cached.pathID
        end
        return nil, nil
    end

    local normalizedRecipeName = NormalizeForMatch(recipeName)
    local tabIDs = C_ProfSpecs.GetSpecTabIDsForSkillLine(skillLineID) or {}

    for _, tabID in ipairs(tabIDs) do
        local rootPathID = C_ProfSpecs.GetRootPathForTab(tabID)
        if rootPathID then
            local matchedPathID
            WalkSpecPaths(skillLineID, rootPathID, {}, function(pathID)
                if matchedPathID then
                    return
                end
                local perkInfos = C_ProfSpecs.GetPerksForPath(pathID) or {}
                for _, perkInfo in ipairs(perkInfos) do
                    local perkID = perkInfo.perkID
                    if perkID then
                        local description = C_ProfSpecs.GetDescriptionForPerk(perkID)
                        local normalizedDescription = NormalizeForMatch(description)
                        if normalizedDescription ~= "" then
                            if normalizedRecipeName ~= "" and normalizedDescription:find(normalizedRecipeName, 1, true) then
                                matchedPathID = pathID
                                return
                            end
                            if normalizedDescription:find("unlock", 1, true)
                                and normalizedDescription:find("recipe", 1, true) then
                                matchedPathID = pathID
                                return
                            end
                        end
                    end
                end
            end)
            if matchedPathID then
                unlockPathCache[cacheKey] = { tabID = tabID, pathID = matchedPathID }
                return tabID, matchedPathID
            end
        end
    end

    unlockPathCache[cacheKey] = false
    return nil, nil
end

---@class CraftSim.RecipeSourceHint
---@field sourceText string?
---@field displayText string?
---@field sourceKind string
---@field specTabID number?
---@field specPathID number?

---@param recipeID number
---@param recipeName string?
---@param skillLineID number?
---@return CraftSim.RecipeSourceHint?
function CraftSim.RECIPE_ACQUISITION:GetRecipeSourceHint(recipeID, recipeName, skillLineID)
    if not recipeID then
        return nil
    end

    local sourceText
    if C_TradeSkillUI.GetRecipeSourceText then
        sourceText = C_TradeSkillUI.GetRecipeSourceText(recipeID)
    end
    sourceText = StripColorCodes(sourceText)

    local sourceKind = ClassifySourceKind(sourceText)
    local specTabID, specPathID

    if skillLineID and (sourceKind == CraftSim.RECIPE_ACQUISITION.KIND.SPEC or sourceKind == CraftSim.RECIPE_ACQUISITION.KIND.OTHER or sourceText == "") then
        specTabID, specPathID = self:FindRecipeUnlockSpecPath(skillLineID, recipeID, recipeName)
        if specTabID and specPathID then
            sourceKind = CraftSim.RECIPE_ACQUISITION.KIND.SPEC
        end
    end

    if sourceText == "" and not specPathID then
        return nil
    end

    local displayText = sourceText
    if sourceKind == CraftSim.RECIPE_ACQUISITION.KIND.SPEC and specTabID then
        local tabInfo = C_ProfSpecs.GetTabInfo(specTabID)
        if tabInfo and tabInfo.name and tabInfo.name ~= "" then
            displayText = tabInfo.name
        elseif displayText == "" then
            displayText = tabInfo and tabInfo.name or ""
        end
    end

    if displayText == "" then
        return nil
    end

    ---@type CraftSim.RecipeSourceHint
    return {
        sourceText = sourceText,
        displayText = displayText,
        sourceKind = sourceKind,
        specTabID = specTabID,
        specPathID = specPathID,
    }
end

---@class CraftSim.QualitySpecSuggestion
---@field pathID number
---@field tabID number?
---@field nodeName string

---@param recipeData CraftSim.RecipeData
---@param minQuality number?
---@return CraftSim.QualitySpecSuggestion?
function CraftSim.RECIPE_ACQUISITION:GetQualitySpecSuggestion(recipeData, minQuality)
    if not recipeData or not minQuality or minQuality <= 0 then
        return nil
    end

    local specializationData = recipeData.specializationData
    if not specializationData or not specializationData.isImplemented then
        return nil
    end

    local skillLineID = recipeData.professionData and recipeData.professionData.skillLineID
    if not skillLineID then
        return nil
    end

    ---@type CraftSim.NodeData?
    local bestNode
    local bestSkill = -1

    for _, nodeData in pairs(specializationData.nodeData or {}) do
        if nodeData.rank < nodeData.maxRank
            and nodeData:HasRelevantStats(recipeData)
            and nodeData.maxProfessionStats.skill.value > 0 then
            local skillValue = nodeData.maxProfessionStats.skill.value
            if skillValue > bestSkill then
                bestSkill = skillValue
                bestNode = nodeData
            end
        end
    end

    if not bestNode then
        return nil
    end

    local tabID = self:FindSpecTabForPath(skillLineID, bestNode.nodeID)
    return {
        pathID = bestNode.nodeID,
        tabID = tabID,
        nodeName = bestNode.name or "",
    }
end

---@param profession Enum.Profession
---@param expansionID CraftSim.EXPANSION_IDS
---@return number?
function CraftSim.RECIPE_ACQUISITION:GetSkillLineID(profession, expansionID)
    local professionLines = CraftSim.CONST.TRADESKILLLINEIDS[profession]
    if not professionLines then
        return nil
    end
    return professionLines[expansionID]
end

---@param profession Enum.Profession
---@return number?
function CraftSim.RECIPE_ACQUISITION:GetBaseTradeSkillID(profession)
    local professionLines = CraftSim.CONST.TRADESKILLLINEIDS[profession]
    return professionLines and professionLines.BASE
end

---@param snapshot CraftSim.PatronWorkOrderSnapshot
---@param recipeID number
---@param recipeName string
---@param profession Enum.Profession
---@param expansionID CraftSim.EXPANSION_IDS
function CraftSim.RECIPE_ACQUISITION:EnrichSnapshotForNeedsRecipe(snapshot, recipeID, recipeName, profession, expansionID)
    local skillLineID = self:GetSkillLineID(profession, expansionID)
    local hint = self:GetRecipeSourceHint(recipeID, recipeName, skillLineID)
    if not hint then
        return
    end

    snapshot.acquisitionHint = hint.displayText or hint.sourceText
    snapshot.acquisitionKind = hint.sourceKind
    snapshot.specTabID = hint.specTabID
    snapshot.specPathID = hint.specPathID
end

---@param snapshot CraftSim.PatronWorkOrderSnapshot
---@param recipeData CraftSim.RecipeData
function CraftSim.RECIPE_ACQUISITION:EnrichSnapshotForNeedsQuality(snapshot, recipeData)
    local suggestion = self:GetQualitySpecSuggestion(recipeData, snapshot.minQuality)
    if not suggestion or suggestion.nodeName == "" then
        return
    end

    snapshot.acquisitionHint = suggestion.nodeName
    snapshot.acquisitionKind = CraftSim.RECIPE_ACQUISITION.KIND.SPEC
    snapshot.specTabID = suggestion.tabID
    snapshot.specPathID = suggestion.pathID
end

---@param tabID number?
---@param pathID number?
local function ApplySpecNavigation(tabID, pathID)
    if not ProfessionsFrame or not ProfessionsFrame:IsVisible() then
        return
    end

    local specTabID = ProfessionsFrame.specializationsTabID or 2
    if ProfessionsFrame.SetTab then
        ProfessionsFrame:SetTab(specTabID, true)
    else
        ProfessionsFrame:GetTabButton(2):Click()
    end

    RunNextFrame(function()
        if tabID then
            EventRegistry:TriggerEvent("ProfessionsSpecializations.TabSelected", tabID)
        end
        if pathID then
            RunNextFrame(function()
                EventRegistry:TriggerEvent("ProfessionsSpecializations.PathSelected", pathID)
            end)
        end
    end)
end

---@param skillLineID number
---@param tabID number?
---@param pathID number?
function CraftSim.RECIPE_ACQUISITION:NavigateToSpec(skillLineID, tabID, pathID)
    if not skillLineID then
        return
    end

    local profession = CraftSim.UTIL:GetProfessionBySkillLineID(skillLineID)
    local baseTradeSkillID = profession and self:GetBaseTradeSkillID(profession)

    local function navigateWhenReady()
        C_TradeSkillUI.SetProfessionChildSkillLineID(skillLineID)
        ApplySpecNavigation(tabID, pathID)
    end

    if ProfessionsFrame and ProfessionsFrame:IsVisible() then
        local currentSkillLineID = C_TradeSkillUI.GetProfessionChildSkillLineID()
        if currentSkillLineID == skillLineID then
            navigateWhenReady()
            return
        end
    end

    if not baseTradeSkillID or not ProfessionsFrame then
        return
    end

    ProfessionsFrame:SetOpenRecipeResponse(skillLineID, nil, true)
    C_TradeSkillUI.OpenTradeSkill(baseTradeSkillID)
    RunNextFrame(function()
        RunNextFrame(navigateWhenReady)
    end)
end

---@param recipeID number
function CraftSim.RECIPE_ACQUISITION:NavigateToRecipe(recipeID)
    if not recipeID then
        return
    end

    local professionInfo = C_TradeSkillUI.GetProfessionInfoByRecipeID(recipeID)
    local skillLineID = professionInfo and (professionInfo.skillLineID or professionInfo.professionID)
    local baseTradeSkillID = professionInfo and professionInfo.professionID

    local function openRecipe()
        if ProfessionsFrame and ProfessionsFrame:IsVisible() then
            if not ProfessionsFrame.CraftingPage:IsVisible() then
                ProfessionsFrame:GetTabButton(1):Click()
            end
            C_TradeSkillUI.OpenRecipe(recipeID)
        end
    end

    if ProfessionsFrame and ProfessionsFrame:IsVisible() and skillLineID then
        local currentSkillLineID = C_TradeSkillUI.GetProfessionChildSkillLineID()
        if currentSkillLineID == skillLineID then
            openRecipe()
            return
        end
    end

    if not baseTradeSkillID or not ProfessionsFrame or not skillLineID then
        return
    end

    ProfessionsFrame:SetOpenRecipeResponse(skillLineID, recipeID, false)
    C_TradeSkillUI.OpenTradeSkill(baseTradeSkillID)
    RunNextFrame(openRecipe)
end

---@param snapshot CraftSim.PatronWorkOrderSnapshot
---@param profession Enum.Profession
---@param expansionID CraftSim.EXPANSION_IDS
function CraftSim.RECIPE_ACQUISITION:NavigateFromSnapshot(snapshot, profession, expansionID)
    if not snapshot or not snapshot.acquisitionHint then
        return
    end

    local skillLineID = self:GetSkillLineID(profession, expansionID)
    ---@type CraftSim.RecipeSourceHint
    local hint = {
        sourceText = snapshot.acquisitionHint,
        displayText = snapshot.acquisitionHint,
        sourceKind = snapshot.acquisitionKind or CraftSim.RECIPE_ACQUISITION.KIND.OTHER,
        specTabID = snapshot.specTabID,
        specPathID = snapshot.specPathID,
    }
    self:NavigateFromHint(hint, snapshot.spellID, skillLineID, snapshot.recipeName)
end

local RECIPE_ITEM_PREFIXES = {
    "Recipe: ",
    "Pattern: ",
    "Schematic: ",
    "Plans: ",
    "Formula: ",
    "Design: ",
    "Technique: ",
}

---@param sourceText string?
---@return string? itemName
---@return number? qualityID
local function ExtractItemFromSourceText(sourceText)
    if not sourceText or sourceText == "" then
        return nil, nil
    end

    local itemLink = sourceText:match("|H(item:[^|]+)|h")
    if not itemLink then
        return nil, nil
    end

    local item = Item:CreateFromItemLink(itemLink)
    local itemName = item:GetItemName()
    if itemName and itemName ~= "" then
        return itemName, GUTIL:GetQualityIDFromLink(itemLink)
    end

    return nil, nil
end

---@class CraftSim.RecipeShoppingSearch
---@field itemName string
---@field qualityID number?

---@param recipeID number
---@param recipeName string?
---@param sourceText string?
---@return CraftSim.RecipeShoppingSearch?
function CraftSim.RECIPE_ACQUISITION:GetRecipeShoppingSearch(recipeID, recipeName, sourceText)
    local itemName, qualityID = ExtractItemFromSourceText(sourceText)
    if not itemName then
        itemName, qualityID = CraftSim.DB.ITEM_RECIPE:FindItemForRecipe(recipeID)
    end

    if not itemName and recipeName and recipeName ~= "" then
        local hasPrefix = false
        for _, prefix in ipairs(RECIPE_ITEM_PREFIXES) do
            if recipeName:find("^" .. prefix, 1, true) then
                hasPrefix = true
                break
            end
        end
        if hasPrefix then
            itemName = recipeName
        else
            itemName = "Recipe: " .. recipeName
        end
    end

    if not itemName then
        local recipeInfo = C_TradeSkillUI.GetRecipeInfo(recipeID)
        if recipeInfo and recipeInfo.name and recipeInfo.name ~= "" then
            itemName = "Recipe: " .. recipeInfo.name
        end
    end

    if not itemName or itemName == "" then
        return nil
    end

    return {
        itemName = itemName,
        qualityID = qualityID,
    }
end

---@param hint CraftSim.RecipeSourceHint
---@param recipeID number
---@param skillLineID number?
---@param recipeName string?
function CraftSim.RECIPE_ACQUISITION:NavigateFromHint(hint, recipeID, skillLineID, recipeName)
    if not hint then
        return
    end

    if hint.sourceKind == CraftSim.RECIPE_ACQUISITION.KIND.SPEC
        and hint.specPathID
        and skillLineID then
        local tabID = hint.specTabID or self:FindSpecTabForPath(skillLineID, hint.specPathID)
        self:NavigateToSpec(skillLineID, tabID, hint.specPathID)
        return
    end

    if hint.sourceKind == CraftSim.RECIPE_ACQUISITION.KIND.DROP
        and CraftSim.SHOPPING
        and CraftSim.SHOPPING:AddRecipeToShoppingList(recipeID, recipeName, hint.sourceText) then
        return
    end

    self:NavigateToRecipe(recipeID)
end

---@param recipeID number
---@param recipeName string?
---@param skillLineID number?
function CraftSim.RECIPE_ACQUISITION:NavigateForUnlearnedRecipe(recipeID, recipeName, skillLineID)
    local hint = self:GetRecipeSourceHint(recipeID, recipeName, skillLineID)
    if not hint then
        return
    end
    self:NavigateFromHint(hint, recipeID, skillLineID, recipeName)
end

---@param hint { sourceKind: string? }?
---@return string
local function GetAtlasForHint(hint)
    if hint and hint.sourceKind == CraftSim.RECIPE_ACQUISITION.KIND.SPEC then
        return CraftSim.CONST.ATLAS_TEXTURES.ACQUISITION_SPEC
    end
    if hint and hint.sourceKind == CraftSim.RECIPE_ACQUISITION.KIND.DROP then
        return CraftSim.CONST.ATLAS_TEXTURES.ACQUISITION_SHOPPING
    end
    return CraftSim.CONST.ATLAS_TEXTURES.ACQUISITION_RECIPE
end

local ACQUISITION_ICON_SIZE = 20

---@class CraftSim.AcquisitionIconButton
---@field frame Button
---@field icon Texture
---@field clickCallback fun()?

---@param parent Frame
---@param anchorParent Frame
---@param anchorA string
---@param anchorB string
---@param offsetX number?
---@param offsetY number?
---@param size number?
---@return CraftSim.AcquisitionIconButton
function CraftSim.RECIPE_ACQUISITION:CreateIconButton(parent, anchorParent, anchorA, anchorB, offsetX, offsetY, size)
    size = size or ACQUISITION_ICON_SIZE

    local btn = CreateFrame("Button", nil, parent)
    btn:SetSize(size, size)
    btn:SetPoint(anchorA, anchorParent, anchorB, offsetX or 0, offsetY or 0)
    btn:SetFrameLevel(anchorParent:GetFrameLevel() + 5)

    local icon = btn:CreateTexture(nil, "ARTWORK")
    icon:SetSize(size, size)
    icon:SetPoint("CENTER")

    btn:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")

    ---@type CraftSim.AcquisitionIconButton
    local widget = {
        frame = btn,
        icon = icon,
        clickCallback = nil,
    }

    btn:SetScript("OnClick", function()
        if widget.clickCallback then
            widget.clickCallback()
        end
    end)

    function widget:Show()
        btn:Show()
    end

    function widget:Hide()
        btn:Hide()
        self.clickCallback = nil
    end

    function widget:SetIconAtlas(hint)
        icon:SetAtlas(GetAtlasForHint(hint))
        icon:SetSize(size, size)
    end

    widget:Hide()
    return widget
end

---@param button CraftSim.AcquisitionIconButton?
---@param hint CraftSim.RecipeSourceHint?
---@param onClick fun()?
---@param tooltipCallback fun(btn: Button)?
function CraftSim.RECIPE_ACQUISITION:UpdateAcquisitionButton(button, hint, onClick, tooltipCallback)
    if not button then
        return
    end

    if not hint or not onClick then
        button:Hide()
        button.frame:SetScript("OnEnter", nil)
        button.frame:SetScript("OnLeave", nil)
        return
    end

    button:SetIconAtlas(hint)
    button.clickCallback = onClick

    if tooltipCallback then
        button.frame:SetScript("OnEnter", tooltipCallback)
        button.frame:SetScript("OnLeave", GameTooltip_Hide)
    else
        button.frame:SetScript("OnEnter", function(btn)
            GameTooltip:SetOwner(btn, "ANCHOR_LEFT")
            GameTooltip:ClearLines()
            if hint.sourceKind == CraftSim.RECIPE_ACQUISITION.KIND.SPEC then
                GameTooltip:AddLine(L("WORK_ORDER_TRACKER_HINT_OPEN_SPEC"), 1, 1, 1, true)
                GameTooltip:AddLine(hint.displayText or hint.sourceText or "", 1, 0.82, 0, true)
            elseif hint.sourceKind == CraftSim.RECIPE_ACQUISITION.KIND.DROP then
                GameTooltip:AddLine(L("WORK_ORDER_TRACKER_HINT_ADD_TO_SHOPPING_LIST"), 1, 1, 1, true)
                GameTooltip:AddLine(hint.displayText or hint.sourceText or "", 1, 0.82, 0, true)
            else
                GameTooltip:AddLine(L("WORK_ORDER_TRACKER_HINT_VIEW_RECIPE_SOURCE"), 1, 1, 1, true)
                GameTooltip:AddLine(hint.displayText or hint.sourceText or "", 1, 0.82, 0, true)
            end
            GameTooltip:Show()
        end)
        button.frame:SetScript("OnLeave", GameTooltip_Hide)
    end

    button:Show()
end

---@param column Frame
---@param recipeID number
---@param recipeName string?
---@param learned boolean
---@param skillLineID number?
function CraftSim.RECIPE_ACQUISITION:UpdateListRowAcquisitionButton(column, recipeID, recipeName, learned, skillLineID)
    local button = column.acquisitionButton
    if not button then
        return
    end

    if learned then
        column.acquisitionHint = nil
        self:UpdateAcquisitionButton(button, nil, nil)
        return
    end

    local hint = self:GetRecipeSourceHint(recipeID, recipeName, skillLineID)
    if not hint then
        column.acquisitionHint = nil
        self:UpdateAcquisitionButton(button, nil, nil)
        return
    end

    column.acquisitionHint = hint
    self:UpdateAcquisitionButton(button, hint, function()
        self:NavigateFromHint(hint, recipeID, skillLineID, recipeName)
    end)
end

---@param schematicForm Frame
---@return CraftSim.AcquisitionIconButton?
local function EnsureSchematicAcquisitionButton(schematicForm)
    if schematicForm.craftSimAcquisitionButton then
        return schematicForm.craftSimAcquisitionButton
    end

    schematicForm.craftSimAcquisitionButton = CraftSim.RECIPE_ACQUISITION:CreateIconButton(
        schematicForm, schematicForm, "TOPLEFT", "TOPLEFT", 0, 0, 20)
    schematicForm.craftSimAcquisitionButton.frame:SetFrameLevel(schematicForm:GetFrameLevel() + 20)
    return schematicForm.craftSimAcquisitionButton
end

---@param schematicForm Frame
---@param recipeInfo TradeSkillRecipeInfo?
function CraftSim.RECIPE_ACQUISITION:UpdateSchematicFormButton(schematicForm, recipeInfo)
    local button = EnsureSchematicAcquisitionButton(schematicForm)
    if not button then
        return
    end

    RunNextFrame(function()
        if not schematicForm:IsVisible() or not recipeInfo or recipeInfo.learned then
            self:UpdateAcquisitionButton(button, nil, nil)
            return
        end

        local skillLineID = C_TradeSkillUI.GetProfessionChildSkillLineID()
        local hint = self:GetRecipeSourceHint(recipeInfo.recipeID, recipeInfo.name, skillLineID)
        if not hint then
            self:UpdateAcquisitionButton(button, nil, nil)
            return
        end

        button.frame:ClearAllPoints()
        if schematicForm.RecipeSourceButton and schematicForm.RecipeSourceButton:IsShown() then
            button.frame:SetPoint("LEFT", schematicForm.RecipeSourceButton, "RIGHT", 6, 0)
        elseif schematicForm.Description then
            button.frame:SetPoint("TOPLEFT", schematicForm.Description, "BOTTOMLEFT", 0, -6)
        else
            button.frame:SetPoint("TOPLEFT", schematicForm, "TOPLEFT", 28, -80)
        end

        self:UpdateAcquisitionButton(button, hint, function()
            self:NavigateFromHint(hint, recipeInfo.recipeID, skillLineID, recipeInfo.name)
        end)
    end)
end

function CraftSim.RECIPE_ACQUISITION:InitSchematicFormButtons()
    local forms = {
        ProfessionsFrame.CraftingPage.SchematicForm,
        ProfessionsFrame.OrdersPage.OrderView.OrderDetails.SchematicForm,
    }

    for _, schematicForm in ipairs(forms) do
        EnsureSchematicAcquisitionButton(schematicForm)
    end
end

function CraftSim.RECIPE_ACQUISITION:Init()
    self:InitSchematicFormButtons()
end

---@param recipeInfo TradeSkillRecipeInfo?
function CraftSim.RECIPE_ACQUISITION:CRAFTSIM_OPEN_RECIPE_INFO_UPDATED(recipeInfo)
    self:UpdateSchematicFormButton(ProfessionsFrame.CraftingPage.SchematicForm, recipeInfo)
    self:UpdateSchematicFormButton(ProfessionsFrame.OrdersPage.OrderView.OrderDetails.SchematicForm, recipeInfo)
end
