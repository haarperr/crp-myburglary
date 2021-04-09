Config = {}
Translation = {}

Config.Locale = 'en'

Config.BurglaryTime = {start = 0, endtime = 24}

Config.useSeller = true -- should the Seller be there
Config.SellerLocation = {x = 953.63604736328, y = -2180.607421875, z = 30.551578521729, rot = 94.35311126709}
Config.SellerPedModel = "s_m_m_cntrybar_01"
Config.showSellerBlip = true

Config.SellItems = { -- set up the items here, that your players can sell at the seller - You can set up the items they get in the missions config.
    {sqlitem = 'bag', label = 'Bag of Money', priceBuy = 2100.0},
    {sqlitem = 'gold_ingot', label = 'Gold Ingot', priceBuy = 1000.0},
    {sqlitem = 'weed', label = 'Weed', priceBuy = 100.0},
    {sqlitem = 'weed_pooch', label = 'Weed Pooch', priceBuy = 350.0},
}

Config.requiresItem = false -- should an item be required to enter a house
Config.LockpickItem = 'lockpick'

Config.InteractKey = 38 -- Key, to start robbing and to collect items
Config.CodeKey = 47 -- G

Config.useBlackMoney = false
Config.BlackMoneyName = 'black_money'

Config.showMissionBlips = true

Config.Missions = {
    {
        name = 'Vinweood House',
        requiredCops = 2,
        delay = 30, --min delay, until this mission can be started again
        loc = {x = 122.71, y = 564.77, z = 184.04},
        inside = {x = 117.35, y = 559.39, z = 184.3, rot = 184.5},
        alarmLocation = {x = 116.18002319336, y = 559.94860839844, z = 184.29702758789, rot = 89.901557922363},
		callCopPercentageAnyways = 100, -- In this percentage the cops are directly notified after lockpicking
        alarmTimeBeforeDispatch = {randomA = 25, randomB = 35},
        randomCodeLocations = {
            {x = 118.00901031494, y = 543.08685302734, z = 180.38031005859, rot = 328.80206298828}, 
            {x = 116.89733123779, y = 560.85339355469, z = 179.49705505371, rot = 196.72248840332}, 
            {x = 123.7970199585, y = 543.38757324219, z = 183.37001037598, rot = 70.289360046387}, 
        },
        customScreenMessage = '~b~Find money and items - be fast!',
        objects = {
            {
                objectHash = 'p_michael_backpack_s',
                loc = {x = 117.0365524292, y = 554.72521972656, z = 183.60381774902, rot = 92.96},
                giveItems = {{item = 'bag', amount = 1}}, giveMoney = 0,
            },
            {
                objectHash = 'hei_prop_heist_cash_pile',
                loc = {x = 120.58995819092, y = 554.77227783203, z = 184.55868225098, rot = 260.81030273438},
                giveItems = {}, giveMoney = 2000,
            },
        },
    },

    {
        name = 'Michaels House',
        requiredCops = 2,
        delay = 60, --min delay, until this mission can be started again
        loc = {x = -817.58123779297, y = 177.78002929688, z = 72.222496032715},
        inside = nil,
        alarmLocation = {x = -815.55377197266, y = 189.08438110352, z = 72.478134155273, rot = 100.662008285522},
        callCopPercentageAnyways = 100, -- In this percentage the cops are directly notified after lockpicking
        alarmTimeBeforeDispatch = {randomA = 55, randomB = 85}, -- time in seconds to find the alarm code before definately a dispatch is sent
        randomCodeLocations = { -- set up multiple possible locations for the alarm code to make the search interessting
            {x = -799.17700195312, y = 185.48817443848, z = 73.516288757324, rot = 335.2941284179}, 
            {x = -805.32006835938, y = 178.10200500488, z = 73.929138183594, rot = 183.47573852539},
        },
        customScreenMessage = '~b~Find money and items - be fast!', -- can be used for missions where f.e. a certain item (USB STICK) have to be found.
        objects = { -- objects, which can be stolen
            {
                objectHash = 'p_michael_backpack_s',
                loc = {x = -814.36102294922, y = 181.00151062012, z = 77.412704467773, rot = 243.61514282227},
                giveItems = {{item = 'bag', amount = 1}}, giveMoney = 0,
            },
            {
                objectHash = 'hei_prop_heist_cash_pile',
                loc = {x = -808.54888916016, y = 181.48764038086, z = 73.153358459473, rot = 181.29470825195},
                giveItems = {}, giveMoney = 2000,
            },
            {
                objectHash = 'hei_prop_heist_cash_pile',
                loc = {x = -803.97418212891, y = 183.32978820801, z = 73.599349975586, rot = 246.3042755127},
                giveItems = {}, giveMoney = 3000,
            },
            {
                objectHash = 'ex_prop_exec_award_diamond',
                loc = {x = -802.28350830078, y = 170.99723815918, z = 73.341979980469, rot = 261.39303588867},
                giveItems = {{item = 'gold_ingot', amount = 1}}, giveMoney = 0,
            },
            {
                objectHash = 'bkr_prop_weed_bag_pile_01a',
                loc = {x = -804.28381347656, y = 168.6369934082, z = 77.570930480957, rot = 287.05276489258},
                giveItems = {{item = 'weed_pooch', amount = 1},{item = 'weed', amount = 3}}, giveMoney = 0,
            },
            {
                objectHash = 'bkr_prop_weed_bigbag_open_01a',
                loc = {x = -797.15246582031, y = 177.87405395508, z = 72.834747314453, rot = 327.42092895508},
                giveItems = {{item = 'weed_pooch', amount = 10},{item = 'weed', amount = 12}}, giveMoney = 0,
            },
        },
    },
	{
        name = 'Franklin House',
        requiredCops = 2,
        delay = 60, 
        loc = {x = 8.6036, y = 540.1011, z = 176.0271},
        inside = nil,
        alarmLocation = {x = 21.1172, y = 548.8147, z = 176.0275, rot = 236.4980},
        callCopPercentageAnyways = 100, --
        alarmTimeBeforeDispatch = {randomA = 55, randomB = 85}, 
        randomCodeLocations = { 
            {x = -11.0596, y = 516.3331, z = 174.6280, rot = 70.7664}, 
            {x = -8.0306, y = 529.9075, z = 175.0351, rot = 88.8193},
        },
        customScreenMessage = '~b~Find money and items - be fast!', 
        objects = {
            {
                objectHash = 'p_michael_backpack_s',
                loc = {x = -1.3757, y = 524.0341, z = 171.3190, rot = 20.5666},
                giveItems = {{item = 'bag', amount = 1}}, giveMoney = 0,
            },
            {
                objectHash = 'hei_prop_heist_cash_pile',
                loc = {x = 0.4814, y = 535.5685, z = 175.7627, rot = 149.3674},
                giveItems = {}, giveMoney = 2000,
            },
            {
                objectHash = 'hei_prop_heist_cash_pile',
                loc = {x = 0.3538, y = 534.7559, z = 175.7627, rot = 149.3674},
                giveItems = {}, giveMoney = 2000,
            },
            {
                objectHash = 'ex_prop_exec_award_diamond',
                loc = {x = 10.9155, y = 530.5971, z = 175.0472, rot = 296.1210},
                giveItems = {{item = 'gold_ingot', amount = 1}}, giveMoney = 0,
            },
            {
                objectHash = 'bkr_prop_weed_bigbag_open_01a',
                loc = {x = 2.8356, y = 527.5584, z = 175.1480, rot = 264.2103},
                giveItems = {{item = 'weed_pooch', amount = 10},{item = 'weed', amount = 12}}, giveMoney = 0,
            },
        },
    },
}

