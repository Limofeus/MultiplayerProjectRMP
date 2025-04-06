extends Node

@export var network_manager : NetworkManager

@export var connection_address_input : TextEdit
@export var connection_port_input : TextEdit

func _ready():
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

func set_connection_address() -> void:
	network_manager.connection_address = connection_address_input.text

func set_connection_port() -> void:
	network_manager.connection_port = int(connection_port_input.text)

func set_connection_address_string(address : String) -> void:
	network_manager.connection_address = address

func set_connection_port_string(port : String) -> void:
	network_manager.connection_port = int(port)
