extends Panel

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var well_paused = false


func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func _process(delta):
	# Called every frame. Delta is time since last frame.
	# Update game logic here.
	if Input.is_action_just_released("ui_select"):
		if well_paused:
			well_paused = false
			get_tree().paused = false
			self.hide()
	
	if Input.is_action_just_released("ui_pause"):
		well_paused = true

	if well_paused and Input.is_action_pressed("ui_pause"):
		get_tree().paused = false
		$"../..".title_screen()

