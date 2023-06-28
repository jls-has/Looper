@tool
extends Control


const FREQ_MAX := 20000.0
const MIN_DB =60

var recording : bool
var printed : bool = false


var mic_index: int
var input_spectrum : AudioEffectInstance

func _ready() -> void:
	mic_index = AudioServer.get_bus_index("Microphone")
	$VBoxContainer/HBoxContainer/MonitorInput.button_pressed = AudioServer.is_bus_mute(mic_index)
	input_spectrum = AudioServer.get_bus_effect_instance(mic_index,1)
	set_audioserver_mix_rate()
	$spectrograph.enabled = true

#func _process(delta: float) -> void:
#	set_frequency_labels()
#
func set_frequency_labels()->void:
	var freq_chunks := 648
	var prev_hz := 0
	var t = []
	for l in $freq_labels.get_children():
		#var hz = l.position.y * FREQ_MAX/freq_chunks 
		#var exp_chunk =  (l.position.y   / freq_chunks) * (l.position.y   / freq_chunks))
		var p = (l.position.y   / freq_chunks)
		p = 1-p
		var exp = p*p*p
		var hz =exp* FREQ_MAX

		l.text = str(hz)
		#t.append(1-p)
		t.append(hz)
		prev_hz = hz
	print(t)
#	for i in range(1, freq_chunks + 1):
#		var hz := i * FREQ_MAX/freq_chunks
#		for l in $freq_labels.get_children():
#			if l.position.y >= prev_hz and l.position.y <= hz:
#				l.text = 
#

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


func get_notes(analyzer: AudioEffectSpectrumAnalyzerInstance, min_db: float)->PackedVector2Array:
	var	pixels : PackedVector2Array = []
	@warning_ignore("integer_division")
	var prev_hz : = 16.35
	var notes_in_octave := 64.0
	for octave in 10:
		for note in notes_in_octave:
			var n : float = (octave+1)*(note+1)
			var hz :float= prev_hz * pow(2, 1/(notes_in_octave*10.0))
			#var h1 :float = prev_hz * pow(2, 0.5/notes_in_octave)
			#var h2 :float = prev_hz * pow(2, 1.5/notes_in_octave)
			var magnitude := analyzer.get_magnitude_for_frequency_range(prev_hz, hz).length()
			var energy := clampf((min_db + linear_to_db(magnitude)) / min_db, 0, 1)
			var x :float= energy
			var y := n
			pixels.append(Vector2(x,y))
			prev_hz = hz
	#print(pixels.slice(0,8))
		
	return pixels

func get_mel_frame(analyzer: AudioEffectSpectrumAnalyzerInstance,freq_chunks: float, max_hz:float, min_hz:float, min_db:float, scalor:float, descalor:float)->PackedVector2Array:
	
   
	
	var	pixels : PackedVector2Array = []
	@warning_ignore("integer_division")
	var prev_hz : = 0.0
	for i in range(1, freq_chunks + 1):
		var hz : float = min_hz*pow(max_hz/min_hz,i/(freq_chunks-1))
		#var hz : float = i / float(freq_chunks)
		hz = scalor * log(1.0 + hz / descalor)/log(10)
		var magnitude := analyzer.get_magnitude_for_frequency_range(prev_hz, hz).length()
		var energy := clampf((min_db + linear_to_db(magnitude)) / min_db, 0, 1)
		var x : float = energy
		var y : float = i
		pixels.append(Vector2(x,y))
		prev_hz = hz
	return pixels

func get_logarithmic_frame(analyzer: AudioEffectSpectrumAnalyzerInstance,freq_chunks: float, max_hz:float, min_hz:float, min_db)->PackedVector2Array:
	#start - start frequency
	#stop - stop frequency
	#n - the point which you wish to compute (zero based)
	#N - the number of points over which to divide the frequency range.
	#return start * pow(stop/start, n/(double)(N-1));
	
	var	pixels : PackedVector2Array = []
	@warning_ignore("integer_division")
	var prev_hz : = 0.0
	for i in range(1, freq_chunks + 1):
		var hz : float = min_hz*pow(max_hz/min_hz,i/(freq_chunks-1))
		var magnitude := analyzer.get_magnitude_for_frequency_range(prev_hz, hz).length()
		var energy := clampf((min_db + linear_to_db(magnitude)) / min_db, 0, 1)
		var x : float = energy
		var y : float = i
		pixels.append(Vector2(x,y))
		prev_hz = hz
	return pixels

func get_frequency_energy_array(analyzer: AudioEffectSpectrumAnalyzerInstance, freq_chunks: float, scalor: float, descalor: float, min_db:float)->PackedVector2Array:
	var	pixels : PackedVector2Array = []
	var	mags : PackedVector2Array = []
	@warning_ignore("integer_division")
	var prev_hz : = 0.0
	var min_max := Vector2(prev_hz,0)
	for i in range(1, freq_chunks + 1):
	
		
		#var hz: float = i / float(freq_chunks)
		#hz = scalor * pow(exponential, hz)
		#prev_hz = hz * (i -0.5)
		#hz = hz * (i+0.5)
		
		#correct, but leaves the spaces at the bottom too close together
		var hz : float = scalor*pow(FREQ_MAX/freq_chunks,(i/freq_chunks))
		prev_hz = hz * (i -1.0)
		hz = hz * (i)
		
		var magnitude := analyzer.get_magnitude_for_frequency_range(prev_hz, hz).length()
		mags.append(Vector2(prev_hz, hz))
		var energy := clampf((min_db + linear_to_db(magnitude)) / min_db, 0, 1)
		var x : float = energy
		var y : float = i
		pixels.append(Vector2(x,y))
		min_max.x = min(min_max.x,hz)
		#min_max.y = max(min_max.y, hz)
		min_max.x = i
		min_max.y = min_max.y+hz-prev_hz
		#prev_hz = hz
		if i == 648:
			print(min_max)
	#print(pow(2.0,1.0/12.0)*scalor)
	var x := 5
	#print(mags.slice(x,x+5))
	#print(min_max)
	return pixels


func _on_seconds_enter_value_changed(value: float) -> void:
	Global.master_length = value + $VBoxContainer/HBoxContainer/Minutes_Enter.value*60
	print(Global.master_length)



func _on_minutes_enter_value_changed(value: float) -> void:
	Global.master_length = value*60 + $VBoxContainer/HBoxContainer/Seconds_Enter.value
	print(Global.master_length)
