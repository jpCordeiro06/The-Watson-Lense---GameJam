extends PanelContainer

const EVIDENCIA_UI_SCENE = preload("res://cenas/EvidenciaUI.tscn")

@onready var grid: GridContainer = $GridContainer

func adicionar_evidencia(id_da_pista: String):
	var nova_evidencia_ui = EVIDENCIA_UI_SCENE.instantiate()

	var imagem = load("res://caminho/para/imagem_da_" + id_da_pista + ".png")
	var texto = "Evidência: " + id_da_pista.capitalize()

	nova_evidencia_ui.configurar(imagem, texto)
	grid.add_child(nova_evidencia_ui)


func _on_timer_timeout() -> void:
	pass # Replace with function body.
