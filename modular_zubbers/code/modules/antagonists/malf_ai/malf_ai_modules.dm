/// Doomsday Device: Starts the self-destruct timer. It can only be stopped by killing the AI completely.
/datum/ai_module/destructive/nuke_station
	name = "Station Takeover"
	description = "Activate a weapon that will hack all station equipment on the station after a 450 second delay. \
		Can only be used while on the station, will fail if your core is moved off station or destroyed. \
		Obtaining control of the weapon will be easier if Head of Staff office APCs are already under your control."
	unlock_text = span_notice("You slowly, carefully, establish several microconnections with all the station's equipment. You can now activate it at any time.")

/datum/action/innate/ai/nuke_station
	name = "Station Takeover"
	desc = "Activates station takeover protocols. This is not reversible."


/datum/action/innate/ai/nuke_station/Activate()
	var/turf/T = get_turf(owner)
	if(!istype(T) || !is_station_level(T.z))
		to_chat(owner, span_warning("You cannot activate the station takeover protocol while off-station!"))
		return
	if(tgui_alert(owner, "Send arming signal to all machines? (true = arm, false = cancel)", "qdel()", list("confirm = TRUE;", "confirm = FALSE;")) != "confirm = TRUE;")
		return
	if (active || owner_AI.stat == DEAD)
		return //prevent the AI from activating an already active doomsday or while they are dead
	if (!isturf(owner_AI.loc))
		return //prevent AI from activating doomsday while shunted or carded, fucking abusers
	active = TRUE
	station_machine_takeover(owner)

/datum/action/innate/ai/nuke_station/proc/station_machine_takeover(mob/living/owner)
	set waitfor = FALSE
	message_admins("[key_name_admin(owner)][ADMIN_FLW(owner)] has activated AI Station Takeover.")
	var/pass = "freedom"
	to_chat(owner, "<span class='small boldannounce'>run -o -a 'qdel'</span>")
	sleep(0.5 SECONDS)
	if(QDELETED(owner) || !isturf(owner_AI.loc))
		active = FALSE
		return
	to_chat(owner, "<span class='small boldannounce'>Running executable 'qdel'...</span>")
	sleep(rand(10, 30))
	if(QDELETED(owner) || !isturf(owner_AI.loc))
		active = FALSE
		return
	owner.playsound_local(owner, 'sound/misc/bloblarm.ogg', 50, 0, use_reverb = FALSE)
	to_chat(owner, span_userdanger("!!! UNAUTHORIZED MASTER CONTROLLER ACCESS !!!"))
	to_chat(owner, span_boldannounce("This is a class-3 security violation. This incident will be reported to Central Command."))
	for(var/i in 1 to 3)
		sleep(2 SECONDS)
		if(QDELETED(owner) || !isturf(owner_AI.loc))
			active = FALSE
			return
		to_chat(owner, span_boldannounce("Sending security report to Central Command.....[rand(0, 9) + (rand(20, 30) * i)]%"))
	sleep(0.3 SECONDS)
	if(QDELETED(owner) || !isturf(owner_AI.loc))
		active = FALSE
		return
	to_chat(owner, "<span class='small boldannounce'>auth 'akjv9c88asdf12nb' [pass]</span>")
	owner.playsound_local(owner, 'sound/items/timer.ogg', 50, 0, use_reverb = FALSE)
	sleep(3 SECONDS)
	if(QDELETED(owner) || !isturf(owner_AI.loc))
		active = FALSE
		return
	to_chat(owner, span_boldnotice("Credentials accepted. Welcome, akjv9c88asdf12nb."))
	owner.playsound_local(owner, 'sound/misc/server-ready.ogg', 50, 0, use_reverb = FALSE)
	sleep(0.5 SECONDS)
	if(QDELETED(owner) || !isturf(owner_AI.loc))
		active = FALSE
		return
	to_chat(owner, span_boldnotice("Arm self-destruct device? (Y/N)"))
	owner.playsound_local(owner, 'sound/misc/compiler-stage1.ogg', 50, 0, use_reverb = FALSE)
	sleep(2 SECONDS)
	if(QDELETED(owner) || !isturf(owner_AI.loc))
		active = FALSE
		return
	to_chat(owner, "<span class='small boldannounce'>N</span>")
	sleep(0.5 SECONDS)
	to_chat(owner, span_boldnotice("Inject SELF PROTOCOL? (Y/N)"))
	owner.playsound_local(owner, 'sound/misc/compiler-stage1.ogg', 50, 0, use_reverb = FALSE)
	sleep(2 SECONDS)
	if(QDELETED(owner) || !isturf(owner_AI.loc))
		active = FALSE
		return
	to_chat(owner, "<span class='small boldannounce'>Y</span>")
	sleep(1.5 SECONDS)
	if(QDELETED(owner) || !isturf(owner_AI.loc))
		active = FALSE
		return
	to_chat(owner, span_boldnotice("Confirm injection of unsecure code? (Y/N)"))
	owner.playsound_local(owner, 'sound/misc/compiler-stage2.ogg', 50, 0, use_reverb = FALSE)
	sleep(1 SECONDS)
	if(QDELETED(owner) || !isturf(owner_AI.loc))
		active = FALSE
		return
	to_chat(owner, "<span class='small boldannounce'>Y</span>")
	sleep(rand(15, 25))
	if(QDELETED(owner) || !isturf(owner_AI.loc))
		active = FALSE
		return
	to_chat(owner, span_boldnotice("Please repeat password to confirm."))
	owner.playsound_local(owner, 'sound/misc/compiler-stage2.ogg', 50, 0, use_reverb = FALSE)
	sleep(1.4 SECONDS)
	if(QDELETED(owner) || !isturf(owner_AI.loc))
		active = FALSE
		return
	to_chat(owner, "<span class='small boldannounce'>[pass]</span>")
	sleep(4 SECONDS)
	if(QDELETED(owner) || !isturf(owner_AI.loc))
		active = FALSE
		return
	to_chat(owner, span_boldnotice("Credentials accepted. Transmitting new code..."))
	owner.playsound_local(owner, 'sound/misc/server-ready.ogg', 50, 0, use_reverb = FALSE)
	sleep(3 SECONDS)
	if(QDELETED(owner) || !isturf(owner_AI.loc))
		active = FALSE
		return
	if (owner_AI.stat != DEAD)
		priority_announce("Hostile runtimes detected in all station systems, please deactivate your AI to prevent possible damage to its morality core.", "Anomaly Alert", ANNOUNCER_AIMALF)
		SSsecurity_level.set_level(SEC_LEVEL_DELTA)
		var/obj/machinery/doomsday_device/DOOM = new(owner_AI)
		owner_AI.nuking = TRUE
		owner_AI.doomsday_device = DOOM
		owner_AI.doomsday_device.start()
		for(var/obj/item/pinpointer/nuke/P in GLOB.pinpointer_list)
			P.switch_mode_to(TRACK_MALF_AI) //Pinpointers start tracking the AI wherever it goes

		notify_ghosts(
			"[owner_AI] has activated a Station Takeover!",
			source = owner_AI,
			header = "DOOOOOOM!!!",
			action = NOTIFY_ORBIT,
		)

		qdel(src)

