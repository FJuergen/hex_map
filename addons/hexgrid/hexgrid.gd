@tool
extends EditorPlugin

var editing = false
var eds = get_editor_interface().get_selection()
var mouse_position

var hex_grid : HexagonGrid

func _edit(object: Object):
	hex_grid = object


func _handles(object):
	return object is HexagonGrid


func _enter_tree():
	add_custom_type("HexagonGrid", "HexagonGrid", preload("res://HexagonGrid.gd"), preload("res://icon.svg"))
	set_process_input(true)
	eds.connect("selection_changed", on_selection_changed)


func _exit_tree():
	remove_custom_type("HexagonGrid")


func on_selection_changed():
	var selected = eds.get_selected_nodes()
	if not selected.is_empty():
		editing = false
		for sel in selected: 
			if sel.script == HexagonGrid:
				editing = true


func _forward_canvas_gui_input(event):
	if event is InputEventMouse:
		if mouse_position != event.position:
			mouse_position = event.position
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			var hex_pos = hex_grid.global_to_hex(
				(hex_grid.get_canvas_transform().affine_inverse() * hex_grid.get_viewport_transform().affine_inverse()  * event.position) * hex_grid.transform)
			if not hex_grid.has_hex(hex_pos):
				hex_grid.generate_hexagon_vec3(hex_pos)
			return true
		if event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
			return true
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_DELETE:
			var hex_pos = hex_grid.global_to_hex(
				(hex_grid.get_canvas_transform().affine_inverse() * hex_grid.get_viewport_transform().affine_inverse() * mouse_position) * hex_grid.transform)
			if hex_grid.has_hex(hex_pos):
				hex_grid._hex_list[hex_pos].free()
			return true 
	return false
