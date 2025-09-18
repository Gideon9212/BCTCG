--Awakened Bahamut
--Scripted by Kooder
--Effects:
-- This card can only be Ritual Summoned with the Ritual Spell Card, "Awaken thy Cat!".
-- If this card is Ritual Summoned using only FIRE Dragon Monster's, apply the following effect when Summoned; Destroy All monster(s) your opponent controls.
-- This card gains 400 ATK/DEF for each monster in your GY.
-- This card cannot attack directly.
-- At the start of your Battle Phase, You can Target 1 monster in your opponent's GY; Special Summon it in face-up Attack Position on your opponent's side of the field.
-- When this card destroys a monster by battle; Add 1 monster from your GY to the bottom of your deck (You do not shuffle your deck).
-- If this Ritual Summoned card is destroyed by a card effect; Destroy 1 card your opponent controls.
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
--  When summoned with only FIRE Dragon Monsters, destroy all opponent's monsters
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_MATERIAL_CHECK)
	e1:SetValue(s.matcheck)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(s.condition)
	e2:SetTarget(s.target)
	e2:SetOperation(s.activate)
	c:RegisterEffect(e2)
-- 400 ATK/DEF for each monster in your GY
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetValue(s.value)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
    e4:SetCode(EFFECT_UPDATE_DEFENSE)
    c:RegisterEffect(e4)
-- Cannot attack directly
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	c:RegisterEffect(e5)
-- Special summon on your opponent's side of the field
	local e6=Effect.CreateEffect(c)
    e6:SetDescription(aux.Stringid(id,1))
    e6:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e6:SetCode(EVENT_PHASE|PHASE_BATTLE_START)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCountLimit(1)
    e6:SetProperty(EFFECT_FLAG_DELAY)
    e6:SetCondition(s.spcon)
    e6:SetTarget(s.sptg)
	e6:SetOperation(s.spop)
    c:RegisterEffect(e6)
-- Add 1 monster from your GY to the bottom of your deck
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(id,2))
	e7:SetCategory(CATEGORY_TODECK)
	e7:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e7:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e7:SetCode(EVENT_BATTLE_DESTROYING)
	e7:SetCondition(s.rccon)
	e7:SetTarget(s.rctg)
	e7:SetOperation(s.rcop)
	c:RegisterEffect(e7)
-- Destroy 1 card your opponent controls
	local e8=Effect.CreateEffect(c)
	e8:SetDescription(aux.Stringid(id,3))
	e8:SetCategory(CATEGORY_DESTROY)
	e8:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e8:SetCode(EVENT_DESTROYED)
	e8:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e8:SetRange(LOCATION_MZONE)
	e8:SetCondition(s.descon)
	e8:SetTarget(s.destg)
	e8:SetOperation(s.desop)
	c:RegisterEffect(e8)
end
function s.fdfilter(c)
	return c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_FIRE)
end
function s.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.rcfilter(c)
	return c:IsAbleToDeck() and c:IsMonster()
end
function s.matcheck(e,c)
	local c=e:GetHandler()
	local g=c:GetMaterial()
	local lg=g:Filter(s.fdfilter,nil,nil)
	if #g==#lg then
		c:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD&~(RESET_TOFIELD|RESET_LEAVE|RESET_TEMP_REMOVE),0,1)
	end
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsRitualSummoned() and c:GetFlagEffect(id)~=0
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,#sg,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	Duel.Destroy(sg,REASON_EFFECT)
end
function s.value(e,c)
	return Duel.GetMatchingGroupCount(Card.IsMonster,c:GetControler(),LOCATION_GRAVE,0,nil)*400
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsTurnPlayer(tp)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.spfilter,tp,0,LOCATION_GRAVE,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
    if ft<=0 then return end
    local g=Duel.GetMatchingGroup(s.spfilter,tp,0,LOCATION_GRAVE,nil,e,tp)
    if #g>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local sg=g:Select(tp,1,1,nil)
        Duel.SpecialSummon(sg,0,tp,1-tp,false,false,POS_FACEUP_ATTACK)
    end
end
function s.rccon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return c:IsRelateToBattle()
end
function s.rctg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.rcfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.rcfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,s.rcfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
function s.rcop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SendtoDeck(tc,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
	end
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsRitualSummoned() and c:IsReason(REASON_EFFECT)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end