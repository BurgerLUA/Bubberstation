/obj/structure/mold/structure/
	var/icon/underfloor_icon = 'modular_zubbers/modules/mold/icons/mold_base_01.dmi'

/obj/structure/mold/structure/update_overlays()
	SSvis_overlays.remove_vis_overlay(src, managed_vis_overlays)
	. = ..()
	var/obj/effect/overlay/vis/overlay1 = SSvis_overlays.add_vis_overlay(src, underfloor_icon, "[x % 10],[y % 10]", layer-1, plane, dir, alpha)
	overlay1.appearance_flags = PIXEL_SCALE | TILE_BOUND

/obj/structure/mold/structure/core
	icon = 'modular_zubbers/modules/mold/icons/mold_overlays.dmi'
	icon_state = "blob_core"

/obj/structure/mold/structure/bulb
	icon = 'modular_zubbers/modules/mold/icons/mold_overlays.dmi'
	icon_state = "blob_bulb"

/obj/structure/mold/structure/spawner
	icon = 'modular_zubbers/modules/mold/icons/mold_overlays.dmi'
	icon_state = "blob_spawner"

/obj/structure/mold/structure/spawner/update_overlays() //Not actually included in the skyrat file.
	SSvis_overlays.remove_vis_overlay(src, managed_vis_overlays)
	. = ..()
	var/obj/effect/overlay/vis/overlay1 = SSvis_overlays.add_vis_overlay(src, icon, "blob_spawner_overlay", layer, plane, dir, alpha)
	var/obj/effect/overlay/vis/overlay2 = SSvis_overlays.add_vis_overlay(src, icon, "blob_spawner_overlay", 0, EMISSIVE_PLANE, dir, alpha)
	overlay1.appearance_flags = PIXEL_SCALE | TILE_BOUND | RESET_COLOR
	overlay2.appearance_flags = PIXEL_SCALE | TILE_BOUND | RESET_COLOR