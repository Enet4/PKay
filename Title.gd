extends Node

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	$"margin/vbox/vbox/BtnNew".grab_focus()
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass


func _on_BtnNew_button_down():
	get_parent().new_game()


func _on_BtnInstr_button_down():
	get_parent().open_instructions()


func _on_BtnExit_button_down():
	get_parent().exit_game()

