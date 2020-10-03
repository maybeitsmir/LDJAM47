extends Area2D


func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.is_pressed():
		self.on_click()
 
func on_click():
	$BarTapSprite.frame = 1
	$PourTimer.start()

func _on_PourTimer_timeout():
	$BarTapSprite.frame = 0
	
