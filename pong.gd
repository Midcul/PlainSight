extends Node2D

signal game_finished()

onready var player2 = $Player2


func _ready():
	# By default, all nodes in server inherit from master,
	# while all nodes in clients inherit from puppet.
	# set_network_master is tree-recursive by default.
	
	if get_tree().is_network_server():
		# For the server, give control of player 2 to the other peer.
		player2.set_network_master(get_tree().get_network_connected_peers()[0])

	else:
		# For the client, give control of player 2 to itself.
		player2.set_network_master(get_tree().get_network_unique_id())

	print("Unique id: ", get_tree().get_network_unique_id())
	
#	for _i in range(20):
#		var computer = preload('res://cpu.tscn').instance()
#		var xlocation = (randi() % 20) * 32 + 16
#		var ylocation = (randi() % 15) * 32 + 16
#		computer.position = Vector2(xlocation, ylocation)
#		add_child(computer)

#	$DebugLabel.add_color_override("font_color", Color(0, 0, 0, 1))
	
	
func _input(event):
	if event.is_action_pressed("click"):
		if event.position.x > $Player1.position.x - 16 and event.position.x < $Player1.position.x + 16:
			if event.position.y > $Player1.position.y - 16 and event.position.y < $Player1.position.y + 16:
				$Player1/Sprite.set_texture(preload("res://found.png"))
		if event.position.x > $Player2.position.x - 16 and event.position.x < $Player2.position.x + 16:
			if event.position.y > $Player2.position.y - 16 and event.position.y < $Player2.position.y + 16:
				$Player2/Sprite.set_texture(preload("res://found.png"))
	else:
		return


func _on_exit_game_pressed():
	emit_signal("game_finished")


# Position synchronization debugger
#func _process(_delta):
#	$DebugLabel.set_text(str($Player1.position) + str($Player2.position) + str(get_viewport().get_mouse_position()))