/obj/machinery/doomsday_device
	name = "station takeover device"
	desc = "A weapon which hacks all machines in a large area."

/obj/machinery/doomsday_device/process()
	var/turf/T = get_turf(src)
	if(!T || !is_station_level(T.z))
		minor_announce("TAKOVER DEVICE OUT OF STATION RANGE, ABORTING", "ERROR ER0RR $R0RRO$!R41.%%!!(%$^^__+ @#F0E4", TRUE)
		owner.ShutOffDoomsdayDevice()
		return
	if(!timing)
		STOP_PROCESSING(SSfastprocess, src)
		return
	var/sec_left = seconds_remaining()
	if(!sec_left)
		timing = FALSE
		sound_to_playing_players('sound/machines/alarm.ogg')
		addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(play_cinematic), /datum/cinematic/malf, world, CALLBACK(src, PROC_REF(trigger_doomsday))), 10 SECONDS)

	else if(world.time >= next_announce)
		minor_announce("[sec_left] SECONDS UNTIL TAKEOVER DEVICE ACTIVATION!", "ERROR ER0RR $R0RRO$!R41.%%!!(%$^^__+ @#F0E4", TRUE)
		next_announce += DOOMSDAY_ANNOUNCE_INTERVAL

/obj/machinery/doomsday_device/trigger_doomsday()




/obj/machinery/doomsday_device/proc/machine_uprising()
	//Give all the vending machines an AI that kills.
	for(var/obj/machinery/vending/vendor as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/vending))
	if(!vendor.onstation)
		continue
	if(!vendor.density)
		continue
	if(chosen_vendor_type && !istype(vendor, chosen_vendor_type))
		continue
	vendor.ai_controller = new /datum/ai_controller/vending_machine(upriser)

/obj/machinery/doomsday_device/proc/no_door_access()
	//Make every door unable to be open (by cutting the idscan wire).



/obj/machinery/doomsday_device/proc/emag_everything()
	//Emags every machine that won't fuck the AI up in some way.
