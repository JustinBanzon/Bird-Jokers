--- STEAMODDED HEADER
--- MOD_NAME: Bird Jokers
--- MOD_ID: BirdJokers
--- PREFIX: bird_jokers
--- MOD_AUTHOR: [Justin]
--- MOD_DESCRIPTION: Adds a couple of custom bird Jokers
--- LOADER_VERSION_GEQ: 1.0.0
----------------------------------------------
------------MOD CODE -------------------------
--localization

function SMODS.current_mod.process_loc_text()
    G.localization.descriptions.Other['crow_key'] = {
        name = 'Unfortunate bird',
        text = {
            'gains {X:mult,C:white}X#1#{} Mult when',
            'Wheel of Fortune says "'..localize("k_nope_ex")..'"'
        }
    }
    G.localization.descriptions.Other['swallow_key'] = {
        name = 'Fortunate bird',
        text = {
            'gains {X:mult,C:white}X#1#{} Mult when',
            'Wheel of Fortune gives an edition'
        }
    }
    G.localization.descriptions.Other['bird_sacred'] = {
        name = 'Sacred Geometry',
        text = {
            'This card was marked',
            'by a crow person,',
            'becomes "returned"',
            'when scored'
        }
    }
    G.localization.descriptions.Other['bird_returned_sacred'] = {
        name = 'Returned Sacred Geometry',
        text = {
            'This card was scored',
            'after being marked',
            'by a crow person.',
        }
    }
    G.localization.misc.labels['bird_sacred']='Sacred Geometry'
    G.localization.misc.labels['bird_returned_sacred']='Returned Sacred Geometry'
end
SMODS.Atlas{
    key = "unlucky_crow",
    path = "j_unlucky_crow.png",
    px = 71,
    py = 95
}
SMODS.Atlas{
    key = "lucky_swallow",
    path = "j_lucky_swallow.png",
    px = 71,
    py = 95
}
SMODS.Atlas{
    key = "manzai_birds",
    path = "j_manzai.png",
    px = 71,
    py = 95
}
SMODS.Atlas{
    key = "crow_person",
    path = "j_crow_person.png",
    px = 71,
    py = 95
}
SMODS.Atlas{
    key = "crow_person_true",
    path = "j_crow_person_true.png",
    px = 71,
    py = 95
}
-- local Wheel = SMODS.Tarot:take_ownership('wheel_of_fortune'):register()
-- crow_person_transformed = false;
-- function conditional_bark(condition,true_bark,false_bark)
--     if condition then
--         card_eval_status_text(card, 'extra', nil, nil, nil, {message = true_bark})
--     else
--         card_eval_status_text(card, 'extra', nil, nil, nil, {message = false_bark})
--     end
-- end
local get_badge_colourref = get_badge_colour
function get_badge_colour(key)
    if key == 'bird_sacred' then return HEX("00CCCC") end
    if key == 'bird_returned_sacred' then return HEX("00FFFF") end
    return get_badge_colourref(key);
