local Services = setmetatable({}, {
    __index = function(Self, Index)
        Self[Index] = game.GetService(game, Index)
        return Self[Index]
    end
})
local require, pairs, huge, insert, sort, unpack, wait, tostring, Vector3new = require, pairs, math.huge, table.insert, table.sort, unpack, wait, tostring, Vector3.new
local Player = Services.Players.LocalPlayer
local Zombies = workspace.Zombies
local Border = workspace.Map.Border
local PlayerTeleport = Services.ReplicatedStorage.RemoteEvents.PlayerTeleport
local RemoteCritMelee = Services.ReplicatedStorage.RemoteEvents.RemoteCritMelee
local ModuleScripts = Services.ReplicatedStorage.ModuleScripts
local RemoteFireMelee = Services.ReplicatedStorage.RemoteEvents.RemoteFireMelee
local Time = Player.PlayerGui.ScreenGui.GameFrame.Core.PlayerFrame.Time
local CharacterManager = require(ModuleScripts.CharacterManager)
local RandomManager = require(ModuleScripts.RandomManager)
local OldRoll = RandomManager.Roll
local OldGetValue = CharacterManager.GetValue
local OldIsCrit = CharacterManager.IsCrit
local VoteSkip = Services.ReplicatedStorage.RemoteFunctions.VoteSkip
local RemoteCritMelee = Services.ReplicatedStorage.RemoteEvents.RemoteCritMelee
local RemoteFireMelee = Services.ReplicatedStorage.RemoteEvents.RemoteFireMelee
local DamageRampUp = 50
local HeadSize = false
local AutoMelee = false
local AutoVote = false
local TeleportHead = false
local ReturnIndex = 5000
local Autobackup = false
local Switch = false
local EnergySwordAvaible = false
local DebounceSword = false
local OldPos
_G.HeadSize = Vector3new(5, 5, 5)
_G.Modification = {
    --AttackSpeed = 3;
    --MeleeAttackSpeed = huge;
    ZoomSpreadDecrease = huge;
    SpreadDecrease = huge;
    Pierce = 999;
    MeleeRange = 999;
    Spread = 0;
    SpreadMax = 0;
    ZoomSpread = 0;
    ZoomSpreadIncrease = 0;
    ZoomSpreadMax = 0;
    SpreadIncrease = 0;
    MeleeDelay = 0;
}
local Settings = {
    WeaponAttack = {
        ToggledAlt = false, 
		ADS = true, 
		ScopeChargeAlpha = huge, 
		RolledAmmo = true, 
		WalkSpeed = 0, 
		StunCrits = true, 
		AltDamage = huge, 
		IgnoreHeadshot = false, 
		Critical = {true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true}, 
		CriticalRolls = {true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true},
		StackHeadshot = huge, 
		DoTCount = {huge, huge, huge, huge, huge, huge, huge, huge, huge, huge, huge, huge, huge, huge, huge, huge, huge, huge, huge, huge}, 
		SuperCritRolls = {true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true}, 
		GUID = Services.HttpService.GenerateGUID(Services.HttpService, false), 
		FrozenCrits = true,
    };
    Types = {
        Adsing = true;
        EnergyEnabled = true;
        Meleeing = true;
        CharPos = Vector3.new();
        Posing = false;
    };
    Values = {
        "MeleeRange";
        "MeleeWither";
        "MeleeAttackSpeed";
    };
}
local function IsCritSwap(...)
    if not checkcaller() then
        return true
    end
    return OldIsCrit
end
local function GetNearestZombies()
    if Player and Player.Character and Player.Character.FindFirstChild(Player.Character, "HumanoidRootPart") then
        local Objects = {}
        local Table = {}
        for _, v in pairs(Zombies.GetChildren(Zombies)) do
            if v.FindFirstChild(v, "Torso") and v.FindFirstChild(v, "Zombie") and v.Zombie.Health > 0 and (v.Torso.Position - Player.Character.HumanoidRootPart.Position).Magnitude <= 25 then
                insert(Objects, {Part = v, magnitude = (v.Torso.Position - Player.Character.HumanoidRootPart.Position).Magnitude})
            end
        end
        sort(Objects, function(Table1, Table2)
            return Table1.magnitude < Table2.magnitude
        end)
        local Amount = DamageRampUp / #Objects
        for _, v in pairs(Objects) do
            for i = 1, Amount do
                insert(Table, {v.Part.Torso, {["Critical"] = true}})
            end
        end
        return Table
    end
