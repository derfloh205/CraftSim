necessary tables as csv from wago.tools:
- ModifiedCraftingReagentItem -> Maps ModifiedCraftingReagentItemID to ModifiedCraftingCategoryID
- ModifiedCraftingCategory -> Maps ModifiedCraftingCategoryID to MatQualityWeight
- Item -> ClassID 7 = TradeSkillReagents, Maps ItemID to ModifiedCraftingReagentItemID, everything with id not 0 is relevant

Mapping Process

For each TradeSkillReagent Item in Item with ClassID 7 and ModifiedCraftingReagentItemID not 0 and CraftingQualityID not 0:
fetch the ModifiedCraftingCategoryID from ModifiedCraftingReagentItem by ModifiedCraftingReagentItemID
fetch the MatQualityWeight from ModifiedCraftingCategory by ModifiedCraftingCategoryID

