extends Control

@onready var status_label: Label = $Background/StatusLabel
@onready var join_game_button: Button = $GridContainer/Join
@onready var create_game_button: Button = $GridContainer/Create
@onready var ip_input: TextEdit = $IPInput

func _ready():
	Network.connected.connect(_on_connection_succeeded)
	Network.failedToConnect.connect(_on_connection_failed)
	Network.gameReady.connect(_on_game_ready)
	Network.networkProgress.connect(_update_status)
	
	create_game_button.pressed.connect(_on_create_game_pressed)
	join_game_button.pressed.connect(_on_join_game_pressed)

func _on_create_game_pressed():
	Network.create_game()
	status_label.text = "Waiting for opponent..."
	create_game_button.disabled = true
	join_game_button.disabled = true

func _on_join_game_pressed():
	var ip = ip_input.text if ip_input.text else "127.0.0.1"
	Network.join_game(ip)
	status_label.text = "Connecting..."
	create_game_button.disabled = true
	join_game_button.disabled = true

func _on_connection_succeeded():
	status_label.text = "Connected! Waiting for game to start..."

func _on_connection_failed():
	status_label.text = "Connection Failed"
	create_game_button.disabled = false
	join_game_button.disabled = false

func _on_game_ready():
	Trans.send("res://scenes/game_scene.tscn")
	
func _update_status(message, percent):
	status_label.text = "%s%% - %s" % [percent, message]
