@tool
extends Control

## Keys and clicks at the bottom left of the editor view

const MAX_LINES := 5
## Seconds a line stays up
const LIFE_TIME := 3.0
const FONT_SIZE := 16
const MARGIN := Vector2(16, 16)
## The 2D view has rulers and scrollbars in the way
const MARGIN_2D := Vector2(32, 28)
const TEXT_COLOR := Color.WHITE
## Godot blue
const HELD_COLOR := Color("478cbf")
const BORDER_COLOR := Color("c0c0c0")
## Same ratio as Blender
const MOUSE_SIZE := Vector2(36, 47)

const MOUSE_NAMES := {
	MOUSE_BUTTON_LEFT: "Left Mouse",
	MOUSE_BUTTON_RIGHT: "Right Mouse",
	MOUSE_BUTTON_MIDDLE: "Middle Mouse",
	MOUSE_BUTTON_WHEEL_UP: "Wheel Up",
	MOUSE_BUTTON_WHEEL_DOWN: "Wheel Down",
	MOUSE_BUTTON_WHEEL_LEFT: "Wheel Left",
	MOUSE_BUTTON_WHEEL_RIGHT: "Wheel Right",
	MOUSE_BUTTON_XBUTTON1: "Button4 Mouse",
	MOUSE_BUTTON_XBUTTON2: "Button5 Mouse",
}

# {text, count, time}, oldest first
var lines: Array[Dictionary] = []
var held := PackedStringArray()
var font: Font
var key_style := StyleBoxFlat.new()
var mouse_body := StyleBoxFlat.new()
var left_button := StyleBoxFlat.new()
var right_button := StyleBoxFlat.new()
var wheel := StyleBoxFlat.new()
var wheel_pressed := StyleBoxFlat.new()


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_preset(Control.PRESET_FULL_RECT)
	font = EditorInterface.get_base_control().get_theme_font("main", "EditorFonts")

	var editor_scale := EditorInterface.get_editor_scale()
	key_style.bg_color = Color(0, 0, 0, 0.4)
	key_style.border_color = BORDER_COLOR
	key_style.set_border_width_all(maxi(1, int(editor_scale)))
	key_style.set_corner_radius_all(int(5 * editor_scale))

	var border := maxi(1, int(editor_scale))
	var corner := int(MOUSE_SIZE.x * 0.4 * editor_scale)
	mouse_body.bg_color = Color(0, 0, 0, 0.4)
	mouse_body.border_color = BORDER_COLOR
	mouse_body.set_border_width_all(border)
	mouse_body.set_corner_radius_all(corner)
	left_button.bg_color = HELD_COLOR
	left_button.corner_radius_top_left = corner
	right_button.bg_color = HELD_COLOR
	right_button.corner_radius_top_right = corner
	wheel.bg_color = Color(0.1, 0.1, 0.1)
	wheel.border_color = BORDER_COLOR
	wheel.set_border_width_all(border)
	wheel.set_corner_radius_all(int(4 * editor_scale))
	wheel_pressed = wheel.duplicate()
	wheel_pressed.bg_color = HELD_COLOR


func _input(event: InputEvent) -> void:
	if not visible:
		return

	if event is InputEventKey and event.pressed and not event.echo:
		var code: Key = event.keycode
		if code == KEY_NONE:
			code = event.physical_keycode
		# Modifiers alone go in the held box
		if code not in [KEY_SHIFT, KEY_CTRL, KEY_ALT, KEY_META]:
			push_line(modifiers_text(event) + OS.get_keycode_string(code))

	elif event is InputEventMouseButton and event.pressed:
		if MOUSE_NAMES.has(event.button_index):
			push_line(modifiers_text(event) + MOUSE_NAMES[event.button_index])


func _process(delta: float) -> void:
	for line in lines.duplicate():
		line.time -= delta
		if line.time <= 0.0:
			lines.erase(line)

	# Every frame so nothing gets stuck
	held = held_keys()
	queue_redraw()


