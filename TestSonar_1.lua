--- Localize API
local rad = math.rad
local deg = math.deg
local cos = math.cos
local sin = math.sin
local sqrt = math.sqrt
local atan = math.atan
local w2s = client.WorldToScreen
local pi = math.pi

--
local lowFOV = 0
local highFOV = 20

local hitbox = {
	head = 0,
	neck = 1,
	pelvis = 2,
	stomach = 3,
	thorax = 4,
	l_chest = 5,
	u_chest = 6,
	r_thigh = 7,
	l_thigh = 8,
	r_calf = 9,
	l_calf = 10,
	r_foot = 11,
	l_foot = 12,
	r_hand = 13,
	l_hand = 14,
	r_upperarm = 15,
	r_forearm = 16,
	l_upperarm = 17,
	l_forearm = 18,
	--max_hitbox = 19,
};

function drawSkeleton(hitboxs)

    if(hitboxs == nil) then 
        return;
    end
    --//spine
    draw.Line( hitboxs.head.x, hitboxs.head.y, hitboxs.neck.x, hitboxs.neck.y)
    draw.Line( hitboxs.neck.x, hitboxs.neck.y, hitboxs.u_chest.x, hitboxs.u_chest.y)
    draw.Line( hitboxs.u_chest.x, hitboxs.u_chest.y, hitboxs.l_chest.x, hitboxs.l_chest.y)
    draw.Line( hitboxs.l_chest.x, hitboxs.l_chest.y, hitboxs.thorax.x, hitboxs.thorax.y)
    draw.Line( hitboxs.thorax.x, hitboxs.thorax.y, hitboxs.stomach.x, hitboxs.stomach.y)
    draw.Line( hitboxs.stomach.x, hitboxs.stomach.y, hitboxs.pelvis.x, hitboxs.pelvis.y)
    --//right leg
    draw.Line( hitboxs.pelvis.x, hitboxs.pelvis.y, hitboxs.r_thigh.x, hitboxs.r_thigh.y)
    draw.Line( hitboxs.r_thigh.x, hitboxs.r_thigh.y, hitboxs.r_calf.x, hitboxs.r_calf.y)
    draw.Line( hitboxs.r_calf.x, hitboxs.r_calf.y, hitboxs.r_foot.x, hitboxs.r_foot.y)
    --//right arm
    draw.Line( hitboxs.neck.x, hitboxs.neck.y, hitboxs.r_upperarm.x, hitboxs.r_upperarm.y)
    draw.Line( hitboxs.r_upperarm.x, hitboxs.r_upperarm.y, hitboxs.r_forearm.x, hitboxs.r_forearm.y)
    draw.Line( hitboxs.r_forearm.x, hitboxs.r_forearm.y, hitboxs.r_hand.x, hitboxs.r_hand.y)
    --//left leg
    draw.Line( hitboxs.pelvis.x, hitboxs.pelvis.y, hitboxs.l_thigh.x, hitboxs.l_thigh.y)
    draw.Line( hitboxs.l_thigh.x, hitboxs.l_thigh.y, hitboxs.l_calf.x, hitboxs.l_calf.y)
    draw.Line( hitboxs.l_calf.x, hitboxs.l_calf.y, hitboxs.l_foot.x, hitboxs.l_foot.y)
    --//left arm
    draw.Line( hitboxs.neck.x, hitboxs.neck.y, hitboxs.l_upperarm.x, hitboxs.l_upperarm.y)
    draw.Line( hitboxs.l_upperarm.x, hitboxs.l_upperarm.y, hitboxs.l_forearm.x, hitboxs.l_forearm.y)
    draw.Line( hitboxs.l_forearm.x, hitboxs.l_forearm.y, hitboxs.l_hand.x, hitboxs.l_hand.y)
end

local function DrawHook()
    local screenW, screenH = draw.GetScreenSize();
    local screenCenterX = screenW * 0.5;
    local screenCenterY = screenH * 0.5;
    local localPlayer = entities.GetLocalPlayer()    
    if localPlayer and localPlayer:IsAlive() then
        local players = entities.FindByClass( "CCSPlayer" )
        --local localPlayerPos = localPlayer:GetBonePosition(8)
        local localPlayerPos = localPlayer:GetAbsOrigin();
        local src = localPlayerPos + localPlayer:GetPropVector("localdata", "m_vecViewOffset[0]");
        local localPlayerTeamNumber = localPlayer:GetTeamNumber()
        for i = 1, #players do
            local player = players[ i ];
            if player and player:IsAlive() then
                if player:GetTeamNumber() ~= localPlayerTeamNumber then
                    local playerPos = player:GetBonePosition(8)
                    local x, y = w2s(playerPos)
                    if x ~= nil and y ~= nil then
                        local tmp1 = Vector3(x,y,0)
                        local tmp2 = Vector3(screenCenterX, screenCenterY,0)
                        -- fov
                        local tmp3 = (tmp2 - tmp1):Length()
                        -- distance
                        local tmp4 =  sqrt((localPlayerPos.x-playerPos.x)^2 + (localPlayerPos.y-playerPos.y)^2)
                        if (tmp3 >= lowFOV) and (tmp3 <= highFOV ) --[[and (tmp4 <= 900)]] then
                            local hitboxs = {};
                            local VisibilityBlock = false;
                            for key, value in pairs(hitbox) do
                                local dst = player:GetHitboxPosition(value)
                                local dst_x, dst_y = w2s(dst)
                                if dst_x ~= nil and dst_y ~= nil then
                                    hitboxs[key] = { x = dst_x , y = dst_y }
                                    local tr = engine.TraceLine(src , dst, 0x46004009)
                                    if (tr.entity ~= nil --[[and tr.entity:IsPlayer() and tr.entity:IsAlive()]] and tr.entity:GetIndex() == player:GetIndex()) then
                                        VisibilityBlock = true;
                                    end
                                else
                                    VisibilityBlock = false;
                                    hitboxs = nil;
                                    break;
                                end
                            end
                            if(VisibilityBlock) then
                                draw.Color( 255, 255, 0, 255 )
                            else
                                draw.Color( 255, 255, 255, 255 )
                            end
                            drawSkeleton(hitboxs)
                            draw.Color( 255, 255, 255, 255 )
                            draw.Line( x, y, screenCenterX, screenCenterY )
                            draw.Color( 255, 0, 0, 255 )
                            draw.FilledCircle( x, y, 1 )
                        end
                    end
                end
            end
        end
    end
end

callbacks.Register( "Draw", "DrawHook", DrawHook )
