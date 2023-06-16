extends ProgressBar

@export var bus_name : String = "Microphone"
var bus_index: int
var input_spectrum : AudioEffectInstance

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	bus_index = AudioServer.get_bus_index(bus_name)
	input_spectrum = AudioServer.get_bus_effect_instance(bus_index,0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var mag = input_spectrum.get_magnitude_for_frequency_range(0.0,100000.0, 2).length()
	var e = linear_to_db(mag)
	value = e

