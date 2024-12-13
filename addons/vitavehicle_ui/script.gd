@tool
extends EditorPlugin

const TeamPanelScene = preload("res://addons/vitavehicle_ui/interface.tscn")

var team_panel_instance

func _enter_tree():
	# Crear instancia del panel del equipo
	team_panel_instance = TeamPanelScene.instantiate()
	# Verificar que la instancia se creó correctamente
	if team_panel_instance:
		# Agregar el panel al editor
		get_editor_interface().get_editor_main_screen().add_child(team_panel_instance)
		_make_visible(false)  # Ocultar el panel inicialmente
	else:
		print("Error: No se pudo instanciar team_panel_instance")

func _exit_tree():
	# Limpiar la instancia cuando el complemento se desactiva
	if team_panel_instance:
		team_panel_instance.queue_free()

func _has_main_screen():
	return true  # Indica que este complemento tiene una pantalla principal

func _make_visible(visible):
	if team_panel_instance:
		team_panel_instance.visible = visible
	else:
		print("Error: team_panel_instance es null")

func _get_plugin_name():
	return "Nombres del equipo"

func _get_plugin_icon():
	# Icono genérico del editor
	return get_editor_interface().get_base_control().get_theme_icon("Node", "EditorIcons")
