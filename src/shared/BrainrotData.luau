-- BrainrotData: the shared catalogue for Brainrot Blitz.
-- Both the server and the client require this module, so it holds no state:
-- only the character list, the mutation rules, the economy numbers, and a
-- few pure helpers every other system can call without side effects.

local BrainrotData = {}

-- The sixteen characters, cheapest first. Five rarities, prices and income
-- climbing steeply so the late game still feels like a climb. Each entry
-- carries the colours its 3D model is built from and a one-line caption the
-- model builder shows on its name label.
BrainrotData.Characters = {
	{ id = "sahur", name = "Tung Tung Tung Sahur", tier = "Common", price = 50, income = 2,
		body = Color3.fromRGB(139, 94, 52), accent = Color3.fromRGB(92, 58, 28),
		caption = "A log that knocks three times.", trait = "log" },
	{ id = "boneca", name = "Boneca Ambalabu", tier = "Common", price = 80, income = 3,
		body = Color3.fromRGB(244, 164, 196), accent = Color3.fromRGB(190, 90, 140),
		caption = "A little doll with a big stare.", trait = "doll" },
	{ id = "trippi", name = "Trippi Troppi", tier = "Common", price = 120, income = 5,
		body = Color3.fromRGB(64, 180, 190), accent = Color3.fromRGB(30, 120, 130),
		caption = "Three fins, one mission.", trait = "fish" },
	{ id = "lirili", name = "Lirili Larila", tier = "Rare", price = 260, income = 11,
		body = Color3.fromRGB(120, 190, 90), accent = Color3.fromRGB(70, 130, 50),
		caption = "A cactus that hums in the sun.", trait = "cactus" },
	{ id = "frigo", name = "Frigo Camelo", tier = "Rare", price = 420, income = 17,
		body = Color3.fromRGB(170, 210, 235), accent = Color3.fromRGB(90, 140, 180),
		caption = "Cold on the outside, cool inside.", trait = "fridge" },
	{ id = "chimpanzini", name = "Chimpanzini Bananini", tier = "Rare", price = 650, income = 26,
		body = Color3.fromRGB(250, 215, 90), accent = Color3.fromRGB(200, 150, 40),
		caption = "Half chimp, half banana, all chaos.", trait = "banana" },
	{ id = "patapim", name = "Brr Brr Patapim", tier = "Epic", price = 950, income = 38,
		body = Color3.fromRGB(150, 200, 250), accent = Color3.fromRGB(80, 130, 200),
		caption = "Shivers when it walks.", trait = "ice" },
	{ id = "ballerina", name = "Ballerina Cappuccina", tier = "Epic", price = 1500, income = 60,
		body = Color3.fromRGB(210, 150, 100), accent = Color3.fromRGB(150, 90, 60),
		caption = "Dances on espresso.", trait = "dancer" },
	{ id = "assassino", name = "Cappuccino Assassino", tier = "Epic", price = 2200, income = 88,
		body = Color3.fromRGB(80, 55, 40), accent = Color3.fromRGB(40, 25, 18),
		caption = "Silent, foamy, deadly.", trait = "assassin" },
	{ id = "orangutini", name = "Orangutini Ananasini", tier = "Legendary", price = 3400, income = 135,
		body = Color3.fromRGB(245, 170, 60), accent = Color3.fromRGB(200, 120, 30),
		caption = "An orangutan in a pineapple suit.", trait = "pineapple" },
	{ id = "vaca", name = "La Vaca Saturno Saturnita", tier = "Legendary", price = 5200, income = 210,
		body = Color3.fromRGB(170, 130, 220), accent = Color3.fromRGB(110, 70, 160),
		caption = "A cow with rings like Saturn.", trait = "cow" },
	{ id = "tralalero", name = "Tralalero Tralala", tier = "Mythic", price = 8500, income = 340,
		body = Color3.fromRGB(70, 130, 220), accent = Color3.fromRGB(30, 70, 150),
		caption = "Three legs, one shark, endless song.", trait = "shark" },
	{ id = "bombardiro", name = "Bombardiro Crocodilo", tier = "Mythic", price = 12500, income = 500,
		body = Color3.fromRGB(90, 160, 80), accent = Color3.fromRGB(50, 100, 45),
		caption = "A crocodile that drops in from the sky.", trait = "croc" },
	{ id = "giraffa", name = "Giraffa Celeste", tier = "Mythic", price = 18000, income = 720,
		body = Color3.fromRGB(140, 200, 240), accent = Color3.fromRGB(255, 215, 0),
		caption = "A giraffe that grazes the clouds.", trait = "giraffe" },
	{ id = "bananita", name = "Bananita Dolphinita", tier = "Mythic", price = 25000, income = 1000,
		body = Color3.fromRGB(255, 235, 130), accent = Color3.fromRGB(244, 143, 177),
		caption = "A dolphin that peels out.", trait = "dolphin" },
	{ id = "graipuss", name = "Graipuss Medussi", tier = "Mythic", price = 35000, income = 1400,
		body = Color3.fromRGB(180, 140, 220), accent = Color3.fromRGB(120, 60, 180),
		caption = "A jellyfish made of grapes.", trait = "jellyfish" },
}

