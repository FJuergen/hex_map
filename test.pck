GDPC                 �                                                                         T   res://.godot/exported/133200997/export-f059ade1057d2ebb8e628038eb1f2c4b-Hexagon.scn �      6      ͩWZP^:�xq����    P   res://.godot/exported/133200997/export-f0a4ea32b72b64218d23e48a955cbc61-test.scn�,      U      ;�+}�5R�<��L��    ,   res://.godot/global_script_class_cache.cfg   3             ��Р�8���8~$}P�    D   res://.godot/imported/icon.svg-218a8f2b3041327d8a5756f3a245f83b.ctex0      �      �̛�*$q�*�́        res://.godot/uid_cache.bin   7      W       ��A�k��c����y�       res://CameraController.gd   �(      �      8�e⎤�������       res://Hexagon.gd        ,      ���%��ʲ1�{�*j       res://Hexagon.gdshader  0      �      4�L�;L�Q¡�fF       res://Hexagon.tscn.remap@2      d       Q�.�Uh�s3A�E;4        res://HexagonGridController.gd         +      �[�1�Xe�:�*+��       res://TestController.gd �/      G      !��],�f�ʓ�	��p       res://icon.svg  @3      �      C��=U���^Qu��U3       res://icon.svg.import   (      �       �����.�V��m���       res://project.binary`7      �!      W�h	С��*�0.�       res://test.tscn.remap   �2      a       �ڡ�$��h��h���    �=e�BߘQ[E	extends Polygon2D

var x = 0
var y = 0
var z = 0

var _selected = false
var outline_color = null


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
	$TextX.text = str(x)
	$TextY.text = str(y)
	$TextZ.text = str(z)


func get_hex_coords():
	return Vector3i(x,y,z)

