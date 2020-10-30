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
local screenW = 0
local screenH = 0
local screenCenterX = 0
local screenCenterY = 0

local vmt_1 = [[VertexLitGeneric {
    "$basetexture" 				"VGUI/white_additive"
    "$color" 					"[1 1 1]"
    "$bumpmap"					""
    "$nofog" 					"1"
    "$envmap" 					"env_cubemap"
    "$envmaptint" 				"[0 0 0]"
    "$phong" 					"1"
    "$basemapalphaphongmask" 	"1"
    "$phongboost" 				"0"
    "$rimlight" 				"1"
    "$phongtint" 				"[1 1 1]"
    "$rimlightexponent" 		"9999999"
    "$rimlightboost" 			"0"
    "$pearlescent" 				"0"
    "$alpha" 					"1"			"$ignorez"					"1"
    "$selfillum" 				"1"

    "$enthealth"    			"0"
    "$tempVar"    				"1"
    "$resVal"         			"0"

    "$entspeed"					"0"
    "$maxspeed"					"200"
    "$alpha_unclamped"			"0.0"

    "$translate"				"[0.0 0.0]"
    "$angle" 					"0"

    "Proxies"
    {
        "TextureScroll"
        {
            "textureScrollVar" 		"$translate"
            "textureScrollRate" 	"0"
            "textureScrollAngle" 	"90"
        }

        "TextureTransform"
        {
            "translateVar" 			"$translate"
            "rotateVar" 			"$angle"
            "centerVar" 			"[-0.5 -0.5]"
            "resultVar" 			"$basetexturetransform"
        }

                        "TextureScroll"
        {
            "textureScrollVar" 		"$bumptransform"
            "textureScrollRate" 	"0"
            "textureScrollAngle" 	"90"
        }				
    }
}]]

local vmt_mat_1 = materials.Create("vmt_mat_1",vmt_1)

local vmt_2 =[[VertexLitGeneric {
    "$basetexture" 				"VGUI/white_additive"
    "$color" 					"[1 0.75294117647059 0]"
    "$bumpmap"					""
    "$nofog" 					"1"
    "$envmap" 					"env_cubemap"
    "$envmaptint" 				"[0 0 0]"
    "$phong" 					"1"
    "$basemapalphaphongmask" 	"1"
    "$phongboost" 				"0"
    "$rimlight" 				"1"
    "$phongtint" 				"[1 1 1]"
    "$rimlightexponent" 		"9999999"
    "$rimlightboost" 			"0"
    "$pearlescent" 				"0"
    "$alpha" 					"1"			"$ignorez"					"0"
    "$selfillum" 				"1"

    "$enthealth"    			"0"
    "$tempVar"    				"1"
    "$resVal"         			"0"

    "$entspeed"					"0"
    "$maxspeed"					"200"
    "$alpha_unclamped"			"0.0"

    "$translate"				"[0.0 0.0]"
    "$angle" 					"0"

    "Proxies"
    {
        "TextureScroll"
        {
            "textureScrollVar" 		"$translate"
            "textureScrollRate" 	"0"
            "textureScrollAngle" 	"90"
        }

        "TextureTransform"
        {
            "translateVar" 			"$translate"
            "rotateVar" 			"$angle"
            "centerVar" 			"[-0.5 -0.5]"
            "resultVar" 			"$basetexturetransform"
        }

                        "TextureScroll"
        {
            "textureScrollVar" 		"$bumptransform"
            "textureScrollRate" 	"0"
            "textureScrollAngle" 	"90"
        }				
    }
}]]

local vmt_mat_2 = materials.Create("vmt_mat_2",vmt_2)

local function DrawHook()
    screenW, screenH = draw.GetScreenSize();
    screenCenterX = screenW * 0.5;
    screenCenterY = screenH * 0.5;
end

local function DrawModelHook(Context)
    local pLocal = entities.GetLocalPlayer()
    if pLocal ~= nil and pLocal:IsAlive() then
        local localPlayerPos = pLocal:GetAbsOrigin();
        local src = localPlayerPos + pLocal:GetPropVector("localdata", "m_vecViewOffset[0]");
        local pEntity = Context:GetEntity()
        if pEntity ~= nil and pEntity:IsPlayer() and pEntity:IsAlive() then
            if (pEntity:GetTeamNumber() ~= pLocal:GetTeamNumber()) then
                local playerPos = pEntity:GetBonePosition(8)
                local x, y = w2s(playerPos)
                if x ~= nil and y ~= nil then
                    local tmp1 = Vector3(x,y,0)
                    local tmp2 = Vector3(screenCenterX, screenCenterY,0)
                    -- fov
                    local tmp3 = (tmp2 - tmp1):Length()
                    -- distance
                    -- local tmp4 =  sqrt((localPlayerPos.x-playerPos.x)^2 + (localPlayerPos.y-playerPos.y)^2)
                    if (tmp3 >= lowFOV) and (tmp3 <= highFOV ) --[[and (tmp4 <= 900)]] then
                        gui.SetValue("esp.chams.enemy.visible", 0)
                        Context:ForcedMaterialOverride(vmt_mat_1)
                        Context:DrawExtraPass()
                        Context:ForcedMaterialOverride(vmt_mat_2)
                        Context:DrawExtraPass()
                    end
                end
            end
        end
    end
end

callbacks.Register( "Draw", DrawHook )
callbacks.Register("DrawModel", DrawModelHook)