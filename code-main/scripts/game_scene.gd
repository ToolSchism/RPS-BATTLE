extends Control

# Possible choices
enum Choice {
	ROCK,
	PAPER,
	SCISSORS
}

# Player choices
var local_choice = null
var opponent_choice = null
var local_peer_id = 0

var local_wins: int = 0
var opponent_wins: int = 0

@onready var result_label: Label = $Background/ResultLabel
@onready var scissors_button: Button = $GridContainer/Scissors
@onready var paper_button: Button = $GridContainer/Paper
@onready var rock_button: Button = $GridContainer/Rock

func _ready():
	# this hurts my head
	local_peer_id = multiplayer.get_unique_id()
	print("Local Peer ID: ", local_peer_id)
	
	multiplayer.peer_connected.connect(on_player_connected)
	multiplayer.peer_disconnected.connect(on_player_disconnected)
	
	rock_button.pressed.connect(func(): submit_choice(Choice.ROCK))
	paper_button.pressed.connect(func(): submit_choice(Choice.PAPER))
	scissors_button.pressed.connect(func(): submit_choice(Choice.SCISSORS))

	$Background/PlayerNameLabel.text = Network.player_name
	$Background/OpponentNameLabel.text = Network.opponent_name

func submit_choice(choice):
	if local_choice == null:
		print("Player submitting choice: ", choice)
		local_choice = choice
		
		if multiplayer.is_server():
			# If server, directly process the choice
			server_receive_player_choice.rpc(local_peer_id, choice)
		else:
			# If client, send RPC to server
			rpc_id(1, "server_receive_player_choice", local_peer_id, choice)
		
		disable_choice_buttons()

# Server-side choice collection
@rpc("call_local", "any_peer", "reliable")
func server_receive_player_choice(sender_id, choice):
	print("Server received choice - Sender ID: ", sender_id, " Choice: ", choice)
	
	# This function will only run on the server
	if not multiplayer.is_server():
		print("Not server, ignoring choice")
		return
	
	# Determine which player submitted the choice
	if sender_id == local_peer_id:
		local_choice = choice
		print("Local player choice set: ", local_choice)
	else:
		opponent_choice = choice
		print("Opponent choice set: ", opponent_choice)
	
	# Check if both choices are in
	if local_choice != null and opponent_choice != null:
		print("Both choices received. Determining winner.")
		determine_winner()

# Disable choice buttons after selection
func disable_choice_buttons():
	rock_button.disabled = true
	paper_button.disabled = true
	scissors_button.disabled = true

func _process(delta: float) -> void:
	# Update labels with current network names
	$Background/PlayerNameLabel.text = Network.player_name
	$Background/OpponentNameLabel.text = Network.opponent_name
	
# Determine the game winner (only called on server)
func determine_winner():
	print("Determining winner with choices - Local: ", local_choice, " Opponent: ", opponent_choice)
	var result = ""
	var winner_name = ""
	
	if local_choice == opponent_choice:
		result = "It's a Tie!"
		winner_name = "No one"
	elif (
		(local_choice == Choice.ROCK and opponent_choice == Choice.SCISSORS) or
		(local_choice == Choice.PAPER and opponent_choice == Choice.ROCK) or
		(local_choice == Choice.SCISSORS and opponent_choice == Choice.PAPER)
	):
		result = "You Win!"
		local_wins += 1
		winner_name = Network.player_name
	else:
		result = "Opponent Wins!"
		opponent_wins += 1
		winner_name = Network.opponent_name
	
	print("Result determined: ", result, " Winner: ", winner_name)
	rpc("show_result", result, winner_name, local_wins, opponent_wins)


@rpc("call_local", "authority", "reliable")
func show_result(result, winner_name, local_score, opponent_score):
	print("Showing result - Winner: ", winner_name, " Result: ", result)
	result_label.text = "%s wins!" % [winner_name]
	
	$Rounds.text = "%s - %s" % [local_score, opponent_score]
	
	local_choice = null
	opponent_choice = null
	
	await get_tree().create_timer(2.0).timeout
	result_label.text = "Reset!"
	await get_tree().create_timer(0.75).timeout
	result_label.text = ""
	rock_button.disabled = false
	paper_button.disabled = false
	scissors_button.disabled = false

func on_player_connected(id):
	print("Player connected with ID: ", id)

	result_label.text = ""
	rock_button.disabled = false
	paper_button.disabled = false
	scissors_button.disabled = false

func on_player_disconnected(id):
	print("Player disconnected with ID: ", id)
	result_label.text = "Opponent Disconnected"
	$Background/OpponentNameLabel.text = "Nobody's here?!"
	local_choice = null
	opponent_choice = null
	rock_button.disabled = true
	paper_button.disabled = true
	scissors_button.disabled = true
