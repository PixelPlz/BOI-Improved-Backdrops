ImprovedBackdrops = RegisterMod("Improved Backdrops", 1)
local mod = ImprovedBackdrops
local game = Game()
local json = require("json")

-- This code is terrible... I should rewrite it *again* someday.



-- Backdrop enums
BackdropType.MAUSOLEUM_BOSS = BackdropType.MAUSOLEUM3
BackdropType.GEHENNA_BOSS = BackdropType.MAUSOLEUM4
BackdropType.CORPSE_ENTRANCE_GEHENNA = BackdropType.MORTIS

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

-- Positions for custom room entities
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

-- Positions for inner L room walls
local LinnerPositions = {
	Vector(-20,  340), -- LTL
	Vector(1180, 340), -- LTR
	Vector(-20,  500), -- LBL
	Vector(1180, 500), -- LBR
}

-- Mod config menu settings
local config = {
	-- General
	customrocks 	 = true,
	tintedcompat 	 = false,
	cooloverlays 	 = true,
	voidstatic 		 = false,
	randvoid 		 = false,
	-- Special rooms
	udevil 			 = true,
	uangel 			 = true,
	ucurse 			 = true,
	uchallenge 		 = true,
	ucrawlspace 	 = true,
	ubmarket 		 = true,
	-- Boss rooms
	custombossrooms  = true,
	customgreedrooms = true,
}



-- Load settings
function mod:postGameStarted()
    if mod:HasData() then
        local data = json.decode(mod:LoadData())
        for k, v in pairs(data) do
            if config[k] ~= nil then config[k] = v end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, mod.postGameStarted)

-- Save settings
function mod:preGameExit() mod:SaveData(json.encode(config)) end
mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, mod.preGameExit)



-- For Revelations compatibility
function mod:CheckForRev()
	if REVEL and REVEL.IsRevelStage(true) then
		return true
	else
		return false
	end
end



