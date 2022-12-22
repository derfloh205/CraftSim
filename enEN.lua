CraftSimLOC_EN = {}

function CraftSimLOC_EN:GetData()
    return {
        -- Profit Breakdown Tooltips
        [CraftSimCONST.TEXT.RESOURCEFULNESS_EXPLANATION_TOOLTIP] = "Resourcefulness proccs for every material individually and then saves about 30% of its quantity.\n\nThe average value it saves is the average saved value of EVERY combination and their chances.\n(All materials proccing at once is very unlikely but saves a lot)\n\nThe average total saved material costs is the sum of the saved material costs of all combinations weighted against their chance.",
        [CraftSimCONST.TEXT.MULTICRAFT_ADDITIONAL_ITEMS_EXPLANATION_TOOLTIP] = "This number shows the average amount of items that are additionally created by multicraft.\n\nThis considers your chance and assumes for multicraft that\n(1-2.5y)*any_spec_bonus additional items are created where y is base average of items created for 1 craft",
        [CraftSimCONST.TEXT.MULTICRAFT_ADDITIONAL_ITEMS_VALUE_EXPLANATION_TOOLTIP] = "This is the average number of additional items created by multicraft times the sell price of the result item on this quality",
        [CraftSimCONST.TEXT.MULTICRAFT_ADDITIONAL_ITEMS_HIGHER_VALUE_EXPLANATION_TOOLTIP] = "This is the average number of additional items created by multicraft and inspiration times the sell price of the result item on the quality reached by inspiration",
        [CraftSimCONST.TEXT.MULTICRAFT_ADDITIONAL_ITEMS_HIGHER_QUALITY_EXPLANATION_TOOLTIP] = "This number shows the average amount of items that are additionally created by multicraft proccing with inspiration.\n\nThis considers your multicraft and inspiration chance and reflects the additional items created when both procc at once",
        [CraftSimCONST.TEXT.INSPIRATION_ADDITIONAL_ITEMS_EXPLANATION_TOOLTIP] = "This number shows the average amount of items that are created on your current guaranteed quality, when inspiration does not procc",
        [CraftSimCONST.TEXT.INSPIRATION_ADDITIONAL_ITEMS_HIGHER_QUALITY_EXPLANATION_TOOLTIP] = "This number shows the average amount of items that are created on the next reachable quality with inspiration",
        [CraftSimCONST.TEXT.INSPIRATION_ADDITIONAL_ITEMS_VALUE_EXPLANATION_TOOLTIP] = "This is the average number of items created on the guaranteed quality times the sell price of the result item on this quality",
        [CraftSimCONST.TEXT.INSPIRATION_ADDITIONAL_ITEMS_HIGHER_VALUE_EXPLANATION_TOOLTIP] = "This is the average number of items created on the quality reached with inspiration times the sell price of the result item on the quality reached by inspiration",
    
        -- Details Frame
        [CraftSimCONST.TEXT.RECIPE_DIFFICULTY_LABEL] = "Recipe Difficulty: ",
    }
end