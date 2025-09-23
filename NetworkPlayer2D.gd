#extends Human2D
extends CharacterBody2D

var is_player = false ## Always means that this is the player being controlled
var peer_id = 1 ## Unique id of Network.multiplayer_peer

func _process(delta):
	is_player = (peer_id == Network.peer_get_id()) or !Network.is_online

func _physics_process(delta):
	%Label.text = "npeer id:"+str(Network.peer_get_id())+"\npeer id:" + str(peer_id) + "\ncount: "+str(Network.players.size()) +"\n"+ str(Network.multiplayer.get_peers())
	if !Network.is_online:
		if Input.is_action_just_pressed("HOST"):
			Network.host()
			Network.peer_id_assign(self, Network.peer_get_id())
		if Input.is_action_just_pressed("JOIN"):
			Network.join()
			Network.peer_id_assign(self, Network.peer_get_id())
	if is_player:
		velocity += Input.get_vector("ui_left","ui_right","ui_up","ui_down") * 50
		velocity /= 1.1
		Network.variable_set.rpc("position" + str(peer_id), global_position)
		move_and_slide()
	else:
		global_position = Network.variable_get("position" + str(peer_id), global_position)
