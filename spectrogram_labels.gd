@tool
extends Control

@export var lines := 10 : set = update_lines
func update_lines(v:int)->void:
	lines = v
	for i in lines:
		var line = Line2D.new()
		line.set_width(2)
		line.add_point(Vector2(0, size.y/lines *i))
		line.add_point(Vector2(size.x, size.y/lines *i))
		$lines.add_child(line)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_lines(lines)
	for i in $freq_labels.get_child_count():
		$freq_labels.get_child(i).position.y = size.y/lines *i
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
