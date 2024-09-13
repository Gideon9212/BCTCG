--Strike Unit R.E.I.
--Scripted by poka-poka
local s,id=GetID()
function s.initial_effect(c)
    -- Effect 3: Only control 1 "Strike Unit R.E.I."
	c:SetUniqueOnField(1,0,id)
    -- Effect 1: Special Summon if opponent controls 3 or more Dragon/Spellcaster monsters
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))  
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY+CATEGORY_DRAW)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetRange(LOCATION_HAND)
    e1:SetCondition(s.spcon1)
    e1:SetOperation(s.spop1)
    c:RegisterEffect(e1)
    -- Effect 2: Special Summon by discarding 2 cards
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))  
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_SPSUMMON_PROC)
    e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,id)
    e2:SetCondition(s.spcon2)
    e2:SetOperation(s.spop2)
    c:RegisterEffect(e2)
    -- Effect 4: Controller Effect Damage becomes LP gain
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD)
    e4:SetCode(EFFECT_REVERSE_DAMAGE)
    e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e4:SetRange(LOCATION_MZONE)
    e4:SetTargetRange(1,0)
	e4:SetValue(s.rev)
	c:RegisterEffect(e4)
    -- Effect 5: Add 1 card from GY if you control 3 or more Machine monsters
    local e5=Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id,2))
    e5:SetCategory(CATEGORY_TOHAND)
    e5:SetType(EFFECT_TYPE_IGNITION)
    e5:SetRange(LOCATION_MZONE)
    e5:SetCountLimit(1)
    e5:SetCondition(s.thcon)
    e5:SetTarget(s.thtg)
    e5:SetOperation(s.thop)
    c:RegisterEffect(e5)
    -- Effect 6: Send 1 monster from Deck to GY, then draw 1 card if you control 3 or more Warrior monsters
    local e6=Effect.CreateEffect(c)
    e6:SetDescription(aux.Stringid(id,3))
    e6:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DRAW)
    e6:SetType(EFFECT_TYPE_IGNITION)
    e6:SetRange(LOCATION_MZONE)
    e6:SetCountLimit(1)
    e6:SetCondition(s.warcon)
    e6:SetTarget(s.wartg)
    e6:SetOperation(s.warop)
    c:RegisterEffect(e6)
    -- Effect 7: During damage calculation, ATK becomes 5000
    local e7=Effect.CreateEffect(c)
    e7:SetDescription(aux.Stringid(id,4))
    e7:SetType(EFFECT_TYPE_QUICK_O)
	e7:SetRange(LOCATION_MZONE)
    e7:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e7:SetCountLimit(1,id,EFFECT_COUNT_CODE_CHAIN)
    e7:SetCondition(s.atkcon)
    e7:SetCost(s.atkcost)
    e7:SetOperation(s.atkop)
    c:RegisterEffect(e7)
end

-- Effect 1 condition: Opponent controls 3 or more Dragon/Spellcaster monsters
function s.spcon1(e,c)
    if c==nil then return true end
    return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.dragon_spellcaster_filter,c:GetControler(),0,LOCATION_MZONE,3,nil)
end
function s.dragon_spellcaster_filter(c)
    return c:IsRace(RACE_DRAGON+RACE_SPELLCASTER)
end
-- Effect 1 operation: Destroy opponent's monsters and draw cards
function s.spop1(e,tp,eg,ep,ev,re,r,rp,c)
    local c=e:GetHandler()
    -- Special Summon the card
    if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
        -- After Special Summon, destroy all face-up opponent monsters
        local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
        local ct=Duel.Destroy(g,REASON_EFFECT)
        -- Draw cards equal to the number of monsters destroyed
        if ct>0 then
            Duel.BreakEffect()
            Duel.Draw(1-tp,ct,REASON_EFFECT)
        end
        -- Prevent damage for the rest of the turn
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetCode(EFFECT_CHANGE_DAMAGE)
        e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        e1:SetTargetRange(0,1)
        e1:SetValue(0)
        e1:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(e1,tp)
        local e2=e1:Clone()
        e2:SetCode(EFFECT_NO_EFFECT_DAMAGE)
        e2:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(e2,tp)
    end
end
-- Effect 2 condition: Discard 2 cards to Special Summon
function s.spcon2(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local rg=Duel.GetMatchingGroup(Card.IsDiscardable,tp,LOCATION_HAND,0,e:GetHandler())
	return aux.SelectUnselectGroup(rg,e,tp,2,2,aux.ChkfMMZ(1),0,c)
end
-- Effect 2 operation: Discard and add 1 card from GY to hand
function s.spop2(e,tp,eg,ep,ev,re,r,rp,c)
    local g=Duel.SelectMatchingCard(tp,s.discardfilter,tp,LOCATION_HAND,0,2,2,c)
    if #g==2 then
        Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
        Duel.BreakEffect()
        if Duel.SpecialSummon(c,SUMMON_TYPE_SPECIAL,tp,tp,false,false,POS_FACEUP)~=0 then
            Duel.BreakEffect()
            local tg=Duel.SelectMatchingCard(tp,Card.IsAbleToHand,tp,LOCATION_GRAVE,0,1,1,nil)
            if #tg>0 then
                Duel.SendtoHand(tg,nil,REASON_EFFECT)
                Duel.ConfirmCards(1-tp,tg)
            end
        end
    end
end
-- Effect 4 : Filter effect damage
function s.rev(e,re,r,rp,rc)
	return (r&REASON_EFFECT)>0
end
-- Effect 5 condition: 3 or more Machine monsters
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetMatchingGroupCount(Card.IsRace,tp,LOCATION_MZONE,0,nil,RACE_MACHINE)>=3
end
-- Effect 5 target and operation
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,LOCATION_GRAVE,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,Card.IsAbleToHand,tp,LOCATION_GRAVE,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
    end
end
-- Effect 6 condition: 3 or more Warrior monsters
function s.warcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetMatchingGroupCount(Card.IsRace,tp,LOCATION_MZONE,0,nil,RACE_WARRIOR)>=3
end
-- Effect 6 target and operation
function s.wartg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.warop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGrave,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoGrave(g,REASON_EFFECT)
        Duel.Draw(tp,1,REASON_EFFECT)
    end
end
-- Effect 7 condition: During damage calculation
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():GetBattleTarget()~=nil
end
-- Effect 7 cost: Send 1 monster from field to GY
function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGrave,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
    Duel.SendtoGrave(g,REASON_COST)
end
-- Effect 7 operation: ATK becomes 5000
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_SET_ATTACK_FINAL)
        e1:SetValue(5000)
        e1:SetReset(RESET_PHASE+PHASE_DAMAGE_CAL)
        c:RegisterEffect(e1)
        -- Destroy during end phase
        local e2=Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e2:SetCode(EVENT_PHASE+PHASE_END)
        e2:SetCountLimit(1)
        e2:SetOperation(s.desop)
        e2:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(e2,tp)
    end
end
-- Destroy during end phase
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end