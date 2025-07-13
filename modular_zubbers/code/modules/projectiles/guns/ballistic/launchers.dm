/obj/item/gun/ballistic/revolver/grenadelauncher/cyborg
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/cylinder/grenademulti/stingbang

/obj/item/ammo_box/magazine/internal/cylinder/grenademulti/stingbang
	ammo_type = /obj/item/ammo_casing/a40mm/stingbang

/obj/item/ammo_casing/a40mm/stingbang
	name = "40mm stingbang shell"
	desc = "A cased stringbang grenade that can only be activated once fired out of a grenade launcher."
	projectile_type = /obj/projectile/bullet/a40mm_stingbang

/obj/projectile/bullet/a40mm_stingbang
	name ="40mm stingbang grenade"
	desc = "USE A WEEL GUN"
	icon_state = "bolter"
	damage = 60
	embed_type = null
	shrapnel_type = /obj/projectile/bullet/pellet/stingball
	shrapnel_radius = 5
