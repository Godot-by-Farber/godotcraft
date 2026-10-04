extends SceneTree

var failures := 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	for path in ["res://scenes/main_menu.tscn", "res://scenes/world.tscn", "res://scenes/player.tscn", "res://scenes/hotbar.tscn"]:
		var packed := load(path) as PackedScene
		_expect(packed != null, "%s must load with its resources." % path)
		if packed:
			var instance := packed.instantiate()
			_expect(instance != null, "%s must instantiate." % path)
			if instance:
				instance.free()
	var startup := str(ProjectSettings.get_setting("application/run/main_scene"))
	_expect(load(startup) is PackedScene, "The configured startup scene must resolve after import.")
	var menu: Node = load("res://scenes/main_menu.tscn").instantiate()
	root.add_child(menu)
	await process_frame
	_expect(menu.get_node("VBoxContainer/NewGameButton").has_focus(), "New Game must initially have focus for controller navigation.")
	menu.free()
	quit(1 if failures else 0)

func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error(message)
