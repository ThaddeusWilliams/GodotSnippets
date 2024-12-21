extends NavigationRegion2D

func _process(delta):
	%NetworkSideDisplay.text = " Peers: " + str(multiplayer.get_peers().size()) + "\n" + Network.messages + str(Network.players)

func _on_host_pressed():
	Network.host()
	Network.player_spawn()
	#await get_tree().create_timer(1).timeout
	Network.player_spawn_others.rpc()
	Network.player_spawn_others()

func _on_join_pressed():
	Network.join()
	Network.player_spawn()
	await Network.multiplayer_peer.peer_connected#get_tree().create_timer(1).timeout
	Network.player_spawn_others.rpc()
	Network.player_spawn_others()

func _on_message_input_text_submitted(new_text):
	Network.message_send.rpc(new_text)
	Network.message_send(new_text)
	%MessageInput.text = ""

func _on_user_name_text_submitted(new_text):
	Network.username_set(Network.multiplayer_peer.get_unique_id(), new_text)
	Network.username_set.rpc(Network.multiplayer_peer.get_unique_id(), new_text)
	%UserName.editable = false
