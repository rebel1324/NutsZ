SCHEMA.name = "좀비파이드 월드" -- Change this name if you're going to create new schema.
SCHEMA.author = "Black Tea / RealKallos"
SCHEMA.desc = "희망과 질서가 사라진 땅에서"

-- Schema Help Menu. You can add more stuffs in cl_hooks.lua.
SCHEMA.helps = {
	["라크알피의 역사에 대해"] = 
	[[라크알피의 탄생은 Lac 와 RealKallos 의 협력으로 이루어졌습니다.
	<br>라크알피 시즌1 초기, Black Tea za rebel1324 이 개발팀에 합류하였습니다.
	<br>라크알피 시즌2 이후 Lac가 서버 운영과 개발을 그만두고 모든 개발과 운영은 RealKallos 이 이어 진행하였습니다.
	<br>이후 Black Tea za rebel1324 또한 군입대로 인해 개발을 그만두었으나 시즌5, 다시금 라크알피에 합류하였습니다.
	<br>RealKallos 의 시즌3,4 가 지나고 새로운 시즌인 시즌5가 현재 진행중입니다.]],
	["이모드는 무엇인가요?"] = 
	[[현재 플레이중 이신 모드는 뉴 라크알피입니다.
	<br>NutScript 의 ModernRP base 를 기본으로 원작자인 Black Tea za rebel1324 의 주도하에 제작되었습니다.
	<br>기존 넛스크립트의 SeriousRP가 아닌 DarkRP와 같은 가벼운 RP모드를 지향하며 제작되었습니다.]],
	["제작자에 대해"] = 
	[[이 Schema의 메인 제작자는 Black Tea za rebel1324(https://github.com/rebel1324) 입니다.
	<br>2015. Feb. 9, 군에 입대하여 제대한후 제작한 Schema 입니다.
	<br>이 Schema는 RealKallos 와 Weed 의 도움으로 만들어졌습니다.
	<br>현재 서버는 RealGaming.kr 의 메인 서버로 가동중입니다.]]
}

SCHEMA.itemLists = {
    ["foods"] = {
		items = {
            ["food_chip"] = 1,
            ["food_mre"] = .1,
            ["food_oat"] = .88,
            ["food_chobar"] = .58,
            ["food_grabar"] = .77,
            ["food_pascan"] = .11,
            ["food_soupcan"] = .18,
            ["food_hamcan"] = .11,
            ["food_tunacan"] = .22,
            ["food_coco"] = .5,
            ["food_endrink"] = .2,
            ["food_ion"] = .1,
            ["food_cherry"] = .2,
            ["food_bread"] = .6,
            ["food_soda"] = .2,
            ["food_lwater"] = .4,
            ["food_swater"] = .6,
            ["aidkit"] = .8,
            ["healthkit"] = .4,
            ["healvial"] = .1,
        },
		max = 40,
		interval = 60,
	},
    ["components"] = {
		items = {

		},
		max = 15,
		interval = 600,
	},
    ["ammo"] = {
		items = {
			["ammo_pistol"] = 1,
			["ammo_ar2"] = 0.8,
			["ammo_smg1"] = 1,
			["ammo_buckshot"] = 0.6,
			["ammo_sniperround"] = 0.2,
		},
		max = 16,
		interval = 300,
	},
    ["artifacts"] = {
		items = {},
		max = 3,
		interval = 600,
	},
    ["wears"] = {
		items = {
			["banda"] = 1,
			["bandol"] = 1,
			["beerhat"] = 1,
			["biker"] = 1,
			["buttbag"] = 1,
			["chiefhat"] = 1,
			["civbag"] = 1,
			["civbag2"] = 1,
			["gunjang"] = 1,
			["hat"] = 1,
			["hat2"] = 1,
			["hat3"] = 1,
			["hat4"] = 1,
			["hat5"] = 1,
			["hphone"] = 1,
			["mask"] = 1,
			["mask2"] = 1,
			["mask3"] = 1,
			["mask4"] = 1,
			["scarf"] = 1,
			["smallbag"] = 1,
		},
		max = 4,
		interval = 600,
	},
    ["rarewears"] = {
		items = {
			["balivest"] = 0.3,
			["largebag"] = 1,
			["civbag3"] = 1,
			["hugebag"] = 1,
			["vest2"] = 0.4,
			["vest3"] = 0.4,
			["vision_a"] = 0.2,
			["vision_b"] = 0.2,
		},
		max = 4,
		interval = 600,
	},
    ["weapons"] = {
		items = {
			["ma85_wf_pt22"] = 1,
			["ma85_wf_pt21"] = 1,
			["ma85_wf_pt41_ww2"] = 0.2,
			["ma85_wf_pt27"] = 0.6,
			["ma85_wf_pt14"] = 0.4,
			["ma85_wf_pt10"] = 1,
			["ma85_wf_smg35"] = 1,
			["ma85_wf_shg37"] = 1,
			["ma85_wf_smg31"] = 1,
		},
		max = 4,
		interval = 600,
	},
    ["rareweapons"] = {
		items = {
			["ma85_wf_shg38"] = 1,
			["ma85_wf_shg13"] = 1,
			["ma85_wf_shg03"] = 1,
			["ma85_wf_shg07"] = 1,
			["ma85_wf_smg25"] = 1,
			["ma85_wf_smg26"] = 1,
			["ma85_wf_smg17"] = 1,
			["ma85_wf_smg33"] = 1,
			["ma85_wf_shg38"] = 1,
			["ma85_wf_smg41"] = 1,
			["ma85_wf_ar04"] = 1,
			["ma85_wf_ar22"] = 1,
			["ma85_wf_ar22_old"] = 1,
			["ma85_wf_ar03"] = 1,
			["ma85_wf_ar25"] = 1,
			["ma85_wf_ar06"] = 1,
			["ma85_wf_ar24"] = 1,
			["ma85_wf_ar12"] = 1,
			["ma85_wf_ar26"] = 1,
			["ma85_wf_ar01"] = 1,
			["ma85_wf_sr07"] = 1,
			["ma85_wf_sr35"] = 1,
			["ma85_wf_sr34"] = 1,
			["ma85_wf_sr12"] = 1,
		},
		max = 1,
		interval = 600,
	},
    ["uniqueweapons"] = {
		items = {
			["ma85_wf_shg05"] = 1,
			["ma85_wf_ar11"] = 1,
			["ma85_wf_mg07"] = 1,
			["ma85_wf_ar41"] = 1,
			["ma85_wf_sr04"] = 1,
			["ma85_wf_sr09"] = 1,
			["ma85_wf_sr37"] = 1,
		},
		max = 1,
		interval = 600,
	},
}
SCHEMA.itemSpawns = SCHEMA.itemSpawns or {}

SCHEMA.npcLists = {
    ["normal"] = {
		items = {
            ["nz_berserker"] = 1,
            ["nz_elite_zombine"] = 1,
            ["nz_metro_zombie"] = 1,
            ["nz_boss_zombine"] = 1,
            ["nz_risen"] = 1,
        },
		max = 40,
		interval = 300,
	},
    ["rare"] = {
		items = {},
		max = 15,
		interval = 600,
	},
    ["boss"] = {
		items = {},
        nospawn = true,
		max = 15,
		interval = 600,
	},
}
SCHEMA.npcSpawns = SCHEMA.npcSpawns or {}

-- RANK레벨 관련 선언
-- RANK가 먼저 이걸 설정하려면 rankLevel를 잘 해야한다
-- 이 예제와 같이 -3이라면 rankLevel은 3이 되야하는것.
SCHEMA.ranks = {
	[-3] = "정예 약탈자",
	[-2] = "숙련 약탈자",
	[-1] = "약탈자",
	[0] = "생존자",
	[1] = "자경단",
	[2] = "숙련 자경단",
	[3] = "정예 자경단",
}
SCHEMA.rankLevels = 3

if (SERVER) then
	resource.AddWorkshop(207739713) -- Nutscript content

	resource.AddWorkshop(152430372)
	resource.AddWorkshop(195744668)
	resource.AddWorkshop(572310302)
	resource.AddWorkshop(551144079)
	resource.AddWorkshop(152429869)
	resource.AddWorkshop(848953556)
	resource.AddWorkshop(406603968)
	resource.AddWorkshop(165772389)
	resource.AddWorkshop(384303540)
	resource.AddWorkshop(527885257)
	resource.AddWorkshop(148638160)
	resource.AddWorkshop(524675815)
	resource.AddWorkshop(358608166)
	resource.AddWorkshop(707343339)
	resource.AddWorkshop(675824914)
	resource.AddWorkshop(104691717)
	resource.AddWorkshop(320536858)
	resource.AddWorkshop(380225333)
	resource.AddWorkshop(129873473)
	resource.AddWorkshop(875284959)
	resource.AddWorkshop(349050451)
	resource.AddWorkshop(677125227)
	resource.AddWorkshop(848953359)
	resource.AddWorkshop(873302121)
	resource.AddWorkshop(757604550)
	

	-- Adding Gasmask Resources
	resource.AddFile("sound/gasmaskon.wav")
	resource.AddFile("sound/gasmaskoff.wav")
	resource.AddFile("sound/gmsk_in.wav")
	resource.AddFile("sound/gmsk_out.wav")
	resource.AddFile("materials/gasmask_fnl.vmt")
	resource.AddFile("materials/gasmask3.vtf")
	resource.AddFile("materials/gasmask3_n.vtf")
	resource.AddFile("materials/shtr_01.vmt")
	resource.AddFile("materials/shtr.vtf")
	resource.AddFile("materials/shtr_n.vtf")

	-- Adding Schema Resources
	resource.AddFile("materials/modernrp/dankweed.png")
	resource.AddFile("materials/modernrp/hitmarker.png")
	resource.AddFile("materials/effects/fas_muzzle1.png")
	resource.AddFile("materials/effects/fas_muzzle2.png")
	resource.AddFile("materials/effects/fas_muzzle3.png")
	resource.AddFile("materials/effects/fas_muzzle4.png")
	resource.AddFile("materials/effects/fas_muzzle5.png")
	resource.AddFile("materials/effects/fas_muzzle6.png")
	resource.AddFile("materials/effects/fas_muzzle7.png")
	resource.AddFile("materials/effects/fas_muzzle8.png")
	resource.AddFile("materials/effects/money.png")
	resource.AddFile("sound/ui/bad.wav")
	resource.AddFile("sound/ui/bip.wav")
	resource.AddFile("sound/ui/boop.wav")
	resource.AddFile("sound/ui/charged.wav")
	resource.AddFile("sound/ui/confirm.wav")
	resource.AddFile("sound/ui/deny.wav")
	resource.AddFile("sound/ui/extended.wav")
	resource.AddFile("sound/ui/good.wav")
	resource.AddFile("sound/ui/notify.wav")
	resource.AddFile("sound/ui/okay.wav")
	resource.AddFile("sound/ui/welcome.wav")
	resource.AddFile("sound/policesiren.wav")
	
	resource.AddFile("resource/fonts/NanumBarunGothic.ttf")
	resource.AddFile("resource/fonts/NanumBarunGothicBold.ttf")
	resource.AddFile("resource/fonts/NanumBarunGothicLight.ttf")
	resource.AddFile("resource/fonts/NanumBarunGothicUltraLight.ttf")
	resource.AddFile("resource/fonts/malgun.ttf")
	resource.AddFile("resource/fonts/malgunbd.ttf")
	--Adding Sound Resources
	resource.AddFile("sound/mainbgm.mp3")
end

nut.util.include("sv_database.lua")
nut.util.include("sh_configs.lua")
nut.util.include("cl_effects.lua")
nut.util.include("sv_hooks.lua")
nut.util.include("cl_hooks.lua")
nut.util.include("sh_hooks.lua")
nut.util.include("sh_commands.lua")
nut.util.include("meta/sh_player.lua")
nut.util.include("meta/sh_entity.lua")
nut.util.include("meta/sh_character.lua")
nut.util.include("sh_dev.lua") -- Developer Functions
nut.util.include("sv_schema.lua")

nut.anim.player = {
	fist = {
		[ACT_MP_RUN] = "sprint_all"
	},
	normal = {
		[ACT_MP_STAND_IDLE] = ACT_HL2MP_IDLE,
		[ACT_MP_CROUCH_IDLE] = ACT_HL2MP_IDLE_CROUCH,
		[ACT_MP_WALK] = ACT_HL2MP_WALK,
		[ACT_MP_RUN] = "sprint_all"
	},
	passive = {
		[ACT_MP_STAND_IDLE] = ACT_HL2MP_IDLE_PASSIVE,
		[ACT_MP_WALK] = ACT_HL2MP_WALK_PASSIVE,
		[ACT_MP_CROUCHWALK] = ACT_HL2MP_WALK_CROUCH_PASSIVE,
		[ACT_MP_RUN] = ACT_HL2MP_RUN_PASSIVE
	}
}