---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL

CraftSim.WIDGETS = CraftSim.WIDGETS or {}

---@class CraftSim.WIDGETS.ContextMenu
CraftSim.WIDGETS.ContextMenu = {}

---@alias CraftSim.WIDGETS.ContextMenu.Item table
---| { type: "checkbox", label: string, get: fun():boolean, set: fun(checked:boolean), tooltip: fun(tooltip, elementDescription)|nil }
---| { type: "divider" }
---| { type: "submenu", label: string, children: CraftSim.WIDGETS.ContextMenu.Item[] }
---| { type: "radio", label: string, value: any, get: fun():any, set: fun(value:any), tooltip: fun(tooltip, elementDescription)|nil }
---| { type: "title", text: string }
---| { type: "button", label: string, onClick: fun(), tooltip: fun(tooltip, elementDescription)|nil }
---| { type: "custom", build: fun(rootDescription: any) }

---Build menu items on a MenuUtil root description from a config table.
---@param rootDescription any MenuUtil root description (e.g. from MenuUtil.CreateContextMenu callback)
---@param items CraftSim.WIDGETS.ContextMenu.Item[] array of item descriptors
function CraftSim.WIDGETS.ContextMenu.Build(rootDescription, items)
    for _, item in ipairs(items) do
        if item.type == "checkbox" then
            local el = rootDescription:CreateCheckbox(item.label, item.get, item.set)
            if item.tooltip and el.SetTooltip then
                el:SetTooltip(item.tooltip)
            end
        elseif item.type == "divider" then
            rootDescription:CreateDivider()
        elseif item.type == "submenu" then
            local sub = rootDescription:CreateButton(item.label)
            CraftSim.WIDGETS.ContextMenu.Build(sub, item.children or {})
        elseif item.type == "radio" then
            local value = item.value
            local el = rootDescription:CreateRadio(item.label, function()
                return item.get() == value
            end, function()
                item.set(value)
            end)
            if item.tooltip and el and el.SetTooltip then
                el:SetTooltip(item.tooltip)
            end
        elseif item.type == "title" then
            rootDescription:CreateTitle(item.text)
        elseif item.type == "button" then
            local el = rootDescription:CreateButton(item.label, item.onClick)
            if item.tooltip and el and el.SetTooltip then
                el:SetTooltip(item.tooltip)
            end
        elseif item.type == "custom" and item.build then
            item.build(rootDescription)
        end
    end
end

---Open a context menu. Config can be a callback or a table of menu items.
---@param parent Frame anchor frame for the menu (e.g. UIParent)
---@param config fun(ownerRegion: Region, rootDescription: any) | CraftSim.WIDGETS.ContextMenu.Item[] callback or item array
function CraftSim.WIDGETS.ContextMenu.Open(parent, config)
    if type(config) == "function" then
        MenuUtil.CreateContextMenu(parent, config)
    else
        MenuUtil.CreateContextMenu(parent, function(ownerRegion, rootDescription)
            CraftSim.WIDGETS.ContextMenu.Build(rootDescription, config or {})
        end)
    end
end
