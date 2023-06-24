extends Node

var loops_ready: int= 0
var audioserver_mix_rate : int
var longest_length : float 
var sync_loop : AudioStreamPlayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	audioserver_mix_rate = AudioServer.get_mix_rate()
	



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
