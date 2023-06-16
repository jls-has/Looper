@tool
extends OptionButton

var input_devices : PackedStringArray

func _ready() -> void:
	clear()
	input_devices = AudioServer.get_input_device_list()
	#print("Input Devices: ", input_devices)
	for i in input_devices.size():
		add_item(input_devices[i], i)

func _on_item_selected(index: int) -> void:
	var id = get_item_id(index)
	AudioServer.set_input_device(input_devices[index])
	await get_tree().create_timer(0.1).timeout
	print("Input Device: ", AudioServer.input_device)

