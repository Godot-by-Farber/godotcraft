extends SceneTree

var failures := 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var grid = load("res://scripts/grid_map.gd").new()
	grid.cell_size = Vector3.ONE * 2.0
	root.add_child(grid)
	var coordinate := Vector3(3.1, 1.0, -1.0)
	var cell: Vector3i = grid.local_to_map(coordinate)
	grid.create_block(coordinate, 4)
	_expect(grid.get_cell_item(cell) == 4, "Creating a block must set the selected cell item.")
	grid.destroy_block(coordinate)
	_expect(grid.get_cell_item(cell) == GridMap.INVALID_CELL_ITEM, "Destroying a block must empty its cell.")
	grid.position = Vector3(10, 2, -4)
	grid.rotation.y = PI / 2
	var snapped: Transform3D = grid.get_snapped_transform(coordinate)
	_expect(snapped.origin.is_equal_approx(grid.to_global(grid.map_to_local(cell))), "Snapping must return the cell center in global space.")
	_expect(snapped.basis.is_equal_approx(grid.global_transform.basis), "Snapping must preserve the grid basis.")
	grid.free()
	quit(1 if failures else 0)

func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error(message)
