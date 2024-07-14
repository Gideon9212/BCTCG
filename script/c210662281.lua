-- Festival Ms.Sign
local s,id=GetID()
function s.initial_effect(c)
    --activate
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_ACTIVATE)
    e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetHintTiming(0,TIMING_END_PHASE)
    c:RegisterEffect(e0)
    --cannot attack
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_CANNOT_ATTACK)
    e2:SetRange(LOCATION_SZONE)
    e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
    e2:SetTarget(s.atktarget)
    c:RegisterEffect(e2)
end
function s.atktarget(e,c)
	return c:GetLevel()<=4
end
