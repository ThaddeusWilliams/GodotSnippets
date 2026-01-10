@tool 
class_name CollisionCone2D
extends CollisionPolygon2D
@export_range(20, 270) var angle : float = 80
@export_range(4, 1000) var length : float = 32
@export_range(-10, 256) var spacing : int = 0

var length_point = Vector2()

func lengthdir_x(length, direction_degrees):
	var radians = deg_to_rad(direction_degrees)  # Convert degrees to radians
	return length * cos(radians)  # Calculate x coordinate

func lengthdir_y(length, direction_degrees):
	var radians = deg_to_rad(direction_degrees)  # Convert degrees to radians
	return length * sin(radians)  # Calculate y coordinate

func _property_can_revert(property):
	update()
func update():
	var _points = [Vector2.ZERO]
	var total = angle
	for i in total:
		var x = lengthdir_x(length, i - angle / 2)
		var y = lengthdir_y(length, i - angle / 2)
		if i < angle:
			if int(i) % spacing == 0:
				_points.append(Vector2(x,y))
	#set_point_cloud(_points)
	polygon = _points
	length_point.x = length


