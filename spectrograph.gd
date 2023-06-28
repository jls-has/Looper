@tool
extends ColorRect

var spectrum_analyzer := AudioServer.get_bus_effect_instance(0, 0)
@export var enabled := false
@export var scalor :float = 2595
@export var descalor : float = 700
@export var min_db : float = 60
@export var max_freq : float = 20000
@export var min_freq : float = 20
@export var mel_bands: float = 88
var pixels: PackedVector2Array = []
var sprite := Sprite2D.new()


func _process(_delta):
	# Sound plays back continuously, so the graph needs to be updated every frame.
	if enabled:
		#ixels = get_parent().get_logarithmic_frame(spectrum_analyzer, size.y,max_freq, min_freq, min_db)
		pixels = get_parent().get_mel_frame(spectrum_analyzer, size.y,max_freq, min_freq, min_db, scalor, descalor)
		#pixels = get_parent().get_frequency_energy_array(spectrum_analyzer, size.y, scalor, descalor, min_db )
		#pixels = get_parent().get_notes(spectrum_analyzer,min_db)
		generate_sprite()
		for s in get_children():
			s.position.x-=1
			if s.position.x<0:
				s.queue_free()
		
		#print(pixels[0],pixels[1],pixels[pixels.size()/2],pixels[pixels.size()-1])
#		queue_redraw()
	pass
	
func generate_sprite()->void:
	var i_size := size.y
	var image := Image.create(1,i_size,false,Image.FORMAT_RGBAF)
	
	for p in pixels:
		image.set_pixel(0,pixels.size()-p.y,Color(1,1,1,p.x))
	
	var texture := ImageTexture.create_from_image(image)
	var s := Sprite2D.new()
	s.set_texture(texture)
	s.position.x = size.x
	#s.scale.y = size.y/float(i_size)
	s.set_centered(false)
	add_child(s)

func _exit_tree() -> void:
	for each in get_children():
		each.queue_free()
