extends Node
class_name NetworkManager

@export var connection_address : String = "127.0.0.1"
@export var connection_port : int = 1337

@export var network_spawner : NetworkSpawner
@export var peer_tracker : PeerTracker

@export var initial_player_scene : PackedScene
@export var player_spawn_arguments : Array[SpawnArgument] = []

@export var debugLabel1 : Label
@export var debugLabel2 : Label

var is_dedicaded_server : bool = false
static var instance : NetworkManager = null

signal player_scenes_created() #Maybe port this to main branch as well

func _enter_tree():
	instance = self

func _ready():
	multiplayer.peer_connected.connect(on_peer_connected)
	multiplayer.peer_disconnected.connect(on_peer_disconnected)
	var cmdline_user_args = OS.get_cmdline_user_args()
	print(cmdline_user_args)
	if "--dedicated" in cmdline_user_args:
		print("Running in dedicated server mode")
		is_dedicaded_server = true

func create_server() -> void:
	var peer : ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	peer.create_server(connection_port)
	set_network_peer(peer)
	peer_tracker.initialize_peer_list(multiplayer.get_unique_id())

func create_client() -> void:
	var peer : ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	peer.create_client(connection_address, connection_port)
	set_network_peer(peer)

func set_network_peer(peer : ENetMultiplayerPeer) -> void:
	multiplayer.multiplayer_peer = peer
	print(multiplayer.get_unique_id())
	debugLabel1.text = str(multiplayer.get_unique_id())

func create_players() -> void:
	create_players_rpc.rpc()

@rpc("authority", "call_local", "reliable", 0)
func create_players_rpc() -> void:
	if is_dedicaded_server and multiplayer.get_unique_id() == 1:
		return
	var current_player_entity = network_spawner.spawn_network_entity(initial_player_scene, player_spawn_arguments)
	peer_tracker.add_player_reference(current_player_entity)

	player_scenes_created.emit()

func on_peer_connected(peer_id : int) -> void:
	print("Peer with id " + str(peer_id) + " connected")
	if multiplayer.get_unique_id() == 1:
		peer_tracker.add_peer_to_list(peer_id)

func on_peer_disconnected(peer_id : int) -> void:
	print("Peer with id " + str(peer_id) + " disconnected")
	if multiplayer.get_unique_id() == 1:
		peer_tracker.remove_peer_from_list(peer_id)
