class_name mod_loader

static func init_mods() -> Array[mod_loader.mod_package]:
	var mod_list:Array[mod_loader.mod_package]
	
	var base_package = mod_package.new('res://')
	base_package.init_meta('internal_res','internal','base assets stored within the game')
	mod_list.append(base_package)
	
	var manager = AssetManager ; manager.get_user_directory()
	var path = manager.user_dir.path_join(manager.MOD_FOLDER_NAME)
	if !DirAccess.dir_exists_absolute(path): return mod_list
	
	var mod_folders := DirAccess.get_directories_at(path)
	for folder in mod_folders:
		var package = init_new_package(path.path_join(folder))
		if package == null: continue
		mod_list.append(package)
	return mod_list


static func init_new_package(mod_folder:String) -> mod_package:
	var package = mod_package.new(mod_folder)
	if !FileAccess.file_exists(package.meta_path): return null
	
	var file_access = FileAccess.open(package.meta_path,FileAccess.READ)
	var meta = JSON.parse_string(file_access.get_as_text())
	
	if meta == null || !(meta is Dictionary): return null
	
	var name = meta.get('name','') ; var id = meta.get('id','')
	var desc = meta.get('description','')
	package.init_meta(name,id,desc)
	return package

class mod_package:
	var name:String
	var id:String
	var description:String
	
	var meta_path:
		get():
			return path.path_join('mod_meta.json')
	
	var path := ''
	var enabled := true
	
	func _init(p_path := '') -> void:
		path = p_path
	
	func init_meta(p_name:String,p_id:String,p_description:String) -> void:
		name = p_name ; id = p_id
		description = p_description
