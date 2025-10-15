--Dynasaurus Cat
--Scripted by Kooder
-- Effects:
-- (1) Cannot be Special Summoned from your Hand or GY.
-- (2) This card's ATK & DEF is equal to the number of cards in your banish x 300
-- (3) Once per duel, at the start of the Damage Step, if this card battles an opponent's monster: You can banish that opponent's monster, face-down, and if you do, banish the top 5 cards of your deck face-up. You cannot Summon "Wonder MOMOCO" the turn you use this effect.
-- (4) If this card is in your GY, You can return 4 random cards from your opponent's banish zone to their deck; Add this card to your hand. You can only active this effect of "Dynasaurus Cat" once per duel.
local s,id=GetID()
function s.initial_effect(c)
-- (1) Cannot be Special Summoned from your Hand or GY.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetCondition(s.splimcon)
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
-- (2) This card's ATK & DEF is equal to the number of cards in your banish x 300
	local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCode(EFFECT_UPDATE_ATTACK)
    e2:SetValue(s.stat)
    c:RegisterEffect(e2)
	local e3=e2:Clone()
    e3:SetCode(EFFECT_UPDATE_DEFENSE)
    c:RegisterEffect(e3)
-- (3) Once per duel, at the start of the Damage Step, if this card battles an opponent's monster: You can banish that opponent's monster, face-down, and if you do, banish the top 5 cards of your deck face-up. You cannot Summon "Wonder MOMOCO" the turn you use this effect.
	local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,0))
    e4:SetCategory(CATEGORY_REMOVE)
    e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e4:SetCode(EVENT_BATTLE_START)
	e4:SetCountLimit(1,id,EFFECT_COUNT_CODE_DUEL)
    e4:SetTarget(s.rmtg)
    e4:SetOperation(s.rmop)
    c:RegisterEffect(e4)
-- (4) If this card is in your GY, You can return 4 random cards from your opponent's banish zone to their deck; Add this card to your hand. You can only active this effect of "Dynasaurus Cat" once per duel.
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,2))
	e5:SetCategory(CATEGORY_TOHAND+CATEGORY_TODECK)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_GRAVE)
    e5:SetCountLimit(1,id,EFFECT_COUNT_CODE_DUEL)
	e5:SetTarget(s.target)
	e5:SetOperation(s.operation)
	c:RegisterEffect(e5)
end
-- (1) Cannot be Special Summoned from your Hand or GY.
function s.splimcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsLocation(LOCATION_HAND|LOCATION_GRAVE)
end
-- (2) This card's ATK & DEF is equal to the number of cards in your banish x 300
function s.stat(e,tp,eg,ep,ev,re,r,rp,chk)
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_REMOVED,0)*300
end
-- (3) Once per duel, at the start of the Damage Step, if this card battles an opponent's monster: You can banish that opponent's monster, face-down
function s.mmfilter(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsCode(210660455)
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=e:GetHandler():GetBattleTarget()
	local g=Duel.GetDecktopGroup(tp,5)
	if chk==0 then return tc and tc:IsControler(1-tp) and tc:IsAbleToRemove(tp,POS_FACEDOWN) and g:FilterCount(Card.IsAbleToRemove,nil,POS_FACEUP)==5 end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,tc,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,tp,0)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetBattleTarget()
	if tc and tc:IsRelateToBattle() then
		Duel.Remove(tc,POS_FACEDOWN,REASON_EFFECT)
-- (3) Banish the top 5 cards of your deck face-up.
		local g=Duel.GetDecktopGroup(tp,5)
		if #g>0 then
			Duel.DisableShuffleCheck()
			Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
		end
-- (3) You cannot Summon "Wonder MOMOCO" the turn you use this effect.
		local c=e:GetHandler()
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetReset(RESET_PHASE|PHASE_END)
		e1:SetTargetRange(1,0)
		e1:SetTarget(s.mmfilter)
		e1:SetLabelObject(e)
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_CANNOT_SUMMON)
		Duel.RegisterEffect(e2,tp)
		local e3=e1:Clone()
		e3:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
		Duel.RegisterEffect(e3,tp)
		aux.RegisterClientHint(e:GetHandler(),nil,tp,1,0,aux.Stringid(id,1),nil)
	end
end
-- (4) If this card is in your GY, You can return 4 random cards from your opponent's banish zone to their deck; Add this card to your hand. You can only active this effect of "Dynasaurus Cat" once per duel.
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=Duel.GetFieldGroup(tp,0,LOCATION_REMOVED)
	if chk==0 then return g:FilterCount(Card.IsAbleToDeck,nil,POS_FACEDOWN)>=4 end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,4,0,LOCATION_REMOVED)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,0,LOCATION_REMOVED)
	if #g<4 then return end
	if #g>=4 then
		g=g:RandomSelect(tp,4)
		Duel.ConfirmCards(tp,g)
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		Duel.ShuffleHand(tp)
		Duel.SendtoHand(e:GetHandler(),nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,e:GetHandler())
	end
end