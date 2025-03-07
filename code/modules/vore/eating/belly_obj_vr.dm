#define VORE_SOUND_FALLOFF 0.1
#define VORE_SOUND_RANGE 3

//
//  Belly system 2.0, now using objects instead of datums because EH at datums.
//	How many times have I rewritten bellies and vore now? -Aro
//

// If you change what variables are on this, then you need to update the copy() proc.

//
// Parent type of all the various "belly" varieties.
//
/obj/belly
	name = "belly"							// Name of this location
	desc = "It's a belly! You're in it!"	// Flavor text description of inside sight/sound/smells/feels.
	var/vore_sound = "Gulp"					// Sound when ingesting someone
	var/vore_verb = "ingest"				// Verb for eating with this in messages
	var/release_verb = "expels"				// Verb for releasing something from a stomach
	var/human_prey_swallow_time = 100		// Time in deciseconds to swallow /mob/living/carbon/human
	var/nonhuman_prey_swallow_time = 30		// Time in deciseconds to swallow anything else
	var/nutrition_percent = 100				// Nutritional percentage per tick in digestion mode
	var/digest_brute = 0.5					// Brute damage per tick in digestion mode
	var/digest_burn = 0.5					// Burn damage per tick in digestion mode
	var/digest_oxy = 0						// Oxy damage per tick in digestion mode
	var/digest_tox = 0						// Toxins damage per tick in digestion mode
	var/digest_clone = 0					// Clone damage per tick in digestion mode
	var/immutable = FALSE					// Prevents this belly from being deleted
	var/escapable = FALSE					// Belly can be resisted out of at any time
	var/escapetime = 20 SECONDS				// Deciseconds, how long to escape this belly
	var/digestchance = 0					// % Chance of stomach beginning to digest if prey struggles
	var/absorbchance = 0					// % Chance of stomach beginning to absorb if prey struggles
	var/escapechance = 0 					// % Chance of prey beginning to escape if prey struggles.
	var/escape_stun = 0						// AI controlled mobs with a number here will be weakened by the provided var when someone escapes, to prevent endless nom loops
	var/transferchance = 0 					// % Chance of prey being trasnsfered, goes from 0-100%
	var/transferchance_secondary = 0 		// % Chance of prey being transfered to transferchance_secondary, also goes 0-100%
	var/save_digest_mode = TRUE				// Whether this belly's digest mode persists across rounds
	var/can_taste = FALSE					// If this belly prints the flavor of prey when it eats someone.
	var/bulge_size = 0.25					// The minimum size the prey has to be in order to show up on examine.
	var/display_absorbed_examine = FALSE	// Do we display absorption examine messages for this belly at all?
	var/absorbed_desc						// Desc shown to absorbed prey. Defaults to regular if left empty.
	var/shrink_grow_size = 1				// This horribly named variable determines the minimum/maximum size it will shrink/grow prey to.
	var/transferlocation					// Location that the prey is released if they struggle and get dropped off.
	var/transferlocation_secondary			// Secondary location that prey is released to.
	var/release_sound = "Splatter"			// Sound for letting someone out. Replaced from True/false
	var/mode_flags = 0						// Stripping, numbing, etc.
	var/fancy_vore = FALSE					// Using the new sounds?
	var/is_wet = TRUE						// Is this belly's insides made of slimy parts?
	var/wet_loop = TRUE						// Does the belly have a fleshy loop playing?
	var/obj/item/weapon/storage/vore_egg/ownegg	// Is this belly creating an egg?
	var/egg_type = "Egg"					// Default egg type and path.
	var/egg_path = /obj/item/weapon/storage/vore_egg
	var/egg_name = null						// CHOMPAdd. Custom egg name
	var/list/list/emote_lists = list()			// Idle emotes that happen on their own, depending on the bellymode. Contains lists of strings indexed by bellymode
	var/emote_time = 60						// How long between stomach emotes at prey (in seconds)
	var/emote_active = TRUE					// Are we even giving emotes out at all or not?
	var/next_emote = 0						// When we're supposed to print our next emote, as a world.time
	var/selective_preference = DM_DIGEST	// Which type of selective bellymode do we default to?
	var/eating_privacy_local = "default"	//Overrides eating_privacy_global if not "default". Determines if attempt/success messages are subtle/loud
	var/is_feedable = TRUE					// If this belly shows up in belly selections for others. //CHOMPAdd
	var/silicon_belly_overlay_preference = "Sleeper" //Selects between placing belly overlay in sleeper or normal vore mode. Exclusive
	var/belly_mob_mult = 1		//Multiplier for how filling mob types are in borg bellies
	var/belly_item_mult = 1 	//Multiplier for how filling items are in borg borg bellies. Items are also weighted on item size
	var/belly_overall_mult = 1	//Multiplier applied ontop of any other specific multipliers

	// Generally just used by AI
	var/autotransferchance = 0 				// % Chance of prey being autotransferred to transfer location
	var/autotransferwait = 10 				// Time between trying to transfer.
	var/autotransferlocation				// Place to send them
	var/autotransfer_whitelist = 0			// Flags for what can be transferred to the primary location //CHOMPAdd
	var/autotransfer_blacklist = 2			// Flags for what can not be transferred to the primary location, defaults to Absorbed //CHOMPAdd
	var/autotransfer_whitelist_items = 0	// Flags for what can be transferred to the primary location //CHOMPAdd
	var/autotransfer_blacklist_items = 0	// Flags for what can not be transferred to the primary location //CHOMPAdd
	var/autotransferchance_secondary = 0 	// % Chance of prey being autotransferred to secondary transfer location //CHOMPAdd
	var/autotransferlocation_secondary		// Second place to send them //CHOMPAdd
	var/autotransfer_secondary_whitelist = 0// Flags for what can be transferred to the secondary location //CHOMPAdd
	var/autotransfer_secondary_blacklist = 2// Flags for what can not be transferred to the secondary location, defaults to Absorbed //CHOMPAdd
	var/autotransfer_secondary_whitelist_items = 0// Flags for what can be transferred to the secondary location //CHOMPAdd
	var/autotransfer_secondary_blacklist_items = 0// Flags for what can not be transferred to the secondary location //CHOMPAdd
	var/autotransfer_enabled = FALSE		// Player toggle
	var/autotransfer_min_amount = 0			// Minimum amount of things to pass at once. //CHOMPAdd
	var/autotransfer_max_amount = 0			// Maximum amount of things to pass at once. //CHOMPAdd
	var/tmp/list/autotransfer_queue = list()// Reserve for above things. //CHOMPAdd
	//Auto-transfer flags for whitelist //CHOMPAdd
	var/tmp/static/list/autotransfer_flags_list = list("Creatures" = AT_FLAG_CREATURES, "Absorbed" = AT_FLAG_ABSORBED, "Carbon" = AT_FLAG_CARBON, "Silicon" = AT_FLAG_SILICON, "Mobs" = AT_FLAG_MOBS, "Animals" = AT_FLAG_ANIMALS, "Mice" = AT_FLAG_MICE, "Dead" = AT_FLAG_DEAD, "Digestable Creatures" = AT_FLAG_CANDIGEST, "Absorbable Creatures" = AT_FLAG_CANABSORB, "Full Health" = AT_FLAG_HEALTHY)
	var/tmp/static/list/autotransfer_flags_list_items = list("Items" = AT_FLAG_ITEMS, "Trash" = AT_FLAG_TRASH, "Eggs" = AT_FLAG_EGGS, "Remains" = AT_FLAG_REMAINS, "Indigestible Items" = AT_FLAG_INDIGESTIBLE, "Recyclable Items" = AT_FLAG_RECYCLABLE, "Ores" = AT_FLAG_ORES, "Clothes and Bags" = AT_FLAG_CLOTHES, "Food" = AT_FLAG_FOOD)

	//I don't think we've ever altered these lists. making them static until someone actually overrides them somewhere.
	//Actual full digest modes
	var/tmp/static/list/digest_modes = list(DM_HOLD,DM_DIGEST,DM_ABSORB,DM_DRAIN,DM_SELECT,DM_UNABSORB,DM_HEAL,DM_SHRINK,DM_GROW,DM_SIZE_STEAL,DM_EGG)
	//Digest mode addon flags
	var/tmp/static/list/mode_flag_list = list("Numbing" = DM_FLAG_NUMBING, "Stripping" = DM_FLAG_STRIPPING, "Leave Remains" = DM_FLAG_LEAVEREMAINS, "Muffles" = DM_FLAG_THICKBELLY, "Affect Worn Items" = DM_FLAG_AFFECTWORN, "Jams Sensors" = DM_FLAG_JAMSENSORS, "Complete Absorb" = DM_FLAG_FORCEPSAY, "Slow Body Digestion" = DM_FLAG_SLOWBODY, "Muffle Items" = DM_FLAG_MUFFLEITEMS, "TURBO MODE" = DM_FLAG_TURBOMODE) //CHOMPEdit
	//Item related modes
	var/tmp/static/list/item_digest_modes = list(IM_HOLD,IM_DIGEST_FOOD,IM_DIGEST,IM_DIGEST_PARALLEL)

	//List of slots that stripping handles strips
	var/tmp/static/list/slots = list(slot_back,slot_handcuffed,slot_l_store,slot_r_store,slot_wear_mask,slot_l_hand,slot_r_hand,slot_wear_id,slot_glasses,slot_gloves,slot_head,slot_shoes,slot_belt,slot_wear_suit,slot_w_uniform,slot_s_store,slot_l_ear,slot_r_ear)

	var/tmp/mob/living/owner					// The mob whose belly this is.
	var/tmp/digest_mode = DM_HOLD				// Current mode the belly is set to from digest_modes (+transform_modes if human)
	var/tmp/list/items_preserved = list()		// Stuff that wont digest so we shouldn't process it again.
	var/tmp/recent_sound = FALSE				// Prevent audio spam

	// Don't forget to watch your commas at the end of each line if you change these.
	var/list/struggle_messages_outside = list(
		"%pred's %belly wobbles with a squirming meal.",
		"%pred's %belly jostles with movement.",
		"%pred's %belly briefly swells outward as someone pushes from inside.",
		"%pred's %belly fidgets with a trapped victim.",
		"%pred's %belly jiggles with motion from inside.",
		"%pred's %belly sloshes around.",
		"%pred's %belly gushes softly.",
		"%pred's %belly lets out a wet squelch.")

	var/list/struggle_messages_inside = list(
		"Your useless squirming only causes %pred's slimy %belly to squelch over your body.",
		"Your struggles only cause %pred's %belly to gush softly around you.",
		"Your movement only causes %pred's %belly to slosh around you.",
		"Your motion causes %pred's %belly to jiggle.",
		"You fidget around inside of %pred's %belly.",
		"You shove against the walls of %pred's %belly, making it briefly swell outward.",
		"You jostle %pred's %belly with movement.",
		"You squirm inside of %pred's %belly, making it wobble around.")

	var/list/absorbed_struggle_messages_outside = list(
		"%pred's %belly wobbles, seemingly on its own.",
		"%pred's %belly jiggles without apparent cause.",
		"%pred's %belly seems to shake for a second without an obvious reason.")

	var/list/absorbed_struggle_messages_inside = list(
		"You try and resist %pred's %belly, but only cause it to jiggle slightly.",
		"Your fruitless mental struggles only shift %pred's %belly a tiny bit.",
		"You can't make any progress freeing yourself from %pred's %belly.")

	var/list/digest_messages_owner = list(
		"You feel %prey's body succumb to your digestive system, which breaks it apart into soft slurry.",
		"You hear a lewd glorp as your %belly muscles grind %prey into a warm pulp.",
		"Your %belly lets out a rumble as it melts %prey into sludge.",
		"You feel a soft gurgle as %prey's body loses form in your %belly. They're nothing but a soft mass of churning slop now.",
		"Your %belly begins gushing %prey's remains through your system, adding some extra weight to your thighs.",
		"Your %belly begins gushing %prey's remains through your system, adding some extra weight to your rump.",
		"Your %belly begins gushing %prey's remains through your system, adding some extra weight to your belly.",
		"Your %belly groans as %prey falls apart into a thick soup. You can feel their remains soon flowing deeper into your body to be absorbed.",
		"Your %belly kneads on every fiber of %prey, softening them down into mush to fuel your next hunt.",
		"Your %belly churns %prey down into a hot slush. You can feel the nutrients coursing through your digestive track with a series of long, wet glorps.")

	var/list/digest_messages_prey = list(
		"Your body succumbs to %pred's digestive system, which breaks you apart into soft slurry.",
		"%pred's %belly lets out a lewd glorp as their muscles grind you into a warm pulp.",
		"%pred's %belly lets out a rumble as it melts you into sludge.",
		"%pred feels a soft gurgle as your body loses form in their %belly. You're nothing but a soft mass of churning slop now.",
		"%pred's %belly begins gushing your remains through their system, adding some extra weight to %pred's thighs.",
		"%pred's %belly begins gushing your remains through their system, adding some extra weight to %pred's rump.",
		"%pred's %belly begins gushing your remains through their system, adding some extra weight to %pred's belly.",
		"%pred's %belly groans as you fall apart into a thick soup. Your remains soon flow deeper into %pred's body to be absorbed.",
		"%pred's %belly kneads on every fiber of your body, softening you down into mush to fuel their next hunt.",
		"%pred's %belly churns you down into a hot slush. Your nutrient-rich remains course through their digestive track with a series of long, wet glorps.")

	var/list/absorb_messages_owner = list(
		"You feel %prey becoming part of you.")

	var/list/absorb_messages_prey = list(
		"You feel yourself becoming part of %pred's %belly!")

	var/list/unabsorb_messages_owner = list(
		"You feel %prey reform into a recognizable state again.")

	var/list/unabsorb_messages_prey = list(
		"You are released from being part of %pred's %belly.")

	var/list/examine_messages = list(
		"They have something solid in their %belly!",
		"It looks like they have something in their %belly!")

	var/list/examine_messages_absorbed = list(
		"Their body looks somewhat larger than usual around the area of their %belly.",
		"Their %belly looks larger than usual.")

	var/item_digest_mode = IM_DIGEST_FOOD	// Current item-related mode from item_digest_modes
	var/contaminates = TRUE					// Whether the belly will contaminate stuff // CHOMPedit: reset to true like it always was
	var/contamination_flavor = "Generic"	// Determines descriptions of contaminated items
	var/contamination_color = "green"		// Color of contamination overlay

	// Lets you do a fullscreen overlay. Set to an icon_state string.
	var/belly_fullscreen = ""
	var/disable_hud = FALSE
	var/colorization_enabled = TRUE //CHOMPedit
	var/belly_fullscreen_color = "#823232"
	//var/belly_fullscreen_color_secondary = "#428242" //Chomp Disable, using our implementation
	//var/belly_fullscreen_color_trinary = "#f0f0f0" //Chomp Disable, using our implementation
	var/belly_fullscreen_color2 = "#FFFFFF" //ChompEDIT
	var/belly_fullscreen_color3 = "#823232" //ChompEDIT
	var/belly_fullscreen_color4 = "#FFFFFF" //ChompEDIT
	var/belly_fullscreen_alpha = 255 //ChompEDIT


