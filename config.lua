Config = {
    testDriveEnabled = true, -- enables test-driving before purchasing.
    testDriveTime = 45, -- amount of time IN SECONDS that test-drivers get alloted.
    testDriveRadius = 250.0, -- radius around the dealership that test-drivers can be in (will end the test-drive if they venture outside this value, 250 is a good start).
    dealerships = {
        ["PDM"] = {
            pedModel = `cs_siemonyetarian`,
            pedCoords = vector4(-57.19, -1098.90, 26.42, 17.27),
            displayLocation = vector4(-44.38, -1098.05, 26.42, 248.96),
            testDriveLocation = vector4(-44.88, -1082.68, 26.69, 67.59),
            categories = {"Compacts", "Sedans", "SUVs", "Coupes", "Muscle", "Classics", "Sports", "super", "Motorcycles", "Off-Road", "Vans"},
            blip = {sprite = 523, color = 3},
            spawns = {
                vector4(-14.16, -1108.17, 26.20, 282.01),
                vector4(-12.82, -1105.19, 26.20, 282.08),
                vector4(-11.70, -1102.36, 26.20, 280.18),
                vector4(-10.60, -1099.58, 26.20, 280.60),
                vector4(-9.77, -1096.74, 26.20, 280.28),
                vector4(-8.10, -1081.52, 26.21, 124.82),
                vector4(-11.14, -1080.48, 26.20, 125.45),
                vector4(-47.71, -1116.63, 25.96, 1.28),
                vector4(-50.64, -1116.85, 25.96, 1.26),
                vector4(-53.53, -1116.77, 25.96, 0.48),
                vector4(-56.33, -1116.96, 25.96, 2.03)
            }
        },
        ["Mission Row PD"] = {
            jobs = {"SAHP", "LSPD", "BCSO"},
            pedModel = `csb_trafficwarden`,
            pedCoords = vector4(458.82, -1017.13, 28.18, 90.48),
            displayLocation = vector4(405.16, -964.92, -99.64, 212.03),
            testDriveLocation = vector4(-2135.30, 1106.10, -27.43, 273.24),
            categories = {"MRPD"},
            blip = {sprite = 523, color = 3},
            spawns = {
                vector4(462.81, -1019.49, 27.68, 90.90),
                vector4(462.99, -1014.55, 27.66, 91.79)
            }
        }
    },
    vehicles = {
        ["MRPD"] = {
            { model = `police`, price = 6000, label = "Wannabe Crown Vic" },
            { model = `police2`, price = 25000, label = "Wannabe Charger" },
            { model = `police3`, price = 15000, label = "Wannabe Taurus" }
        },
        ["Compacts"] = {
            { model = `asbo`, price = 8000 },
            { model = `blista`, price = 16000 },
            { model = `brioso`, price = 12000 },
            { model = `brioso2`, price = 18000 },
            { model = `club`, price = 3000 },
            { model = `dilettante`, price = 20000 },
            { model = `issi2`, price = 25000 },
            { model = `issi3`, price = 9000 },
            { model = `kanjo`, price = 6000 },
            { model = `panto`, price = 5000 },
            { model = `prairie`, price = 12000 },
            { model = `rhapsody`, price = 3000 },
            { model = `weevil`, price = 5000 }
        },
        ["Sedans"] = {
            { model = `asea`, price = 8000 },
            { model = `asterope`, price = 11000 },
            { model = `cog55`, price = 210000 },
            { model = `cognoscenti`, price = 265000 },
            { model = `emperor`, price = 7900 },
            { model = `fugitive`, price = 40000 },
            { model = `glendale`, price = 45000 },
            { model = `glendale2`, price = 50000 },
            { model = `ingot`, price = 5000 },
            { model = `intruder`, price = 6000 },
            { model = `premier`, price = 15000 },
            { model = `primo`, price = 8000 },
            { model = `primo2`, price = 16000 },
            { model = `regina`, price = 2100 },
            { model = `romero`, price = 4800 },
            { model = `schafter2`, price = 43000 },
            { model = `stafford`, price = 37000 },
            { model = `stanier`, price = 7200 },
            { model = `stratum`, price = 3000 },
            { model = `stretch`, price = 29000 },
            { model = `superd`, price = 134000 },
            { model = `surge`, price = 34000 },
            { model = `tailgater`, price = 55000 },
            { model = `warrener`, price = 96000 },
            { model = `washington`, price = 13000 }
        },
        ["SUVs"] = {
            { model = `baller`, price = 100 },
            { model = `baller2`, price = 100 },
            { model = `baller3`, price = 100 },
            { model = `baller4`, price = 100 },
            { model = `bjxl`, price = 100 },
            { model = `cavalcade`, price = 100 },
            { model = `cavalcade2`, price = 100 },
            { model = `contender`, price = 100 },
            { model = `dubsta`, price = 100 },
            { model = `dubsta2`, price = 100 },
            { model = `granger`, price = 100 },
            { model = `gresley`, price = 100 },
            { model = `habanero`, price = 100 },
            { model = `huntley`, price = 100 },
            { model = `landstalker`, price = 100 },
            { model = `landstalker2`, price = 100 },
            { model = `mesa`, price = 100 },
            { model = `novak`, price = 100 },
            { model = `patriot`, price = 100 },
            { model = `patriot2`, price = 100 },
            { model = `radi`, price = 100 },
            { model = `rebla`, price = 100 },
            { model = `rocoto`, price = 100 },
            { model = `seminole`, price = 100 },
            { model = `seminole2`, price = 100 },
            { model = `serrano`, price = 100 },
            { model = `squaddie`, price = 100 },
            { model = `toros`, price = 100 },
            { model = `xls`, price = 100 }
        },
        ["Coupes"] = {
            { model = `cogcabrio`, price = 100 },
            { model = `exemplar`, price = 100 },
            { model = `f620`, price = 100 },
            { model = `felon`, price = 100 },
            { model = `felon2`, price = 100 },
            { model = `jackal`, price = 100 },
            { model = `oracle`, price = 100 },
            { model = `oracle2`, price = 100 },
            { model = `sentinel`, price = 100 },
            { model = `sentinel2`, price = 100 },
            { model = `windsor`, price = 100 },
            { model = `windsor2`, price = 100 },
            { model = `zion`, price = 100 },
            { model = `zion2`, price = 100 }
        },
        ["Muscle"] = {
            { model = `blade`, price = 100 },
            { model = `buccaneer`, price = 100 },
            { model = `buccaneer2`, price = 100 },
            { model = `chino`, price = 100 },
            { model = `chino2`, price = 100 },
            { model = `clique`, price = 100 },
            { model = `coquette3`, price = 100 },
            { model = `deviant`, price = 100 },
            { model = `dominator`, price = 100 },
            { model = `dominator2`, price = 100 },
            { model = `dominator3`, price = 100 },
            { model = `dukes`, price = 100 },
            { model = `ellie`, price = 100 },
            { model = `faction`, price = 100 },
            { model = `faction2`, price = 100 },
            { model = `faction3`, price = 100 },
            { model = `gauntlet`, price = 100 },
            { model = `gauntlet2`, price = 100 },
            { model = `gauntlet3`, price = 100 },
            { model = `gauntlet4`, price = 100 },
            { model = `gauntlet5`, price = 100 },
            { model = `hermes`, price = 100 },
            { model = `hotknife`, price = 100 },
            { model = `hustler`, price = 100 },
            { model = `impaler`, price = 100 },
            { model = `manana2`, price = 100 },
            { model = `moonbeam`, price = 100 },
            { model = `moonbeam2`, price = 100 },
            { model = `nightshade`, price = 100 },
            { model = `peyote2`, price = 100 },
            { model = `phoenix`, price = 100 },
            { model = `picador`, price = 100 },
            { model = `ruiner`, price = 100 },
            { model = `sabregt`, price = 100 },
            { model = `sabregt2`, price = 100 },
            { model = `slamvan`, price = 100 },
            { model = `slamvan2`, price = 100 },
            { model = `slamvan3`, price = 100 },
            { model = `stalion`, price = 100 },
            { model = `stalion2`, price = 100 },
            { model = `tampa`, price = 100 },
            { model = `tulip`, price = 100 },
            { model = `vamos`, price = 100 },
            { model = `vigero`, price = 100 },
            { model = `virgo`, price = 100 },
            { model = `virgo2`, price = 100 },
            { model = `virgo3`, price = 100 },
            { model = `voodoo`, price = 100 },
            { model = `yosemite`, price = 100 },
            { model = `yosemite2`, price = 100 }
        },
        ["Classics"] = {
            { model = `btype`, price = 100 },
            { model = `btype2`, price = 100 },
            { model = `btype3`, price = 100 },
            { model = `casco`, price = 100 },
            { model = `cheburek`, price = 100 },
            { model = `cheetah2`, price = 100 },
            { model = `coquette2`, price = 100 },
            { model = `dynasty`, price = 100 },
            { model = `fagaloa`, price = 100 },
            { model = `feltzer3`, price = 100 },
            { model = `gt500`, price = 100 },
            { model = `infernus2`, price = 100 },
            { model = `jb7002`, price = 100 },
            { model = `jester3`, price = 100 },
            { model = `mamba`, price = 100 },
            { model = `manana`, price = 100 },
            { model = `michelli`, price = 100 },
            { model = `monroe`, price = 100 },
            { model = `nebula`, price = 100 },
            { model = `peyote`, price = 100 },
            { model = `pigalle`, price = 100 },
            { model = `rapidgt3`, price = 100 },
            { model = `retinue`, price = 100 },
            { model = `retinue2`, price = 100 },
            { model = `savestra`, price = 100 },
            { model = `stinger`, price = 100 },
            { model = `stingergt`, price = 100 },
            { model = `swinger`, price = 100 },
            { model = `torero`, price = 100 },
            { model = `tornado2`, price = 100 },
            { model = `tornado5`, price = 100 },
            { model = `turismo2`, price = 100 },
            { model = `viseris`, price = 100 },
            { model = `z190`, price = 100 },
            { model = `zion3`, price = 100 },
            { model = `ztype`, price = 100 }
        },
        ["Sports"] = {
            { model = `alpha`, price = 100 },
            { model = `banshee`, price = 100 },
            { model = `bestiagts`, price = 100 },
            { model = `blista2`, price = 100 },
            { model = `blista3`, price = 100 },
            { model = `buffalo`, price = 100 },
            { model = `buffalo2`, price = 100 },
            { model = `buffalo3`, price = 100 },
            { model = `buffalo4`, price = 100 },
            { model = `carbonizzare`, price = 100 },
            { model = `comet2`, price = 100 },
            { model = `comet3`, price = 100 },
            { model = `comet4`, price = 100 },
            { model = `comet5`, price = 100 },
            { model = `coquette`, price = 100 },
            { model = `coquette4`, price = 100 },
            { model = `drafter`, price = 100 },
            { model = `elegy`, price = 100 },
            { model = `elegy2`, price = 100 },
            { model = `feltzer2`, price = 100 },
            { model = `flashgt`, price = 100 },
            { model = `furoregt`, price = 100 },
            { model = `fusilade`, price = 100 },
            { model = `futo`, price = 100 },
            { model = `gb200`, price = 100 },
            { model = `hotring`, price = 100 },
            { model = `imorgon`, price = 100 },
            { model = `issi7`, price = 100 },
            { model = `italigto`, price = 100 },
            { model = `italirsx`, price = 100 },
            { model = `jester`, price = 100 },
            { model = `jester2`, price = 100 },
            { model = `jugular`, price = 100 },
            { model = `khamelion`, price = 100 },
            { model = `komoda`, price = 100 },
            { model = `kuruma`, price = 100 },
            { model = `locust`, price = 100 },
            { model = `lynx`, price = 100 },
            { model = `massacro`, price = 100 },
            { model = `massacro2`, price = 100 },
            { model = `neo`, price = 100 },
            { model = `neon`, price = 100 },
            { model = `ninef`, price = 100 },
            { model = `ninef2`, price = 100 },
            { model = `tenf`, price = 100 },
            { model = `tenf2`, price = 100 },
            { model = `omnis`, price = 100 },
            { model = `paragon`, price = 100 },
            { model = `pariah`, price = 100 },
            { model = `penumbra`, price = 100 },
            { model = `penumbra2`, price = 100 },
            { model = `raiden`, price = 100 },
            { model = `rapidgt`, price = 100 },
            { model = `rapidgt2`, price = 100 },
            { model = `raptor`, price = 100 },
            { model = `revolter`, price = 100 },
            { model = `ruston`, price = 100 },
            { model = `schafter2`, price = 100 },
            { model = `schafter3`, price = 100 },
            { model = `schafter4`, price = 100 },
            { model = `schlagen`, price = 100 },
            { model = `schwarzer`, price = 100 },
            { model = `sentinel3`, price = 100 },
            { model = `seven70`, price = 100 },
            { model = `specter`, price = 100 },
            { model = `specter2`, price = 100 },
            { model = `sugoi`, price = 100 },
            { model = `sultan`, price = 100 },
            { model = `sultan2`, price = 100 },
            { model = `surano`, price = 100 },
            { model = `tampa2`, price = 100 },
            { model = `tropos`, price = 100 },
            { model = `verlierer2`, price = 100 },
            { model = `vstr`, price = 100 },
        },
        ["super"] = {
            { model = `adder`, price = 100 },
            { model = `autarch`, price = 100 },
            { model = `banshee2`, price = 100 },
            { model = `bullet`, price = 100 },
            { model = `cheetah`, price = 100 },
            { model = `cyclone`, price = 100 },
            { model = `deveste`, price = 100 },
            { model = `emerus`, price = 100 },
            { model = `entityxf`, price = 100 },
            { model = `entity2`, price = 100 },
            { model = `fmj`, price = 100 },
            { model = `furia`, price = 100 },
            { model = `gp1`, price = 100 },
            { model = `infernus`, price = 100 },
            { model = `italigtb`, price = 100 },
            { model = `italigtb2`, price = 100 },
            { model = `krieger`, price = 100 },
            { model = `le7b`, price = 100 },
            { model = `nero`, price = 100 },
            { model = `nero2`, price = 100 },
            { model = `osiris`, price = 100 },
            { model = `penetrator`, price = 100 },
            { model = `pfister811`, price = 100 },
            { model = `prototipo`, price = 100 },
            { model = `reaper`, price = 100 },
            { model = `s80`, price = 100 },
            { model = `sc1`, price = 100 },
            { model = `sheava`, price = 100 },
            { model = `sultanrs`, price = 100 },
            { model = `t20`, price = 100 },
            { model = `taipan`, price = 100 },
            { model = `tempesta`, price = 100 },
            { model = `tezeract`, price = 100 },
            { model = `thrax`, price = 100 },
            { model = `tigon`, price = 100 },
            { model = `turismor`, price = 100 },
            { model = `tyrant`, price = 100 },
            { model = `tyrus`, price = 100 },
            { model = `vacca`, price = 100 },
            { model = `vagner`, price = 100 },
            { model = `visione`, price = 100 },
            { model = `voltic`, price = 100 },
            { model = `xa21`, price = 100 },
            { model = `zentorno`, price = 100 },
            { model = `zorrusso`, price = 100 }
        },
        ["Motorcycles"] = {
            { model = `akuma`, price = 100 },
            { model = `avarus`, price = 100 },
            { model = `bagger`, price = 100 },
            { model = `bati`, price = 100 },
            { model = `bati2`, price = 100 },
            { model = `bf400`, price = 100 },
            { model = `carbonrs`, price = 100 },
            { model = `chimera`, price = 100 },
            { model = `cliffhanger`, price = 100 },
            { model = `daemon`, price = 100 },
            { model = `daemon2`, price = 100 },
            { model = `defiler`, price = 100 },
            { model = `diablous`, price = 100 },
            { model = `diablous2`, price = 100 },
            { model = `double`, price = 100 },
            { model = `enduro`, price = 100 },
            { model = `esskey`, price = 100 },
            { model = `faggio`, price = 100 },
            { model = `faggio2`, price = 100 },
            { model = `faggio3`, price = 100 },
            { model = `fcr`, price = 100 },
            { model = `fcr2`, price = 100 },
            { model = `gargoyle`, price = 100 },
            { model = `hakuchou`, price = 100 },
            { model = `hakuchou2`, price = 100 },
            { model = `hexer`, price = 100 },
            { model = `innovation`, price = 100 },
            { model = `lectro`, price = 100 },
            { model = `manchez`, price = 100 },
            { model = `manchez2`, price = 100 },
            { model = `nemesis`, price = 100 },
            { model = `nightblade`, price = 100 },
            { model = `pcj`, price = 100 },
            { model = `rrocket`, price = 100 },
            { model = `ruffian`, price = 100 },
            { model = `sanchez`, price = 100 },
            { model = `sanchez2`, price = 100 },
            { model = `sanctus`, price = 100 },
            { model = `sovereign`, price = 100 },
            { model = `stryder`, price = 100 },
            { model = `thrust`, price = 100 },
            { model = `vader`, price = 100 },
            { model = `vindicator`, price = 100 },
            { model = `vortex`, price = 100 },
            { model = `wolfsbane`, price = 100 },
            { model = `zombiea`, price = 100 },
            { model = `zombieb`, price = 100 }
        },
        ["Off-Road"] = {
            { model = `bfinjection`, price = 100 },
            { model = `bifta`, price = 100 },
            { model = `blazer`, price = 100 },
            { model = `blazer3`, price = 100 },
            { model = `blazer4`, price = 100 },
            { model = `brawler`, price = 100 },
            { model = `caracara2`, price = 100 },
            { model = `dubsta3`, price = 100 },
            { model = `everon`, price = 100 },
            { model = `freecrawler`, price = 100 },
            { model = `hellion`, price = 100 },
            { model = `kalahari`, price = 100 },
            { model = `kamacho`, price = 100 },
            { model = `mesa3`, price = 100 },
            { model = `outlaw`, price = 100 },
            { model = `rancherxl`, price = 100 },
            { model = `rebel2`, price = 100 },
            { model = `riata`, price = 100 },
            { model = `sandking`, price = 100 },
            { model = `sandking2`, price = 100 },
            { model = `trophytruck`, price = 100 },
            { model = `trophytruck2`, price = 100 },
            { model = `vagrant`, price = 100 },
            { model = `verus`, price = 100 },
            { model = `winky`, price = 100 },
            { model = `yosemite3`, price = 100 },
            { model = `guardian`, price = 100 },
            { model = `sadler`, price = 100 }
        },
        ["Vans"] = {
            { model = `bison`, price = 100 },
            { model = `bobcatxl`, price = 100 },
            { model = `burrito3`, price = 100 },
            { model = `camper`, price = 100 },
            { model = `gburrito2`, price = 100 },
            { model = `minivan`, price = 100 },
            { model = `minivan2`, price = 100 },
            { model = `speedo`, price = 100 },
            { model = `surfer`, price = 100 },
            { model = `youga`, price = 100 },
            { model = `youga2`, price = 100 }
        },
        ["Cycles"] = {
            { model = `bmx`, price = 100 },
            { model = `cruiser`, price = 100 },
            { model = `fixter`, price = 100 },
            { model = `scorcher`, price = 100 },
            { model = `tribike`, price = 100 },
            { model = `tribike2`, price = 100 },
            { model = `tribike3`, price = 100 }
        }
    }
}