[B��shader_type canvas_item;

uniform vec4 color : source_color = vec4(1.0);
uniform float width : hint_range(0, 10) = 1.0;
uniform int pattern : hint_range(0, 2) = 0; // diamond, circle, square
uniform bool inside = false;
uniform bool add_margins = true; // only useful when inside is false

void vertex() {
	if (add_margins) {
		VERTEX += (UV * 2.0 - 1.0) * width;
	}
}

bool hasContraryNeighbour(vec2 uv, vec2 texture_pixel_size, sampler2D texture) {
	for (float i = -ceil(width); i <= ceil(width); i++) {
		float x = abs(i) > width ? width * sign(i) : i;
		float offset;
		
		if (pattern == 0) {
			offset = width - abs(x);
		} else if (pattern == 1) {
			offset = floor(sqrt(pow(width + 0.5, 2) - x * x));
		} else if (pattern == 2) {
			offset = width;
		}
		
		for (float j = -ceil(offset); j <= ceil(offset); j++) {
			float y = abs(j) > offset ? offset * sign(j) : j;
			vec2 xy = uv + texture_pixel_size * vec2(x, y);
			
			if ((xy != clamp(xy, vec2(0.0), vec2(1.0)) || texture(texture, xy).a == 0.0) == inside) {
				return true;
			}
		}
	}
	
	return false;
}

void fragment() {
	vec2 uv = UV;
	
	if (add_margins) {
		vec2 texture_pixel_size = vec2(1.0) / (vec2(1.0) / TEXTURE_PIXEL_SIZE + vec2(width * 2.0));
		
		uv = (uv - texture_pixel_size * width) * TEXTURE_PIXEL_SIZE / texture_pixel_size;
		
		if (uv != clamp(uv, vec2(0.0), vec2(1.0))) {
			COLOR.a = 0.0;
		} else {
			COLOR = texture(TEXTURE, uv);
		}
	} else {
		COLOR = texture(TEXTURE, uv);
	}
	
	if ((COLOR.a > 0.0) == inside && hasContraryNeighbour(uv, TEXTURE_PIXEL_SIZE, TEXTURE)) {
		COLOR.rgb = inside ? mix(COLOR.rgb, color.rgb, color.a) : color.rgb;
		COLOR.a += (1.0 - COLOR.a) * color.a;
	}
}Z��RSRC                    PackedScene            ��������                                                  resource_local_to_scene    resource_name 	   _bundled    script       Script    res://Hexagon.gd ��������      local://PackedScene_hp4vm          PackedScene          	         names "      
   Polygon2D    polygon    script    TextX    offset_left    offset_top    offset_right    offset_bottom    RichTextLabel    TextY    TextZ    	   variants       %        �B      HB33�B  H�33�B  ��      H�33��  HB33��               ��     ��     �A     \�     x�     �A     �     HB     XB     �A     �B     @B      node_count             nodes     8   ��������        ����                                  ����                                          	   ����                        	                  
   ����      
                               conn_count              conns               node_paths              editable_instances              version             RSRCf�`;6�=��extends Node2D


@onready var _hexagon = preload("res://Hexagon.tscn")
var _hex_count_x = 40
var _hex_count_y = 40
var _hex_count_z = 40
var _hex_list = {}
var _last_interacted = []
var rng = RandomNumberGenerator.new()

@export var size = 100

func generate_hex_map():
	for i in range(-_hex_count_x,_hex_count_x):
		for j in range(-_hex_count_y,_hex_count_y):
			for k in range(-_hex_count_z,_hex_count_z):
				if i + j + k == 0:
					generate_hexagon(i, j, k)



func generate_hexagon(i, j, k):
	var temp = _hexagon.instantiate()
	temp.scale = Vector2(size/100.0,size/100.0)
	temp.color = Color.from_hsv(rng.randf(), 0.75, 0.75)
	temp.position.x = i * size + j * -size*0.5 + k * -size*0.5
	temp.position.y = j * -size*0.866 + k * size*0.866
	temp.set_hex_coords(i, j, k)
	_hex_list[Vector3i(i,j,k)] = temp
	add_child(temp)
	return temp


func mouse_as_hex_coord():
	var mouse_position = get_global_mouse_position()
	print(mouse_position)
	var q = (2.0/3 * mouse_position.x) / size
	var r = (-1.0/3 * mouse_position.x + sqrt(3)/3 * mouse_position.y) / size
	var s = -q - r
	return Vector3i(hex_round(Vector3(q,s,r)))


func get_current_hexagon():
	return _hex_list.get(mouse_as_hex_coord())


func _ready():
	generate_hex_map()


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
					print("test")
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
			var line = hexagon_line(_last_interacted[0], get_current_hexagon())
			for hex in line.slice(1,line.size()):
				hex.outline_color = Color.BLUE
				hex.select()
				_last_interacted.append(hex)


func get_neighboring_hexagons(hex):
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


func hexagon_line(a, b):
	var N = hexagon_distance(a, b)
	var ret = []
	for i in range(N + 1):
		var hex_coord = Vector3i(hex_round(lerp((Vector3)(a.get_hex_coords()), Vector3(b.get_hex_coords()), 1.0 / N * i)))
		var temp = _hex_list.get(hex_coord)
		if temp != null:
			ret.append(temp)
	return ret


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


func hexagon_distance(hexagon_1, hexagon_2):
	var temp = hexagon_1.get_hex_coords() - hexagon_2.get_hex_coords()
	return (abs(temp.x) + abs(temp.y) + abs(temp.z)) / 2

���b�GST2   �   �      ����               � �        �  RIFF�  WEBPVP8L�  /������!"2�H�$�n윦���z�x����դ�<����q����F��Z��?&,
ScI_L �;����In#Y��0�p~��Z��m[��N����R,��#"� )���d��mG�������ڶ�$�ʹ���۶�=���mϬm۶mc�9��z��T��7�m+�}�����v��ح�m�m������$$P�����එ#���=�]��SnA�VhE��*JG�
&����^x��&�+���2ε�L2�@��		��S�2A�/E���d"?���Dh�+Z�@:�Gk�FbWd�\�C�Ӷg�g�k��Vo��<c{��4�;M�,5��ٜ2�Ζ�yO�S����qZ0��s���r?I��ѷE{�4�Ζ�i� xK�U��F�Z�y�SL�)���旵�V[�-�1Z�-�1���z�Q�>�tH�0��:[RGň6�=KVv�X�6�L;�N\���J���/0u���_��U��]���ǫ)�9��������!�&�?W�VfY�2���༏��2kSi����1!��z+�F�j=�R�O�{�
ۇ�P-�������\����y;�[ ���lm�F2K�ޱ|��S��d)é�r�BTZ)e�� ��֩A�2�����X�X'�e1߬���p��-�-f�E�ˊU	^�����T�ZT�m�*a|	׫�:V���G�r+�/�T��@U�N׼�h�+	*�*sN1e�,e���nbJL<����"g=O��AL�WO!��߈Q���,ɉ'���lzJ���Q����t��9�F���A��g�B-����G�f|��x��5�'+��O��y��������F��2�����R�q�):VtI���/ʎ�UfěĲr'�g�g����5�t�ۛ�F���S�j1p�)�JD̻�ZR���Pq�r/jt�/sO�C�u����i�y�K�(Q��7őA�2���R�ͥ+lgzJ~��,eA��.���k�eQ�,l'Ɨ�2�,eaS��S�ԟe)��x��ood�d)����h��ZZ��`z�պ��;�Cr�rpi&��՜�Pf��+���:w��b�DUeZ��ڡ��iA>IN>���܋�b�O<�A���)�R�4��8+��k�Jpey��.���7ryc�!��M�a���v_��/�����'��t5`=��~	`�����p\�u����*>:|ٻ@�G�����wƝ�����K5�NZal������LH�]I'�^���+@q(�q2q+�g�}�o�����S߈:�R�݉C������?�1�.��
�ڈL�Fb%ħA ����Q���2�͍J]_�� A��Fb�����ݏ�4o��'2��F�  ڹ���W�L |����YK5�-�E�n�K�|�ɭvD=��p!V3gS��`�p|r�l	F�4�1{�V'&����|pj� ߫'ş�pdT�7`&�
�1g�����@D�˅ �x?)~83+	p �3W�w��j"�� '�J��CM�+ �Ĝ��"���4� ����nΟ	�0C���q'�&5.��z@�S1l5Z��]�~L�L"�"�VS��8w.����H�B|���K(�}
r%Vk$f�����8�ڹ���R�dϝx/@�_�k'�8���E���r��D���K�z3�^���Vw��ZEl%~�Vc���R� �Xk[�3��B��Ğ�Y��A`_��fa��D{������ @ ��dg�������Mƚ�R�`���s����>x=�����	`��s���H���/ū�R�U�g�r���/����n�;�SSup`�S��6��u���⟦;Z�AN3�|�oh�9f�Pg�����^��g�t����x��)Oq�Q�My55jF����t9����,�z�Z�����2��#�)���"�u���}'�*�>�����ǯ[����82һ�n���0�<v�ݑa}.+n��'����W:4TY�����P�ר���Cȫۿ�Ϗ��?����Ӣ�K�|y�@suyo�<�����{��x}~�����~�AN]�q�9ޝ�GG�����[�L}~�`�f%4�R!1�no���������v!�G����Qw��m���"F!9�vٿü�|j�����*��{Ew[Á��������u.+�<���awͮ�ӓ�Q �:�Vd�5*��p�ioaE��,�LjP��	a�/�˰!{g:���3`=`]�2��y`�"��N�N�p���� ��3�Z��䏔��9"�ʞ l�zP�G�ߙj��V�>���n�/��׷�G��[���\��T��Ͷh���ag?1��O��6{s{����!�1�Y�����91Qry��=����y=�ٮh;�����[�tDV5�chȃ��v�G ��T/'XX���~Q�7��+[�e��Ti@j��)��9��J�hJV�#�jk�A�1�^6���=<ԧg�B�*o�߯.��/�>W[M���I�o?V���s��|yu�xt��]�].��Yyx�w���`��C���pH��tu�w�J��#Ef�Y݆v�f5�e��8��=�٢�e��W��M9J�u�}]釧7k���:�o�����Ç����ս�r3W���7k���e�������ϛk��Ϳ�_��lu�۹�g�w��~�ߗ�/��ݩ�-�->�I�͒���A�	���ߥζ,�}�3�UbY?�Ӓ�7q�Db����>~8�]
� ^n׹�[�o���Z-�ǫ�N;U���E4=eȢ�vk��Z�Y�j���k�j1�/eȢK��J�9|�,UX65]W����lQ-�"`�C�.~8ek�{Xy���d��<��Gf�ō�E�Ӗ�T� �g��Y�*��.͊e��"�]�d������h��ڠ����c�qV�ǷN��6�z���kD�6�L;�N\���Y�����
�O�ʨ1*]a�SN�=	fH�JN�9%'�S<C:��:`�s��~��jKEU�#i����$�K�TQD���G0H�=�� �d�-Q�H�4�5��L�r?����}��B+��,Q�yO�H�jD�4d�����0*�]�	~�ӎ�.�"����%
��d$"5zxA:�U��H���H%jس{���kW��)�	8J��v�}�rK�F�@�t)FXu����G'.X�8�KH;���[ ���0/ap�|}�[remap]