func _draw() -> void:
	var screen := EditorInterface.get_editor_main_screen()
	var editor_scale := EditorInterface.get_editor_scale()
	var size_px := int(FONT_SIZE * editor_scale)
	var line_height := font.get_height(size_px)
	var pad := Vector2(6, 2) * editor_scale

	var mouse_size := MOUSE_SIZE * editor_scale

	var margin := MARGIN_2D if in_2d() else MARGIN

	var x := screen.global_position.x - global_position.x + margin.x
	var y := screen.global_position.y - global_position.y + screen.size.y - margin.y

	# Mouse always drawn so the lines above don't jump
	y -= mouse_size.y
	draw_mouse(Rect2(Vector2(x, y), mouse_size))
	if not held.is_empty():
		var text := " + ".join(held)
		var width := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, size_px).x
		var box_height := line_height + pad.y * 2
		var box_x := x + mouse_size.x * 1.4
		var box_y := y + (mouse_size.y - box_height) / 2.0
		draw_style_box(key_style, Rect2(box_x, box_y, width + pad.x * 2, box_height))
		draw_text(Vector2(box_x + pad.x, box_y + pad.y), text, size_px, HELD_COLOR)

	# Newest at the bottom
	y -= line_height * 0.6
	for i in range(lines.size() - 1, -1, -1):
		var line: Dictionary = lines[i]
		var text: String = line.text
		if line.count > 1:
			text += " x%d" % line.count
		y -= line_height
		draw_text(Vector2(x, y), text, size_px, TEXT_COLOR)


func draw_mouse(rect: Rect2) -> void:
	var half := Vector2(rect.size.x / 2.0, rect.size.y / 2.0)
	var middle_x := rect.position.x + half.x
	var button_y := rect.position.y + half.y

	draw_style_box(mouse_body, rect)
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		draw_style_box(left_button, Rect2(rect.position, half))
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		draw_style_box(right_button, Rect2(Vector2(middle_x, rect.position.y), half))

	draw_line(Vector2(rect.position.x, button_y), Vector2(rect.end.x, button_y), BORDER_COLOR)
	draw_line(Vector2(middle_x, rect.position.y), Vector2(middle_x, button_y), BORDER_COLOR)

	# Over the lines
	var wheel_size := Vector2(rect.size.x * 0.2, half.y * 0.74)
	var wheel_rect := Rect2(Vector2(middle_x - wheel_size.x / 2.0, rect.position.y + half.y * 0.39), wheel_size)
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE):
		draw_style_box(wheel_pressed, wheel_rect)
	else:
		draw_style_box(wheel, wheel_rect)


## Top of the line, not the baseline
func draw_text(top_left: Vector2, text: String, size_px: int, color: Color) -> void:
	var baseline := top_left + Vector2(0, font.get_ascent(size_px))
	var outline := int(4 * EditorInterface.get_editor_scale())
	draw_string_outline(font, baseline, text, HORIZONTAL_ALIGNMENT_LEFT, -1, size_px, outline, Color(0, 0, 0, 0.8))
	draw_string(font, baseline, text, HORIZONTAL_ALIGNMENT_LEFT, -1, size_px, color)


func push_line(text: String) -> void:
	# Same key again counts up
	if not lines.is_empty() and lines.back().text == text:
		lines.back().count += 1
		lines.back().time = LIFE_TIME
		return

	lines.append({"text": text, "count": 1, "time": LIFE_TIME})
	if lines.size() > MAX_LINES:
		lines.pop_front()


func in_2d() -> bool:
	var view := EditorInterface.get_editor_viewport_2d().get_parent() as Control
	return view != null and view.is_visible_in_tree()


func held_keys() -> PackedStringArray:
	var keys := PackedStringArray()
	if Input.is_key_pressed(KEY_CTRL):
		keys.append("Ctrl")
	if Input.is_key_pressed(KEY_SHIFT):
		keys.append("Shift")
	if Input.is_key_pressed(KEY_ALT):
		keys.append("Alt")
	if Input.is_key_pressed(KEY_META):
		keys.append("Meta")
	return keys


func modifiers_text(event: InputEventWithModifiers) -> String:
	var text := ""
	if event.ctrl_pressed:
		text += "Ctrl + "
	if event.shift_pressed:
		text += "Shift + "
	if event.alt_pressed:
		text += "Alt + "
	if event.meta_pressed:
		text += "Meta + "
	return text
