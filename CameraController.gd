extends Camera2D

var _pressed = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_pressed("Up"):
		translate(Vector2.UP * delta * 1000) 
	if Input.is_action_pressed("Left"):
		translate(Vector2.LEFT * delta * 1000)
	if Input.is_action_pressed("Down"):
		translate(Vector2.DOWN * delta * 1000)
	if Input.is_action_pressed("Right"):
		translate(Vector2.RIGHT * delta * 1000)


func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_MIDDLE:
		if event.pressed:
			_pressed = true
		else:
			_pressed = false
	if event is InputEventMouseMotion and _pressed:
		translate(-event.relative * 1/zoom)
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_WHEEL_UP:
		zoom *= Vector2(1.25,1.25)
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
		zoom /= Vector2(1.25,1.25)
