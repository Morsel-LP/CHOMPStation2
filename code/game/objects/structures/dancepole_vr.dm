//Dance pole
/obj/structure/dancepole
	name = "dance pole"
	desc = "Engineered for your entertainment"
	icon = 'icons/obj/objects_vr.dmi'
	icon_state = "dancepole"
	density = FALSE
	anchored = TRUE

/obj/structure/dancepole/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if(O.has_tool_quality(TOOL_SCREWDRIVER))
		anchored = !anchored
		playsound(src, O.usesound, 50, 1)
		if(anchored)
			to_chat(user, "<font color='blue'>You secure \the [src].</font>")
		else
			to_chat(user, "<font color='blue'>You unsecure \the [src].</font>")
	if(O.has_tool_quality(TOOL_WRENCH))
		playsound(src, O.usesound, 50, 1)
		to_chat(user, "<span class='notice'>Now disassembling \the [src]...</span>")
		if(do_after(user, 30 * O.toolspeed))
			if(!src) return
			to_chat(user, "<span class='notice'>You dissasembled \the [src]!</span>")
			new /obj/item/stack/material/steel(src.loc, 1)
			qdel(src)