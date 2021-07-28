extends Area2D

func _on_Item_body_entered(body):
	set_collision_mask_bit(0, false)
	PlayerVariables.treasure += 1 # update player treasure count
	get_tree().call_group("Gui", "update_coin_counter") # update gui coin tracker
	$AnimatedSprite.play("die")
	yield($AnimatedSprite, "animation_finished")
	queue_free()

	