-- Rarity order, cheapest tier first. Used by the index menu and by the
-- conveyor when it weights which character to spawn.
BrainrotData.Tiers = { "Common", "Rare", "Epic", "Legendary", "Mythic" }

-- Mutation: a small slice of spawns comes out Diamond (three times the
-- income) and a slightly bigger slice comes out Gold (twice the income).
-- A very rare slice comes out Rainbow (five times the income). The Golden
-- event character is a separate thing: it only ever rides in on the golden
-- event, also at five times the income. The rest are normal.
BrainrotData.Mutation = {
	goldChance = 0.07,
	diamondChance = 0.02,
	rainbowChance = 0.005,
	goldMult = 2,
	diamondMult = 3,
	rainbowMult = 5,
	goldenMult = 5,
}

-- The economy every system shares.
BrainrotData.Economy = {
	startCash = 150,
	startStands = 4,
	maxStands = 10,
	upgradeBase = 100,
	sellFraction = 0.5,
	rebirthBase = 12000,
	rebirthBoost = 0.5,
	milestoneEvery = 5,
	milestoneBoost = 0.25,
	rebirthStore = "BlitzRebirthsV1",
}

-- The conveyor belt: where it runs, how fast, how often a new character
-- rolls out.
BrainrotData.Conveyor = {
	spawnInterval = 3.5,
	speed = 4.2,
	startX = -131,
	endX = 131,
}

-- The golden event: every four minutes a golden brainrot rides the belt,
-- worth five times its normal income.
BrainrotData.Golden = {
	interval = 240,
}

-- The tsunami rhythm: first wave, warning window, sweep length, gap.
BrainrotData.Wave = {
	firstAt = 52,
	warnTime = 14,
	sweepTime = 8,
	gap = 54,
}

-- The shield: how long it holds, then how long before it can rise again.
BrainrotData.Shield = {
	duration = 26,
	cooldown = 48,
}

-- The six safehouse plots: three on each side of the conveyor, at the
-- island's left, centre and right.
BrainrotData.Bases = {
	{ x = -82, z = -51 },
	{ x = 0, z = -51 },
	{ x = 82, z = -51 },
	{ x = -82, z = 51 },
	{ x = 0, z = 51 },
	{ x = 82, z = 51 },
}

-- Look a character up by its id. Returns nil for an unknown id.
function BrainrotData.byId(id)
	for _, char in ipairs(BrainrotData.Characters) do
		if char.id == id then
			return char
		end
	end
	return nil
end

-- Roll a mutation for a fresh spawn. Rainbow is the rarest, then Diamond,
-- then Gold.
function BrainrotData.rollMutation()
	local roll = math.random()
	local rainbow = BrainrotData.Mutation.rainbowChance
	local diamond = BrainrotData.Mutation.diamondChance
	local gold = BrainrotData.Mutation.goldChance
	if roll < rainbow then
		return "Rainbow"
	elseif roll < rainbow + diamond then
		return "Diamond"
	elseif roll < rainbow + diamond + gold then
		return "Gold"
	end
	return "Normal"
end

-- The income a character actually pays out, mutation included.
function BrainrotData.mutationIncome(char, mutation)
	if mutation == "Diamond" then
		return char.income * BrainrotData.Mutation.diamondMult
	elseif mutation == "Gold" then
		return char.income * BrainrotData.Mutation.goldMult
	elseif mutation == "Rainbow" then
		return char.income * BrainrotData.Mutation.rainbowMult
	elseif mutation == "Golden" then
		return char.income * BrainrotData.Mutation.goldenMult
	end
	return char.income
end

-- What the next stand costs. The price climbs with the square of the
-- stands the player already owns, so late stands are a real decision.
function BrainrotData.upgradeCost(stands)
	return BrainrotData.Economy.upgradeBase * stands * stands
end

-- What the next rebirth costs: a flat base times one more than the
-- rebirths the player already has.
function BrainrotData.rebirthCost(rebirths)
	return BrainrotData.Economy.rebirthBase * (rebirths + 1)
end

-- The income boost from rebirths: half again per rebirth, plus a quarter
-- more for every five rebirths as a milestone bonus.
function BrainrotData.rebirthBoost(rebirths)
	local milestones = math.floor(rebirths / BrainrotData.Economy.milestoneEvery)
	return 1 + BrainrotData.Economy.rebirthBoost * rebirths + BrainrotData.Economy.milestoneBoost * milestones
end

-- What a character sells for: half what it cost to buy.
function BrainrotData.sellPrice(price)
	return math.floor(price * BrainrotData.Economy.sellFraction)
end

return BrainrotData
