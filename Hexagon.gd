@tool
class_name Hexagon
extends Polygon2D


@export var x = 0
@export var y = 0
@export var z = 0
@export var terrain_mod = 0
@export var tex: Texture2D


var _selected = false
var outline_color = null

func _init():
	super()
	var poly := []
	for i in range(6):
		var angle_rad = PI / 180 * (60 * i)
		poly.append(Vector2(cos(angle_rad) * 100,sin(angle_rad) * 100))
	polygon.resize(6)
	polygon = poly


func _exit_tree():
	get_parent().remove_hex(Vector3i(x,y,z))


func _enter_tree():
	get_parent()._hex_list[get_hex_coords()] = self


func toggle_selected():
	_selected = !_selected
	queue_redraw()


func deselect():
	_selected = false
	queue_redraw()


func select():
	_selected = true
	queue_redraw()


func _draw():
	if _selected:
		var temp = polygon
		temp.append(temp[0])
		draw_polyline(temp, outline_color, 3, true)


func set_hex_coords(a,b,c):
	x = a
	y = b
	z = c
	#$TextX.text = str(x)
	#$TextY.text = str(y)
	#$TextZ.text = str(z)


func get_hex_coords() -> Vector3i:
	return Vector3i(x,y,z)

