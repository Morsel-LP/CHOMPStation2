// Internal surgeries.
/datum/surgery_step/internal
	priority = 2
	can_infect = 1
	blood_level = 1

/datum/surgery_step/internal/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)

	if (!hasorgans(target))
		return 0

	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	if(coverage_check(user, target, affected, tool))
		return 0
	return affected && affected.open == (affected.encased ? 3 : 2)

//Removed unused Embryo Surgery, derelict and broken.

//////////////////////////////////////////////////////////////////
//				CHEST INTERNAL ORGAN SURGERY					//
//////////////////////////////////////////////////////////////////
/datum/surgery_step/internal/fix_organ
	allowed_tools = list(
	/obj/item/stack/medical/advanced/bruise_pack= 100,		\
	/obj/item/stack/medical/bruise_pack = 20
	)

	min_duration = 70
	max_duration = 90

/datum/surgery_step/internal/fix_organ/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if (!hasorgans(target))
		return
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	if(!affected)
		return
	var/is_organ_damaged = 0
	for(var/obj/item/organ/I in affected.internal_organs)
		if(I && (I.damage > 0 || I.status == ORGAN_DEAD))
			is_organ_damaged = 1
			break
	return ..() && is_organ_damaged

/datum/surgery_step/internal/fix_organ/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/tool_name = "\the [tool]"
	if (istype(tool, /obj/item/stack/medical/advanced/bruise_pack))
		tool_name = "regenerative membrane"
	else if (istype(tool, /obj/item/stack/medical/bruise_pack))
		tool_name = "the bandaid"

	if (!hasorgans(target))
		return

	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	for(var/obj/item/organ/I in affected.internal_organs)
		if(I && (I.damage > 0 || I.status == ORGAN_DEAD))
			if(!(I.robotic >= ORGAN_ROBOT))
				user.visible_message("<span class='filter_notice'>[user] starts treating damage to [target]'s [I.name] with [tool_name].</span>", \
				"<span class='filter_notice'>You start treating damage to [target]'s [I.name] with [tool_name].</span>" )

	target.custom_pain("The pain in your [affected.name] is living hell!", 100)
	..()

/datum/surgery_step/internal/fix_organ/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/tool_name = "\the [tool]"
	if (istype(tool, /obj/item/stack/medical/advanced/bruise_pack))
		tool_name = "regenerative membrane"
	if (istype(tool, /obj/item/stack/medical/bruise_pack))
		tool_name = "the bandaid"

	if (!hasorgans(target))
		return
	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	for(var/obj/item/organ/internal/I in affected.internal_organs)
		if(I && (I.damage > 0 || I.status == ORGAN_DEAD))
			if(!(I.robotic >= ORGAN_ROBOT))
				user.visible_message("<span class='notice'>[user] treats damage to [target]'s [I.name] with [tool_name].</span>", \
				"<span class='notice'>You treat damage to [target]'s [I.name] with [tool_name].</span>" )
				if(I.organ_tag == O_BRAIN && I.status == ORGAN_DEAD && target.can_defib == 0) //Let people know they still got more work to get the brain back into working order.
					to_chat(user, "<span class='warning'>You fix their [I] but the neurological structure is still heavily damaged and in need of repair.</span>")
				I.damage = 0
				I.status = 0
				if(I.organ_tag == O_EYES)
					target.sdisabilities &= ~BLIND
				if(I.organ_tag == O_LUNGS)
					target.SetLosebreath(0)

/datum/surgery_step/internal/fix_organ/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if (!hasorgans(target))
		return
	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	user.visible_message("<span class='warning'>[user]'s hand slips, getting mess and tearing the inside of [target]'s [affected.name] with \the [tool]!</span>", \
	"<span class='warning'>Your hand slips, getting mess and tearing the inside of [target]'s [affected.name] with \the [tool]!</span>")
	var/dam_amt = 2

	if (istype(tool, /obj/item/stack/medical/advanced/bruise_pack))
		target.adjustToxLoss(5)
	else if (istype(tool, /obj/item/stack/medical/bruise_pack))
		dam_amt = 5
		target.adjustToxLoss(10)
		affected.createwound(CUT, 5)

	for(var/obj/item/organ/I in affected.internal_organs)
		if(I && I.damage > 0)
			I.take_damage(dam_amt,0)






