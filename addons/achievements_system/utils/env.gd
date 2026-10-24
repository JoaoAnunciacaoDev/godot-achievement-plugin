class_name EnvConfig

const ENV_PASSWORD_KEY: String = "ACHIEVEMENTS_KEY"
const ENV_FILE_PATH: String = "res://.env"

static var default_encryption_password: String = "minha_senha_secreta_123"
static var _cached_password: String = ""


## Retorna a chave atual ou gera/salva uma automaticamente se não houver
static func get_encryption_password() -> String:
	if not _cached_password.is_empty():
		return _cached_password
	
	var env_val: String = OS.get_environment(ENV_PASSWORD_KEY)
	if not env_val.is_empty():
		_cached_password = env_val
		return _cached_password
	
	var file_env := _read_key_from_env_file(ENV_PASSWORD_KEY)
	if not file_env.is_empty():
		_cached_password = file_env
		return _cached_password
	
	if OS.is_debug_build() and not FileAccess.file_exists(ENV_FILE_PATH):
		var new_key: String = generate_and_save_to_env()
		if not new_key.is_empty():
			_cached_password = new_key
			return _cached_password
	
	_cached_password = default_encryption_password
	return _cached_password

## Gera uma chave criptográfica forte (AES-256 / 32 bytes em Hexadecimal)
static func generate_random_key(byte_length: int = 32) -> String:
	var crypto := Crypto.new()
	var random_bytes := crypto.generate_random_bytes(byte_length)
	return random_bytes.hex_encode()

## Gera a chave e já cria/escreve no arquivo res://.env
static func generate_and_save_to_env() -> String:
	var key: String = generate_random_key(32)
	var content: String = "%s=\"%s\"\n" % [ENV_PASSWORD_KEY, key]
	
	var file := FileAccess.open(ENV_FILE_PATH, FileAccess.WRITE)
	if not file:
		printerr("EnvConfig: Não foi possível criar o arquivo '%s'." % ENV_FILE_PATH)
		return ""
	
	file.store_string(content)
	file.close()
	print("EnvConfig: Chave gerada com sucesso e salva em '%s'!" % ENV_FILE_PATH)
	return key

static func _read_key_from_env_file(key: String) -> String:
	if not FileAccess.file_exists(ENV_FILE_PATH):
		return ""
	
	var file := FileAccess.open(ENV_FILE_PATH, FileAccess.READ)
	if not file:
		return ""
	
	while not file.eof_reached():
		var line := file.get_line().strip_edges()
		if line.begins_with("#") or not line.contains("="):
			continue
		var parts := line.split("=", false, 1)
		if parts.size() == 2 and parts[0].strip_edges() == key:
			var val := parts[1].strip_edges()
			val = val.trim_prefix('"').trim_suffix('"')
			val = val.trim_prefix("'").trim_suffix("'")
			return val
	return ""
