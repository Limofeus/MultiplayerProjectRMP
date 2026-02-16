extends Node
class_name NetworkStatsDebugMonitor

#NO OWD, ONLY RTT monitoring

const RTT_HISTORY_SIZE : int = 100
const RTT_REQUEST_DELAY_MSEC : int = 100

const PACKET_LOSS_THRESHOLD_MSEC : int = 10000
const PACKET_LOSS_THRESHOLD_COUNT : int = 20 #If there are N new packets, older packets are considered lost

var _send_pings : bool = false

var _current_packet_index : int = 0 #therefore rtt_history end index
var _sent_packets : Dictionary[int, int] = {} #packet_index > timestamp
var _other_peer_ids : Array = []
var _peer_rtt_histories : Dictionary[int, Array] = {} #null = pending, -1 = lost ||| [0] = latest packet, [99] = oldest

var _ping_timer : float = 0.0

func _process(delta : float) -> void:
	if _send_pings:
		_ping_timer += delta
		if _ping_timer * 1000.0 > RTT_REQUEST_DELAY_MSEC:
			_ping_timer -= RTT_REQUEST_DELAY_MSEC / 1000.0
			send_ping()

func request_stat_monitoring_reset() -> void:
	print("NET STAT MONITOR RESET REQUESTED on peer " + str(multiplayer.get_unique_id()))
	reset_stat_monitoring.rpc(true)

func send_ping() -> void:
	receive_ping.rpc(multiplayer.get_unique_id(), _current_packet_index)
	_sent_packets[_current_packet_index] = Time.get_ticks_msec()
	increment_ping_history()

func increment_ping_history() -> void:
	_current_packet_index += 1
	for peer_history in _peer_rtt_histories.values():
		peer_history.pop_back()
		peer_history.push_front(null)

func get_net_stat_data() -> Dictionary:
	var net_stat_data : Dictionary[int, Dictionary] = {}
	for peer_id in _other_peer_ids:
		net_stat_data[peer_id] = get_peer_data(peer_id)
	return net_stat_data

func get_peer_data(peer_id : int) -> Dictionary:
	var peer_data : Dictionary[String, Variant] = {}
	var ping_avg : float = 0.0
	var ping_max : float = 0.0
	var packets_received : int = 0
	var packets_lost : int = 0
	var loss_percent : float = 0.0
	for packet_info in _peer_rtt_histories[peer_id]:
		if packet_info != null and packet_info >= 0:
			ping_avg += packet_info
			ping_max = max(ping_max, packet_info)
			packets_received += 1
		if packet_info == -1:
			packets_lost += 1
	var packets_total = packets_received + packets_lost
	loss_percent = packets_lost * 100.0 / packets_total
	peer_data["ping_avg"] = ping_avg / packets_received
	peer_data["ping_max"] = ping_max
	peer_data["packets_received"] = packets_received
	peer_data["packets_lost"] = packets_lost
	peer_data["loss_percent"] = loss_percent
	return peer_data

@rpc("reliable", "call_local", "any_peer")
func reset_stat_monitoring(send_pings : bool) -> void:
	_current_packet_index = 0
	var other_peers : = Array(multiplayer.get_peers())
	other_peers.erase(multiplayer.get_unique_id())
	_other_peer_ids = other_peers
	
	var rtt_history_array : Array = []
	rtt_history_array.resize(RTT_HISTORY_SIZE)
	for peer in other_peers:
		_peer_rtt_histories[peer] = rtt_history_array.duplicate(false)

	_send_pings = send_pings

@rpc("unreliable", "call_remote", "any_peer")
func receive_ping(sender_peer_id : int, packet_index : int) -> void:
	receive_pong.rpc_id(sender_peer_id, multiplayer.get_unique_id(), packet_index)

@rpc("unreliable", "call_remote", "any_peer")
func receive_pong(remote_peer_id : int, packet_index : int) -> void:
	if !_other_peer_ids.has(remote_peer_id):
		return
	if _sent_packets.has(packet_index):
		var rtt = Time.get_ticks_msec() - _sent_packets[packet_index]
		var history_index = _current_packet_index - packet_index - 1
		if history_index >= RTT_HISTORY_SIZE:
			print("PING EXCEEDED RTT HISTORY SIZE")
			return
		_peer_rtt_histories[remote_peer_id][history_index] = rtt

		update_lost_packets(remote_peer_id)

func update_lost_packets(peer_index : int) -> void:
	var received_peer_packets : int = 0
	for i in range(RTT_HISTORY_SIZE):
		var packet_info = _peer_rtt_histories[peer_index][i]
		
		if packet_info != null and packet_info >= 0:
			received_peer_packets += 1

		if packet_info == -1:
			return

		if received_peer_packets >= PACKET_LOSS_THRESHOLD_COUNT and packet_info == null:
			_peer_rtt_histories[peer_index][i] = -1