//Robo internal organ fix. For when an organic has robotic limbs.
/datum/surgery_step/fix_organic_organ_robotic //For artificial organs
	allowed_tools = list(
	/obj/item/stack/nanopaste = 100,
	/obj/item/stack/cable_coil = 75,
	/obj/item/weapon/tool/wrench = 50,
	/obj/item/weapon/storage/toolbox = 10 	//Percussive Maintenance
	)

	min_duration = 70
	max_duration = 90

/datum/surgery_step/fix_organic_organ_robotic/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if (!hasorgans(target))
		return
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	if(!affected) return
	var/is_organ_damaged = 0
	for(var/obj/item/organ/I in affected.internal_organs)
		if(I.damage > 0 && (I.robotic >= ORGAN_ROBOT))
			is_organ_damaged = 1
			break
	return affected.open != 3 && is_organ_damaged //Robots have their own code.

/datum/surgery_step/fix_organic_organ_robotic/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if (!hasorgans(target))
		return
	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	for(var/obj/item/organ/I in affected.internal_organs)
		if(I && I.damage > 0)
			if(I.robotic >= ORGAN_ROBOT)
				user.visible_message("[user] starts mending the damage to [target]'s [I.name]'s mechanisms.", \
				"You start mending the damage to [target]'s [I.name]'s mechanisms." )

	target.custom_pain("The pain in your [affected.name] is living hell!",1)
	..()

/datum/surgery_step/fix_organic_organ_robotic/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if (!hasorgans(target))
		return
	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	for(var/obj/item/organ/I in affected.internal_organs)
		if(I && I.damage > 0)
			if(I.robotic >= ORGAN_ROBOT)
				user.visible_message("<span class='notice'>[user] repairs [target]'s [I.name] with [tool].</span>", \
				"<span class='notice'>You repair [target]'s [I.name] with [tool].</span>" )
				I.damage = 0
				if(I.organ_tag == O_EYES)
					target.sdisabilities &= ~BLIND

/datum/surgery_step/fix_organic_organ_robotic/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if (!hasorgans(target))
		return
	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	user.visible_message("<span class='warning'>[user]'s hand slips, gumming up the mechanisms inside of [target]'s [affected.name] with \the [tool]!</span>", \
	"<span class='warning'>Your hand slips, gumming up the mechanisms inside of [target]'s [affected.name] with \the [tool]!</span>")

	target.adjustBruteLoss(5)

	for(var/obj/item/organ/I in affected.internal_organs)
		if(I)
			I.take_damage(rand(3,5),0)


//Robo limb fix end


///////////////////////////////////////////////////////////////
// Organ Detaching Surgery
///////////////////////////////////////////////////////////////

/datum/surgery_step/internal/detatch_organ/
	surgery_name = "Detach Organ"	//CHOMPEdit
	allowed_tools = list(
	/obj/item/weapon/surgical/scalpel = 100,		\
	/obj/item/weapon/material/knife = 75,	\
	/obj/item/weapon/material/shard = 50, 		\
	)

	min_duration = 90
	max_duration = 110

/datum/surgery_step/internal/detatch_organ/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if (!..())
		return 0

	if(!istype(tool))
		return 0

	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	if(!(affected && !(affected.robotic >= ORGAN_ROBOT)))
		return 0

	target.op_stage.current_organ = null

	var/list/attached_organs = list()
	for(var/organ in target.internal_organs_by_name)
		var/obj/item/organ/I = target.internal_organs_by_name[organ]
		if(I && !(I.status & ORGAN_CUT_AWAY) && I.parent_organ == target_zone)
			attached_organs |= organ

	var/organ_to_remove = tgui_input_list(user, "Which organ do you want to prepare for removal?", "Organ Choice", attached_organs)
	if(!organ_to_remove)
		return 0

	target.op_stage.current_organ = organ_to_remove

	return ..() && organ_to_remove

/datum/surgery_step/internal/detatch_organ/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	user.visible_message("<span class='filter_notice'>[user] starts to separate [target]'s [target.op_stage.current_organ] with \the [tool].</span>", \
	"<span class='filter_notice'>You start to separate [target]'s [target.op_stage.current_organ] with \the [tool].</span>" )
	target.custom_pain("The pain in your [affected.name] is living hell!", 100)
	..()

/datum/surgery_step/internal/detatch_organ/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='notice'>[user] has separated [target]'s [target.op_stage.current_organ] with \the [tool].</span>" , \
	"<span class='notice'>You have separated [target]'s [target.op_stage.current_organ] with \the [tool].</span>")

	var/obj/item/organ/I = target.internal_organs_by_name[target.op_stage.current_organ]
	if(I && istype(I))
		I.status |= ORGAN_CUT_AWAY

