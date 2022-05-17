ImprovedBackdrops = RegisterMod("Improved Backdrops", 1)
local mod = ImprovedBackdrops
local game = Game()
local json = require("json")

-- Mod config menu values
local config = {
	custombossrooms  = true,
	customrocks 	 = true,
	tintedcompat 	 = false,
	cooloverlays 	 = true,
	udevil 			 = true,
	uangel 			 = true,
	ucurse 			 = true,
	uchallenge 		 = true,
	ucrawlspace 	 = true,
	customgreedrooms = true,
	ubmarket 		 = true,
	voidstatic 		 = true,
	randvoid 		 = true
}

local Settings = {
	OverlaySubType = 2727,
	WallSubType    = 2727,
}

-- Shorter room shape enums
local reg  = RoomShape.ROOMSHAPE_1x1
local IH   = RoomShape.ROOMSHAPE_IH
local IV   = RoomShape.ROOMSHAPE_IV
local tall = RoomShape.ROOMSHAPE_1x2
local IIV  = RoomShape.ROOMSHAPE_IIV
local long = RoomShape.ROOMSHAPE_2x1
local IIH  = RoomShape.ROOMSHAPE_IIH
local big  = RoomShape.ROOMSHAPE_2x2
local LTL  = RoomShape.ROOMSHAPE_LTL
local LTR  = RoomShape.ROOMSHAPE_LTR
local LBL  = RoomShape.ROOMSHAPE_LBL
local LBR  = RoomShape.ROOMSHAPE_LBR

local BackdropPositons = {
	{Vector(-20, 60),  Vector(660, 60),  Vector(-20, 500), Vector(660, 500)}, -- 1x1
	{Vector(-20, 140), Vector(660, 140), Vector(-20, 420), Vector(660, 420)}, -- IH
	{Vector(140, 60),  Vector(500, 60),  Vector(140, 500), Vector(500, 500)}, -- IV
	
	{Vector(-20, 60), Vector(660, 60), Vector(-20, 780), Vector(660, 780)}, -- 1x2
	{Vector(140, 60), Vector(500, 60), Vector(140, 780), Vector(500, 780)}, -- IIV
	
	{Vector(-20, 60),  Vector(1180, 60),  Vector(-20, 500), Vector(1180, 500)}, -- 2x1
	{Vector(-20, 140), Vector(1180, 140), Vector(-20, 420), Vector(1180, 420)}, -- IIH
	
	{Vector(-20, 60), Vector(1180, 60), Vector(-20, 780), Vector(1180, 780)}, -- 2x2
	
	{Vector(-20, 340), Vector(1180, 60),  Vector(-20, 780), Vector(1180, 780)}, -- LTL
	{Vector(-20, 60),  Vector(1180, 340), Vector(-20, 780), Vector(1180, 780)}, -- LTR
	{Vector(-20, 60),  Vector(1180, 60),  Vector(-20, 500), Vector(1180, 780)}, -- LBL
	{Vector(-20, 60),  Vector(1180, 60),  Vector(-20, 780), Vector(1180, 500)}, -- LBR
}

local LinnerPositions = {
	Vector(-20, 340), -- LTL
	Vector(1180, 340), -- LTR
	Vector(-20, 500), -- LBL
	Vector(1180, 500), -- LBR
}



