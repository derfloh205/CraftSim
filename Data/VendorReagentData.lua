---@class CraftSim
local CraftSim = select(2, ...)

---@class CraftSim.VendorReagentEntry
---@field price number  copper (base price, no reputation discount)
---@field vendorName string  display name of the vendor NPC
---@field zoneID number  uiMapID of the zone; 0 = sold across multiple zones

---@type table<ItemID, CraftSim.VendorReagentEntry>
CraftSim.VENDOR_REAGENT_DATA = {

    -- ============================================================
    -- CLASSIC
    -- ============================================================

    -- Tailoring / Trade Goods
    [4340]  = { price = 10,   vendorName = "Trade Goods Vendors",  zoneID = 0 }, -- Coarse Thread
    [4291]  = { price = 100,  vendorName = "Trade Goods Vendors",  zoneID = 0 }, -- Silken Thread
    [6260]  = { price = 50,   vendorName = "Tailoring Suppliers",  zoneID = 0 }, -- Runed Thread
    [4289]  = { price = 100,  vendorName = "Trade Goods Vendors",  zoneID = 0 }, -- Coarse Salt

    -- Blacksmithing / Mining
    [2880]  = { price = 500,  vendorName = "Mining Suppliers",     zoneID = 0 }, -- Weak Flux
    [3427]  = { price = 1000, vendorName = "Mining Suppliers",     zoneID = 0 }, -- Strong Flux
    [10558] = { price = 500,  vendorName = "Mining Suppliers",     zoneID = 0 }, -- Coal (Blacksmithing)

    -- Alchemy
    [3371]  = { price = 100,  vendorName = "Alchemy Suppliers",    zoneID = 0 }, -- Crystal Vial
    [5956]  = { price = 100,  vendorName = "Alchemy Suppliers",    zoneID = 0 }, -- Crystal Vial (variant)

    -- Enchanting
    [17020] = { price = 2000, vendorName = "Enchanting Suppliers", zoneID = 0 }, -- Runed Copper Rod (sold as upgrade)

    -- ============================================================
    -- THE BURNING CRUSADE
    -- ============================================================

    [22147] = { price = 150,  vendorName = "Trade Goods Vendors",  zoneID = 0 }, -- Netherweave Cloth (not exact)
    [21877] = { price = 400,  vendorName = "Outland Tailoring",    zoneID = 0 }, -- Diaphanous Thread

    -- ============================================================
    -- WRATH OF THE LICH KING
    -- ============================================================

    [14341] = { price = 400,  vendorName = "Tailoring Suppliers",  zoneID = 0 }, -- Rune Thread
    [38426] = { price = 1600, vendorName = "Trade Goods Vendors",  zoneID = 0 }, -- Eternium Thread

    -- ============================================================
    -- CATACLYSM
    -- ============================================================

    [52329] = { price = 500,  vendorName = "Trade Goods Vendors",  zoneID = 0 }, -- Embroidery Thread

    -- ============================================================
    -- MISTS OF PANDARIA
    -- ============================================================

    [72054] = { price = 1500, vendorName = "Tailoring Suppliers",  zoneID = 862 }, -- Silkweed (vendor sold in Pandaria)

    -- ============================================================
    -- WARLORDS OF DRAENOR
    -- ============================================================

    [111556] = { price = 500,  vendorName = "Trade Goods Vendors", zoneID = 0 }, -- Sumptuous Fur (not typically vendor)

    -- ============================================================
    -- LEGION
    -- ============================================================

    [124124] = { price = 3500, vendorName = "Tailoring Suppliers", zoneID = 0 }, -- Shal'dorei Silk Thread

    -- ============================================================
    -- BATTLE FOR AZEROTH
    -- ============================================================

    [154119] = { price = 1200, vendorName = "Trade Goods Vendors", zoneID = 0 }, -- Embroidered Deep Sea Satin

    -- ============================================================
    -- SHADOWLANDS
    -- ============================================================

    [175878] = { price = 750,  vendorName = "Trade Goods Vendors", zoneID = 0 }, -- Nightforged Steel (vendor sold)

    -- ============================================================
    -- DRAGONFLIGHT
    -- ============================================================

    [194128] = { price = 400,  vendorName = "Trade Goods Vendors", zoneID = 0 }, -- Dracothyst
    [194704] = { price = 200,  vendorName = "Alchemy Suppliers",   zoneID = 0 }, -- Empty Vial (DF)
    [194706] = { price = 300,  vendorName = "Alchemy Suppliers",   zoneID = 0 }, -- Leaded Vial (DF)
    [194708] = { price = 400,  vendorName = "Alchemy Suppliers",   zoneID = 0 }, -- Crystal Vial (DF)
    [194709] = { price = 600,  vendorName = "Alchemy Suppliers",   zoneID = 0 }, -- Imbued Vial (DF)

    -- ============================================================
    -- THE WAR WITHIN
    -- ============================================================

    [224054] = { price = 500,  vendorName = "Trade Goods Vendors", zoneID = 0 }, -- Khaz Algar Silk Thread
    [224057] = { price = 400,  vendorName = "Alchemy Suppliers",   zoneID = 0 }, -- Azerite Vial (TWW)

    -- ============================================================
    -- MIDNIGHT  (Phase 5: Housing Decor legacy reagents populated
    --            primarily via MERCHANT_SHOW dynamic scanning)
    -- ============================================================
    -- NOTE: Midnight reagents are discovered and cached automatically
    --       when the player visits any vendor in-game.
    --       Add confirmed static entries here as expansion matures.
}
