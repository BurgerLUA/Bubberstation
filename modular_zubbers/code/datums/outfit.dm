/datum/outfit/proc/equip_outfit_item(mob/living/carbon/human/user,obj/item/item_path, slot_name, visualsOnly)

	var/obj/item/equipment_item = SSwardrobe.provide_type(item_path, user)

	var/success = FALSE

	success = user.equip_to_slot_if_possible(
		equipment_item,
		slot_name,
		qdel_on_fail = FALSE,
		disable_warning = TRUE,
		redraw_mob = FALSE,
		bypass_equip_delay_self = TRUE,
		initial = TRUE,
		indirect_action = TRUE
	)

	if(!success)
		success = user.equip_to_appropriate_slot(
			equipment_item,
			qdel_on_fail = FALSE,
			indirect_action=TRUE,
			blacklist=slot_name,
			initial = TRUE
		)

	if(!success)
		qdel(equipment_item)
		return null

	equipment_item.on_outfit_equip(user, visualsOnly, slot_name)

	return equipment_item

/datum/outfit/equip(mob/living/carbon/human/user, visualsOnly = FALSE)

	pre_equip(user, visualsOnly)

	var/list/equipped_items = list()

	if(undershirt)
		user.undershirt = initial(undershirt.name)
	if(underwear)
		user.underwear = initial(underwear.name)
	if(socks)
		user.socks = initial(socks.name)
	if(bra)
		user.bra = initial(bra.name)

	//The order here is important.
	if(back)
		equipped_items += equip_outfit_item(user, back, ITEM_SLOT_BACK, visualsOnly)
	if(uniform)
		var/obj/item/clothing/under/spawned_uniform = equip_outfit_item(user, uniform, ITEM_SLOT_ICLOTHING, visualsOnly)
		equipped_items += spawned_uniform
		if(accessory && istype(spawned_uniform))
			spawned_uniform.attach_accessory(SSwardrobe.provide_type(accessory, user))
	if(!visualsOnly)
		if(l_pocket)
			equipped_items += equip_outfit_item(user, l_pocket, ITEM_SLOT_LPOCKET, visualsOnly)
		if(r_pocket)
			equipped_items += equip_outfit_item(user, r_pocket, ITEM_SLOT_RPOCKET, visualsOnly)
	if(belt)
		equipped_items += equip_outfit_item(user, belt, ITEM_SLOT_BELT, visualsOnly)
	if(suit)
		equipped_items += equip_outfit_item(user, suit, ITEM_SLOT_OCLOTHING, visualsOnly)
	if(suit_store)
		equipped_items += equip_outfit_item(user, suit_store, ITEM_SLOT_SUITSTORE, visualsOnly)
	if(l_hand)
		user.put_in_l_hand(SSwardrobe.provide_type(l_hand, user))
	if(r_hand)
		user.put_in_r_hand(SSwardrobe.provide_type(r_hand, user))
	if(gloves)
		equipped_items += equip_outfit_item(user, gloves, ITEM_SLOT_GLOVES, visualsOnly)
	if(shoes)
		equipped_items += equip_outfit_item(user, shoes, ITEM_SLOT_FEET, visualsOnly)
	if(head)
		equipped_items += equip_outfit_item(user, head, ITEM_SLOT_HEAD, visualsOnly)
	if(mask)
		equipped_items += equip_outfit_item(user, mask, ITEM_SLOT_MASK, visualsOnly)
	if(neck)
		equipped_items += equip_outfit_item(user, neck, ITEM_SLOT_NECK, visualsOnly)
	if(ears)
		equipped_items += equip_outfit_item(user, ears, ITEM_SLOT_EARS, visualsOnly)
	if(glasses)
		equipped_items += equip_outfit_item(user, glasses, ITEM_SLOT_EYES, visualsOnly)
	if(id)
		var/obj/item/card/id/id_card = equip_outfit_item(user, id, ITEM_SLOT_ID, visualsOnly)
		equipped_items += id_card
		if(!visualsOnly && istype(id_card))
			id_card.registered_age = user.age
			if(id_trim)
				if(!SSid_access.apply_trim_to_card(id_card, id_trim))
					WARNING("Unable to apply trim [id_trim] to [id_card] in outfit [name].")
				user.sec_hud_set_ID()
	if(!visualsOnly) // Items in pockets or backpack don't show up on mob's icon.
		if(box)
			equip_outfit_item(user, box, ITEM_SLOT_BACKPACK, visualsOnly)
		if(backpack_contents)
			for(var/path in backpack_contents)
				var/number = backpack_contents[path]
				if(!isnum(number))//Default to 1 if it isn't a key/value list.
					number = 1
				for(var/i in 1 to number)
					equip_outfit_item(user, path, ITEM_SLOT_BACKPACK, visualsOnly)

	if(!visualsOnly)
		var/obj/item/storage/briefcase/empty/suitcase //Fuck you, it's a suitcase. It stores suits.
		for(var/obj/item/equipped_item as anything in equipped_items)
			if(!equipped_item)
				to_chat(user,span_notice("NULL entry existed in equipped_items."))
				continue
			if(!equipped_item.loc)
				to_chat(user,span_notice("[equipped_item.type] was in a NULL loc!"))
				continue
			to_chat(user,span_notice("[equipped_item] is on [equipped_item.loc]"))
			if(equipped_item.loc != user.loc) //All good in the hood.
				continue
			//On the ground! Pick that shit up!
			if(!suitcase)
				to_chat(user,span_notice("Giving you a suitcase..."))
				suitcase = new(user.loc)
				var/list/dropped_items = user.drop_all_held_items()
				user.put_in_hands(suitcase)
				for(var/obj/item/dropped_item as anything in dropped_items)
					dropped_item.forceMove(suitcase)
			equipped_item.forceMove(suitcase)

	post_equip(user, visualsOnly, equipped_items)

	if(!visualsOnly)
		apply_fingerprints(user)
		if(internals_slot)
			if(internals_slot & ITEM_SLOT_HANDS)
				var/obj/item/tank/internals/internals = user.is_holding_item_of_type(/obj/item/tank/internals)
				if(internals)
					user.open_internals(internals)
			else
				user.open_internals(user.get_item_by_slot(internals_slot))
		if(implants)
			for(var/implant_type in implants)
				var/obj/item/implant/implanter = SSwardrobe.provide_type(implant_type, user)
				implanter.implant(user, null, TRUE)

		// Insert the skillchips associated with this outfit into the target.
		if(skillchips)
			for(var/skillchip_path in skillchips)
				var/obj/item/skillchip/skillchip_instance = SSwardrobe.provide_type(skillchip_path)
				var/implant_msg = user.implant_skillchip(skillchip_instance)
				if(implant_msg)
					stack_trace("Failed to implant [user] with [skillchip_instance], on job [src]. Failure message: [implant_msg]")
					qdel(skillchip_instance)
					return

				var/activate_msg = skillchip_instance.try_activate_skillchip(TRUE, TRUE)
				if(activate_msg)
					CRASH("Failed to activate [user]'s [skillchip_instance], on job [src]. Failure message: [activate_msg]")

	user.update_body()
	return TRUE


