-- AdminService: chat commands that let an admin trigger events by hand
-- while testing, instead of waiting for the automatic schedule. Only the
-- game owner (or anyone, while the game runs inside Roblox Studio) may
-- use them — everyone else gets a short "not an admin" note and nothing
-- happens. Admin-triggered events are spectacular on purpose: the sky
-- changes colour for the whole event and every player sees an
-- "ADMIN EVENT" banner, so an admin event is easy to tell apart from
-- the ordinary scheduled ones (which do not change the sky and do not
-- show the banner). The banner is built server-side, straight into each
-- player's screen, so no client script needs to know about admin events.

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")

local BrainrotData = require(game:GetService("ReplicatedStorage").Shared.BrainrotData)

local AdminService = {}

local services = nil

-- How long each admin sky lasts, in seconds. The golden sky stays for
-- half a minute (the golden character rides the belt for about a minute,
-- so the sky is back to normal before it reaches the end). The storm sky
-- lasts exactly as long as the wave it belongs to: warning plus sweep.
local GOLDEN_SKY_SECONDS = 30

-- The sky as the game normally has it. Captured once when the server
-- starts, so every admin sky can be undone cleanly afterwards.
local normalSky = {}

-- A counter that grows with every sky change. A delayed revert only
-- restores the normal sky if no newer sky change has happened since —
-- so two quick admin commands cannot make an old revert undo a new sky.
local skyToken = 0

local function saveNormalSky()
	normalSky.Ambient = Lighting.Ambient
	normalSky.OutdoorAmbient = Lighting.OutdoorAmbient
	normalSky.FogColor = Lighting.FogColor
	normalSky.FogStart = Lighting.FogStart
	normalSky.FogEnd = Lighting.FogEnd
	normalSky.ClockTime = Lighting.ClockTime
	normalSky.Brightness = Lighting.Brightness
end

local function restoreNormalSky()
	Lighting.Ambient = normalSky.Ambient
	Lighting.OutdoorAmbient = normalSky.OutdoorAmbient
	Lighting.FogColor = normalSky.FogColor
	Lighting.FogStart = normalSky.FogStart
	Lighting.FogEnd = normalSky.FogEnd
	Lighting.ClockTime = normalSky.ClockTime
	Lighting.Brightness = normalSky.Brightness
end

-- Apply a sky preset now and schedule its revert. Returns the token for
-- this change so the revert can check it is still the newest one.
local function applySky(preset, revertAfterSeconds)
	skyToken += 1
	local token = skyToken
	Lighting.Ambient = preset.Ambient
	Lighting.OutdoorAmbient = preset.OutdoorAmbient
	Lighting.FogColor = preset.FogColor
	Lighting.FogStart = preset.FogStart
	Lighting.FogEnd = preset.FogEnd
	Lighting.ClockTime = preset.ClockTime
	Lighting.Brightness = preset.Brightness
	task.delay(revertAfterSeconds, function()
		if token == skyToken then
			restoreNormalSky()
		end
	end)
	return token
end

-- Golden hour: warm gold light, a honey-coloured haze, low sun.
local GOLDEN_SKY = {
	Ambient = Color3.fromRGB(255, 200, 120),
	OutdoorAmbient = Color3.fromRGB(255, 190, 110),
	FogColor = Color3.fromRGB(255, 205, 140),
	FogStart = 100,
	FogEnd = 600,
	ClockTime = 17.5,
	Brightness = 1.2,
}

-- Storm: dark and close, the fog thick and slate-blue.
local STORM_SKY = {
	Ambient = Color3.fromRGB(35, 40, 55),
	OutdoorAmbient = Color3.fromRGB(30, 35, 50),
	FogColor = Color3.fromRGB(50, 55, 70),
	FogStart = 50,
	FogEnd = 300,
	ClockTime = 19,
	Brightness = 0.6,
}

-- A banner shown to one player: a temporary label at the top of the
-- screen, built server-side and removed after a few seconds.
local function showBanner(player, text, color)
	local playerGui = player:FindFirstChild("PlayerGui")
	if playerGui == nil then
		return
	end
	local screen = Instance.new("ScreenGui")
	screen.Name = "AdminBanner"
	screen.ResetOnSpawn = false
	screen.Parent = playerGui
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.6, 0, 0, 54)
	label.Position = UDim2.new(0.2, 0, 0, 64)
	label.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
	label.BackgroundTransparency = 0.2
	label.Text = text
	label.TextColor3 = color or Color3.fromRGB(255, 220, 90)
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.Parent = screen
	task.delay(5, function()
		screen:Destroy()
	end)
end

local function notifyPlayer(player, text)
	showBanner(player, text, Color3.fromRGB(255, 255, 255))
end

local function notifyAll(text)
	for _, player in ipairs(Players:GetPlayers()) do
		showBanner(player, text, Color3.fromRGB(255, 220, 90))
	end
end

-- Admins are the game owner, plus everybody while the game runs inside
-- Roblox Studio (so testing never needs a permission step). For a
-- user-owned game the creator id is a user id; for a group-owned game
-- it is a group id, so group members count as admins there.
local function isAdmin(player)
	if RunService:IsStudio() then
		return true
	end
	if game.CreatorType == Enum.CreatorType.User then
		return player.UserId == game.CreatorId
	elseif game.CreatorType == Enum.CreatorType.Group then
		local ok, member = pcall(function()
			return player:IsInGroup(game.CreatorId)
		end)
		return ok and member or false
	end
	return false
end

function AdminService.init(deps)
	services = deps

	saveNormalSky()

	local function handleGolden(admin)
		applySky(GOLDEN_SKY, GOLDEN_SKY_SECONDS)
		notifyAll("ADMIN EVENT — Golden Brainrot!")
		services.Conveyor.spawnGolden()
		notifyPlayer(admin, "Golden Brainrot spawned — the sky turns gold for 30 seconds.")
	end

	local function handleTsunami(admin)
		local started = services.Wave.triggerWave()
		if not started then
			notifyPlayer(admin, "A wave is already running — wait for it to finish.")
			return
		end
		local waveSeconds = BrainrotData.Wave.warnTime + BrainrotData.Wave.sweepTime
		applySky(STORM_SKY, waveSeconds)
		notifyAll("ADMIN EVENT — Tsunami!")
	end

	local function handleHelp(admin)
		notifyPlayer(admin, "Admin commands: /golden (spawn Golden Brainrot), /tsunami (trigger tsunami), /help (this list).")
	end

	local function onChatted(player, message)
		local text = string.lower(string.gsub(message, "^%s+", ""))
		local command = string.match(text, "^/(%a+)")
		if command == nil then
			return
		end
		if command ~= "golden" and command ~= "tsunami" and command ~= "help" then
			return
		end
		if not isAdmin(player) then
			notifyPlayer(player, "You are not an admin.")
			return
		end
		if command == "golden" then
			handleGolden(player)
		elseif command == "tsunami" then
			handleTsunami(player)
		elseif command == "help" then
			handleHelp(player)
		end
	end

	local function watchPlayer(player)
		player.Chatted:Connect(function(message)
			onChatted(player, message)
		end)
	end

	Players.PlayerAdded:Connect(watchPlayer)
	for _, player in ipairs(Players:GetPlayers()) do
		watchPlayer(player)
	end
end

return AdminService
