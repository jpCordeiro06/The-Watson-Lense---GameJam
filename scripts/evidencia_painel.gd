# EvidenciaPainel.gd
extends Panel

# Sinal para notificar o painel principal que estamos sendo movidos (para as linhas)
signal being_dragged

var is_dragging: bool = false
var is_pinned: bool = false
var drag_offset: Vector2 # Para o arrastar não "pular" para o cursor

# Função para configurar a aparência desta "foto"
func configurar(imagem: Texture2D, nome_pista: String):
	$TextureRect.texture = imagem
	$Label.text = nome_pista
	# Cria uma cópia do estilo para que cada instância possa ter sua própria cor de borda
	# sem afetar as outras. Isso é importante para o feedback de "fixado".
	var style_override = get("theme_override_styles/panel").duplicate()
	set("theme_override_styles/panel", style_override)

# Esta função nativa do Godot lida com inputs do mouse diretamente no controle da UI
func _gui_input(event: InputEvent):
	# Se a evidência estiver fixada, não podemos movê-la.
	if is_pinned:
		# Permitimos desafixar, no entanto.
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.is_pressed():
			set_pinned(false)
		return
		
	# Iniciar o arrastar com o botão esquerdo do mouse
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			is_dragging = true
			drag_offset = get_global_mouse_position() - global_position
		else:
			is_dragging = false
			
	# Fixar a evidência com o botão direito
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.is_pressed():
		set_pinned(true)

# Atualiza a posição da "foto" enquanto está sendo arrastada
func _process(delta: float):
	if is_dragging:
		global_position = get_global_mouse_position() - drag_offset
		emit_signal("being_dragged") # Avisa o painel principal para redesenhar as linhas

# Função para mudar o estado de "fixado" e dar feedback visual
func set_pinned(pinned_status: bool):
	is_pinned = pinned_status
	var stylebox = get("theme_override_styles/panel") as StyleBoxFlat
	
	if is_pinned:
		# Mudar a cor para dar feedback visual de que está fixado
		stylebox.set_border_color(Color.GOLD) 
	else:
		# Cor normal (a mesma do seu tema)
		stylebox.set_border_color(Color("#00f0ff"))
