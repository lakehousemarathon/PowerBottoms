extends Node

#Default local address
@export var Address = "127.0.0.1"
var port = 9453

#not immediately calling peer = Server because we only need to call it 
#once it is invoked, TL;DR optimization reasoning I know it looks kinda weird.
var peer 
# Called when the node enters the scene tree for the first time.
func _ready():
	multiplayer.peer_connected.connect(PlayerConnected)
	multiplayer.peer_disconnected.connect(PlayerDisconnected)
	multiplayer.connected_to_server.connect(ConnectedToServer)
	multiplayer.connection_failed.connect(ConnectionFailed)
	if "--server" in OS.get_cmdline_args():
		hostGame()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
	
#from server and clients
func PlayerConnected(id):
	print("player connected: " + str(id))
	SendPlayerInformation.rpc_id(1, $LineEdit.text, multiplayer.get_unique_id())

func PlayerDisconnected(id):
	print("player disconnected: " + str(id))
	
#called only from clients
func ConnectedToServer(id):
	print("connected to server: " + str(id))


func ConnectionFailed(id):
	print("connected to server failed: " + str(id))

@rpc("any_peer")
func SendPlayerInformation(name, id):
	if !GameManager.Players.has(id):
		GameManager.Players[id] ={
			"name": name,
			"id": id,
			#add any player info here
		}
	#send player information to all clients, probably insecure, but itll work
	if multiplayer.is_server():
		for i in GameManager.Players:
			SendPlayerInformation.rpc(GameManager.Players[i].name, i)
	
@rpc("any_peer","call_local")
func StartGame():
	var scene = load("res://scenes/game.tscn").instantiate()
	get_tree().root.add_child(scene)
	$HostButton.hide()
	$JoinButton.hide()
	$Button.hide()
	$LineEdit.hide()

	
func hostGame():
		#Creates a multiplayer type object in which 
	#we can invoke a server.
	peer = ENetMultiplayerPeer.new()
	#create server takes two arguments, port and max number of clients
	var server = peer.create_server(port)
	
	if(server != OK):
		print("something fucked up big time dawg")
		print(server)
		return
	# Compression algorithm used for packets;
	# choosing the one that utilizes least amount of CPU
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)

	#this will set my server as my peer.
	"""
	Okay so basically, we want to be able to use our own host as a peer.
	If we don't do this, then the the server machine cannot also be a client.
	"""
	multiplayer.set_multiplayer_peer(peer)
	print("Waiting for clients...")


	
func _on_host_button_button_down():
	hostGame()
	SendPlayerInformation($LineEdit.text, multiplayer.get_unique_id())
	pass

	
	
func _on_join_button_button_down():
	peer = ENetMultiplayerPeer.new()
	peer.create_client(Address, port)
	#in order to maintain sanity, we keep the same compression as the server.
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(peer)
	SendPlayerInformation($LineEdit.text, multiplayer.get_unique_id())
	


func _on_button_button_down():
	"""
	RPC -> check docs for more info
	https://docs.godotengine.org/en/stable/tutorials/networking/high_level_multiplayer.html
	"""
	StartGame.rpc()
	pass # Replace with function body.