//For serialization, keep this updated, required for bellies to save correctly.
/obj/belly/vars_to_save()
	var/list/saving = list(
	"name",
	"desc",
	"absorbed_desc",
	"vore_sound",
	"vore_verb",
	"release_verb",
	"human_prey_swallow_time",
	"nonhuman_prey_swallow_time",
	"emote_time",
	"nutrition_percent",
	"digest_brute",
	"digest_burn",
	"digest_oxy",
	"digest_tox",
	"digest_clone",
	"immutable",
	"can_taste",
	"escapable",
	"escapetime",
	"digestchance",
	"absorbchance",
	"escapechance",
	"transferchance",
	"transferchance_secondary",
	"transferlocation",
	"transferlocation_secondary",
	"bulge_size",
	"display_absorbed_examine",
	"shrink_grow_size",
	"struggle_messages_outside",
	"struggle_messages_inside",
	"absorbed_struggle_messages_outside",
	"absorbed_struggle_messages_inside",
	"digest_messages_owner",
	"digest_messages_prey",
	"absorb_messages_owner",
	"absorb_messages_prey",
	"unabsorb_messages_owner",
	"unabsorb_messages_prey",
	"examine_messages",
	"examine_messages_absorbed",
	"emote_lists",
	"emote_time",
	"emote_active",
	"selective_preference",
	"mode_flags",
	"item_digest_mode",
	"contaminates",
	"contamination_flavor",
	"contamination_color",
	"release_sound",
	"fancy_vore",
	"is_wet",
	"wet_loop",
	"belly_fullscreen",
	"disable_hud",
	"reagent_mode_flags",	//CHOMP start of variables from CHOMP
	"belly_fullscreen_color",
	//"belly_fullscreen_color_secondary",  //Chomp Disable, using our implementation
	//"belly_fullscreen_color_trinary",  //Chomp Disable, using our implementation
	"belly_fullscreen_color2",
	"belly_fullscreen_color3",
	"belly_fullscreen_color4",
	"belly_fullscreen_alpha",
	"colorization_enabled",
	"reagentbellymode",
	"liquid_fullness1_messages",
	"liquid_fullness2_messages",
	"liquid_fullness3_messages",
	"liquid_fullness4_messages",
	"liquid_fullness5_messages",
	"reagent_name",
	"reagent_chosen",
	"reagentid",
	"reagentcolor",
	"liquid_overlay",
	"max_liquid_level",
	"reagent_touches",
	"mush_overlay",
	"mush_color",
	"mush_alpha",
	"max_mush",
	"min_mush",
	"item_mush_val",
	"custom_reagentcolor",
	"custom_reagentalpha",
	"metabolism_overlay",
	"metabolism_mush_ratio",
	"max_ingested",
	"custom_ingested_color",
	"custom_ingested_alpha",
	"gen_cost",
	"gen_amount",
	"gen_time",
	"gen_time_display",
	"reagent_transfer_verb",
	"custom_max_volume",
	"generated_reagents",
	"vorefootsteps_sounds",
	"fullness1_messages",
	"fullness2_messages",
	"fullness3_messages",
	"fullness4_messages",
	"fullness5_messages",
	"vorespawn_blacklist",
	"vore_sprite_flags",
	"affects_vore_sprites",
	"count_absorbed_prey_for_sprite",
	"absorbed_multiplier",
	"count_liquid_for_sprite",
	"liquid_multiplier",
	"count_items_for_sprite",
	"item_multiplier",
	"health_impacts_size",
	"resist_triggers_animation",
	"size_factor_for_sprite",
	"belly_sprite_to_affect",
	"undergarment_chosen",
	"undergarment_if_none",
	"undergarment_color",
	"autotransferchance",
	"autotransferwait",
	"autotransferlocation",
	"autotransfer_enabled",
	"autotransferchance_secondary",
	"autotransferlocation_secondary",
	"autotransfer_secondary_whitelist",
	"autotransfer_secondary_blacklist",
	"autotransfer_whitelist",
	"autotransfer_blacklist",
	"autotransfer_secondary_whitelist_items",
	"autotransfer_secondary_blacklist_items",
	"autotransfer_whitelist_items",
	"autotransfer_blacklist_items",
	"autotransfer_min_amount",
	"autotransfer_max_amount",
	"slow_digestion",
	"slow_brutal",
	"sound_volume",
	"speedy_mob_processing",
	"egg_name",
	"recycling",
	"is_feedable",
	"entrance_logs",
	"noise_freq",
	"item_digest_logs", //CHOMP end of variables from CHOMP
	"egg_type",
	"save_digest_mode",
	"eating_privacy_local",
	"silicon_belly_overlay_preference",
	"belly_mob_mult",
	"belly_item_mult",
	"belly_overall_mult",
	)

	if (save_digest_mode == 1)
		return ..() + saving + list("digest_mode")

	return ..() + saving

/obj/belly/Initialize()
	. = ..()
	//If not, we're probably just in a prefs list or something.
	if(ismob(loc))
		owner = loc
		owner.vore_organs |= src
		if(isliving(loc))
			if(speedy_mob_processing) //CHOMPEdit Start
				START_PROCESSING(SSobj, src)
			else
				START_PROCESSING(SSbellies, src)

	create_reagents(300)	//CHOMP So we can have some liquids in bellies
	flags |= NOREACT		// We dont want bellies to start bubling nonstop due to people mixing when transfering and making different reagents

/obj/belly/Destroy()
	if(speedy_mob_processing)
		STOP_PROCESSING(SSobj, src)
	else
		STOP_PROCESSING(SSbellies, src)
	owner?.vore_organs?.Remove(src)
	owner = null
	for(var/mob/observer/G in src)
		G.forceMove(get_turf(src)) //CHOMPEdit End
	return ..()

// Called whenever an atom enters this belly
/obj/belly/Entered(atom/movable/thing, atom/OldLoc)
	. = ..()  //CHOMPEdit Start
	if(!owner)
		thing.forceMove(get_turf(src))
		return
	thing.enter_belly(src) // Atom movable proc, does nothing by default. Overridden in children for special behavior.
	if(owner && istype(owner.loc,/turf/simulated) && !cycle_sloshed && reagents.total_volume > 0)
		var/turf/simulated/T = owner.loc
		var/S = pick(T.base_vorefootstep_sounds["human"]) //ChompEDIT
		if(S)
			playsound(T, S, sound_volume * (reagents.total_volume / 100), FALSE, frequency = noise_freq, preference = /datum/client_preference/digestion_noises) //CHOMPEdit
			cycle_sloshed = TRUE
	thing.belly_cycles = 0 //reset cycle count
	if(istype(thing, /mob/observer)) //Silence, spook.
		if(desc)
			//Allow ghosts see where they are if they're still getting squished along inside.
			var/formatted_desc
			formatted_desc = replacetext(desc, "%belly", lowertext(name)) //replace with this belly's name
			formatted_desc = replacetext(formatted_desc, "%pred", owner) //replace with this belly's owner
			formatted_desc = replacetext(formatted_desc, "%prey", thing) //replace with whatever mob entered into this belly
			to_chat(thing, "<span class='notice'><B>[formatted_desc]</B></span>")
		return
	if(OldLoc in contents)
		return //Someone dropping something (or being stripdigested)
	if(istype(OldLoc, /mob/observer) || istype(OldLoc, /obj/item/device/mmi)) // Prevent reforming causing a lot of log spam/sounds
		return //Someone getting reformed most likely (And if not, uh... shouldn't happen anyways?)
	//CHOMPEdit end

	//Generic entered message
	if(!owner.mute_entry && entrance_logs) //CHOMPEdit
		to_chat(owner,"<span class='notice'>[thing] slides into your [lowertext(name)].</span>")

	//Sound w/ antispam flag setting
	if(vore_sound && !recent_sound)
		var/soundfile
		if(!fancy_vore)
			soundfile = classic_vore_sounds[vore_sound]
		else
			soundfile = fancy_vore_sounds[vore_sound]
		if(special_entrance_sound) //CHOMPEdit: Custom sound set by mob's init_vore or ingame varedits.
			soundfile = special_entrance_sound
		if(soundfile)
			playsound(src, soundfile, vol = sound_volume, vary = 1, falloff = VORE_SOUND_FALLOFF, frequency = noise_freq, preference = /datum/client_preference/eating_noises, volume_channel = VOLUME_CHANNEL_VORE) //CHOMPEdit
			recent_sound = TRUE

	if(reagents.total_volume >= 5 && !isliving(thing) && (item_digest_mode == IM_DIGEST || item_digest_mode == IM_DIGEST_PARALLEL)) //CHOMPAdd
		reagents.trans_to(thing, reagents.total_volume * 0.1, 1 / max(LAZYLEN(contents), 1), FALSE) //CHOMPAdd
	//Messages if it's a mob
	if(isliving(thing))
		var/mob/living/M = thing
		M.updateVRPanel()
		var/raw_desc //Let's use this to avoid needing to write the reformat code twice
		if(absorbed_desc && M.absorbed)
			raw_desc = absorbed_desc
		else if(desc)
			raw_desc = desc

		//Was there a description text? If so, it's time to format it!
		if(raw_desc)
			//Replace placeholder vars
			var/formatted_desc
			formatted_desc = replacetext(raw_desc, "%belly", lowertext(name)) //replace with this belly's name
			formatted_desc = replacetext(formatted_desc, "%pred", owner) //replace with this belly's owner
			formatted_desc = replacetext(formatted_desc, "%prey", M) //replace with whatever mob entered into this belly
			to_chat(M, "<span class='notice'><B>[formatted_desc]</B></span>")

		var/taste
		if(can_taste && (taste = M.get_taste_message(FALSE)))
			to_chat(owner, "<span class='notice'>[M] tastes of [taste].</span>")
		vore_fx(M, TRUE) //CHOMPEdit: update belleh
		if(owner.previewing_belly == src) //CHOMPEdit
			vore_fx(owner, TRUE) //CHOMPEdit: update belleh
		owner.update_fullness() //CHOMPEdit - This is run whenever a belly's contents are changed.
		//Stop AI processing in bellies
		if(M.ai_holder)
			M.ai_holder.go_sleep()
		if(reagents.total_volume >= 5 && M.digestable) //CHOMPEdit Start
			if(digest_mode == DM_DIGEST)
				reagents.trans_to(M, reagents.total_volume * 0.1, 1 / max(LAZYLEN(contents), 1), FALSE)
			to_chat(M, "<span class='warning'><B>You splash into a pool of [reagent_name]!</B></span>")
	else if(count_items_for_sprite) //CHOMPEdit - If this is enabled also update fullness for non-living things
		owner.update_fullness() //CHOMPEdit - This is run whenever a belly's contents are changed.
	//if(istype(thing, /obj/item/capture_crystal)) //CHOMPEdit start: Capture crystal occupant gets to see belly text too. Moved to modular_chomp capture_crystal.dm.
		//var/obj/item/capture_crystal/CC = thing
		//if(CC.bound_mob && desc)
			//if(CC.bound_mob in CC.contents)
				//var/formatted_desc
				//formatted_desc = replacetext(desc, "%belly", lowertext(name)) //replace with this belly's name
				//formatted_desc = replacetext(formatted_desc, "%pred", owner) //replace with this belly's owner
				//formatted_desc = replacetext(formatted_desc, "%prey", thing) //replace with whatever mob entered into this belly
				//to_chat(CC.bound_mob, "<span class='notice'><B>[formatted_desc]</B></span>") //CHOMPedit end

	/*/ Intended for simple mobs //CHMOPEdit: Counting belly cycles now.
	if((!owner.client || autotransfer_enabled) && autotransferlocation && autotransferchance > 0)
		addtimer(CALLBACK(src, TYPE_PROC_REF(/obj/belly, check_autotransfer), thing, autotransferlocation), autotransferwait)
	*/

