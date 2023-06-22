extends Area2D

var horz : int
var vert : int

onready var _screen_size_y = get_viewport_rect().size.y
onready var _screen_size_x = get_viewport_rect().size.x

var random = RandomNumberGenerator.new()
var counter = 0
var countertarget = 0


func _ready():
	random.randomize()


func _process(_delta):
	# Check for overlapping bodies and highlight if overlap occurs
	# TODO (logic): Player hiding behind cpu should be selectable
	if len(get_overlapping_areas()) > 0:
		$Sprite.set_texture(preload('res://overlap.png'))
	else:
		$Sprite.set_texture(preload('res://square.png'))
	
	# Breakpoint: Host should determine all cpu movement
	if not is_network_master():
		return
		
	if counter >= countertarget:
		horz = random.randi_range(-1, 1)
		vert = random.randi_range(-1, 1)
		
		position += Vector2(horz*32, vert*32)

		counter = 0
		countertarget = random.randi_range(30, 120)
	
	counter += 1

	# Set screen limits.
	position.y = clamp(position.y, 16, _screen_size_y - 16)
	position.x = clamp(position.x, 16, _screen_size_x - 16)
	
	# Using unreliable to make sure position is updated as fast
	# as possible, even if one of the calls is dropped.
	rpc_unreliable("set_pos", position)
	

puppet func set_pos(pos):
	position = pos
	
