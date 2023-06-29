extends Control

# Default game server port. Can be any number between 1024 and 49151.
# Not on the list of registered or common ports as of November 2020:
# https://en.wikipedia.org/wiki/List_of_TCP_and_UDP_port_numbers
const DEFAULT_PORT = 8910

onready var address = $Address
onready var host_button = $HostButton
onready var join_button = $JoinButton
onready var status_ok = $StatusOk
onready var status_fail = $StatusFail
onready var port_forward_label = $PortForward
onready var find_public_ip_button = $FindPublicIP
onready var player_tracker = $PlayerTracker
onready var playername = $Name

var peer = null
var players = []


func _ready():
	# Connect all the callbacks related to networking.
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")

#### Network callbacks from SceneTree ####

# Callback from SceneTree.
# Players already in lobby - send nicknames to new players joining
func _player_connected(_id):
	rpc("_add_self", playername.get_text())


remotesync func _add_self(nickname):
	players.append(nickname)
	rpc("_update_player_list")


func _player_disconnected(_id):
	if get_tree().is_network_server():
		_end_game("Client disconnected")
	else:
		_end_game("Server disconnected")


# Callback from SceneTree, only for clients (not server).
# New player - see who else is in the lobby
func _connected_ok():
	_update_player_list()


# Callback from SceneTree, only for clients (not server).
func _connected_fail():
	_set_status("Couldn't connect", false)

	get_tree().set_network_peer(null) # Remove peer.
	host_button.set_disabled(false)
	join_button.set_disabled(false)


func _server_disconnected():
	_end_game("Server disconnected")

##### Game creation functions ######

func _end_game(with_error = ""):
	if has_node("/root/Pong"):
		# Erase immediately, otherwise network might show
		# errors (this is why we connected deferred above).
		get_node("/root/Pong").free()
		show()

	get_tree().set_network_peer(null) # Remove peer.
	host_button.set_disabled(false)
	join_button.set_disabled(false)

	_set_status(with_error, false)


func _set_status(text, isok):
	# Simple way to show status.
	if isok:
		status_ok.set_text(text)
		status_fail.set_text("")
	else:
		status_ok.set_text("")
		status_fail.set_text(text)


func _on_host_pressed():
	peer = NetworkedMultiplayerENet.new()
	peer.set_compression_mode(NetworkedMultiplayerENet.COMPRESS_RANGE_CODER)
	var err = peer.create_server(DEFAULT_PORT, 4) # Maximum of 4 peers, to accomodate 5 players.
	if err != OK:
		# Is another server running?
		_set_status("Can't host, address in use.",false)
		return

	get_tree().set_network_peer(peer)
	
	# Consider removing lines 104/105, so that typos can be corrected without locking the UI
	host_button.set_disabled(true)
	join_button.set_disabled(true)
	_set_status("Waiting for player...", true)

	# Only show hosting instructions when relevant.
	port_forward_label.visible = true
	find_public_ip_button.visible = true
	
	# Begin player list with host name
	players.append(playername.get_text())
	_update_player_list()


func _on_join_pressed():
	var ip = address.get_text()
	if not ip.is_valid_ip_address():
		_set_status("IP address is invalid", false)
		return

	peer = NetworkedMultiplayerENet.new()
	peer.set_compression_mode(NetworkedMultiplayerENet.COMPRESS_RANGE_CODER)
	peer.create_client(ip, DEFAULT_PORT)
	get_tree().set_network_peer(peer)

	_set_status("Connecting...", true)
	

# Update list of players
remote func _update_player_list():
	player_tracker.text = "Players"
	
	# "Set" data type implementation. Prevent repetition of player names
	var seen = []
	for i in players:
		if not seen.has(i):
			player_tracker.text += "\n" + i
			seen.append(i)
	

func _on_start_game_pressed():
	rpc("_start_game")


remotesync func _start_game():
	var pong = load("res://pong.tscn").instance()
	# Connect deferred so we can safely erase it from the callback.
	pong.connect("game_finished", self, "_end_game", [], CONNECT_DEFERRED)

	# Replace lobby scene with pong scene
	get_tree().get_root().add_child(pong)
	hide()


func _on_find_public_ip_pressed():
	OS.shell_open("https://icanhazip.com/")
