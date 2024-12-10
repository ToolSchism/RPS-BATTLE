extends Control
@onready var rounds: Label = $Rounds
var player_wins: int = 0
var bot_wins: int = 0

# Possible choices
enum Choice {
	ROCK,
	PAPER,
	SCISSORS
}

# Player choices
var local_choice = null
var bot_choice = null

@onready var result_label: Label = $Background/ResultLabel
@onready var scissors_button: Button = $GridContainer/Scissors
@onready var paper_button: Button = $GridContainer/Paper
@onready var rock_button: Button = $GridContainer/Rock

func _ready():
	# Connect button signals
	rock_button.pressed.connect(func(): submit_player_choice(Choice.ROCK))
	paper_button.pressed.connect(func(): submit_player_choice(Choice.PAPER))
	scissors_button.pressed.connect(func(): submit_player_choice(Choice.SCISSORS))

	# Set initial labels
	$Background/PlayerNameLabel.text = "Player"
	$Background/OpponentNameLabel.text = "Bot"

func submit_player_choice(choice):
	if local_choice == null:
		local_choice = choice
		print("Player submitted choice: ", choice)
		
		# Bot makes a random choice
		bot_choice = Choice.values()[randi() % Choice.values().size()]
		print("Bot chose: ", bot_choice)
		
		# Determine the winner
		determine_winner()
		
		# Disable buttons after choice
		disable_choice_buttons()

# Disable choice buttons after selection
func disable_choice_buttons():
	rock_button.disabled = true
	paper_button.disabled = true
	scissors_button.disabled = true

# Determine the game winner
func determine_winner():
	var result = ""
	var winner_name = ""
	
	if local_choice == bot_choice:
		result = "It's a Tie!"
		winner_name = "No one"
	elif (
		(local_choice == Choice.ROCK and bot_choice == Choice.SCISSORS) or
		(local_choice == Choice.PAPER and bot_choice == Choice.ROCK) or
		(local_choice == Choice.SCISSORS and bot_choice == Choice.PAPER)
	):
		result = "You Win!"
		player_wins += 1
		winner_name = "Player"
	else:
		result = "Bot Wins!"
		bot_wins += 1
		winner_name = "Bot"
	
	rounds.text = "%s - %s" % [player_wins, bot_wins]
	print("Result determined: ", result, " Winner: ", winner_name)
	
	# Display the result
	show_result(result, winner_name)

# Display result and reset for next round
func show_result(result, winner_name):
	print("Showing result - Winner: ", winner_name, " Result: ", result)
	result_label.text = "%s wins!" % [winner_name]
	
	# Reset for next round
	await get_tree().create_timer(2.0).timeout
	result_label.text = "Reset!"
	await get_tree().create_timer(0.75).timeout
	result_label.text = ""
	
	# Reset choices and re-enable buttons
	local_choice = null
	bot_choice = null
	rock_button.disabled = false
	paper_button.disabled = false
	scissors_button.disabled = false
