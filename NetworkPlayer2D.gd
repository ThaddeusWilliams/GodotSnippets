#extends Human2D
extends CharacterBody2D

var is_player = false ## Always means that this is the player being controlled
var peer_id = 1 ## Unique id of Network.multiplayer_peer

func _ready():
	#name = str(get_multiplayer_authority())
	pass
func _process(delta):
	is_player = peer_id == Network.peer_get_id() or !Network.is_online
	$Label.text = str(peer_id)


func _physics_process(delta):
	if is_player:
		process_controls(delta)
		process_animations()
		## Network portion of code
		$Camera2D.make_current()
		look_position = get_global_mouse_position()
		velocity = Input.get_vector("MoveLeft", "MoveRight", "MoveUp", "MoveDown") * speed * delta
		move_and_slide()
		Network.variable_set(str(peer_id) + ":position", position)
	else:
		position = Network.variable_get(str(peer_id) + ":position", Vector2())
		

