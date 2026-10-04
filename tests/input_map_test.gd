extends SceneTree

var failures := 0

func _init() -> void:
	for binding in [["up", KEY_W, KEY_UP], ["down", KEY_S, KEY_DOWN], ["left", KEY_A, KEY_LEFT], ["right", KEY_D, KEY_RIGHT]]:
		_expect_key(binding[0], binding[1])
		_expect_key(binding[0], binding[2])
	for binding in [["left", JOY_AXIS_LEFT_X, -1.0], ["right", JOY_AXIS_LEFT_X, 1.0], ["up", JOY_AXIS_LEFT_Y, -1.0], ["down", JOY_AXIS_LEFT_Y, 1.0], ["look_left", JOY_AXIS_RIGHT_X, -1.0], ["look_right", JOY_AXIS_RIGHT_X, 1.0], ["look_up", JOY_AXIS_RIGHT_Y, -1.0], ["look_down", JOY_AXIS_RIGHT_Y, 1.0], ["left_click", JOY_AXIS_TRIGGER_RIGHT, 1.0], ["right_click", JOY_AXIS_TRIGGER_LEFT, 1.0]]:
		_expect_axis(binding[0], binding[1], binding[2])
	for binding in [["jump", KEY_SPACE], ["sprint", KEY_SHIFT], ["inventory_2d", KEY_Q], ["ui_cancel", KEY_ESCAPE], ["ui_accept", KEY_ENTER]]:
		_expect_key(binding[0], binding[1])
	for binding in [["jump", JOY_BUTTON_A], ["sprint", JOY_BUTTON_LEFT_STICK], ["inventory_2d", JOY_BUTTON_Y], ["ui_cancel", JOY_BUTTON_B], ["ui_accept", JOY_BUTTON_A], ["hotbar_next", JOY_BUTTON_DPAD_RIGHT], ["hotbar_previous", JOY_BUTTON_DPAD_LEFT], ["ui_up", JOY_BUTTON_DPAD_UP], ["ui_down", JOY_BUTTON_DPAD_DOWN]]:
		_expect_button(binding[0], binding[1])
	_expect_key("hotbar_next", KEY_TAB)
	_expect_key("hotbar_previous", KEY_TAB, true)
	for binding in [["left_click", MOUSE_BUTTON_LEFT], ["right_click", MOUSE_BUTTON_RIGHT]]:
		_expect_event(binding[0], func(event): return event is InputEventMouseButton and event.button_index == binding[1])
	for action in ["left", "right", "up", "down", "look_left", "look_right", "look_up", "look_down"]:
		_expect(is_equal_approx(InputMap.action_get_deadzone(action), 0.2), "%s needs a 0.2 deadzone." % action)
	for action in ["left_click", "right_click"]:
		_expect(is_equal_approx(InputMap.action_get_deadzone(action), 0.5), "%s needs a 0.5 trigger threshold." % action)
	quit(1 if failures else 0)

func _expect_key(action: StringName, code: int, shift := false) -> void:
	_expect_event(action, func(event): return event is InputEventKey and (event.keycode == code or event.physical_keycode == code) and event.shift_pressed == shift)

func _expect_button(action: StringName, button: int) -> void:
	_expect_event(action, func(event): return event is InputEventJoypadButton and event.button_index == button and event.device == -1)

func _expect_axis(action: StringName, axis: int, value: float) -> void:
	_expect_event(action, func(event): return event is InputEventJoypadMotion and event.axis == axis and is_equal_approx(event.axis_value, value) and event.device == -1)

func _expect_event(action: StringName, matches: Callable) -> void:
	for event in InputMap.action_get_events(action):
		if matches.call(event):
			return
	_expect(false, "Missing binding for %s." % action)

func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error(message)