-- Spawn entities when entering a room
function mod:IBackdropsEnterRoom()
	local room = game:GetRoom()
	local bg = room:GetBackdropType()
	local rtype = room:GetType()
	local shape = room:GetRoomShape()
	local level = game:GetLevel()
	local stage = level:GetStage()
	
	-- Check if boss room is valid for custom walls
	function IBackdropsIsValidBossRoom()
		if config.custombossrooms == true and (rtype == RoomType.ROOM_BOSS or rtype == RoomType.ROOM_MINIBOSS) and stage ~= LevelStage.STAGE7 then
			return true
		end
	end
	
	-- Custom walls
	function mod:IBackdropsCustomBG(sheet, type)
		if type == "corner" then
			type = 1
		elseif type == "L" then
			type = 2
		elseif type == "floor" then
			type = 3
		elseif type == "special" then
			type = 4
		else
			type = 0
		end

		-- L room inner walls
		if type == 2 then
			local backdrop = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BACKDROP_DECORATION, Settings.WallSubType + type, LinnerPositions[shape - 8], Vector.Zero, nil):ToEffect()
			local sprite = backdrop:GetSprite()
			
			for i = 0, sprite:GetLayerCount() do
				sprite:ReplaceSpritesheet(i, "gfx/backdrop/custom/" .. sheet .. ".png")
			end

			sprite:LoadGraphics()
			sprite:SetFrame(sprite:GetDefaultAnimation(), shape - 9)
			backdrop:AddEntityFlags(EntityFlag.FLAG_RENDER_WALL | EntityFlag.FLAG_RENDER_FLOOR)
		
		-- Floors
		elseif type == 3 then
			local backdrop = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BACKDROP_DECORATION, Settings.WallSubType + type, Vector(-20, 60), Vector.Zero, nil):ToEffect()
			local sprite = backdrop:GetSprite()
			
			sprite:ReplaceSpritesheet(0, "gfx/backdrop/custom/" .. sheet .. ".png")
			sprite:LoadGraphics()
			backdrop:AddEntityFlags(EntityFlag.FLAG_RENDER_FLOOR)
		
		-- Walls / Corner details
		else
			for p = 1, 4 do
				local backdrop = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BACKDROP_DECORATION, Settings.WallSubType + type, BackdropPositons[shape][p], Vector.Zero, nil):ToEffect()
				local sprite = backdrop:GetSprite()

				for i = 0, sprite:GetLayerCount() do
					sprite:ReplaceSpritesheet(i, "gfx/backdrop/custom/" .. sheet .. ".png")
				end

				sprite:LoadGraphics()
				sprite:SetFrame(shape, p - 1)
				backdrop:AddEntityFlags(EntityFlag.FLAG_RENDER_WALL | EntityFlag.FLAG_RENDER_FLOOR)
			end
		end
		
		-- Additional stuff
		-- Burning Basement rocks
		if BackdropSheets[entity.State - Settings.StateOffset].ID == "1" then
			IBackdropsGetGrids("rocks_burning_custom")
			
		-- Angel room grids
		elseif BackdropSheets[entity.State - Settings.StateOffset].ID == "11" then
			IBackdropsGetGrids("rocks_angel")
			IBackdropsGetGrids("props_angel", GridEntityType.GRID_DECORATION)
			IBackdropsGetGrids("grid_pit_angel", GridEntityType.GRID_PIT)
		
		-- Dark Room boss walls
		elseif BackdropSheets[entity.State - Settings.StateOffset].ID == "42" then
			Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BACKDROP_DECORATION, Settings.WallSubType + 5, Vector(-20, 60), Vector.Zero, nil):ToEffect().DepthOffset = -10000

			for i = 0, 5 do
				Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.DOGMA_DEBRIS, 0, Isaac.GetRandomPosition(), Vector.Zero, nil):ToEffect()
			end
		end
	end


	-- Persistent entities
	if room:IsInitialized() then
		-- Basement
		if bg == BackdropType.BASEMENT then
			if config.custombossrooms == true and rtype == RoomType.ROOM_MINIBOSS then
				IBackdropsCustomBG("boss_basement_1")
			end
		
		-- Cellar
		elseif bg == BackdropType.CELLAR then
			--IBackdropsTopDecorPositions(shape)
			
			if IBackdropsIsValidBossRoom() == true then
				IBackdropsChangeBG(bg, true)
				IBackdropsCustomBG("boss_cellar_1")
			end
		
		-- Burning Basement
		elseif bg == BackdropType.BURNT_BASEMENT then
			if room:GetDecorationSeed() % 2 == 0 or IBackdropsIsValidBossRoom() == true then
				if IBackdropsIsValidBossRoom() == true then
					IBackdropsCustomBG("boss_burning_1")
				end

				IBackdropsCustomBG("burning_ash", "corner")
			end
		
		-- Caves
		elseif bg == BackdropType.CAVES then
			--IBackdropsTopDecorPositions(shape)
			
			if IBackdropsIsValidBossRoom() == true then
				IBackdropsChangeBG(bg, true)
				IBackdropsCustomBG("boss_caves_1")
			end
			
		-- Catacombs
		elseif bg == BackdropType.CATACOMBS then
			if IBackdropsIsValidBossRoom() == true then
				IBackdropsChangeBG(bg, true)
				IBackdropsCustomBG("boss_catacombs_1")
			end
			
		-- Flooded Caves
		elseif bg == BackdropType.FLOODED_CAVES then
			--IBackdropsTopDecorPositions(shape)
			
			if IBackdropsIsValidBossRoom() == true then
				IBackdropsCustomBG("boss_flooded_1")
			end
			
		-- Depths
		elseif bg == BackdropType.DEPTHS then
			--IBackdropsTopDecorPositions(shape)
			IBackdropsCustomBG("depths_pillar", "corner")
			
			if IBackdropsIsValidBossRoom() == true then
				IBackdropsChangeBG(bg, true)
				IBackdropsCustomBG("boss_depths_1")
			end
		
		-- Necropolis
		elseif bg == BackdropType.NECROPOLIS then
			if IBackdropsIsValidBossRoom() == true then
				IBackdropsChangeBG(bg, true)
				IBackdropsCustomBG("boss_necropolis_1")
			end
		
		-- Dank Depths
		elseif bg == BackdropType.DANK_DEPTHS then
			--IBackdropsTopDecorPositions(shape)
			IBackdropsCustomBG("dank_pillar", "corner")
			
			if IBackdropsIsValidBossRoom() == true then
				IBackdropsCustomBG("boss_dank_1")
			end
			
		-- Sheol / Sheol backdrop special rooms
		elseif bg == BackdropType.SHEOL then
			if IBackdropsIsValidBossRoom() == true or (config.udevil == true and rtype == RoomType.ROOM_DEVIL) then
				IBackdropsCustomBG("boss_devil_1")
				
			elseif config.ucurse == true and rtype == RoomType.ROOM_CURSE then
				IBackdropsCustomBG("curse_" .. room:GetDecorationSeed % 2, "corner")
				IBackdropsCustomBG("blood", "floor")
				
			elseif config.uchallenge == true and (rtype == RoomType.ROOM_CHALLENGE or rtype == RoomType.ROOM_BOSSRUSH) then
				IBackdropsCustomBG("challenge_1")
				if stage % 2 == 0 and rtype ~= RoomType.ROOM_BOSSRUSH then
					IBackdropsCustomBG("blood", "floor")
				end
				
			elseif config.ubmarket == true and rtype == RoomType.ROOM_BLACK_MARKET then
				IBackdropsCustomBG("blackmarket_1")
			end
		
		-- Cathedral / Cathedral backdrop special rooms
		elseif bg == BackdropType.CATHEDRAL then
			if config.uangel == true and rtype == RoomType.ROOM_ANGEL then
				IBackdropsCustomBG("angel_1")
			
			else
				if shape == tall or shape == long or shape == big then
					IBackdropsCustomBG("cathedral_trim")
				elseif shape == LBL or shape == LBR or shape == LTL or shape == LTR then
					IBackdropsCustomBG("cathedral_l_inner", "L")
				elseif shape == IH or shape == IIH or shape == IV or shape == IIV then
					IBackdropsCustomBG("ihv_cathedral")
				end

				if IBackdropsIsValidBossRoom() == true then
					IBackdropsCustomBG("boss_cathedral_1")
				end
			end
		
		-- Dark Room
		elseif bg == BackdropType.DARKROOM then
			if IBackdropsIsValidBossRoom() == true and shape == reg then
				IBackdropsCustomBG("boss_darkroom", "floor")
				IBackdropsCustomBG("boss_darkroom", "special")
			else
				IBackdropsSpawnDecorGrids(shape)
			end
		
		-- Shop
		elseif bg == BackdropType.SHOP then
			if shape == reg then
				IBackdropsCustomBG("shop_1")
			end
			if (config.customgreedrooms == true and level:GetCurrentRoomDesc().SurpriseMiniboss == true) or stage == LevelStage.STAGE4_3 then
				IBackdropsCustomBG("greed_shop")
			end
		
		-- Secret Room
		elseif bg == BackdropType.SECRET then
			if rtype == RoomType.ROOM_SHOP and config.customgreedrooms == true and level:GetCurrentRoomDesc().SurpriseMiniboss == true then
				IBackdropsCustomBG("greed_secret")
			elseif rtype == RoomType.ROOM_SECRET_EXIT then
				IBackdropsChangeBG(BackdropType.MINES_ENTRANCE)
			end
		
		-- Downpour
		elseif bg == BackdropType.DOWNPOUR then
			if IBackdropsIsValidBossRoom() then
				IBackdropsCustomBG("boss_downpour_1")
			end
		
		-- Mines
		elseif bg == BackdropType.MINES then
			if IBackdropsIsValidBossRoom() then
				IBackdropsCustomBG("boss_mines_1")
			
			-- Better wall details for IH and IV rooms
			elseif shape == IH or shape == IIH or shape == IV or shape == IIV then
				for i,problematics in pairs(Isaac.GetRoomEntities()) do
					if problematics.Type == EntityType.ENTITY_EFFECT and problematics.Variant == EffectVariant.BACKDROP_DECORATION then
						local problemsprite = problematics:GetSprite()
						
						if problemsprite:GetFilename() == "gfx/backdrop/03x_mines_bg_details.anm2" or problemsprite:GetFilename() == "gfx/backdrop/03x_mines_bg_details_dark.anm2" then	
							if shape == IH or shape == IIH then
								problemsprite:SetFrame(1)
							elseif shape == IV or shape == IIV then
								problemsprite:SetFrame(2) -- Why don't the light layers change frame??
							end
						end
					end
				end
			end
		
		-- Mausoleum
		elseif bg == BackdropType.MAUSOLEUM or bg == BackdropType.MAUSOLEUM2 then
			if IBackdropsIsValidBossRoom() then
				IBackdropsChangeBG(BackdropType.MAUSOLEUM3)
			else
				local add = 1
				if bg == BackdropType.MAUSOLEUM2 then
					add = 2
				end
				
				if shape == LBL or shape == LBR or shape == LTL or shape == LTR then
					IBackdropsCustomBG("mausoleum_l_inner_" .. add, "L")
				elseif shape == IH or shape == IIH or shape == IV or shape == IIV then
					IBackdropsCustomBG("ihv_mausoleum_" .. add)
				end
			end
		
		-- Downpour Entrance
		elseif bg == BackdropType.DOWNPOUR_ENTRANCE then
			--IBackdropsTopDecorPositions(shape)
		
		-- Dross
		elseif bg == BackdropType.DROSS then
			if not room:HasWater() then
				IBackdropsCustomBG("dross_drain", "corner")
			end
			if IBackdropsIsValidBossRoom() then
				IBackdropsCustomBG("boss_dross_1")
			end
		
		-- Ashpit
		elseif bg == BackdropType.ASHPIT then
			if IBackdropsIsValidBossRoom() then
				IBackdropsCustomBG("boss_ashpit_1")
			end
		
		-- Gehenna
		elseif bg == BackdropType.GEHENNA then
			if shape == LBL or shape == LBR or shape == LTL or shape == LTR then
				IBackdropsCustomBG("gehenna_l_inner", "L")
			elseif shape == IH or shape == IIH or shape == IV or shape == IIV then
				IBackdropsCustomBG("ihv_gehenna")
			end
		end
	end
	
	
	-- Custom rocks
	if room:IsInitialized() then
		-- Sacrifice rooms / Necropolis
		if bg == BackdropType.SACRIFICE or bg == BackdropType.NECROPOLIS then
			IBackdropsGetGrids("rocks_necropolis_custom")
			
		-- Dank Depths
		elseif bg == BackdropType.DANK_DEPTHS then
			IBackdropsGetGrids("rocks_dankdepths_custom")
			
		-- Scarred Womb
		elseif bg == BackdropType.SCARRED_WOMB then
			if room:HasWater() then
				IBackdropsGetGrids("rocks_scarredwomb_blood")
			end
			
		-- Dark Room
		elseif bg == BackdropType.DARKROOM then
			IBackdropsGetGrids("rocks_darkroom_custom")
			
		-- Chest
		elseif bg == BackdropType.CHEST then
			IBackdropsGetGrids("rocks_chest_custom")
		
		-- Dice rooms
		elseif bg == BackdropType.DICE then
			IBackdropsGetGrids("rocks_red")
		
		-- Arcades
		elseif bg == BackdropType.ARCADE then
			IBackdropsGetGrids("rocks_gray")

		-- Mines
		elseif bg == BackdropType.MINES then
			IBackdropsGetGrids("rocks_mines_custom")
		
		-- Mausoleum
		elseif bg == BackdropType.MAUSOLEUM or bg == BackdropType.MAUSOLEUM2 or bg == BackdropType.MAUSOLEUM_ENTRANCE or bg == BackdropType.MAUSOLEUM3 then
			IBackdropsGetGrids("rocks_mines_custom")
			
		-- Ashpit
		elseif bg == BackdropType.ASHPIT then
			if room:HasWaterPits() then
				IBackdropsGetGrids("rocks_ashpit_ash")
			else
				IBackdropsGetGrids("rocks_ashpit_custom")
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, mod.IBackdropsEnterRoom)



