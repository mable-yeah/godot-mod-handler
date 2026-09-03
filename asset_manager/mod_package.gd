class_name mod_loader

static func init_mods() -> Array[mod_loader.mod_package]:
	var mod_list:Array[mod_loader.mod_package]
	
	var base_package = mod_package.new('res://')
	base_package.init_meta('internal_res','internal','base assets stored within the game')
	mod_list.append(base_package)
	
	var manager = AssetManager ; manager.get_user_directory()
	var path = manager.user_dir.path_join(manager.MOD_FOLDER_NAME)
	if !DirAccess.dir_exists_absolute(path): return mod_list
	
	var mod_folders := []
	for file in DirAccess.get_files_at(path):
		if file.get_extension() != 'zip': continue
		var mod_zip = temp_zip.read_zip(path.path_join(file),file.get_basename())
		if mod_zip.is_empty(): continue
		mod_folders.append(mod_zip)
	
	for folder in DirAccess.get_directories_at(path):
		mod_folders.append(path.path_join(folder))
	
	for mod_path in mod_folders:
		var package = init_new_package(mod_path)
		if package == null: continue
		mod_list.append(package)
	
	return mod_list

static func init_new_package(mod_folder:String) -> mod_package:
	var package = mod_package.new(mod_folder)
	if !FileAccess.file_exists(package.meta_path): 
		printerr('mod_meta.json does not exist for "%s"' % package.path)
		return null
	
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

#mod zips are only temporarily stored (hence the name),
#they delete when the game closes or when temp_mods_folder free's
class temp_zip:
	static var temp_zip_folder := DirAccess.create_temp('temp_zip')
	
	static func read_zip(zip_path:String,zip_name:String) -> String:
		if !FileAccess.file_exists(zip_path) || temp_zip_folder == null: return ''
		var reader = ZIPReader.new() ; var err = reader.open(zip_path)
		var files:Array = reader.get_files()
		if err != OK: return ''
		var out_path = temp_zip_folder.get_current_dir().path_join(zip_name)
		err = temp_zip_folder.make_dir_recursive(zip_name)
		var file_access = DirAccess.open(out_path)
		var temp_dir = file_access.get_current_dir()
		
		#fixes the out path if the zip structure is 
		#'zip_name.zip -> folder_name -> files' instead of 'zip_name.zip -> files'
		var start_file = files.front()
		for path in files:
			if path == start_file || !path.begins_with(start_file): continue
			out_path = temp_dir.path_join(start_file)
			break
		
		for path in files:
			if path.ends_with("/"): file_access.make_dir_recursive(path) ; continue
			file_access.make_dir_recursive(temp_dir)
			var file = FileAccess.open(temp_dir.path_join(path), FileAccess.WRITE)
			var buffer = reader.read_file(path)
			file.store_buffer(buffer)
		return out_path
