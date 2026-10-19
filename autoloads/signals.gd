extends Node

signal interactable_changed(is_interactable: bool)
signal player_state_changed(state: Enums.PlayerState)
signal kerosene_toggled(is_equipped: bool)
signal kerosene_amount_changed(new_amount: int)
signal gun_state_changed(state: Enums.GunState)
signal enemy_died(enemy: Variant)

signal status_message(String)

signal lamp_lit(lamp_id: int)
signal lamp_door_opened(is_open: bool)

signal tutorial_advanced(idx: int)

signal aim_prompt_changed(text: String)

signal player_took_damage

signal game_over
signal win
