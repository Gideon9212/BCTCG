--Marauder Cat
--Scripted by Konstak. Effect 4 by Kooder.
--Effect:
-- (1) When this card attacks, gain 800 ATK during the damage calulation only.
-- (2) If this card is destroyed by battle; Draw a card then banish this card from your GY.
-- (3) If this card is destroyed by a card effect; Add 1 Level 9 or lower monster from your deck to your hand then banish this card from your GY.
-- (4) If you control no monster(s) while there is at least 3 or more Cards in your Banish Zone, You can Special Summon this card from your hand.
local s,id=GetID()
function s.initial_effect(c)
    -- Raise ATK once attack during calulation only (1)
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_ATKCHANGE)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
    e1:SetCode(EVENT_BATTLE_START)
    e1:SetCondition(s.atkcon)
    e1:SetOperation(s.atkop)
    c:RegisterEffect(e1)
    -- If this card is destroyed by battle; Draw a card then banish this card from your GY. (2)
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,2))
    e2:SetCategory(CATEGORY_DRAW)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
    e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
    e2:SetCode(EVENT_DESTROYED)
    e2:SetCondition(s.descon)
    e2:SetTarget(s.destg)
    e2:SetOperation(s.desop)
    c:RegisterEffect(e2)
    -- once destroyed by card effect; add one lvl9 or lower monster from your deck to your hand (3)
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
    e3:SetCode(EVENT_TO_GRAVE)
    e3:SetCondition(s.drecon)
    e3:SetTarget(s.dretg)
    e3:SetOperation(s.dreop)
    c:RegisterEffect(e3)
	-- SP when you have no monsters and alteast 3 in banish
	local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,3))
    e4:SetType(EFFECT_TYPE_FIELD)
    e4:SetCode(EFFECT_SPSUMMON_PROC)
    e4:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e4:SetRange(LOCATION_HAND)
    e4:SetCondition(s.spcon)
    c:RegisterEffect(e4)
end
--(1)
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetAttackedCount()>0
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToBattle() then
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetValue(800)
        e1:SetReset(RESET_PHASE+PHASE_DAMAGE_CAL)
        c:RegisterEffect(e1)
    end
end
--(2)
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local t=e:GetHandler():GetBattleTarget()
	e:SetLabelObject(t)
	return t 
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
    Duel.Draw(tp,1,REASON_EFFECT)
    Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
end
--(3)
function s.drefilter(c)
    return c:IsAbleToHand() and c:IsCode(210660455) or c:IsCode(210660519) or c:IsCode(210660059) or c:IsCode(210660042) or c:IsCode(210660044) or c:IsCode(210660057) or c:IsCode(210660668) or c:IsCode(210660043) or c:IsCode(210660617) or c:IsCode(210660427) or c:IsCode(210660143)
end
function s.drecon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsReason(REASON_EFFECT)
end
function s.dretg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.drefilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.dreop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.drefilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
        Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
    end
end
--(4)
function s.spcon(e,c)
    if c==nil then return true end
    return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_MZONE,0)==0
        and Duel.IsExistingMatchingCard(aux.TRUE,e:GetHandlerPlayer(),LOCATION_REMOVED,0,3,nil)
end