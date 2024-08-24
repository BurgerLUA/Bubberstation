/obj/structure/interactive/growth/core

	name = "growth core"
	desc = ""
	icon_state = "core"

	max_integrity = 500

	var/list/obj/structure/interactive/growth/linked_walls = list()
	var/list/obj/structure/interactive/growth/node/linked_nodes = list()
	var/current_node = 1

	var/next_grow = 0
	var/fast_grows_left = 100
	var/heal_amount = 10 //How much to heal as well the starting HP of new growth walls.

	var/list/turf/lost_turfs = list()

	var/growth_limit = 700


/obj/structure/interactive/growth/core/New(var/desired_loc,var/obj/structure/interactive/growth/core/desired_owner)
	color = random_color()
	if(!color)
		color = "#00FF00"
	. = ..()

/obj/structure/interactive/growth/core/Destory()

	for(var/obj/structure/interactive/growth/found_wall as anything in linked_walls)
		found_wall.color = null
		found_wall.modify_max_integrity(1, can_break = FALSE, damage_type = BRUTE)

	for(var/obj/structure/interactive/growth/found_node as anything in linked_nodes)
		found_node.atom_break()

	linked_walls?.Cut()
	linked_nodes?.Cut()

	. = ..()

	return ..()

/obj/structure/interactive/growth/core/Initialize()

	for(var/possible_direction in DIRECTIONS_ALL)
		var/turf/other_turf = get_step(src,possible_direction)
		var/obj/structure/interactive/growth/node/possible_node = new(other_turf,src)
		possible_node.color = color
		linked_nodes += possible_node

	. = ..()

	//Todo: Make this process.

/obj/structure/interactive/growth/core/process()

	if(next_grow <= world.time || fast_grows_left > 0)
		var/node_count = length(linked_nodes)
		if(node_count)
			if(health.health_current > 0)
				health.adjust_loss_smart(brute = -node_count) //Core gets HP regen.
			if(current_node > node_count)
				current_node = 1
			var/turf/priority_turf
			if(length(lost_turfs))
				priority_turf = pick(lost_turfs)
			var/obj/structure/interactive/growth/node/N = linked_nodes[current_node]
			N.grow_charge(src,src,1,priority_turf)
			next_grow = world.time + CEILING(SECONDS_TO_DECISECONDS(5)/max(1,node_count),1)
			current_node++
			if(fast_grows_left > 0)
				fast_grows_left--

	. = ..()

/obj/structure/interactive/growth/core/on_update_integrity(old_value, new_value)

	. = ..()

	if(old_value > new_value)
		fast_grows_left += (old_value - new_value)
