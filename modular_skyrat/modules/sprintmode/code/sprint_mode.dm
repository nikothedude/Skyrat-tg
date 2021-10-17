#define SPRINT_MODE_COOLDOWN 25 SECONDS
GLOBAL_VAR_INIT(sprint_mode_overlay, GenerateSprintOverlay())

/proc/GenerateSprintOverlay()
	var/mutable_appearance/sprint_indicator = mutable_appearance('modular_skyrat/modules/indicators/icons/combat_indicator.dmi', "combat", FLY_LAYER) //placeholder icon
	sprint_indicator.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA | KEEP_APART
	return sprint_indicator

/mob/living/proc/sprint_mode_unconscious_signal()
	SIGNAL_HANDLER
	set_sprint_mode(FALSE)

/mob/living
	var/sprint_indicator = FALSE
	var/sprint_mode = FALSE
	var/nextsprintactivation = 0

/mob/living/proc/set_sprint_mode(state)
	if(stat == DEAD)
		sprint_mode = FALSE

	if(sprint_mode == state)
		return

	sprint_mode = state

	if(sprint_mode)
		if(world.time > nextsprintactivation)
			nextsprintactivation = world.time + SPRINT_MODE_COOLDOWN
			playsound(src, 'sound/machines/chime.ogg', 10, ignore_walls = FALSE)
			flick_emote_popup_on_mob("combat", 20)
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
