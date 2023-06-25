extends HBoxContainer

var spectrum_analyzer : AudioEffectSpectrumAnalyzer
var mic_record : AudioEffectRecord
var mic_capture : AudioEffectCapture
var sample : AudioStream
var waveform_width : int
var waveform_height : int
var waveform_begin : int
var playhead : Line2D 
var loop_num : int 
var my_bus_idx : int
var recording := false
var sliding := false
var slide_start_x : float
var trim_frames_begin: int
var trim_frames_end: int
var loop_data : PackedVector2Array = []
var loop_segment_a : PackedVector2Array = []
var loop_segment_b : PackedVector2Array = []
var loop_segment_c : PackedVector2Array = []
var data_limit : int
var segment_limit : int
var timer : float = 0
var loop_bit_depth := 32
var loop_mix_rate := 48000
var loop_channels := 2 

var record_position : float
var record_start_p : float


@export var loop_name : String = "Loop" : set = set_loop_name
func set_loop_name(v: String)->void:
	delete_wav(Global.temp_dir, loop_name)
	loop_name = v
	$Name.set_text(loop_name) 

func _ready() -> void:

	loop_num = Global.loops_ready + 1
	set_loop_name(loop_name + str(loop_num))
	#$Name.text = loop_name 
	
	var mic_bus = AudioServer.get_bus_index("Microphone")
	mic_record = AudioServer.get_bus_effect(mic_bus, 1)
	mic_capture = AudioServer.get_bus_effect(mic_bus, 2)
	
	playhead = $Waveform/Playhead


	AudioServer.add_bus()
	my_bus_idx = AudioServer.get_bus_count() - 1
	AudioServer.set_bus_name(my_bus_idx, loop_name)
	var sa := AudioEffectSpectrumAnalyzer.new()
	AudioServer.add_bus_effect(my_bus_idx,sa)
	#$MyLoop.set_bus(loop_name)
	
	$SaveFileDialog.position = get_viewport_rect().size/2 - size/2
	
#	print("My audio stream set to: ", $MyLoop.get_bus())
#	for b in 4:
#		print("Audio Bus idx ", b, " is named ", AudioServer.get_bus_name(b))

	Global.loops_ready += 1
	
func _process(delta: float) -> void:
	if $RecordTimer/PopupPanel.visible:
		$RecordTimer/PopupPanel/Label.text = str($RecordTimer.time_left)
	elif recording:
		var captured_data_size : int = loop_segment_a.size()+loop_segment_b.size()
		if captured_data_size < data_limit:
			if captured_data_size < segment_limit:
				var capture_frames : int = min(segment_limit-captured_data_size, mic_capture.get_frames_available())
				loop_segment_b.append_array(mic_capture.get_buffer(capture_frames))
			else:
				var capture_frames : int = min(data_limit-captured_data_size, mic_capture.get_frames_available())
				loop_segment_a.append_array(mic_capture.get_buffer(capture_frames))
			
			timer += delta
			record_position += delta
			#if record_position < loop_length:

			#else:
			#	loop_segment_a.append_array(mic_capture.get_buffer(capture_frames))

		else:
			#zero_beginning()
			loop_data.append_array(loop_segment_a)
			loop_data.append_array(loop_segment_b)
			print("recorded for ", timer, " seconds.")
			timer = 0.0
			playhead.position.x = 0.0
			$Record.set_pressed(false)

		var p_position = wrapf(record_position, 0, Global.loop_length) 
		#print(record_position)
		playhead.position.x = remap(p_position, 0, Global.loop_length, 0, waveform_width)
		
		
	elif $MyLoop.is_playing():
		var p :float= $MyLoop.get_playback_position()
		playhead.position.x = remap(p, 0.0, Global.loop_length, 0.0, waveform_width)
	
	elif sliding:

		var mouse_x: = get_global_mouse_position().x
		var mouse_dif := mouse_x-slide_start_x
		if Input.is_action_pressed("slide_right"): slide_start_x -= 1
		elif Input.is_action_pressed("slide_left"): slide_start_x +=1
		var l_wave : Line2D = $Waveform/left_wave
		
		#var l_points : PackedVector2Array = l_wave.get_points()
		#l_wave.position.x +=mouse_dif
		
		trim_frames_begin = 0
		trim_frames_end = 0
		var points: int = l_wave.get_point_count()
		l_wave.position.x = mouse_dif
		l_wave.position.x = wrap(l_wave.position.x, -waveform_width, waveform_width)
		if Input.is_action_just_pressed("slide_end"):
			$Slide.set_pressed(false)
		#l_wave.position.x = clamp(l_wave.position.x, -waveform_width, waveform_width)