-- Spawn entities when entering a room
function mod:IBackdropsEnterRoom()
	local room = game:GetRoom()
	local bg = room:GetBackdropType()
	local rtype = room:GetType()
	local shape = room:GetRoomShape()
	local level = game:GetLevel()
	local stage = level:GetStage()
	local roomDesc = level:GetRoomByIdx(level:GetCurrentRoomIndex())


	-- Check if boss room is valid for custom walls
	function IBackdropsIsValidBossRoom()
		if config.custombossrooms == true
		and (rtype == RoomType.ROOM_BOSS or rtype == RoomType.ROOM_MINIBOSS) and stage ~= LevelStage.STAGE7
		and (not StageAPI or not StageAPI.InNewStage()) then
			return true
		else
			return false
		end
	end


	-- Non-persistent changes
	if room:IsInitialized() then
		-- Basement
		if bg == BackdropType.BASEMENT then
			if config.custombossrooms == true and rtype == RoomType.ROOM_MINIBOSS then
				IBackdropsCustomBG("boss_basement_1")
			end

		-- Cellar
		elseif bg == BackdropType.CELLAR then
			if IBackdropsIsValidBossRoom() == true then
				IBackdropsChangeBG(bg, true)
				IBackdropsCustomBG("boss_cellar_1")
			end

		-- Burning Basement
		elseif bg == BackdropType.BURNT_BASEMENT then
			if room:GetDecorationSeed() % 2 == 0 or IBackdropsIsValidBossRoom() == true then
				IBackdropsCustomBG("burning_ash", "corner")
				if IBackdropsIsValidBossRoom() == true then
					IBackdropsCustomBG("boss_burning_1")
				end
				IBackdropsGetGrids("rocks_burning_custom")
			end

		-- Caves
		elseif bg == BackdropType.CAVES then
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
			if IBackdropsIsValidBossRoom() == true then
				IBackdropsCustomBG("boss_flooded_1")
			end

		-- Depths
		elseif bg == BackdropType.DEPTHS then
			if IBackdropsIsValidBossRoom() == true then
				IBackdropsChangeBG(bg, true)
				IBackdropsCustomBG("boss_depths_1")
			else
				if shape ~= IV and shape ~= IIV then
					IBackdropsCustomBG("depths_pillar", "corner")
				end
			end

		-- Necropolis / Sacrifice rooms
		elseif bg == BackdropType.NECROPOLIS or bg == BackdropType.SACRIFICE then
			IBackdropsGetGrids("rocks_necropolis_custom")
			if bg == BackdropType.NECROPOLIS then
				if IBackdropsIsValidBossRoom() == true then
					IBackdropsChangeBG(bg, true)
					IBackdropsCustomBG("boss_necropolis_1")
				end
			end

		-- Dank Depths
		elseif bg == BackdropType.DANK_DEPTHS then
			IBackdropsGetGrids("rocks_dankdepths_custom")
			if IBackdropsIsValidBossRoom() == true then
				IBackdropsCustomBG("boss_dank_1")
			else
				if shape ~= IV and shape ~= IIV then
					IBackdropsCustomBG("dank_pillar", "corner")
				end
			end

		-- Scarred Womb
		elseif bg == BackdropType.SCARRED_WOMB then
			if room:HasWater() then
				IBackdropsGetGrids("rocks_scarredwomb_blood")
			end

		-- Sheol / Sheol backdrop special rooms
		elseif bg == BackdropType.SHEOL then
			if IBackdropsIsValidBossRoom() == true or (config.udevil == true and rtype == RoomType.ROOM_DEVIL and mod:CheckForRev() == false) then
				IBackdropsCustomBG("devil_1")

			elseif config.ucurse == true and rtype == RoomType.ROOM_CURSE and mod:CheckForRev() == false then
				IBackdropsChangeBG(bg, true, "dark")
				IBackdropsCustomBG("curse", "corner_extras")
				IBackdropsCustomBG("curse", "corner_extras_curse", true)

			elseif config.uchallenge == true and (rtype == RoomType.ROOM_CHALLENGE or rtype == RoomType.ROOM_BOSSRUSH) and mod:CheckForRev() == false and not FiendFolio then
				if stage % 2 == 0 then
					IBackdropsChangeBG(bg, true, "dark")
				end
				IBackdropsCustomBG("challenge_1")

			elseif config.ubmarket == true and rtype == RoomType.ROOM_BLACK_MARKET then
				IBackdropsCustomBG("blackmarket_1")
				IBackdropsGetGrids("rocks_depths")
			end

		-- Cathedral / Cathedral backdrop special rooms
		elseif bg == BackdropType.CATHEDRAL then
			if config.uangel == true and rtype == RoomType.ROOM_ANGEL then
				IBackdropsCustomBG("angel_1")
				IBackdropsGetGrids("rocks_angel")
				IBackdropsGetGrids("props_angel", GridEntityType.GRID_DECORATION)
				IBackdropsGetGrids("grid_pit_angel", GridEntityType.GRID_PIT)

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
			IBackdropsGetGrids("rocks_darkroom_custom")
			if shape == IH or shape == IV or shape == IIH or shape == IIV or shape > 8 then
				IBackdropsDarkRoomBottom(shape, tostring((room:GetDecorationSeed() % 2) + 1))
			elseif shape == reg then
				if IBackdropsIsValidBossRoom() == true then
					IBackdropsCustomBG("boss_darkroom", "boss_darkroom")
					IBackdropsCustomBG("boss_darkroom", "boss_darkroom_lights", true)
				end
			end

		-- Chest
		elseif bg == BackdropType.CHEST then
			IBackdropsGetGrids("rocks_chest_custom")

		-- Shop
		elseif bg == BackdropType.SHOP then
			if shape == reg and not (mod:CheckForRev() == true and StageAPI.GetCurrentRoomType() == "VanityShop") then
				IBackdropsCustomBG("shop_1")
			end
			if (config.customgreedrooms == true and roomDesc.SurpriseMiniboss == true) or stage == LevelStage.STAGE4_3 then
				IBackdropsCustomBG("greed_shop")
			end

		-- Secret Room
		elseif bg == BackdropType.SECRET then
			if (config.customgreedrooms == true and roomDesc.SurpriseMiniboss == true) or rtype == RoomType.ROOM_SHOP then
				IBackdropsCustomBG("greed_secret")
			elseif rtype == RoomType.ROOM_SECRET_EXIT then
				IBackdropsChangeBG(BackdropType.MINES_ENTRANCE)
			end

		-- Dice rooms
		elseif bg == BackdropType.DICE then
			IBackdropsGetGrids("rocks_red")

		-- Arcades
		elseif bg == BackdropType.ARCADE then
			IBackdropsGetGrids("rocks_gray")
			if shape == IH or shape == IIH or shape == IV or shape == IIV then
				IBackdropsCustomBG("ihv_arcade")
			end

		-- Crawlspaces
		elseif bg == BackdropType.DUNGEON then
			if stage == LevelStage.STAGE3_1 or stage == LevelStage.STAGE3_2 or stage == LevelStage.STAGE5 then
				IBackdropsCrawlspace("tiles_itemdungeon_gray")
			elseif stage == LevelStage.STAGE4_1 or stage == LevelStage.STAGE4_2 then
				if level:GetStageType() == StageType.STAGETYPE_REPENTANCE then
					IBackdropsCrawlspace("tiles_rotgut")
				else
					IBackdropsCrawlspace("tiles_womb")
				end
			elseif stage == LevelStage.STAGE4_3 then
				IBackdropsCrawlspace("tiles_bluewomb")
			end

		-- Downpour
		elseif bg == BackdropType.DOWNPOUR then
			if IBackdropsIsValidBossRoom() then
				IBackdropsCustomBG("boss_downpour_1")
			end

		-- Mines
		elseif bg == BackdropType.MINES or bg == BackdropType.MINES_SHAFT then
			IBackdropsGetGrids("rocks_mines_custom")
			if IBackdropsIsValidBossRoom() then
				-- Remove decoration sprites that don't fit
				for i,problematics in pairs(Isaac.GetRoomEntities()) do
					if problematics.Type == EntityType.ENTITY_EFFECT and problematics.Variant == EffectVariant.BACKDROP_DECORATION then
						if problematics:GetSprite():GetFilename() ~= "gfx/backdrop/03x_mines_lanterns.anm2" and problematics:GetSprite():GetFilename() ~= "gfx/backdrop/03x_mines_lanterns_dark.anm2" then	
							problematics:Remove()
						end
					end
				end
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
								problemsprite:SetFrame(2)
							end
						end
					end
				end
			end

		-- Mausoleum
		elseif bg == BackdropType.MAUSOLEUM or bg == BackdropType.MAUSOLEUM2 or bg == BackdropType.MAUSOLEUM_ENTRANCE or bg == BackdropType.MAUSOLEUM3 then
			IBackdropsGetGrids("rocks_mausoleum_custom")

			if bg == BackdropType.MAUSOLEUM or bg == BackdropType.MAUSOLEUM2 then
				if IBackdropsIsValidBossRoom() then
					IBackdropsChangeBG(BackdropType.MAUSOLEUM_BOSS)
				else
					local add = "1"
					if bg == BackdropType.MAUSOLEUM2 then
						add = "2"
					end

					if shape == LBL or shape == LBR or shape == LTL or shape == LTR then
						IBackdropsCustomBG("mausoleum_l_inner_" .. add, "L")
					elseif shape == IH or shape == IIH or shape == IV or shape == IIV then
						IBackdropsCustomBG("ihv_mausoleum_" .. add)
					end
				end
			end

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
			if room:HasWaterPits() or (roomDesc.Flags & RoomDescriptor.FLAG_USE_ALTERNATE_BACKDROP > 0) then
				IBackdropsGetGrids("rocks_ashpit_ash")
				if (roomDesc.Flags & RoomDescriptor.FLAG_USE_ALTERNATE_BACKDROP > 0) and not room:HasWaterPits() then
					IBackdropsGetGrids("grid_pit_ashpit_ash", GridEntityType.GRID_PIT)
				end
			else
				IBackdropsGetGrids("rocks_ashpit_custom")
			end
			if IBackdropsIsValidBossRoom() then
				IBackdropsCustomBG("boss_ashpit_1")
			end

		-- Gehenna
		elseif bg == BackdropType.GEHENNA then
			-- Post-Mom's Heart
			if game:GetStateFlag(GameStateFlag.STATE_MAUSOLEUM_HEART_KILLED) and stage == LevelStage.STAGE3_2 then
				IBackdropsChangeBG(BackdropType.CORPSE_ENTRANCE_GEHENNA, true, "dark")
				-- Remove wall details
				for i,problematics in pairs(Isaac.GetRoomEntities()) do
					if problematics.Type == EntityType.ENTITY_EFFECT and problematics.Variant == EffectVariant.BACKDROP_DECORATION then
						if problematics:GetSprite():GetFilename() == "gfx/backdrop/06x_gehenna_wall_details.anm2" then	
							problematics:Remove()
						end
					end
				end
			else
				if IBackdropsIsValidBossRoom() then
					IBackdropsChangeBG(BackdropType.GEHENNA_BOSS)
				else
					if shape == LBL or shape == LBR or shape == LTL or shape == LTR then
						IBackdropsCustomBG("gehenna_l_inner", "L")
					elseif shape == IH or shape == IIH or shape == IV or shape == IIV then
						IBackdropsCustomBG("ihv_gehenna")
					end
				end
			end
		end

		-- Randomized Void backdrops
		if config.randvoid == true and stage == LevelStage.STAGE7 and rtype == RoomType.ROOM_DEFAULT and bg ~= BackdropType.DARKROOM then
			IBackdropsChangeBG()
		end
	end


	-- Persistent changes
	if room:IsFirstVisit() then
		-- Overlays
		if bg == BackdropType.CELLAR or bg == BackdropType.CAVES or bg == BackdropType.FLOODED_CAVES or bg == BackdropType.DEPTHS or bg == BackdropType.DANK_DEPTHS 
		or (bg == BackdropType.SHEOL and rtype == RoomType.ROOM_DEFAULT) or bg == BackdropType.DOWNPOUR_ENTRANCE then
			IBackdropsTopDecorPositions(shape)

		-- Dark Room decoration grids
		elseif bg == BackdropType.DARKROOM and rtype ~= RoomType.ROOM_BOSS then
			IBackdropsSpawnDecorGrids(shape)
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, mod.IBackdropsEnterRoom)



