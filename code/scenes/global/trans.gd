extends Control

@onready var animation_player = $AnimationPlayer
signal sent

func _ready():
	hide()
	
func send(target: String):
	show()
	animation_player.play("trans")
	await animation_player.animation_finished
	await get_tree().change_scene_to_file(target)
	animation_player.play_backwards("trans")
	await animation_player.animation_finished
	sent.emit()
	hide()
