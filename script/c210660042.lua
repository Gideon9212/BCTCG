--Ice Cat
--Scripted by Konstak during beta, Scripted by Poka. Strings fixed by Gideon. Effect 7 by Kooder.
--Effect
-- (1) Cannot be Normal Summoned/Set. Can only be Special Summoned (from your hand) while you control no monsters and cannot be Special Summoned by other means.
-- (2) During either player's turn (Quick): You can Target 1 card on the field and banish this card on the field; negate that target until the end of this turn. You can only use this effect of "Ice Cat" once per turn. During your opponent's end phase after using this effect, move this card from your banish zone to GY.
-- (3) When this card is attacked; Double this card's attack until end of damage calculation.
-- (4) If you control 3 or more monsters, Destroy this card.
-- (5) If this card is destroyed while on the field; Banish it.
-- (6) You can banish this card from your GY (Ignition); Special Summon 1 "Lesser Demon Cat" from your Deck to the field. Increase it's attack by 1000 when summoned this way.
-- (7) If there is 10 or more cards in your banished face-up: You can pay 1000 LPs; Add this card from your banished to your Hand. You can only use this effect of "Ice Cat" once per turn.
local s,id=GetID()
function s.initial_effect(c)
    c:EnableUnsummonable()
	--Cannot be SS by other ways other then it's own effect via above and this function
	local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e0:SetCode(EFFECT_SPSUMMON_CONDITION)
    e0:SetValue(aux.FALSE)
    c:RegisterEffect(e0)
    --Special Summon this card (1)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetRange(LOCATION_HAND)
    e1:SetCondition(s.spcon)
    c:RegisterEffect(e1)
    --either player's turn (Quick): Target 1 card on the field (2)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(s.selfbanishcosttogy)
	e2:SetTarget(s.negtg)
	e2:SetOperation(s.negop)
	c:RegisterEffect(e2)
    --if this card is attacked (3)
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
    e3:SetCode(EVENT_BE_BATTLE_TARGET)
    e3:SetCondition(s.atkcon)
    e3:SetOperation(s.atkop)
    c:RegisterEffect(e3)
    --3 or more cards you control. Destroy this card (4)
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE)
    e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e4:SetRange(LOCATION_MZONE)
    e4:SetTargetRange(LOCATION_MZONE,0)
    e4:SetCode(EFFECT_SELF_DESTROY)
    e4:SetCondition(s.drcon)
    c:RegisterEffect(e4)
    --If this card is destroyed while on the field (5)
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,3))
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_DELAY)
	e5:SetCondition(s.leavecon)
	e5:SetValue(LOCATION_REMOVED)
	c:RegisterEffect(e5)
	-- Banish from GY Spsummon Lesser demon
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,2))
	e6:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e6:SetType(EFFECT_TYPE_IGNITION)
	e6:SetRange(LOCATION_GRAVE)
	e6:SetCountLimit(1)
	e6:SetCost(aux.bfgcost)
	e6:SetTarget(s.sptg2)
	e6:SetOperation(s.spop2)
	c:RegisterEffect(e6)
	-- If 10 or more banished face-up, add this from your banish to hand
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(id,4))
	e7:SetCategory(CATEGORY_TOHAND)
	e7:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e7:SetType(EFFECT_TYPE_IGNITION)
	e7:SetRange(LOCATION_REMOVED)
	e7:SetCountLimit(1)
	e7:SetCost(s.thcost)
	e7:SetCondition(s.thcon)
	e7:SetTarget(s.thtg)
	e7:SetOperation(s.thop)
	c:RegisterEffect(e7)
end
--Special Summon Function
function s.spcon(e,c)
    if c==nil then return true end
    local tp=e:GetHandlerPlayer()
    return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0,nil)==0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
end
--(2)
function s.selfbanishcosttogy(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return Duel.IsPlayerCanRemove(tp,c) end
    if Duel.Remove(c,POS_FACEUP,REASON_COST)~=0 then
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e1:SetCode(EVENT_PHASE+PHASE_END)
        e1:SetCountLimit(1)
        e1:SetCondition(s.retcon)
        e1:SetOperation(s.retop)
        e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
        Duel.RegisterEffect(e1,tp)
    end
end
function s.retcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetTurnPlayer()~=tp 
end
function s.retop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsLocation(LOCATION_REMOVED) then
        Duel.SendtoGrave(c,REASON_EFFECT+REASON_RETURN)
    end
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() and chkc:IsNegatable() end
    if chk==0 then return Duel.IsExistingTarget(Card.IsNegatable,tp,0,LOCATION_ONFIELD,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE)
    local g=Duel.SelectTarget(tp,Card.IsNegatable,tp,0,LOCATION_ONFIELD,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if tc and ((tc:IsFaceup() and not tc:IsDisabled()) or tc:IsType(TYPE_TRAPMONSTER)) and tc:IsRelateToEffect(e) then
        Duel.NegateRelatedChain(tc,RESET_TURN_SET)
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        e1:SetCode(EFFECT_DISABLE)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        tc:RegisterEffect(e1)
        local e2=Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        e2:SetCode(EFFECT_DISABLE_EFFECT)
        e2:SetValue(RESET_TURN_SET)
        e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        tc:RegisterEffect(e2)
        if tc:IsType(TYPE_TRAPMONSTER) then
            local e3=Effect.CreateEffect(c)
            e3:SetType(EFFECT_TYPE_SINGLE)
            e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
            e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
            e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
            tc:RegisterEffect(e3)
        end
    end
end
--(3)
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler()==Duel.GetAttackTarget()
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToBattle() then
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetValue(c:GetAttack())
        e1:SetReset(RESET_PHASE+PHASE_DAMAGE_CAL)
        c:RegisterEffect(e1)
    end
end
--(4)
function s.countfilter(c)
	return c:IsFaceup() and c:IsMonster()
end
function s.drcon(e)
	return Duel.IsExistingMatchingCard(s.countfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,3,nil)
end
--(5)
function s.leavecon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsReason(REASON_DESTROY)
end
--e7
function s.lesserdemonfilter(c,e,tp)
    return c:IsCode(210660044) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
        and Duel.IsExistingMatchingCard(s.lesserdemonfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    local tc=Duel.SelectMatchingCard(tp,s.lesserdemonfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()
    if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
        -- Increase ATK by 1000
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetValue(1000)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        tc:RegisterEffect(e1)
    end
end
--(7)
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.CheckLPCost(tp,1000) end
    Duel.PayLPCost(tp,1000)
end
function s.refilter(c,e,tp)
    return c:IsFaceup()
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.refilter,e:GetHandlerPlayer(),LOCATION_REMOVED,0,10,nil)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,c)
	end
end