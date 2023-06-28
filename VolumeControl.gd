extends HSlider

@export var bus_name : String : set = set_bus_name
func set_bus_name(v: String)->void:
	bus_name = v
	set_bus_index (AudioServer.get_bus_index(bus_name))
	
	
@export var bus_index: int : set = set_bus_index
func set_bus_index(v:int)->void:
	value = db_to_linear(AudioServer.get_bus_volume_db(bus_index))

func _ready() -> void:
	value_changed.connect(_on_value_changed)
	set_bus_name(bus_name)
	
func _on_value_changed(value:float)->void:
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))
