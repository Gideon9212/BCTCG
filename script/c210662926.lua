-- Dark Seal
--Scripted by Konstak
local s,id=GetID()
function s.initial_effect(c)
    c:EnableUnsummonable()
    -- Special Summon this card
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetRange(LOCATION_HAND)
    e1:SetCondition(s.spcon)
    c:RegisterEffect(e1)
    -- Special Summon Tribute
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetRange(LOCATION_HAND)
    e2:SetCode(EFFECT_SPSUMMON_PROC)
    e2:SetCondition(s.spcon2)
    e2:SetTarget(s.sptg2)
    e2:SetOperation(s.spop2)
    c:RegisterEffect(e2)
    --Slow Ability
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
    e3:SetCode(EVENT_ATTACK_ANNOUNCE)
    e3:SetCondition(s.slowcon)
    e3:SetOperation(s.slowop)
    c:RegisterEffect(e3)
    --Opponent drop Money draw
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,3))
    e4:SetCategory(CATEGORY_DRAW)
    e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
    e4:SetCode(EVENT_TO_GRAVE)
    e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e4:SetOperation(s.drop)
    c:RegisterEffect(e4)
end
--Special Summon SS Function
function s.spcon(e,c)
    if c==nil then return true end
    local tp=e:GetHandlerPlayer()
    return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0,nil)==0 or Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsAttribute,ATTRIBUTE_DARK),c:GetControler(),LOCATION_MZONE,0,1,nil) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
end
--Special Summon Tribute Function
function s.blackfilter(c)
    return c:IsAttribute(ATTRIBUTE_DARK)
end
function s.spcon2(e,c)
    if c==nil then return true end
    return Duel.CheckReleaseGroup(c:GetControler(),s.blackfilter,1,false,1,true,c,c:GetControler(),nil,false,nil,nil)
end
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,c)
    local g=Duel.SelectReleaseGroup(tp,s.blackfilter,1,1,false,true,true,c,nil,nil,false,nil,nil)
    if g then
        g:KeepAlive()
        e:SetLabelObject(g)
    return true
    end
    return false
end
function s.spop2(e,tp,eg,ep,ev,re,r,rp,c)
    local g=e:GetLabelObject()
    if not g then return end
    Duel.Release(g,REASON_COST)
    g:DeleteGroup()
end
--Slow Ability Function
function s.slowcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsRelateToBattle()
end
function s.slowop(e,tp,eg,ep,ev,re,r,rp)
    local effp=e:GetHandler():GetControler()
    local c=e:GetHandler()
    if c:IsFaceup() and c:IsRelateToEffect(e) and Duel.TossCoin(tp,1)==COIN_HEADS then
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetCode(EFFECT_CANNOT_BP)
        e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        e1:SetTargetRange(0,1)
        if Duel.GetTurnPlayer()==effp then
            e1:SetLabel(Duel.GetTurnCount())
            e1:SetCondition(s.skipcon)
            e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,2)
        else
            e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,1)
        end
        Duel.RegisterEffect(e1,effp)
        Duel.NegateAttack()
    end
end
function s.skipcon(e)
    return Duel.GetTurnCount()~=e:GetLabel()
end
--Draw Function
function s.drop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if Duel.IsPlayerCanDraw(1-tp,1) then
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_FIELD)
        e1:SetRange(LOCATION_GRAVE)
        e1:SetCode(EVENT_PHASE+PHASE_DRAW)
        e1:SetReset(RESET_PHASE+PHASE_END,2)
        e1:SetCountLimit(1)
        e1:SetOperation(s.drawop)
        c:RegisterEffect(e1)
    end
end
function s.drawop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Draw(1-tp,1,REASON_EFFECT)
end