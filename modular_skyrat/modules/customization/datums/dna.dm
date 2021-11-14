/datum/dna
	var/list/list/mutant_bodyparts = list()
	features = MANDATORY_FEATURE_LIST
	///Body markings of the DNA's owner. This is for storing their original state for re-creating the character. They'll get changed on species mutation
	var/list/list/body_markings = list()
	///Current body size, used for proper re-sizing and keeping track of that
	var/current_body_size = BODY_SIZE_NORMAL

/datum/dna/proc/initialize_dna(newblood_type, skip_index = FALSE)
	if(newblood_type)
		blood_type = newblood_type
	unique_enzymes = generate_unique_enzymes()
	unique_identity = generate_unique_identity()
	if(!skip_index) //I hate this
		generate_dna_blocks()
	features = species.get_random_features()
	mutant_bodyparts = species.get_random_mutant_bodyparts(features)
	unique_features = generate_unique_features()

/datum/dna/proc/generate_unique_features()
	var/list/data = list()

	if(features["mcolor"])
		data += sanitize_hexcolor(features["mcolor"])
	else
		data += random_string(DNA_BLOCK_SIZE,GLOB.hex_characters)
	if(features["mcolor2"])
		data += sanitize_hexcolor(features["mcolor2"])
	else
		data += random_string(DNA_BLOCK_SIZE,GLOB.hex_characters)
	if(features["mcolor3"])
		data += sanitize_hexcolor(features["mcolor3"])
	else
		data += random_string(DNA_BLOCK_SIZE,GLOB.hex_characters)
	if(features["ethcolor"])
		data += sanitize_hexcolor(features["ethcolor"])
	else
		data += random_string(DNA_BLOCK_SIZE,GLOB.hex_characters)
	if(features["skin_color"])
		data += sanitize_hexcolor(features["skin_color"])
	else
		data += random_string(DNA_BLOCK_SIZE,GLOB.hex_characters)
	for(var/key in GLOB.genetic_accessories)
		if(mutant_bodyparts[key] && (mutant_bodyparts[key][MUTANT_INDEX_NAME] in GLOB.genetic_accessories[key]))
			var/list/accessories_for_key = GLOB.genetic_accessories[key]
			data += construct_block(accessories_for_key.Find(mutant_bodyparts[key][MUTANT_INDEX_NAME]), accessories_for_key.len)
			var/colors_to_randomize = DNA_BLOCKS_PER_FEATURE-1
			for(var/color in mutant_bodyparts[key][MUTANT_INDEX_COLOR_LIST])
				colors_to_randomize--
				data += sanitize_hexcolor(color)
			if(colors_to_randomize)
				data += random_string(DNA_BLOCK_SIZE*colors_to_randomize,GLOB.hex_characters)
		else
			data += random_string(DNA_BLOCK_SIZE*DNA_BLOCKS_PER_FEATURE,GLOB.hex_characters)
	for(var/zone in GLOB.marking_zones)
		if(body_markings[zone])
			data += construct_block(body_markings[zone].len+1, MAXIMUM_MARKINGS_PER_LIMB+1)
			var/list/marking_list = GLOB.body_markings_per_limb[zone]
			var/markings_to_randomize = MAXIMUM_MARKINGS_PER_LIMB
			for(var/marking in body_markings[zone])
				markings_to_randomize--
				data += construct_block(marking_list.Find(marking), marking_list.len)
				data += sanitize_hexcolor(body_markings[zone][marking])
			if(markings_to_randomize)
				data += random_string(DNA_BLOCK_SIZE*markings_to_randomize*DNA_BLOCKS_PER_MARKING,GLOB.hex_characters)
		else
			data += construct_block(1, MAXIMUM_MARKINGS_PER_LIMB+1)
			data += random_string(DNA_BLOCK_SIZE*MAXIMUM_MARKINGS_PER_LIMB*DNA_BLOCKS_PER_MARKING,GLOB.hex_characters)
	return data.Join()

