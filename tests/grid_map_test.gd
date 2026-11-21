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

	var negative_cell := Vector3i(-1, 0, 0)
	var target_cell := Vector3i.ZERO
	var positive_cell := Vector3i(1, 0, 0)
	grid.create_block(Vector3(-0.01, 1.0, 1.0), 2)
	grid.create_block(Vector3(0.0, 1.0, 1.0), 4)
	grid.create_block(Vector3(2.0, 1.0, 1.0), 6)
	_expect(grid.get_cell_item(negative_cell) == 2, "A negative coordinate just below zero must land in the negative cell.")
	_expect(grid.get_cell_item(target_cell) == 4, "Zero must land in the cell on the positive side of the boundary.")
	_expect(grid.get_cell_item(positive_cell) == 6, "The next exact boundary must land in the next cell.")

	var target_coordinate := Vector3(1.99, 1.0, 1.0)
	grid.create_block(target_coordinate, 5)
	_expect(grid.get_cell_item(target_cell) == 5, "Creating a block in an occupied cell must replace it.")
	_expect(grid.get_cell_item(negative_cell) == 2 and grid.get_cell_item(positive_cell) == 6, "Replacing a block must preserve its neighbors.")

	grid.destroy_block(target_coordinate)
	grid.destroy_block(target_coordinate)
	_expect(grid.get_cell_item(target_cell) == GridMap.INVALID_CELL_ITEM, "Repeated destruction must leave the target cell empty.")
	_expect(grid.get_cell_item(negative_cell) == 2 and grid.get_cell_item(positive_cell) == 6, "Destroying a block must preserve its neighbors.")

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
