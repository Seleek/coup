extends Node

const MAX_INFLUENCE = 2
const START_COINS = 2
const INFLUENCE_TYPES = ["Duque", "Asesino", "Capitan", "Embajador", "Condesa"]
const ACTION_COSTS = {"Asesinar" : 3, "Coup" : 7}

enum GameState{
	WAITING_FOR_ACTION,
	WAITING_FOR_CHALLENGE,
	WAITING_FOR_BLOCK,
	RESOLVING_CHALLENGE,
	RESOLVING_BLOCK_CHALLENGE,
	EXECUTING_ACTION,
	INFLUENCE_LOSS
}

var players = []
var deck = []
var treasury = 50
var currently_player_index = 0
var current_game_state = GameState.WAITING_FOR_ACTION

var active_action = {}
signal game_state_changed
signal log_message(message)
signal action_requested(player_index, options)

#iniciar juego
func init_game (player_names : Array):
	deck.clear()
	for type in INFLUENCE_TYPES:
		for i in range(3):
			deck.append(type)
	deck.shuffle()
	
	#iniciar jugadores
	players.clear()
	for name in player_names:
		var new_player = {
			"name": name,
			"coins": START_COINS,
			"influence": [draw_card(), draw_card()],
			"revealed_influence":[],
			"is_out": false
		}
		players.append(new_player)
	currently_player_index=0
	current_game_state = GameState.WAITING_FOR_ACTION
	emit_signal("game_state_changed")
	emit_signal("log_message", "El juego ha comenzado. Empieza %s." % get_current_player().name)

func draw_card():
	if deck.size()>0:
		return deck.pop_back()
	return null

func get_player(index):
	return players[index]

func get_current_player():
	return players[currently_player_index]
	

	
	
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