-- Custom walls
function IBackdropsCustomBG(sheet, anim, animated)
	if not (FiendFolio and FiendFolio.roomBackdrop ~= nil) then -- Don't do it in rooms with custom FF backdrops
		local shape = game:GetRoom():GetRoomShape()

		if anim == "corner" then
			anim = "corner_extras"
		elseif anim == "L" then
			anim = "wall_L_inner"
		elseif not anim then
			anim = "walls"
		end

		local type = EffectVariant.BACKDROP_DECORATION
		local flags = EntityFlag.FLAG_RENDER_FLOOR | EntityFlag.FLAG_RENDER_WALL | EntityFlag.FLAG_BACKDROP_DETAIL
		if animated == true then
			type = EffectVariant.WORMWOOD_HOLE
			flags = EntityFlag.FLAG_BACKDROP_DETAIL
		end


		-- L room inner walls
		if anim == "wall_L_inner" then
			local backdrop = Isaac.Spawn(EntityType.ENTITY_EFFECT, type, 0, LinnerPositions[shape - 8], Vector.Zero, nil):ToEffect()
			backdrop:AddEntityFlags(flags)
			backdrop.DepthOffset = -10000

			local sprite = backdrop:GetSprite()
			sprite:Load("gfx/backdrop/custom/" .. anim .. ".anm2", false)
			for i = 0, sprite:GetLayerCount() do
				sprite:ReplaceSpritesheet(i, "gfx/backdrop/custom/" .. sheet .. ".png")
			end
			sprite:LoadGraphics()
			sprite:SetFrame(sprite:GetDefaultAnimation(), shape - 9)


		-- Walls / Corner details
		else
			for p = 1, 4 do
				local backdrop = Isaac.Spawn(EntityType.ENTITY_EFFECT, type, 0, BackdropPositons[shape][p], Vector.Zero, nil):ToEffect()
				backdrop:AddEntityFlags(flags)
				backdrop.DepthOffset = -10000

				local sprite = backdrop:GetSprite()
				sprite:Load("gfx/backdrop/custom/" .. anim .. ".anm2", false)
				for i = 0, sprite:GetLayerCount() do
					sprite:ReplaceSpritesheet(i, "gfx/backdrop/custom/" .. sheet .. ".png")
				end
				sprite:LoadGraphics()

				if anim == "walls" then
					sprite:Play(shape, true)
				else
					sprite:Play(sprite:GetDefaultAnimation(), true)
				end
				sprite:SetFrame(p - 1)
			end
		end
	end
