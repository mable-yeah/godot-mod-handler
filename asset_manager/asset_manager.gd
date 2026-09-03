class_name AssetManager
##Instead of querying both the built in folder and the user's shared folder manually,
##this class handles that

enum open_type {
	DIR, ##just directory names
	FILES, ##just file names
	FILES_PATH ##full file paths
}

static var user_dir := ''
static var implimentations = asset_implementations
static var mod_list:Array[mod_loader.mod_package]
const MOD_FOLDER_NAME = 'mods'

##a list of every implementation,and their repective extension 
static var loader_map:Dictionary[String,Variant] = {
		'png':implimentations.texture,
		'ogg':implimentations.ogg,
		'txt':implimentations.txt,
		'json':implimentations.json,
		#'gd':implimentations.txt, #very very unsafe, but it technically works
}

##verifies if an asset exists in either the shared directory or internal pck, 
##by default it prioritizes the shared/modded directory allowing for overwritable internal assets
static func verify_asset(path:String,force_internal := false) -> asset_container:
	init_mod_list()
	if path.is_empty(): return asset_container.new('',path)
	var last_shared_path = path ; var in_shared = false
	var file_meta = get_file_meta(path)
	
	for mod in mod_list:
		if force_internal: break
		
		if mod.id == 'internal': 
			last_shared_path = path ; in_shared = false
			continue
		var as_mod_path = join_mod_path(file_meta.path,mod.path)
		if !FileAccess.file_exists(as_mod_path):continue
		last_shared_path = as_mod_path ; in_shared = true
	
	var this_container = asset_container.new(last_shared_path,path,in_shared)
	var loader = loader_map.get(file_meta.extension)
	if loader != null: return loader.get_asset(this_container)
	this_container.asset = this_container.path 
	return this_container



#static func get_files_at(dir:String,dir_typing:open_type = open_type.DIR) -> PackedStringArray:
	#var val:PackedStringArray = []
	#var shared_folder := to_local(dir)
	#if !DirAccess.dir_exists_absolute(shared_folder): shared_folder = ''
	#var shared_exists = !shared_folder.is_empty()
	#
	#while true:
		#match dir_typing:
			#open_type.DIR:
				#val.append_array(DirAccess.get_directories_at(dir))
				#if !shared_exists: break
				#val.append_array(DirAccess.open(shared_folder).get_directories())
			#
			#open_type.FILES:
				#val.append_array(DirAccess.get_files_at(dir))
				#if !shared_exists: break
				#val.append_array(DirAccess.open(shared_folder).get_files())
			#
			#open_type.FILES_PATH:
				#var file_names = []
				#file_names.append_array(DirAccess.get_files_at(dir))
				#for file in file_names: val.append(dir.path_join(file))
				#
				#file_names.clear()
				#if !shared_exists: break
				#file_names.append_array(DirAccess.open(shared_folder).get_files())
				#for file in file_names: val.append(shared_folder.path_join(file))
			#_:
				#printerr("invalid get_files type")
		#break
	#return val


static func get_file_meta(path:String) -> Dictionary[String,String]:
	return {
		'path':path,
		'name':path.get_file().get_basename(),
		'extension':path.get_extension()
	}

static func join_mod_path(path:String,mod_path:String) -> String:
	path = path.trim_prefix('res://').trim_prefix('shared')
	return mod_path.path_join(path)

##gets the location of the game's directory
static func get_user_directory() -> void:
	if !user_dir.is_empty(): return
	user_dir = ProjectSettings.globalize_path(OS.get_executable_path().get_base_dir())


##initializes the mods list based on user_dir + MOD_FOLDER_NAME
static func init_mod_list():
	if !mod_list.is_empty(): return
	mod_list = mod_loader.init_mods()

##asset containers... contain the result of an implementation
class asset_container:
	##can be a texture file, a loaded directory string, whatever really
	var asset:Variant = null
	
	##the path to this asset
	var path:String = ''
	
	##base path of the asset 
	##..this can differ from 'path', if the asset exists in both shared and internally 
	var base_path:String = ''
	
	##if the file is from the users folder
	##needed for some implementations
	var in_shared = false
	
	func _init(p_path:String,p_base:String,p_shared = true) -> void:
		base_path = p_base ; path = p_path ; in_shared = p_shared

##implementations are what actually load's assets into the container
##custom ones can be made easily if needed
@abstract class implementation:
	const exists_err = 'file doesnt exist in any valid directory "%s"'
	const asset_c = asset_container
	
	static func get_asset(_container:asset_c) -> asset_c:
		return null