#		for i in points:
#			var pos := l_wave.get_point_position(i)
#			pos.x+=mouse_dif
#			if pos.x > waveform_width:
#				trim_frames_end += 1
#				pos.x = 0
#				l_wave.remove_point(i)
#				l_wave.add_point(pos,0)
#			elif pos.x < 0.0:
#				trim_frames_begin += 1
#				pos.x = waveform_width
#				l_wave.remove_point(i)
#				l_wave.add_point(pos)
#			else:
#				l_wave.set_point_position(i, pos)
#

			

			#if l_wave.points[i].x + mouse_dif > 
		#for f in l_wave.points:
		#	if f.x + mouse_dif > waveform_width:
		#		trim_frames_end+= 1
		#		var p :=Vector2(0, f.y)
				
		#	elif f.x + mouse_dif < waveform_width:
		#		trim_frames_begin += 1
		#print(l_wave.position)
		#print("trim begin: ", trim_frames_begin, " trim end: ", trim_frames_end, " mouse_dif: ", mouse_dif, " waveform width: ", waveform_width)
		#loop_segment_a.append_array(loop_segment_b)
		#loop_segment_a.append_array(loop_segment_c)
		#l_wave.clear_points()
		#l_wave.set_points(loop_segment_a)
				
		
func zero_fill(frames:int)->PackedVector2Array:
	var fill_size :int = Global.loop_length * Global.audioserver_mix_rate
	fill_size -= data_limit
	var temp_frames : PackedVector2Array = []
	if fill_size>0:
		for each in fill_size:
			temp_frames.append(Vector2.ZERO)
	return temp_frames
	
func update_waveform_box()->void:
	if Global.sync_loop == null or Global.sync_loop == $MyLoop:
		$nullbox.set_stretch_ratio(0.0)
		$nullbox2.set_stretch_ratio(0.0)
#	else:
#		if record_start_p>0.0:
#			$
	
	waveform_width = $Waveform.size.x
	waveform_height = $Waveform.size.y
	waveform_begin = $Waveform.position.x
	playhead.points[1] = Vector2(0,waveform_height)
	playhead.position.x = 0.0


