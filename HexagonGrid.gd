@tool
class_name HexagonGrid
extends Node2D


var _hexagon_points = null

var _hex_list := {}
var _last_interacted = []
var rng = RandomNumberGenerator.new()


var _size = 100


func _ready():
	var temp = Hexagon.new()
	_hexagon_points = temp.polygon
	_hexagon_points.append(_hexagon_points[0])
	temp.free()
	print(_hex_list.keys())
	if Engine.is_editor_hint():
		set_notify_transform(true)


func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			for hex in _last_interacted:
				if hex != null:
					hex.deselect()
			_last_interacted.clear()
			if Input.is_key_pressed(KEY_CTRL):
				var current = get_current_hexagon()
				if current != null:
					for hex in get_neighboring_hexagons(current):
						hex.outline_color = Color.GREEN
						hex.select()
						_last_interacted.append(hex)
			else:
				_last_interacted.append(get_current_hexagon())
				if _last_interacted[0] == null:
					var temp = mouse_as_hex_coord()
					generate_hexagon(temp.x, temp.y, temp.z)
					return
				_last_interacted[0].outline_color = Color.YELLOW
				_last_interacted[0].select()
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			if get_current_hexagon() == null:
				return
			for i in range(1,_last_interacted.size()):
				_last_interacted[i].deselect()
			_last_interacted.resize(1)
			var line = find_path(get_current_hexagon(),_last_interacted[0])
			for hex in line.slice(1,line.size()):
				hex.outline_color = Color.BLUE
				hex.select()
				_last_interacted.append(hex)


func generate_hexagon(i: int, j: int, k: int) -> void:
	var temp = Hexagon.new()
	_hexagon_points = temp.polygon
	temp.scale = Vector2(_size/100.0,_size/100.0)
	temp.color = Color.from_hsv(rng.randf(), 0.75, 0.75)
	temp.position.x = i * _size + j * -_size*0.5 + k * -_size*0.5
	temp.position.y = j * -_size*0.866 + k * _size*0.866
	temp.set_hex_coords(i, j, k)
	_hex_list[Vector3i(i,j,k)] = temp
	temp.name = str("Hexgrid ", i," ", j, " ", k)
	add_child(temp)
	temp.set_owner(get_tree().edited_scene_root)


func generate_hexagon_vec3(vec: Vector3i) -> void:
	generate_hexagon(vec.x, vec.y, vec.z)


func mouse_as_hex_coord():
	return global_to_hex(get_local_mouse_position())


func global_to_hex(vec):
	vec - position
	vec.rotated(rotation_degrees)
	var q = (2.0/3 * vec.x) / _size
	var r = (-1.0/3 * vec.x + sqrt(3)/3 * vec.y) / _size
	var s = -q - r
	return Vector3i(hex_round(Vector3(q,s,r)))


func get_current_hexagon():
	return _hex_list.get(mouse_as_hex_coord())


func get_neighboring_hexagons(hex: Hexagon):
	var current_coords = hex.get_hex_coords()
	var directions = [
		Vector3i(+1, 0, -1),
		Vector3i(+1, -1, 0),
		Vector3i(0, -1, +1),
		Vector3i(-1, 0, +1),
		Vector3i(-1, +1, 0),
		Vector3i(0, +1, -1),
	]
	var ret = []
	for dir in directions:
		var temp = _hex_list.get(current_coords + dir)
		if temp != null:
			ret.append(temp)
	return ret	


func hexagon_line(a: Hexagon, b: Hexagon):
	var N = hexagon_distance(a, b)
	var ret = []
	for i in range(N + 1):
		var hex_coord = Vector3i(hex_round(lerp((Vector3)(a.get_hex_coords()), Vector3(b.get_hex_coords()), 1.0 / N * i)))
		var temp = _hex_list.get(hex_coord)
		if temp != null:
			ret.append(temp)
	return ret


func has_hex(vec: Vector3i) -> bool:
	print(vec in _hex_list)
	print(vec)
	print(_hex_list.keys())
	return vec in _hex_list.keys()


func remove_hex(vec:Vector3i):
	_hex_list.erase(vec)


func hex_round(vec):
	var rounded = round(vec)
	var x_diff = abs(rounded.x-vec.x)
	var y_diff = abs(rounded.y-vec.y)
	var z_diff = abs(rounded.z-vec.z)
	
	if(x_diff >= y_diff and x_diff >= z_diff):
		rounded.x = -rounded.y - rounded.z
	elif(y_diff >= z_diff):
		rounded.y = -rounded.x - rounded.z
	else:
		rounded.z = -rounded.x - rounded.y
	return rounded


func hexagon_distance(hexagon_1: Hexagon, hexagon_2: Polygon2D):
	var temp = hexagon_1.get_hex_coords() - hexagon_2.get_hex_coords()
	return (abs(temp.x) + abs(temp.y) + abs(temp.z)) / 2.0


func find_path(from: Hexagon, to: Hexagon):
	var frontier = PriorityQueue.new()
	frontier.append(from, 0)
	var came_from = {}
	var cost_so_far = {}
	came_from[from] = null
	cost_so_far[from] = 0
	while not frontier.is_empty():
		var current: Hexagon = frontier.poll()
		if current == to:
			var path = []
			path.append(to)
			path.append(came_from[to])
			while true:
				var next = came_from[path.back()]
				if next == null:
					break
				path.append(next)
			return path
		for next in get_neighboring_hexagons(current):
			var new_cost = cost_so_far[current] + 1 + next.terrain_mod
			if next not in cost_so_far or new_cost < cost_so_far[next]:
				cost_so_far[next] = new_cost
				var priority = new_cost + hexagon_distance(to, next)
				frontier.append(next, priority)
				came_from[next] = current
