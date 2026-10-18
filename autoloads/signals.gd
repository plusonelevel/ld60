extends Node

signal game_start

signal interactable_changed(is_interactable: bool)
signal player_state_changed(state: Enums.PlayerState)
signal gun_loaded
signal gun_primed
signal gun_fired

signal status_message(String)

signal lamp_lit(int)