func _on_record_toggled(button_pressed: bool) -> void:
	Global.update_audioserver_mix_rate()

	update_waveform_box()
	
	if button_pressed:
		if $Play.pressed:
			$Play.set_pressed(false)
		$RecordTimer.start()
		$RecordTimer/PopupPanel.visible= true
		await $RecordTimer.timeout
		recording = button_pressed
		clear_data()
		mic_capture.clear_buffer() 
		update_wav_data()
		$MyLoop.stop()
		$Play.set_pressed_no_signal(false)
		$Play.set_disabled(true)
		$Slide.set_disabled(true)
		data_limit = Global.loop_length * Global.audioserver_mix_rate
		if Global.sync_loop:
			record_position = Global.sync_loop.get_playback_position()# + AudioServer.get_time_since_last_mix()
			
			segment_limit = (Global.loop_length - record_position) * Global.audioserver_mix_rate
			#record_position -= AudioServer.get_output_latency() + AudioServer.get_time_to_next_mix()
			#record_position -= mic_capture.buffer_length
		else:
			record_position = 0.0
			segment_limit = data_limit
		record_start_p = record_position
		#print("loop length: ", loop_length, "  audioserver mix rate: ", Global.audioserver_mix_rate)
		#print("data size: ", data_size)
	else:
		recording = button_pressed
		if Global.sync_loop == null:
			Global.sync_loop = $MyLoop
		print(loop_name, " data is this big: ", loop_data.size())
		print("Audio Server Mix Rate: ", AudioServer.get_mix_rate())
		print("samples per second: ", loop_data.size()/Global.loop_length)
		#print("output latency: ", AudioServer.get_output_latency())
		
		var temp_path : String = Global.temp_dir+loop_name+".wav"
		#create_sample()
		create_wav(temp_path)
		draw_waveform()
		var audio_loader := AudioLoader.new()
		var play_stream : AudioStreamWAV = audio_loader.loadfile(temp_path)
		$MyLoop.set_stream(play_stream)
		$Play.set_disabled(false)
		$Slide.set_disabled(false)
		$Play.set_pressed(true)

#	if mic_record.is_recording_active():
#		$Record.set_pressed_no_signal(false)
#		print("mic is already recording")
#		return
#	else:

func create_wav(path: String)->void:
	var file = FileAccess.open(path, FileAccess.WRITE)
	
	#info on wav files: https://docs.fileformat.com/audio/wav/
	#header chunk each should be 4bytes long
	var h1 := "RIFF" #Marks the file as a riff file. Characters are each 1 byte long.?
	file.store_string(h1)
	var h2 := 0  #Size of the overall file - 8 bytes, in bytes (32-bit integer). Typically, you’d fill this in after creation.
	file.store_32(h2)
	var h3 := "WAVE" #File Type Header. For our purposes, it always equals “WAVE”.
	file.store_string(h3)
	
	#format chunk - all 4bytes except 3, 4, 7, 8 which are 2bytes each
	var f1 := "fmt " # Format chunk marker. Includes trailing null
	file.store_string(f1)
	var f2 := 16 #Length of format data as listed above
	file.store_32(f2) #32bits==4bytes
	var f3 := 3 #Type of format (1 is PCM, 3 is WAVE_FORMAT_IEEE_FLOAT ) - 2 byte integer
	file.store_16(f3) #16bits==2bytes
	var f4 := loop_channels #Number of Channels - 2 byte integer
	file.store_16(f4)
	var f5 := loop_mix_rate #Sample Rate - 32 byte integer. Common values are 44100 (CD), 48000 (DAT). Sample Rate = Number of Samples per second, or Hertz.
	file.store_32(f5)
	var f6 := (f5*32*f4)/8 # Byte Rate(Sample Rate * BitsPerSample * Channels) / 8
	file.store_32(f6)
	var f7 := (32*f4)/8 #Block Align (BitsPerSample * Channels) / 8.1 - 8 bit mono2 - 8 bit stereo/16 bit mono4 - 16 bit stereo
	file.store_16(f7)
	var f8 := loop_bit_depth #Bits per sample
	file.store_16(f8)
	
	#data chunk 4B each
	var f9 := "data" # “data” chunk header. Marks the beginning of the data section.
	file.store_string(f9)
	var f10 := 0 #Size of the data section.
	file.store_32(f10)
	#print("og header file_length: ", file.get_length(), " bytes.")
	
	#add sound data
	file.store_buffer(loop_data.to_byte_array())
	
	#update missing size info
	var data_size : int = file.get_length()-44 #remove 44 header bytes
	var file_size : int = data_size+36 #add back all but h1 & h2
	file.seek(4)
	file.store_32(file_size)
	file.seek(40)
	file.store_32(data_size)
	var data : PackedByteArray = loop_data.to_byte_array()

