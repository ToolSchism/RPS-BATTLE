extends Button
@onready var label: Label = $"../Label"
@onready var texture_rect: TextureRect = $"../TextureRect"

var progress = 1
const MAX_MESSAGES = 5

const RPS_1 = preload("res://screenshots/RPS1.PNG")
const RPS_2 = preload("res://screenshots/RPS2.PNG")
const RPS_3 = preload("res://screenshots/RPS3.PNG")
const RPS_4 = preload("res://screenshots/RPS4.PNG")
const RPS_5 = preload("res://screenshots/RPS5.PNG")

const MESSAGES = {
	"1": {"message": "This is what happens in the non-demo when you press join and create.", "image": RPS_1},
	"2": {"message": "These are the create/join functions in network from the previous screenshot", "image": RPS_2},
	"3": {"message": "This is my first time working with threading stuff so I put it in allllll the functions lol", "image": RPS_3},
	"4": {"message": "It uses UPnP which is another first! This makes it so people don't have to open ports on their network manually.", "image": RPS_4},
	"5": {"message": "It's quite a mess, but this is the final section of networking. The rest uses rpc and stuff like that to send the data of the names and choices of the players.", "image": RPS_5}
}

func _ready() -> void:
	update_message(progress)

func _on_pressed() -> void:
	Trans.send("res://scenes/connection_menu.tscn")

func previous_message() -> void:
	progress -= 1
	if progress < 1:
		progress = MAX_MESSAGES
	update_message(progress)

func next_message() -> void:
	progress += 1
	if progress > MAX_MESSAGES:
		progress = 1
	update_message(progress)

func update_message(msg_number: int) -> void:
	var msg_key = str(msg_number)
	label.text = MESSAGES[msg_key]["message"]
	texture_rect.texture = MESSAGES[msg_key]["image"]