/datum/surgery_step/internal/detatch_organ/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, slicing an artery inside [target]'s [affected.name] with \the [tool]!</span>", \
	"<span class='warning'>Your hand slips, slicing an artery inside [target]'s [affected.name] with \the [tool]!</span>")
	affected.createwound(CUT, rand(30,50), 1)

///////////////////////////////////////////////////////////////
// Organ Removal Surgery
///////////////////////////////////////////////////////////////

/datum/surgery_step/internal/remove_organ
	surgery_name = "Remove Organ"

	allowed_tools = list(
	/obj/item/weapon/surgical/hemostat = 100,	\
	/obj/item/weapon/material/kitchen/utensil/fork = 20
	)

	allowed_procs = list(IS_WIRECUTTER = 100) //FBP code also uses this, so let's be nice. Roboticists won't know to use hemostats.

	min_duration = 60
	max_duration = 80

/datum/surgery_step/internal/remove_organ/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if (!..())
		return 0

	if(!istype(tool))
		return 0

	var/list/removable_organs = list()
	for(var/organ in target.internal_organs_by_name)
		var/obj/item/organ/internal/I = target.internal_organs_by_name[organ]
		if(istype(I) && (I.status & ORGAN_CUT_AWAY) && I.parent_organ == target_zone)
			removable_organs |= organ

	if(!removable_organs.len)
		return 0

	return ..()

/datum/surgery_step/internal/remove_organ/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	var/list/removable_organs = list()
	for(var/organ in target.internal_organs_by_name)
		var/obj/item/organ/internal/I = target.internal_organs_by_name[organ]
		if(istype(I) && (I.status & ORGAN_CUT_AWAY) && I.parent_organ == target_zone)
			removable_organs |= organ

	var/organ_to_remove = tgui_input_list(user, "Which organ do you want to remove?", "Organ Choice", removable_organs)
	if(!organ_to_remove) //They chose cancel!
		to_chat(user, "<span class='notice'>You decide against preparing any organs for removal.</span>")
		user.visible_message("<span class='filter_notice'>[user] starts pulling \the [tool] from [target]'s [affected].</span>", \
		"<span class='filter_notice'>You start pulling \the [tool] from [target]'s [affected].</span>")

	target.op_stage.current_organ = organ_to_remove

	user.visible_message("<span class='filter_notice'>[user] starts removing [target]'s [target.op_stage.current_organ] with \the [tool].</span>", \
	"<span class='filter_notice'>You start removing [target]'s [target.op_stage.current_organ] with \the [tool].</span>")
	target.custom_pain("Someone's ripping out your [target.op_stage.current_organ]!", 100)
	..()

/datum/surgery_step/internal/remove_organ/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	if(!target.op_stage.current_organ) //They chose to remove their tool instead.
		user.visible_message("<span class='notice'>[user] has removed \the [tool] from [target]'s [affected].</span>", \
		"<span class='notice'>You have removed \the [tool] from [target]'s [affected].</span>")

	// Extract the organ!
	if(target.op_stage.current_organ)
		user.visible_message("<span class='notice'>[user] has removed [target]'s [target.op_stage.current_organ] with \the [tool].</span>", \
		"<span class='notice'>You have removed [target]'s [target.op_stage.current_organ] with \the [tool].</span>")
		var/obj/item/organ/O = target.internal_organs_by_name[target.op_stage.current_organ]
		if(O && istype(O))
			O.removed(user)
	target.op_stage.current_organ = null

/datum/surgery_step/internal/remove_organ/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, damaging [target]'s [affected.name] with \the [tool]!</span>", \
	"<span class='warning'>Your hand slips, damaging [target]'s [affected.name] with \the [tool]!</span>")
	affected.createwound(BRUISE, 20)

///////////////////////////////////////////////////////////////
// Organ Replacement Surgery
///////////////////////////////////////////////////////////////

/datum/surgery_step/internal/replace_organ
	allowed_tools = list(
	/obj/item/organ = 100
	)

	min_duration = 60
	max_duration = 80