-- Persistent entity
function mod:IBackdropsPersistentEntity(entity)
	-- Overlays
	if entity.SubType == Settings.OverlaySubType and entity.FrameCount == 0 then
		local sprite = entity:GetSprite()
		local bg = game:GetRoom():GetBackdropType()

		local sheet = "cobwebs"
		if bg == BackdropType.CAVES then
			sheet = "caves"
		elseif bg == BackdropType.FLOODED_CAVES then
			sheet = "flooded"
		elseif bg == BackdropType.DEPTHS then
			sheet = "depths"
		elseif bg == BackdropType.DANK_DEPTHS then
			sheet = "dank"
		elseif bg == BackdropType.SHEOL then
			sheet = "sheol"
		elseif bg == BackdropType.DOWNPOUR_ENTRANCE then
			sheet = "downpour"
		end

		sprite:ReplaceSpritesheet(0, "gfx/backdrop/custom/overlay_" .. sheet .. ".png")
		sprite:SetFrame(entity.State % 10) -- set frame to the last digit of the state (even numbers - left, odd numbers - right)
		sprite:LoadGraphics()
		entity.DepthOffset = 10000 -- make the entity appear above other ones
		entity.Visible = true



	end
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, mod.IBackdropsPersistentEntity, EffectVariant.SPAWNER)



