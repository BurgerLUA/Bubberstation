

/proc/generate_loadout_recommendation_for_clothing_type(/obj/item/clothing/clothing_type)

	for(var/k in subtypesof(clothing_subtype))

		var/obj/item/clothing/found_clothing = k

		//Only add colorable options.
		if(found_clothing.flags_1 & IS_PLAYER_COLORABLE_1)
			continue

		//Don't add the option if it has armor.
		if(found_clothing.armor_type)
			var/has_armor = FALSE
			var/datum/armor/found_armor = GLOB.armor_by_type[found_clothing.armor_type]
			for(var/rating as anything in (ARMOR_LIST_ALL() - WOUND))
				if(found_armor.vars[rating] > 0)
					has_armor = TRUE
					break
			if(has_armor)
				continue

		//If the type has the same description as the parent, then that means it's likely the same item, but a different color.
		var/obj/item/clothing/parent_type = found_clothing.parent_type
		if(found_clothing.desc == found_clothing.desc)
			continue