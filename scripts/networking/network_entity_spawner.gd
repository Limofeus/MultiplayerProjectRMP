extends Node
class_name NetworkSpawner

const SPAWN_CHANNEL = 0

static var spawner_singleton : NetworkSpawner

@export var spawn_parent : Node
@export var add_as_singleton : bool = false

var object_spawn_increment : int = 0

func _ready():
	#Might try singleton approach later, several spawner nodes should work tho
	#Forget it, it'll mess up the hierarchy
	if add_as_singleton:
		spawner_singleton = self

func custom_spawn_functiuon(custom_spawn_object : Variant) -> Node:
	if(custom_spawn_object == null):
		push_warning("Hey, you're trying to spawn a null object! hope you know what you're doing boy, cus this will probably just throw an error")

	print("Curr net id: "+str(multiplayer.get_unique_id()))
	print("[" + str(Time.get_unix_time_from_system() * 1000) + ", " + str(multiplayer.get_unique_id()) + "]" + "2) custom_spawn_object is: " + str(custom_spawn_object))
	var instantiated_scene = null

	if custom_spawn_object is PackedScene:
		print("Instantiating packed scene...")
		instantiated_scene = custom_spawn_object.instantiate()
	elif custom_spawn_object is String:
		print("decoding by path...")
		print("object path: " + custom_spawn_object)
		var decoded_spawn_object = ResourceLoader.load(custom_spawn_object, "PackedScene", ResourceLoader.CACHE_MODE_REUSE)
		print("decoded_spawn_object: " + str(decoded_spawn_object))
		instantiated_scene = decoded_spawn_object.instantiate()

	if(instantiated_scene == null):
		print("instantiated_scene is null!")
	spawn_parent.add_child(instantiated_scene) #TODO: Maybe need to call add_child after done tinkering with authority to prevent _ready calls on Owner logic before entity actually recieves proper authority
	return instantiated_scene #(see above) confirmed bug? all nodes have authority of 1 when their _ready is called

@rpc("reliable", "call_remote", "any_peer", SPAWN_CHANNEL)
func spawn_rpc(custom_spawn_object : Variant, authority_to_set : int, int_name_addition : int = 0) -> void:
	var spawned_object : Node = custom_spawn_functiuon(custom_spawn_object)
	spawned_object.name += "_" + str(authority_to_set) + "_" + str(int_name_addition) + "_0" #Godot's default automatic naming increment does not suffice for preventing name conflicts with such spawning system
	if spawned_object is NetworkEntity:
		spawned_object.set_entity_authority(authority_to_set)

		#Entity was propagated from other peer, call entity_ready

		spawned_object.emit_entity_ready()

	else:
		spawned_object.set_multiplayer_authority(authority_to_set, true)

#[resolved] Peer that spawned the object will be authority! (Might not be desired, make it later so that it depends on the entity (call something inside of the entity))
func spawn_network_entity(network_entity : PackedScene, spawn_arguments : Array[SpawnArgument] = []) -> NetworkEntity:
	print("Curr net id: "+ str(multiplayer.get_unique_id()))

	if(network_entity == null):
		print("network_entity is null")

	print("[" + str(Time.get_unix_time_from_system() * 1000) + ", " + str(multiplayer.get_unique_id()) + "]" + "1) custom_spawn_object is: " + str(network_entity))

	var this_entity : NetworkEntity = custom_spawn_functiuon(network_entity)

	if(this_entity == null):
		print("this_entity is null")

	var desired_authority : int = this_entity.get_desired_authority() #TODO: Add an alternate way to set desired authority (e.g. as function argument)

	this_entity.name += "_" + str(desired_authority) + "_" + str(object_spawn_increment) + "_0"
	this_entity.set_entity_authority(desired_authority)
	spawn_rpc.rpc(network_entity.resource_path, desired_authority, object_spawn_increment)

	object_spawn_increment += 1 #Helps prevent name conflicts

	#Propagate to other peers via rpc, then call entity_ready
	this_entity.emit_entity_ready()

	this_entity.fire_spawn_logic(spawn_arguments)
	#Arguments apply AFTER entity ready, this way... Idk entity_ready will be called immidiatly after spawn and arguments will only be called on owner peer that spawned the entity (then it should propagate to other peers)
	#Looking back at it.. I kinda regret this.. 
	#TODO: In YOLO ai it'll also be benefitial to fire this args before entity ready or something idk

	print("[" + str(Time.get_unix_time_from_system() * 1000) + ", " + str(multiplayer.get_unique_id()) + "]" + this_entity.name + " has been spawned")
	
	return this_entity

#I think this function is abandoned?
func custom_spawn(custom_spawn_object : Variant):
	var this_object = custom_spawn_functiuon(custom_spawn_object)
	spawn_rpc.rpc(custom_spawn_object, multiplayer.get_unique_id())

	print(this_object.name + " has been spawned")
	this_object.set_multiplayer_authority(multiplayer.get_unique_id(), true)
	return this_object
