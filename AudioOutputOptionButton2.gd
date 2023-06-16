@tool
extends OptionButton

var output_devices : PackedStringArray

func _ready() -> void:
	clear()
	output_devices = AudioServer.get_output_device_list()
	#print(output_devices)
	for i in output_devices.size():
		add_item(output_devices[i], i)

func _on_item_selected(index: int) -> void:
	var id = get_item_id(index)
	AudioServer.set_output_device(output_devices[id])
	await get_tree().create_timer(0.1).timeout
	print("Output Device: ", AudioServer.output_device)
