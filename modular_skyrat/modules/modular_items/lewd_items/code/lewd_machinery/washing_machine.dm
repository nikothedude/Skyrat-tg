/obj/machinery/washing_machine
	can_buckle = TRUE

#define WASHING_MACHINE_VAGINA_AROUSAL 2
#define WASHING_MACHINE_PENIS_AROUSAL 0.5

/obj/machinery/washing_machine/process(seconds_per_tick)
	. = ..()
	if (. == PROCESS_KILL)
		return PROCESS_KILL

	if (!LAZYLEN(buckled_mobs))
		return

	for (var/mob/iterated_mob as anything in buckled_mobs)
		if (ishuman(iterated_mob))
			var/mob/living/carbon/human/buckled_human = iterated_mob

			if (!buckled_human.client?.prefs?.read_preference(/datum/preference/toggle/erp))
				continue

			var/covered = FALSE
			for (var/obj/item/clothing/iter_clothing in buckled_human.get_all_worn_items())
				if (!(iter_clothing.body_parts_covered & GROIN))
					covered = TRUE
					break
				if (iter_clothing.clothing_flags & THICKMATERIAL)
					covered = TRUE
					break

			if (covered)
				continue

			var/obj/item/organ/external/genital/vagina/found_vagina = buckled_human.get_organ_slot(ORGAN_SLOT_VAGINA)
			var/obj/item/organ/external/genital/vagina/found_penis = buckled_human.get_organ_slot(ORGAN_SLOT_PENIS)

			var/do_message = FALSE
			if (!isnull(found_vagina))
				buckled_human.adjust_arousal(WASHING_MACHINE_VAGINA_AROUSAL * seconds_per_tick)
				do_message = TRUE
			if (!isnull(found_penis))
				buckled_human.adjust_arousal(WASHING_MACHINE_PENIS_AROUSAL * seconds_per_tick)
				do_message = TRUE
			if (do_message && SPT_PROB(20, seconds_per_tick))
				to_chat(buckled_human, span_userlove("[src] vibrates into your groin, and you feel a warm fuzzy feeling..."))

#undef WASHING_MACHINE_VAGINA_AROUSAL
#undef WASHING_MACHINE_PENIS_AROUSAL
