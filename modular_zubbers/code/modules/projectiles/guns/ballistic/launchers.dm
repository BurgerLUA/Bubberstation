/obj/item/gun/ballistic/revolver/grenadelauncher/cyborg
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/cylinder/grenademulti/stingbang

/obj/item/ammo_box/magazine/internal/cylinder/grenademulti/stingbang
	ammo_type = /obj/item/ammo_casing/a40mm/stingbang

/obj/item/ammo_casing/a40mm/stingbang
	name = "40mm stingbang shell"
	desc = "A cased stringbang grenade that can only be activated once fired out of a grenade launcher."
	projectile_type = /obj/projectile/bullet/a40mm_stingbang


/obj/item/ammo_casing/a40mm/stingbang/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/caseless, TRUE)

/obj/projectile/bullet/a40mm_stingbang
	name ="40mm stingbang grenade"
	desc = "USE A WEEL GUN"
	icon_state = "bolter"
	damage = 60
	embed_type = null

	var/shrapnel_to_create = /obj/projectile/bullet/pellet/stingball
	var/shrapnel_radius = 5

/obj/projectile/bullet/a40mm_stingbang/on_hit(atom/target, blocked = 0, pierce_hit)

	..()

	//Stolen from code/datums/components/mirv.dm

	if(!target)
		return BULLET_ACT_BLOCK

	var/turf/target_turf = get_turf(target)
	if(!target_turf)
		return BULLET_ACT_BLOCK

	for(var/turf/shootat_turf as anything in (RANGE_TURFS(shrapnel_radius, target_turf) - RANGE_TURFS(shrapnel_radius-1, target_turf)) )
		var/obj/projectile/proj = new shrapnel_to_create(target_turf)
		//Shooting Code:
		proj.range = shrapnel_radius+1
		proj.aim_projectile(shootat_turf, target)
		proj.firer = firer // don't hit ourself that would be really annoying
		proj.fire()

	return BULLET_ACT_HIT