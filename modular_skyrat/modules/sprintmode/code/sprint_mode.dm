#define SPRINT_MODE_COOLDOWN 25 SECONDS
GLOBAL_VAR_INIT(sprint_mode_overlay, GenerateSprintOverlay())

/proc/GenerateSprintOverlay()
	var/mutable_appearance/sprint_indicator = mutable_appearance('modular_skyrat/modules/indicators/icons/combat_indicator.dmi', "combat", FLY_LAYER) //placeholder icon
	sprint_indicator.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA | KEEP_APART
	return sprint_indicator

/mob/living
	var/sprint_indicator = FALSE
	var/sprint_mode = FALSE
	var/nextsprintactivation = 0

 /* /mob/living/proc/sprint_mode_unconscious_signal()
	SIGNAL_HANDLER
	set_sprint_mode(FALSE) */

/mob/living/proc/set_sprint_mode(state)
	var/sprint_lock_time = 3.5 SECONDS //how long you are locked in place for after toggling sprint on + how long the do_after takes
	var/sprint_length = 10.5 SECONDS//how long sprint lasts for

	if(stat == DEAD)
		sprint_mode = FALSE

	if(sprint_mode == state)
		return

	sprint_mode = state

	if(sprint_mode)
		if(world.time > nextsprintactivation)
			nextsprintactivation = world.time + SPRINT_MODE_COOLDOWN //TODO: change this so it only increases cooldown after it ends
			playsound(src, 'sound/machines/chime.ogg', 10, ignore_walls = FALSE)
			flick_emote_popup_on_mob("combat", 20)
			if(sprint_lock_time)
				ADD_TRAIT(src, TRAIT_IMMOBILIZED, type)
				sleep(sprint_lock_time)
				REMOVE_TRAIT(src, TRAIT_IMMOBILIZED, type)
			if(issilicon(src))
				visible_message(span_boldwarning("[src]'s motors begin to sharply whine, as its engine prepares for overdrive...")) //todo: add section for when sprint activates
			if(isalien(src))
				visible_message(span_boldwarning("[src] suddenly hunches over, firmly planting [p_their()] legs onto the ground..."))
			if(ishuman(src) && src.usable_legs == 2)
				visible_message(span_boldwarning("[src] suddenly hunches over, firmly planting [p_their()] legs onto the ground..."))
			else if(ishuman(src) && (src.usable_legs == 1))
				visible_message(span_boldwarning("[src] suddenly hunches over, shifting their body backwards, and their arms backward..."))
			else if(ishuman(src) && (src.usable_legs == 0))
				visible_message(span_boldwarning("[src] suddenly pushes themself off the ground and grips the ground tightly as they lean their body back and arms forward..."))
			else if((ishuman(src)) && !(src.usable_legs && src.usable_hands))
				visible_message(span_boldwarning("[src] takes a deep breath, closing their eyes and arching their chest upward..."))
			else
				visible_message(span_boldwarning("[src] gets ready to sprint..."))
			add_overlay(GLOB.sprint_mode_overlay)
			sprint_mode = TRUE
			src.log_message("<font color='red'>has toggled sprint!</font>", LOG_ATTACK)
	//		RegisterSignal(src, COMSIG_LIVING_STATUS_UNCONSCIOUS, .proc/sprint_mode_unconscious_signal)

			sleep(sprint_length) //todo: end sprint apon being inhibited



		else
			to_chat(usr, span_warning("You can't sprint just yet!"))
