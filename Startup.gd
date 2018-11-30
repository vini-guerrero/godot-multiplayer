extends Node

onready var serverNode = get_node("Server")
onready var clientNode = get_node("Client")

func _ready():
	var args = OS.get_cmdline_args()
	if (args):
		if (args[0] == "--server"):
			serverNode.create_server()
	elif (!!serverNode.RUN_AS_SERVER):
		serverNode.create_server()
	else:
		clientNode.startClient()

# Server Start - Godot Headless
# ./Godot_v3.1Headless.64 --path ./NetworkServer