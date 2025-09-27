--Izanami of Dusk
--Scripted by Kooder with some from Izanagi
--Effects:
-- Cannot be Normal Summoned/Set. Must be Special Summoned (from your hand, GY, or Banish zone) by banishing 1 Level 12 or higher monster OR link 3 or higher monster except "Izanami of Dusk" from your GY.
-- Unaffected by other cards' effects.
-- Cannot be targeted by card effects.
-- Any battle damage to your opponent from any monster becomes 1000 damage instead.
-- This card loses 200 ATK for each card in both player's GY. This effect cannot be negated.
-- If any card on the field inflicts battle damage: Each Player adds the top card from their GY to the bottom of their Deck. This effect cannot be negated.
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
-- SP Summon by banishing
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_SPSUMMON_PROC)
    e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e2:SetRange(LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED)
    e2:SetCondition(s.spcon)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)
-- Unaffected by other cards
	local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetCode(EFFECT_IMMUNE_EFFECT)
    e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e3:SetRange(LOCATION_MZONE)
    e3:SetValue(s.efilter)
    c:RegisterEffect(e3)
-- Cannot be targeted by effects
	local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE)
    e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e4:SetValue(1)
	c:RegisterEffect(e4)
-- Battle damage to opponent becomes 1000
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e5:SetRange(LOCATION_MZONE)
	e5:SetTargetRange(0,1)
	e5:SetValue(1000)
	c:RegisterEffect(e5)
-- Loses 200 ATK for each card in both GY
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE)
	e6:SetCode(EFFECT_UPDATE_ATTACK)
	e6:SetRange(LOCATION_MZONE)
	e6:SetValue(s.val)
	c:RegisterEffect(e6)
-- Top GY card to the bottom of the deck
	local e7=Effect.CreateEffect(c)
	e7:SetCategory(CATEGORY_TODECK)
	e7:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e7:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e7:SetCode(EVENT_BATTLE_DAMAGE)
	e7:SetRange(LOCATION_MZONE)
	e7:SetCondition(s.tdcon)
	e7:SetTarget(s.tdtg)
	e7:SetOperation(s.tdop)
	c:RegisterEffect(e7)
end
function s.spfilter(c,tp)
    return (c:IsLevelAbove(12) or (c:IsType(TYPE_LINK) and c:GetLink()>=3)) 
        and c:IsAbleToRemoveAsCost() and not c:IsCode(id)
end
function s.spcon(e,c)
    if c==nil then return true end
    local tp=c:GetControler()
    local code=c:GetCode()
-- Exclude the card itself that is attempting to be Special Summoned
    return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler(),code)
		and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
    local code=c:GetCode()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
-- Select a Level 12 or higher monster from the Graveyard, including this card copies but not the one activating the effect (prevent derp moment)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler(),code)
    Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.efilter(e,te)
    return te:GetHandler()~=e:GetHandler()
end
function s.val(e,c)
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_GRAVE,LOCATION_GRAVE)*-200
end
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp and eg:GetFirst():IsControler(tp)
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local tc1=Duel.GetFieldCard(tp,LOCATION_GRAVE,Duel.GetFieldGroupCount(tp,LOCATION_GRAVE,0)-1)
	local tc2=Duel.GetFieldCard(1-tp,LOCATION_GRAVE,Duel.GetFieldGroupCount(1-tp,LOCATION_GRAVE,0)-1)
	if tc1 or tc2 then
		Duel.SetOperationInfo(0,CATEGORY_TODECK,tc,1,0,0)
	end
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local tc1=Duel.GetFieldCard(tp,LOCATION_GRAVE,Duel.GetFieldGroupCount(tp,LOCATION_GRAVE,0)-1)
	local tc2=Duel.GetFieldCard(1-tp,LOCATION_GRAVE,Duel.GetFieldGroupCount(1-tp,LOCATION_GRAVE,0)-1)
	if tc1 then
		Duel.SendtoDeck(tc1,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
	end
	if tc2 then
		Duel.SendtoDeck(tc2,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
	end
end