end
local function RollSwap(...)
    local Table = {...}
    if not checkcaller() and Table[3] ~= "AmmoSeed" then
        return -999
    end
    return OldRoll(...)
end
local function ValueSwap(Table, String, ...)
    if not checkcaller() and table.find(Settings.Values, String) then
        return ReturnIndex
    end
    return OldGetValue(Table, String, ...)
end
local function Input(Key, Chat)
    if Key.KeyCode == Enum.KeyCode.KeypadOne and not Chat then
        AutoMelee = not AutoMelee
    elseif Key.KeyCode == Enum.KeyCode.KeypadTwo and not Chat then
        TeleportHead = not TeleportHead
    elseif Key.KeyCode == Enum.KeyCode.KeypadThree and not Chat then
        HeadSize = not HeadSize
    elseif Key.KeyCode == Enum.KeyCode.KeypadFour and not Chat then
        AutoVote = not AutoVote
    elseif Key.KeyCode == Enum.KeyCode.KeypadFive and not Chat then
        Autobackup = not Autobackup
        OldPos = Player.Character.HumanoidRootPart.CFrame
    end
end
local function TimeText()
    if Autobackup == true then
        local Text = Time.Text:gsub("%D", "")
        Text = tonumber(Text)
        if Text >= 555 and Text <= 1700 and Switch == false then
            Switch = true
            Player.Character.Humanoid:MoveTo((OldPos * CFrame.new(0, 0, -50)).p)
        elseif Text >= 1730 and Switch == true then
            Switch = false
            Player.Character.Humanoid:MoveTo(OldPos.p)
        end
    end
end
local function ChangeValues()
    TimeText()
	if Player.Character and Player.Character:FindFirstChild("CharacterManager") then
		Player.Character.CharacterManager:Destroy()
	end
    if AutoMelee == true and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
        for _, v in pairs(Zombies:GetChildren()) do
            if v and v.FindFirstChild(v, "Head") and v.FindFirstChild(v, "Zombie") and v.Zombie.Health ~= 0 and (v.Head.Position - Player.Character.HumanoidRootPart.Position).Magnitude <= 25 then
            	local Tool = Player.Character:FindFirstChild("Military Axe") or Player.Character:FindFirstChild("Katana") or Player.Character:FindFirstChild("Machete") or Player.Character:FindFirstChild("Baseball Bat") or Player.Character:FindFirstChild("Dual Sai") or Player.Character:FindFirstChild("Energy Sword") or Player.Character:FindFirstChild("Cutlass")
                if Tool then
                    RemoteFireMelee:FireServer(Tool, {})
                    RemoteCritMelee:FireServer(Tool, true, {})
                else
                    RemoteFireMelee:FireServer("Melee", {})
                    RemoteCritMelee:FireServer("Melee", true, {})
                end
                break
            end
        end
    end
    if TeleportHead == true then
        for _, v in pairs(Zombies:GetChildren()) do
            if v:FindFirstChild("Head") then
                v.Torso.Neck.Enabled = false
                v.Head.Anchored = true
                v.Head.CFrame = Player.Character.HumanoidRootPart.CFrame + Player.Character.HumanoidRootPart.CFrame.LookVector * 5
            end
        end
    end
    if HeadSize == true then
		for _, v in pairs(Zombies:GetChildren()) do
			if v:FindFirstChild("Head") and not v.Head:GetAttribute("OldSize") then
				v.Head:SetAttribute("OldSize", v.Head.Size)
				v.Head.Size = _G.HeadSize
				v.Head.CanCollide = false
				v.Head.Massless = true
			end
		end
	end
    for i, v in pairs(_G.Modification) do
        if Player.Character and Player.Character:FindFirstChildOfClass("Tool") and Player.Character:FindFirstChildOfClass("Tool"):FindFirstChild("CurrentValues") and Player.Character:FindFirstChildOfClass("Tool").CurrentValues:FindFirstChild(i) and Player.Character:FindFirstChildOfClass("Tool").CurrentValues[i].Value ~= v then
            Player.Character:FindFirstChildOfClass("Tool").CurrentValues[i].Value = v
        end
        if Player:FindFirstChild("PlayerValues") and Player.PlayerValues:FindFirstChild(i) and Player.PlayerValues[i].Value ~= v then
            Player.PlayerValues[i].Value = v
        end
    end