importer="texture"
type="CompressedTexture2D"
uid="uid://bu5bux5t40hdv"
path="res://.godot/imported/icon.svg-218a8f2b3041327d8a5756f3a245f83b.ctex"
metadata={
"vram_texture": false
}
 �/�g;:F�p��xథextends Camera2D

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
�b���WRSRC                    PackedScene            ��������                                                  resource_local_to_scene    resource_name 	   _bundled    script       Script    res://HexagonGridController.gd ��������   Script    res://CameraController.gd ��������      local://PackedScene_ahboi G         PackedScene          	         names "         Node    metadata/_edit_group_    Node2D    HexagonGrid    script    size 	   Camera2D    	   variants                          2                  node_count             nodes        ��������       ����                            ����                                 ����                   conn_count              conns               node_paths              editable_instances              version             RSRC�v��W�{l�extends Sprite2D

var speed = 400
var angular_speed = PI

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var direction = 0
	if Input.is_action_pressed("ui_left"):
		direction = -1
	if Input.is_action_pressed("ui_right"):
		direction = 1
	rotation += angular_speed * direction * delta
	var velocity = Vector2.ZERO
	if Input.is_action_pressed("ui_up"):
		velocity = Vector2.UP.rotated(rotation) * speed
	if Input.is_action_pressed("ui_down"):
		velocity = Vector2.DOWN.rotated(rotation) * speed * 0.5
	position += velocity * delta
	
