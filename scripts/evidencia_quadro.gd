# EvidenciaNoQuadro.gd
extends PanelContainer

# Sinaliza ao quadro principal que este item foi clicado (para criar conexões)
signal clicado(evidencia_node)
# Sinaliza ao quadro principal que este item está sendo arrastado (para redesenhar linhas)
signal arrastado

signal inspecionado(evidencia_id)

# Referências
@onready var texture_rect: TextureRect = $VBoxContainer/TextureRect
@onready var label: Label = $VBoxContainer/Label

# Estado de arrastar
var is_dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO

# Função para receber os dados quando o item é "dropado" no quadro
func set_data(id: String, nome: String, sprite: Texture2D):
	# Define o nome do nó com o ID da evidência para fácil referência
	self.name = id
	
	# Configura o visual
	texture_rect.texture = sprite
	
	# Duplica o estilo para que a cor da borda possa ser mudada
	# individualmente (para feedback de seleção) sem afetar os outros.
	var style_override = StyleBoxFlat.new()

	# 2. Define as propriedades dele para bater com seu GameTheme.
	style_override.bg_color = Color("#20202a") # Fundo Carvão Digital
	style_override.border_width_left = 3
	style_override.border_width_top = 3
	style_override.border_width_right = 3
	style_override.border_width_bottom = 3
	style_override.border_color = Color("#00d9ff") # Borda Ciano Neon
	style_override.content_margin_left = 8
	style_override.content_margin_top = 8
	style_override.content_margin_right = 8
	style_override.content_margin_bottom = 8

	# 3. Aplica este novo estilo criado como o override local.
	set("theme_override_styles/panel", style_override)

# Função que lida com os cliques do mouse neste item
func _gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.double_click:
		print("Evidência ", name, " inspecionada (double-click)")
		emit_signal("inspecionado", name) # 'name' é o ID da evidência
		return # Impede que o "drag" comece
	# Arrastar com o Botão Esquerdo
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			is_dragging = true
			drag_offset = get_global_mouse_position() - global_position
			# Trocamos pela função alternativa
			move_to_front() 
		else:
			is_dragging = false
			
	# Selecionar para Conexão com o Botão Direito
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.is_pressed():
		# Avisa o script "QuadroConexoes.gd" que este item foi clicado.
		emit_signal("clicado", self)

# Atualiza a posição do item enquanto é arrastado
func _process(delta: float):
	if is_dragging:
		# Define a nova posição global
		global_position = get_global_mouse_position() - drag_offset
		# Avisa o quadro principal para redesenhar as linhas de conexão
		emit_signal("arrastado")

# Funções públicas para o quadro principal controlar o feedback visual
func selecionar():
	var stylebox = get("theme_override_styles/panel") as StyleBoxFlat
	
	# --- DEBUG ---
	print("Tentando SELECIONAR. Stylebox encontrado: ", stylebox != null)
	
	if stylebox:
		print("  > Cor da borda ANTES: ", stylebox.border_color)
		stylebox.set_border_color(Color.GOLD)
		print("  > Cor da borda AGORA: ", stylebox.border_color)
	else:
		print("  > ERRO: Stylebox não encontrado em selecionar()")

func deselecionar():
	var stylebox = get("theme_override_styles/panel") as StyleBoxFlat
	
	# --- DEBUG ---
	print("Tentando DESELECIONAR. Stylebox encontrado: ", stylebox != null)
	
	if stylebox:
		stylebox.set_border_color(Color("#00d9ff")) # Cor padrão (ciano neon)
	else:
		print("  > ERRO: Stylebox não encontrado em deselecionar()")
