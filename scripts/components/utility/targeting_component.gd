extends EntityComponent
class_name TargetingComponent

func find_same_team_creatures(finder_attributes : CreatureAttributes, filter_authoritative_entities : bool = true) -> Array[CreatureAttributes]:
	var same_team_lambda = func(l_finder_attributes : CreatureAttributes, l_target_attributes : CreatureAttributes) -> bool:
		return l_finder_attributes.team_id == l_target_attributes.team_id and l_finder_attributes != l_target_attributes
	return find_creatures_with_function(finder_attributes, same_team_lambda, filter_authoritative_entities)

func find_different_team_creatures(finder_attributes : CreatureAttributes, filter_authoritative_entities : bool = true) -> Array[CreatureAttributes]:
	var different_team_lambda = func(l_finder_attributes : CreatureAttributes, l_target_attributes : CreatureAttributes) -> bool:
		return l_finder_attributes.team_id != l_target_attributes.team_id
	return find_creatures_with_function(finder_attributes, different_team_lambda, filter_authoritative_entities)

func find_creatures_with_function(finder_attributes : CreatureAttributes, filter_function : Callable, filter_authoritative_entities : bool = true) -> Array[CreatureAttributes]:
	var creature_array = get_tree().get_nodes_in_group("Creature")
	var return_array : Array[CreatureAttributes] = []
	for creature in creature_array:
		if creature is CreatureAttributes:
			if filter_function.call(finder_attributes, creature) and ((!filter_authoritative_entities) or check_creature_by_authority(creature)):
				return_array.append(creature)
	return return_array #Maybe also add a backup array, if no same peer entities were found, right now you'll have to do 2 searches for that, but WHO CARES LOL, also: maybe consider SWITCHING A PEER if you want to target other peers entities

func check_creature_by_authority(creature_attributes : CreatureAttributes) -> bool:
	return creature_attributes.is_multiplayer_authority()

	#Uses in engine function because it's faster
	#Alternative way to do this through entity's authority check method:

	#return StaticNetworkUtility.get_network_entity_from_node(creature_attributes).has_authority()

	#TODO: Contemplate...