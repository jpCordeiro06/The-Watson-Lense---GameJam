# FadeTransition.gd
extends CanvasLayer

@onready var color_rect: ColorRect = $ColorRect
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready():
	# Garante que o jogo comece visível
	animation_player.play("fade_in")

# Esta é a nossa nova função de transição
func change_scene(scene_path: String):
	# 1. Escurece a tela
	animation_player.play("fade_out")
	# 2. Espera a animação de fade terminar
	await animation_player.animation_finished
	
	# 3. Muda a cena (enquanto a tela está preta)
	get_tree().change_scene_to_file(scene_path)
	
	# 4. Clareia a tela na nova cena
	animation_player.play("fade_in")