��J��=�[remap]

path="res://.godot/exported/133200997/export-f059ade1057d2ebb8e628038eb1f2c4b-Hexagon.scn"
�}nUt?��k��[remap]

path="res://.godot/exported/133200997/export-f0a4ea32b72b64218d23e48a955cbc61-test.scn"
�چ�����j.[�#�list=Array[Dictionary]([])
A���<svg height="128" width="128" xmlns="http://www.w3.org/2000/svg"><rect x="2" y="2" width="124" height="124" rx="14" fill="#363d52" stroke="#212532" stroke-width="4"/><g transform="scale(.101) translate(122 122)"><g fill="#fff"><path d="M105 673v33q407 354 814 0v-33z"/><path fill="#478cbf" d="m105 673 152 14q12 1 15 14l4 67 132 10 8-61q2-11 15-15h162q13 4 15 15l8 61 132-10 4-67q3-13 15-14l152-14V427q30-39 56-81-35-59-83-108-43 20-82 47-40-37-88-64 7-51 8-102-59-28-123-42-26 43-46 89-49-7-98 0-20-46-46-89-64 14-123 42 1 51 8 102-48 27-88 64-39-27-82-47-48 49-83 108 26 42 56 81zm0 33v39c0 276 813 276 813 0v-39l-134 12-5 69q-2 10-14 13l-162 11q-12 0-16-11l-10-65H447l-10 65q-4 11-16 11l-162-11q-12-3-14-13l-5-69z"/><path d="M483 600c3 34 55 34 58 0v-86c-3-34-55-34-58 0z"/><circle cx="725" cy="526" r="90"/><circle cx="299" cy="526" r="90"/></g><g fill="#414042"><circle cx="307" cy="532" r="60"/><circle cx="717" cy="532" r="60"/></g></g></svg>
�ڟa�5A�%   �����R   res://Hexagon.tscn�=&z��u5   res://icon.svg���	NTx   res://test.tscn�B+�l�7ECFG      application/config/name         Projects   application/run/main_scene         res://test.tscn    application/config/features$   "         4.1    Forward Plus       application/config/icon         res://icon.svg  "   display/window/size/viewport_width         #   display/window/size/viewport_height      �     display/window/stretch/mode         canvas_items   input/ui_left�              deadzone      ?      events              InputEventKey         resource_local_to_scene           resource_name             device         	   window_id             alt_pressed           shift_pressed             ctrl_pressed          meta_pressed          pressed           keycode     @    physical_keycode       	   key_label             unicode           echo          script            InputEventJoypadButton        resource_local_to_scene           resource_name             device            button_index         pressure          pressed           script            InputEventJoypadMotion        resource_local_to_scene           resource_name             device            axis       
   axis_value       ��   script            InputEventKey         resource_local_to_scene           resource_name             device     ����	   window_id             alt_pressed           shift_pressed             ctrl_pressed          meta_pressed          pressed           keycode           physical_keycode   A   	   key_label             unicode    a      echo          script         input/ui_right�              deadzone      ?      events              InputEventKey         resource_local_to_scene           resource_name             device         	   window_id             alt_pressed           shift_pressed             ctrl_pressed          meta_pressed          pressed           keycode     @    physical_keycode       	   key_label             unicode           echo          script            InputEventJoypadButton        resource_local_to_scene           resource_name             device            button_index         pressure          pressed           script            InputEventJoypadMotion        resource_local_to_scene           resource_name             device            axis       
   axis_value       �?   script            InputEventKey         resource_local_to_scene           resource_name             device     ����	   window_id             alt_pressed           shift_pressed             ctrl_pressed          meta_pressed          pressed           keycode           physical_keycode   D   	   key_label             unicode    d      echo          script         input/ui_up�              deadzone      ?      events              InputEventKey         resource_local_to_scene           resource_name             device         	   window_id             alt_pressed           shift_pressed             ctrl_pressed          meta_pressed          pressed           keycode     @    physical_keycode    @ 	   key_label       @    unicode           echo          script            InputEventJoypadButton        resource_local_to_scene           resource_name             device            button_index         pressure          pressed           script            InputEventJoypadMotion        resource_local_to_scene           resource_name             device            axis      
   axis_value       ��   script            InputEventKey         resource_local_to_scene           resource_name             device     ����	   window_id             alt_pressed           shift_pressed             ctrl_pressed          meta_pressed          pressed           keycode           physical_keycode   W   	   key_label             unicode    w      echo          script         input/ui_down�              deadzone      ?      events              InputEventKey         resource_local_to_scene           resource_name             device         	   window_id             alt_pressed           shift_pressed             ctrl_pressed          meta_pressed          pressed           keycode     @    physical_keycode       	   key_label             unicode           echo          script            InputEventJoypadButton        resource_local_to_scene           resource_name             device            button_index         pressure          pressed           script            InputEventJoypadMotion        resource_local_to_scene           resource_name             device            axis      
   axis_value       �?   script            InputEventKey         resource_local_to_scene           resource_name             device     ����	   window_id             alt_pressed           shift_pressed             ctrl_pressed          meta_pressed          pressed           keycode           physical_keycode   S   	   key_label             unicode    s      echo          script         input/Up0              events              InputEventKey         resource_local_to_scene           resource_name             device     ����	   window_id             alt_pressed           shift_pressed             ctrl_pressed          meta_pressed          pressed           keycode           physical_keycode    @ 	   key_label             unicode           echo          script            InputEventKey         resource_local_to_scene           resource_name             device     ����	   window_id             alt_pressed           shift_pressed             ctrl_pressed          meta_pressed          pressed           keycode           physical_keycode   W   	   key_label             unicode    w      echo          script            deadzone      ?
   input/Down0              events              InputEventKey         resource_local_to_scene           resource_name             device     ����	   window_id             alt_pressed           shift_pressed             ctrl_pressed          meta_pressed          pressed           keycode           physical_keycode    @ 	   key_label             unicode           echo          script            InputEventKey         resource_local_to_scene           resource_name             device     ����	   window_id             alt_pressed           shift_pressed             ctrl_pressed          meta_pressed          pressed           keycode           physical_keycode   S   	   key_label             unicode    s      echo          script            deadzone      ?
   input/Left0              events              InputEventKey         resource_local_to_scene           resource_name             device     ����	   window_id             alt_pressed           shift_pressed             ctrl_pressed          meta_pressed          pressed           keycode           physical_keycode    @ 	   key_label             unicode           echo          script            InputEventKey         resource_local_to_scene           resource_name             device     ����	   window_id             alt_pressed           shift_pressed             ctrl_pressed          meta_pressed          pressed           keycode           physical_keycode   A   	   key_label             unicode    a      echo          script            deadzone      ?   input/Right0              events              InputEventKey         resource_local_to_scene           resource_name             device     ����	   window_id             alt_pressed           shift_pressed             ctrl_pressed          meta_pressed          pressed           keycode           physical_keycode    @ 	   key_label             unicode           echo          script            InputEventKey         resource_local_to_scene           resource_name             device     ����	   window_id             alt_pressed           shift_pressed             ctrl_pressed          meta_pressed          pressed           keycode           physical_keycode   D   	   key_label             unicode    d      echo          script            deadzone      ?��!If�t�é