// Called whenever an atom leaves this belly
/obj/belly/Exited(atom/movable/thing, atom/OldLoc)
	. = ..()
	thing.exit_belly(src) // CHOMPEdit - atom movable proc, does nothing by default. Overridden in children for special behavior.
	if(isbelly(thing.loc)) //CHOMPEdit Start
		var/obj/belly/NB = thing.loc
		if(count_items_for_sprite && !NB.count_items_for_sprite)
			owner.update_fullness()
		return //CHOMPEdit End
	if(isliving(thing) && !isbelly(thing.loc))
		owner.update_fullness() //CHOMPEdit - This is run whenever a belly's contents are changed.
		var/mob/living/L = thing
		L.clear_fullscreen("belly")
		//L.clear_fullscreen("belly2") // CHOMP Disable - using our implementation, not upstream's
		//L.clear_fullscreen("belly3") // CHOMP Disable - using our implementation, not upstream's
		//L.clear_fullscreen("belly4") // CHOMP Disable - using our implementation, not upstream's
		if(L.hud_used)
			if(!L.hud_used.hud_shown)
				L.toggle_hud_vis()
		if((L.stat != DEAD) && L.ai_holder)
			L.ai_holder.go_wake()
	if(isitem(thing) && !isbelly(thing.loc)) //CHOMPEdit: Digest stage effects. Don't bother adding overlays to stuff that won't make it back out.
		if(count_items_for_sprite) //CHOMPEdit - If this is enabled also update fullness for non-living things
			owner.update_fullness() //CHOMPEdit - This is run whenever a belly's contents are changed.
		var/obj/item/I = thing
		if(I.gurgled)
			I.cut_overlay(gurgled_overlays[I.gurgled_color]) //No double-overlay for worn items.
			I.add_overlay(gurgled_overlays[I.gurgled_color])
		if(I.d_mult < 1)
			if(I.d_stage_overlay)
				I.cut_overlay(I.d_stage_overlay)
			var/image/temp = new /image(gurgled_overlays[I.gurgled_color ? I.gurgled_color : "green"])
			temp.filters += filter(type = "alpha", icon = icon(I.icon, I.icon_state))
			I.d_stage_overlay = temp
			for(var/count in I.d_mult to 1 step 0.25)
				I.add_overlay(I.d_stage_overlay, TRUE) //CHOMPEdit end

// CHOMPedit: SEND_SIGNAL(COMSIG_BELLY_UPDATE_VORE_FX) is sometimes used when calling vore_fx() to send belly visuals
// to certain non-belly atoms. Not called here as vore_fx() is usually only called if a mob is in the belly.
// Don't forget it if you need to rework vore_fx().
/obj/belly/proc/vore_fx(mob/living/L, var/update, var/severity = 0) //CHOMPEdit
	if(!istype(L))
		return
	if(!L.client)
		return
	if(L.previewing_belly && L.previewing_belly != src) //CHOMPEdit Start
		return
	if(L.previewing_belly == src && L.vore_selected != src)
		L.previewing_belly = null
		return
	if(!L.show_vore_fx)
		L.clear_fullscreen("belly")
		L.previewing_belly = null //CHOMPEdit End
		return
	if(update)
		L.clear_fullscreen("belly")
	if(belly_fullscreen)
		if(colorization_enabled)
			/* //Chomp Disable - disable upstream's solution, use ours
			var/obj/screen/fullscreen/F = L.overlay_fullscreen("belly", /obj/screen/fullscreen/belly/colorized)
			F.icon_state = belly_fullscreen
			F.color = belly_fullscreen_color
			if("[belly_fullscreen]_l1" in icon_states('icons/mob/screen_full_colorized_vore_overlays.dmi'))
				var/obj/screen/fullscreen/F2 = L.overlay_fullscreen("belly2", /obj/screen/fullscreen/belly/colorized/overlay)
				F2.icon_state = "[belly_fullscreen]_l1"
				F2.color = belly_fullscreen_color_secondary
			else
				L.clear_fullscreen("belly2")
			if("[belly_fullscreen]_l2" in icon_states('icons/mob/screen_full_colorized_vore_overlays.dmi'))
				var/obj/screen/fullscreen/F3 = L.overlay_fullscreen("belly3", /obj/screen/fullscreen/belly/colorized/overlay)
				F3.icon_state = "[belly_fullscreen]_l2"
				F3.color = belly_fullscreen_color_trinary
			else
				L.clear_fullscreen("belly3")
			if("[belly_fullscreen]_nc" in icon_states('icons/mob/screen_full_colorized_vore_overlays.dmi'))
				var/obj/screen/fullscreen/F4 = L.overlay_fullscreen("belly4", /obj/screen/fullscreen/belly/colorized/overlay)
				F4.icon_state = "[belly_fullscreen]_nc"
			else
				L.clear_fullscreen("belly4")
			*/ //Chomp Disable END

			// Chomp EDIT Begin
			var/obj/screen/fullscreen/F = L.overlay_fullscreen("belly", /obj/screen/fullscreen/belly, severity) //CHOMPEdit Start: preserving save data
			F.icon = file("modular_chomp/icons/mob/vore_fullscreens/[belly_fullscreen].dmi")
			F.cut_overlays()
			var/image/I = image(F.icon, belly_fullscreen) //Would be cool if I could just include color and alpha in the image define so we don't have to copy paste
			I.color = belly_fullscreen_color
			I.alpha = belly_fullscreen_alpha
			F.add_overlay(I)
			I = image(F.icon, belly_fullscreen+"-2")
			I.color = belly_fullscreen_color2
			I.alpha = belly_fullscreen_alpha
			F.add_overlay(I)
			I = image(F.icon, belly_fullscreen+"-3")
			I.color = belly_fullscreen_color3
			I.alpha = belly_fullscreen_alpha
			F.add_overlay(I)
			I = image(F.icon, belly_fullscreen+"-4")
			I.color = belly_fullscreen_color4
			I.alpha = belly_fullscreen_alpha
			F.add_overlay(I)
			var/extra_mush = 0
			var/extra_mush_color = mush_color
			if(L.liquidbelly_visuals && ishuman(owner) && metabolism_overlay && metabolism_mush_ratio > 0)
				var/mob/living/carbon/human/H = owner
				var/datum/reagents/metabolism/ingested = H.ingested
				if(ingested && ingested.total_volume > 0)
					if(custom_ingested_color)
						extra_mush_color = custom_ingested_color
					else
						extra_mush_color = ingested.get_color()
					extra_mush = ingested.total_volume * metabolism_mush_ratio
				if(!mush_overlay)
					I = image('modular_chomp/icons/mob/vore_fullscreens/bubbles.dmi', "mush")
					I.color = extra_mush_color
					I.alpha = custom_ingested_alpha
					I.pixel_y = -450 + ((450 / max(max_ingested, 1)) * min(max_ingested, ingested.total_volume))
					F.add_overlay(I)
			if(L.liquidbelly_visuals && mush_overlay && (owner.nutrition > 0 || max_mush == 0 || min_mush > 0 || (LAZYLEN(contents) * item_mush_val) > 0))
				I = image('modular_chomp/icons/mob/vore_fullscreens/bubbles.dmi', "mush")
				I.color = mush_color
				I.alpha = mush_alpha
				var/total_mush_content = owner.nutrition + LAZYLEN(contents) * item_mush_val + extra_mush
				I.pixel_y = -450 + (450 / max(max_mush, 1) * max(min(max_mush, total_mush_content), 1))
				if(I.pixel_y < -450 + (450 / 100 * min_mush))
					I.pixel_y = -450 + (450 / 100 * min_mush)
				var/stored_y = I.pixel_y
				F.add_overlay(I)
				if(metabolism_overlay && metabolism_mush_ratio > 0 && extra_mush > 0)
					I = image('modular_chomp/icons/mob/vore_fullscreens/bubbles.dmi', "mush")
					I.color = extra_mush_color
					I.alpha = min(mush_alpha, (extra_mush / max(total_mush_content, 1)) * mush_alpha)
					I.pixel_y = stored_y
					F.add_overlay(I)
			if(L.liquidbelly_visuals && liquid_overlay && reagents.total_volume)
				if(digest_mode == DM_HOLD && item_digest_mode == IM_HOLD)
					I = image('modular_chomp/icons/mob/vore_fullscreens/bubbles.dmi', "calm")
				else
					I = image('modular_chomp/icons/mob/vore_fullscreens/bubbles.dmi', "bubbles")
				if(custom_reagentcolor)
					I.color = custom_reagentcolor
				else
					I.color = reagentcolor
				if(custom_reagentalpha)
					I.alpha = custom_reagentalpha
				else
					I.alpha = max(150, min(custom_max_volume, 255)) - (255 - belly_fullscreen_alpha)
				I.pixel_y = -450 + min((450 / custom_max_volume * reagents.total_volume), 450 / 100 * max_liquid_level)
				F.add_overlay(I)
			F.update_for_view(L.client.view)
		else
			var/obj/screen/fullscreen/F = L.overlay_fullscreen("belly", /obj/screen/fullscreen/belly/fixed, severity) //preserving save data
			F.icon = file("modular_chomp/icons/mob/vore_fullscreens/[belly_fullscreen].dmi")
			F.cut_overlays()
			F.add_overlay(image(F.icon, belly_fullscreen))
			F.add_overlay(image(F.icon, belly_fullscreen+"-2"))
			F.add_overlay(image(F.icon, belly_fullscreen+"-3"))
			F.add_overlay(image(F.icon, belly_fullscreen+"-4"))
			var/image/I
			var/extra_mush = 0
			var/extra_mush_color = mush_color
			if(L.liquidbelly_visuals && ishuman(owner) && metabolism_overlay && metabolism_mush_ratio > 0)
				var/mob/living/carbon/human/H = owner
				var/datum/reagents/metabolism/ingested = H.ingested
				if(ingested && ingested.total_volume > 0)
					if(custom_ingested_color)
						extra_mush_color = custom_ingested_color
					else
						extra_mush_color = ingested.get_color()
					extra_mush = ingested.total_volume * metabolism_mush_ratio
				if(!mush_overlay)
					I = image('modular_chomp/icons/mob/vore_fullscreens/bubbles.dmi', "mush")
					I.color = extra_mush_color
					I.alpha = custom_ingested_alpha
					I.pixel_y = -450 + (450 / max(max_ingested, 1) * max(min(max_ingested, ingested.total_volume), 1))
					F.add_overlay(I)
			if(L.liquidbelly_visuals && mush_overlay && (owner.nutrition > 0 || max_mush == 0 || min_mush > 0 || (LAZYLEN(contents) * item_mush_val) > 0))
				I = image('modular_chomp/icons/mob/vore_fullscreens/bubbles.dmi', "mush")
				I.color = mush_color
				I.alpha = mush_alpha
				var/total_mush_content = owner.nutrition + LAZYLEN(contents) * item_mush_val + extra_mush
				I.pixel_y = -450 + (450 / max(max_mush, 1) * max(min(max_mush, total_mush_content), 1))
				if(I.pixel_y < -450 + (450 / 100 * min_mush))
					I.pixel_y = -450 + (450 / 100 * min_mush)
				var/stored_y = I.pixel_y
				F.add_overlay(I)
				if(metabolism_overlay && metabolism_mush_ratio > 0 && extra_mush > 0)
					I = image('modular_chomp/icons/mob/vore_fullscreens/bubbles.dmi', "mush")
					I.color = extra_mush_color
					I.alpha = min(mush_alpha, (extra_mush / max(total_mush_content, 1)) * mush_alpha)
					I.pixel_y = stored_y
					F.add_overlay(I)
			if(L.liquidbelly_visuals && liquid_overlay && reagents.total_volume)
				if(digest_mode == DM_HOLD && item_digest_mode == IM_HOLD)
					I = image('modular_chomp/icons/mob/vore_fullscreens/bubbles.dmi', "calm")
				else
					I = image('modular_chomp/icons/mob/vore_fullscreens/bubbles.dmi', "bubbles")
				if(custom_reagentcolor)
					I.color = custom_reagentcolor
				else
					I.color = reagentcolor
				if(custom_reagentalpha)
					I.alpha = custom_reagentalpha
				else
					I.alpha = max(150, min(custom_max_volume, 255)) - (255 - belly_fullscreen_alpha)
				I.pixel_y = -450 + min((450 / custom_max_volume * reagents.total_volume), 450 / 100 * max_liquid_level)
				F.add_overlay(I)
			F.update_for_view(L.client.view)
			 //CHOMPEdit End
	else
		L.clear_fullscreen("belly")
		//L.clear_fullscreen("belly2") //Chomp Disable - disable upstream's solution, use ours
		//L.clear_fullscreen("belly3") //Chomp Disable - disable upstream's solution, use ours
		//L.clear_fullscreen("belly4") //Chomp Disable - disable upstream's solution, use ours

	if(disable_hud && L != owner)
		if(L?.hud_used?.hud_shown)
			to_chat(L, "<span class='notice'>((Your pred has disabled huds in their belly. Turn off vore FX and hit F12 to get it back; or relax, and enjoy the serenity.))</span>")
			L.toggle_hud_vis(TRUE)

/obj/belly/proc/vore_preview(mob/living/L)
	if(!istype(L) || !L.client) //CHOMPEdit Start
		L.previewing_belly = null
		return
	L.previewing_belly = src
	vore_fx(L)
	//CHOMPEdit End

