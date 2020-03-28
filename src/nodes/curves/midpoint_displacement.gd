tool
extends ConceptNode

"""
Apply the midpoint displacement algorithm to a curve. Useful to randomize an existing curve path
"""

var _rng: RandomNumberGenerator

func _init() -> void:
	node_title = "Midpoint displacement"
	category = "Curves/Operations"
	description = "Randomize a curve using midpoint displacement. This creates new points in the curve."

	set_input(0, "Curve", ConceptGraphDataType.CURVE)
	set_input(1, "Seed", ConceptGraphDataType.SCALAR, {"step": 1})
	set_input(2, "Steps", ConceptGraphDataType.SCALAR,
		{"step": 1, "min": 0, "allow_lesser": false, "value": 1})
	set_input(3, "Factor", ConceptGraphDataType.SCALAR, {"value": 1})
	set_input(4, "Attenuation %", ConceptGraphDataType.SCALAR, {"value": 50})
	set_input(5, "Axis", ConceptGraphDataType.VECTOR)
	set_input(6, "Min segment size", ConceptGraphDataType.SCALAR,
		{"min": 0.01, "allow_lesser": false, "value": 1})
	set_output(0, "", ConceptGraphDataType.CURVE)


func get_output(idx: int) -> Path:
	var path: Path = get_input(0)
	if not path:
		print("No path found")
		return null

	var random_seed: int = get_input(1, 0)
	_rng = RandomNumberGenerator.new()
	_rng.seed = random_seed

	var steps: int = get_input(2, 1)
	var factor: float = get_input(3, 1.0)
	var attenuation: float = 1.0 - (get_input(4, 50.0) / 100.0)

	for i in range(steps):
		_displace(path, factor)
		factor *= attenuation

	return path


func _displace(path: Path, factor: float) -> Path:
	if path.curve.get_point_count() < 2:
		return path

	var axis: Vector3 = get_input(5, Vector3.ZERO)
	var min_size: float = get_input(6, 1.0)

	var i := 1
	var start: Vector3 = path.curve.get_point_position(0)
	var end: Vector3 = path.curve.get_point_position(1)
	var done := false

	while not done:
		var dist = start.distance_to(end)
		if dist > min_size:
			var dir
			if axis == Vector3.ZERO:
				dir = _rand_vector()
			else:
				dir = (end - start).cross(axis).normalized()

			var deviation = factor * dist * 0.1
			var midpoint = start + (end - start) / 2.0
			midpoint += dir * _rng.randf_range(-deviation, deviation)

			path.curve.add_point(midpoint, Vector3.ZERO, Vector3.ZERO, i)
			i += 2
		else:
			i += 1

		if i < path.curve.get_point_count():
			start = end
			end = path.curve.get_point_position(i)
		else:
			done = true

	return path


func _rand_vector() -> Vector3:
	var v = Vector3(_rng.randf_range(-1.0, 1.0), _rng.randf_range(-1.0, 1.0), _rng.randf_range(-1.0, 1.0))
	return v.normalized()