end
local unlucky_crow = SMODS.Joker{
    key="unlucky_crow", 
    name="Unlucky Crow", 
    rarity=2, 
    unlocked=true, 
    discovered=false, 
    blueprint_compat=true, 
    perishable_compat=false, 
    eternal_compat=true,
    pos={ x = 0, y = 0 },
    cost=6,
    config={ x_mult = 1 ,extra = {odds = 4, x_mult=0.25}},
    loc_txt={
        name="Unlucky Crow",
        text={
            'This Joker has a {C:green} #3# in #4#{} chance',
            'to gain {X:mult,C:white}X#2#{} every hand',
        '{C:inactive}(Currently {X:mult,C:white}X#1#{C:inactive} Mult)'
        }},
    -- This Joker has a 1 in 4 chance
    -- to gain X0.25 Mult every hand
    --
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = {set = 'Other', key = 'crow_key', vars = {card.ability.extra.x_mult}}
        return {vars = {card.ability.x_mult,card.ability.extra.x_mult,G.GAME.probabilities.normal,card.ability.extra.odds}}
    end,
    calculate = function(self,card, context)
        if not context.blueprint then
            if context.consumeable then
                if context.consumeable.ability.name =='The Wheel of Fortune' and not(context.consumeable.yep) then
                    card.ability.x_mult = card.ability.x_mult + card.ability.extra.x_mult
                    card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize('k_upgrade_ex')})
                    return true
                end
            end
            if context.cardarea == G.jokers and context.before then
                if (pseudorandom('unlucky_crow') < G.GAME.probabilities.normal/card.ability.extra.odds) then
                    card.ability.x_mult = card.ability.x_mult + card.ability.extra.x_mult
                    card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize('k_upgrade_ex')})
                else
                    -- card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize{type='variable',key='a_xmult',vars={card.ability.x_mult}}})
                    card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize('k_nope_ex')})
                end
            end
        end
        if context.cardarea == G.jokers and not context.before and not context.after and card.ability.x_mult>1 then
            return {
                message = localize{type='variable',key='a_xmult',vars={card.ability.x_mult}},
                Xmult_mod = card.ability.x_mult,
            }
        end
    end,
    atlas = "unlucky_crow"
}
local lucky_swallow = SMODS.Joker{
    key="lucky_swallow", 
    name="Lucky Swallow", 
    rarity=2, 
    unlocked=true, 
    discovered=false, 
    blueprint_compat=true, 
    perishable_compat=false, 
    eternal_compat=true,
    pos={ x = 0, y = 0 },
    cost=6,
    config={ x_mult = 1 ,extra = {odds = 8,odds_numer = 1, x_mult=0.25}},
    loc_txt={
        name="Lucky Swallow",
        text={
            'This Joker has a {C:green}#3# in #4#{} chance',
            'to gain {X:mult,C:white}X#2#{} every hand,',
            'odds increase per consecutive',
            'hand played without succeeding',
        '{C:inactive}(Currently {X:mult,C:white}X#1#{C:inactive} Mult)'
        }},
    -- This Joker has a 1 in 8 chance
    -- to gain X0.25 Mult every hand,
    -- Odds increase per consecutive 
    -- hand played without succeeding
    -- (Currently X1.00 Mult)
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = {set = 'Other', key = 'swallow_key', vars = {card.ability.extra.x_mult}}
        return {vars = {card.ability.x_mult,card.ability.extra.x_mult,G.GAME.probabilities.normal*card.ability.extra.odds_numer,card.ability.extra.odds}}
    end,
    calculate = function(self,card, context)
        if not context.blueprint then
            if context.consumeable then
                if context.consumeable.ability.name =='The Wheel of Fortune' and context.consumeable.yep then
                    card.ability.x_mult = card.ability.x_mult + card.ability.extra.x_mult
                    card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize('k_upgrade_ex')})
                    return true
                end
            end
            if context.cardarea == G.jokers and context.before then
                if (pseudorandom('lucky_swallow') < G.GAME.probabilities.normal*card.ability.extra.odds_numer/card.ability.extra.odds) then
                    card.ability.extra.odds_numer = 1
                    card.ability.x_mult = card.ability.x_mult + card.ability.extra.x_mult
                    card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize('k_upgrade_ex')})
                else
                    card.ability.extra.odds_numer = card.ability.extra.odds_numer + 1
                    card_eval_status_text(card, 'extra', nil, nil, nil, {message = ((G.GAME.probabilities.normal*card.ability.extra.odds_numer)..' in '..card.ability.extra.odds)})
                end
            end
        end
        if context.cardarea == G.jokers and not context.before and not context.after and card.ability.x_mult>1 then
            return {
                message = localize{type='variable',key='a_xmult',vars={card.ability.x_mult}},
                Xmult_mod = card.ability.x_mult,
            }
        end
    end,
    atlas = "lucky_swallow"
}
local manzai_birds = SMODS.Joker{
    key="manzai", 
    name="Manzai birds", 
    rarity=2, 
    unlocked=true, 
    discovered=false, 
    blueprint_compat=true, 
    perishable_compat=true, 
    eternal_compat=true,
    pos={ x = 0, y = 0 },
    cost=6,
    config={extra = {odds = 4, x_mult=2}},
    loc_txt={
        name="Manzai Birds",
        text={
            'Retrigger the last played',
            'card used in scoring once,',
            '{C:green}#1# in #2#{} chance for retriggered',
            'card to gain {X:mult,C:white}X#3#{} mult'
        }},
    -- Retrigger the last played
    -- card used in scoring once,
    -- 1 in 4 chance for Retriggered
    -- card to gain x2 Mult
    loc_vars = function(self, info_queue, card)
        return {vars = {G.GAME.probabilities.normal,card.ability.extra.odds,card.ability.extra.x_mult}}
    end,
    calculate = function(self, card, context)
        if context.repetition and context.cardarea == G.play
            and context.other_card == context.scoring_hand[#(context.scoring_hand)] then
            return {
                message = localize('k_again_ex'),
                repetitions = 1,
                card = card
            }
        end
        if context.individual and pseudorandom('manzai') < G.GAME.probabilities.normal/card.ability.extra.odds 
            and context.cardarea == G.play
            and context.other_card == context.scoring_hand[#(context.scoring_hand)] then
            return {
                        x_mult = card.ability.extra.x_mult,
                        colour = G.C.RED,
                        card = card
                    }
        end
    end,
    atlas = "manzai_birds"
}
local crow_person = SMODS.Joker{
    key="crow_person",
    name="Crow Person",
    rarity=1,
    unlocked=true, 
    discovered=false, 
    blueprint_compat=false, 
    perishable_compat=true, 
    eternal_compat=true,
    pos={ x = 0, y = 0 },
    cost=2,
    config={extra={odds=2 , returned_geometries=0}},
    loc_txt={
        name="Crow Person",
        text={
            'Has a {C:green}#1# in #2#{} chance',
            'to mark all scored cards',
            'as sacred geometry cards,',
            'Transforms into its true form',
            'if 10 or more sacred geometry',
            'cards score',
            '{C:inactive}(Currently #3#/10)'
        }},
    -- has a 1 in 2 chance 
    -- to mark all scored cards
    -- as sacred geometry cards, 
    -- Transforms into its true form 
    -- if 10 or more sacred geometry
    -- cards score
    -- (Currently 1/10)
    loc_vars = function(self, info_queue, card)
        return {vars = {G.GAME.probabilities.normal,card.ability.extra.odds,card.ability.extra.returned_geometries}}
    end,
    calculate = function(self, card, context)
        if context.cardarea == G.jokers and context.before and not context.blueprint then
            local returning = false;
            for k, v in ipairs(context.scoring_hand) do
                if v.ability and v.ability.sacred_geometry and not v.ability.returned then
                    returning = true;
                    card.ability.extra.returned_geometries = card.ability.extra.returned_geometries + 1;
                    G.E_MANAGER:add_event(Event({
                        trigger = 'before',
                        delay = 0.0,
                        func = function()
                            v:juice_up()
                            v.ability.returned = true
                        return true
                        end
                    }))
                end
            end
            if returning then
                card:juice_up()
                if card.ability.extra.returned_geometries < 10 then
                    card_eval_status_text(card, 'extra', nil, nil, nil, {message = (card.ability.extra.returned_geometries..'/'..10)})
                else
                    card_eval_status_text(card, 'extra', nil, nil, nil, {message = ('Transformed!')})
                    G.E_MANAGER:add_event(Event({trigger = 'immediate', func = function()
                        local new_card = nil
                        -- create_card_alt(_type, area, legendary, _rarity, skip_materialize, soulable, forced_key, key_append, edition_append, forced_edition)
                        if card.edition then
                            new_card = create_card_alt('Joker', G.jokers, nil, nil, nil, nil, 'j_bird_jokers_crow_person_true', nil, true, card.edition)
                        else
                            new_card = create_card_alt('Joker', G.jokers, nil, nil, nil, nil, 'j_bird_jokers_crow_person_true')
                        end
                        new_card:add_to_deck()
                        G.jokers:emplace(new_card)
                        new_card:start_materialize()
                        G.GAME.joker_buffer = 0
                        return true;
                    end}))
                    G.E_MANAGER:add_event(Event({
                            func = function()
                                play_sound('tarot1')
                                card.T.r = -0.2
                                card:juice_up(0.3, 0.4)
                                card.states.drag.is = true
                                card.children.center.pinch.x = true
                                G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.3, blockable = false,
                                    func = function()
                                            G.jokers:remove_card(card)
                                            card:remove()
                                            card = nil
                                        return true; end})) 
                                return true
                            end
                        })) 
                    G.GAME.pool_flags["crow_person_transformed"] = true;

                end
            end
            if pseudorandom('crow_person') < G.GAME.probabilities.normal/card.ability.extra.odds then
                for k, v in ipairs(context.scoring_hand) do
                    if v.ability and not v.ability.sacred_geometry then
                        G.E_MANAGER:add_event(Event({
                            trigger = 'before',
                            delay = 0.0,
                            func = function()
                                v:juice_up()
                                v.ability.sacred_geometry = true
                            return true
                            end
                        }))
                    end
                end
                card:juice_up()
                card_eval_status_text(card, 'extra', nil, nil, nil, {message = ("Marked!")})
            end
        end
    end,
    atlas = "crow_person"
}
local true_crow = SMODS.Joker{
    key="crow_person_true",
    name="Crow Person (True form)",
    yes_pool_flag="crow_person_transformed",
    rarity=3,
    unlocked=true, 
    discovered=false, 
    blueprint_compat=true, 
    perishable_compat=true, 
    eternal_compat=true,
    pos={ x = 0, y = 0 },
    cost=6,
    config={extra={odds=2,x_mult=2}},
    loc_txt={
        name="Crow Person (True Form)",
        text={
            'Has a {C:green}#1# in #2#{} chance','to mark all scored cards',
            'as sacred geometry cards,',
            'Scoring returned sacred geometry',
            'cards give {X:mult,C:white}X#3#{} mult'
        }},
    -- has a 1 in 2 chance 
    -- to mark all scored cards
    -- as sacred geometry cards, 
    -- Transforms into its true form 
    loc_vars = function(self, info_queue, card)
        return {vars = {G.GAME.probabilities.normal,card.ability.extra.odds,card.ability.extra.x_mult}}
    end,
    calculate = function(self, card, context)
        if context.cardarea == G.jokers and context.before and not context.blueprint then
            local returning = false
            for k, v in ipairs(context.scoring_hand) do
                if v.ability and v.ability.sacred_geometry and not v.ability.returned then
                    returning = true;
                    G.E_MANAGER:add_event(Event({
                        trigger = 'before',
                        delay = 0.0,
                        func = function()
                            v:juice_up()
                            v.ability.returned = true
                        return true
                        end
                    }))
                end
            end
            if returning then
                card:juice_up()
                card_eval_status_text(card, 'extra', nil, nil, nil, {message = ("returned!")})
            end
            if pseudorandom('crow_person') < G.GAME.probabilities.normal/card.ability.extra.odds then
                for k, v in ipairs(context.scoring_hand) do
                    if v.ability and not v.ability.sacred_geometry then
                        G.E_MANAGER:add_event(Event({
                            trigger = 'before',
                            delay = 0.0,
                            func = function()
                                v:juice_up()
                                v.ability.sacred_geometry = true
                            return true
                            end
                        }))
                    end
                end
                card:juice_up()
                card_eval_status_text(card, 'extra', nil, nil, nil, {message = ("Marked!")})
            end
        end
        if context.individual and context.cardarea == G.play then
            if context.other_card.ability.returned then
                return {
                            x_mult = card.ability.extra.x_mult,
                            colour = G.C.RED,
                            card = card
                        }
            end
        end
    end,
    atlas = "crow_person_true"
}

