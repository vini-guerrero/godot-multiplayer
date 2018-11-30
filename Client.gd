extends Node

const SERVER_IP = "127.0.0.1"
const SERVER_PORT = 8080
onready var server = get_node("../Server")
onready var playersContainer = get_node("../PlayersContainer")
var startPos = Vector2(60, 60)
var player = preload("res://Player.tscn").instance()
var playerInfo = { 
		name = "AEIOAIO Noob Online", 
		favorite_color = Color8(255, 0, 255) 
	}

func startClient():
	server.create_client(playerInfo);

func _input(event):
	if event is InputEventMouseButton and event.is_pressed():
		server.updateClientPos(event.position);

slave func create_player(id, info):
	# spawn players with their respective names
	player.set_name(str(id))
	player.position = startPos
	playersContainer.call_deferred("add_child", player)
	print("Player Created")
	rpc("notifyServer")
	
remote func notifyServer():
	print("Client Created")