/* //CHOMPRemove. Using regular vore_fx above.
	if(belly_fullscreen)
		if(colorization_enabled)
			/* //Chomp Disable - disable upstream's solution, use ours
			var/obj/screen/fullscreen/F = L.overlay_fullscreen("belly", /obj/screen/fullscreen/belly/colorized)
			F.icon_state = belly_fullscreen
			F.color = belly_fullscreen_color
			if("[belly_fullscreen]_l1" in icon_states('icons/mob/screen_full_colorized_vore_overlays.dmi'))
				var/obj/screen/fullscreen/F2 = L.overlay_fullscreen("belly2", /obj/screen/fullscreen/belly/colorized/overlay)
				F2.icon_state = "[belly_fullscreen]_l1"
				F2.color = belly_fullscreen_color_secondary
			if("[belly_fullscreen]_l2" in icon_states('icons/mob/screen_full_colorized_vore_overlays.dmi'))
				var/obj/screen/fullscreen/F3 = L.overlay_fullscreen("belly3", /obj/screen/fullscreen/belly/colorized/overlay)
				F3.icon_state = "[belly_fullscreen]_l2"
				F3.color = belly_fullscreen_color_trinary
			if("[belly_fullscreen]_nc" in icon_states('icons/mob/screen_full_colorized_vore_overlays.dmi'))
				var/obj/screen/fullscreen/F4 = L.overlay_fullscreen("belly4", /obj/screen/fullscreen/belly/colorized/overlay)
				F4.icon_state = "[belly_fullscreen]_nc"
			*/ //Chomp Disable END
			//CHOMPedit Start: preserving save data
			var/obj/screen/fullscreen/F = L.overlay_fullscreen("belly", /obj/screen/fullscreen/belly, reagents.total_volume)
			F.icon = file("modular_chomp/icons/mob/vore_fullscreens/[belly_fullscreen].dmi")
			F.cut_overlays()
			var/image/I = image(F.icon, belly_fullscreen)
			I.color = belly_fullscreen_color
			I.alpha = belly_fullscreen_alpha
			F.add_overlay(I)
			I = image(F.icon, belly_fullscreen+"-2")
			I.color = belly_fullscreen_color2
			I.alpha = belly_fullscreen_alpha
			F.add_overlay(I)
			I = image(F.icon, belly_fullscreen+"-3")
			I.color = belly_fullscreen_color3
			I.alpha = belly_fullscreen_alpha
			F.add_overlay(I)
			I = image(F.icon, belly_fullscreen+"-4")
			I.color = belly_fullscreen_color4
			I.alpha = belly_fullscreen_alpha
			F.add_overlay(I)
			var/extra_mush = 0
			var/extra_mush_color = mush_color
			if(L.liquidbelly_visuals && ishuman(owner) && metabolism_overlay && metabolism_mush_ratio > 0)
				var/mob/living/carbon/human/H = owner
				var/datum/reagents/metabolism/ingested = H.ingested
				if(ingested && ingested.total_volume > 0)
					if(custom_ingested_color)
						extra_mush_color = custom_ingested_color
					else
						extra_mush_color = ingested.get_color()
					extra_mush = ingested.total_volume * metabolism_mush_ratio
				if(!mush_overlay)
					I = image('modular_chomp/icons/mob/vore_fullscreens/bubbles.dmi', "mush")
					I.color = extra_mush_color
					I.alpha = custom_ingested_alpha
					I.pixel_y = -450 + (450 / max(max_ingested, 1) * max(min(max_ingested, ingested.total_volume), 1))
					F.add_overlay(I)
			if(L.liquidbelly_visuals && mush_overlay && (owner.nutrition > 0 || max_mush == 0 || min_mush > 0 || (LAZYLEN(contents) * item_mush_val) > 0))
				I = image('modular_chomp/icons/mob/vore_fullscreens/bubbles.dmi', "mush")
				I.color = mush_color
				I.alpha = mush_alpha
				var/total_mush_content = owner.nutrition + LAZYLEN(contents) * item_mush_val + extra_mush
				I.pixel_y = -450 + (450 / max(max_mush, 1) * max(min(max_mush, total_mush_content), 1))
				if(I.pixel_y < -450 + (450 / 100 * min_mush))
					I.pixel_y = -450 + (450 / 100 * min_mush)
				var/stored_y = I.pixel_y
				F.add_overlay(I)
				if(metabolism_overlay && metabolism_mush_ratio > 0 && extra_mush > 0)
					I = image('modular_chomp/icons/mob/vore_fullscreens/bubbles.dmi', "mush")
					I.color = extra_mush_color
					I.alpha = min(mush_alpha, (extra_mush / max(total_mush_content, 1)) * mush_alpha)
					I.pixel_y = stored_y
					F.add_overlay(I)
			if(L.liquidbelly_visuals && liquid_overlay && reagents.total_volume)
				if(digest_mode == DM_HOLD && item_digest_mode == IM_HOLD)
					I = image('modular_chomp/icons/mob/vore_fullscreens/bubbles.dmi', "mush")
				else
					I = image('modular_chomp/icons/mob/vore_fullscreens/bubbles.dmi', "bubbles")
				if(custom_reagentcolor)
					I.color = custom_reagentcolor
				else
					I.color = reagentcolor
				if(custom_reagentalpha)
					I.alpha = custom_reagentalpha
				else
					I.alpha = max(150, min(custom_max_volume, 255)) - (255 - belly_fullscreen_alpha)
				I.pixel_y = -450 + min((450 / custom_max_volume * reagents.total_volume), 450 / 100 * max_liquid_level)
				F.add_overlay(I)
			F.update_for_view(L.client.view)
		else
			var/obj/screen/fullscreen/F = L.overlay_fullscreen("belly", /obj/screen/fullscreen/belly/fixed, reagents.total_volume) //preserving save data
			F.cut_overlays()
			F.add_overlay(image(F.icon, belly_fullscreen))
			F.add_overlay(image(F.icon, belly_fullscreen+"-2"))
			F.add_overlay(image(F.icon, belly_fullscreen+"-3"))
			F.add_overlay(image(F.icon, belly_fullscreen+"-4"))
			var/image/I
			var/extra_mush = 0
			var/extra_mush_color = mush_color
			if(L.liquidbelly_visuals && ishuman(owner) && metabolism_overlay && metabolism_mush_ratio > 0)
				var/mob/living/carbon/human/H = owner
				var/datum/reagents/metabolism/ingested = H.ingested
				if(ingested && ingested.total_volume > 0)
					if(custom_ingested_color)
						extra_mush_color = custom_ingested_color
					else
						extra_mush_color = ingested.get_color()
					extra_mush = ingested.total_volume * metabolism_mush_ratio
				if(!mush_overlay)
					I = image('modular_chomp/icons/mob/vore_fullscreens/bubbles.dmi', "mush")
					I.color = extra_mush_color
					I.alpha = custom_ingested_alpha
					I.pixel_y = -450 + (450 / max(max_ingested, 1) * max(min(max_ingested, ingested.total_volume), 1))
					F.add_overlay(I)
			if(L.liquidbelly_visuals && mush_overlay && (owner.nutrition > 0 || max_mush == 0 || min_mush > 0 || (LAZYLEN(contents) * item_mush_val) > 0))
				I = image('modular_chomp/icons/mob/vore_fullscreens/bubbles.dmi', "mush")
				I.color = mush_color
				I.alpha = mush_alpha
				var/total_mush_content = owner.nutrition + LAZYLEN(contents) * item_mush_val + extra_mush
				I.pixel_y = -450 + (450 / max(max_mush, 1) * max(min(max_mush, total_mush_content), 1))
				if(I.pixel_y < -450 + (450 / 100 * min_mush))
					I.pixel_y = -450 + (450 / 100 * min_mush)
				var/stored_y = I.pixel_y
				F.add_overlay(I)
				if(metabolism_overlay && metabolism_mush_ratio > 0 && extra_mush > 0)
					I = image('modular_chomp/icons/mob/vore_fullscreens/bubbles.dmi', "mush")
					I.color = extra_mush_color
					I.alpha = min(mush_alpha, (extra_mush / max(total_mush_content, 1)) * mush_alpha)
					I.pixel_y = stored_y
					F.add_overlay(I)
			if(L.liquidbelly_visuals && liquid_overlay && reagents.total_volume)
				if(digest_mode == DM_HOLD && item_digest_mode == IM_HOLD)
					I = image('modular_chomp/icons/mob/vore_fullscreens/bubbles.dmi', "calm")
				else
					I = image('modular_chomp/icons/mob/vore_fullscreens/bubbles.dmi', "bubbles")
				if(custom_reagentcolor)
					I.color = custom_reagentcolor
				else
					I.color = reagentcolor
				if(custom_reagentalpha)
					I.alpha = custom_reagentalpha
				else
					I.alpha = max(150, min(custom_max_volume, 255)) - (255 - belly_fullscreen_alpha)
				I.pixel_y = -450 + min((450 / custom_max_volume * reagents.total_volume), 450 / 100 * max_liquid_level)
				F.add_overlay(I)
			F.update_for_view(L.client.view)
			//CHOMPEdit End
	else
		L.clear_fullscreen("belly")
		//L.clear_fullscreen("belly2") //Chomp Disable - disable upstream's solution, use ours
		//L.clear_fullscreen("belly3") //Chomp Disable - disable upstream's solution, use ours
		//L.clear_fullscreen("belly4") //Chomp Disable - disable upstream's solution, use ours
*/

/obj/belly/proc/clear_preview(mob/living/L)
	L.previewing_belly = null //CHOMPAdd
	L.clear_fullscreen("belly")
	//L.clear_fullscreen("belly2") //Chomp Disable - disable upstream's solution, use ours
	//L.clear_fullscreen("belly3") //Chomp Disable - disable upstream's solution, use ours
	//L.clear_fullscreen("belly4") //Chomp Disable - disable upstream's solution, use ours



// Release all contents of this belly into the owning mob's location.
// If that location is another mob, contents are transferred into whichever of its bellies the owning mob is in.
// Returns the number of mobs so released.
/obj/belly/proc/release_all_contents(include_absorbed = FALSE, silent = FALSE)
	//Don't bother if we don't have contents
	if(!contents.len)
		return FALSE

	//Find where we should drop things into (certainly not the owner)
	var/count = 0

	//Iterate over contents and move them all
	for(var/atom/movable/AM as anything in contents)
		if(isliving(AM))
			var/mob/living/L = AM
			if(L.absorbed && !include_absorbed)
				continue
		count += release_specific_contents(AM, silent = TRUE)

	//Clean up our own business
	items_preserved.Cut()
	if(!ishuman(owner))
		owner.update_icons()

	//Determines privacy
	var/privacy_range = world.view
	//var/privacy_volume = 100
	switch(eating_privacy_local) //Third case of if("loud") not defined, as it'd just leave privacy_range and volume untouched
		if("default")
			if(owner.eating_privacy_global)
				privacy_range = 1
				//privacy_volume = 25
		if("subtle")
			privacy_range = 1
			//privacy_volume = 25

	//Print notifications/sound if necessary
	if(!silent && count)
		owner.visible_message("<font color='green'><b>[owner] [release_verb] everything from their [lowertext(name)]!</b></font>", range = privacy_range)
		var/soundfile
		if(!fancy_vore)
			soundfile = classic_release_sounds[release_sound]
		else
			soundfile = fancy_release_sounds[release_sound]
		if(soundfile)
			playsound(src, soundfile, vol = sound_volume, vary = 1, falloff = VORE_SOUND_FALLOFF, frequency = noise_freq, preference = /datum/client_preference/eating_noises, volume_channel = VOLUME_CHANNEL_VORE) //CHOMPEdit

	return count

// Release a specific atom from the contents of this belly into the owning mob's location.
// If that location is another mob, the atom is transferred into whichever of its bellies the owning mob is in.
// Returns the number of atoms so released.
/obj/belly/proc/release_specific_contents(atom/movable/M, silent = FALSE)
	if (!(M in contents))
		return 0 // They weren't in this belly anyway

	if(istype(M, /mob/living/simple_mob/vore/morph/dominated_prey))
		var/mob/living/simple_mob/vore/morph/dominated_prey/p = M
		p.undo_prey_takeover(FALSE)
		return 0
	for(var/mob/living/L in M.contents)
		L.muffled = FALSE
		L.forced_psay = FALSE

	for(var/obj/item/weapon/holder/H in M.contents)
		H.held_mob.muffled = FALSE
		H.held_mob.forced_psay = FALSE

	if(isliving(M))
		var/mob/living/slip = M
		slip.slip_protect = world.time + 25 // This is to prevent slipping back into your pred if they stand on soap or something.
	//Place them into our drop_location
	M.forceMove(drop_location())
	if(ismob(M))
		var/mob/ourmob = M
		ourmob.reset_view(null)
	items_preserved -= M

	//Special treatment for absorbed prey
	if(isliving(M))
		var/mob/living/ML = M
		var/mob/living/OW = owner
		if(ML.client)
			ML.stop_sound_channel(CHANNEL_PREYLOOP) //Stop the internal loop, it'll restart if the isbelly check on next tick anyway
		if(ML.muffled)
			ML.muffled = FALSE
		if(ML.forced_psay)
			ML.forced_psay = FALSE
		if(ML.absorbed)
			ML.absorbed = FALSE
			handle_absorb_langs(ML, owner)
			if(ishuman(M) && ishuman(OW))
				var/mob/living/carbon/human/Prey = M
				var/mob/living/carbon/human/Pred = OW
				var/absorbed_count = 2 //Prey that we were, plus the pred gets a portion
				for(var/mob/living/P in contents)
					if(P.absorbed)
						absorbed_count++
				Pred.bloodstr.trans_to(Prey, Pred.reagents.total_volume / absorbed_count)

	//Clean up our own business
	if(!ishuman(owner))
		owner.update_icons()

	//Determines privacy
	var/privacy_range = world.view
	//var/privacy_volume = 100
	switch(eating_privacy_local) //Third case of if("loud") not defined, as it'd just leave privacy_range and volume untouched
		if("default")
			if(owner.eating_privacy_global)
				privacy_range = 1
				//privacy_volume = 25
		if("subtle")
			privacy_range = 1
			//privacy_volume = 25

	//Print notifications/sound if necessary
	if(istype(M, /mob/observer)) //CHOMPEdit
		silent = TRUE
	if(!silent)
		owner.visible_message("<font color='green'><b>[owner] [release_verb] [M] from their [lowertext(name)]!</b></font>",range = privacy_range)
		var/soundfile
		if(!fancy_vore)
			soundfile = classic_release_sounds[release_sound]
		else
			soundfile = fancy_release_sounds[release_sound]
		if(soundfile)
			playsound(src, soundfile, vol = sound_volume, vary = 1, falloff = VORE_SOUND_FALLOFF, frequency = noise_freq, preference = /datum/client_preference/eating_noises, volume_channel = VOLUME_CHANNEL_VORE) //CHOMPEdit
	//Should fix your view not following you out of mobs sometimes!
	if(ismob(M))
		var/mob/ourmob = M
		ourmob.reset_view(null)

	if(!owner.ckey && escape_stun)
		owner.Weaken(escape_stun)

	return 1