end
CharacterManager.IsCrit = IsCritSwap
RandomManager.Roll = RollSwap
Services.UserInputService.InputBegan:Connect(Input)
Services.RunService.RenderStepped:Connect(ChangeValues)
HookRemote = hookmetamethod(game, "__namecall", function(Self, ...)
    local Table = {...}
    if not checkcaller() and getnamecallmethod() == "Kick" then
        wait(9e9)
    elseif not checkcaller() and tostring(Self) == "PlayerPing" then
        return
    elseif not checkcaller() and tostring(Self) == "PacketRemote" and (Table[1].WeaponAttack) then
         pcall(function()
            for i, v in pairs(Settings.Types) do
                if i == "EnergyEnabled" and EnergySwordAvaible == true and DebounceSword == false then
                    DebounceSword = true
                    Table[1][i] = v
                elseif i ~= "EnergyEnabled" then
                    Table[1][i] = v
                end
            end
        end)
        local DefaultValues = Player.Character[Table[1].WeaponAttack[1][1]].DefaultValues
        for i, v in pairs(Table[1].WeaponAttack) do
            for i, x in pairs(Settings.WeaponAttack) do
                v[3][i] = x
            end
            v[3]["ExplosionPos"] = Player.GetMouse(Player).Hit.p
            v[3]["ClientVCheck"] = {DefaultValues.AttackSpeed.Value, DefaultValues.Spread.Value, DefaultValues.SpreadDecrease.Value, DefaultValues.SpreadIncrease.Value, DefaultValues.SpreadMax.Value, DefaultValues.ZoomSpread.Value, DefaultValues.ZoomSpreadDecrease.Value, DefaultValues.ZoomSpreadIncrease.Value, DefaultValues.ZoomSpreadMax.Value}
            if v[2][1][1] and v[2][1][1].Parent then
                v[2][1][1] = v[2][1][1].Parent.Head
                v[2][1][2] = v[2][1][1].Parent.Torso.Position + Vector3.new(0, 1.5, 0)
                v[3].RayOriginPos = v[2][1][1].Position + Vector3.new(0, 1, 0)
                v[2][1][3].Critical = true
                v[2][1][3]["StackHeadshot"] = huge
                v[2][1][3].HitPartSize = v[2][1][1].GetAttribute(v[2][1][1], "OldSize") or v[2][1][1].Size
            end
        end
        return HookRemote(Self, unpack(Table))
    elseif not checkcaller() and tostring(Self) == "PacketRemote" then
        pcall(function()
            for i, v in pairs(Settings.Types) do
                if i == "EnergyEnabled" and EnergySwordAvaible == true and DebounceSword == false then
                    DebounceSword = true
                    Table[1][i] = v
                elseif i ~= "EnergyEnabled" then
                    Table[1][i] = v
                end
            end
        end)
        return HookRemote(Self, unpack(Table))
    elseif not checkcaller() and tostring(Self) == "RemoteCritMelee" then
        Table[2] = true
        return HookRemote(Self, unpack(Table))
    elseif tostring(Self) == "RemoteFireMelee" then
        local NearestZombies = GetNearestZombies()
        if not NearestZombies then return end
        Table[2] = NearestZombies
        return HookRemote(Self, unpack(Table))
    end
    return HookRemote(Self, ...)
end)
while wait() do
    if AutoVote == true then
        VoteSkip:InvokeServer()
    end
    if Player.Character:FindFirstChild("Energy Sword") then
        EnergySwordAvaible = true
    else
        EnergySwordAvaible = false
        DebounceSword = false
    end
end