end



-- Persistent entity
function mod:IBackdropsPersistentEntity(entity)
	if config.cooloverlays == true and entity.SubType == 2727 and entity.FrameCount == 0 then
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

		sprite:Load("gfx/backdrop/custom/overlay.anm2", false)
		sprite:ReplaceSpritesheet(0, "gfx/backdrop/custom/overlay_" .. sheet .. ".png")
		sprite:SetFrame(sprite:GetDefaultAnimation(), entity.State % 10) -- set frame to the last digit of the state (even numbers - left, odd numbers - right)
		sprite:LoadGraphics()
		entity.DepthOffset = 10000 -- make the entity appear above other ones
		entity.Visible = true
	end
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, mod.IBackdropsPersistentEntity, EffectVariant.SPAWNER)

-- Get overlay decor positions
function IBackdropsTopDecorPositions(shape)
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

-- Spawn overlay decor
function IBackdropsSpawnTopDecor(type, x, thin)
	if math.random(1, 8) > 5 then
		local y = 60
		if thin == true then -- If room is thin horizontal
			y = 140
		end
		local alt = math.random(0, 1) * 4

		local entity = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SPAWNER, 2727, Vector(x, y), Vector.Zero, nil):ToEffect()
		entity.State = 2000 + type + alt
	end
end



