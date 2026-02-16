extends Node
class_name PeerTracker

@export var peer_ids : Array[int] #1 - 1; 2 - NNNNNNNNN (UID of peer 2); etc. maybe create a dict to map UID to normal ids quicker.. but for now I'm still lazy asf
@export var player_references : Array[Node]

signal peer_list_changed()
signal player_list_changed()
signal all_peer_players_created()

#Those should only be used on server, then synced to other peers
func initialize_peer_list(server_id : int):
	peer_ids.clear()
	peer_ids.append(server_id)

func add_peer_to_list(peer_id : int):
	peer_ids.append(peer_id)
	sync_peer_list.rpc(peer_ids)
	peer_list_changed.emit()

func remove_peer_from_list(peer_id : int):
	peer_ids.erase(peer_id)
	sync_peer_list.rpc(peer_ids)
	peer_list_changed.emit()

#On the contrary this one can be called on any peer, but AFTER the peer list has been composed
func add_player_reference(player_node : Node):
	var current_peer : int = multiplayer.get_unique_id()
	var player_reference_path : NodePath = get_path_to(player_node)
	add_player_reference_rpc.rpc(player_reference_path, current_peer)

@rpc("any_peer", "call_local", "reliable", 0)
func add_player_reference_rpc(player_reference_path : NodePath, player_peer : int):
	print("On peer " + str(multiplayer.get_unique_id()) + " adding player reference: " + str(player_reference_path) + " from peer " + str(player_peer))
	if player_peer in peer_ids:
		var peer_index = peer_ids.find(player_peer)
		if peer_index >= player_references.size():
			player_references.resize(peer_index + 1)
		player_references[peer_index] = get_node(player_reference_path)
		player_list_changed.emit()

		if peer_ids.size() == player_references.size():
			all_peer_players_created.emit()


@rpc("authority", "call_remote", "reliable", 0)
func sync_peer_list(new_peer_ids : Array[int]):
	peer_ids = new_peer_ids
	peer_list_changed.emit()
