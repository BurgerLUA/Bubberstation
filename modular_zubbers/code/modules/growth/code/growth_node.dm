/obj/structure/interactive/blob/node
	name = "blob node"
	icon_state = "node"
	desc_extended = "A segment of the ever-expanding blob. This one creates and deploys blobbernaughts if the blob's expanse is hindered by the living."
	has_damaged_state = TRUE
	health_base = 250

	health_states = 2

	var/mob/living/simple/blobbernaught/linked_mob

	var/next_spawn = 0

/obj/structure/interactive/blob/node/New(var/desired_loc,var/obj/structure/interactive/blob/core/desired_owner)

	. = ..()

	if(desired_owner)
		desired_owner.linked_nodes += src

/obj/structure/interactive/blob/node/Destroy()
	linked_mob = null
	. = ..()

/obj/structure/interactive/blob/node/proc/check_mob()

	if(QDELETED(src))
		return FALSE

	if(!linked_mob)
		if(next_spawn <= world.time)
			linked_mob = new(get_turf(src),null,1,src)
			INITIALIZE(linked_mob)
			GENERATE(linked_mob)
			FINALIZE(linked_mob)
			return TRUE
	else if( (linked_mob.stat & DEAD) || QDELETED(linked_mob))
		linked_mob = null
		next_spawn = world.time + SECONDS_TO_DECISECONDS(60)

	return FALSE

