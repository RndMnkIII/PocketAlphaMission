[![Alpha Mission Marqueé](alpha-mission_marquee.jpg)](#)

---

[![Twitter Follow](https://img.shields.io/twitter/follow/rndmnkiii?style=social)](https://twitter.com/rndmnkiii)

# SNK ASO/Alpha Mission Compatible Gateware IP Core

Follow any core updates and news on my Twitter acount [@RndMnkIII](https://twitter.com/RndMnkIII). this project is a hobby but it requires investing in arcade game boards and specific tools, so any donation is welcome: [https://ko-fi.com/rndmnkiii](https://ko-fi.com/rndmnkiii).

## ℹ️ About

This core originated from the core project for __SNK's__ __Alpha__ __Mission__ arcade game. Encompass the __"SNK Triple Z80"__ platform, this groups together several games that were developed by SNK around the mid-1980s using a similar hardware architecture. For a complete reference of the list of games consult
[https://github.com/mamedev/mame/blob/master/src/mame/snk/snk.cpp](https://github.com/mamedev/mame/blob/master/src/mame/snk/snk.cpp).

## 🔗 Compatible Games

> __ROMs NOT INCLUDED:__ By using this core you agree to provide your own roms. We do not condone or support the unauthorized use or distribution of copyrighted or other intellectual property-protected materials

| Name                         | Status |
| :--------------------------- | :----: |
| ASO - Armored Scrum Object   |  ✅    |
| Alpha Mission, Arian Mission |  ✅    |
| Arian Mission                |  ✅    |

## 🎮 Controls
| Name           | Button          |
| :------------- | :-------------- |
| Missile        | 🕹️ PAD Btn B      |
| Fire           | 🕹️ PAD Btn Y      |
| Armor          | 🕹️ PAD Btn A      |
| Start Player 1 | 🕹️ PAD Btn Start  |
| Start Player 2 | 🕹️ PAD trig L     |
| Coin           | 🕹️ PAD Btn Select |

## 🧩 Game strategy
{| {{prettytable}}
| width=50% | [[File:ASO Armor Octo.png|left]] The '''Octo Armor''' provides the Syd with 8-way simultaneous laser fire. It's energy consumption is strictly by time. Whether you fire the lasers or not, the Octo Armor will drain energy at a slow pace.
| width=50% | [[File:ASO Armor Shield.png|right]] The '''Shield Armor''' is the most defensive armor available to the Syd. It protects the Syd with a circular barrier that will absorb damage at the cost of it's energy (two bars of energy per hit, half the rate of all other armors.) You can recharge the Shield by collecting more energy tiles.
|-
|[[File:ASO Armor Cannon.png|left]] The '''Cannon Armor''' gives the Syd access to six simultaneous laser shots all in a row, providing ultimate forward destructive power which travels very quickly. Energy consumption for the Cannon is time based, slowly draining energy whether the cannon is fired or not.
|[[File:ASO Armor Homing.png|right]] The '''Homing Armor''' upgrades the power of the Syd's missile launchers. They will fire two glowing orbs which, over a short period of time, divide into six orbs and follow a prescribed path until they get close enough to a ground target to be attracted to it and destroy it. Energy consumption for the Homing Armor is per homing missiles fired. Do not blindly hold the missile button down or you will expend the armor quickly.
|-
|[[File:ASO Armor Paralyzer.png|left]] The '''Paralyzer Armor''' send a column of energy immediately in front of the Syd. Any enemy hit by this column becomes frozen in place, and shatters a few seconds later. The column of energy can also be used to cancel the bullets of enemy fire. The Paralyzer drains energy twice as fast as most weapon armors, as it is constantly active and cannot be turned off. This armor is great for stages with heavy enemy activity, but terrible against most boss fights.
|[[File:ASO Armor Nuclear.png|right]] The '''Nuclear Armor''' is another armor that upgrades the Syd's missile launchers. They will fire a single bomb which travels a certain distance forward and explodes whenever it hits a ground target, or reaches it's maximum travel distance. The explosion is immense, attacking even aerial targets, but the energy cost is high: 3 units of energy per missile. This makes it less practical for typical stage scenarios, but excellent for many boss fights.
|-
|[[File:ASO Armor Fire.png|left]] The '''Fire Armor''' sends out a column of energy much like the Paralyzer armor, only in this case, it is a column of fire. While the Fire armor is active, you will be unable to shoot your regular lasers of missiles, but the column of fire will destroy every object it touches, whether on the ground or in the air, and it will even destroy enemy bullets. Fire Armor drains energy twice as fast as other typical weapon armors.
|[[File:ASO Armor Thunder.png|right]] The '''Thunder Armor''' is the most powerful offensive armor. When the missile button is pressed, the Syd travels to the center of the screen, and unleashes a web of lightning that destroys every enemy present on the screen at that time. The cost is very high for this armor, 8 units of energy per use (although you may still fire one last thunder if you have less than 8 units). Since you can't fire missiles with this armor, it is also the only method that you have of revealing and collecting tiles. This armor is best saved for boss fights.
|}

## ROM Instructions

1. Download [ORCA](https://github.com/opengateware/tools-orca/releases/latest) (Open ROM Conversion Assistant)
2. Download the [ROM Recipes](https://github.com/RndMnkIII/PocketAlphaMission/releases/tag/alphamission_rom-recipes-v1.0) and extract to your computer.
3. Copy the required MAME `.zip` files into the `roms` folder.
4. Inside the `tools` execute the script related to your system.
   1. **Windows:** right click `make_roms.ps1` and select `Run with Powershell`
   2. **Linux and MacOS:** run script `make_roms.sh`.
5. After the convertion is completed, copy the `Assets` folder to the Root of your SD Card.

> **Note:** Make sure your `.rom` files are in the `Assets/alphamission/common` directory.

## ⚙️ Installation

To install the core, copy the content of [latest release file](https://github.com/RndMnkIII/PocketAlphaMission/releases/download/alphamission-pocket-v1.0/rndmnkiii.alphamission_pocket-v1.0.zip) over the root of Pocket SD card.

## Credits and acknowledgment
* First of all I want to thank __Marcus Jordan / Boogermann__ [@marcusjordan](https://twitter.com/marcusjordan) for his help, without which this port would not have been possible and for making it easier for the developers to port cores to the Analogue Pocket using the [Gateman Pocket](https://github.com/opengateware/gateman-pocket) tool.

* __Adam Gastineau__ for his support of the [OpenFPGA](https://www.analogue.co/developer/docs/overview) initiative by publishing information and tools to facilitate the development/port of cores on the Analogue Pocket platform: https://github.com/agg23/analogue-pocket-utils


* To all Ko-fi contributors for supporting this project: __@bdlou__, __Peter Bray__, __Nat__, __Funkycochise__, __David__, __Kevin Coleman__, __Denymetanol__, __Schermobianco__, __TontonKaloun__, __Wark91__, __Dan__, __Beaps__.
* __@caiusarcade__ for their assistance in using files and converting PLD files.
* __@topapate__ for general advice with the JTOPL core.
* __@FCochise__ for helping with the rom settings of MRA files.
* __@alanswx__ for helping me with some technical aspects related to the use of the MiSTer framework.
* And all those who with their comments and shows of support have encouraged me to continue with this project.

## Powered by Open-Source Software

This project borrowed and use code from several other projects. A great thanks to their efforts!

| Modules | Copyright/Developer     |
| :------ | :---------------------- |
| [JTOPL] | 2018 (c) Jose Tejada    |
| [T80]   | 2001 (c) Daniel Wallner |
| [7400 TTL]   | 2017 (c) Tim Rudy |

## Legal Notices

ASO - Armored Scrum Object, Alpha Mission, Arian Mission © 1985 SNK. All rights reserved.
All trademarks, logos, and copyrights mentioned herein belong to their respective owners.

The authors, contributors, or maintainers are not affiliated with or endorsed by SNK.

[T80]: https://opencores.org/projects/t80
[JTOPL]: https://github.com/jotego/jt49
[7400 TTL]: https://github.com/TimRudy/ice-chips-verilog
