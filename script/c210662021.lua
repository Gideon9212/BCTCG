-- Ms Sign
--Scripted By Konstak
local s,id=GetID()
function s.initial_effect(c)
    --Activate
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetHintTiming(0,TIMING_END_PHASE)
    c:RegisterEffect(e1)
    --summon count limit
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCode(EFFECT_CANNOT_SUMMON)
    e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e2:SetTargetRange(1,1)
    e2:SetTarget(s.limittg)
    c:RegisterEffect(e2)
    local e3=e2:Clone()
    e3:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
    c:RegisterEffect(e3)
    local e4=e2:Clone()
    e4:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    c:RegisterEffect(e4)
    local e5=e2:Clone()
    e5:SetCode(EFFECT_CANNOT_MSET)
    c:RegisterEffect(e5)
    --counter
    local et=Effect.CreateEffect(c)
    et:SetType(EFFECT_TYPE_FIELD)
    et:SetCode(EFFECT_LEFT_SPSUMMON_COUNT)
    et:SetRange(LOCATION_SZONE)
    et:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    et:SetTargetRange(1,1)
    et:SetValue(s.countval)
    c:RegisterEffect(et)
end
function s.limittg(e,c,tp)
	local t1,t2,t3=Duel.GetActivityCount(tp,ACTIVITY_SUMMON,ACTIVITY_FLIPSUMMON,ACTIVITY_SPSUMMON)
	return t1+t2+t3>=1
end
function s.countval(e,re,tp)
	local t1,t2,t3=Duel.GetActivityCount(tp,ACTIVITY_SUMMON,ACTIVITY_FLIPSUMMON,ACTIVITY_SPSUMMON)
	if t1+t2+t3>=1 then return 0 else return 1-t1-t2-t3 end
end
