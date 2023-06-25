extends Node

var loops_ready: int= 0
var audioserver_mix_rate : int
var loop_length : float = 3.0
var sync_loop : AudioStreamPlayer
var temp_dir : String = "user://"
#var global_sync := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	audioserver_mix_rate = AudioServer.get_mix_rate()
	



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func update_audioserver_mix_rate()->void:
	Global.audioserver_mix_rate = AudioServer.get_mix_rate()
	