function IBackdropsChangeBG(id, bloody)
	if bloody == true then
		game:ShowHallucination(0, 1)
	end
	game:ShowHallucination(0, id)
	SFXManager():Stop(SoundEffect.SOUND_DEATH_CARD)
end



-- Get overlay decor positions
function IBackdropsTopDecorPositions(shape)
	if config.cooloverlays == true then
		local values = {}
		
		if shape == IV or shape == IIV then
			table.insert(values, {0, 140, false}) -- left
			table.insert(values, {1, 500, false}) -- right
			
		else
			local thin = false
			local extra = 0
			if shape == IH or shape == IIH then
				thin = true
			elseif shape == LTL then
				extra = 520
			end
			
			table.insert(values, {0, -20 + extra, thin}) -- left
			table.insert(values, {2, 180 + extra, thin}) -- extra left

			if shape == long or shape == big or shape == LBL or shape == LBR or shape == IIH then
				table.insert(values, {2, 380, thin}) -- extra left
				table.insert(values, {3, 780, thin}) -- extra right
				table.insert(values, {3, 980, thin}) -- extra right
				table.insert(values, {1, 1180, thin}) -- right
				
			else
				table.insert(values, {1, 660 + extra, thin}) -- right
				table.insert(values, {3, 460 + extra, thin}) -- extra right
			end
		end
		
		for i, entry in pairs(values) do
			IBackdropsSpawnTopDecor(entry[1], entry[2], entry[3])
		end
	end
