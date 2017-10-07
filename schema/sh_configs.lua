WEAPON_REQSKILLS = {}

-- 아이템 스킬 필요도 초기화 함수
local function addRequire(itemID, reqAttribs)
	WEAPON_REQSKILLS[itemID] =  reqAttribs
end

nut.currency.symbol = "크레딧"
nut.currency.singular = ""
nut.currency.plural = ""
nut.config.language = "korean"

-- 아이템 스킬 필요도
--[[
	addRequire("ak47", {gunskill = 3})
	addRequire("aug", {gunskill = 5})
	addRequire("deagle", {gunskill = 5})
	addRequire("famas", {gunskill = 3})
	addRequire("fiveseven", {gunskill = 2})
	addRequire("galil", {gunskill = 3})
	addRequire("m4a1", {gunskill = 5})
	addRequire("mac10", {gunskill = 3})
	addRequire("mp5", {gunskill = 4})
	addRequire("p228", {gunskill = 1})
	addRequire("p90", {gunskill = 4})
	addRequire("sg552", {gunskill = 5})
	addRequire("tmp", {gunskill = 3})
	addRequire("ump", {gunskill = 3})
	addRequire("usp", {gunskill = 2})
	addRequire("healthkit", {medical = 7})
	addRequire("healvial", {medical = 3})
]]


-- ALLOWED_ENTS : 피직스건 및 툴건 허용목록
-- 여기에 등록된 엔티티는 피직스건 및 툴건으로 지우거나 할 수 있습니다.
ALLOWED_ENTS = {
    ["prop_physics"] = true,
}

USABLE_FUNCS = {
	"use",
	"throw",
	"View",
	"Equip",
	"EquipUn",
}

SAVE_ENTS = {
	["nut_atm"] = true,
	["nut_outfit"] = true,
	["nut_m_recycler"] = true,
	["nut_fedboard"] = true,
	["nut_roll"] = true,
}


WEAPON_STOCKS = {
	[1] = {
		desc = "현재 소총류를 판매하고 있습니다.",
		stocks = {
			["cw_ak74"] = {amount = 3, price = 5000},
			["cw_ar15"] = {amount = 3, price = 4000},
			["cw_g36c"] = {amount = 3, price = 4000},
			["cw_scarh"] = {amount = 3, price = 6000},
			["cw_g3a3"] = {amount = 3, price = 6000},
			["cw_m14"] = {amount = 3, price = 6000},
		},
	},
	[2] = {
		desc = "현재 중화기류를 판매하고 있습니다.",
		stocks = {
			["cw_m249_official"] = {amount = 2, price = 6000},
			["cw_pkm"] = {amount = 1, price = 7000},
		},
	},
	[3] = {
		desc = "현재 저격 소총류를 판매하고 있습니다.",
		stocks = {
			["cw_l115"] = {amount = 1, price = 9000},
		},
	},
}
-- Adding Schema Specific Configs.
nut.config.setDefault("font", "Malgun Gothic")

nut.config.add("garbageInterval", 20, "쓰레기가 소환되는 시간입니다.", 
	function(oldValue, newValue)
		if (timer.Exists("nutGrabage")) then
			timer.Adjust("nutGrabage", newValue, 0, SCHEMA.CrapPayload)
		end
	end, {
	data = {min = 10, max = 3600},
	category = "schema"
})

nut.config.add("garbageMax", 25, "월드에 쓰레기가 최대 몇개 나올지 제한합니다.", nil, {
	data = {min = 0, max = 100},
	category = "schema"
})

nut.config.add("garbageCount", 7, "쓰레기가 한번에 몇개 나올지 제한합니다.", nil, {
	data = {min = 0, max = 100},
	category = "schema"
})

nut.config.add("voteJob", 25, "직업 투표를 할때 필요한 플레이어 찬성수입니다. (기본 25%)", nil, {
	data = {min = 0, max = 100},
	category = "schema"
})

nut.config.add("voteDemote", 25, "탄핵 투표를 할때 필요한 플레이어 찬성수입니다. (기본 25%)", nil, {
	data = {min = 0, max = 100},
	category = "schema"
})

nut.config.add("vendorInterval", 3600, "암상인의 업데이트 시간을 설정합니다.", 
	function(oldValue, newValue)
		if (timer.Exists("nutVendorSell")) then
			timer.Adjust("nutVendorSell", newValue, 0, SCHEMA.UpdateVendors)
		end
	end, {
	data = {min = 600, max = 7200},
	category = "schema"
})

nut.config.add("dpBank", 10, "죽을때 몇 퍼센트의 돈을 잃는지 설정합니다 (1이 1퍼센트임.).", nil, {
	data = {min = 0, max = 100},
	category = "schema"
})

nut.config.add("startMoney", 0, "Start money for new character.", nil, {
	data = {min = 0, max = 50000},
	category = "schema"
})

nut.config.add("deathMoney", true, "죽을때 돈을 잃습니다.", nil, {
	category = "penalty"
})

nut.config.add("deathWeapon", true, "죽을때 장착한 무기를 잃습니다. 떨어진 무기는 30초뒤 삭제됩니다.", nil, {
	category = "penalty"
})

