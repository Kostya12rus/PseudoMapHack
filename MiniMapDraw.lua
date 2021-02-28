local MiniMapDraw = {}
local KostyaUtils = require("KostyaUtils/Utils")
MiniMapDraw.TrigerActiv =		Menu.AddOption({"Kostya12rus", "MiniMapDraw"}, "Off/On", "")
MiniMapDraw.IconSize =			Menu.AddOption({"Kostya12rus", "MiniMapDraw"}, "Size minimap icon", "", 500, 1500, 100)
MiniMapDraw.HeroIconOnly =		Menu.AddOption({"Kostya12rus", "MiniMapDraw"}, "Type Draw", "", 0, 2, 1)
MiniMapDraw.OnlyHero =			Menu.AddOption({"Kostya12rus", "MiniMapDraw"}, "Only Hero Icon", "")

Menu.SetValueName(MiniMapDraw.HeroIconOnly, 0, 'MiniMap and World')
Menu.SetValueName(MiniMapDraw.HeroIconOnly, 1, 'MiniMap')
Menu.SetValueName(MiniMapDraw.HeroIconOnly, 2, 'World')

MiniMapDraw.Font = Renderer.LoadFont("Tahoma", 14, Enum.FontWeight.EXTRABOLD)

function MiniMapDraw.OnParticleCreate(particle)
	if not Menu.IsEnabled(MiniMapDraw.TrigerActiv) then return end
	local ignorethisparticle = false
	for _,nameparticle in pairs(MiniMapDraw.TableIngoreParticleName) do
		if particle.name == nameparticle then
			ignorethisparticle = true
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
		--if npc and Entity.IsSameTeam(Heroes.GetLocal(), npc) then return end
		MiniMapDraw.TableParticle[particle.index] = 
		{
			name = particle.name,
			entity = npc,
			pos = nil,
			timing = GameRules.GetGameTime() + 3,
			drawing = false,
			ignore = ignorethisparticle,
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
				if MiniMapDraw.CheckSameTeam(particle.entity) then return end
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
				if MiniMapDraw.CheckSameTeam(particle.entity) then return end
				MiniMap.AddIcon(nil, Hero.GetIcon(particle.entity), particle.position, 255, 255, 255, 255, 1, Menu.GetValue(MiniMapDraw.IconSize))
				Renderer.AddWorldIcon(nil, Hero.GetIcon(particle.entity), particle.position, 255, 255, 255, 255, 1, 32)
			else
				MiniMap.AddIconByName(nil, "minimap_plaincircle", particle.position, 255, 255, 255, 255, 1, Menu.GetValue(MiniMapDraw.IconSize))
			end
		end
	end
end

function MiniMapDraw.OnDraw()
	if not Menu.IsEnabled(MiniMapDraw.TrigerActiv) then return end
	if not Players.GetLocal() or not Players.Contains(Players.GetLocal()) then 
		MiniMapDraw.init()
		return 
	end
	if not MiniMapDraw.TeamNumLocal and (not Player.GetPlayerData(Players.GetLocal()) or Player.GetPlayerData(Players.GetLocal()).teamNum < 2) then
		MiniMapDraw.TeamNumLocal = MiniMapDraw.ChangeTeam()
	end
	if Heroes.GetLocal() and Heroes.Contains(Heroes.GetLocal()) and Entity.GetTeamNum(Heroes.GetLocal()) then
		MiniMapDraw.TeamNumLocal = Entity.GetTeamNum(Heroes.GetLocal())
	end
	local typedraw = Menu.GetValue(MiniMapDraw.HeroIconOnly)
	if MiniMapDraw.TableParticle then
		for i,tableinfo in pairs(MiniMapDraw.TableParticle) do
			if tableinfo.timing <= GameRules.GetGameTime() or not tableinfo.pos then
				MiniMapDraw.TableParticle[i] = nil
				return
			end
			if not tableinfo.ignore then
				if tableinfo then
					local realhero = tableinfo.entity and NPCs.Contains(tableinfo.entity)
					local herotriger = realhero and MiniMapDraw.CheckSameTeam(tableinfo.entity)
					local ingorenamehero = realhero and (NPC.GetUnitName(tableinfo.entity) == "npc_dota_hero_grimstroke")
					if tableinfo.timing <= GameRules.GetGameTime() or not tableinfo.pos or herotriger or ingorenamehero then
						MiniMapDraw.TableParticle[i] = nil
						return
					end
				end
				if not tableinfo.drawing and tableinfo.pos and not tableinfo.ignore then
					if tableinfo.entity and NPCs.Contains(tableinfo.entity) and Heroes.Contains(tableinfo.entity) then
						if not MiniMapDraw.CheckSameTeam(tableinfo.entity) then
							if typedraw == 0 or typedraw == 1 then
								MiniMap.AddIcon(nil, Hero.GetIcon(tableinfo.entity), tableinfo.pos, 255, 255, 255, 255, 3, Menu.GetValue(MiniMapDraw.IconSize))
							end
							if typedraw == 0 or typedraw == 2 then
								Renderer.AddWorldIcon(nil, Hero.GetIcon(tableinfo.entity), tableinfo.pos, 255, 255, 255, 255, 3, 32)
							end
						end
						tableinfo.drawing = true
					else
						if not Menu.IsEnabled(MiniMapDraw.OnlyHero) then
							if typedraw == 0 or typedraw == 1 then
								MiniMap.AddIconByName(nil, "minimap_plaincircle", tableinfo.pos, 255, 255, 255, 255, 3, Menu.GetValue(MiniMapDraw.IconSize))
							end
						end
						tableinfo.drawing = true
					end
				end
			end
		end
	end
end

function MiniMapDraw.ChangeTeam()
	local w_screen,h_screen = Renderer.GetScreenSize()
	Renderer.SetDrawColor(255, 255, 255, 255)
	local sizeboard = 50
	local sizex = sizeboard
	local sizey = sizeboard*0.5
	Renderer.SetDrawColor(255, 255, 255, 255)
	Renderer.DrawTextCentered(MiniMapDraw.Font, math.floor(w_screen*0.5), math.floor(h_screen*0.1), "Select u team", 1)
	local posy = math.floor(h_screen*0.1+10)

	local posx = math.floor(w_screen*0.5-sizex)
	Renderer.SetDrawColor(0, 255, 0, 255)
	Renderer.DrawFilledRect(posx, posy, math.floor(sizex), math.floor(sizey))
	if Input.IsCursorInRect(posx, posy, math.floor(sizex), math.floor(sizey)) and Input.IsKeyDownOnce(Enum.ButtonCode.MOUSE_LEFT) then
		return 2
	end
	Renderer.SetDrawColor(255, 255, 255, 255)
	Renderer.DrawTextCentered(MiniMapDraw.Font, math.floor(posx+sizex*0.5), math.floor(posy+sizey*0.5), "Radiant", 1)


	local posx = math.floor(w_screen*0.5)
	Renderer.SetDrawColor(255, 0, 0, 255)
	Renderer.DrawFilledRect(posx, posy, math.floor(sizex), math.floor(sizey))
	if Input.IsCursorInRect(posx, posy, math.floor(sizex), math.floor(sizey)) and Input.IsKeyDownOnce(Enum.ButtonCode.MOUSE_LEFT) then
		return 3
	end
	Renderer.SetDrawColor(255, 255, 255, 255)
	Renderer.DrawTextCentered(MiniMapDraw.Font, math.floor(posx+sizex*0.5), math.floor(posy+sizey*0.5), "Dire", 1)
end

function MiniMapDraw.CheckSameTeam(data)
	if not data then return end
	local teamNum = data
	if NPCs.Contains(data) then
		teamNum = Entity.GetTeamNum(data)
	end
	if not MiniMapDraw.TeamNumLocal then return end
	if teamNum == MiniMapDraw.TeamNumLocal then return true end
	return false
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
		if (realz+10 >= checkz and realz-2 <= checkz) and (checkz < 1000 and checkz > -300) then
			return true
		end
	end
	return false
end

function MiniMapDraw.init()
	MiniMapDraw.TeamNumLocal = nil
	MiniMapDraw.TableParticle = {}
	MiniMapDraw.TableIngoreParticleName = 
	{
		"dire_creep_spawn",
		"radiant_creep_spawn",
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