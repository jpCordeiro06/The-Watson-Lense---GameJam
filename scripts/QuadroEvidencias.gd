extends CanvasLayer


# Sinais
signal evidencia_inspecionada(id_evidencia: String)

# Referências de UI
@onready var painel_principal: Panel = $PainelPrincipal
@onready var btn_fechar: Button = $PainelPrincipal/Header/BtnFechar
@onready var lista_evidencias: VBoxContainer = $PainelPrincipal/HBoxContainer/InventarioScroll/ListaEvidencias
@onready var quadro_conexoes: Control = $PainelPrincipal/HBoxContainer/QuadroConexoes

# Estado
var aberto: bool = false
var evidencias_coletadas: Dictionary = {}  # {id: {nome, sprite, posicao, conexoes}}
var evidencia_selecionada: PanelContainer = null
var conexoes: Array = [] # Vai guardar pares de evidências [evidencia_a, evidencia_b]

# Configurações
const LARGURA_PAINEL = 0.85  # 85% da tela (408px de 480px)
const ALTURA_PAINEL = 0.85   # 85% da tela (229px de 270px)
const DURACAO_ANIMACAO = 0.3  # Mais rápido para tela pequena
const ICONE_INVENTARIO_SCRIPT = preload("res://scripts/IconeInventario.gd")
const EVIDENCIA_NO_QUADRO_SCENE = preload("res://cenas/EvidenciaQuadro.tscn")
const RESUMO_UI_SCENE = preload("res://cenas/ResumoUI.tscn")

func _ready():
	print("=== DEBUG QuadroEvidencias ===")
	print("PainelPrincipal existe? ", painel_principal != null)
	
	# IMPORTANTE: Forçar visibilidade do painel
	if painel_principal:
		painel_principal.visible = true
	
	# Configurar tamanho do painel
	_ajustar_tamanho()
	
	# Esconder no início (após ajustar tamanho)
	var viewport_size = get_viewport().get_visible_rect().size
	var pos_escondida = -painel_principal.size.x - 50  # Garante que fica fora da tela
	painel_principal.position.x = pos_escondida
	
	print("Posição inicial X: ", painel_principal.position.x)
	print("Tamanho do painel: ", painel_principal.size)
	print("Viewport size: ", viewport_size)
	
	# Conectar botão fechar
	if btn_fechar:
		btn_fechar.pressed.connect(_on_btn_fechar_pressed)
		print("Botão fechar conectado!")
	else:
		print("AVISO: Botão fechar não encontrado!")
	
	if quadro_conexoes:
		quadro_conexoes.evidencia_largada.connect(_on_evidencia_largada_no_quadro)
	
func _ajustar_tamanho():
	var viewport_size = get_viewport().get_visible_rect().size
	var largura = viewport_size.x * LARGURA_PAINEL
	var altura = viewport_size.y * ALTURA_PAINEL
	
	painel_principal.custom_minimum_size = Vector2(largura, altura)
	painel_principal.size = Vector2(largura, altura)
	
	# Centralizar verticalmente
	painel_principal.position.y = (viewport_size.y - altura) / 2

func abrir():
	print("=== Função ABRIR chamada ===")
	
	if aberto:
		print("Já está aberto, ignorando...")
		return
	
	print("Abrindo quadro...")
	aberto = true
	get_tree().paused = true
	
	# Animar slide da esquerda para direita
	var tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)  # Continua mesmo com jogo pausado
	
	var posicao_final = Vector2.ZERO
	posicao_final.y = painel_principal.position.y  # Mantém Y centralizado
	
	print("Posição final X: ", posicao_final.x)
	
	tween.tween_property(painel_principal, "position:x", posicao_final.x, DURACAO_ANIMACAO)\
		.set_trans(Tween.TRANS_CUBIC)\
		.set_ease(Tween.EASE_OUT)
	
	print("Animação iniciada!")

func fechar():
	print("=== Função FECHAR chamada ===")
	
	if not aberto:
		print("Já está fechado, ignorando...")
		return
	
	print("Fechando quadro...")
	aberto = false
	
	# Animar slide da direita para esquerda
	var tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	
	var pos_escondida = -painel_principal.size.x - 50
	
	print("Posição final (escondida) X: ", pos_escondida)
	
	tween.tween_property(painel_principal, "position:x", pos_escondida, DURACAO_ANIMACAO)\
		.set_trans(Tween.TRANS_CUBIC)\
		.set_ease(Tween.EASE_IN)
	
	await tween.finished
	get_tree().paused = false
	print("Quadro fechado e jogo despausado!")