function IBackdropsChangeBG(id, bloody, bloodtype)
	if bloody == true then
		local bloodID = bloodtype == "dark" and BackdropType.CORPSE_ENTRANCE or BackdropType.BASEMENT
		if REPENTOGON then
			game:GetRoom():SetBackdropType(bloodID, 1)
		else
			game:ShowHallucination(0, bloodID)
		end
	end

	if REPENTOGON then
		game:GetRoom():SetBackdropType(id, 1)
	else
		game:ShowHallucination(0, id)
		SFXManager():Stop(SoundEffect.SOUND_DEATH_CARD)
	end
end



-- Go through all grid entities and replace their spritesheet if they're a rock variant
function IBackdropsGetGrids(spritesheet, checkType)
	if config.customrocks == true and not FiendFolio then
		local room = game:GetRoom()

		for grindex = 0, room:GetGridSize() - 1 do
			if room:GetGridEntity(grindex) ~= nil then
				local grid = room:GetGridEntity(grindex)
				local replace = false

				-- Replace it for rocks if not specified
				if checkType == nil and grid:ToRock() then
					replace = true
				elseif grid:GetType() == checkType then
					replace = true
				end

				if replace == true then
					local gridsprite = grid:GetSprite()
					gridsprite:ReplaceSpritesheet(0, "gfx/grid/" .. spritesheet .. ".png")
					if checkType ~= GridEntityType.GRID_PIT then
						gridsprite:ReplaceSpritesheet(1, "gfx/grid/" .. spritesheet .. ".png")
					end
					gridsprite:LoadGraphics()
				end
			end
		end
	end
end

-- Replace crawlspace grids
function IBackdropsCrawlspace(spritesheet)
	if config.ucrawlspace == true and not FiendFolio and not CrawlspacesRebuilt then
		local room = game:GetRoom()

		for grindex = 0, room:GetGridSize() - 1 do
			if room:GetGridEntity(grindex) ~= nil then
				local gtype = room:GetGridEntity(grindex):GetType()
				local gridsprite = room:GetGridEntity(grindex):GetSprite()

				if gtype == GridEntityType.GRID_WALL or gtype == GridEntityType.GRID_DECORATION or (gtype == GridEntityType.GRID_GRAVITY and gridsprite:GetFilename() ~= "") then
					gridsprite:ReplaceSpritesheet(0, "gfx/grid/" .. spritesheet .. ".png")
					gridsprite:ReplaceSpritesheet(1, "gfx/grid/" .. spritesheet .. ".png")
					gridsprite:LoadGraphics()
				end
			end
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



