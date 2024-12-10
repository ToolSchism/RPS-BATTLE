extends Control

@onready var status_label: Label = $Background/StatusLabel
@onready var join_game_button: Button = $GridContainer/Join
@onready var create_game_button: Button = $GridContainer/Create
@onready var ip_input: TextEdit = $IPInput

func _ready():
	create_game_button.pressed.connect(_on_create_game_pressed)
	join_game_button.pressed.connect(_on_join_game_pressed)

func _on_create_game_pressed():
	status_label.text = "99% - This would make a server outside the demo version"
	create_game_button.disabled = true
	join_game_button.disabled = true
	
	await get_tree().create_timer(2.0).timeout
	Trans.send("res://scenes/game_scene.tscn")

func _on_join_game_pressed():
	status_label.text = "99% - This would connect to a server outside the demo version"
	create_game_button.disabled = true
	join_game_button.disabled = true
	
	await get_tree().create_timer(2.0).timeout
	Trans.send("res://scenes/game_scene.tscn")


func _on_nerd_stuff_pressed() -> void:
	Trans.send("res://scenes/info.tscn")