/datum/surgery_step/internal/replace_organ/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/internal/O = tool
	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	if(!affected || !istype(O))
		return

	var/organ_compatible
	var/organ_missing

	if(!istype(O))
		return 0

	if((affected.robotic >= ORGAN_ROBOT) && !(O.robotic >= ORGAN_ROBOT))
		to_chat(user, "<span class='danger'>You cannot install a naked organ into a robotic body.</span>")
		return SURGERY_FAILURE

	if(!target.species)
		to_chat(user, "<span class='danger'>You have no idea what species this person is. Report this on the bug tracker.</span>")
		return SURGERY_FAILURE

	var/o_is = (O.gender == PLURAL) ? "are" : "is"
	var/o_a =  (O.gender == PLURAL) ? "" : "a "
	var/o_do = (O.gender == PLURAL) ? "don't" : "doesn't"

	if(O.damage > (O.max_damage * 0.75))
		to_chat(user, "<span class='warning'>\The [O.organ_tag] [o_is] in no state to be transplanted.</span>")
		return SURGERY_FAILURE

	if(!target.internal_organs_by_name[O.organ_tag])
		organ_missing = 1
	else
		to_chat(user, "<span class='warning'>\The [target] already has [o_a][O.organ_tag].</span>")
		return SURGERY_FAILURE

	if(O && affected.organ_tag == O.parent_organ)
		organ_compatible = 1

	else
		to_chat(user, "<span class='warning'>\The [O.organ_tag] [o_do] normally go in \the [affected.name].</span>")
		return SURGERY_FAILURE

	return ..() && organ_missing && organ_compatible

/datum/surgery_step/internal/replace_organ/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='filter_notice'>[user] starts transplanting \the [tool] into [target]'s [affected.name].</span>", \
	"<span class='filter_notice'>You start transplanting \the [tool] into [target]'s [affected.name].</span>")
	target.custom_pain("Someone's rooting around in your [affected.name]!", 100)
	..()

/datum/surgery_step/internal/replace_organ/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'>[user] has transplanted \the [tool] into [target]'s [affected.name].</span>", \
	"<span class='notice'>You have transplanted \the [tool] into [target]'s [affected.name].</span>")
	var/obj/item/organ/O = tool
	if(istype(O))
		user.remove_from_mob(O)
		O.replaced(target,affected)

/datum/surgery_step/internal/replace_organ/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='warning'>[user]'s hand slips, damaging \the [tool]!</span>", \
	"<span class='warning'>Your hand slips, damaging \the [tool]!</span>")
	var/obj/item/organ/I = tool
	if(istype(I))
		I.take_damage(rand(3,5),0)

///////////////////////////////////////////////////////////////
// Organ Attaching Surgery
///////////////////////////////////////////////////////////////

/datum/surgery_step/internal/attach_organ
	surgery_name = "Attach Organ"	//CHOMPEdit
	allowed_tools = list(
	/obj/item/weapon/surgical/FixOVein = 100, \
	/obj/item/stack/cable_coil = 75
	)

	min_duration = 100
	max_duration = 120

/datum/surgery_step/internal/attach_organ/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if (!..())
		return 0

	if(!istype(tool))
		return 0

	target.op_stage.current_organ = null

	var/list/removable_organs = list()
	for(var/organ in target.internal_organs_by_name)
		var/obj/item/organ/I = target.internal_organs_by_name[organ]
		if(istype(I) && (I.status & ORGAN_CUT_AWAY) && !(I.robotic >= ORGAN_ROBOT) && I.parent_organ == target_zone)
			removable_organs |= organ

	var/organ_to_replace = tgui_input_list(user, "Which organ do you want to reattach?", "Organ Choice", removable_organs)
	if(!organ_to_replace)
		return 0

	target.op_stage.current_organ = organ_to_replace
	return ..()

/datum/surgery_step/internal/attach_organ/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='filter_notice'>[user] begins reattaching [target]'s [target.op_stage.current_organ] with \the [tool].</span>", \
	"<span class='filter_notice'>You start reattaching [target]'s [target.op_stage.current_organ] with \the [tool].</span>")
	target.custom_pain("Someone's digging needles into your [target.op_stage.current_organ]!", 100)
	..()

/datum/surgery_step/internal/attach_organ/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='notice'>[user] has reattached [target]'s [target.op_stage.current_organ] with \the [tool].</span>" , \
	"<span class='notice'>You have reattached [target]'s [target.op_stage.current_organ] with \the [tool].</span>")

	var/obj/item/organ/I = target.internal_organs_by_name[target.op_stage.current_organ]
	if(I && istype(I))
		I.status &= ~ORGAN_CUT_AWAY

/datum/surgery_step/internal/attach_organ/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, damaging the flesh in [target]'s [affected.name] with \the [tool]!</span>", \
	"<span class='warning'>Your hand slips, damaging the flesh in [target]'s [affected.name] with \the [tool]!</span>")
	affected.createwound(BRUISE, 20)
