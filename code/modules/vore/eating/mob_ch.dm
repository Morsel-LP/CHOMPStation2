/mob
	var/receive_reagents = FALSE			//Pref for people to avoid others transfering reagents into them.
	var/give_reagents = FALSE				//Pref for people to avoid others taking reagents from them.

	// CHOMP vore icons refactor (Now on mob)
	var/vore_capacity = 0				// Maximum capacity, -1 for unlimited
	var/vore_capacity_ex = list("stomach" = 0) //expanded list of capacities
	var/vore_fullness = 0				// How "full" the belly is (controls icons)
	var/list/vore_fullness_ex = list("stomach" = 0) // Expanded list of fullness
	var/belly_size_multiplier = 1
	var/vore_sprite_multiply = list("stomach" = FALSE, "taur belly" = FALSE)
	var/vore_sprite_color = list("stomach" = "#000", "taur belly" = "#000")

	var/list/vore_icon_bellies = list("stomach")
	var/updating_fullness = FALSE
	var/obj/belly/previewing_belly
