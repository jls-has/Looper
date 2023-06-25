extends Control


var recording : bool
var printed : bool = false


var mic_index: int
var input_spectrum : AudioEffectInstance

func _ready() -> void:
	mic_index = AudioServer.get_bus_index("Microphone")
	$VBoxContainer/HBoxContainer/MonitorInput.button_pressed = AudioServer.is_bus_mute(mic_index)
	input_spectrum = AudioServer.get_bus_effect_instance(mic_index,1)
	set_audioserver_mix_rate()
	

func _on_monitor_input_toggled(button_pressed: bool) -> void:
	AudioServer.set_bus_mute(mic_index, button_pressed)

func set_audioserver_mix_rate()->void:
	await get_tree().create_timer(0.5).timeout
	Global.update_audioserver_mix_rate()
	$VBoxContainer/LabelAudioServerMixRate.text = "AudioServer_Mix_Rate: " + str(Global.audioserver_mix_rate)


func _on_audio_input_option_button_item_selected(index: int) -> void:
	set_audioserver_mix_rate()

func _on_audio_output_option_button_2_item_selected(index: int) -> void:
	set_audioserver_mix_rate()

