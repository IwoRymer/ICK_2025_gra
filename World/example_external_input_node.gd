extends Node

signal contr

func _ready() -> void:
	var server = get_node('../UDPServer') #get server node
	#connect to a signal and call _do_something when data gets sent through it
	server.client_control.connect(_do_something) 
	

func _do_something(data):
	#do something with received data i.e. process the user input
	print(data)	
