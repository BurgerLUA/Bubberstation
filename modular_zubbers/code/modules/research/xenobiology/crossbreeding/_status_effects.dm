/datum/status_effect/stabilized/rainbow/tick(seconds_between_ticks)
	if(owner.stat = DEAD)
		var/obj/item/slimecross/stabilized/rainbow/X = linked_extract
		if(istype(X))
			if(X.regencore)
				X.regencore.interact_with_atom(owner, owner)
				X.regencore = null
				owner.visible_message(span_warning("[owner] flashes a rainbow of colors, and [owner.p_their()] skin is coated in a milky regenerative goo!"))
				qdel(src)
				qdel(linked_extract)
	return ..()
