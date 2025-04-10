extends Node

var server = UDPServer.new()
var peers = []
var control_vals = []

signal client_control(control_vals)

func _ready():
	control_vals.resize(4)
	control_vals.fill(null)
	
	server.listen(4242)
	
func _process(delta):
	server.poll()
	
	if server.is_connection_available():
		var peer = server.take_connection()
		var packet = peer.get_packet()
		
		print("Accepted peer: %s:%s" % [peer.get_packet_ip(), peer.get_packet_port()])
		print("Received data: %s" % [packet.get_string_from_utf8()])
				
		peers.append(peer)
	
	for i in range(0, peers.size()):
		var array_bytes = peers[i].get_packet()
		if !array_bytes.is_empty():
			var id = (array_bytes.slice(0, 1)).get_string_from_utf8()
			var packet_string = (array_bytes.slice(1)).get_string_from_utf8()

			control_vals[int(id)] = packet_string
			client_control.emit(control_vals)
		
	
