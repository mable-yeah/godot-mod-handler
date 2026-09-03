class_name asset_implementations
const implementation = AssetManager.implementation

class json extends implementation:
	static func get_asset(container:asset_c) -> asset_c:
		var data_raw = FileAccess.open(container.path, FileAccess.READ)
		if data_raw == null:
			return container
		
		var parsed = JSON.parse_string(data_raw.get_as_text())
		container.asset = parsed
		return container


class txt extends implementation:
	static func get_asset(container:asset_c) -> asset_c:
		var data_raw = FileAccess.open(container.path,FileAccess.READ)
		if data_raw == null:
			return container
		
		container.asset = encode_string_as_unix(data_raw.get_as_text())
		return container
	
	#passed in strings can end up in other formats besides unix 
	static func encode_string_as_unix(string:String) -> String:
		string = string.c_escape()
		var el_r =  string.count("\\r") ; var el_n =  string.count("\\n")
		if el_r > 0:
			var replacement = '' if el_n > 0 else '\\n'
			string = string.replace("\\r",replacement)
		return string.c_unescape()
	#if n and r both exist just scrape out the \r
	#otherwise if r only exists replace it with n


class texture extends implementation:
	static func get_asset(container:asset_c) -> asset_c:
		if container.in_shared:
			container.asset = loadSharedTex(container.path)
			return container

		if !ResourceLoader.exists(container.path):
			printerr(exists_err % container.path)
			return container
		
		container.asset = load(container.path)
		return container

	static func loadSharedTex(path) -> Texture:
		var Read = FileAccess.open(path,FileAccess.READ)
		var Data = Read.get_buffer(Read.get_length())
		var IMG = Image.new()
		IMG.load_png_from_buffer(Data)
		Read.close()
		
		var user_resource = ImageTexture.new()
		user_resource.set_image(IMG)
		return user_resource

class ogg extends implementation:
	static func get_asset(container:asset_c) -> asset_c:
		if container.in_shared:
			container.asset = AudioStreamOggVorbis.load_from_file(container.path)
			return container
		
		if !ResourceLoader.exists(container.path):
			printerr(exists_err % container.path)
			return container
		
		container.asset = load(container.path)
		return container