// Actually perform the mechanics of devouring the tasty prey.
// The purpose of this method is to avoid duplicate code, and ensure that all necessary
// steps are taken.
/obj/belly/proc/nom_mob(mob/prey, mob/user)
	if(owner.stat == DEAD)
		return
	if(prey.buckled)
		prey.buckled.unbuckle_mob()

	prey.forceMove(src)
	if(ismob(prey))
		var/mob/ourmob = prey
		ourmob.reset_view(owner)
	owner.updateVRPanel()
	if(isanimal(owner))
		owner.update_icon()

	for(var/mob/living/M in contents)
		M.updateVRPanel()

	if(prey.ckey)
		GLOB.prey_eaten_roundstat++
		if(owner.mind)
			owner.mind.vore_prey_eaten++

// Get the line that should show up in Examine message if the owner of this belly
// is examined.   By making this a proc, we not only take advantage of polymorphism,
// but can easily make the message vary based on how many people are inside, etc.
// Returns a string which shoul be appended to the Examine output.
/obj/belly/proc/get_examine_msg()
	if(!(contents.len) || !(examine_messages.len))
		return ""

	var/formatted_message
	var/raw_message = pick(examine_messages)
	var/total_bulge = 0

	var/living_count = 0
	for(var/mob/living/L in contents)
		living_count++

	for(var/mob/living/P in contents)
		if(!P.absorbed) //This is required first, in case there's a person absorbed and not absorbed in a stomach.
			total_bulge += P.size_multiplier

	if(total_bulge < bulge_size || bulge_size == 0)
		return ""

	formatted_message = replacetext(raw_message, "%belly", lowertext(name))
	formatted_message = replacetext(formatted_message, "%pred", owner)
	formatted_message = replacetext(formatted_message, "%prey", english_list(contents))
	formatted_message = replacetext(formatted_message, "%countprey", living_count)
	formatted_message = replacetext(formatted_message, "%count", contents.len)

	return("<span class='warning'>[formatted_message]</span>")

/obj/belly/proc/get_examine_msg_absorbed()
	if(!(contents.len) || !(examine_messages_absorbed.len) || !display_absorbed_examine)
		return ""

	var/formatted_message
	var/raw_message = pick(examine_messages_absorbed)

	var/absorbed_count = 0
	var/list/absorbed_victims = list()
	for(var/mob/living/L in contents)
		if(L.absorbed)
			absorbed_victims += L
			absorbed_count++

	if(!absorbed_count)
		return ""

	formatted_message = replacetext(raw_message, "%belly", lowertext(name))
	formatted_message = replacetext(formatted_message, "%pred", owner)
	formatted_message = replacetext(formatted_message, "%prey", english_list(absorbed_victims))
	formatted_message = replacetext(formatted_message, "%countprey", absorbed_count)

	return("<span class='warning'>[formatted_message]</span>")

// The next function gets the messages set on the belly, in human-readable format.
// This is useful in customization boxes and such. The delimiter right now is \n\n so
// in message boxes, this looks nice and is easily delimited.
/obj/belly/proc/get_messages(type, delim = "\n\n")
	ASSERT(type == "smo" || type == "smi" || type == "asmo" || type == "asmi" || type == "dmo" || type == "dmp" || type == "amo" || type == "amp" || type == "uamo" || type == "uamp" || type == "em" || type == "ema" || type == "im_digest" || type == "im_hold" || type == "im_holdabsorbed" || type == "im_absorb" || type == "im_heal" || type == "im_drain" || type == "im_steal" || type == "im_egg" || type == "im_shrink" || type == "im_grow" || type == "im_unabsorb")

	var/list/raw_messages
	switch(type)
		if("smo")
			raw_messages = struggle_messages_outside
		if("smi")
			raw_messages = struggle_messages_inside
		if("asmo")
			raw_messages = absorbed_struggle_messages_outside
		if("asmi")
			raw_messages = absorbed_struggle_messages_inside
		if("dmo")
			raw_messages = digest_messages_owner
		if("dmp")
			raw_messages = digest_messages_prey
		if("em")
			raw_messages = examine_messages
		if("ema")
			raw_messages = examine_messages_absorbed
		if("amo")
			raw_messages = absorb_messages_owner
		if("amp")
			raw_messages = absorb_messages_prey
		if("uamo")
			raw_messages = unabsorb_messages_owner
		if("uamp")
			raw_messages = unabsorb_messages_prey
		if("im_digest")
			raw_messages = emote_lists[DM_DIGEST]
		if("im_hold")
			raw_messages = emote_lists[DM_HOLD]
		if("im_holdabsorbed")
			raw_messages = emote_lists[DM_HOLD_ABSORBED]
		if("im_absorb")
			raw_messages = emote_lists[DM_ABSORB]
		if("im_heal")
			raw_messages = emote_lists[DM_HEAL]
		if("im_drain")
			raw_messages = emote_lists[DM_DRAIN]
		if("im_steal")
			raw_messages = emote_lists[DM_SIZE_STEAL]
		if("im_egg")
			raw_messages = emote_lists[DM_EGG]
		if("im_shrink")
			raw_messages = emote_lists[DM_SHRINK]
		if("im_grow")
			raw_messages = emote_lists[DM_GROW]
		if("im_unabsorb")
			raw_messages = emote_lists[DM_UNABSORB]
	var/messages = null
	if(raw_messages)
		messages = raw_messages.Join(delim)
	return messages

// The next function sets the messages on the belly, from human-readable var
// replacement strings and linebreaks as delimiters (two \n\n by default).
// They also sanitize the messages.
/obj/belly/proc/set_messages(raw_text, type, delim = "\n\n")
	ASSERT(type == "smo" || type == "smi" || type == "asmo" || type == "asmi" || type == "dmo" || type == "dmp" || type == "amo" || type == "amp" || type == "uamo" || type == "uamp" || type == "em" || type == "ema" || type == "im_digest" || type == "im_hold" || type == "im_holdabsorbed" || type == "im_absorb" || type == "im_heal" || type == "im_drain" || type == "im_steal" || type == "im_egg" || type == "im_shrink" || type == "im_grow" || type == "im_unabsorb")

	var/list/raw_list = splittext(html_encode(raw_text),delim)
	if(raw_list.len > 10)
		raw_list.Cut(11)
		log_debug("[owner] tried to set [lowertext(name)] with 11+ messages")

	for(var/i = 1, i <= raw_list.len, i++)
		if((length(raw_list[i]) > 160 || length(raw_list[i]) < 10) && !(type == "im_digest" || type == "im_hold" || type == "im_holdabsorbed" || type == "im_absorb" || type == "im_heal" || type == "im_drain" || type == "im_steal" || type == "im_egg" || type == "im_shrink" || type == "im_grow" || type == "im_unabsorb")) //160 is fudged value due to htmlencoding increasing the size
			raw_list.Cut(i,i)
			log_debug("[owner] tried to set [lowertext(name)] with >121 or <10 char message")
		else if((type == "im_digest" || type == "im_hold" || type == "im_holdabsorbed" || type == "im_absorb" || type == "im_heal" || type == "im_drain" || type == "im_steal" || type == "im_egg" || type == "im_shrink" || type == "im_grow" || type == "im_unabsorb") && (length(raw_list[i]) > 510 || length(raw_list[i]) < 10))
			raw_list.Cut(i,i)
			log_debug("[owner] tried to set [lowertext(name)] idle message with >501 or <10 char message")
		else if((type == "em" || type == "ema") && (length(raw_list[i]) > 260 || length(raw_list[i]) < 10))
			raw_list.Cut(i,i)
			log_debug("[owner] tried to set [lowertext(name)] examine message with >260 or <10 char message")
		else
			raw_list[i] = readd_quotes(raw_list[i])
			//Also fix % sign for var replacement
			raw_list[i] = replacetext(raw_list[i],"&#37;","%")

	ASSERT(raw_list.len <= 10) //Sanity

	switch(type)
		if("smo")
			struggle_messages_outside = raw_list
		if("smi")
			struggle_messages_inside = raw_list
		if("asmo")
			absorbed_struggle_messages_outside = raw_list
		if("asmi")
			absorbed_struggle_messages_inside = raw_list
		if("dmo")
			digest_messages_owner = raw_list
		if("dmp")
			digest_messages_prey = raw_list
		if("amo")
			absorb_messages_owner = raw_list
		if("amp")
			absorb_messages_prey = raw_list
		if("uamo")
			unabsorb_messages_owner = raw_list
		if("uamp")
			unabsorb_messages_prey = raw_list
		if("em")
			examine_messages = raw_list
		if("ema")
			examine_messages_absorbed = raw_list
		if("im_digest")
			emote_lists[DM_DIGEST] = raw_list
		if("im_hold")
			emote_lists[DM_HOLD] = raw_list
		if("im_holdabsorbed")
			emote_lists[DM_HOLD_ABSORBED] = raw_list
		if("im_absorb")
			emote_lists[DM_ABSORB] = raw_list
		if("im_heal")
			emote_lists[DM_HEAL] = raw_list
		if("im_drain")
			emote_lists[DM_DRAIN] = raw_list
		if("im_steal")
			emote_lists[DM_SIZE_STEAL] = raw_list
		if("im_egg")
			emote_lists[DM_EGG] = raw_list
		if("im_shrink")
			emote_lists[DM_SHRINK] = raw_list
		if("im_grow")
			emote_lists[DM_GROW] = raw_list
		if("im_unabsorb")
			emote_lists[DM_UNABSORB] = raw_list

	return

