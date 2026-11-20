-- Bootstrap: the server entry point. It builds the island, wires every
-- service together through one shared table (each service receives the
-- others through init, so no module requires another service at load
-- time), and keeps a slow heartbeat in the server log.

local World = require(script.Parent.World)
local BrainrotData = require(game:GetService("ReplicatedStorage").Shared.BrainrotData)
local MoneyService = require(script.Parent.MoneyService)
local BaseService = require(script.Parent.BaseService)
local ShieldService = require(script.Parent.ShieldService)
local ConveyorService = require(script.Parent.ConveyorService)
local StealService = require(script.Parent.StealService)
local BatService = require(script.Parent.BatService)
local WaveService = require(script.Parent.WaveService)
local MerchantService = require(script.Parent.MerchantService)
local AdminService = require(script.Parent.AdminService)

-- The island first: everything else stands on it.
local refs = World.build()

-- The server bus: BindableEvents services use to talk to each other
-- without requiring each other at load time.
local busFolder = Instance.new("Folder")
busFolder.Name = "BrainrotBus"
busFolder.Parent = game:GetService("ServerScriptService")
local bus = {}
local carryInterrupted = Instance.new("BindableEvent")
carryInterrupted.Name = "CarryInterrupted"
carryInterrupted.Parent = busFolder
bus.CarryInterrupted = carryInterrupted

-- The service table every service receives in init.
local services = {
	Money = MoneyService,
	Base = BaseService,
	Shield = ShieldService,
	Conveyor = ConveyorService,
	Steal = StealService,
	Bat = BatService,
	Wave = WaveService,
	Merchant = MerchantService,
	Admin = AdminService,
	Bus = bus,
	World = refs,
}

-- Start the services in a fixed order: money and bases first (players
-- need cash and a plot the moment they arrive), then the shield, the
-- belt, the stealing rules, the bat, the waves, the merchant and admin.
MoneyService.init(services)
BaseService.init(services)
ShieldService.init(services)
ConveyorService.init(services)
StealService.init(services)
BatService.init(services)
WaveService.init(services)
MerchantService.init(services)
AdminService.init(services)

print("[Brainrot Blitz] Server ready: " .. #BrainrotData.Bases .. " bases, " .. #BrainrotData.Characters .. " characters, island built.")

-- The heartbeat: a slow status line in the server log, so the run can be
-- told apart from a stalled one.
task.spawn(function()
	while true do
		task.wait(30)
		local players = game:GetService("Players"):GetPlayers()
		print("[Brainrot Blitz] Heartbeat: " .. #players .. " players, " .. #ConveyorService.getItems() .. " on the belt.")
	end
end)