-- Dark Room bottom
function IBackdropsDarkRoomBottom(shape, spritesheet)
	local spawns = {}

	if shape == IH then
		table.insert(spawns, {Vector(-13, 410), 0}) -- Left
		table.insert(spawns, {Vector(652, 410), 4}) -- Right
	elseif shape == IV then
		table.insert(spawns, {Vector(147, 490), 3}) -- Bottom
	elseif shape == IIV then
		table.insert(spawns, {Vector(147, 770), 3}) -- Bottom
	elseif shape == IIH then
		table.insert(spawns, {Vector(-13,  410), 1}) -- Left
		table.insert(spawns, {Vector(1172, 410), 5}) -- Right
	elseif shape == LTL or shape == LTR then
		table.insert(spawns, {Vector(-13,  770), 1}) -- Left
		table.insert(spawns, {Vector(1172, 770), 5}) -- Right
	elseif shape == LBL then
		table.insert(spawns, {Vector(507,  770), 0}) -- Left
		table.insert(spawns, {Vector(1172, 770), 4}) -- Right
		table.insert(spawns, {Vector(-13,  490), 2}) -- Left extra
	elseif shape == LBR then
		table.insert(spawns, {Vector(-13,  770), 0}) -- Left
		table.insert(spawns, {Vector(652,  770), 4}) -- Right
		table.insert(spawns, {Vector(1172, 490), 6}) -- Right extra
	end

	for i, entry in pairs(spawns) do
		local backdrop = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BACKDROP_DECORATION, 0, entry[1], Vector.Zero, nil):ToEffect()
		backdrop:AddEntityFlags(EntityFlag.FLAG_RENDER_FLOOR | EntityFlag.FLAG_RENDER_WALL | EntityFlag.FLAG_BACKDROP_DETAIL)
		backdrop.DepthOffset = -10000

		local sprite = backdrop:GetSprite()
		sprite:Load("gfx/backdrop/custom/darkroom_bottom.anm2", false)
		sprite:SetFrame(sprite:GetDefaultAnimation(), entry[2])
		sprite:ReplaceSpritesheet(0, "gfx/backdrop/custom/darkroom_bottom_" .. spritesheet .. ".png")
		sprite:ReplaceSpritesheet(1, "gfx/backdrop/custom/darkroom_bottom_" .. spritesheet .. ".png")
		sprite:LoadGraphics()
	end
end