// Handle the death of a mob via digestion.
// Called from the process_Life() methods of bellies that digest prey.
// Default implementation calls M.death() and removes from internal contents.
// Indigestable items are removed, and M is deleted.
/obj/belly/proc/digestion_death(mob/living/M)
	add_attack_logs(owner, M, "Digested in [lowertext(name)]")

	//CHOMPEdit Start - Reverts TF on death. This fixes a bug with posibrains or similar, and also makes reforming easier.
	if(M.tf_mob_holder && M.tf_mob_holder.loc == M)
		M.tf_mob_holder.ckey = M.ckey
		M.tf_mob_holder.enabled = TRUE
		M.tf_mob_holder.loc = M.loc
		M.tf_mob_holder.forceMove(M.loc)
		QDEL_LIST_NULL(M.tf_mob_holder.vore_organs)
		M.tf_mob_holder.vore_organs = list()
		for(var/obj/belly/B as anything in M.vore_organs)
			B.loc = M.tf_mob_holder
			B.forceMove(M.tf_mob_holder)
			B.owner = M.tf_mob_holder
			M.tf_mob_holder.vore_organs |= B
			M.vore_organs -= B

	if(M.tf_mob_holder)
		M.tf_mob_holder = null
	//CHOMPEdit End

	// If digested prey is also a pred... anyone inside their bellies gets moved up.
	if(is_vore_predator(M))
		M.release_vore_contents(include_absorbed = TRUE, silent = TRUE)

	var/obj/item/device/mmi/hasMMI // CHOMPEdit - Adjust how MMI's are handled

	//Drop all items into the belly.
	if(config.items_survive_digestion)
		for(var/obj/item/W in M)
			if(istype(W, /obj/item/organ/internal/mmi_holder/posibrain))
				var/obj/item/organ/internal/mmi_holder/MMI = W
				var/obj/item/device/mmi/brainbox = MMI.removed()
				if(brainbox)
					items_preserved += brainbox
					hasMMI = brainbox // CHOMPEdit - Adjust how MMI's are handled
			for(var/slot in slots)
				var/obj/item/I = M.get_equipped_item(slot = slot)
				if(I)
					M.unEquip(I,force = TRUE)
					if(contaminates)
						I.gurgle_contaminate(contents, contamination_flavor, contamination_color) //We do an initial contamination pass to get stuff like IDs wet.
					if(item_digest_mode == IM_HOLD)
						items_preserved |= I
					else if(item_digest_mode == IM_DIGEST_FOOD && !(istype(I,/obj/item/weapon/reagent_containers/food) || istype(I,/obj/item/organ)))
						items_preserved |= I

	//Reagent transfer
	if(ishuman(owner))
		var/mob/living/carbon/human/Pred = owner
		if(ishuman(M))
			var/mob/living/carbon/human/Prey = M
			Prey.bloodstr.del_reagent("numbenzyme")
			Prey.bloodstr.trans_to_holder(Pred.ingested, Prey.bloodstr.total_volume, 0.5, TRUE) // Copy=TRUE because we're deleted anyway //CHOMPEdit Start
			Prey.ingested.trans_to_holder(Pred.ingested, Prey.ingested.total_volume, 0.5, TRUE) // Therefore don't bother spending cpu
			Prey.touching.del_reagent("stomacid") //Don't need this stuff in our bloodstream.
			Prey.touching.del_reagent("diet_stomacid") //Don't need this stuff in our bloodstream.
			Prey.touching.del_reagent("cleaner") //Don't need this stuff in our bloodstream.
			Prey.touching.trans_to_holder(Pred.ingested, Prey.touching.total_volume, 0.5, TRUE) // On updating the prey's reagents
		else if(M.reagents)
			M.reagents.del_reagent("stomacid") //Don't need this stuff in our bloodstream.
			M.reagents.del_reagent("diet_stomacid") //Don't need this stuff in our bloodstream.
			M.reagents.del_reagent("cleaner") //Don't need this stuff in our bloodstream.
			M.reagents.trans_to_holder(Pred.ingested, M.reagents.total_volume, 0.5, TRUE) //CHOMPEdit End

	owner.update_fullness() //CHOMPEdit - This is run whenever a belly's contents are changed.
	//Incase they have the loop going, let's double check to stop it.
	M.stop_sound_channel(CHANNEL_PREYLOOP)
	// Delete the digested mob
	//CHOMPEdit start - Changed qdel to a forceMove to allow reforming, and... handled robots special.
	if(isrobot(M))
		var/mob/living/silicon/robot/R = M
		if(R.mmi && R.mind && R.mmi.brainmob)
			R.mmi.loc = src
			items_preserved += R.mmi
			var/obj/item/weapon/robot_module/MB = locate() in R.contents
			if(MB)
				R.mmi.brainmob.languages = MB.original_languages
			else
				R.mmi.brainmob.languages = R.languages
			R.mmi.brainmob.remove_language("Robot Talk")
			hasMMI = R.mmi
			M.mind.transfer_to(hasMMI.brainmob)
			R.mmi = null
		else if(!R.shell) // Shells don't have brainmobs in their MMIs.
			to_chat(R, "<span class='danger'>Oops! Something went very wrong, your MMI was unable to receive your mind. You have been ghosted. Please make a bug report so we can fix this bug.</span>")
		if(R.shell) // Let the standard procedure for shells handle this.
			qdel(R)
			return

	if(istype(hasMMI))
		hasMMI.body_backup = M
		M.enabled = FALSE
		M.forceMove(hasMMI)
	else
		//Another CHOMPEdit started here. I left the comment here, though obviously we're doing a lot more now as well.
		var/mob/observer/G = M.ghostize(FALSE) //CHOMPEdit start. Make sure they're out, so we can copy attack logs and such.
		if(G)
			G.forceMove(src)
			G.body_backup = M
			M.enabled = FALSE
			M.forceMove(G)
		else
			qdel(M)
	if(isanimal(owner))
		owner.update_icon()
	//CHOMPEdit End

// Handle a mob being absorbed
/obj/belly/proc/absorb_living(mob/living/M)
	var/absorb_alert_owner = pick(absorb_messages_owner)
	var/absorb_alert_prey = pick(absorb_messages_prey)

	var/absorbed_count = 0
	for(var/mob/living/L in contents)
		if(L.absorbed)
			absorbed_count++

	//Replace placeholder vars
	absorb_alert_owner = replacetext(absorb_alert_owner, "%pred", owner)
	absorb_alert_owner = replacetext(absorb_alert_owner, "%prey", M)
	absorb_alert_owner = replacetext(absorb_alert_owner, "%belly", lowertext(name))
	absorb_alert_owner = replacetext(absorb_alert_owner, "%countprey", absorbed_count)

	absorb_alert_prey = replacetext(absorb_alert_prey, "%pred", owner)
	absorb_alert_prey = replacetext(absorb_alert_prey, "%prey", M)
	absorb_alert_prey = replacetext(absorb_alert_prey, "%belly", lowertext(name))
	absorb_alert_prey = replacetext(absorb_alert_prey, "%countprey", absorbed_count)

	M.absorbed = TRUE
	if(M.ckey)
		handle_absorb_langs(M, owner)

		GLOB.prey_absorbed_roundstat++

	to_chat(M, "<span class='notice'>[absorb_alert_prey]</span>")
	to_chat(owner, "<span class='notice'>[absorb_alert_owner]</span>")
	if(M.noisy) //Mute drained absorbee hunger if enabled.
		M.noisy = FALSE

	if(ishuman(M) && ishuman(owner))
		var/mob/living/carbon/human/Prey = M
		var/mob/living/carbon/human/Pred = owner
		//Reagent sharing for absorbed with pred - Copy so both pred and prey have these reagents.
		Prey.bloodstr.trans_to_holder(Pred.ingested, Prey.bloodstr.total_volume, copy = TRUE)
		Prey.ingested.trans_to_holder(Pred.ingested, Prey.ingested.total_volume, copy = TRUE)
		Prey.touching.del_reagent("stomacid") //CHOMPEdit Don't need this stuff in our bloodstream.
		Prey.touching.del_reagent("diet_stomacid") //CHOMPEdit Don't need this stuff in our bloodstream.
		Prey.touching.del_reagent("cleaner") //CHOMPEdit Don't need this stuff in our bloodstream.
		Prey.touching.trans_to_holder(Pred.ingested, Prey.touching.total_volume, copy = TRUE)
		// TODO - Find a way to make the absorbed prey share the effects with the pred.
		// Currently this is infeasible because reagent containers are designed to have a single my_atom, and we get
		// problems when A absorbs B, and then C absorbs A,  resulting in B holding onto an invalid reagent container.

	//This is probably already the case, but for sub-prey, it won't be.
	if(M.loc != src)
		M.forceMove(src)

	if(ismob(M))
		var/mob/ourmob = M
		ourmob.reset_view(owner)

	//Seek out absorbed prey of the prey, absorb them too.
	//This in particular will recurse oddly because if there is absorbed prey of prey of prey...
	//it will just move them up one belly. This should never happen though since... when they were
	//absobred, they should have been absorbed as well!
	for(var/obj/belly/B as anything in M.vore_organs)
		for(var/mob/living/Mm in B)
			if(Mm.absorbed)
				absorb_living(Mm)


	if(absorbed_desc)
		//Replace placeholder vars
		var/formatted_abs_desc
		formatted_abs_desc = replacetext(absorbed_desc, "%belly", lowertext(name)) //replace with this belly's name
		formatted_abs_desc = replacetext(formatted_abs_desc, "%pred", owner) //replace with this belly's owner
		formatted_abs_desc = replacetext(formatted_abs_desc, "%prey", M) //replace with whatever mob entered into this belly
		to_chat(M, "<span class='notice'><B>[formatted_abs_desc]</B></span>")

	//Update owner
	owner.updateVRPanel()
	owner.update_fullness() //CHOMPEdit - This is run whenever a belly's contents are changed.
	if(isanimal(owner))
		owner.update_icon()

// Handle a mob being unabsorbed
/obj/belly/proc/unabsorb_living(mob/living/M)
	var/unabsorb_alert_owner = pick(unabsorb_messages_owner)
	var/unabsorb_alert_prey = pick(unabsorb_messages_prey)

	var/absorbed_count = 0
	for(var/mob/living/L in contents)
		if(L.absorbed)
			absorbed_count++

	//Replace placeholder vars
	unabsorb_alert_owner = replacetext(unabsorb_alert_owner, "%pred", owner)
	unabsorb_alert_owner = replacetext(unabsorb_alert_owner, "%prey", M)
	unabsorb_alert_owner = replacetext(unabsorb_alert_owner, "%belly", lowertext(name))
	unabsorb_alert_owner = replacetext(unabsorb_alert_owner, "%countprey", absorbed_count)

	unabsorb_alert_prey = replacetext(unabsorb_alert_prey, "%pred", owner)
	unabsorb_alert_prey = replacetext(unabsorb_alert_prey, "%prey", M)
	unabsorb_alert_prey = replacetext(unabsorb_alert_prey, "%belly", lowertext(name))
	unabsorb_alert_prey = replacetext(unabsorb_alert_prey, "%countprey", absorbed_count)

	M.absorbed = FALSE
	handle_absorb_langs(M, owner)
	to_chat(M, "<span class='notice'>[unabsorb_alert_prey]</span>")
	to_chat(owner, "<span class='notice'>[unabsorb_alert_owner]</span>")

	if(desc)
		to_chat(M, "<span class='notice'><B>[desc]</B></span>")

	//Update owner
	owner.updateVRPanel()
	owner.update_fullness() //CHOMPEdit - This is run whenever a belly's contents are changed.
	if(isanimal(owner))
		owner.update_icon()

/////////////////////////////////////////////////////////////////////////
/obj/belly/proc/handle_absorb_langs()
	owner.absorb_langs()

////////////////////////////////////////////////////////////////////////


//Digest a single item
//Receives a return value from digest_act that's how much nutrition
//the item should be worth
/obj/belly/proc/digest_item(obj/item/item, touchable_amount) //CHOMPEdit
	var/digested = item.digest_act(src, touchable_amount) //CHOMPEdit
	if(digested == FALSE) //CHOMPEdit
		items_preserved |= item
	else
		owner.adjust_nutrition((nutrition_percent / 100) * 5 * digested)
		// if(isrobot(owner)) //CHOMPEdit: Borgos can now use nutrition too.
		//	var/mob/living/silicon/robot/R = owner
		//	R.cell.charge += ((nutrition_percent / 100) * 50 * digested)
		digested = TRUE //CHOMPEdit
	return digested

//Determine where items should fall out of us into.
//Typically just to the owner's location.
/obj/belly/drop_location()
	//Should be the case 99.99% of the time
	if(owner)
		return owner.drop_location()
	//Sketchy fallback for safety, put them somewhere safe.
	else
		log_debug("[src] (\ref[src]) doesn't have an owner, and dropped someone at a latespawn point!")
		var/fallback = pick(latejoin)
		return get_turf(fallback)

//Yes, it's ""safe"" to drop items here
/obj/belly/AllowDrop()
	return TRUE

/obj/belly/onDropInto(atom/movable/AM)
	return null

