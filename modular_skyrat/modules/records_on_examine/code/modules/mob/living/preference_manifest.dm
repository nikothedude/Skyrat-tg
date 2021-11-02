/datum/interactions_manifest

/datum/datacore/proc/get_interactions_manifest()
	var/list/int_manifest_out = list()
	for(var/datum/job_department/department as anything in SSjob.joinable_departments)
		int_manifest_out[department.department_name] = list()
	int_manifest_out[DEPARTMENT_UNASSIGNED] = list()

	var/list/departments_by_type = SSjob.joinable_departments_by_type
	for(var/datum/data/record/general_record in GLOB.data_core.general)
		var/name = general_record.fields["name"]
		var/rank = general_record.fields["rank"]
		var/truerank = general_record.fields["truerank"] // SKYRAT EDIT ADD - ALT TITLES
		var/interaction_preferences = general_record.fields["interaction_prefs"]
		var/datum/job/job = SSjob.GetJob(truerank) // SKYRAT EDIT - ORIGINAL CALLED GetJob(rank)
		var/interaction_preferences_empty = (length(interaction_preferences) < 2)
		if(!job || !(job.job_flags & JOB_CREW_MANIFEST) || !LAZYLEN(job.departments_list) && (!interaction_preferences_empty)) // In case an unlawful custom rank is added.
			var/list/int_misc_list = int_manifest_out[DEPARTMENT_UNASSIGNED]
			int_misc_list[++int_misc_list.len] = list(
				"name" = name,
				"rank" = rank,
				"truerank" = truerank,
				"interaction_prefs" = interaction_preferences,
				)
			continue
		for(var/department_type as anything in job.departments_list)
			var/datum/job_department/department = departments_by_type[department_type]
			if(!department)
				stack_trace("get_interactions_manifest() failed to get job department for [department_type] of [job.type]")
				continue
			if(interaction_preferences_empty)
				continue
			var/list/int_entry = list(
				"name" = name,
				"rank" = rank,
				"truerank" = truerank,
				"interaction_prefs" = interaction_preferences,
				)
			var/list/int_department_list = int_manifest_out[department.department_name]
			if(istype(job, department.department_head))
				int_department_list.Insert(1, null)
				int_department_list[1] = int_entry
			else
				int_department_list[++int_department_list.len] = int_entry

	// Trim the empty categories.
	for (var/department in int_manifest_out)
		if(!length(int_manifest_out[department]))
			int_manifest_out -= department

	return int_manifest_out

/datum/interactions_manifest/ui_state(mob/user)
	return GLOB.always_state

/datum/interactions_manifest/ui_status(mob/user, datum/ui_state/state)
	return (is_special_character(user)) ? UI_INTERACTIVE : UI_CLOSE

/datum/interactions_manifest/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "InteractionsManifest")
		ui.open()

/datum/interactions_manifest/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	if(action == "show_interaction_preferences")
		var/interactions_id = params["interactions_id"]
		var/datum/data/record/interactions_record = find_record("name", interactions_id, GLOB.data_core.general)
		to_chat(usr, "<b>Interaction Preferences:</b> [interactions_record.fields["interaction_prefs"]] You can ask this person for clarification in LOOC of their preferences! Remember: Only messages prefixed with INTPREF are bound by policy.")

/datum/interactions_manifest/ui_data(mob/user)
	var/list/positions = list()
	for(var/datum/job_department/department as anything in SSjob.joinable_departments)
		var/list/exceptions = list()
		for(var/datum/job/job as anything in department.department_jobs)
			if(job.total_positions == -1)
				exceptions += job.title
				continue
		positions[department.department_name] = list("exceptions" = exceptions)

	return list(
		"manifest" = GLOB.data_core.get_interactions_manifest(),
		"positions" = positions
	)
