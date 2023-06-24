extends Area2D

var _you_hidden = false
var xlocation : int
var ylocation : int
var random = RandomNumberGenerator.new()

onready var _screen_size_y = get_viewport_rect().size.y
onready var _screen_size_x = get_viewport_rect().size.x


func _ready():
	random.randomize()
	xlocation = (random.randi() % 20) * 32 + 16
	ylocation = (random.randi() % 15) * 32 + 16
	position = Vector2(xlocation, ylocation)
	set_process_input(true)


func _input(event):
	if is_network_master():
		if event.is_action_pressed("move_up"):
			position += Vector2.UP * 32
		elif event.is_action_pressed("move_down"):
			position += Vector2.DOWN * 32
		elif event.is_action_pressed("move_left"):
			position += Vector2.LEFT * 32
		elif event.is_action_pressed("move_right"):
			position += Vector2.RIGHT * 32
		else:
			return
		if not _you_hidden:
			_hide_you_label()


func _process(_delta):
	# Is the master of the paddle.
	if is_network_master():
		# Using unreliable to make sure position is updated as fast
		# as possible, even if one of the calls is dropped.
		rpc_unreliable("set_identity", position)
	else:
		if not _you_hidden:
			_hide_you_label()

	# Set screen limits.
	position.y = clamp(position.y, 16, _screen_size_y - 16)
	position.x = clamp(position.x, 16, _screen_size_x - 16)


# Synchronize position to the other peers.
# CURRENT BUG - Texture of other player disappears completely (no texture)
# Though the texture-setting call goes through when testing with preload(square)
puppet func set_identity(pos):
	position = pos


func _hide_you_label():
	_you_hidden = true
	get_node("You").hide()


#func _on_Paddle_input_event(_viewport, event, _shape_idx):
#	if event is InputEventMouseButton and event.pressed:
#		$Sprite.set_texture(preload("res://found.png"))
