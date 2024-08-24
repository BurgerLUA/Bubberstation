/obj/structure/growth/
	name = "growth piece"
	desc = "Confirmed outbreak of level 5 biohazard aboard the station. All personnel must contain the outbreak."

	icon = 'icons/obj/structure/growth.dmi'

	var/obj/structure/growth/core/linked_core
	var/list/obj/structure/growth/adjacent_growths

	var/inert = FALSE

	max_integrity = 1

/obj/structure/growth/Destroy()

	if(linked_core)
		linked_core.linked_walls -= src
		linked_core.linked_nodes -= src
		linked_core = null

	for(var/obj/structure/growth/growth as anything in adjacent_growths)
		growth.adjacent_growths -= src
		adjacent_growths -= growth

	. = ..()

/obj/structure/growth/proc/grow_charge(var/obj/structure/growth/original_growth,var/obj/structure/growth/last_growth,var/tolerance=1,var/turf/priority_turf)

	if(QDELETING(src) || QDELETING(original_growth) || QDELETING(qdeleting))
		return FALSE

	tolerance += 0.1

	var/prefered_dir = last_growth ? get_dir(last_growth,src) : null //Keep the momentum.
	var/prefered_dir_2 = original_growth ? get_dir(original_growth,src) : null //Move away from the core to expand.
	if(linked_core)
		atom_integrity = min(max_integrity, atom_integrity+linked_core.heal_amount)

	if(src.inert) //Inerts can't make anything.
		return TRUE

	var/list/possible_options = list()
	var/list/possible_options_inert = list()

	for(var/obj/structure/growth/growth as anything in adjacent_growths)
		var/growth_direction = get_dir(src,growth)
		if(growth.color != color)
			continue
		if(priority_turf && growth_direction & get_dir(src,priority_turf))
			possible_options += growth
			if(growth.inert)
				possible_options_inert += growth
		else if(prefered_dir_2 && growth_direction & prefered_dir_2)
			possible_options += growth
			if(growth.inert)
				possible_options_inert += growth
		else if(prefered_dir && growth_direction & prefered_dir) //Looks like we're kinda stuck. Float around in circles if possible.
			possible_options += growth
			if(growth.inert)
				possible_options_inert += growth

	var/options = length(possible_options)

	if(options >= tolerance)

		var/obj/structure/growth/chosen_growth

		if(length(possible_options_inert))
			chosen_growth = pick(possible_options_inert)
		else
			chosen_growth = pick(possible_options)

		addtimer(CALLBACK(src, TYPE_PROC_REF(/obj/structure/growth/, grow_charge), original_growth, src, tolerance, priority_turf), 1)

	else

		var/list/possible_spawns = list()

		for(var/possible_dir in DIRECTIONS_CARDINAL)
			var/turf/possible_turf = get_step(src,possible_dir)
			if(linked_core && possible_turf == priority_turf)
				linked_core.lost_turfs -= priority_turf

			var/did_attack = FALSE
			if(possible_turf.uses_integrity)
				possible_turf.take_damage(25, damage_type = BRUTE, damage_flag = "", sound_effect = TRUE, possible_dir, armour_penetration = 0)
				did_attack = TRUE
				break

			for(var/atom/movable/possible_target as anything in possible_turf)
				if(!possible_target.uses_integrity)
					continue
				if(istype(possible_target,/obj/structure/growth/))
					continue
				possible_target.take_damage(25, damage_type = BRUTE, damage_flag = "", sound_effect = TRUE, possible_dir, armour_penetration = 0)
				did_attack = TRUE
				break

			if(!did_attack)
				possible_spawns += possible_turf

		if(length(possible_spawns))

			var/make_inert = length(linked_core.linked_walls) > linked_core.growth_limit

			var/turf/possible_turf = pick(possible_spawns)
			var/obj/structure/growth/node/found_node = locate() in range(4,possible_turf)

			var/obj/structure/growth/growth
			if(found_node)
				growth = new/obj/structure/growth/wall(possible_turf,linked_core) //Already a node nearby. Make one.
				if(make_inert)
					growth.inert = TRUE
					growth.name = "inert [initial(growth.name)]"
			else
				growth = new/obj/structure/growth/node(possible_turf,linked_core) //Make a node if there is none.
			growth.color = "#000000"
			growth.alpha = 0
			animate(growth,transform=growth.get_base_transform(),alpha=255,color=src.color)

	return TRUE

/obj/structure/growth/New(var/desired_loc,var/obj/structure/growth/core/desired_owner)

	adjacent_growths = list()

	turn_angle = pick(0,90,180,270)
	if(desired_owner)
		linked_core = desired_owner
		linked_core.linked_walls += src

	. = ..()


/obj/structure/growth/Initialize()

	. = ..()

	for(var/possible_dir in DIRECTIONS_CARDINAL)
		var/turf/possible_turf = get_step(src,possible_dir)
		if(!possible_turf)
			continue
		var/obj/structure/growth/growth = locate() in possible_turf.contents
		if(growth)
			adjacent_growths |= growth
			growth.adjacent_growths |= src



/obj/structure/growth/update_icon_state()
	. = ..()
	icon_state = "[x % 10],[y % 10]"


/obj/structure/growth/on_update_integrity(old_value, new_value)

	. = ..()

	if(new_value < old_value)
		play_sound(pick('sound/effects/impacts/flesh_01.ogg','sound/effects/impacts/flesh_02.ogg','sound/effects/impacts/flesh_03.ogg'),self_turf)


/obj/structure/growth/atom_break(damage_flag)
	if(linked_core)
		linked_core.lost_turfs += self_turf //Don't worry about duplicate turfs.
	. = ..()
