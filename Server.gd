extends Node

export var SERVER_PORT = 8080;
export var MAX_PLAYERS = 50;
export var SERVER_IP = "127.0.0.1"
onready var client = get_node("../Client")
var peer

func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")

# Player info, associate ID to data
var player_info = {}
# Info we send to other players
var currentPlayerInfo

func printDebug(info):
	var date = OS.get_datetime()
	var dateFormat = String(date.day)
	dateFormat +=  "/" + String(date.month)
	dateFormat +=  "/" + String(date.year) 
	dateFormat +=  " - " + String(date.hour)
	dateFormat += ":" + String(date.minute)
	dateFormat += ":" + String(date.second) + " - "
	#print(str(dateFormat, info))

func create_server():
	printDebug("Server Created")
	peer = NetworkedMultiplayerENet.new()
	peer.create_server(SERVER_PORT, MAX_PLAYERS)
	self.set_network_master(1)
	get_tree().set_network_peer(peer)

func create_client(playerInfo):
	currentPlayerInfo = playerInfo
	peer = NetworkedMultiplayerENet.new()
	peer.create_client(SERVER_IP, SERVER_PORT)
	get_tree().set_network_peer(peer)
	
remote func updateClientPos(position):
	print(position)
	if (checkServer()):
		printDebug(position)

func _player_connected(id):
	if (checkServer()):
		printDebug("New Player Connected To Server: " + str(id))

func _player_disconnected(id):
	if (checkServer()):
		printDebug("New Player Connected To Server: " + str(id))
	# Erase player from info
	player_info.erase(id)

func _connected_ok():
	if (!checkServer()):
		printDebug("Client Connected To Server: ");
		printDebug("Client Notifying Date: ");
	# Only called on clients, not server. Send my ID and info to all the other peers
	rpc("register_player", get_tree().get_network_unique_id(), currentPlayerInfo);

func _server_disconnected():
	pass # Server kicked us, show error and abort

func _connected_fail():
	pass # Could not even connect to server, abort

func close():
	peer.close_connection(0)

remote func register_player(id, info):
	if (!checkServer() && !!info):
		printDebug("Server Received Player Info: " + str(id));
		printDebug(info.name);
		# Store the info
		player_info[id] = info
	
	if (checkServer()):
		printDebug("Server Broadcasting New Player: " + str(id));
		var playersOnline = get_tree().get_network_connected_peers().size()
		printDebug(str("Total Players Online: ", playersOnline))
	
	# If I'm the server, let the new guy know about existing players
	if get_tree().is_network_server():
	    # Send my info to new player
	    rpc_id(id, "register_player", 1, currentPlayerInfo)
	    # Send the info of existing players
	    for peer_id in player_info:
	        rpc_id(id, "register_player", peer_id, player_info[peer_id])
	else:
		# Call function to update lobby UI here
		client.rpc("create_player", get_tree().get_network_unique_id(), currentPlayerInfo)

func checkServer():
	if get_tree().is_network_server():
		return true