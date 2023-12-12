CraftSimAddonName, CraftSim = ...

CraftSim.NEWS = {}

function CraftSim.NEWS:GET_NEWS()
    -- minimize names to make manual formatting easier :p
    local f = CraftSim.UTIL:GetFormatter()
    local function newP(v) return f.l("\n\n                                   --- Version " .. v .. " ---\n") end

    return
        f.bb("                   Hello and thank you for using CraftSim!\n") ..
        f.bb("                                 ( You are awesome! )") ..
        newP("11.3.1") ..
        f.p .. "Fixed GeneralRestockAmount Options having no default value" ..
        newP("11.3.0") ..
        f.s .. "Changed " .. f.bb("CraftQueue") .. " Restock Option for Sale Rate" ..
        f.a .. "behaviour to check wether any of the chosen qualities reaches" ..
        f.a .. "the threshold instead of the average" ..
        f.p .. "Added Sale Rate Threshold option to General Restock Options" ..
        newP("11.2.2") ..
        f.P .. f.bb("CraftQueue") .. " now has configureable " .. f.g("Restock Options") ..
        f.a .. "affecting " .. f.bb("Restock from Recipe Scan") .. " Behaviour" ..
        f.a .. "This includes " .. f.g("Restock Amount") .. " and thresholds" .. 
        f.a .. "like " .. f.g("Profit Margin") .." and " .. f.g("Sale Rate") ..
        f.a .. f.bb("Sale Rate Thresholds") .. " are only available if TSM is loaded!" ..
        f.s .. f.bb("CraftQueue") .. " now shows average profit margin per recipe" ..
        f.p .. f.bb("PriceDetails:") .. " fixed a bug where not all qualities were listed" ..
        f.a .. "when opening a recipe the first time a session" ..
        newP("11.1.2") ..
        f.p .. "Fixed " .. f.bb("CraftResults") .. " incorrectly adding multicraft results" ..
        f.p .. "Fixed " .. f.bb("CraftQueue") .. " not being initialized sometimes" ..
        f.p .. "Fixed " .. f.bb("Create Auctionator Shopping List") .. " button not working" ..
        f.p .. f.bb("Shopping List") .. " will now exclude soulbound items" ..
        f.p .. f.bb("Shopping List") .. " will now remove/reduce items when bought" ..
        f.p .. "Added a delete button for each " .. f.bb("CraftQueue Row") ..
        f.p .. "Unlearned recipes are now not addable to the " .. f.bb("CraftQueue") ..
        f.p .. f.g("Increased CraftQueue Performance") .. " using an ItemCount Cache" ..
        f.a .. "and a lot of precalculations" ..
        f.p .. f.bb("CraftQueue Rows") .. " are now sorted by" ..
        f.a .. "craftable status > profit per craft" ..
        f.p .. "Supporter List Update!" ..
        f.a .. "Thanks to " .. f.patreon("Jose Luis") .. " for that huge donation! <3" ..
        newP("11.0.0") ..
        f.P .. f.g("New Module:") .. f.l(" CraftQueue") ..
        f.a .. "Queue Recipes from your currently open recipe or even" ..
        f.a .. "from your last " .. f.bb("Recipe Scan") .. " results " .. 
        f.a .. "and craft them all in one place!" ..
        f.a .. "Directly create an " .. f.bb("Auctionator Shopping List") .. 
        f.a .. "to buy every reagent you are missing!" ..
        f.a .. "- More restock options are coming!" ..
        f.a .. "- CraftQueue consisting over sessions is also planned" ..
        f.a .. "(Very new feature, please report any bugs in the discord)" ..
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
        f.p .. "Updated recipes affected by " .. f.bb("Decayology")
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