bgm = {}
bgm_names = {}
bgm_sources = {}

bgm_files = love.filesystem.getDirectoryItems("res/bgm")

for index, filename in ipairs(bgm_files) do
	bgm_names[index] = filename
	bgm_sources[filename] = love.audio.newSource("res/bgm/" .. filename, "stream")
end

local current_bgm = nil
local bgm_playing = false

function playBgmByModeAndIndex(game_mode_name, index)
	new_bgm_name = music_config[game_mode_name][index][2]
	if current_bgm ~= bgm_sources[new_bgm_name] then
		-- make sure any formerly playing bgm does not continue to play
		if current_bgm ~= nil then current_bgm:stop() end
		current_bgm = bgm_sources[new_bgm_name]

		-- reset fadeout, volume
		resetBGMFadeout()
		current_bgm:setVolume(config.bgm_volume)

		current_bgm:play()
	end
end

function switchAndLoadBgmByName(name)
	if current_bgm ~= bgm_sources[name] then
		-- make sure any formerly playing bgm does not continue to play
		if current_bgm ~= nil then current_bgm:stop() end
		current_bgm = bgm_sources[name]

		-- reset fadeout, volume
		resetBGMFadeout()
		current_bgm:setVolume(config.bgm_volume)

		current_bgm:play()
	end
end


local fading_bgm = false
local fadeout_time = 0
local total_fadeout_time = 0

function fadeoutBGM(time)
	if fading_bgm == false then
		fading_bgm = true
		fadeout_time = time
		total_fadeout_time = time
	end
end


function resetBGMFadeout()
	current_bgm:setVolume(config.bgm_volume)
	fading_bgm = false
	resumeBGM()
end

-- gradually decrease bgm volume, keep at 0 until new bgm is played or fadeout is reset. ran automatically.
function processBGMFadeout(dt)
	if current_bgm and fading_bgm then
		fadeout_time = fadeout_time - dt
		if fadeout_time < 0 then
			fadeout_time = 0
		end
		current_bgm:setVolume(
			(fadeout_time / total_fadeout_time) * config.bgm_volume
		)
	end
end

function pauseBGM()
	if current_bgm ~= nil then
		current_bgm:pause()
	end
end

function stopBGM()
	print("Stop bgm")
	if current_bgm ~= nil then
		current_bgm:stop()
	end
	current_bgm = nil
end

function resumeBGM()
	if current_bgm ~= nil then
		current_bgm:play()
	end
end
