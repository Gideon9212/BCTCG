-- Heavenly Rajakong
--Scripted By Konstak
local s,id=GetID()
function s.initial_effect(c)
    c:EnableUnsummonable()
    --special summon tribute
    local e0=Effect.CreateEffect(c)
    e0:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e0:SetType(EFFECT_TYPE_FIELD)
    e0:SetRange(LOCATION_HAND)
    e0:SetCode(EFFECT_SPSUMMON_PROC)
    e0:SetCondition(s.spcon)
    e0:SetTarget(s.sptg)
    e0:SetOperation(s.spop)
    c:RegisterEffect(e0)
    --No battle damage
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_NO_BATTLE_DAMAGE)
    c:RegisterEffect(e1)
    --Avoid Battle damage
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
    e2:SetValue(1)
    c:RegisterEffect(e2)
    --Guaranteed Wave
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,0))
    e3:SetCategory(CATEGORY_DESTROY)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
    e3:SetCode(EVENT_ATTACK_ANNOUNCE)
    e3:SetCondition(s.wavecon)
    e3:SetTarget(s.wavetg)
    e3:SetOperation(s.waveop)
    c:RegisterEffect(e3)
    --Immune to Wave, Surge, Single Attack
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE)
    e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e4:SetValue(1)
    c:RegisterEffect(e4)
end
function s.angelfilter(c)
    return c:IsFaceup() and c:IsCode(210662115)
end
function s.spcon(e,c)
    if c==nil then return true end
    return Duel.CheckReleaseGroup(c:GetControler(),s.angelfilter,1,false,1,true,c,c:GetControler(),nil,false,nil,nil)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,c)
    local g=Duel.SelectReleaseGroup(tp,s.angelfilter,1,1,false,true,true,c,nil,nil,false,nil,nil)
    if g then
        g:KeepAlive()
        e:SetLabelObject(g)
    return true
    end
    return false
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
    local g=e:GetLabelObject()
    if not g then return end
    Duel.Release(g,REASON_COST)
    g:DeleteGroup()
end
--Guaranteed Wave Function
function s.wavecon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetTurnPlayer()==tp and e:GetHandler():GetBattleTarget()~=nil
end
function s.wavetg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
end
function s.waveop(e,tp,eg,ep,ev,re,r,rp)
    if not e:GetHandler():IsRelateToEffect(e) then return end
    local d1=6
    while d1>3 do
        d1=Duel.TossDice(tp,1)
    end
    local tc=Duel.GetFieldCard(1-tp,LOCATION_MZONE,d1)
    if tc then
        Duel.Destroy(tc,REASON_EFFECT)
    end
end
