extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var acc = 0

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	$LblStory.rect_position.y = 390
	$LblStory.text = """
	After multiple intense waves of battles, you take
	a deep breath. The scraps of your enemies lay
	scattered over the vast plane, with no signs of
	adversarial life in the distance. 
	
	
	Just as you exit the battle paddle, you are met
	with a warm applause from the crew. Undeniably,
	a large celebration of your victory
	will take place tonight.
	

	The city is safe for now. Whoever dared
	to test the forces of Einnor will think
	twice before ever coming back. 

	
	Congratulations!
	
	Thank you for playing!
	"""


func _process(delta):
	acc += delta
	if acc >= 0.035:
		$LblStory.rect_position.y -= 1
		acc -= 0.035

	if Input.is_action_just_pressed("ui_pause"):
		get_parent().title_screen()


func _on_Timer_timeout():
	get_parent().title_screen()
