extends Panel

var well_paused = false


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