//Handle a mob struggling
// Called from /mob/living/carbon/relaymove()
/obj/belly/proc/relay_resist(mob/living/R, obj/item/C)
	if (!(R in contents))
		if(!C)
			return  // User is not in this belly

	R.setClickCooldown(50)

	if(owner.stat) //If owner is stat (dead, KO) we can actually escape
		to_chat(R, "<span class='warning'>You attempt to climb out of \the [lowertext(name)]. (This will take around [escapetime/10] seconds.)</span>")
		to_chat(owner, "<span class='warning'>Someone is attempting to climb out of your [lowertext(name)]!</span>")

		if(do_after(R, escapetime, owner, incapacitation_flags = INCAPACITATION_DEFAULT & ~INCAPACITATION_RESTRAINED))
			if((owner.stat || escapable)) //Can still escape?
				if(C)
					release_specific_contents(C)
					return
				if(R.loc == src)
					release_specific_contents(R)
					return
			else if(R.loc != src) //Aren't even in the belly. Quietly fail.
				return
			else //Belly became inescapable or mob revived
				to_chat(R,"<span class='warning'>Your attempt to escape [lowertext(name)] has failed!</span>")
				to_chat(owner,"<span class='notice'>The attempt to escape from your [lowertext(name)] has failed!</span>")
				return
			return
	var/struggle_outer_message = pick(struggle_messages_outside)
	var/struggle_user_message = pick(struggle_messages_inside)

	var/living_count = 0
	for(var/mob/living/L in contents)
		living_count++

	struggle_outer_message = replacetext(struggle_outer_message, "%pred", owner)
	struggle_outer_message = replacetext(struggle_outer_message, "%prey", R)
	struggle_outer_message = replacetext(struggle_outer_message, "%belly", lowertext(name))
	struggle_outer_message = replacetext(struggle_outer_message, "%countprey", living_count)
	struggle_outer_message = replacetext(struggle_outer_message, "%count", contents.len)

	struggle_user_message = replacetext(struggle_user_message, "%pred", owner)
	struggle_user_message = replacetext(struggle_user_message, "%prey", R)
	struggle_user_message = replacetext(struggle_user_message, "%belly", lowertext(name))
	struggle_user_message = replacetext(struggle_user_message, "%countprey", living_count)
	struggle_user_message = replacetext(struggle_user_message, "%count", contents.len)

	struggle_outer_message = "<span class='alert'>[struggle_outer_message]</span>"
	struggle_user_message = "<span class='alert'>[struggle_user_message]</span>"

	for(var/mob/M in hearers(4, owner))
		M.show_message(struggle_outer_message, 2) // hearable
	to_chat(R, struggle_user_message)

	var/sound/struggle_snuggle
	var/sound/struggle_rustle = sound(get_sfx("rustle"))

	//CHOMPEdit Start - vore sprites struggle animation
	if((vore_sprite_flags & DM_FLAG_VORESPRITE_BELLY) && (owner.vore_capacity_ex[belly_sprite_to_affect] >= 1))
		owner.vs_animate(belly_sprite_to_affect)
	//CHOMPEdit End

	if(is_wet)
		if(!fancy_vore)
			struggle_snuggle = sound(get_sfx("classic_struggle_sounds"))
		else
			struggle_snuggle = sound(get_sfx("fancy_prey_struggle"))
		playsound(src, struggle_snuggle, vary = 1, vol = 75, falloff = VORE_SOUND_FALLOFF, frequency = noise_freq, preference = /datum/client_preference/digestion_noises, volume_channel = VOLUME_CHANNEL_VORE) //CHOMPEdit
	else
		playsound(src, struggle_rustle, vary = 1, vol = 75, falloff = VORE_SOUND_FALLOFF, frequency = noise_freq, preference = /datum/client_preference/digestion_noises, volume_channel = VOLUME_CHANNEL_VORE) //CHOMPEdit

	if(escapable) //If the stomach has escapable enabled.
		if(prob(escapechance)) //Let's have it check to see if the prey escapes first.
			to_chat(R, "<span class='warning'>You start to climb out of \the [lowertext(name)].</span>")
			to_chat(owner, "<span class='warning'>Someone is attempting to climb out of your [lowertext(name)]!</span>")
			if(do_after(R, escapetime))
				if(escapable && C)
					release_specific_contents(C)
					to_chat(R,"<span class='warning'>Your struggles successfully cause [owner] to squeeze your container out of their \the [lowertext(name)].</span>")
					to_chat(owner,"<span class='warning'>[C] suddenly slips out of your [lowertext(name)]!</span>")
					for(var/mob/M in hearers(4, owner))
						M.show_message("<span class='warning'>[C] suddenly slips out of [owner]'s [lowertext(name)]!</span>", 2)
					return
				if(escapable && (R.loc == src) && !R.absorbed) //Does the owner still have escapable enabled?
					release_specific_contents(R)
					to_chat(R,"<span class='warning'>You climb out of \the [lowertext(name)].</span>")
					to_chat(owner,"<span class='warning'>[R] climbs out of your [lowertext(name)]!</span>")
					for(var/mob/M in hearers(4, owner))
						M.show_message("<span class='warning'>[R] climbs out of [owner]'s [lowertext(name)]!</span>", 2)
					return
				else if(!(R.loc == src)) //Aren't even in the belly. Quietly fail.
					return
				else //Belly became inescapable.
					to_chat(R,"<span class='warning'>Your attempt to escape [lowertext(name)] has failed!</span>")
					to_chat(owner,"<span class='notice'>The attempt to escape from your [lowertext(name)] has failed!</span>")
					return

		else if(prob(transferchance) && transferlocation) //Next, let's have it see if they end up getting into an even bigger mess then when they started.
			var/obj/belly/dest_belly
			for(var/obj/belly/B as anything in owner.vore_organs)
				if(B.name == transferlocation)
					dest_belly = B
					break

			if(!dest_belly)
				to_chat(owner, "<span class='warning'>Something went wrong with your belly transfer settings. Your <b>[lowertext(name)]</b> has had it's transfer chance and transfer location cleared as a precaution.</span>")
				transferchance = 0
				transferlocation = null
				return

			to_chat(R, "<span class='warning'>Your attempt to escape [lowertext(name)] has failed and your struggles only results in you sliding into [owner]'s [transferlocation]!</span>")
			to_chat(owner, "<span class='warning'>Someone slid into your [transferlocation] due to their struggling inside your [lowertext(name)]!</span>")
			if(C)
				transfer_contents(C, dest_belly)
				return
			transfer_contents(R, dest_belly)
			return

		else if(prob(transferchance_secondary) && transferlocation_secondary) //After the first potential mess getting into, run the secondary one which might be even bigger of a mess.
			var/obj/belly/dest_belly
			for(var/obj/belly/B as anything in owner.vore_organs)
				if(B.name == transferlocation_secondary)
					dest_belly = B
					break

			if(!dest_belly)
				to_chat(owner, "<span class='warning'>Something went wrong with your belly transfer settings. Your <b>[lowertext(name)]</b> has had it's transfer chance and transfer location cleared as a precaution.</span>")
				transferchance_secondary = 0
				transferlocation_secondary = null
				return

			to_chat(R, "<span class='warning'>Your attempt to escape [lowertext(name)] has failed and your struggles only results in you sliding into [owner]'s [transferlocation_secondary]!</span>")
			to_chat(owner, "<span class='warning'>Someone slid into your [transferlocation_secondary] due to their struggling inside your [lowertext(name)]!</span>")
			if(C)
				transfer_contents(C, dest_belly)
				return
			transfer_contents(R, dest_belly)
			return

		else if(prob(absorbchance) && digest_mode != DM_ABSORB) //After that, let's have it run the absorb chance.
			to_chat(R, "<span class='warning'>In response to your struggling, \the [lowertext(name)] begins to cling more tightly...</span>")
			to_chat(owner, "<span class='warning'>You feel your [lowertext(name)] start to cling onto its contents...</span>")
			digest_mode = DM_ABSORB
			return

		else if(prob(digestchance) && digest_mode != DM_DIGEST) //Finally, let's see if it should run the digest chance.
			to_chat(R, "<span class='warning'>In response to your struggling, \the [lowertext(name)] begins to get more active...</span>")
			to_chat(owner, "<span class='warning'>You feel your [lowertext(name)] beginning to become active!</span>")
			digest_mode = DM_DIGEST
			return

		else //Nothing interesting happened.
			to_chat(R, "<span class='warning'>You make no progress in escaping [owner]'s [lowertext(name)].</span>")
			to_chat(owner, "<span class='warning'>Your prey appears to be unable to make any progress in escaping your [lowertext(name)].</span>")
			return


/obj/belly/proc/relay_absorbed_resist(mob/living/R)
	if (!(R in contents) || !R.absorbed)
		return  // User is not in this belly or isn't actually absorbed

	R.setClickCooldown(50)

	var/struggle_outer_message = pick(absorbed_struggle_messages_outside)
	var/struggle_user_message = pick(absorbed_struggle_messages_inside)

	var/absorbed_count = 0
	for(var/mob/living/L in contents)
		if(L.absorbed)
			absorbed_count++

	struggle_outer_message = replacetext(struggle_outer_message, "%pred", owner)
	struggle_outer_message = replacetext(struggle_outer_message, "%prey", R)
	struggle_outer_message = replacetext(struggle_outer_message, "%belly", lowertext(name))
	struggle_outer_message = replacetext(struggle_outer_message, "%countprey", absorbed_count)

	struggle_user_message = replacetext(struggle_user_message, "%pred", owner)
	struggle_user_message = replacetext(struggle_user_message, "%prey", R)
	struggle_user_message = replacetext(struggle_user_message, "%belly", lowertext(name))
	struggle_user_message = replacetext(struggle_user_message, "%countprey", absorbed_count)

	struggle_outer_message = "<span class='alert'>[struggle_outer_message]</span>"
	struggle_user_message = "<span class='alert'>[struggle_user_message]</span>"

	for(var/mob/M in hearers(4, owner))
		M.show_message(struggle_outer_message, 2) // hearable
	to_chat(R, struggle_user_message)

	var/sound/struggle_snuggle
	var/sound/struggle_rustle = sound(get_sfx("rustle"))

	if(is_wet)
		if(!fancy_vore)
			struggle_snuggle = sound(get_sfx("classic_struggle_sounds"))
		else
			struggle_snuggle = sound(get_sfx("fancy_prey_struggle"))
		playsound(src, struggle_snuggle, vary = 1, vol = 75, falloff = VORE_SOUND_FALLOFF, frequency = noise_freq, preference = /datum/client_preference/digestion_noises, volume_channel = VOLUME_CHANNEL_VORE) //CHOMPEdit
	else
		playsound(src, struggle_rustle, vary = 1, vol = 75, falloff = VORE_SOUND_FALLOFF, frequency = noise_freq, preference = /datum/client_preference/digestion_noises, volume_channel = VOLUME_CHANNEL_VORE) //CHOMPEdit

/obj/belly/proc/get_mobs_and_objs_in_belly()
	var/list/see = list()
	var/list/belly_mobs = list()
	see["mobs"] = belly_mobs
	var/list/belly_objs = list()
	see["objs"] = belly_objs
	for(var/mob/living/L in loc.contents)
		belly_mobs |= L
	for(var/obj/O in loc.contents)
		belly_objs |= O

	return see

//Transfers contents from one belly to another
/obj/belly/proc/transfer_contents(atom/movable/content, obj/belly/target, silent = 0)
	if(!(content in src) || !istype(target))
		return
	content.belly_cycles = 0 //CHOMPEdit
	content.forceMove(target)
	if(ismob(content))
		var/mob/ourmob = content
		ourmob.reset_view(owner)
	if(isitem(content))
		var/obj/item/I = content
		if(istype(I,/obj/item/weapon/card/id))
			I.gurgle_contaminate(target.contents, target.contamination_flavor, target.contamination_color)
		if(I.gurgled && target.contaminates)
			I.decontaminate()
			I.gurgle_contaminate(target.contents, target.contamination_flavor, target.contamination_color)
	items_preserved -= content
	owner.updateVRPanel()
	if(isanimal(owner))
		owner.update_icon()
	for(var/mob/living/M in contents)
		M.updateVRPanel()
	owner.update_icon()

//Autotransfer callback CHOMPEdit Start
/obj/belly/proc/check_autotransfer(var/atom/movable/prey)
	if(!(prey in contents) || !prey.autotransferable) return
	var/dest_belly_name
	if(autotransferlocation_secondary && prob(autotransferchance_secondary))
		if(ismob(prey) && autotransfer_filter(prey, autotransfer_secondary_whitelist, autotransfer_secondary_blacklist))
			dest_belly_name = autotransferlocation_secondary
		if(isitem(prey) && autotransfer_filter(prey, autotransfer_secondary_whitelist_items, autotransfer_secondary_blacklist_items))
			dest_belly_name = autotransferlocation_secondary
	if(autotransferlocation && prob(autotransferchance))
		if(ismob(prey) && autotransfer_filter(prey, autotransfer_whitelist, autotransfer_blacklist))
			dest_belly_name = autotransferlocation
		if(isitem(prey) && autotransfer_filter(prey, autotransfer_whitelist_items, autotransfer_blacklist_items))
			dest_belly_name = autotransferlocation
	if(!dest_belly_name) // Didn't transfer, so wait before retrying
		prey.belly_cycles = 0
		return
	var/obj/belly/dest_belly
	for(var/obj/belly/B in owner.vore_organs)
		if(B.name == dest_belly_name)
			dest_belly = B
			break
	if(!dest_belly) return
	transfer_contents(prey, dest_belly)
	return TRUE //CHOMPEdit end

//Autotransfer filter CHOMPEdit Start
/obj/belly/proc/autotransfer_filter(var/atom/movable/prey, var/whitelist, var/blacklist)
	if(ismob(prey))
		if(blacklist & autotransfer_flags_list["Absorbed"])
			if(isliving(prey))
				var/mob/living/L = prey
				if(L.absorbed) return FALSE
		if(blacklist != 2) // Default is 2 for Absorbed, if it's not 2, check everything else
			if(blacklist & autotransfer_flags_list["Creatures"])
				if(isliving(prey)) return FALSE
			if(blacklist & autotransfer_flags_list["Carbon"])
				if(iscarbon(prey)) return FALSE
			if(blacklist & autotransfer_flags_list["Silicon"])
				if(issilicon(prey)) return FALSE
			if(blacklist & autotransfer_flags_list["Mobs"])
				if(istype(prey, /mob/living/simple_mob)) return FALSE
			if(blacklist & autotransfer_flags_list["Animals"])
				if(istype(prey, /mob/living/simple_mob/animal)) return FALSE
			if(blacklist & autotransfer_flags_list["Mice"])
				if(ismouse(prey)) return FALSE
			if(blacklist & autotransfer_flags_list["Dead"])
				if(isliving(prey))
					var/mob/living/L = prey
					if(L.stat == DEAD) return FALSE
			if(blacklist & autotransfer_flags_list["Digestable Creatures"])
				if(isliving(prey))
					var/mob/living/L = prey
					if(L.digestable) return FALSE
			if(blacklist & autotransfer_flags_list["Absorbable Creatures"])
				if(isliving(prey))
					var/mob/living/L = prey
					if(L.absorbable) return FALSE
			if(blacklist & autotransfer_flags_list["Full Health"])
				if(isliving(prey))
					var/mob/living/L = prey
					if((L.getOxyLoss() + L.getToxLoss() + L.getFireLoss() + L.getBruteLoss() + L.getCloneLoss()) == 0) return FALSE
		if(whitelist == 0) return TRUE
		if(whitelist & autotransfer_flags_list["Creatures"])
			if(isliving(prey)) return TRUE
		if(whitelist & autotransfer_flags_list["Absorbed"])
			if(isliving(prey))
				var/mob/living/L = prey
				if(L.absorbed) return TRUE
		if(whitelist & autotransfer_flags_list["Carbon"])
			if(iscarbon(prey)) return TRUE
		if(whitelist & autotransfer_flags_list["Silicon"])
			if(issilicon(prey)) return TRUE
		if(whitelist & autotransfer_flags_list["Mobs"])
			if(istype(prey, /mob/living/simple_mob)) return TRUE
		if(whitelist & autotransfer_flags_list["Animals"])
			if(istype(prey, /mob/living/simple_mob/animal)) return TRUE
		if(whitelist & autotransfer_flags_list["Mice"])
			if(ismouse(prey)) return TRUE
		if(whitelist & autotransfer_flags_list["Dead"])
			if(isliving(prey))
				var/mob/living/L = prey
				if(L.stat == DEAD) return TRUE
		if(whitelist & autotransfer_flags_list["Digestable Creatures"])
			if(isliving(prey))
				var/mob/living/L = prey
				if(L.digestable) return TRUE
		if(whitelist & autotransfer_flags_list["Absorbable Creatures"])
			if(isliving(prey))
				var/mob/living/L = prey
				if(L.absorbable) return TRUE
		if(whitelist & autotransfer_flags_list["Full Health"])
			if(isliving(prey))
				var/mob/living/L = prey
				if((L.getOxyLoss() + L.getToxLoss() + L.getFireLoss() + L.getBruteLoss() + L.getCloneLoss()) == 0) return TRUE
	else
		if(blacklist & autotransfer_flags_list_items["Items"])
			if(isitem(prey)) return FALSE
		if(blacklist & autotransfer_flags_list_items["Trash"])
			if(istype(prey, /obj/item/trash)) return FALSE
		if(blacklist & autotransfer_flags_list_items["Eggs"])
			if(istype(prey, /obj/item/weapon/storage/vore_egg)) return FALSE
		if(blacklist & autotransfer_flags_list_items["Remains"])
			if(istype(prey, /obj/item/weapon/digestion_remains)) return FALSE
		if(blacklist & autotransfer_flags_list_items["Indigestible Items"])
			if(prey in items_preserved) return FALSE
		if(blacklist & autotransfer_flags_list_items["Recyclable Items"])
			if(isitem(prey))
				var/obj/item/I = prey
				if(I.matter) return FALSE
		if(blacklist & autotransfer_flags_list_items["Ores"])
			if(istype(prey, /obj/item/weapon/ore)) return FALSE
		if(blacklist & autotransfer_flags_list_items["Clothes and Bags"])
			if(istype(prey, /obj/item/clothing) || istype(prey, /obj/item/weapon/storage)) return FALSE
		if(blacklist & autotransfer_flags_list_items["Food"])
			if(istype(prey, /obj/item/weapon/reagent_containers/food)) return FALSE
		if(whitelist == 0) return TRUE
		if(whitelist & autotransfer_flags_list_items["Items"])
			if(isitem(prey)) return TRUE
		if(whitelist & autotransfer_flags_list_items["Trash"])
			if(istype(prey, /obj/item/trash)) return TRUE
		if(whitelist & autotransfer_flags_list_items["Eggs"])
			if(istype(prey, /obj/item/weapon/storage/vore_egg)) return TRUE
		if(whitelist & autotransfer_flags_list_items["Remains"])
			if(istype(prey, /obj/item/weapon/digestion_remains)) return TRUE
		if(whitelist & autotransfer_flags_list_items["Indigestible Items"])
			if(prey in items_preserved) return TRUE
		if(whitelist & autotransfer_flags_list_items["Recyclable Items"])
			if(isitem(prey))
				var/obj/item/I = prey
				if(I.matter) return TRUE
		if(whitelist & autotransfer_flags_list_items["Ores"])
			if(istype(prey, /obj/item/weapon/ore)) return TRUE
		if(whitelist & autotransfer_flags_list_items["Clothes and Bags"])
			if(istype(prey, /obj/item/clothing) || istype(prey, /obj/item/weapon/storage)) return TRUE
		if(whitelist & autotransfer_flags_list_items["Food"])
			if(istype(prey, /obj/item/weapon/reagent_containers/food)) return TRUE
	return FALSE //CHOMPEdit end