end

-- Spawn overlay decor
function IBackdropsSpawnTopDecor(type, x, thin)
	if math.random(1, 8) > 5 then
		local y = 60
		if thin == true then -- If room is thin horizontal
			y = 140
		end
		local alt = math.random(0, 1) * 4
		
		local entity = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SPAWNER, Settings.OverlaySubType, Vector(x, y), Vector.Zero, nil):ToEffect()
		entity.State = Settings.StateOffset + type + alt
	end
end



-- Go through all grid entities and replace their spritesheet if they're a rock variant
function IBackdropsGetGrids(spritesheet, checkType)
	if config.customrocks == true then
		local room = game:GetRoom()
		
		for grindex = 0, room:GetGridSize() - 1 do
			if room:GetGridEntity(grindex) ~= nil then
				local grid = room:GetGridEntity(grindex)
				local replace = false
				
				if checkType == nil and IBackdropsIsRock(grid:GetType()) == true then
					replace = true
				elseif grid:GetType() == checkType then
					replace = true
				end
				
				if replace == true then
					local gridsprite = grid:GetSprite()
					gridsprite:ReplaceSpritesheet(0, "gfx/grid/" .. spritesheet .. ".png")
					gridsprite:ReplaceSpritesheet(1, "gfx/grid/" .. spritesheet .. ".png")
					gridsprite:LoadGraphics()
				end
			end
		end
	end