Translation = {
    ['en'] = {
        ['infobar_enter'] = 'Press ~o~E~s~, to enter the property',
        ['infobar_leave'] = 'Press ~o~E~s~, to abort the mission',
        ['infobar_code'] = 'Press ~r~G~s~, to insert the ~r~alarm code',
        ['infobar_seller'] = 'Press ~o~E~s~, to talk with the seller',
        ['no_lockpick'] = '~r~You do not have a lockpick',
        ['collect_items'] = 'Press ~g~E~s~, to take this',
        ['seller_title'] = 'Seller',
        ['input_howmuch'] = 'How much should be sold?',
        ['items_sold_for'] = '~s~Items sold for ~g~',
        ['you_only_have_items'] = '~y~You only have ~w~',
        ['you_only_have_items2'] = 'x ~y~with you',
        ['too_late_rob_aborted'] = '~r~Night is over and inhabitants wake up, RUN!',
        ['screen_deactivatealarm'] = '~b~Deactivate the alarm first.',
        ['screen_alarmtime'] = '~r~Alarm time: ~w~',
        ['screen_alarmtime2'] = 's remaining',
        ['screen_police'] = '~r~Police was informed!',
        ['screen_alarmdisabled'] = '~g~Alarm disabled',
        ['insert_deactivation'] = 'Insert deactivation code',
        ['alarm_deactivated'] = 'The ~r~house alarm ~s~was ~g~deactivated~s~!',
        ['wrong_code'] = '~r~You have inserted the wrong code!',
        ['already_robbed'] = '~r~You have to wait ~w~',
        ['already_robbed2'] = ' minutes ~r~until you can start this mission again!',
        ['3D_alarmtext'] = 'You have found the ~r~alarm ~s~code: ~y~',
        ['house_alarm'] = 'Silent alarm',
        ['house_alarm_msg'] = 'An ~r~alarm ~s~was triggered from a house in ~y~',
        ['house_robbery'] = 'House robbery',
        ['end_robbery_seller'] = '~g~Robbery finished!',
        ['not_enough_cops'] = '~r~Not enough cops online',
    }
}