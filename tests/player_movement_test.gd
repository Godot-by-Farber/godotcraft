extends SceneTree

var failures := 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var player = load("res://scripts/player.gd").new()
	var head := Node3D.new()
	player.add_child(head)
	player.head = head

	_expect_direction(player.movement_direction(Vector2.UP), Vector3.FORWARD, "Forward at neutral yaw")
	_expect_direction(player.movement_direction(Vector2.RIGHT), Vector3.RIGHT, "Right at neutral yaw")

	head.rotation.y = PI / 2.0
	_expect_direction(player.movement_direction(Vector2.UP), Vector3.LEFT, "Forward after a 90-degree turn")
	_expect_direction(player.movement_direction(Vector2.RIGHT), Vector3.FORWARD, "Right after a 90-degree turn")
	_expect_direction(player.movement_direction(Vector2.ZERO), Vector3.ZERO, "No movement input")
	_expect_direction(player.movement_direction(Vector2.UP * 0.5), Vector3.LEFT * 0.5, "Half-strength forward input")

	player.free()
	quit(1 if failures else 0)

func _expect_direction(actual: Vector3, expected: Vector3, description: String) -> void:
	if not actual.is_equal_approx(expected):
		failures += 1
		push_error("%s produced %s, expected %s." % [description, actual, expected])