end

-- Check if the grid entity is a rock variant
function IBackdropsIsRock(t)
	if config.tintedcompat == true then
		if t == 2 or t == 3 or t == 5 or t == 6 or t == 22 or t == 24 or t == 25 or t == 26 or t == 27 then
			return true
		end
	else
		if t == 2 or t == 3 or t == 4 or t == 5 or t == 6 or t == 22 or t == 24 or t == 25 or t == 26 or t == 27 then
			return true
		end
	end
end



-- Spawn decoration grids
function IBackdropsSpawnDecorGrids(shape)
	local debrisExtra = 0
	if shape == tall or shape == long then
		debrisExtra = 2
	elseif shape == IH or shape == IV then
		debrisExtra = -2
	elseif shape >= 8 then
		debrisExtra = 4
	end

	for i = 0, math.random(1, 4 + debrisExtra) do
		Isaac.GridSpawn(GridEntityType.GRID_DECORATION, 1, Isaac.GetRandomPosition(), false)
	end
end



-- Special overlays
function mod:IBackdropsVoidOverlay()
    if config.voidstatic == true and game:GetLevel():GetStage() == LevelStage.STAGE7 then
        if static == nil then
			static = Sprite()
			static:Load("/gfx/backdrop/void_static.anm2", true)
        end
		
		static:Render(game:GetRoom():GetRenderSurfaceTopLeft(), Vector.Zero, Vector.Zero)
		static:Play("Stage", false)
		static:Update()
    end
end
mod:AddCallback(ModCallbacks.MC_POST_RENDER, mod.IBackdropsVoidOverlay)



-- Save / load settings
function mod:postGameStarted()
    if mod:HasData() then
        local data = json.decode(mod:LoadData())
        for k, v in pairs(data) do
            if config[k] ~= nil then config[k] = v end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, mod.postGameStarted)

function mod:preGameExit() mod:SaveData(json.encode(config)) end
mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, mod.preGameExit)



