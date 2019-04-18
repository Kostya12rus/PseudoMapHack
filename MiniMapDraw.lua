local MiniMapDraw = {}
local KostyaUtils = require("KostyaUtils/Utils")
MiniMapDraw.TrigerActiv = Menu.AddOption({"Kostya12rus", "MiniMapDraw"}, "Off/On", "")
MiniMapDraw.IconSize = Menu.AddOption({"Kostya12rus", "MiniMapDraw"}, "Size minimap icon", "", 500, 1500, 100)
--[[ MiniMapDraw.HeroIconOnly = Menu.AddOption({"Kostya12rus", "MiniMapDraw"}, "Only Hero icon", "") ]]

function MiniMapDraw.OnParticleCreate(particle)
	if not Menu.IsEnabled(MiniMapDraw.TrigerActiv) then return end
	for _,nameparticle in pairs(MiniMapDraw.TableIngoreParticleName) do
		if particle.name == nameparticle then
			return
		end
	end
	if not MiniMapDraw.TableParticle[particle.index] then
		local npc = nil
		if NPCs.Contains(particle.entity) and not NPCs.Contains(particle.entityForModifiers) then
			npc = particle.entity
		end
		if not NPCs.Contains(particle.entity) and NPCs.Contains(particle.entityForModifiers) then
			npc = particle.entityForModifiers
		end
		if NPCs.Contains(particle.entity) and NPCs.Contains(particle.entityForModifiers) then
			npc = particle.entityForModifiers
		end
		MiniMapDraw.TableParticle[particle.index] = 
		{
			name = particle.name,
			entity = npc,
			pos = nil,
			timing = GameRules.GetGameTime() + 3,
			drawing = false
		}
	end
end

function MiniMapDraw.OnParticleUpdate(particle)
	if not Menu.IsEnabled(MiniMapDraw.TrigerActiv) then return end
	if MiniMapDraw.TableParticle[particle.index] then
		if MiniMapDraw.CheckVector(particle.position) then
			MiniMapDraw.TableParticle[particle.index].timing = GameRules.GetGameTime() + 3
			MiniMapDraw.TableParticle[particle.index].drawing = false
			MiniMapDraw.TableParticle[particle.index].pos = particle.position
		end
	else
		if MiniMapDraw.CheckVector(particle.position) then
			if particle.entity and NPCs.Contains(particle.entity) and Heroes.Contains(particle.entity) then
				MiniMap.AddIcon(nil, Hero.GetIcon(particle.entity), particle.position, 255, 255, 255, 255, 1, Menu.GetValue(MiniMapDraw.IconSize))
				Renderer.AddWorldIcon(nil, Hero.GetIcon(particle.entity), particle.position, 255, 255, 255, 255, 1, 32)
			else
				MiniMap.AddIconByName(nil, "minimap_plaincircle", particle.position, 255, 255, 255, 255, 1, Menu.GetValue(MiniMapDraw.IconSize))
			end
		end
	end
end

function MiniMapDraw.OnParticleUpdateEntity(particle)
	if not Menu.IsEnabled(MiniMapDraw.TrigerActiv) then return end
	if MiniMapDraw.TableParticle[particle.index] then
		if MiniMapDraw.TableParticle[particle.index].entity and not Heroes.Contains(MiniMapDraw.TableParticle[particle.index].entity) then
			if particle.entity and Heroes.Contains(particle.entity) then
				MiniMapDraw.TableParticle[particle.index].entity = particle.entity
			end
		end
		if MiniMapDraw.CheckVector(particle.position) then
			MiniMapDraw.TableParticle[particle.index].timing = GameRules.GetGameTime() + 3
			MiniMapDraw.TableParticle[particle.index].drawing = false
			MiniMapDraw.TableParticle[particle.index].pos = particle.position
		end
	else
		if MiniMapDraw.CheckVector(particle.position) then
			if particle.entity and NPCs.Contains(particle.entity) and Heroes.Contains(particle.entity) then
				MiniMap.AddIcon(nil, Hero.GetIcon(particle.entity), particle.position, 255, 255, 255, 255, 1, Menu.GetValue(MiniMapDraw.IconSize))
				Renderer.AddWorldIcon(nil, Hero.GetIcon(particle.entity), particle.position, 255, 255, 255, 255, 1, 32)
			else
				MiniMap.AddIconByName(nil, "minimap_plaincircle", particle.position, 255, 255, 255, 255, 1, Menu.GetValue(MiniMapDraw.IconSize))
			end
		end
	end
end

function MiniMapDraw.OnUpdate()
	Renderer.SetDrawColor(255,255,255,255)
	if not Menu.IsEnabled(MiniMapDraw.TrigerActiv) then return end
	if MiniMapDraw.TableParticle then
		for i,tableinfo in pairs(MiniMapDraw.TableParticle) do
			if tableinfo then
				if tableinfo.timing <= GameRules.GetGameTime() or not tableinfo.pos then
					MiniMapDraw.TableParticle[i] = nil
				end
			end
			if not tableinfo.drawing and tableinfo.pos then
				if tableinfo.entity and NPCs.Contains(tableinfo.entity) and Heroes.Contains(tableinfo.entity) then
					MiniMap.AddIcon(nil, Hero.GetIcon(tableinfo.entity), tableinfo.pos, 255, 255, 255, 255, 3, Menu.GetValue(MiniMapDraw.IconSize))
					Renderer.AddWorldIcon(nil, Hero.GetIcon(tableinfo.entity), tableinfo.pos, 255, 255, 255, 255, 3, 32)
					tableinfo.drawing = true
				else
					MiniMap.AddIconByName(nil, "minimap_plaincircle", tableinfo.pos, 255, 255, 255, 255, 3, Menu.GetValue(MiniMapDraw.IconSize))
					tableinfo.drawing = true
				end
			end
		end
	end
end

function MiniMapDraw.CheckVector(vec)
	if not vec then return end
	local hasnpcinpos = NPCs.InRadius(vec,10,2,Enum.TeamType.TEAM_BOTH)
	if hasnpcinpos and #hasnpcinpos ~= 0 then
		for i,j in pairs(hasnpcinpos) do
			if NPCs.Contains(j) and NPC.GetUnitName(j) ~= "npc_dota_thinker" then
				return false
			end
		end
	end
	local realpos = KostyaUtils.RealPosInWorld(vec)
	if realpos then
		local realz = math.ceil(realpos:GetZ())
		local checkz = math.ceil(vec:GetZ())
		if (realz+10 >= checkz and realz-2 <= checkz) and checkz < 1000 and checkz > -300 then
			return true
		end
	end
	return false
end

function MiniMapDraw.init()
	MiniMapDraw.TableParticle = {}
	MiniMapDraw.TableIngoreParticleName = 
	{
		"dire_creep_spawn",
		"radiant_creep_spawn"
	}
end

function MiniMapDraw.OnGameStart()
  MiniMapDraw.init()
end

function MiniMapDraw.OnGameEnd()
  MiniMapDraw.init()
end
MiniMapDraw.init()

return MiniMapDraw