/datum/movespeed_modifier/sprint
	multiplicative_slowdown = -0.25

/datum/status_effect/sprinting
	id = "sprinting"
	duration = 70
	tick_interval = 1
	var/steps_taken = 0

/datum/status_effect/sprinting/on_apply()
	. = ..()
	owner.add_movespeed_modifier(/datum/movespeed_modifier/sprint)

/datum/status_effect/sprinting/tick()



/datum/status_effect/sprinting/on_remove()
	. = ..()
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/sprint)

