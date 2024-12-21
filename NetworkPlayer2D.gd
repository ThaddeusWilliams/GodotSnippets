#extends Human2D
extends CharacterBody2D

var is_player = false ## Always means that this is the player being controlled
var peer_id = 1 ## Unique id of Network.multiplayer_peer

func _ready():
	#name = str(get_multiplayer_authority())
	pass
func _process(delta):
	process_look()
	is_player = peer_id == Network.peer_get_id() or !Network.is_online
	$Label.text = str(peer_id)


func _physics_process(delta):
	if is_player:
		process_controls(delta)
		process_animations()
	process_net_code(delta)
	
func process_controls(delta = 1):
	$Camera2D.make_current()
	look_position = get_global_mouse_position()
	velocity = Input.get_vector("MoveLeft", "MoveRight", "MoveUp", "MoveDown") * speed * delta
	move_and_slide()
	
# NETWORK CODE
func process_net_code(delta):
	if is_player:
		Network.variable_set(str(peer_id) + ":position", position)
		#Network.variable_set(str(peer_id) + ":frame", rig.get_node("%Body").frame)
		#Network.variable_set(str(peer_id) + ":arm_front:angle", rig.get_node("%ArmFront").rotation)
		#Network.variable_set(str(peer_id) + ":arm_back:angle", rig.get_node("%ArmBack").rotation)
		#Network.variable_set(str(peer_id) + ":look_position", look_position)
	else:
		position = Network.variable_get(str(peer_id) + ":position", Vector2())
		#rig.get_node("%Body").frame = Network.variable_get(str(peer_id) + ":frame")
		#rig.get_node("%ArmFront").rotation = Network.variable_get(str(peer_id) + ":arm_front:angle")
		#rig.get_node("%ArmBack").rotation = Network.variable_get(str(peer_id) + ":arm_back:angle")
		#var look = Network.variable_get(str(peer_id) + ":look_position", Vector2())
		#look_position = look
