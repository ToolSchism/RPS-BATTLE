extends Node
const CONNECTION_MENU = preload("res://scenes/connection_menu.tscn")

func _on_button_pressed() -> void:
	Trans.send("res://scenes/connection_menu.tscn")
