extends Node

const MAX_INFLUENCE = 2
const START_COINS = 2
const INFLUENCE_TYPES = ["Duque", "Asesino", "Capitan", "Embajador", "Condesa"]

var players = []
var deck = []
var treasury = 50
var currently_player_index = 0

#iniciar juego
func init_game (player_names : Array):
	for type in INFLUENCE_TYPES:
		for i in range(3):
			deck.append(type)
	deck.shuffle()
	
	#iniciar jugadores
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

func draw_card():
	if deck.size()>0:
		return deck.pop_back()
	return null

func get_current_player():
	return players[currently_player_index]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
