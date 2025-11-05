# Instrucoes.gd
extends Control

func _on_button_pressed():
	# Muda para a sua cena principal do jogo.
	# Verifique se o caminho está correto!
	get_tree().change_scene_to_file("res://cenas/Sala.tscn")


func _on_creditos_button_pressed() -> void:
	get_tree().change_scene_to_file("res://cenas/creditos.tscn")
