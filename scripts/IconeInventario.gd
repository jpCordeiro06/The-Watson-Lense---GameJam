# IconeInventario.gd
extends PanelContainer

# Vamos armazenar os dados da evidência aqui
var id: String
var nome: String
var sprite: Texture2D
var type: String = "evidencia_inventario" # O tipo que o "Dropper" procura

# Esta é a função mágica do Godot 4. Ela é chamada AUTOMATICAMENTE
# pelo motor quando um clique e arrasto começa neste nó.
func _get_drag_data(at_position) -> Variant:
	
	print("Drag iniciado para: ", nome)
	
	# 1. Os dados que queremos "carregar"
	var data = {
		"id": id,
		"nome": nome,
		"sprite": sprite,
		"type": type
	}
	
	# 2. A pré-visualização (o que segue o mouse)
	var preview = TextureRect.new()
	preview.texture = sprite
	preview.custom_minimum_size = Vector2(40, 40)
	preview.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	
	# 3. Define a pré-visualização e retorna os dados
	set_drag_preview(preview)
	return data
