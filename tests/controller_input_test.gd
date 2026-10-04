extends SceneTree

var failures := 0
var selections: Array[int] = []

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var hotbar = load("res://scenes/hotbar.tscn").instantiate()
	root.add_child(hotbar)
	hotbar.set_process(false)
	await create_timer(1.05).timeout
	var signals := root.get_node("Signals")
	signals.selected_hotbar_item.connect(_on_selection)

	hotbar.cell_item = hotbar.cubes.size() - 1
	await _send_button(JOY_BUTTON_DPAD_RIGHT)
	_expect(hotbar.cell_item == 0 and selections == [0], "D-pad right must wrap and emit exactly once.")
	_expect(Input.get_vector("left", "right", "up", "down").is_zero_approx(), "D-pad selection must not move the player.")
	_expect(hotbar.cubes[0].scale == Vector3.ONE * 1.5, "Selection must update the highlighted cube.")
	selections.clear()
	await _send_button(JOY_BUTTON_DPAD_LEFT)
	_expect(hotbar.cell_item == hotbar.cubes.size() - 1 and selections.size() == 1, "D-pad left must wrap backwards once.")
	selections.clear()
	await _send_key(false)
	_expect(hotbar.cell_item == 0 and selections == [0], "Tab must advance once.")
	selections.clear()
	await _send_key(true)
	_expect(hotbar.cell_item == hotbar.cubes.size() - 1 and selections.size() == 1, "Shift+Tab must move backwards once.")
	selections.clear()
	await _send_key(false, true)
	await _send_button(JOY_BUTTON_DPAD_RIGHT, false)
	_expect(selections.is_empty(), "Repeats and releases must not select items.")
	hotbar.hide_with_children()
	await _send_button(JOY_BUTTON_DPAD_RIGHT)
	_expect(selections.is_empty(), "Hidden hotbars must ignore selection.")
	hotbar.show_with_children()
	var cubes: Array = hotbar.cubes
	hotbar.cubes = []
	await _send_button(JOY_BUTTON_DPAD_RIGHT)
	hotbar._process(0.016)
	_expect(selections.is_empty(), "Empty hotbars must ignore selection and processing.")
	hotbar.cubes = cubes
	signals.selected_hotbar_item.disconnect(_on_selection)
	hotbar.free()

	# Exercise the player camera without starting physics or rendering the world.
	var player = load("res://scripts/player.gd").new()
	player.head = Node3D.new()
	player.main_camera = Camera3D.new()
	player.add_child(player.head)
	player.head.add_child(player.main_camera)
	Input.action_press("look_right", 0.1)
	player.update_controller_look(0.1)
	_expect(is_zero_approx(player.head.rotation.y), "Stick movement inside the deadzone must not rotate the camera.")
	Input.action_release("look_right")
	Input.action_press("look_right")
	player.update_controller_look(0.1)
	var yaw: float = player.head.rotation.y
	_expect(yaw < 0.0, "Right stick right must turn the camera right.")
	player.head.rotation = Vector3.ZERO
	player.update_controller_look(0.05)
	player.update_controller_look(0.05)
	_expect(is_equal_approx(player.head.rotation.y, yaw), "Look must be independent of frame duration.")
	Input.action_release("look_right")
	Input.action_press("look_down")
	player.update_controller_look(0.1)
	_expect(player.main_camera.rotation.x < 0.0, "Stick down must look down.")
	player.update_controller_look(10.0)
	_expect(is_equal_approx(player.main_camera.rotation.x, deg_to_rad(-70)), "Lower pitch limit must be enforced.")
	Input.action_release("look_down")
	Input.action_press("look_up")
	player.update_controller_look(10.0)
	_expect(is_equal_approx(player.main_camera.rotation.x, deg_to_rad(80)), "Upper pitch limit must be enforced.")
	Input.action_release("look_up")
	_expect(is_equal_approx(player.movement_direction(Vector2(0.5, 0)).length(), 0.5), "Partial stick movement must retain its magnitude.")
	player.free()
	quit(1 if failures else 0)

func _send_button(button: int, pressed := true) -> void:
	var event := InputEventJoypadButton.new()
	event.device = 2
	event.button_index = button
	event.pressed = pressed
	Input.parse_input_event(event)
	await process_frame

func _send_key(shift: bool, repeat := false) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = KEY_TAB
	event.shift_pressed = shift
	event.pressed = true
	event.echo = repeat
	Input.parse_input_event(event)
	await process_frame

func _on_selection(index: int) -> void:
	selections.append(index)

func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error(message)
