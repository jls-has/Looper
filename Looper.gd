extends Control

var capture : AudioEffect
var recording : bool
var printed : bool = false
var num_loops := 1

var mic_index: int
var input_spectrum : AudioEffectInstance

func _ready() -> void:
	mic_index = AudioServer.get_bus_index("Microphone")
	$VBoxContainer/HBoxContainer/MonitorInput.button_pressed = AudioServer.is_bus_mute(mic_index)
	
	input_spectrum = AudioServer.get_bus_effect_instance(mic_index,1)
	
	
func _on_monitor_input_toggled(button_pressed: bool) -> void:
	AudioServer.set_bus_mute(mic_index, button_pressed)