-- Credit to Joker Evolution for the code for creating cards

function create_card_alt(_type, area, legendary, _rarity, skip_materialize, soulable, forced_key, key_append, edition_append, forced_edition)
    local area = area or G.jokers
    local center = G.P_CENTERS.b_red
        

    --should pool be skipped with a forced key
    if not forced_key and soulable and (not G.GAME.banned_keys['c_soul']) then
        if (_type == 'Tarot' or _type == 'Spectral' or _type == 'Tarot_Planet') and
        not (G.GAME.used_jokers['c_soul'] and not next(find_joker("Showman")))  then
            if pseudorandom('soul_'.._type..G.GAME.round_resets.ante) > 0.997 then
                forced_key = 'c_soul'
            end
        end
        if (_type == 'Planet' or _type == 'Spectral') and
        not (G.GAME.used_jokers['c_black_hole'] and not next(find_joker("Showman")))  then 
            if pseudorandom('soul_'.._type..G.GAME.round_resets.ante) > 0.997 then
                forced_key = 'c_black_hole'
            end
        end
    end

    if _type == 'Base' then 
        forced_key = 'c_base'
    end

    if forced_key and not G.GAME.banned_keys[forced_key] then 
        center = G.P_CENTERS[forced_key]
        _type = (center.set ~= 'Default' and center.set or _type)
    else
        local _pool, _pool_key = get_current_pool(_type, _rarity, legendary, key_append)
        center = pseudorandom_element(_pool, pseudoseed(_pool_key))
        local it = 1
        while center == 'UNAVAILABLE' do
            it = it + 1
            center = pseudorandom_element(_pool, pseudoseed(_pool_key..'_resample'..it))
        end

        center = G.P_CENTERS[center]
    end

    local front = ((_type=='Base' or _type == 'Enhanced') and pseudorandom_element(G.P_CARDS, pseudoseed('front'..(key_append or '')..G.GAME.round_resets.ante))) or nil

    local card = Card(area.T.x + area.T.w/2, area.T.y, G.CARD_W, G.CARD_H, front, center,
    {bypass_discovery_center = area==G.shop_jokers or area == G.pack_cards or area == G.shop_vouchers or (G.shop_demo and area==G.shop_demo) or area==G.jokers or area==G.consumeables,
     bypass_discovery_ui = area==G.shop_jokers or area == G.pack_cards or area==G.shop_vouchers or (G.shop_demo and area==G.shop_demo),
     discover = area==G.jokers or area==G.consumeables, 
     bypass_back = G.GAME.selected_back.pos})
    if card.ability.consumeable and not skip_materialize then card:start_materialize() end

    if _type == 'Joker' then
        if G.GAME.modifiers.all_eternal then
            card:set_eternal(true)
        end
        if (area == G.shop_jokers) or (area == G.pack_cards) then 
            local eternal_perishable_poll = pseudorandom((area == G.pack_cards and 'packetper' or 'etperpoll')..G.GAME.round_resets.ante)
            if G.GAME.modifiers.enable_eternals_in_shop and eternal_perishable_poll > 0.7 then
                card:set_eternal(true)
            elseif G.GAME.modifiers.enable_perishables_in_shop and ((eternal_perishable_poll > 0.4) and (eternal_perishable_poll <= 0.7)) then
                card:set_perishable(true)
            end
            if G.GAME.modifiers.enable_rentals_in_shop and pseudorandom((area == G.pack_cards and 'packssjr' or 'ssjr')..G.GAME.round_resets.ante) > 0.7 then
                card:set_rental(true)
            end
        end

        if edition_append then
            if forced_edition == nil then
                local edition = poll_edition('edi'..(key_append or '')..G.GAME.round_resets.ante)
                card:set_edition(edition)
            else
                card:set_edition(forced_edition)
            end
            check_for_unlock({type = 'have_edition'})
        end
    end
    return card
end

----------------------------------------------
------------MOD CODE END----------------------