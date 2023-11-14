# SNK ASO/Alpha Mission Compatible Gateware IP Core

Follow any core updates and news on my Twitter acount [@RndMnkIII](https://twitter.com/RndMnkIII). this project is a hobby but it requires investing in arcade game boards and specific tools, so any donation is welcome: [https://ko-fi.com/rndmnkiii](https://ko-fi.com/rndmnkiii).

## About

This core originated from the core project for __SNK's__ __Alpha__ __Mission__ arcade game. Encompass the __"SNK Triple Z80"__ platform, this groups together several games that were developed by SNK around the mid-1980s using a similar hardware architecture. For a complete reference of the list of games consult
[https://github.com/mamedev/mame/blob/master/src/mame/drivers/snk.cpp](https://github.com/mamedev/mame/blob/master/src/mame/drivers/snk.cpp).

## Compatible Games

> __ROMs NOT INCLUDED:__ By using this core you agree to provide your own roms. We do not condone or support the unauthorized use or distribution of copyrighted or other intellectual property-protected materials

| Name                         | Status |
| :--------------------------- | :----: |
| ASO - Armored Scrum Object   |  ✅    |
| Alpha Mission, Arian Mission |  ✅    |
| Arian Mission                |  ✅    |

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
