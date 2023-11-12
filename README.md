# SNK Triple Z80 Compatible Gateware IP Core (WIP)

Follow any core updates and news on my Twitter acount [@RndMnkIII](https://twitter.com/RndMnkIII). this project is a hobby but it requires investing in arcade game boards and specific tools, so any donation is welcome: [https://ko-fi.com/rndmnkiii](https://ko-fi.com/rndmnkiii).

## About

This core originated from the core project for __SNK's__ __Alpha__ __Mission__ arcade game. In the end, it has become a multigame project where new games will be added, encompassed in the so-called __"SNK Triple Z80"__ platform, this groups together several games that were developed by SNK around the mid-1980s using a similar hardware architecture. For a complete reference of the list of games consult
[https://github.com/mamedev/mame/blob/master/src/mame/drivers/snk.cpp](https://github.com/mamedev/mame/blob/master/src/mame/drivers/snk.cpp).

I am currently making the core of other of these games, as I develop them I will incorporate modular features to use certain hardware parts depending on the game that is loaded in the core. The idea is to use a single core for all these games or try to modularize it as much as possible. Next games that I've planned to incorporate: Ikari Warriors, T.N.K. III, Psycho Soldier and more.

While it is in this development process, it will be appreciated that parallel developments of these games are not made to those of the author based on the code of this project or my previous project for the Alpha Mission standalone game core, although I think it is good that it is ported to other platforms apart from MiSTer. Respecting that if I would like to receive suggestions or advice from other developers or users about this core.

## Compatible Games

> __ROMs NOT INCLUDED:__ By using this core you agree to provide your own roms. We do not condone or support the unauthorized use or distribution of copyrighted or other intellectual property-protected materials

| Name                         | Status |
| :--------------------------- | :----: |
| ASO - Armored Scrum Object   |  ✅    |
| Alpha Mission, Arian Mission |  ✅    |
| Arian Mission                |  ✅    |

## Credits and acknowledgment

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
