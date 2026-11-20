[![make.fun · roblox-brainrot-01](https://make.fun/badge/roblox-brainrot-01.svg)](https://make.fun/bounty/roblox-brainrot-01?utm_source=github&utm_medium=readme&utm_campaign=roblox-brainrot-01)
[![rank](https://make.fun/badge/roblox-brainrot-01/nagajaja02-pixel/makefun-roblox-brainrot-01-v4/rank.svg)](https://make.fun/bounty/roblox-brainrot-01)
[![reward](https://make.fun/badge/roblox-brainrot-01/nagajaja02-pixel/makefun-roblox-brainrot-01-v4/reward.svg)](https://make.fun/bounty/roblox-brainrot-01)

# Brainrot Blitz

A 3D harbour tycoon game for the **roblox-brainrot-01** bounty on [make.fun](https://make.fun/bounty/roblox-brainrot-01). Buy absurd brainrot characters off a moving conveyor, park them on stands in your safehouse, and watch them earn money every second — while rival players try to steal them, a tsunami sweeps the island, and a shield keeps your base safe.

Play it live: https://www.roblox.com/games/105239944014039

The aerial thumbnail is live and approved on Roblox.

## The game

- **13 brainrot characters** with viral names, from Tung Tung Tung Sahur (Common) to Bombardiro Crocodilo (Mythic), across five rarities.
- **Conveyor**: new brainrots roll out every few seconds and ride the belt from the west dock to the east gate. Click one to buy it.
- **Safehouses**: six bases around the island, each with stands for your brainrots. Start with 4 stands, upgrade up to 8.
- **Steal**: grab a brainrot off someone else's stand and carry it home. A shield blocks raids for 26 seconds, then needs a 48-second cooldown.
- **Tsunami**: a wave sweeps the island on a schedule. Climb onto a base roof or the lookout deck to stay dry.
- **Mutations**: rare Gold (2x income) and Diamond (3x income) spawns.
- **Rebirth**: reset for a permanent +50% income boost, with the price rising each time.
- **Merchant**: a stall by the belt sells three characters at a time, rotating regularly.

## Build

This project uses [Rojo](https://rojo.space/) and Node. To build the place file:

```sh
rojo build -o game.rbxl
```

To run the entrypoint (copies the game into the output directory and writes the dossier):

```sh
node main.ts
```

The entrypoint reads `MAKEFUN_OUTPUT_DIR` when it is set, and falls back to `/output`. It never deletes the output directory: it creates the directory when it is missing, then copies files into it and writes over what is already there.

## How to play

- You start with **$150** and **4 stands**.
- Buy brainrots from the conveyor or the merchant, and place them on your stands. Each one earns money every second.
- Upgrade your stands (up to **8**) when you can afford it; the price climbs with the square of the stands you already own.
- Sell a brainrot for **half its buy price** from the character menu.
- Steal from other players by clicking their brainrots and carrying them home — but watch out: if the owner catches you, the brainrot goes straight back.
- Raise your shield (F key or the SHIELD button) to block raids for 26 seconds. After it falls, it needs 48 seconds before it can rise again.
- When the tsunami warning sounds, get to high ground: a base roof or the lookout deck.
- Rebirth from the menu for a permanent +50% income boost.
