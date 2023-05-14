AddonName, CraftSim = ...

local print = CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.CUSTOMER_HISTORY)

local migrations = {
    ["8.6.2"] = function(db)
        local realm = {}
        for charName, charData in pairs(db.realm) do
            if (string.find(charName, "-") and charData.history) then
                local newHistory = {}
                for timestamp, history in pairs(charData.history) do
                    history.timestamp = history.timestamp or timestamp
                    table.insert(newHistory, history)
                end
                charData.history = newHistory
                realm[charName] = charData
            end
        end
        table.sort(realm, function(a, b) return a.timestamp < b.timestamp end)
    end
}

CraftSim.CUSTOMER_HISTORY.MIGRATIONS = {}

function CraftSim.CUSTOMER_HISTORY.MIGRATIONS:Migrate(db)
    local versions = {}

    for k, _ in pairs(migrations) do
        table.insert(versions, k)
    end

    table.sort(versions)

    for _, k in ipairs(versions) do
        if (db.realm.version == nil or db.realm.version < k) then
            print("Running migration " .. k)
            migrations[k](db)
            db.realm.version = k
        end
    end
end