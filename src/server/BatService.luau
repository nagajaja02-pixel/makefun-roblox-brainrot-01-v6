-- BatService: the free baseball bat every player gets for raid defence.
--
-- Every player spawns with a wooden baseball bat in their Backpack. When a
-- rival is raiding your safehouse, equip the bat and click to swing. A swing
-- has a short cooldown and only reaches a short distance in front of you, so
-- you have to get close. A player caught by the swing is shoved hard away
-- from you. If that player is carrying a stolen brainrot, the hit knocks the
-- brainrot out of their hands and the raid fails: the character drops and
-- the steal system is told the carry was interrupted.
--
-- The service talks to the steal system through the server bus, not by
-- requiring it: it fires a CarryInterrupted bus event when a bat hit breaks
-- a carry. It also checks the target's character directly for a carried
-- brainrot model (the weld the steal system puts on it), so the drop works
-- even if the bus tracking and the steal system disagree about the carry
-- state.

local Players = game:GetService("Players")
local StarterPack = game:GetService("StarterPack")

local BatService = {}

local services = nil
local lastSwing = {}

-- One swing a second, eight studs of reach, a hard shove and a pop up.
local SWING_COOLDOWN = 1
local SWING_RANGE = 8
local KNOCKBACK = 55
local POP = 22
local KNOCK_TIME = 0.25

-- Find the brainrot model welded to a player, if they are carrying one.
-- The steal system welds the carried model to the carrier's root part with
-- a weld called CarryWeld, so that weld is the ground truth for a carry.
local function findCarriedModel(player)
	local character = player.Character
	if character == nil then
		return nil
	end
	local root = character:FindFirstChild("HumanoidRootPart")
	if root == nil then
		return nil
	end
	local island = workspace:FindFirstChild("Island")
	if island == nil then
		return nil
	end
	for _, descendant in ipairs(island:GetDescendants()) do
		if descendant:IsA("Weld") and descendant.Name == "CarryWeld" and descendant.Part0 == root then
			local primary = descendant.Parent
			if primary ~= nil then
				return primary.Parent
			end
		end
	end
	return nil
end

-- Shove a player away from the attacker and pop them up into the air.
local function knockback(attackerRoot, targetRoot)
	local dir = targetRoot.Position - attackerRoot.Position
	dir = Vector3.new(dir.X, 0, dir.Z)
	if dir.Magnitude < 0.01 then
		dir = Vector3.new(0, 0, 1)
	end
	dir = dir.Unit
	local velocity = Instance.new("BodyVelocity")
	velocity.Name = "BatKnockback"
	velocity.Velocity = dir * KNOCKBACK + Vector3.new(0, POP, 0)
	velocity.MaxForce = Vector3.new(100000, 100000, 100000)
	velocity.Parent = targetRoot
	task.delay(KNOCK_TIME, function()
		velocity:Destroy()
	end)
end

-- One swing: find the nearest player in front, within range, and hit them.
local function swing(player)
	local now = os.clock()
	if lastSwing[player.UserId] ~= nil and now - lastSwing[player.UserId] < SWING_COOLDOWN then
		return
	end
	lastSwing[player.UserId] = now
	local character = player.Character
	if character == nil then
		return
	end
	local root = character:FindFirstChild("HumanoidRootPart")
	if root == nil then
		return
	end
	local forward = root.CFrame.LookVector
	local best = nil
	local bestDist = SWING_RANGE
	for _, other in ipairs(Players:GetPlayers()) do
		if other ~= player then
			local otherChar = other.Character
			if otherChar ~= nil then
				local otherRoot = otherChar:FindFirstChild("HumanoidRootPart")
				if otherRoot ~= nil then
					local toOther = otherRoot.Position - root.Position
					local dist = toOther.Magnitude
					if dist <= SWING_RANGE and dist > 0.01 then
						local dot = forward:Dot(toOther.Unit)
						if dot >= 0.5 and dist < bestDist then
							best = other
							bestDist = dist
						end
					end
				end
			end
		end
	end
	if best == nil then
		return
	end
	local targetRoot = best.Character:FindFirstChild("HumanoidRootPart")
	if targetRoot == nil then
		return
	end
	-- If the target is carrying a stolen brainrot, the hit breaks the raid.
	local carried = findCarriedModel(best)
	knockback(root, targetRoot)
	if carried ~= nil then
		if services.Bus ~= nil and services.Bus.CarryInterrupted ~= nil then
			services.Bus.CarryInterrupted:Fire(best)
		end
		-- Fallback: if the steal system did not take the character back
		-- (its records disagree with the weld), drop it right here.
		task.delay(0.15, function()
			local still = findCarriedModel(best)
			if still ~= nil and still.PrimaryPart ~= nil then
				local weld = still.PrimaryPart:FindFirstChild("CarryWeld")
				if weld ~= nil then
					weld:Destroy()
				end
				for _, descendant in ipairs(still:GetDescendants()) do
					if descendant:IsA("BasePart") then
						descendant.Anchored = true
						descendant.CanCollide = false
					end
				end
			end
		end)
	end
end

-- The bat itself: a wooden handle, free for everyone.
local function makeBat()
	local tool = Instance.new("Tool")
	tool.Name = "Baseball Bat"
	tool.RequiresHandle = true
	tool.CanBeDropped = false
	local handle = Instance.new("Part")
	handle.Name = "Handle"
	handle.Size = Vector3.new(0.6, 3.2, 0.6)
	handle.Color = Color3.fromRGB(150, 110, 70)
	handle.Material = Enum.Material.Wood
	handle.Parent = tool
	return tool
end

-- Hook a bat tool's swing. Guarded so a tool that is equipped, unequipped
-- and equipped again only ever gets one connection.
local function hookTool(player, tool)
	if not tool:IsA("Tool") or tool.Name ~= "Baseball Bat" then
		return
	end
	if tool:GetAttribute("BatHooked") then
		return
	end
	tool:SetAttribute("BatHooked", true)
	tool.Activated:Connect(function()
		swing(player)
	end)
end

-- Hook every bat a character picks up, now and later.
local function hookCharacter(player, character)
	for _, child in ipairs(character:GetChildren()) do
		hookTool(player, child)
	end
	character.ChildAdded:Connect(function(child)
		hookTool(player, child)
	end)
end

-- Hand a player their bat: one in the backpack now, and one in the
-- StarterPack so it comes back after every respawn.
local function giveBat(player)
	local backpack = player:FindFirstChildOfClass("Backpack")
	if backpack ~= nil and backpack:FindFirstChild("Baseball Bat") == nil then
		makeBat().Parent = backpack
	end
	if StarterPack:FindFirstChild("Baseball Bat") == nil then
		makeBat().Parent = StarterPack
	end
end

-- Give every player a bat on join and on respawn, and hook their swings.
function BatService.init(deps)
	services = deps
	local function onPlayerAdded(player)
		giveBat(player)
		player.CharacterAdded:Connect(function(character)
			hookCharacter(player, character)
		end)
		if player.Character ~= nil then
			hookCharacter(player, player.Character)
		end
	end
	Players.PlayerAdded:Connect(onPlayerAdded)
	Players.PlayerRemoving:Connect(function(player)
		lastSwing[player.UserId] = nil
	end)
	for _, player in ipairs(Players:GetPlayers()) do
		onPlayerAdded(player)
	end
end

return BatService
