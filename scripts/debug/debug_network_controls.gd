extends Node

@export var network_manager : NetworkManager
@export var peer_tracker : PeerTracker

@export var debug_net_label : Label

@export var net_stat_debug_monitor : NetworkStatsDebugMonitor
@export var nsd_peer_label : Label
@export var nsd_ping_avg_label : Label
@export var nsd_ping_max_label : Label
@export var nsd_loss_label : Label

func _ready():
	network_manager.network_peer_set.connect(_on_network_peer_set)
	network_manager.player_scenes_created.connect(_on_players_created)
	print("[" + str(Time.get_unix_time_from_system() * 1000) + ", " + str(multiplayer.get_unique_id()) + "]" + "ready")

func _process(_delta)->void:
	ImGui.Begin("Debug Network Controls")
	if ImGui.Button("Create Server"):
		network_manager.create_server()
	if ImGui.Button("Create Client"):
		network_manager.create_client()
	if ImGui.Button("Start Game"):
		network_manager.create_players()
	if ImGui.Checkbox("Dedicated server", [network_manager.is_dedicaded_server]):
		network_manager.is_dedicaded_server = !network_manager.is_dedicaded_server
	ImGui.End()

func set_connection_address_string(address : String) -> void:
	network_manager.connection_address = address

func set_connection_port_string(port : String) -> void:
	network_manager.connection_port = int(port)

func update_net_stat_debug_info() -> void:
	var net_stats : Dictionary = net_stat_debug_monitor.get_net_stat_data()
	nsd_peer_label.text = "Peer"
	nsd_ping_avg_label.text = "ms (10s avg)"
	nsd_ping_max_label.text = "ms (10s max)"
	nsd_loss_label.text = "loss %"
	for peer_id in net_stats.keys():
		nsd_peer_label.text += "\n" + str(peer_id).right(2)
		nsd_ping_avg_label.text += "\n" + ("%.0f" % net_stats[peer_id]["ping_avg"])
		nsd_ping_max_label.text += "\n" + ("%.0f" % net_stats[peer_id]["ping_max"])
		nsd_loss_label.text += "\n" + ("%.1f" % net_stats[peer_id]["loss_percent"])

func _on_network_peer_set():
	debug_net_label.text = str(multiplayer.get_unique_id())

func _on_players_created():
	if multiplayer.get_unique_id() != 1:
		return
	net_stat_debug_monitor.request_stat_monitoring_reset()
