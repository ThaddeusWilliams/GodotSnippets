## ALWAYS LOAD IN "Globals"
extends Node

@onready var multiplayer_peer = ENetMultiplayerPeer.new()

const net_port = 3200
const net_address = "localhost" # localhost
var usernames = {}
var players = {} ## Keeps track of all the player instances spawned
var messages = ""
var variables = {}
var is_online = false

signal message_sent(type: MessageType, text) ## For sending messages/notifications 
enum MessageType {
	MESSAGE_TYPE_SYSTEM, MESSAGE_TYPE_PLAYER
}

func _ready():
	multiplayer_peer.peer_disconnected.connect(_peer_disconnected)

func _peer_disconnected(id):
	players[id].queue_free()
	if peer_get_id() == 1:
		is_online = false

func _message_sent(type, text):
	messages += text

func host():
	var error = multiplayer_peer.create_server(net_port, 6)
	if error == OK:
		is_online = true
	multiplayer.multiplayer_peer = multiplayer_peer
	message_sent.emit(0, "Host = " + str(peer_get_id))
	

func join():
	var error = multiplayer_peer.create_client(net_address, net_port)
	if error == OK:
		is_online = true
	multiplayer.multiplayer_peer = multiplayer_peer
	message_sent.emit(0, "Client = " + str(peer_get_id))

@rpc("any_peer","reliable") func username_set(id, uname: String):
	usernames[id] = uname

@rpc("any_peer","reliable") func message_send(message: String):
	messages += "\n" + message

@rpc("any_peer","reliable") func player_spawn(peer_id = peer_get_id()):
	var p = preload("res://actors/human/player/player.tscn")
	var player = p.instantiate()
	player.peer_id = peer_id
	add_child(player)
	players[peer_id] = player

@rpc("any_peer","reliable") func player_spawn_others():
	for i in multiplayer.get_peers():
		player_spawn(i)

@rpc("any_peer","unreliable") func node_properties_update(from: Node, to: Node, _only_use = []):
	for property in from.get_property_list():
		var pname = property.name
		# Check if the variable exists in BOTH Nodes, and if it's not readonly
		if pname in from && pname in to && typeof(from[pname]) in [TYPE_COLOR, TYPE_BOOL, TYPE_FLOAT, TYPE_INT, TYPE_VECTOR2, TYPE_STRING] : 
			# Check for only required variables if any specified
			if pname in _only_use or _only_use.is_empty():
				# Apply the property from From to To
				var pvalue = from[pname]
				to[pname] = pvalue

@rpc("any_peer","reliable") func _variable_set(vid, value):
	variables[vid] = value

@rpc("any_peer","unreliable") func _variable_set_unreliable(vid, value):
	variables[vid] = value


func variable_set(vid, value, _reliable = true):
	variables[vid] = value
	if _reliable:
		_variable_set.rpc(vid, value)
	else:
		_variable_set_unreliable(vid, value)

func variable_get(vid, _def = 0):
	if vid in variables:
		return variables[vid]
	return _def

func peer_get_index(): ## return the actual index of the multiplayer_peer unique id inside the list of peers
	if !is_online:
		return 0
	return multiplayer.get_peers().find(multiplayer_peer.get_unique_id())

func peer_get_id(): ## Shorthand for 'multiplayer_peer.get_unique_id()'
	if !is_online:
		return 1
	return multiplayer_peer.get_unique_id()

func id_shorten(id): ## Returns a multiplayer_peer unique id but smaller
	var result = str(id)
	for x in range(9):
		for y in range(9):
			result = result.replace(str(x) + str(y), "" )
	return result
