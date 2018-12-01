extends Node


func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass


func _input(event):
	if event.is_action_pressed("ui_select") or event.is_action_pressed("ui_accept"):
		get_parent().new_game()
	elif event.is_action_pressed("ui_pause"):
		get_parent().exit_game()

