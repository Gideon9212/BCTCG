--Jizo's Wedding Cake
--Scripted by Konstak
--Effect
--(1) If you control a monster that is not a WIND Attribute monster, destroy this card.
--(2) If you control a WIND Attribute monster, you can Special Summon this card from your hand.
--(3) If an attack is declared involving this card and a Warrior monster: Banish that Warrior monster.
--(4) You can only use 1 of these effects of "Jizo's Wedding Cake" per turn, and only once that turn.
--* You can Target 1 card on the field (Ignition); Negate its effects.
--* If this card is sent to the GY: You can target 1 card on the field; Negate its effects. You cannot activate this effect if you control a non WIND monster.
--* If this card is destroyed by a card effect: You can add 1 "Lost & Found" from your Deck or GY to your hand.
local s,id=GetID()
function s.initial_effect(c)
    --self destroy (1)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCode(EFFECT_SELF_DESTROY)
    e1:SetCondition(s.sdcon)
    c:RegisterEffect(e1)
    --Special Summon this card (2)
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e2:SetCode(EFFECT_SPSUMMON_PROC)
    e2:SetRange(LOCATION_HAND)
    e2:SetCondition(s.spcon)
    c:RegisterEffect(e2)
    --Banish Warrior monster when battling (3)
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,0))
    e3:SetCategory(CATEGORY_REMOVE)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
    e3:SetCode(EVENT_BATTLE_START)
    e3:SetTarget(s.bntg)
    e3:SetOperation(s.bnop)
    c:RegisterEffect(e3)
    --Target 1 card on the field; negate its effects (4.1)
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,1))
    e4:SetCategory(CATEGORY_DISABLE)
    e4:SetType(EFFECT_TYPE_IGNITION)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCountLimit(1,id)
    e4:SetTarget(s.destg)
    e4:SetOperation(s.desop)
    c:RegisterEffect(e4)
    --When sent to GY, target 1 card on the field; negate its effects (4.2)
    local e5=Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id,1))
    e5:SetCategory(CATEGORY_DISABLE)
    e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e5:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
    e5:SetCode(EVENT_TO_GRAVE)
    e5:SetCountLimit(1,id)
    e5:SetCondition(s.descon)
    e5:SetTarget(s.destg)
    e5:SetOperation(s.desop)
    c:RegisterEffect(e5)
    --If destroyed by card effect, add Lost & Found card (4.3)
    local e6=Effect.CreateEffect(c)
    e6:SetDescription(aux.Stringid(id,2))
    e6:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e6:SetProperty(EFFECT_FLAG_DELAY)
    e6:SetCode(EVENT_DESTROYED)
    e6:SetCountLimit(1,id)
    e6:SetCondition(s.thcon)
    e6:SetTarget(s.thtg)
    e6:SetOperation(s.thop)
    c:RegisterEffect(e6)
end
--Self Destroy Function
function s.sdfilter(c)
    return c:IsMonster() and c:IsAttributeExcept(ATTRIBUTE_WIND)
end
function s.sdcon(e)
    return Duel.IsExistingMatchingCard(s.sdfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
--Filter and Special summon function
function s.spfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WIND)
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=e:GetHandlerPlayer()
	return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_MZONE,0,1,nil) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
end
--Banish Warrior monster function
function s.bntg(e,tp,eg,ep,ev,re,r,rp,chk)
    local bc=e:GetHandler():GetBattleTarget()
    if chk==0 then return bc and bc:IsFaceup() and bc:IsRace(RACE_WARRIOR) end
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,bc,1,0,0)
end
function s.bnop(e,tp,eg,ep,ev,re,r,rp)
    local bc=e:GetHandler():GetBattleTarget()
    if bc:IsRelateToBattle() then
    Duel.Remove(bc,POS_FACEUP,REASON_EFFECT)
    end
end
--Target 1 card on the field; negate its effects
function s.desfilter(c)
    return c:IsMonster() and not c:IsAttributeExcept(ATTRIBUTE_WIND)
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsOnField() and chkc:IsNegatable() end
    if chk==0 then return Duel.IsExistingTarget(Card.IsNegatable,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE)
    local g=Duel.SelectTarget(tp,Card.IsNegatable,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) then
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        e1:SetCode(EFFECT_DISABLE)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        tc:RegisterEffect(e1)
        local e2=Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        e2:SetCode(EFFECT_DISABLE_EFFECT)
        e2:SetValue(RESET_TURN_SET)
        e2:SetReset(RESET_EVENT+RESETS_STANDARD)
        tc:RegisterEffect(e2)
        if tc:IsType(TYPE_TRAPMONSTER) then
            local e3=Effect.CreateEffect(c)
            e3:SetType(EFFECT_TYPE_SINGLE)
            e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
            e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
            e3:SetReset(RESET_EVENT+RESETS_STANDARD)
            tc:RegisterEffect(e3)
        end
    end
end
--Functions for effect 4.3 (Add Lost & Found when destroyed)
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsReason(REASON_EFFECT)
end
function s.thfilter(c)
    return (c:IsCode(210663007) or c:IsCode(210663005) or c:IsCode(210663009) or c:IsCode(210663008) or c:IsCode(210663004)) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end