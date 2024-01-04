local binser = require 'libs.binser'

function loadSave()
	config = loadFromFile('config.sav')
	highscores = loadFromFile('highscores.sav')
	music_config = loadFromFile('music_config.sav')
end

function loadFromFile(filename)
	local file_data = love.filesystem.read(filename)
	if file_data == nil then
		return {} -- new object
	end
	local save_data = binser.deserialize(file_data)
	if save_data == nil then
		return {} -- new object
	end
	return save_data[1]
end

function initConfig()
	if not config.das then config.das = 10 end
	if not config.arr then config.arr = 2 end
	if not config.dcd then config.dcd = 0 end
	if not config.sfx_volume then config.sfx_volume = 0.5 end
	if not config.bgm_volume then config.bgm_volume = 0.5 end
	
	if config.fullscreen == nil then config.fullscreen = false end
	if config.secret == nil then config.secret = false end

	if not config.gamesettings then config.gamesettings = {} end
	for _, option in ipairs(GameConfigScene.options) do
		if not config.gamesettings[option[1]] then
			config.gamesettings[option[1]] = 1
		end
	end
	
	if not config.input then
		scene = InputConfigScene()
	else
		if config.current_mode then current_mode = config.current_mode end
		if config.current_ruleset then current_ruleset = config.current_ruleset end
		scene = TitleScene()
	end
end

function initMusicConfig()
	if not music_config then music_config = {} end
end

function initMusicConfigForGameMode(game_mode_name, num_slots)
	for key, _ in pairs(music_config) do
		if key == game_mode_name then return end
	end

	slots_list = {}
	for i = 1, num_slots do
		slots_list[i] = {1, nil}
	end
	music_config[game_mode_name] = slots_list
end

function createSav(filename, obj)
	print(filename)
	love.filesystem.write(
		filename .. '.sav', binser.serialize(obj)
	)
end