-- Menu options
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
	    Display = function() return "Custom rocks: " .. (config.customrocks and "On" or "Off") end,
	    OnChange = function(bool)
	    	config.customrocks = bool
	    end,
	    Info = {"Enable/Disable the mod's custom rocks. (default = on)"}
  	})

  	ModConfigMenu.AddSetting(category, "General", {
    	Type = ModConfigMenu.OptionType.BOOLEAN,
	    CurrentSetting = function() return config.tintedcompat end,
	    Display = function() return "Tinted rock compatibility: " .. (config.tintedcompat and "On" or "Off") end,
	    OnChange = function(bool)
	    	config.tintedcompat = bool
	    end,
	    Info = {"(for the custom rocks option) Tinted rocks will not use custom sprites, allowing you to use tinted rock mods. (default = off)"}
  	})

	ModConfigMenu.AddSetting(category, "General", {
    	Type = ModConfigMenu.OptionType.BOOLEAN,
	    CurrentSetting = function() return config.cooloverlays end,
	    Display = function() return "Overlay details: " .. (config.cooloverlays and "On" or "Off") end,
	    OnChange = function(bool)
	    	config.cooloverlays = bool
	    end,
	    Info = {"Enable/Disable overlay details eg. Stalactites in caves. (default = on)"}
  	})

	ModConfigMenu.AddSetting(category, "General", {
    	Type = ModConfigMenu.OptionType.BOOLEAN,
	    CurrentSetting = function() return config.voidstatic end,
	    Display = function() return "Void Overlay: " .. (config.voidstatic and "On" or "Off") end,
	    OnChange = function(bool)
	    	config.voidstatic = bool
	    end,
	    Info = {"Enable/Disable the Void overlay. (default = off)"}
  	})

	ModConfigMenu.AddSetting(category, "General", {
    	Type = ModConfigMenu.OptionType.BOOLEAN,
	    CurrentSetting = function() return config.randvoid end,
	    Display = function() return "Randomize Void backdrops: " .. (config.randvoid and "On" or "Off") end,
	    OnChange = function(bool)
	    	config.randvoid = bool
	    end,
	    Info = {"Enable/Disable randomized Void backdrops. (default = off)"}
  	})


	-- Unique special rooms
	ModConfigMenu.AddSetting(category, "Special", {
    	Type = ModConfigMenu.OptionType.BOOLEAN,
	    CurrentSetting = function() return config.udevil end,
	    Display = function() return "Unique devil rooms: " .. (config.udevil and "On" or "Off") end,
	    OnChange = function(bool)
	    	config.udevil = bool
	    end,
	    Info = {"Enable/Disable unique devil rooms. (default = on)"}
  	})

	ModConfigMenu.AddSetting(category, "Special", {
    	Type = ModConfigMenu.OptionType.BOOLEAN,
	    CurrentSetting = function() return config.uangel end,
	    Display = function() return "Unique angel rooms: " .. (config.uangel and "On" or "Off") end,
	    OnChange = function(bool)
	    	config.uangel = bool
	    end,
	    Info = {"Enable/Disable unique angel rooms. (default = on)"}
  	})

	ModConfigMenu.AddSetting(category, "Special", {
    	Type = ModConfigMenu.OptionType.BOOLEAN,
	    CurrentSetting = function() return config.ucurse end,
	    Display = function() return "Unique curse rooms: " .. (config.ucurse and "On" or "Off") end,
	    OnChange = function(bool)
	    	config.ucurse = bool
	    end,
	    Info = {"Enable/Disable unique curse rooms. (default = on)"}
  	})

	ModConfigMenu.AddSetting(category, "Special", {
    	Type = ModConfigMenu.OptionType.BOOLEAN,
	    CurrentSetting = function() return config.uchallenge end,
	    Display = function() return "Unique challenge rooms: " .. (config.uchallenge and "On" or "Off") end,
	    OnChange = function(bool)
	    	config.uchallenge = bool
	    end,
	    Info = {"Enable/Disable unique challenge rooms. This also applies to boss rush. (default = on)"}
  	})

	ModConfigMenu.AddSetting(category, "Special", {
    	Type = ModConfigMenu.OptionType.BOOLEAN,
	    CurrentSetting = function() return config.ucrawlspace end,
	    Display = function() return "Unique crawlspaces: " .. (config.ucrawlspace and "On" or "Off") end,
	    OnChange = function(bool)
	    	config.ucrawlspace = bool
	    end,
	    Info = {"Enable/Disable unique crawlspaces. (default = on)"}
  	})

	ModConfigMenu.AddSetting(category, "Special", {
    	Type = ModConfigMenu.OptionType.BOOLEAN,
	    CurrentSetting = function() return config.ubmarket end,
	    Display = function() return "Unique black market: " .. (config.ubmarket and "On" or "Off") end,
	    OnChange = function(bool)
	    	config.ubmarket = bool
	    end,
	    Info = {"Enable/Disable unique black markets. (default = on)"}
  	})


	-- Unique boss / miniboss rooms
	ModConfigMenu.AddSetting(category, "Boss", {
    	Type = ModConfigMenu.OptionType.BOOLEAN,
	    CurrentSetting = function() return config.custombossrooms end,
	    Display = function() return "Unique boss rooms: " .. (config.custombossrooms and "On" or "Off") end,
	    OnChange = function(bool)
	    	config.custombossrooms = bool
	    end,
	    Info = {"Enable/Disable unique boss rooms. (default = on)"}
  	})

	ModConfigMenu.AddSetting(category, "Boss", {
    	Type = ModConfigMenu.OptionType.BOOLEAN,
	    CurrentSetting = function() return config.customgreedrooms end,
	    Display = function() return "Unique Greed miniboss rooms: " .. (config.customgreedrooms and "On" or "Off") end,
	    OnChange = function(bool)
	    	config.customgreedrooms = bool
	    end,
	    Info = {"Enable/Disable unique Greed miniboss rooms. (default = on)"}
  	})
end