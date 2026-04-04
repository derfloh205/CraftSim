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
            name = f.bb("Ian R."),
            type = kofi,
            message =
            "Donating to the author of a great article.",
            date = "15.09.2024",
        },
        {
            name = f.bb("Red"),
            type = kofi,
            message =
            "I cannot thank you enough for this magnificent S-Tier addon, I would have lost my sanity if I had to do professions without it. <3",
            date = "10.09.2024",
        },
        {
            name = f.bb("David H."),
            type = paypal,
            message =
            "-",
            date = "07.09.2024",
        },
        {
            name = f.bb("Gruune"),
            type = kofi,
            message = "Fantastic addon, great support on discord. Well deserved Coffee!",
            date = "06.09.2024",
        },
        {
            name = f.bb("SmoothGeorge1"),
            type = kofi,
            message = "-",
            date = "06.09.2024",
        },
        {
            name = f.bb("sprdl"),
            type = kofi,
            message = "Thanks a lot for your work! :)",
            date = "02.09.2024",
        },
        {
            name = f.bb("Tyranastrasz"),
            type = kofi,
            message = "Thanks alot, awesome work",
            date = "02.09.2024",
        },
        {
            name = f.bb("Zathe"),
            type = kofi,
            message = "-",
            date = "30.08.2024",
        },
        {
            name = f.bb("Celtic"),
            type = kofi,
            message = "Cheers.",
            date = "30.08.2024",
        },
        {
            name = f.bb("Tourn"),
            type = kofi,
            message = "You deserve so much more! Tyvm for the service you do for the WoW community.",
            date = "28.08.2024",
        },
        {
            name = f.bb("DiegoSnoop"),
            type = kofi,
            message = "-",
            date = "25.08.2024",
        },
        {
            name = f.bb("Somebody"),
            type = kofi,
            message = "-",
            date = "22.08.2024",
        },
        {
            name = f.bb("John S."),
            type = kofi,
            message =
            "Love what you do for the game! Donated enough for a cheeseburger (or multiple coffees if that is your preference)",
            date = "12.08.2024",
        },
        {
            name = f.bb("Ten"),
            type = kofi,
            message = "Thank you for the hard work",
            date = "09.08.2024",
        },
        {
            name = f.bb("John S."),
            type = kofi,
            message =
            "Love what you do for the game! Donated enough for a cheeseburger (or multiple coffees if that is your preference).",
            date = "13.08.2024",
        },
        {
            name = f.bb("Ten"),
            type = kofi,
            message = "Thank you for the hard work",
            date = "09.08.2024",
        },
        {
            name = f.bb("Endriss"),
            type = kofi,
            message = "Thank you for your work!",
            date = "09.08.2024",
        },
        {
            name = f.bb("Sarge"),
            type = kofi,
            message = "Thank you for your help! Great addon.",
            date = "09.08.2024",
        },
        {
            name = f.bb("Helge"),
            type = kofi,
            message = "Great work!",
            date = "06.08.2024",
        },
        {
            name = f.bb("Krixi"),
            type = kofi,
            message = "Thanks for all your work!",
            date = "05.08.2024",
        },
        {
            name = f.bb("Zach B."),
            type = paypal,
            message = "For my favourite addon",
            date = "30.07.2024",
        },
        {
            name = f.bb("Hademar"),
            type = kofi,
            message = "Thanks for still working on this great addon and good luck going into TWW! <3",
            date = "13.06.2024",
        },
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