func toggle():
	print("=== Função TOGGLE chamada ===")
	print("Estado atual - aberto: ", aberto)
	
	if aberto:
		fechar()
	else:
		abrir()

# Função específica para o botão fechar
func _on_btn_fechar_pressed():
	print("=== Botão FECHAR pressionado ===")
	fechar()

# Adicionar evidência coletada ao quadro
func adicionar_evidencia(id: String, nome: String, sprite: Texture2D, analise_holmes: String):
	if evidencias_coletadas.has(id):
		print("Evidência '", id, "' já foi adicionada.")
		return
	
	# Salvar dados da evidência
	evidencias_coletadas[id] = {
		"nome": nome,
		"sprite": sprite,
		"analise": analise_holmes,
		"posicao_quadro": Vector2.ZERO,  # Será setada quando arrastar
		"conexoes": []  # Array de IDs conectados
	}
	
	# Criar ícone na lista de inventário
	_criar_icone_inventario(id, nome, sprite)
	
	print("Evidência '", nome, "' adicionada ao quadro!")

func _criar_icone_inventario(id: String, nome: String, sprite: Texture2D):
	# Criar container do ícone
	var icone_container = PanelContainer.new()
	icone_container.name = "Evidencia_" + id
	icone_container.custom_minimum_size = Vector2(70, 70)  # Ajustado para tela pequena
	
	# Estilo cyberpunk para o container
	var style = StyleBoxFlat.new()
	style.bg_color = Color("#1a1a2e")
	style.border_color = Color("#00d9ff")
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4
	
	icone_container.add_theme_stylebox_override("panel", style)
	
	# VBox para organizar sprite + label
	var vbox = VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	
	# Sprite da evidência
	var texture_rect = TextureRect.new()
	texture_rect.texture = sprite
	texture_rect.custom_minimum_size = Vector2(40, 40)  # Ajustado para tela pequena
	texture_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	
	# Label com nome
	var label = Label.new()
	label.text = nome
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_color_override("font_color", Color("#00d9ff"))
	label.add_theme_font_size_override("font_size", 7)  # Ajustado para tela pequena
	
	# Montar hierarquia
	vbox.add_child(texture_rect)
	vbox.add_child(label)
	icone_container.add_child(vbox)
	
	icone_container.set_script(ICONE_INVENTARIO_SCRIPT)

	# 2. Passa os dados da evidência para as variáveis do script do ícone.
	icone_container.id = id
	icone_container.nome = nome
	icone_container.sprite = sprite

	# --- FIM DA LÓGICA CORRIGIDA ---

	# Adicionar ao inventário
	lista_evidencias.add_child(icone_container)
	
	# TODO: Adicionar funcionalidade de drag & drop (Parte 2)
	# TODO: Adicionar double-click para ver detalhes (Parte 4)


func _on_evidencia_largada_no_quadro(data, posicao_local):
	var nova_evidencia = EVIDENCIA_NO_QUADRO_SCENE.instantiate()
	
	# Isto vai inicializar todas as variáveis @onready dentro de EvidenciaNoQuadro.gd
	quadro_conexoes.add_child(nova_evidencia)
	
	# 2. AGORA você pode chamar set_data com segurança.
	nova_evidencia.set_data(data["id"], data["nome"], data["sprite"])
	
	# 3. E finalmente, defina a posição.
	nova_evidencia.position = posicao_local - (nova_evidencia.size / 2) # Centraliza
	
	nova_evidencia.clicado.connect(quadro_conexoes._on_evidencia_no_quadro_clicada)
	nova_evidencia.arrastado.connect(quadro_conexoes._on_evidencia_arrastada)
	nova_evidencia.inspecionado.connect(_on_evidencia_inspecionada)
	# TODO: Remover o item da lista de inventário (lista_evidencias)

func _on_evidencia_inspecionada(evidencia_id: String):
	# 1. Pega os dados da evidência que salvamos
	var dados_evidencia = evidencias_coletadas.get(evidencia_id)
	if dados_evidencia:
		var resumo = dados_evidencia.get("analise")
		print("Mostrando resumo: ", resumo)

		# 2. Cria o pop-up
		var popup = RESUMO_UI_SCENE.instantiate()

		# 3. Adiciona o pop-up à cena (self é o CanvasLayer)
		add_child(popup)

		# 4. Mostra o texto
		popup.mostrar_resumo(resumo)

# Carregar evidências salvas (será implementado com persistência)
func carregar_estado():
	# TODO: Carregar do save file
	pass

# Salvar estado atual
func salvar_estado():
	# TODO: Salvar conexões e posições
	pass