// Belly copies and then returns the copy
// Needs to be updated for any var changes
/obj/belly/proc/copy(mob/new_owner)
	var/obj/belly/dupe = new /obj/belly(new_owner)

	//// Non-object variables
	dupe.name = name
	dupe.desc = desc
	dupe.absorbed_desc = absorbed_desc
	dupe.vore_sound = vore_sound
	dupe.vore_verb = vore_verb
	dupe.release_verb = release_verb
	dupe.human_prey_swallow_time = human_prey_swallow_time
	dupe.nonhuman_prey_swallow_time = nonhuman_prey_swallow_time
	dupe.emote_time = emote_time
	dupe.nutrition_percent = nutrition_percent
	dupe.digest_brute = digest_brute
	dupe.digest_burn = digest_burn
	dupe.digest_oxy = digest_oxy
	dupe.digest_tox = digest_tox
	dupe.digest_clone = digest_clone
	dupe.immutable = immutable
	dupe.can_taste = can_taste
	dupe.escapable = escapable
	dupe.escapetime = escapetime
	dupe.digestchance = digestchance
	dupe.absorbchance = absorbchance
	dupe.escapechance = escapechance
	dupe.transferchance = transferchance
	dupe.transferchance_secondary = transferchance_secondary
	dupe.transferlocation = transferlocation
	dupe.transferlocation_secondary = transferlocation_secondary
	dupe.bulge_size = bulge_size
	dupe.shrink_grow_size = shrink_grow_size
	dupe.mode_flags = mode_flags
	dupe.item_digest_mode = item_digest_mode
	dupe.contaminates = contaminates
	dupe.contamination_flavor = contamination_flavor
	dupe.contamination_color = contamination_color
	dupe.release_sound = release_sound
	dupe.fancy_vore = fancy_vore
	dupe.is_wet = is_wet
	dupe.wet_loop = wet_loop

	dupe.reagent_mode_flags = reagent_mode_flags	//CHOMP start of variables from CHOMP
	dupe.belly_fullscreen_color2 = belly_fullscreen_color2
	dupe.belly_fullscreen_color3 = belly_fullscreen_color3
	dupe.belly_fullscreen_color4 = belly_fullscreen_color4
	dupe.belly_fullscreen_alpha = belly_fullscreen_alpha
	dupe.reagentbellymode = reagentbellymode
	dupe.vorefootsteps_sounds = vorefootsteps_sounds
	dupe.liquid_fullness1_messages = liquid_fullness1_messages
	dupe.liquid_fullness2_messages = liquid_fullness2_messages
	dupe.liquid_fullness3_messages = liquid_fullness3_messages
	dupe.liquid_fullness4_messages = liquid_fullness4_messages
	dupe.liquid_fullness5_messages = liquid_fullness5_messages
	dupe.reagent_name = reagent_name
	dupe.reagent_chosen = reagent_chosen
	dupe.reagentid = reagentid
	dupe.reagentcolor = reagentcolor
	dupe.liquid_overlay = liquid_overlay
	dupe.max_liquid_level = max_liquid_level
	dupe.reagent_touches = reagent_touches
	dupe.mush_overlay = mush_overlay
	dupe.mush_color = mush_color
	dupe.mush_alpha = mush_alpha
	dupe.max_mush = max_mush
	dupe.min_mush = min_mush
	dupe.item_mush_val = item_mush_val
	dupe.custom_reagentcolor = custom_reagentcolor
	dupe.custom_reagentalpha = custom_reagentalpha
	dupe.metabolism_overlay = metabolism_overlay
	dupe.metabolism_mush_ratio = metabolism_mush_ratio
	dupe.max_ingested = max_ingested
	dupe.custom_ingested_color = custom_ingested_color
	dupe.custom_ingested_alpha = custom_ingested_alpha
	dupe.gen_cost = gen_cost
	dupe.gen_amount = gen_amount
	dupe.gen_time = gen_time
	dupe.gen_time_display = gen_time_display
	dupe.reagent_transfer_verb = reagent_transfer_verb
	dupe.custom_max_volume = custom_max_volume
	dupe.vorespawn_blacklist = vorespawn_blacklist
	dupe.vore_sprite_flags = vore_sprite_flags
	dupe.affects_vore_sprites = affects_vore_sprites
	dupe.count_absorbed_prey_for_sprite = count_absorbed_prey_for_sprite
	dupe.absorbed_multiplier = absorbed_multiplier
	dupe.count_liquid_for_sprite = count_liquid_for_sprite
	dupe.liquid_multiplier = liquid_multiplier
	dupe.count_items_for_sprite = count_items_for_sprite
	dupe.item_multiplier = item_multiplier
	dupe.health_impacts_size = health_impacts_size
	dupe.resist_triggers_animation = resist_triggers_animation
	dupe.size_factor_for_sprite = size_factor_for_sprite
	dupe.belly_sprite_to_affect = belly_sprite_to_affect
	dupe.undergarment_chosen = undergarment_chosen
	dupe.undergarment_if_none = undergarment_if_none
	dupe.undergarment_color = undergarment_color
	dupe.autotransferchance = autotransferchance
	dupe.autotransferwait = autotransferwait
	dupe.autotransferlocation = autotransferlocation
	dupe.autotransfer_enabled = autotransfer_enabled
	dupe.autotransferchance_secondary = autotransferchance_secondary
	dupe.autotransferlocation_secondary = autotransferlocation_secondary
	dupe.autotransfer_min_amount = autotransfer_min_amount
	dupe.autotransfer_max_amount = autotransfer_max_amount
	dupe.slow_digestion = slow_digestion
	dupe.slow_brutal = slow_brutal
	dupe.sound_volume = sound_volume
	dupe.egg_name = egg_name
	dupe.recycling = recycling
	dupe.is_feedable = is_feedable
	dupe.entrance_logs = entrance_logs
	dupe.noise_freq = noise_freq
	dupe.item_digest_logs = item_digest_logs //CHOMP end of variables from CHOMP

	dupe.belly_fullscreen = belly_fullscreen
	dupe.disable_hud = disable_hud
	dupe.belly_fullscreen_color = belly_fullscreen_color
	//dupe.belly_fullscreen_color_secondary = belly_fullscreen_color_secondary //Chomp Disable - Use our solution, not upstream's
	//dupe.belly_fullscreen_color_trinary = belly_fullscreen_color_trinary //Chomp Disable - Use our solution, not upstream's
	dupe.colorization_enabled = colorization_enabled
	dupe.egg_type = egg_type
	dupe.emote_time = emote_time
	dupe.emote_active = emote_active
	dupe.selective_preference = selective_preference
	dupe.save_digest_mode = save_digest_mode
	dupe.eating_privacy_local = eating_privacy_local
	dupe.silicon_belly_overlay_preference = silicon_belly_overlay_preference
	dupe.belly_mob_mult = belly_mob_mult
	dupe.belly_item_mult = belly_item_mult
	dupe.belly_overall_mult	= belly_overall_mult

	//// Object-holding variables
	//struggle_messages_outside - strings
	dupe.struggle_messages_outside.Cut()
	for(var/I in struggle_messages_outside)
		dupe.struggle_messages_outside += I

	//struggle_messages_inside - strings
	dupe.struggle_messages_inside.Cut()
	for(var/I in struggle_messages_inside)
		dupe.struggle_messages_inside += I

	//absorbed_struggle_messages_outside - strings
	dupe.absorbed_struggle_messages_outside.Cut()
	for(var/I in absorbed_struggle_messages_outside)
		dupe.absorbed_struggle_messages_outside += I

	//absorbed_struggle_messages_inside - strings
	dupe.absorbed_struggle_messages_inside.Cut()
	for(var/I in absorbed_struggle_messages_inside)
		dupe.absorbed_struggle_messages_inside += I

	//digest_messages_owner - strings
	dupe.digest_messages_owner.Cut()
	for(var/I in digest_messages_owner)
		dupe.digest_messages_owner += I

	//digest_messages_prey - strings
	dupe.digest_messages_prey.Cut()
	for(var/I in digest_messages_prey)
		dupe.digest_messages_prey += I

	//absorb_messages_owner - strings
	dupe.absorb_messages_owner.Cut()
	for(var/I in absorb_messages_owner)
		dupe.absorb_messages_owner += I

	//absorb_messages_prey - strings
	dupe.absorb_messages_prey.Cut()
	for(var/I in absorb_messages_prey)
		dupe.absorb_messages_prey += I

	//unabsorb_messages_owner - strings
	dupe.unabsorb_messages_owner.Cut()
	for(var/I in unabsorb_messages_owner)
		dupe.unabsorb_messages_owner += I

	//unabsorb_messages_prey - strings
	dupe.unabsorb_messages_prey.Cut()
	for(var/I in unabsorb_messages_prey)
		dupe.unabsorb_messages_prey += I

	//examine_messages - strings
	dupe.examine_messages.Cut()
	for(var/I in examine_messages)
		dupe.examine_messages += I


	// CHOMP reagent belly
	//generated_reagents - strings
	dupe.generated_reagents.Cut()
	for(var/I in generated_reagents)
		dupe.generated_reagents += I

	// CHOMP fullness messages stage 1
	//fullness1_messages - strings
	dupe.fullness1_messages.Cut()
	for(var/I in fullness1_messages)
		dupe.fullness1_messages += I

	// CHOMP fullness messages stage 2
	//fullness2_messages - strings
	dupe.fullness2_messages.Cut()
	for(var/I in fullness2_messages)
		dupe.fullness2_messages += I

	// CHOMP fullness messages stage 3
	//fullness3_messages - strings
	dupe.fullness3_messages.Cut()
	for(var/I in fullness3_messages)
		dupe.fullness3_messages += I

	// CHOMP fullness messages stage 4
	//fullness4_messages - strings
	dupe.fullness4_messages.Cut()
	for(var/I in fullness4_messages)
		dupe.fullness4_messages += I

	// CHOMP fullness messages stage 5
	//generated_reagents - strings
	dupe.fullness5_messages.Cut()
	for(var/I in fullness5_messages)
		dupe.fullness5_messages += I

	//examine_messages_absorbed - strings
	dupe.examine_messages_absorbed.Cut()
	for(var/I in examine_messages_absorbed)
		dupe.examine_messages_absorbed += I

	//emote_lists - index: digest mode, key: list of strings
	dupe.emote_lists.Cut()
	for(var/K in emote_lists)
		dupe.emote_lists[K] = list()
		for(var/I in emote_lists[K])
			dupe.emote_lists[K] += I

	return dupe

/obj/belly/container_resist(mob/M)
	return relay_resist(M)
