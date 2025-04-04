--Sanada Yukimura
--Scripted By poka-poka
local s,id=GetID()
function s.initial_effect(c) 
    -- Effect 1: Special summon when no monster or only FIRE monster
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE + EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetRange(LOCATION_HAND)
    e1:SetCondition(s.spcon)
	e1:SetOperation (s.spop)
    c:RegisterEffect(e1)
    -- Effect 3: Destroy 1 monster your opponent controls when this card is Summoned
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,0))
    e3:SetCategory(CATEGORY_DESTROY)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
    e3:SetCode(EVENT_SUMMON_SUCCESS)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
--    e3:SetCondition(s.descon)
    e3:SetTarget(s.destg)
    e3:SetOperation(s.desop)
    c:RegisterEffect(e3)
    local e3a=e3:Clone()
    e3a:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e3a)
    local e3b=e3:Clone()
    e3b:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
    c:RegisterEffect(e3b)
    -- Effect 4: When sent to GY, send 1 FIRE Warrior from Deck to GY
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,1))
    e4:SetCategory(CATEGORY_TOGRAVE)
    e4:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e4:SetCode(EVENT_TO_GRAVE)
    e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP + EFFECT_FLAG_DELAY)
    e4:SetTarget(s.ssptg)
    e4:SetOperation(s.sspop)
    c:RegisterEffect(e4)
    -- Effect 5: Gain ATK when a monster is destroyed by battle
    local e5=Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e5:SetRange(LOCATION_MZONE)
    e5:SetCode(EVENT_BATTLE_DESTROYED)
    e5:SetCondition(s.batcon)
    e5:SetOperation(s.batop)
    c:RegisterEffect(e5)
	--
	local e6=Effect.CreateEffect(c)
    e6:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e6:SetCode(EVENT_EQUIP)
    e6:SetRange(LOCATION_MZONE)
    e6:SetCountLimit(1,id)
    e6:SetCondition(s.eqcon)
    e6:SetTarget(s.eqtg)
    e6:SetOperation(s.eqop)
    c:RegisterEffect(e6)
end

-- Condition for Special Summon
function s.spcon(e, c)
    if c==nil then return true end
    local tp=c:GetControler()
    local hasNonFireMonster = Duel.IsExistingMatchingCard(function(mc) return not mc:IsAttribute(ATTRIBUTE_FIRE) end, tp, LOCATION_MZONE, 0, 1, nil)
    return Duel.GetFieldGroupCount(tp, LOCATION_MZONE, 0) == 0 or not hasNonFireMonster
end
-- Operation function to restrict other summons
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
    -- Apply restriction for FIRE Warrior Monsters only
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_SUMMON)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
    e1:SetRange(LOCATION_MZONE)
    e1:SetTargetRange(1,0)
    e1:SetTarget(s.summon_limit)
    e1:SetReset(RESET_PHASE+PHASE_END)
    c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    c:RegisterEffect(e2)
    local e3=e1:Clone()
    e3:SetCode(EFFECT_CANNOT_MSET)
    c:RegisterEffect(e3)
end
-- Restricting summon to FIRE Warrior Monsters
function s.summon_limit(e,c,sump,sumtype,sumpos,targetp,se)
    return not c:IsAttribute(ATTRIBUTE_FIRE) or not c:IsRace(RACE_WARRIOR)
end
-- Destroy 1 opponent monster on summon
--function s.descon(e,tp,eg,ep,ev,re,r,rp)
--    local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_MONSTER)
--    if g:IsExists(function(c) return not c:IsAttribute(ATTRIBUTE_FIRE) end,1,nil) then
--        return false
--    else
--        return true
--    end
--end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingTarget(Card.IsDestructable,tp,0,LOCATION_MZONE,1,nil) end
    local g=Duel.SelectTarget(tp,Card.IsDestructable,tp,0,LOCATION_MZONE,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) then
        Duel.Destroy(tc,REASON_EFFECT)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1)
	e1:SetValue(1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
    end
end
-- Send 1 FIRE Warrior from Deck to GY
function s.ssptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk == 0 then return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
        and Duel.IsExistingMatchingCard(s.sgfilter, tp, LOCATION_DECK, 0, 1, nil) end
    Duel.SetOperationInfo(0, CATEGORY_TOGRAVE, nil, 1, tp, LOCATION_DECK)
end
function s.sspop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
    local g = Duel.SelectMatchingCard(tp, s.sgfilter, tp, LOCATION_DECK, 0, 1, 1, nil)
    if #g > 0 then
        Duel.SendtoGrave(g, REASON_EFFECT)
    end
end
function s.sgfilter(c)
    return c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsAbleToGrave()
end
-- Gain ATK when a monster is destroyed by battle
function s.batcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(Card.IsType, 1, nil, TYPE_MONSTER) and eg:IsExists(Card.IsReason, 1, nil, REASON_BATTLE)
end
function s.batop(e,tp,eg,ep,ev,re,r,rp)
    local c = e:GetHandler()
    if c:IsFaceup() then
        local ct = eg:FilterCount(Card.IsType, nil, TYPE_MONSTER)
        c:UpdateAttack(ct * 400)
    end
end
-- Condition: Check if this card is being equipped with an Equip Spell
function s.equiptothiscard(c,tc)
    return c:IsType(TYPE_SPELL) and c:IsType(TYPE_EQUIP) and c:GetEquipTarget()==tc
end
function s.eqcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.equiptothiscard,1,nil,e:GetHandler())
end
-- Target: Search for an Equip Spell in the Deck
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_DECK,0,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- Filter: Find Equip Spells in the Deck
function s.eqfilter(c)
    return c:IsType(TYPE_EQUIP) and c:IsAbleToHand()
end
-- Operation: Add the Equip Spell to the hand
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local g = Duel.SelectMatchingCard(tp,s.eqfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end