nut.config.add("afkDemote", 240, "몇초 잠수시 몰수하는지 결정합니다.", nil, {
	data = {min = 0, max = 1000},
	category = "schema"
})


-- DAYZ related connfigs

nut.config.add("maxRep", 1500, "생존자의 최대/최소 평판을 결정합니다.", nil, {
	data = {min = 100, max = 3000},
	category = "dayz",
})

nut.config.add("repKill", 100, "무고한 자를 죽일시에 잃는 평판입니다.", nil, {
	data = {min = 1, max = 1500},
	category = "dayz",
})

nut.config.add("repSavior", 60, "약탈자를 죽일시에 얻는 평판입니다.", nil, {
	data = {min = 1, max = 1500},
	category = "dayz",
})

nut.config.add("repQuest", 150, "퀘스트를 완료시 얻는 평판입니다.", nil, {
	data = {min = 1, max = 1500},
	category = "dayz",
})

nut.config.add("safePenalty", 200, "세이프존 페널티 시간을 설정합니다.", nil, {
	data = {min = 1, max = 1500},
	category = "dayz",
})

-- 평판이 최저치에 도달했을때 세이프존에 못들어가는 페널티를 설정한다.
nut.config.add("safePenaltyMul", 2, "세이프존 페널티 배율을 설정합니다.", nil, {
	data = {min = 1, max = 3},
	category = "dayz",
})

-- 단체 설정시 단체의 최대 그룹원을 설정한다.
-- 여기서 MOTD를 통한 룰 제정으로 무슨 A그룹 1 A그룹 2 이런 식의 확장을 절대로 금지한다.
-- 적발시 그룹을 삭제하고 그룹의 모든 자산을 동결 및 처분한다.
nut.config.add("orgMax", 20, "단체의 최대 그룹원을 설정합니다.", nil, {
	data = {min = 1, max = 1500},
	category = "dayz",
})

nut.tips = {
	--'대부분의 아이템은 Ctrl을 누르고 클릭하면 바로 사용할 수 있습니다.',
	'월급은 바로 은행으로 들어오기 때문에 현금화가 필요합니다.',
	'인벤토리는 F3으로도 바로 열 수 있습니다.',
	'스탯은 특정행동을 반복하는 것으로도 올릴 수 있습니다. ',
	'가끔은 주변사람들에게 베풀어주는 것 만으로도 긍정적인 효과를 얻을 수 있습니다. ',
	'펀치 인형은 "주먹으로 때릴 경우에만" 숙련 경험치를 줍니다.',
	'책을 읽으면 한번에 많은 양의 숙련 경험치를 얻지만, 가격이 매우 높습니다.',
	'C메뉴를 통해서 이 팁을 끌 수 있습니다. 옵션은 화면의 오른쪽 위 구석에 위치하고 있습니다.',
	'C메뉴를 통해서 이 팁을 끌 수 있습니다. 옵션은 화면의 오른쪽 위 구석에 위치하고 있습니다.',
	'C메뉴를 통해서 이 팁을 끌 수 있습니다. 옵션은 화면의 오른쪽 위 구석에 위치하고 있습니다.',
	'사격 인형은 "총으로 사격할 경우에만" 숙련 경험치를 줍니다.',
	'몇몇 상인은 특정 직업에게만 물건을 판매합니다.',
	'쓰레기는 거지만 보고 주울 수 있습니다.',
	'마피아와 갱스터 그리고 경찰끼리만 /팀 을 사용해서 채팅을 주고받을 수 있습니다.',
	'버그와 불편 신고는 이미지나 비디오를 첨부하면 매우 빠르게 해결됩니다.',
	'버그와 불편 신고는 이미지나 비디오를 첨부하면 매우 빠르게 해결됩니다.',
	'버그와 불편 신고는 이미지나 비디오를 첨부하면 매우 빠르게 해결됩니다.',
	'돈 복사기를 숨겨놓아서 돈을 벌 수 있습니다.',
	'경찰들은 돈 복사기를 처리함으로써 돈을 벌 수 있습니다.',
	'IC와 OOC를 구분해 주세요!',
	'IC와 OOC를 구분해 주세요!',
	'신고하기전에 MOTD와 IC/OOC 여부를 체크해주세요.',
	'신고하기전에 MOTD와 IC/OOC 여부를 체크해주세요.',
	'신고하기전에 MOTD와 IC/OOC 여부를 체크해주세요.',
	'!신고 명령어로 어드민에게 신고를 할 수 있습니다.',
	'!신고 명령어로 어드민에게 신고를 할 수 있습니다.',
	'!신고 명령어로 어드민에게 신고를 할 수 있습니다.',
	'!신고 명령어로 어드민에게 신고를 할 수 있습니다.',
}

SCHEMA.safeZones = {
	["rp_stalker_v2"] = {
		{Vector(1308.441650, -10979.700195, -771.940491),
		Vector(-417.521362, -12385.154297, 184.530441)},
		{Vector(-2417.828857, 4796.075195, -577.490723),
		Vector(-3310.129639, 4318.547852, 136.707932)},
	}
}
