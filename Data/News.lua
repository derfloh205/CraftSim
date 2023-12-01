CraftSimAddonName, CraftSim = ...

CraftSim.NEWS = {}

function CraftSim.NEWS:GET_NEWS()
    -- minimize names to make manual formatting easier :p
    local f = CraftSim.UTIL:GetFormatter()
    local function newP(v) return f.l("\n\n                                   --- Version " .. v .. " ---\n") end

    return 
        f.bb("                   Hello and thank you for using CraftSim!\n") .. 
        f.bb("                                 ( You are awesome! )") ..
        newP("10.0.1") ..
        f.p .. "Fixed an issue where " .. f.patreon("CraftSim") .. " overwrote the " .. 
        f.a .. "global print function (sorry other devs)" ..
        f.p .. "Wether to show the news popup will now determined by" ..
        f.a .. "a checksum instead of a manually set const" ..
        f.p .. "Supporter List Update" ..
        newP("10.0.0") ..
        f.P .. "Do you find " .. f.patreon("CraftSim") .. " helpful?" .. 
        f.a .. "You can now " .. f.g("support its development") .. " by following the new" ..
        f.a .. "paypal me link in the above box" .. " or in the " .. 
        f.a .. f.patreon("Supporters Module") .. " <3" ..
        f.P .. f.g("Enchanting Specialization Info ") .. "added" .. 
        f.s .. "Added a current and maximum " .. f.bb("Profession Stat Overview") ..
        f.a .. "in the " .. f.bb("Specialization Info Module") ..
        f.s .. "The " .. f.bb("Profession Talent Help Icon") .. " now always shows in the " ..
        f.a .. f.bb("Specialization Info Module") .. " and shows current and" ..
        f.a .. "maximum stats in its tooltip" ..
        f.s .. "Refactored the " .. f.bb("Specialization Node System") .. " to consider" ..
        f.a .. "talent nodes with thresholds that affect individual recipe types" ..
        f.s .. "Added a " .. f.g("Max All") .. " button to the " .. f.bb("Knowledge Simulator") ..
        f.s .. "Fixed " .. f.bb("Armor Kits") .. " not correctly being affected " ..
        f.a .. "by the talent " .. f.bb("Curing and Tanning (Leatherworking)") ..
        f.p .. "Fixed the legend text alignment in the " .. f.bb("Knowledge Simulator") ..
        f.p .. "Slightly increased the height of the " .. f.bb("Specialization Info Module") ..
        f.a .. "to consider the new profession stat info" ..
        f.p .. "Updated recipes affected by " .. f.bb("Decayology") ..
        newP("9.0.3") ..
        f.p .. "Fixed a bug with the " .. f.bb("Reset Frame Positions") .. " button" ..
        newP("9.0.2") ..
        f.p .. "Hotfixed an issue with the deploy process" .. 
        f.a .. "not recognizing git submodules" ..
        newP("9.0.1") ..
        f.p .. "Code Refactorings regarding GGUI globalizations" ..
        newP("9.0.0") ..
        f.P .. "QOL Updates:" ..
        f.s .. "Added a checkbox to the " .. f.bb("Recipe Scan") .. " module to " ..
        f.a .. "optionally sort by relative profit instead of gold value" ..
        f.s .. "Added a checkbox to the " .. f.bb("Recipe Scan") .. " module to " ..
        f.a .. "use " ..f.bb("(Lesser) Illustrious Insight") .. " for recipes that" ..
        f.a .. "allow it. Might be adding a feature to toggle any" .. 
        f.a .. "Optional Reagents for scans at some point" .. 
        f.s .. "Added a checkbox to the " .. f.bb("Craft Results") .. " module to" ..
        f.a .. "disable any recording for a potential performance increase" ..
        f.a .. "while crafting" ..
        f.s .. "Automatically highlight all text for a " .. f.l("ForgeFinder Export") ..
        f.s .. "Added a new " .. f.g("General Option") .. " to toggle this " .. f.bb("News") .. " Popup" ..
        f.a .. "when logging in after a " .. f.l("CraftSim") .. " Update" ..
        newP("8.9.4") ..
        f.p .. "Added " .. f.l("10.2") ..  f.g(" Optional Reagents") ..
        f.a .. "Thanks to " .. f.bb("https://github.com/TheResinger") .. " !" ..
        newP("8.9.3") ..
        f.p .. "Updated enchant recipes for 10.2" ..
        f.p .. "Supporter List Update"
end

function CraftSim.NEWS:GetChecksum()
    local checksum = 0
    local newsString = CraftSim.NEWS:GET_NEWS()
    local checkSumBitSize = 256

    -- Iterate through each character in the string
    for i = 1, #newsString do
        checksum = (checksum + string.byte(newsString, i)) % checkSumBitSize
    end

    return checksum
end

---@return string | nil newChecksum newChecksum when news should be shown, otherwise nil
function CraftSim.NEWS:IsNewsUpdate()
    local newChecksum = CraftSim.NEWS:GetChecksum()
    local oldChecksum = CraftSimOptions.newsChecksum
    if newChecksum ~= oldChecksum then
        return newChecksum
    end
    return nil
end

function CraftSim.NEWS:ShowNews(force)
    local infoText = CraftSim.NEWS:GET_NEWS()
    local newChecksum = CraftSim.NEWS:IsNewsUpdate()
    if newChecksum == nil and (not force) then
       return 
    end

    CraftSimOptions.newsChecksum = newChecksum

    local infoFrame = CraftSim.GGUI:GetFrame(CraftSim.MAIN.FRAMES, CraftSim.CONST.FRAMES.INFO)
    -- resize
    infoFrame:SetSize(CraftSim.CONST.infoBoxSizeX, CraftSim.CONST.infoBoxSizeY)
    infoFrame.originalX = CraftSim.CONST.infoBoxSizeX
    infoFrame.originalY = CraftSim.CONST.infoBoxSizeY
    infoFrame.showInfo(infoText)
end