func draw_waveform()->void:
	var left_line : Line2D = $Waveform/left_wave
	var right_line : Line2D = $Waveform/right_wave
	left_line.clear_points()
	right_line.clear_points()
	var points : int = loop_data.size()
	for p in points:
		var d : Vector2 = loop_data[p]
		var x : float = remap(p, 0, points, 0, waveform_width)
		var l_y : float = remap(d.x, 0.5, -0.5, 0, waveform_height)
		var r_y : float = remap(d.y, 0.5, -0.5, 0, waveform_height)
		left_line.add_point(Vector2(x,l_y))
		right_line.add_point(Vector2(x, r_y))

		
func _on_save_pressed() -> void:
	if loop_data.size() == 0:
		print("No data to save")
		return
	else:
		$SaveFileDialog.set_current_file(loop_name + ".wav")
		$SaveFileDialog.set_filters(PackedStringArray(["*.wav ; WAV files"]))
		$SaveFileDialog.visible = true
		
func _on_save_file_dialog_file_selected(path: String) -> void:
	pass
	
func _on_play_toggled(button_pressed: bool) -> void:
	if button_pressed:
		#$MyLoop.play()
		for l in get_tree().get_nodes_in_group("loop_audiostream"):
			if l.is_playing():
				l.play()
			$MyLoop.play()
		#$Slide.set_disabled(true)
	else:
		$MyLoop.stop()
		$Slide.set_disabled(false)
	print(loop_name, " playing: ", $MyLoop.is_playing())
	
func delete_wav(path:String, filename:String)->void:
	var dir :=DirAccess.open(path)
	var err := dir.remove(filename)

func clear_data()->void:
	loop_data = []
	loop_segment_a = []
	loop_segment_b = []


func update_wav_data()->void:
	loop_bit_depth = 32
	loop_channels = 2
	loop_mix_rate = Global.audioserver_mix_rate

func _exit_tree() -> void:
	delete_wav(Global.temp_dir, loop_name+".wav")


func _on_name_text_changed(new_text: String) -> void:
	set_loop_name(new_text)


func _on_slide_toggled(button_pressed: bool) -> void:
	if $Play.pressed:
		$Play.set_pressed(false)
	sliding = button_pressed
	slide_start_x = get_global_mouse_position().x
	var left_wave :Line2D=$Waveform/left_wave 
	if button_pressed:
		left_wave.add_child(left_wave.duplicate())
		left_wave.add_child(left_wave.duplicate())
		left_wave.get_child(0).position.x -= waveform_width
		left_wave.get_child(1).position.x += waveform_width
	else:
		#print("Final Position: ", $Waveform/left_wave.position)
		for each in left_wave.get_children():
			each.queue_free()
		trim_frames_begin = 0
		trim_frames_end = 0
		loop_segment_a = []
		loop_segment_b = []
		loop_segment_c = []
		var frames = left_wave.get_point_count()
		for i in frames:
			var pos := left_wave.get_point_position(i) +Vector2(left_wave.position.x, 0)
			if pos.x < 0:
				#trim_frames_begin += 1
				loop_segment_c.append(loop_data[i])
			elif pos.x > waveform_width:
				loop_segment_a.append(loop_data[i])
			else:
				loop_segment_b.append(loop_data[i])
				
		left_wave.position.x = 0
		
		loop_data = []
		loop_data.append_array(loop_segment_a)
		loop_data.append_array(loop_segment_b)
		loop_data.append_array(loop_segment_c)#

		_on_record_toggled(false)
#		loop_segment_a = []
#		loop_segment_b = []
#		loop_segment_c = []
#
#		if trim_frames_begin > 0:
#			loop_segment_a = 
#		elif trim_frames_end>0:
#			pass
		
		#print("begin trim: ", trim_frames_begin, " end trim: ", trim_frames_end)
			
		


func _on_record_timer_timeout() -> void:
	$RecordTimer/PopupPanel.visible = false
	
