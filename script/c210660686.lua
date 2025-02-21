--Goddes of Light Sirius
--Scripted by poka-poka
local s,id=GetID()
function s.initial_effect(c)
    -- Effect 1: Special Summon from hand if LP difference is 3000 or more
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetRange(LOCATION_HAND)
    e1:SetCondition(s.spcon1)
    c:RegisterEffect(e1)
    -- Effect 2: Special Summon from GY if LP is 5000 or Lower (Once per turn)
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,id)
    e2:SetCondition(s.spcon2)
    e2:SetTarget(s.sptg2)
    e2:SetOperation(s.spop2)
    c:RegisterEffect(e2)
    -- Effect 3: Negate DARK monster effects on field or GY
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_DISABLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE)
	e3:SetTarget(s.negtg)
	c:RegisterEffect(e3)  
    -- Effect 4: Opponent Cannot target other cards for effect target while LP is 6000 or higher
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD)
    e4:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e4:SetRange(LOCATION_MZONE)
    e4:SetTargetRange(LOCATION_ONFIELD,0)
    e4:SetCondition(s.tarcon)
    e4:SetTarget(s.tgval)
    e4:SetValue(aux.tgoval)
    c:RegisterEffect(e4)
    -- Effect 5: Heal 500 LP every standby phase for each card on the field
    local e5=Effect.CreateEffect(c)
    e5:SetCategory(CATEGORY_RECOVER)
    e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e5:SetCode(EVENT_PHASE+PHASE_STANDBY)
    e5:SetRange(LOCATION_MZONE)
    e5:SetCountLimit(1)
    e5:SetTarget(s.healtg)
    e5:SetOperation(s.healop)
    c:RegisterEffect(e5)
    -- Effect 6: Halve ATK of opponents monsters during opponents Battle Phase (Once per duel)
    local e6=Effect.CreateEffect(c)
    e6:SetDescription(aux.Stringid(id,2))
    e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e6:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
    e6:SetRange(LOCATION_MZONE)
    e6:SetCondition(s.atkcon)
    e6:SetOperation(s.atkop)
    e6:SetCountLimit(1,id+1,EFFECT_COUNT_CODE_DUEL)
    c:RegisterEffect(e6)
end

-- Special Summon from hand if LP difference is 2000 or more
function s.spcon1(e,c)
    if c==nil then return true end
    local tp=c:GetControler()
    return Duel.GetLP(1-tp) - Duel.GetLP(tp) >= 3000
end
-- Special Summon from GY if LP is 2000 or Lower (Once per turn)
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetLP(tp)<=5000
end
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- Negate DARK monster effects on field or GY
function s.negtg(e,c)
    return c:IsAttribute(ATTRIBUTE_DARK)
end
-- Cannot target other cards while LP is 6000 or higher
function s.tarcon(e)
    return Duel.GetLP(e:GetHandlerPlayer())>=6000
end
function s.tgval(e,c)
    return c~=e:GetHandler()
end
-- Recover 500 LP for each card on the field
function s.healtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk == 0 then return true end
    local ct = Duel.GetFieldGroupCount(tp, LOCATION_ONFIELD, LOCATION_ONFIELD)
    Duel.SetTargetPlayer(tp)
    Duel.SetTargetParam(ct * 500) 
    Duel.SetOperationInfo(0, CATEGORY_RECOVER, nil, 0, tp, ct * 500)
end
function s.healop(e,tp,eg,ep,ev,re,r,rp)
    local p = Duel.GetChainInfo(0, CHAININFO_TARGET_PLAYER)
    local ct = Duel.GetFieldGroupCount(tp, LOCATION_ONFIELD, LOCATION_ONFIELD)
    Duel.Recover(p, ct * 500, REASON_EFFECT)
end
-- Double ATK of monsters during Battle Phase (Once per duel)
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetTurnPlayer()~=tp
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(Card.IsFaceup,1-tp,LOCATION_MZONE,0,nil)
    local c=e:GetHandler()
    for tc in aux.Next(g) do
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_SET_ATTACK_FINAL)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        e1:SetValue(tc:GetAttack()/2)
        tc:RegisterEffect(e1)
    end
end
