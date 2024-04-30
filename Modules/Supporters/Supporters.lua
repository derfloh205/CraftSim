---@class CraftSim
local CraftSim = select(2, ...)

local GUTIL = CraftSim.GUTIL

local f = GUTIL:GetFormatter()

---@class CraftSim.SUPPORTERS
CraftSim.SUPPORTERS = {}

---@class Supporter
---@field name string
---@field type string
---@field note string

function CraftSim.SUPPORTERS:GetList()
    local kofi = CraftSim.MEDIA:GetAsTextIcon(CraftSim.MEDIA.IMAGES.KOFI, 0.45)
    local paypal = " " .. CraftSim.MEDIA:GetAsTextIcon(CraftSim.MEDIA.IMAGES.PAYPAL, 0.35)
    return {

        {
            name = f.bb("Fracguru"),
            type = paypal,
            message = "good addon",
            date = "29.04.2024",
        },
        {
            name = f.bb("Darrell L."),
            type = paypal,
            message = "Craftsim is great.",
            date = "30.01.2024",
        },
        {
            name = f.bb("Holyrain"),
            type = kofi,
            message = "Thank you for an amazing add-on!",
            date = "24.01.2024",
        },
        {
            name = f.bb("Stargrace"),
            type = kofi,
            message = "Your addon is amazing. Thank you",
            date = "20.01.2024",
        },
        {
            name = f.bb("from S.Korea"),
            type = kofi,
            message = "I become the 'master craftsman' with this addons",
            date = "17.01.2024",
        },
        {
            name = f.bb("Zach B."),
            type = paypal,
            message = "Dunno what I`d do without you",
            date = "30.12.2023",
        },
        {
            name = f.bb("Morgan J."),
            type = paypal,
            message = "Thanks for this awesome work :)",
            date = "18.12.2023",
        },
        {
            name = f.bb("Nick R."),
            type = paypal,
            message = "This addon has made me at least this much in wow tokens, thanks for your service",
            date = "17.12.2023",
        },
        {
            name = f.bb("Jose Luis"),
            type = paypal,
            message = "Thanks for your effort!!!!",
            date = "07.12.2023",
        },
        {
            name = f.bb("Evgenii"),
            type = paypal,
            message = "-",
            date = "30.11.2023",
        },
        {
            name = f.bb("B"),
            type = kofi,
            message = "You rock.",
            date = "06.11.2023",
        },
        {
            name = f.bb("Shifu Lou"),
            type = kofi,
            message = "Thanks for the great app!",
            date = "13.07.2023",
        },
        {
            name = f.bb("MH"),
            type = kofi,
            message = "-",
            date = "04.07.2023",
        },
        {
            name = f.bb("Amaelalin"),
            type = kofi,
            message = "May the light of Elune always bare your path.",
            date = "25.06.2023",
        },
        {
            name = f.bb("Aiz"),
            type = kofi,
            message = "Amazing addon that should be in the game baseline :)",
            date = "18.05.2023",
        },
        {
            name = f.bb("Keg"),
            type = kofi,
            message = "Thank you for the amazing work on this addon!",
            date = "15.05.2023",
        },
        {
            name = f.bb("P"),
            type = kofi,
            message = "Paying back some of the gold craftsim has made me <3",
            date = "03.05.2023",
        },
        {
            name = f.bb("Zathe"),
            type = kofi,
            message = "Thank you for taking the time to update CraftSim for 10.1!\n" ..
                "The few hours that it wasn't working reminded me how important this addon is to me.",
            date = "03.05.2023",
        },
        {
            name = f.bb("Kiri"),
            type = kofi,
            message = "Made my life a lot easier",
            date = "01.05.2023",
        },
        {
            name = f.bb("Zathe"),
            type = kofi,
            message = "Thank you so much! I can't imagine crafting in dragonflight without Craftsim!",
            date = "10.03.2023",
        },
        {
            name = f.bb("Milo"),
            type = paypal,
            message = "-",
            date = "28.02.2023",
        },
        {
            name = f.bb("Jacob"),
            type = paypal,
            message = "-",
            date = "03.02.2023",
        }
    }
end