/datum/outfit/job/post_equip(mob/living/carbon/human/equipped, visualsOnly = FALSE, list/equipped_items)

	if(visualsOnly)
		return

	var/datum/job/equipped_job = SSjob.GetJobType(jobtype)

	if(!equipped_job)
		equipped_job = SSjob.GetJob(equipped.job)

	var/obj/item/card/id/card = locate(/obj/item/card/id) in equipped_items

	if(card)
		ADD_TRAIT(card, TRAIT_JOB_FIRST_ID_CARD, ROUNDSTART_TRAIT)
		shuffle_inplace(card.access) // Shuffle access list to make NTNet passkeys less predictable
		card.registered_name = equipped.real_name

		if(equipped.age)
			card.registered_age = equipped.age

		card.update_label()
		card.update_icon()
		var/datum/bank_account/account = SSeconomy.bank_accounts_by_id["[equipped.account_id]"]

		if(account && account.account_id == equipped.account_id)
			card.registered_account = account
			account.bank_cards += card

		equipped.sec_hud_set_ID()

	var/obj/item/modular_computer/pda/pda = locate(/obj/item/modular_computer/pda) in equipped_items

	if(pda)
		pda.imprint_id(equipped.real_name, equipped_job.title)
		pda.update_ringtone(equipped_job.job_tone)
		pda.UpdateDisplay()

		var/client/equipped_client = GLOB.directory[ckey(equipped.mind?.key)]

		if(equipped_client)
			pda.update_pda_prefs(equipped_client)