/datum/dna/proc/update_uf_block(blocknumber)
	if(!blocknumber)
		CRASH("UF block index is null")
	if(blocknumber<1 || blocknumber>DNA_FEATURE_BLOCKS)
		CRASH("UF block index out of bounds")
	if(!ishuman(holder))
		CRASH("Non-human mobs shouldn't have DNA")
	if(blocknumber <= DNA_MANDATORY_COLOR_BLOCKS)
		switch(blocknumber)
			if(DNA_MUTANT_COLOR_BLOCK)
				setblock(unique_features, blocknumber, sanitize_hexcolor(features["mcolor"]))
			if(DNA_MUTANT_COLOR_2_BLOCK)
				setblock(unique_features, blocknumber, sanitize_hexcolor(features["mcolor2"]))
			if(DNA_MUTANT_COLOR_3_BLOCK)
				setblock(unique_features, blocknumber, sanitize_hexcolor(features["mcolor3"]))
			if(DNA_ETHEREAL_COLOR_BLOCK)
				setblock(unique_features, blocknumber, sanitize_hexcolor(features["ethcolor"]))
			if(DNA_SKIN_COLOR_BLOCK)
				setblock(unique_features, blocknumber, sanitize_hexcolor(features["skin_color"]))
	else if(blocknumber <= DNA_MANDATORY_COLOR_BLOCKS+(GLOB.genetic_accessories.len*DNA_BLOCKS_PER_FEATURE))
		var/block_index = blocknumber - DNA_MANDATORY_COLOR_BLOCKS
		var/block_zero_index = block_index-1
		var/bodypart_index = (block_zero_index/DNA_BLOCKS_PER_FEATURE)+1
		var/color_index = block_zero_index%DNA_BLOCKS_PER_FEATURE
		var/key = GLOB.genetic_accessories[bodypart_index]
		if(mutant_bodyparts[key])
			var/list/color_list = mutant_bodyparts[key][MUTANT_INDEX_COLOR_LIST]
			if(color_index && color_index <= color_list.len)
				setblock(unique_features, blocknumber, sanitize_hexcolor(color_list[color_index]))
			else
				var/list/accessories_for_key = GLOB.genetic_accessories[key]
				if(mutant_bodyparts[key][MUTANT_INDEX_NAME] in accessories_for_key)
					setblock(unique_features, blocknumber, construct_block(mutant_bodyparts.Find(mutant_bodyparts[key][MUTANT_INDEX_NAME]), accessories_for_key.len))
	else
		var/block_index = blocknumber - (DNA_MANDATORY_COLOR_BLOCKS+(GLOB.genetic_accessories.len*DNA_BLOCKS_PER_FEATURE))
		var/block_zero_index = block_index-1
		var/zone_index = (block_zero_index/DNA_BLOCKS_PER_MARKING_ZONE)+1
		var/zone = GLOB.marking_zones[zone_index]
		if(blocknumber == GLOB.dna_body_marking_blocks[zone])
			var/markings = 0
			if(body_markings[zone])
				markings = body_markings[zone].len
			setblock(unique_features, blocknumber, construct_block(markings+1, MAXIMUM_MARKINGS_PER_LIMB+1))
		else
			var/color_block = ((block_zero_index%DNA_BLOCKS_PER_MARKING_ZONE)+1)%DNA_BLOCKS_PER_MARKING
			var/marking_index = (((block_zero_index-1)%DNA_BLOCKS_PER_MARKING_ZONE)/DNA_BLOCKS_PER_MARKING)+1
			if(body_markings[zone] && marking_index <= body_markings[zone].len)
				var/marking = body_markings[zone][marking_index]
				if(color_block)
					setblock(unique_features, blocknumber, sanitize_hexcolor(body_markings[zone][marking]))
				else
					var/list/marking_list = GLOB.body_markings_per_limb[zone]
					setblock(unique_features, blocknumber, construct_block(marking_list.Find(marking), marking_list.len))

/datum/dna/proc/update_body_size()
	if(!holder || species.body_size_restricted || current_body_size == features["body_size"])
		return
	var/change_multiplier = features["body_size"] / current_body_size
	//We update the translation to make sure our character doesn't go out of the southern bounds of the tile
	var/translate = ((change_multiplier-1) * 32)/2
	holder.transform = holder.transform.Scale(change_multiplier)
	holder.transform = holder.transform.Translate(0, translate)
	current_body_size = features["body_size"]

