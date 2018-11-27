extends Node2D

# class member variables go here, for example:
export (String) var upgrade_name = ""
export (String) var upgrade_description = ""
export (String) var upgrade_id = ""
export (int) var upgrade_level = 0
export (int) var maximum_upgrade = 1
export (Array) var price = [10, 20, 40, 80]

# request_purchase((Upgrade) upgrade, (int) next_level, (int) price)
signal request_purchase
signal change_level

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	$"vbox/hbox/BtnBuy".text = self.upgrade_name
	$"vbox/LblDescription".text = self.upgrade_description
	self._update_cost_label()
	if self.maximum_upgrade < 4:
		$"vbox/hbox/up4".hide()
	if self.maximum_upgrade < 3:
		$"vbox/hbox/up3".hide()
	if self.maximum_upgrade < 2:
		$"vbox/hbox/up2".hide()


func grab_focus():
	$"vbox/hbox/BtnBuy".grab_focus()


#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass


func set_level(level):
	self.upgrade_level = level
	if level >= 4:
		$"vbox/hbox/up4".modulate = Color("#ffffff19")
	else:
		$"vbox/hbox/up4".modulate = Color("#ff191919")
	if level >= 3:
		$"vbox/hbox/up3".modulate = Color("#ffffff19")
	else:
		$"vbox/hbox/up3".modulate = Color("#ff191919")
	if level >= 2:
		$"vbox/hbox/up2".modulate = Color("#ffffff19")
	else:
		$"vbox/hbox/up2".modulate = Color("#ff191919")
	if level >= 1:
		$"vbox/hbox/up1".modulate = Color("#ffffff19")
	else:
		$"vbox/hbox/up1".modulate = Color("#ff191919")
	self._update_cost_label()


func _on_upgrade_change_level(level):
	self.set_level(level)


func _update_cost_label():
	if self.upgrade_level == self.maximum_upgrade:
		$"vbox/LblCost".text = "Maximized"
	else:
		$"vbox/LblCost".text = "Cost: " + str(self.price[self.upgrade_level])


func _on_BtnBuy_pressed():
	if self.maximum_upgrade > self.upgrade_level:
		var next_level = self.upgrade_level + 1
		self.emit_signal("request_purchase", self, next_level, self.price[self.upgrade_level])
