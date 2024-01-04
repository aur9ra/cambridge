local MusicConfigScene = Scene:extend()

MusicConfigScene.title = "Music Config"

function MusicConfigScene:new(game_mode)
    current_slot = 1
    current_track = 1

    current_track_name = ""

    self.menu_state = {
		slot = current_slot,
		track = current_track,
		select = "slot",
	}
    self.game_mode = game_mode

    if not self.game_mode.music_slot_names then
        self.display_warning = true
        return
    end

    initMusicConfig(game_mode.name)
    initMusicConfigForGameMode(game_mode.name, #game_mode.music_slot_names)
    self.music_config = music_config
end

function MusicConfigScene:update()
    if self.das_up or self.das_down then
		self.das = self.das + 1
	else
		self.das = 0
	end

	if self.das >= 15 then
		self:changeOption(self.das_up and -1 or 1)
		self.das = self.das - 4
	end
end
    
function MusicConfigScene:onInputPress(e)
    if self.display_warning and e.input then
		scene = ModeSelectScene()
	elseif e.type == "wheel" then
		if e.x % 2 == 1 then
			self:switchSelect()
		end
		if e.y ~= 0 then
			self:changeOption(-e.y)
		end
	elseif e.input == "menu_decide" or e.scancode == "return" then
		stopBGM()
		playSE("mode_decide")
        createSav('music_config', self.music_config)
        scene = ModeSelectScene()
	elseif e.input == "up" or e.scancode == "up" then
		self:changeOption(-1)
		self.das_up = true
		self.das_down = nil
	elseif e.input == "down" or e.scancode == "down" then
		self:changeOption(1)
		self.das_down = true
		self.das_up = nil
	elseif e.input == "left" or e.input == "right" or e.scancode == "left" or e.scancode == "right" then
		self:switchSelect()
	elseif e.input == "menu_back" or e.scancode == "delete" or e.scancode == "backspace" then
        stopBGM()
		scene = TitleScene()
    end
end

function MusicConfigScene:onInputRelease(e)
	if e.input == "up" or e.scancode == "up" then
		self.das_up = nil
	elseif e.input == "down" or e.scancode == "down" then
		self.das_down = nil
    end
end

function MusicConfigScene:changeOption(rel)
	if self.menu_state.select == "slot" then
		self:changeSlot(rel)
	elseif self.menu_state.select == "track" then
		self:changeTrack(rel)
	end
	playSE("cursor")
end

function MusicConfigScene:switchSelect()
	if self.menu_state.select == "slot" then
		self.menu_state.select = "track"
	elseif self.menu_state.select == "track" then
		self.menu_state.select = "slot"
	end
	playSE("cursor_lr")
end

function MusicConfigScene:changeSlot(rel)
	local len = table.getn(self.game_mode.music_slot_names)
	self.menu_state.slot = Mod1(self.menu_state.slot + rel, len)
    print(self.music_config[self.game_mode.name][self.menu_state.slot])
    self.menu_state.track = self.music_config[self.game_mode.name][self.menu_state.slot][1]
end

function MusicConfigScene:changeTrack(rel)
	local len = table.getn(bgm_names)
    print("menu_state.track is " .. self.menu_state.track)
	self.menu_state.track = Mod1(self.menu_state.track + rel, len)
    print("menu_state.track is " .. self.menu_state.track)
    current_track_name = bgm_names[self.menu_state.track]
    self.music_config[self.game_mode.name][self.menu_state.slot] = {self.menu_state.track, current_track_name}
end

function MusicConfigScene:render()
	switchAndLoadBgmByName(bgm_names[self.menu_state.track])
	print(bgm_names[self.menu_state.track])
    love.graphics.setColor(1, 1, 1, 1)
    drawBackground("options_input")

    love.graphics.setFont(font_3x5_4)
    love.graphics.print(self.game_mode.name .. " Music Config", 80, 40)

	if self.display_warning then
		love.graphics.setFont(font_3x5_3)
		love.graphics.printf(
			"This mode has not been configured with any music slots.",
			80, 200, 480, "center"
		)
		love.graphics.setFont(font_3x5_2)
		love.graphics.printf(
			"Press any button to select another mode.",
			80, 250, 480, "center"
		)
		return
	end

	if self.menu_state.select == "slot" then
		love.graphics.setColor(1, 1, 1, 0.5)
	elseif self.menu_state.select == "track" then
		love.graphics.setColor(1, 1, 1, 0.25)
	end
	love.graphics.rectangle("fill", 20, 258, 240, 22)

	if self.menu_state.select == "slot" then
		love.graphics.setColor(1, 1, 1, 0.25)
	elseif self.menu_state.select == "track" then
		love.graphics.setColor(1, 1, 1, 0.5)
	end
	love.graphics.rectangle("fill", 340, 258, 200, 22)

	love.graphics.setFont(font_3x5_2)
	for index, slot in pairs(self.game_mode.music_slot_names) do
		if(index >= self.menu_state.slot-9 and index <= self.menu_state.slot+9) then
            love.graphics.setColor(1, 1, 1, 1)
            if self.music_config[self.game_mode.name][index][2] ~= nil then
                love.graphics.setColor(0.5, 1, 0.5, 1)
            end
			love.graphics.printf(slot, 40, (260 - 20*(self.menu_state.slot)) + 20 * index, 200, "left")
		end
	end

    love.graphics.setColor(1, 1, 1, 1)

	for index, track in ipairs(bgm_names) do
		if(index >= self.menu_state.track-9 and index <= self.menu_state.track+9) then
			love.graphics.printf(track, 360, (260 - 20*(self.menu_state.track)) + 20 * index, 160, "left")
		end
	end
end

return MusicConfigScene