/mob/living/carbon/set_species(datum/species/mrace, icon_update = TRUE, var/list/override_features, var/list/override_mutantparts, var/list/override_markings, retain_features = FALSE, retain_mutantparts = FALSE)
	if(QDELETED(src))
		CRASH("You're trying to change your species post deletion, this is a recipe for madness")
	if(mrace && has_dna())
		var/datum/species/new_race
		if(ispath(mrace))
			new_race = new mrace
		else if(istype(mrace))
			new_race = mrace
		else
			return
		deathsound = new_race.deathsound
		dna.species.on_species_loss(src, new_race)
		var/datum/species/old_species = dna.species
		dna.species = new_race

		//BODYPARTS AND FEATURES - We need to instantiate the list with compatible mutant parts so we don't break things

		if(override_mutantparts && override_mutantparts.len)
			for(var/feature in dna.mutant_bodyparts)
				override_mutantparts[feature] = dna.mutant_bodyparts[feature]
			dna.mutant_bodyparts = override_mutantparts

		if(override_markings && override_markings.len)
			for(var/feature in dna.body_markings)
				override_markings[feature] = dna.body_markings[feature]
			dna.body_markings = override_markings

		if(override_features && override_features.len)
			for(var/feature in dna.features)
				override_features[feature] = dna.features[feature]
			dna.features = override_features
		//END OF BODYPARTS AND FEATURES

		apply_customizable_dna_features_to_species()
		dna.unique_features = dna.generate_unique_features()

		dna.update_body_size()

		dna.species.on_species_gain(src, old_species)


		if(ishuman(src))
			qdel(language_holder)
			var/species_holder = initial(mrace.species_language_holder)
			language_holder = new species_holder(src)
		update_atom_languages()


/mob/living/carbon/proc/apply_customizable_dna_features_to_species()
	if(!has_dna())
		CRASH("[src] does not have DNA")
	dna.species.body_markings = dna.body_markings.Copy()
	var/list/bodyparts_to_add = dna.mutant_bodyparts.Copy()
	for(var/key in bodyparts_to_add)
		if(GLOB.sprite_accessories[key] && bodyparts_to_add[key] && bodyparts_to_add[key][MUTANT_INDEX_NAME])
			var/datum/sprite_accessory/SP = GLOB.sprite_accessories[key][bodyparts_to_add[key][MUTANT_INDEX_NAME]]
			if(!SP?.factual)
				bodyparts_to_add -= key
				continue
	dna.species.mutant_bodyparts = bodyparts_to_add.Copy()

/mob/living/carbon/human/updateappearance(icon_update=1, mutcolor_update=0, mutations_overlay_update=0)
	..()
	var/structure = dna.unique_identity
	hair_color = sanitize_hexcolor(getblock(structure, DNA_HAIR_COLOR_BLOCK))
	facial_hair_color = sanitize_hexcolor(getblock(structure, DNA_FACIAL_HAIR_COLOR_BLOCK))
	skin_tone = GLOB.skin_tones[deconstruct_block(getblock(structure, DNA_SKIN_TONE_BLOCK), GLOB.skin_tones.len)]
	eye_color = sanitize_hexcolor(getblock(structure, DNA_EYE_COLOR_BLOCK))
	facial_hairstyle = GLOB.facial_hairstyles_list[deconstruct_block(getblock(structure, DNA_FACIAL_HAIRSTYLE_BLOCK), GLOB.facial_hairstyles_list.len)]
	hairstyle = GLOB.hairstyles_list[deconstruct_block(getblock(structure, DNA_HAIRSTYLE_BLOCK), GLOB.hairstyles_list.len)]
	var/features = dna.unique_features
	if(dna.features["mcolor"])
		dna.features["mcolor"] = sanitize_hexcolor(getblock(features, DNA_MUTANT_COLOR_BLOCK))
	if(dna.features["mcolor2"])
		dna.features["mcolor2"] = sanitize_hexcolor(getblock(features, DNA_MUTANT_COLOR_2_BLOCK))
	if(dna.features["mcolor3"])
		dna.features["mcolor3"] = sanitize_hexcolor(getblock(features, DNA_MUTANT_COLOR_3_BLOCK))
	if(dna.features["ethcolor"])
		dna.features["ethcolor"] = sanitize_hexcolor(getblock(features, DNA_ETHEREAL_COLOR_BLOCK))
	if(dna.features["skin_color"])
		dna.features["skin_color"] = sanitize_hexcolor(getblock(features, DNA_SKIN_COLOR_BLOCK))

	if(icon_update)
		dna.species.handle_body(src) // We want 'update_body_parts()' to be called only if mutcolor_update is TRUE, so no 'update_body()' here.
		update_hair()
		if(mutcolor_update)
			update_body_parts()
		if(mutations_overlay_update)
			update_mutations_overlay()
