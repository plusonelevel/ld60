extends Node

signal interactable_changed(is_interactable: bool)
signal player_state_changed(state: Enums.PlayerState)
signal kerosene_amount_changed(new_amount: int)
signal gun_state_changed(state: Enums.GunState)

signal status_message(String)

signal lamp_lit(int)
signal activate_spawners(int)

signal aim_prompt_changed(text: String)