-- Mod config menu settings
if ModConfigMenu then
  	local category = "Improved Backdrops"
	ModConfigMenu.RemoveCategory(category);
  	ModConfigMenu.UpdateCategory(category, {
		Name = category,
		Info = "Change settings for Improved Backdrops"
	})
	
	-- General settings
	ModConfigMenu.AddSetting(category, "General", {
    	Type = ModConfigMenu.OptionType.BOOLEAN,
	    CurrentSetting = function() return config.customrocks end,
	    Display = function() return "Custom rocks: " .. (config.customrocks and "True" or "False") end,
	    OnChange = function(bool)
	    	config.customrocks = bool
	    end,
	    Info = {"Enable/Disable the mod's custom rocks. (default = true)"}
  	})
	
  	ModConfigMenu.AddSetting(category, "General", {
    	Type = ModConfigMenu.OptionType.BOOLEAN,
	    CurrentSetting = function() return config.tintedcompat end,
	    Display = function() return "Tinted rock compatibility: " .. (config.tintedcompat and "True" or "False") end,
	    OnChange = function(bool)
	    	config.tintedcompat = bool
	    end,
	    Info = {"(for the custom rocks option) Tinted rocks will not use custom sprites, allowing you to use tinted rock mods. (default = false)"}
  	})
	
	ModConfigMenu.AddSetting(category, "General", {
    	Type = ModConfigMenu.OptionType.BOOLEAN,
	    CurrentSetting = function() return config.cooloverlays end,
	    Display = function() return "Overlay details: " .. (config.cooloverlays and "True" or "False") end,
	    OnChange = function(bool)
	    	config.cooloverlays = bool
	    end,
	    Info = {"Enable/Disable overlay details eg. Stalactites in caves. (default = true)"}
  	})
	
	ModConfigMenu.AddSetting(category, "General", {
    	Type = ModConfigMenu.OptionType.BOOLEAN,
	    CurrentSetting = function() return config.voidstatic end,
	    Display = function() return "Void Overlay: " .. (config.voidstatic and "True" or "False") end,
	    OnChange = function(bool)
	    	config.voidstatic = bool
	    end,
	    Info = {"Enable/Disable the Void overlay. (default = true)"}
  	})
	
	ModConfigMenu.AddSetting(category, "General", {
    	Type = ModConfigMenu.OptionType.BOOLEAN,
	    CurrentSetting = function() return config.randvoid end,
	    Display = function() return "Randomize Void backdrops: " .. (config.randvoid and "True" or "False") end,
	    OnChange = function(bool)
	    	config.randvoid = bool
	    end,
	    Info = {"Enable/Disable randomized Void backdrops. (default = true)"}
  	})

	
	-- Unique special rooms
	ModConfigMenu.AddSetting(category, "Special", {
    	Type = ModConfigMenu.OptionType.BOOLEAN,
	    CurrentSetting = function() return config.udevil end,
	    Display = function() return "Unique devil rooms: " .. (config.udevil and "True" or "False") end,
	    OnChange = function(bool)
	    	config.udevil = bool
	    end,
	    Info = {"Enable/Disable unique devil rooms. (default = true)"}
  	})
	
	ModConfigMenu.AddSetting(category, "Special", {
    	Type = ModConfigMenu.OptionType.BOOLEAN,
	    CurrentSetting = function() return config.uangel end,
	    Display = function() return "Unique angel rooms: " .. (config.uangel and "True" or "False") end,
	    OnChange = function(bool)
	    	config.uangel = bool
	    end,
	    Info = {"Enable/Disable unique angel rooms. (default = true)"}
  	})
	
	ModConfigMenu.AddSetting(category, "Special", {
    	Type = ModConfigMenu.OptionType.BOOLEAN,
	    CurrentSetting = function() return config.ucurse end,
	    Display = function() return "Unique curse rooms: " .. (config.ucurse and "True" or "False") end,
	    OnChange = function(bool)
	    	config.ucurse = bool
	    end,
	    Info = {"Enable/Disable unique curse rooms. (default = true)"}
  	})
	
	ModConfigMenu.AddSetting(category, "Special", {
    	Type = ModConfigMenu.OptionType.BOOLEAN,
	    CurrentSetting = function() return config.uchallenge end,
	    Display = function() return "Unique challenge rooms: " .. (config.uchallenge and "True" or "False") end,
	    OnChange = function(bool)
	    	config.uchallenge = bool
	    end,
	    Info = {"Enable/Disable unique challenge rooms. This also applies to boss rush. (default = true)"}
  	})
	
	ModConfigMenu.AddSetting(category, "Special", {
    	Type = ModConfigMenu.OptionType.BOOLEAN,
	    CurrentSetting = function() return config.ucrawlspace end,
	    Display = function() return "Unique crawlspaces: " .. (config.ucrawlspace and "True" or "False") end,
	    OnChange = function(bool)
	    	config.ucrawlspace = bool
	    end,
	    Info = {"Enable/Disable unique crawlspaces. (default = true)"}
  	})
	
	ModConfigMenu.AddSetting(category, "Special", {
    	Type = ModConfigMenu.OptionType.BOOLEAN,
	    CurrentSetting = function() return config.ubmarket end,
	    Display = function() return "Unique black market: " .. (config.ubmarket and "True" or "False") end,
	    OnChange = function(bool)
	    	config.ubmarket = bool
	    end,
	    Info = {"Enable/Disable unique black markets. (default = true)"}
  	})
	
	
	-- Unique boss / miniboss rooms
	ModConfigMenu.AddSetting(category, "Boss", {
    	Type = ModConfigMenu.OptionType.BOOLEAN,
	    CurrentSetting = function() return config.custombossrooms end,
	    Display = function() return "Custom boss rooms: " .. (config.custombossrooms and "True" or "False") end,
	    OnChange = function(bool)
	    	config.custombossrooms = bool
	    end,
	    Info = {"Enable/Disable the custom boss rooms. (default = true)"}
  	})
	
	ModConfigMenu.AddSetting(category, "Boss", {
    	Type = ModConfigMenu.OptionType.BOOLEAN,
	    CurrentSetting = function() return config.customgreedrooms end,
	    Display = function() return "Custom greed miniboss rooms: " .. (config.customgreedrooms and "True" or "False") end,
	    OnChange = function(bool)
	    	config.customgreedrooms = bool
	    end,
	    Info = {"Enable/Disable custom greed miniboss rooms. (default = true)"}
  	})
end