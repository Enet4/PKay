extends Node2D

export var y_direction = 1

func _on_floor_area_entered(area):
	if area.get_parent().get_name() == "PlainBall":
		# just bounce, no dampening
		area.linear_velocity.y = -abs(area.linear_velocity.y)

func _on_ceiling_area_entered(area):
	if area.get_parent().get_name() == "PlainBall":
		# just bounce, no dampening
		area.linear_velocity.y = abs(area.linear_velocity.y)