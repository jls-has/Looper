extends HBoxContainer

var effect : AudioEffect
var sample : AudioStream
var loop_name : String = "Loop1"
var waveform_width : int
var waveform_height : int
var waveform_begin : int

var playhead : Line2D 
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Name.text = loop_name
	var idx = AudioServer.get_bus_index("Microphone")
	effect = AudioServer.get_bus_effect(idx, 0)
	playhead = $Waveform/Playhead

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if $Record.is_pressed():
		playhead.position.x = lerp(waveform_begin, waveform_width, ($Timer.time_left/3))

func initialize_waveform()->void:
	waveform_width = $Waveform.size.x
	waveform_height = $Waveform.size.y
	waveform_begin = $Waveform.position.x
	playhead.points[1] = Vector2(0,waveform_height)

	
func _on_record_pressed() -> void:
	if effect.is_recording_active():
		sample = effect.get_recording()
		$Play.disabled = false
		$Save.disabled = false
		effect.set_recording_active(false)
		sample.set_mix_rate(48000)
		sample.set_format(2)
		sample.set_stereo(false)
		$Record.text = "Record"

	else:
		initialize_waveform()
		$Play.disabled = true
		$Save.disabled = true
		effect.set_recording_active(true)
		$Record.text = "Stop"
		$Timer.start()



func _on_play_pressed() -> void:
	
	var data : PackedByteArray = sample.get_data()
	$MyLoop.stream = sample
	$MyLoop.play()


func _on_timer_timeout() -> void:
	_on_record_pressed()

