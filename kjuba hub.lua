getgenv().script_connections = {}
getgenv().script_running = true

local rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local window = rayfield:CreateWindow({
	Name = "Kjuba Hub",
	LoadingTitle = "Loading Kjuba Hub",
	LoadingSubtitle = "by cyandev",
	ConfigurationSaving = {
		Enabled = false,
		FolderName = nil,
		FileName = "config"
	},
	Discord = {
		Enabled = false,
		Invite = "noinvitelink",
		RememberJoins = true
	}
})

local main_tab = window:CreateTab("Main", nil)
local defense_tab = window:CreateTab("Defense", nil)
local grab_tab = window:CreateTab("Grab", nil)
local pvp_tab = window:CreateTab("PVP", nil)

-- Main Tab Content
local player_section = main_tab:CreateSection("Movement")

local jump_power_control = false
local jump_power_connection = nil
local current_jump_power = 50

local player_jump_toggle = main_tab:CreateToggle({
	Name = "Jump Power Control",
	CurrentValue = false,
	Flag = "jump_power_control",
	Callback = function(value) 
		jump_power_control = value
		
		if value then
			-- Set initial jump power
			if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
				game.Players.LocalPlayer.Character.Humanoid.JumpPower = current_jump_power
			end
			
			-- Create property change connection to override AA changes
			local function setupJumpPowerProtection()
				if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
					jump_power_connection = game.Players.LocalPlayer.Character.Humanoid:GetPropertyChangedSignal("JumpPower"):Connect(function()
						if getgenv().script_running and jump_power_control then
							game.Players.LocalPlayer.Character.Humanoid.JumpPower = current_jump_power
						end
					end)
					table.insert(getgenv().script_connections, jump_power_connection)
				end
			end
			
			-- Setup for current character
			setupJumpPowerProtection()
			
			-- Setup for character respawns
			local character_connection = game.Players.LocalPlayer.CharacterAdded:Connect(function()
				wait(1) -- Wait for character to fully load
				if jump_power_control then
					setupJumpPowerProtection()
				end
			end)
			table.insert(getgenv().script_connections, character_connection)
		else
			-- Disconnect property change connection and reset to default
			if jump_power_connection then
				jump_power_connection:Disconnect()
				jump_power_connection = nil
			end
			if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
				game.Players.LocalPlayer.Character.Humanoid.JumpPower = 25
			end
		end
	end,
})

local walk_speed_control = false
local walk_speed_connection = nil
local current_walk_speed = 30

local player_speed_toggle = main_tab:CreateToggle({
	Name = "Walk Speed Control",
	CurrentValue = false,
	Flag = "walk_speed_control",
	Callback = function(value) 
		walk_speed_control = value
		
		if value then
			-- Set initial walkspeed
			if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
				game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = current_walk_speed
			end
			
			-- Create property change connection to override AA changes
			local function setupWalkSpeedProtection()
				if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
					walk_speed_connection = game.Players.LocalPlayer.Character.Humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
						if getgenv().script_running and walk_speed_control then
							game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = current_walk_speed
						end
					end)
					table.insert(getgenv().script_connections, walk_speed_connection)
				end
			end
			
			-- Setup for current character
			setupWalkSpeedProtection()
			
			-- Setup for character respawns
			local character_connection = game.Players.LocalPlayer.CharacterAdded:Connect(function()
				wait(1) -- Wait for character to fully load
				if walk_speed_control then
					setupWalkSpeedProtection()
				end
			end)
			table.insert(getgenv().script_connections, character_connection)
		else
			-- Disconnect property change connection and reset to default
			if walk_speed_connection then
				walk_speed_connection:Disconnect()
				walk_speed_connection = nil
			end
			if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
				game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 16
			end
		end
	end,
})

local player_jump_slider = main_tab:CreateSlider({
	Name = "Jump Power",
	Range = {5, 300},
	Increment = 1,
	Suffix = " Power",
	CurrentValue = 50,
	Flag = "jump_slider",
	Callback = function(value)
		current_jump_power = value
	end,
})

local player_speed_slider = main_tab:CreateSlider({
	Name = "Walk Speed",
	Range = {16, 100},
	Increment = 1,
	Suffix = " Speed",
	CurrentValue = 30,
	Flag = "speed_slider",
	Callback = function(value)
		current_walk_speed = value
	end,
})

local infinite_jump_toggle = main_tab:CreateToggle({
	Name = "Infinite Jump",
	CurrentValue = false,
	Flag = "infinite_jump",
	Callback = function(value)
		getgenv().infinite_jump = value
		if value then
			local connection = game:GetService("UserInputService").JumpRequest:connect(function()
				if getgenv().infinite_jump and getgenv().script_running then
					game.Players.LocalPlayer.Character:FindFirstChild("Humanoid"):ChangeState("Jumping")
				end
			end)
			table.insert(getgenv().script_connections, connection)
		end
	end,
})

local misc_section = main_tab:CreateSection("Miscellaneous")

local noclip_toggle = main_tab:CreateToggle({
	Name = "Noclip",
	CurrentValue = false,
	Flag = "noclip",
	Callback = function(value)
		getgenv().noclip = value
		local player = game.Players.LocalPlayer
		
		if value then
			getgenv().original_collisions = {}
			
			for _, part in pairs(player.Character:GetDescendants()) do
				if part:IsA("BasePart") then
					getgenv().original_collisions[part] = part.CanCollide
					part.CanCollide = false
				end
			end
			
			local connection = game:GetService("RunService").Stepped:connect(function()
				if getgenv().noclip and getgenv().script_running and player.Character then
					for _, part in pairs(player.Character:GetDescendants()) do
						if part:IsA("BasePart") then
							part.CanCollide = false
						end
					end
				end
			end)
			table.insert(getgenv().script_connections, connection)
		else
			if getgenv().original_collisions and player.Character then
				for part, original_state in pairs(getgenv().original_collisions) do
					if part and part.Parent then
						part.CanCollide = original_state
					end
				end
				getgenv().original_collisions = nil
			end
		end
	end,
})

local noclip_grab_toggle = main_tab:CreateToggle({
	Name = "Noclip Grab",
	CurrentValue = false,
	Flag = "noclip_grab",
	Callback = function(value)
		getgenv().noclip_grab = value
		
		if value then
			getgenv().grabbed_model_collisions = {}
			getgenv().current_grabbed_model = nil
			
			local connection = game:GetService("RunService").Heartbeat:connect(function()
				if getgenv().noclip_grab and getgenv().script_running then
					local grabParts = workspace:FindFirstChild("GrabParts")
					
					if grabParts then
						local grabPart = grabParts:FindFirstChild("GrabPart")
						if grabPart then
							local weldConstraint = grabPart:FindFirstChild("WeldConstraint")
							if weldConstraint and weldConstraint.Part1 then
								local grabbedModel = weldConstraint.Part1.Parent
								
								-- If this is a new model being grabbed
								if getgenv().current_grabbed_model ~= grabbedModel then
									-- Restore previous model if exists
									if getgenv().current_grabbed_model and getgenv().grabbed_model_collisions then
										for part, original_state in pairs(getgenv().grabbed_model_collisions) do
											if part and part.Parent then
												part.CanCollide = original_state
											end
										end
									end
									
									-- Store new model and disable collisions
									getgenv().current_grabbed_model = grabbedModel
									getgenv().grabbed_model_collisions = {}
									
									for _, part in pairs(grabbedModel:GetDescendants()) do
										if part:IsA("BasePart") then
											getgenv().grabbed_model_collisions[part] = part.CanCollide
										end
									end
								end
								
								-- Continuously enforce CanCollide = false for all parts (to override server changes)
								if getgenv().current_grabbed_model then
									for _, part in pairs(getgenv().current_grabbed_model:GetDescendants()) do
										if part:IsA("BasePart") then
											part.CanCollide = false
										end
									end
								end
							end
						end
					else
						-- GrabParts doesn't exist, restore collisions if we had a grabbed model
						if getgenv().current_grabbed_model and getgenv().grabbed_model_collisions then
							for part, original_state in pairs(getgenv().grabbed_model_collisions) do
								if part and part.Parent then
									part.CanCollide = original_state
								end
							end
							getgenv().grabbed_model_collisions = {}
							getgenv().current_grabbed_model = nil
						end
					end
				end
			end)
			table.insert(getgenv().script_connections, connection)
		else
			-- Restore collisions when toggle is disabled
			if getgenv().current_grabbed_model and getgenv().grabbed_model_collisions then
				for part, original_state in pairs(getgenv().grabbed_model_collisions) do
					if part and part.Parent then
						part.CanCollide = original_state
					end
				end
				getgenv().grabbed_model_collisions = {}
				getgenv().current_grabbed_model = nil
			end
		end
	end,
})

-- Ragdoll Walker Section
local ragdoll_section = main_tab:CreateSection("Ragdoll Walker")

-- Ragdoll Walker Variables
local ragdoll_walker_enabled = false
local ragdoll_walker_mode = "Dummy Bones"
local prevent_random_floating = true
local fish_limbs_height = 40
local ragdoll_heartbeat_connection = nil
local ragdoll_timer_connection = nil
local limb_rotation_connection = nil
local fish_input_connection = nil
local fish_rotating = false
local original_position = nil
local desiredCFrames = {}
local originalCFrames = {}

-- Fish Flopping Functions
local function getAllLimbs()
    local player = game.Players.LocalPlayer
    local character = player.Character
    if not character then return {} end
    
    local limbs = {}
    -- Left Leg (R6: "Left Leg", R15: "LeftUpperLeg")
    limbs.leftLeg = character:FindFirstChild("Left Leg") or character:FindFirstChild("LeftUpperLeg")
    -- Right Leg (R6: "Right Leg", R15: "RightUpperLeg") 
    limbs.rightLeg = character:FindFirstChild("Right Leg") or character:FindFirstChild("RightUpperLeg")
    -- Left Arm (R6: "Left Arm", R15: "LeftUpperArm")
    limbs.leftArm = character:FindFirstChild("Left Arm") or character:FindFirstChild("LeftUpperArm")
    -- Right Arm (R6: "Right Arm", R15: "RightUpperArm")
    limbs.rightArm = character:FindFirstChild("Right Arm") or character:FindFirstChild("RightUpperArm")
    
    return limbs
end

local function startFishRotation()
    if fish_rotating then return end
    
    local player = game.Players.LocalPlayer
    local character = player.Character
    if not character then return end
    
    local root = character:FindFirstChild("HumanoidRootPart")
    local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
    if not root or not torso then return end
    
    print("Starting fish rotation - teleporting up by", fish_limbs_height, "studs")
    
    -- Store original position
    original_position = root.Position
    print("Original position:", original_position)
    
    -- Teleport up by fish limbs height
    local newPosition = original_position + Vector3.new(0, fish_limbs_height, 0)
    root.CFrame = CFrame.new(newPosition, newPosition + root.CFrame.LookVector)
    print("Teleported to:", newPosition)

    wait(0.6)
    
    local limbs = getAllLimbs()
    
    -- Check if we have at least one limb
    local hasLimbs = false
    for limbName, limb in pairs(limbs) do
        if limb then
            hasLimbs = true
            print("Found limb:", limbName)
            break
        end
    end
    
    if not hasLimbs then
        print("No limbs found for rotation!")
        return
    end
    
    fish_rotating = true
    print("Fish rotation enabled")
    
    -- Store original CFrames for each limb
    for limbName, limb in pairs(limbs) do
        if limb then
            originalCFrames[limbName] = limb.CFrame
        end
    end
    
    -- Connect to RenderStepped for smooth rotation updates
    limb_rotation_connection = game:GetService("RunService").RenderStepped:Connect(function()
        if not fish_rotating then return end
        
        local limbs = getAllLimbs()
        local currentTime = tick()
        
        for limbName, limb in pairs(limbs) do
            if limb and originalCFrames[limbName] then
                -- Apply rotation to each limb (70, time * 0.1, 0)
                desiredCFrames[limbName] = originalCFrames[limbName] * CFrame.Angles(
                    math.rad(70),
                    currentTime * 0.1,
                    0
                )
                limb.CFrame = desiredCFrames[limbName]
            end
        end
    end)
    
    -- Wait a moment then teleport torso and root back down
    spawn(function()
        wait(0.1)
        if original_position and root and torso then
            print("Teleporting torso and root back to ground")
            root.CFrame = CFrame.new(original_position, original_position + root.CFrame.LookVector)
            torso.CFrame = CFrame.new(original_position, original_position + torso.CFrame.LookVector)
            print("Teleported back to:", original_position)
        end
    end)
end

local function stopFishRotation()
    if not fish_rotating then return end
    
    fish_rotating = false
    
    if limb_rotation_connection then
        limb_rotation_connection:Disconnect()
        limb_rotation_connection = nil
    end
    
    -- Clear stored data
    desiredCFrames = {}
    originalCFrames = {}
end

-- Ragdoll Walker Toggle
local ragdoll_walker_toggle = main_tab:CreateToggle({
	Name = "Ragdoll Walker",
	CurrentValue = false,
	Flag = "ragdoll_walker",
	Callback = function(value)
		ragdoll_walker_enabled = value
		
		if value then
			local player = game.Players.LocalPlayer
			
        if ragdoll_walker_mode == "Dummy Bones" then
            ragdoll_heartbeat_connection = game:GetService("RunService").Heartbeat:Connect(function()
                if not ragdoll_walker_enabled then return end

                local character = player.Character
                if not character then return end

                local root = character:FindFirstChild("HumanoidRootPart")
                local humanoid = character:FindFirstChild("Humanoid")

                if root and humanoid and not root.Anchored then
                    humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
                end
            end)
            table.insert(getgenv().script_connections, ragdoll_heartbeat_connection)
        end
			
			-- Timer connection for ragdoll remote
			local function ragdollTimer()
				while ragdoll_walker_enabled do
					wait(1)
					if ragdoll_walker_enabled then
						local character = player.Character
						if character then
							local root = character:FindFirstChild("HumanoidRootPart")
							if root then
								local remote = game:GetService("ReplicatedStorage"):WaitForChild("CharacterEvents"):WaitForChild("RagdollRemote")
								remote:FireServer(root, 2.5)
							end
						end
					end
				end
			end
			
			ragdoll_timer_connection = coroutine.create(ragdollTimer)
			coroutine.resume(ragdoll_timer_connection)
			
			-- Handle different modes
			print("Current ragdoll walker mode:", ragdoll_walker_mode)
			if ragdoll_walker_mode == "Dummy Bones" then
				print("Setting up Dummy Bones mode")
				-- Handle prevent random floating
				local character = player.Character
				if character then
					-- Handle left leg
					local leftLeg = character:FindFirstChild("Left Leg") or character:FindFirstChild("LeftLowerLeg")
					if leftLeg then
						local ragdollPart = leftLeg:FindFirstChild("RagdollLimbPart")
						if ragdollPart then
							local weld = ragdollPart:FindFirstChild("WeldConstraint")
							if weld then
								weld.Enabled = not prevent_random_floating
							end
						end
					end
					
					-- Handle right leg
					local rightLeg = character:FindFirstChild("Right Leg") or character:FindFirstChild("RightLowerLeg")
					if rightLeg then
						local ragdollPart = rightLeg:FindFirstChild("RagdollLimbPart")
						if ragdollPart then
							local weld = ragdollPart:FindFirstChild("WeldConstraint")
							if weld then
								weld.Enabled = not prevent_random_floating
							end
						end
					end
				end
			elseif ragdoll_walker_mode == "Fish Flopping" then
				spawn(function()
					startFishRotation()
				end)
			end
		else
			-- Cleanup connections
			if ragdoll_heartbeat_connection then
				ragdoll_heartbeat_connection:Disconnect()
				ragdoll_heartbeat_connection = nil
			end
			
			if ragdoll_timer_connection then
				coroutine.close(ragdoll_timer_connection)
				ragdoll_timer_connection = nil
			end
			
			if limb_rotation_connection then
				limb_rotation_connection:Disconnect()
				limb_rotation_connection = nil
			end
			
			if fish_input_connection then
				fish_input_connection:Disconnect()
				fish_input_connection = nil
			end
			
			stopFishRotation()
		end
	end,
})

-- Ragdoll Walker Mode Dropdown
local ragdoll_walker_dropdown = main_tab:CreateDropdown({
	Name = "Ragdoll Walker Mode",
	Options = {"Dummy Bones", "Fish Flopping"},
	CurrentOption = "Dummy Bones",
	Flag = "ragdoll_walker_mode",
	Callback = function(option)
		-- Handle both string and table returns from dropdown
		if type(option) == "table" then
			ragdoll_walker_mode = option[1] or "Dummy Bones"
		else
			ragdoll_walker_mode = option
		end
		
		print("Dropdown callback - new mode:", ragdoll_walker_mode)
		
		-- If ragdoll walker is currently enabled, restart it with new mode
		if ragdoll_walker_enabled then
			ragdoll_walker_toggle:Set(false)
			wait(0.1)
			ragdoll_walker_toggle:Set(true)
		end
	end,
})

-- Prevent Random Floating Checkbox (only shown for Dummy Bones mode)
local prevent_floating_toggle = main_tab:CreateToggle({
	Name = "Prevent Random Floating",
	CurrentValue = true,
	Flag = "prevent_random_floating",
	Callback = function(value)
		prevent_random_floating = value
		
		-- Apply immediately if ragdoll walker is enabled and in dummy bones mode
		if ragdoll_walker_enabled and ragdoll_walker_mode == "Dummy Bones" then
			local player = game.Players.LocalPlayer
			local character = player.Character
			if character then
				-- Handle left leg
				local leftLeg = character:FindFirstChild("Left Leg") or character:FindFirstChild("LeftLowerLeg")
				if leftLeg then
					local ragdollPart = leftLeg:FindFirstChild("RagdollLimbPart")
					if ragdollPart then
						local weld = ragdollPart:FindFirstChild("WeldConstraint")
						if weld then
							weld.Enabled = not prevent_random_floating
						end
					end
				end
				
				-- Handle right leg
				local rightLeg = character:FindFirstChild("Right Leg") or character:FindFirstChild("RightLowerLeg")
				if rightLeg then
					local ragdollPart = rightLeg:FindFirstChild("RagdollLimbPart")
					if ragdollPart then
						local weld = ragdollPart:FindFirstChild("WeldConstraint")
						if weld then
							weld.Enabled = not prevent_random_floating
						end
					end
				end
			end
		end
	end,
})

-- Fish Limbs Height Slider (only shown for Fish Flopping mode)
local fish_height_slider = main_tab:CreateSlider({
	Name = "Fish Limbs Height",
	Range = {10, 100},
	Increment = 1,
	Suffix = " Studs",
	CurrentValue = 40,
	Flag = "fish_limbs_height",
	Callback = function(value)
		fish_limbs_height = value
	end,
})

-- Defense Tab Content
local defense_section = defense_tab:CreateSection("Anti")

-- Required services and variables
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local localPlayer = game.Players.LocalPlayer

local autoStruggleCoroutine
local antiRagdollCoroutine

-- Anti Grab Toggle
local anti_grab_toggle = defense_tab:CreateToggle({
    Name = "Anti Grab",
    CurrentValue = false,
    Flag = "AutoStruggle", 
    Callback = function(enabled)
        if enabled then
            autoStruggleCoroutine = RunService.Heartbeat:Connect(function()
                local character = localPlayer.Character
                if character and character:FindFirstChild("Head") then
                    local head = character.Head
                    local partOwner = head:FindFirstChild("PartOwner")
                    if partOwner then
                        game:GetService("ReplicatedStorage"):WaitForChild("CharacterEvents"):WaitForChild("Struggle"):FireServer()
                        
                        ReplicatedStorage:WaitForChild("GameCorrectionEvents").StopAllVelocity:FireServer()

                        -- Anchor player
                        for _, part in pairs(character:GetChildren()) do
                            if part:IsA("BasePart") then
                                part.Anchored = true
                            end
                        end
                        
                        -- Wait till held
                        while localPlayer:FindFirstChild("IsHeld").Value do wait() end
                        
                        -- Unanchor player
                        for _, part in pairs(character:GetChildren()) do
                            if part:IsA("BasePart") then
                                part.Anchored = false
                            end
                        end
                    end
                end
            end)
            table.insert(getgenv().script_connections, autoStruggleCoroutine)
        else
            if autoStruggleCoroutine then
                autoStruggleCoroutine:Disconnect()
                autoStruggleCoroutine = nil
            end
        end
    end
})

-- Grab Tab Content
local grab_section = grab_tab:CreateSection("Grab")

-- Required variables for grab functionality
local poisonGrabCoroutine
local fireGrabCoroutine
local poisonHurtParts = {}
local campfire = nil
local firePlayerPart = nil
local campfireMain = nil
local campfireTeleportCoroutine = nil
local firePlayerPartTeleportCoroutine = nil
local campfireMainTeleportCoroutine = nil
local lastBurnTimes = {} -- Per-player burn cooldowns
local isBurning = false -- Flag to pause teleport during burns

-- Function to get descendant parts by name
local function getDescendantParts(descendantName)
    local parts = {}
    for _, descendant in ipairs(workspace.Map:GetDescendants()) do
        if descendant:IsA("Part") and descendant.Name == descendantName then
            table.insert(parts, descendant)
        end
    end
    return parts
end

-- Initialize poison hurt parts
poisonHurtParts = getDescendantParts("PoisonHurtPart")

-- Function to spawn campfire
local function spawnCampfire()
    local player = game.Players.LocalPlayer
    local character = player.Character
    if not character then return false end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return false end
    
    -- Spawn campfire near player position
    local playerPos = humanoidRootPart.Position
    local spawnCFrame = CFrame.new(playerPos.X, playerPos.Y + 5, playerPos.Z)
    
    local args = {
        "Campfire",
        spawnCFrame,
        Vector3.new(0, 0, 0)
    }
    
    game:GetService("ReplicatedStorage"):WaitForChild("MenuToys"):WaitForChild("SpawnToyRemoteFunction"):InvokeServer(unpack(args))
    return true
end

-- Function to find and setup campfire
local function setupCampfire()
    local player = game.Players.LocalPlayer
    local spawnedToysFolder = workspace:FindFirstChild(player.Name .. "SpawnedInToys")
    
    if not spawnedToysFolder then
        return false
    end
    
    -- Find the most recently spawned campfire (last child)
    local children = spawnedToysFolder:GetChildren()
    for i = #children, 1, -1 do
        local child = children[i]
        if child.Name == "Campfire" then
            campfire = child
            firePlayerPart = campfire:FindFirstChild("FirePlayerPart")
            campfireMain = campfire:FindFirstChild("Main")
            
            if firePlayerPart and campfireMain then
                -- Disable the weld constraint
                local weldConstraint = firePlayerPart:FindFirstChild("WeldConstraint")
                if weldConstraint then
                    weldConstraint.Enabled = false
                end
                
                -- Start teleporting campfire and firePlayerPart to 0, 400, 0
                campfireTeleportCoroutine = coroutine.create(function()
                    while campfire and campfire.Parent do
                        campfire.FindFirstChild("Main").Position = Vector3.new(0, 400, 0)
                        wait()
                    end
                end)
                coroutine.resume(campfireTeleportCoroutine)
                
                firePlayerPartTeleportCoroutine = coroutine.create(function()
                    while firePlayerPart and firePlayerPart.Parent do
                        if not isBurning then -- Only teleport when not burning
                            firePlayerPart.Position = Vector3.new(0, 400, 0)
                        end
                        wait()
                    end
                end)
                coroutine.resume(firePlayerPartTeleportCoroutine)
                
                campfireMainTeleportCoroutine = coroutine.create(function()
                    while campfireMain and campfireMain.Parent do
                        campfireMain.Position = Vector3.new(0, 400, 0)
                        wait()
                    end
                end)
                coroutine.resume(campfireMainTeleportCoroutine)
                
                return true
            end
        end
    end
    
    return false
end

-- Function to check and respawn campfire if needed
local function checkAndRespawnCampfire()
    if not campfire or not campfire.Parent or not firePlayerPart or not firePlayerPart.Parent or not campfireMain or not campfireMain.Parent then
        print("Campfire deleted, respawning...")
        
        -- Clean up old coroutines
        if campfireTeleportCoroutine then
            coroutine.close(campfireTeleportCoroutine)
            campfireTeleportCoroutine = nil
        end
        if firePlayerPartTeleportCoroutine then
            coroutine.close(firePlayerPartTeleportCoroutine)
            firePlayerPartTeleportCoroutine = nil
        end
        if campfireMainTeleportCoroutine then
            coroutine.close(campfireMainTeleportCoroutine)
            campfireMainTeleportCoroutine = nil
        end
        
        -- Reset variables
        campfire = nil
        firePlayerPart = nil
        campfireMain = nil
        
        -- Spawn new campfire
        if spawnCampfire() then
            -- Wait for new campfire to spawn and set it up
            spawn(function()
                local attempts = 0
                while attempts < 50 and (not campfire or not firePlayerPart or not campfireMain) do
                    wait(0.5)
                    setupCampfire()
                    attempts = attempts + 1
                end
                
                if not campfire or not firePlayerPart or not campfireMain then
                    print("Failed to respawn campfire")
                else
                    print("Campfire respawned successfully!")
                end
            end)
        end
    end
end

-- Grab handler function
local function grabHandler(grabType)
    while true do
        local success, err = pcall(function()
            -- Check campfire status for fire grab
            if grabType == "fire" then
                checkAndRespawnCampfire()
            end
            
            local child = workspace:FindFirstChild("GrabParts")
            if child and child.Name == "GrabParts" then
                local grabPart = child:FindFirstChild("GrabPart")
                local grabbedPart = grabPart:FindFirstChild("WeldConstraint").Part1
                local head = grabbedPart.Parent:FindFirstChild("Head")
                if head then
                    while workspace:FindFirstChild("GrabParts") do
                        if grabType == "poison" then
                            for _, part in pairs(poisonHurtParts) do
                                part.Size = Vector3.new(2, 2, 2)
                                part.Transparency = 1
                                part.Position = head.Position
                            end
                            wait()
                            for _, part in pairs(poisonHurtParts) do
                                part.Position = Vector3.new(0, -200, 0)
                            end
                        elseif grabType == "fire" and firePlayerPart and firePlayerPart.Parent then
                            -- Get player identifier for per-player cooldown
                            local targetPlayer = grabbedPart.Parent
                            local playerKey = targetPlayer.Name or tostring(targetPlayer)
                            
                            -- Check if enough time has passed since last burn for THIS player (3.5 second cooldown)
                            local currentTime = tick()
                            local lastBurnTime = lastBurnTimes[playerKey] or 0
                            
                            if currentTime - lastBurnTime >= 3.5 then
                                -- Set burning flag to pause teleport
                                isBurning = true
                                
                                -- Teleport firePlayerPart to the grabbed player's head
                                firePlayerPart.Position = head.Position
                                lastBurnTimes[playerKey] = currentTime
                                wait(0.5) -- Burn time
                                
                                -- Reset burning flag and teleport back to safe position
                                isBurning = false
                                if firePlayerPart and firePlayerPart.Parent then
                                    firePlayerPart.Position = Vector3.new(0, 400, 0)
                                end
                            end
                        end
                        wait()
                    end
                    -- Clean up after grab ends
                    if grabType == "poison" then
                        for _, part in pairs(poisonHurtParts) do
                            part.Position = Vector3.new(0, -200, 0)
                        end
                    elseif grabType == "fire" and firePlayerPart and firePlayerPart.Parent then
                        firePlayerPart.Position = Vector3.new(0, 400, 0)
                    end
                end
            end
        end)
        wait()
    end
end

local poison_grab_toggle = grab_tab:CreateToggle({
    Name = "Poison Grab (Broken)",
    CurrentValue = false,
    Flag = "", 
    Callback = function(enabled)
        if enabled then
            poisonGrabCoroutine = coroutine.create(function() grabHandler("poison") end)
            coroutine.resume(poisonGrabCoroutine)
        else
            if poisonGrabCoroutine then
                coroutine.close(poisonGrabCoroutine)
                poisonGrabCoroutine = nil
                for _, part in pairs(poisonHurtParts) do
                    part.Position = Vector3.new(0, -200, 0)
                end
            end
        end
    end
})

local fire_grab_toggle = grab_tab:CreateToggle({
    Name = "Fire Grab",
    CurrentValue = false,
    Flag = "",
    Callback = function(enabled)
        if enabled then
            -- Check if campfire is already set up
            if not campfire or not firePlayerPart then
                print("Spawning campfire...")
                if spawnCampfire() then
                    -- Wait for campfire to spawn and then set it up
                    spawn(function()
                        local attempts = 0
                        while attempts < 50 and (not campfire or not firePlayerPart) do
                            wait(0.5)
                            setupCampfire()
                            attempts = attempts + 1
                        end
                        
                        if campfire and firePlayerPart then
                            print("Campfire setup complete!")
                            fireGrabCoroutine = coroutine.create(function() grabHandler("fire") end)
                            coroutine.resume(fireGrabCoroutine)
                        else
                            print("Failed to setup campfire. Disabling fire grab.")
                            fire_grab_toggle:Set(false)
                        end
                    end)
                else
                    print("Failed to spawn campfire. Disabling fire grab.")
                    fire_grab_toggle:Set(false)
                end
            else
                -- Campfire already exists, start fire grab
                fireGrabCoroutine = coroutine.create(function() grabHandler("fire") end)
                coroutine.resume(fireGrabCoroutine)
            end
        else
            -- Disable fire grab
            if fireGrabCoroutine then
                coroutine.close(fireGrabCoroutine)
                fireGrabCoroutine = nil
            end
            
            -- Stop teleport coroutines and clean up
            if campfireTeleportCoroutine then
                coroutine.close(campfireTeleportCoroutine)
                campfireTeleportCoroutine = nil
            end
            
            if firePlayerPartTeleportCoroutine then
                coroutine.close(firePlayerPartTeleportCoroutine)
                firePlayerPartTeleportCoroutine = nil
            end
            
            if campfireMainTeleportCoroutine then
                coroutine.close(campfireMainTeleportCoroutine)
                campfireMainTeleportCoroutine = nil
            end
            
            -- Reset firePlayerPart position
            if firePlayerPart then
                firePlayerPart.Position = Vector3.new(0, 400, 0)
            end
            
            -- Reset burning flag
            isBurning = false
        end
    end
})

-- PVP Tab Content
local pvp_section = pvp_tab:CreateSection("PVP")

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local strength_control = false
local current_strength = 50
local strength_connection = nil
local strength_heartbeat_connection = nil

-- Just cache the last grabbed part
local last_grabbed_part = nil

local strength_toggle = pvp_tab:CreateToggle({
   Name = "Strength Control",
   CurrentValue = false,
   Flag = "strength_control",
   Callback = function(value)
   	strength_control = value
   	
   	if value then
   		-- Monitor and cache grabbed part
   		strength_heartbeat_connection = RunService.Heartbeat:Connect(function()
   			local grabParts = workspace:FindFirstChild("GrabParts")
   			if grabParts then
   				local grabPart = grabParts:FindFirstChild("GrabPart")
   				if grabPart then
   					local weldConstraint = grabPart:FindFirstChild("WeldConstraint")
   					if weldConstraint and weldConstraint.Part1 then
   						last_grabbed_part = weldConstraint.Part1
   					end
   				end
   			end
   		end)
   		
   		-- UserInputService right-click detection (ignoring gameProcessed)
   		strength_connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
   			if input.UserInputType == Enum.UserInputType.MouseButton2 and last_grabbed_part then
   				local player = game.Players.LocalPlayer
   				
   				if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
   					local camera = workspace.CurrentCamera
   					local lookDirection = camera.CFrame.LookVector
   					
   					local bodyVelocity = Instance.new("BodyVelocity")
   					bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
   					bodyVelocity.Velocity = lookDirection * current_strength
   					bodyVelocity.Parent = last_grabbed_part
   					
   					game:GetService("Debris"):AddItem(bodyVelocity, 0.1)
   				end
   			end
   		end)
   		
   		table.insert(getgenv().script_connections, strength_connection)
   		table.insert(getgenv().script_connections, strength_heartbeat_connection)
   	else
   		if strength_connection then
   			strength_connection:Disconnect()
   			strength_connection = nil
   		end
   		if strength_heartbeat_connection then
   			strength_heartbeat_connection:Disconnect()
   			strength_heartbeat_connection = nil
   		end
   		last_grabbed_part = nil
   	end
   end,
})

local strength_slider = pvp_tab:CreateSlider({
	Name = "Strength",
	Range = {1, 3000},
	Increment = 1,
	Suffix = " Force",
	CurrentValue = 100,
	Flag = "strength_slider",
	Callback = function(value)
		current_strength = value
	end,
})

-- Misc Tab Content
local misc_tab = window:CreateTab("Misc", nil)
local misc_section = misc_tab:CreateSection("Visuals")

local current_fov = 70
local fov_slider = misc_tab:CreateSlider({
	Name = "Field of View",
	Range = {30, 120},
	Increment = 1,
	Suffix = " FOV",
	CurrentValue = current_fov,
	Flag = "fov_slider",
	Callback = function(value)
		current_fov = value
		workspace.CurrentCamera.FieldOfView = value
	end,
})

local third_person_enabled = false
local third_person_distance = 10
local third_person_toggle = misc_tab:CreateToggle({
	Name = "3rd Person Camera",
	CurrentValue = false,
	Flag = "third_person",
	Callback = function(value)
		third_person_enabled = value
		local camera = workspace.CurrentCamera
		if value then
			local connection = game:GetService("RunService").RenderStepped:Connect(function()
				if third_person_enabled and game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
					local root = game.Players.LocalPlayer.Character.HumanoidRootPart
					camera.CameraSubject = root
					camera.CFrame = CFrame.new(root.Position - camera.CFrame.LookVector * third_person_distance, root.Position)
				end
			end)
			table.insert(getgenv().script_connections, connection)
		else
			camera.CameraSubject = game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")
		end
	end,
})

local custom_pallets_enabled = false
local pallet_color = Color3.new(1, 1, 1)

local function update_pallet_colors()
	local player_name = game.Players.LocalPlayer.Name
	local spawned_toys = workspace:FindFirstChild(player_name .. "SpawnedInToys")
	local target_color = custom_pallets_enabled and pallet_color or Color3.fromRGB(234, 215, 198)
	
	if spawned_toys then
		for _, child in pairs(spawned_toys:GetChildren()) do
			if string.find(child.Name, "Pallet") then
				for _, pallet_part in pairs(child:GetChildren()) do
					if pallet_part.Name ~= "PlayerValue" and pallet_part.Name ~= "ThisToysNumber" and pallet_part:IsA("BasePart") then
						pallet_part.Color = target_color
					end
				end
			end
		end
	end
end

local function setup_pallet_monitoring()
	local player_name = game.Players.LocalPlayer.Name
	local spawned_toys = workspace:FindFirstChild(player_name .. "SpawnedInToys")
	
	if spawned_toys then
		local connection = spawned_toys.ChildAdded:Connect(function(child)
			if string.find(child.Name, "Pallet") then
				child.ChildAdded:Connect(function(pallet_part)
					if pallet_part.Name ~= "PlayerValue" and pallet_part.Name ~= "ThisToysNumber" and pallet_part:IsA("BasePart") then
						local target_color = custom_pallets_enabled and pallet_color or Color3.fromRGB(234, 215, 198)
						pallet_part.Color = target_color
					end
				end)
				
				for _, pallet_part in pairs(child:GetChildren()) do
					if pallet_part.Name ~= "PlayerValue" and pallet_part.Name ~= "ThisToysNumber" and pallet_part:IsA("BasePart") then
						local target_color = custom_pallets_enabled and pallet_color or Color3.fromRGB(234, 215, 198)
						pallet_part.Color = target_color
					end
				end
			end
		end)
		table.insert(getgenv().script_connections, connection)
	end
end

local custom_pallets_toggle = misc_tab:CreateToggle({
	Name = "Custom Pallets",
	CurrentValue = false,
	Flag = "custom_pallets",
	Callback = function(value)
		custom_pallets_enabled = value
		update_pallet_colors()
		if value then
			setup_pallet_monitoring()
		end
	end,
})

local pallet_color_picker = misc_tab:CreateColorPicker({
	Name = "Pallet Color",
	Color = Color3.new(1, 1, 1),
	Flag = "pallet_color",
	Callback = function(value)
		pallet_color = value
		if custom_pallets_enabled then
			update_pallet_colors()
		end
	end,
})

local world_section = misc_tab:CreateSection("World")

local original_skybox = {}
local gray_sky_enabled = false
local gray_sky_toggle = misc_tab:CreateToggle({
	Name = "Gray Sky",
	CurrentValue = false,
	Flag = "gray_sky",
	Callback = function(value)
		gray_sky_enabled = value
		local lighting = game:GetService("Lighting")
		
		if value then
			original_skybox = {
				SkyboxBk = lighting.Sky and lighting.Sky.SkyboxBk or "",
				SkyboxDn = lighting.Sky and lighting.Sky.SkyboxDn or "",
				SkyboxFt = lighting.Sky and lighting.Sky.SkyboxFt or "",
				SkyboxLf = lighting.Sky and lighting.Sky.SkyboxLf or "",
				SkyboxRt = lighting.Sky and lighting.Sky.SkyboxRt or "",
				SkyboxUp = lighting.Sky and lighting.Sky.SkyboxUp or ""
			}
			
			if not lighting.Sky then
				local sky = Instance.new("Sky")
				sky.Parent = lighting
			end
			
			lighting.Sky.SkyboxBk = "rbxassetid://130997299852363"
			lighting.Sky.SkyboxDn = "rbxassetid://130997299852363"
			lighting.Sky.SkyboxFt = "rbxassetid://130997299852363"
			lighting.Sky.SkyboxLf = "rbxassetid://130997299852363"
			lighting.Sky.SkyboxRt = "rbxassetid://130997299852363"
			lighting.Sky.SkyboxUp = "rbxassetid://130997299852363"
		else
			if lighting.Sky then
				lighting.Sky.SkyboxBk = original_skybox.SkyboxBk
				lighting.Sky.SkyboxDn = original_skybox.SkyboxDn
				lighting.Sky.SkyboxFt = original_skybox.SkyboxFt
				lighting.Sky.SkyboxLf = original_skybox.SkyboxLf
				lighting.Sky.SkyboxRt = original_skybox.SkyboxRt
				lighting.Sky.SkyboxUp = original_skybox.SkyboxUp
			end
		end
	end,
})

local current_time = 11
local time_slider = misc_tab:CreateSlider({
	Name = "World Time",
	Range = {0, 24},
	Increment = 0.1,
	Suffix = "",
	CurrentValue = current_time,
	Flag = "time_slider",
	Callback = function(value)
		current_time = value
		game:GetService("Lighting").TimeOfDay = value
	end,
})

-- When GUI is visible, open toys menu so that the mouse isnt locked.
local UserInputService = game:GetService("UserInputService")

-- Ensure global vars exist
getgenv().auto_e_connection = getgenv().auto_e_connection or nil

-- Cleanup old connection if script is re-run
if getgenv().auto_e_connection then
	getgenv().auto_e_connection:Disconnect()
	getgenv().auto_e_connection = nil
end

-- Add new connection safely
getgenv().auto_e_connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if not getgenv().script_running then return end
	if gameProcessed then return end

	if input.KeyCode == Enum.KeyCode.K then
		game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.E, false, game)
		task.wait()
		game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.E, false, game)
	end
end)

local coins_section = misc_tab:CreateSection("Coins")

-- Auto Slot Machine Variables
local auto_slot_enabled = false
local slot_connection = nil
local slot_cooldown_start = 0
local slot_attempts = 0
local max_attempts = 5
local cooldown_duration = 1200 -- 20 minutes in seconds

-- Auto Slot Machine Toggle
local auto_slot_toggle = misc_tab:CreateToggle({
	Name = "Auto Slot Machine",
	CurrentValue = false,
	Flag = "auto_slot_machine",
	Callback = function(value)
		auto_slot_enabled = value
		
		if value then
			slot_connection = game:GetService("RunService").Heartbeat:Connect(function()
				if not auto_slot_enabled or not getgenv().script_running then return end
				
				-- Check if we're in cooldown
				if slot_cooldown_start > 0 then
					if tick() - slot_cooldown_start < cooldown_duration then
						return -- Still in cooldown
					else
						-- Cooldown finished, reset
						slot_cooldown_start = 0
						slot_attempts = 0
						print("Slot machine cooldown finished, resuming attempts")
					end
				end
				
				-- Try to find available slot machine
				local slots = workspace:FindFirstChild("Slots")
				if not slots then return end
				
				-- GET FRESH CHILDREN EVERY TIME - this was the issue!
				local slotsChildren = slots:GetChildren()
				local totalSlots = #slotsChildren
				
				if totalSlots == 0 then return end
				
				-- Function to try a specific slot and verify success
				local function trySlotWithVerification(slotIndex)
					if slotIndex < 1 or slotIndex > totalSlots then return false end
					
					local slot = slotsChildren[slotIndex]
					if not slot or slot.Name ~= "Slots" then return false end
					
					local slotHandle = slot:FindFirstChild("SlotHandle")
					if not slotHandle then return false end
					
					local lightBall = slotHandle:FindFirstChild("LightBall")
					if not lightBall then return false end
					
					local handle = slotHandle:FindFirstChild("Handle")
					if not handle then return false end
					
					-- Check if LightBall color matches the "available" color
					local targetColor = Color3.fromRGB(255, 73, 76)
					if lightBall.Color == targetColor then
						print("Found available slot machine at index", slotIndex, "Total slots:", totalSlots)
						
						-- Store original position and initial lightball color
						local player = game.Players.LocalPlayer
						if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
							local root = player.Character.HumanoidRootPart
							local originalPosition = root.CFrame
							local initialColor = lightBall.Color
							
							-- Teleport player to the lightball
							root.CFrame = lightBall.CFrame + Vector3.new(0, 0, -3)
							
							-- Wait a bit
							wait(0.5)
							
							-- Fire the remote with slot handle
							local args = {
								handle,
								handle.CFrame
							}
							
							pcall(function()
								game:GetService("ReplicatedStorage"):WaitForChild("GrabEvents"):WaitForChild("SetNetworkOwner"):FireServer(unpack(args))
							end)
							
							-- Wait for the slot machine to process
							wait(2)
							
							-- Check if the lightball color changed
							local newColor = lightBall.Color
							local colorChanged = (newColor.R ~= initialColor.R or newColor.G ~= initialColor.G or newColor.B ~= initialColor.B)
							
							-- Teleport back to original position
							root.CFrame = originalPosition
							
							if colorChanged then
								print("SUCCESS: Slot machine used successfully at index", slotIndex, "- Color changed from", initialColor, "to", newColor)
								return true -- Success!
							else
								print("FAILED: Slot machine at index", slotIndex, "did not change color - Color remained", newColor)
								return false -- Failed attempt
							end
						end
					end
					return false -- Slot not available
				end
				
				-- Try slots starting from the last one (most recent)
				local success = false
				local attempted = false
				
				for i = totalSlots, math.max(1, totalSlots - 4), -1 do -- Try last 5 slots
					local result = trySlotWithVerification(i)
					if result == true then
						success = true
						attempted = true
						slot_attempts = 0 -- Reset attempts on success
						break
					elseif result == false and slotsChildren[i] and slotsChildren[i]:FindFirstChild("SlotHandle") and slotsChildren[i]:FindFirstChild("SlotHandle"):FindFirstChild("LightBall") then
						-- We found a slot and tried it, but it failed
						local lightBall = slotsChildren[i]:FindFirstChild("SlotHandle"):FindFirstChild("LightBall")
						if lightBall.Color == Color3.fromRGB(255, 73, 76) then
							attempted = true -- We tried an available slot but failed
						end
					end
				end
				
				-- Only count as failed attempt if we actually tried to use a slot
				if attempted and not success then
					slot_attempts = slot_attempts + 1
					print("Failed attempt #" .. slot_attempts .. "/" .. max_attempts)
					
					if slot_attempts >= max_attempts then
						print("Max slot machine attempts reached, entering 20 minute cooldown")
						slot_cooldown_start = tick()
						slot_attempts = 0
					end
				end
				
				-- Add small delay to prevent spam
				wait(1)
			end)
			
			table.insert(getgenv().script_connections, slot_connection)
		else
			if slot_connection then
				slot_connection:Disconnect()
				slot_connection = nil
			end
			-- Reset cooldown and attempts when disabled
			slot_cooldown_start = 0
			slot_attempts = 0
		end
	end,
})

local shortcuts_section = misc_tab:CreateSection("Shortcuts")

-- Shortcut variables
local teleport_enabled = true
local teleport_keybind = Enum.KeyCode.Z
local anchor_enabled = true
local anchor_keybind = Enum.KeyCode.G
local spawn_pallet_enabled = false
local spawn_pallet_keybind = Enum.KeyCode.F
local clear_toys_enabled = false
local clear_toys_keybind = Enum.KeyCode.R
local anchored_objects = {}

-- Function to teleport player to camera look direction
local function teleportToCameraLook()
	if not teleport_enabled then return end
	
	local player = game.Players.LocalPlayer
	if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
	
	local camera = workspace.CurrentCamera
	local root = player.Character.HumanoidRootPart
	
	-- Cast a ray from camera position in look direction
	local rayOrigin = camera.CFrame.Position
	local rayDirection = camera.CFrame.LookVector * 1000
	
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
	raycastParams.FilterDescendantsInstances = {player.Character}
	
	local raycastResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
	
	if raycastResult then
		-- Teleport to the hit position with a small offset above
		local teleportPosition = raycastResult.Position + Vector3.new(0, 5, 0)
		root.CFrame = CFrame.new(teleportPosition, teleportPosition + camera.CFrame.LookVector)
	else
		-- If no hit, teleport forward by 100 studs
		local teleportPosition = rayOrigin + rayDirection.Unit * 100
		root.CFrame = CFrame.new(teleportPosition, teleportPosition + camera.CFrame.LookVector)
	end
end

-- Function to anchor/unanchor grabbed part with toggle
local function anchorGrabbedPart()
	if not anchor_enabled then return end
	
	local grabParts = workspace:FindFirstChild("GrabParts")
	if not grabParts then return end
	
	local grabPart = grabParts:FindFirstChild("GrabPart")
	if not grabPart then return end
	
	local weldConstraint = grabPart:FindFirstChild("WeldConstraint")
	if not weldConstraint or not weldConstraint.Part1 then return end
	
	-- Get the second part (the grabbed part)
	local partToAnchor = weldConstraint.Part1
	local parentObject = partToAnchor.Parent
	
	-- Check if parent is already in anchored_objects
	local isAlreadyAnchored = false
	for i, obj in ipairs(anchored_objects) do
		if obj == parentObject then
			isAlreadyAnchored = true
			-- Remove from array
			table.remove(anchored_objects, i)
			break
		end
	end
	
	if isAlreadyAnchored then
		-- Unanchor all parts in the parent
		for _, part in pairs(parentObject:GetDescendants()) do
			if part:IsA("BasePart") then
				part.Anchored = false
			end
		end
		print("Unanchored object:", parentObject.Name)
	else
		-- Anchor all parts in the parent and add to array
		for _, part in pairs(parentObject:GetDescendants()) do
			if part:IsA("BasePart") then
				part.Anchored = true
			end
		end
		table.insert(anchored_objects, parentObject)
		print("Anchored object:", parentObject.Name)
	end
end

-- Function to spawn pallet
local function spawnPallet()
	if not spawn_pallet_enabled then return end
	
	local player = game.Players.LocalPlayer
	local playerGui = player:FindFirstChild("PlayerGui")
	if not playerGui then return end
	
	local menuGui = playerGui:FindFirstChild("MenuGui")
	if not menuGui then return end
	
	local menu = menuGui:FindFirstChild("Menu")
	if not menu then return end
	
	local tabContents = menu:FindFirstChild("TabContents")
	if not tabContents then return end
	
	local toys = tabContents:FindFirstChild("Toys")
	if not toys then return end
	
	local contents = toys:FindFirstChild("Contents")
	if not contents then return end
	
	local palletLightBrown = contents:FindFirstChild("PalletLightBrown")
	if not palletLightBrown then return end
	
	local viewItemButton = palletLightBrown:FindFirstChild("ViewItemButton")
	if not viewItemButton then return end
	
	firesignal(viewItemButton.MouseButton1Click)
	print("Spawned pallet")
end

-- Function to clear toys
local function clearToys()
	if not clear_toys_enabled then return end
	
	local player = game.Players.LocalPlayer
	local playerGui = player:FindFirstChild("PlayerGui")
	if not playerGui then return end
	
	local menuGui = playerGui:FindFirstChild("MenuGui")
	if not menuGui then return end
	
	local menu = menuGui:FindFirstChild("Menu")
	if not menu then return end
	
	local tabContents = menu:FindFirstChild("TabContents")
	if not tabContents then return end
	
	local toyDestroy = tabContents:FindFirstChild("ToyDestroy")
	if not toyDestroy then return end
	
	local contents = toyDestroy:FindFirstChild("Contents")
	if not contents then return end
	
	for _, child in pairs(contents:GetChildren()) do
		local viewItemButton = child:FindFirstChild("ViewItemButton")
		if viewItemButton then
			firesignal(viewItemButton.MouseButton1Click)
		end
	end
	print("Cleared toys")
end

-- Keybind handler
local keybind_connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed or not getgenv().script_running then return end
	
	if input.KeyCode == teleport_keybind then
		teleportToCameraLook()
		print('teleport')
	elseif input.KeyCode == anchor_keybind then
		anchorGrabbedPart()
		print('anchor')
	elseif input.KeyCode == spawn_pallet_keybind then
		spawnPallet()
	elseif input.KeyCode == clear_toys_keybind then
		clearToys()
	end
end)

table.insert(getgenv().script_connections, keybind_connection)

-- Teleport Toggle
local teleport_toggle = misc_tab:CreateToggle({
	Name = "Enable Teleport",
	CurrentValue = true,
	Flag = "teleport_enabled",
	Callback = function(value)
		teleport_enabled = value
	end,
})

-- Teleport Keybind
local teleport_keybind_input = misc_tab:CreateKeybind({
	Name = "Teleport Keybind",
	CurrentKeybind = "Z",
	HoldToInteract = false,
	Flag = "teleport_keybind",
	Callback = function(keybind)
		local keycode = Enum.KeyCode[keybind]
		if keycode then
			teleport_keybind = keycode
		end
	end,
})

-- Anchor Toggle
local anchor_toggle = misc_tab:CreateToggle({
	Name = "Enable Anchor",
	CurrentValue = true,
	Flag = "anchor_enabled",
	Callback = function(value)
		anchor_enabled = value
	end,
})

-- Anchor Keybind
local anchor_keybind_input = misc_tab:CreateKeybind({
	Name = "Anchor Keybind",
	CurrentKeybind = "G",
	HoldToInteract = false,
	Flag = "anchor_keybind",
	Callback = function(keybind)
		local keycode = Enum.KeyCode[keybind]
		if keycode then
			anchor_keybind = keycode
		end
	end,
})

-- Spawn Pallet Toggle
local spawn_pallet_toggle = misc_tab:CreateToggle({
	Name = "Enable Spawn Pallet",
	CurrentValue = false,
	Flag = "spawn_pallet_enabled",
	Callback = function(value)
		spawn_pallet_enabled = value
	end,
})

-- Spawn Pallet Keybind
local spawn_pallet_keybind_input = misc_tab:CreateKeybind({
	Name = "Spawn Pallet Keybind",
	CurrentKeybind = "F",
	HoldToInteract = false,
	Flag = "spawn_pallet_keybind",
	Callback = function(keybind)
		local keycode = Enum.KeyCode[keybind]
		if keycode then
			spawn_pallet_keybind = keycode
		end
	end,
})

-- Clear Toys Toggle
local clear_toys_toggle = misc_tab:CreateToggle({
	Name = "Enable Clear Toys",
	CurrentValue = false,
	Flag = "clear_toys_enabled",
	Callback = function(value)
		clear_toys_enabled = value
	end,
})

-- Clear Toys Keybind
local clear_toys_keybind_input = misc_tab:CreateKeybind({
	Name = "Clear Toys Keybind",
	CurrentKeybind = "R",
	HoldToInteract = false,
	Flag = "clear_toys_keybind",
	Callback = function(keybind)
		local keycode = Enum.KeyCode[keybind]
		if keycode then
			clear_toys_keybind = keycode
		end
	end,
})

------------------
-- Hack Prompts --
------------------
local hack_prompts_enabled = false
local hack_prompts_gui = nil
local current_grabbed_object = nil
local fidget_spinner_active = false
local fidget_angular_velocities = {}
local hack_monitor_connection = nil
local npc_bypass_data = {} -- Store original values for restoration
local bypass_connection = nil -- New variable for continuous collision disabling
local bypass_active_character = nil -- New variable to track active bypass character

local function get_grabbed_object()
   local grab_parts = workspace:FindFirstChild("GrabParts")
   if not grab_parts then return nil end
   local grab_part = grab_parts:FindFirstChild("GrabPart")
   if not grab_part then return nil end
   local weld_constraint = grab_part:FindFirstChild("WeldConstraint")
   if not weld_constraint or not weld_constraint.Part1 then return nil end
   return weld_constraint.Part1
end

local function is_npc(character)
    if not character or character.ClassName ~= "Model" then return false end
    local parent = character.Parent
    if not parent then return false end
    local parent_name = parent.Name
    return parent_name == "SpawnedInToys" or parent_name == "Robloxians" or string.match(parent_name, "SpawnedInToys")
end

local function is_character_ragdolled(character)
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return false end
    local ragdolled_value = humanoid:FindFirstChild("Ragdolled")
    if not ragdolled_value or ragdolled_value.ClassName ~= "BoolValue" then return false end
    return ragdolled_value.Value
end

local function disable_npc_collisions(character)
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") and part.Parent == character then
            part.CanCollide = false
        end
    end
    
    -- Also disable ragdoll limb collisions
    local limbs = {"Right Arm", "Left Arm", "Right Leg", "Left Leg"}
    for _, limb_name in pairs(limbs) do
        local limb = character:FindFirstChild(limb_name)
        if limb then
            local ragdoll_limb_part = limb:FindFirstChild("RagdollLimbPart")
            if ragdoll_limb_part and ragdoll_limb_part:IsA("BasePart") then
                ragdoll_limb_part.CanCollide = false
            end
        end
    end
end

local function enable_npc_collisions(character)
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") and part.Parent == character and part.Name ~= "HumanoidRootPart" then
            part.CanCollide = true
        end
    end
    
    -- Also re-enable ragdoll limb collisions
    local limbs = {"Right Arm", "Left Arm", "Right Leg", "Left Leg"}
    for _, limb_name in pairs(limbs) do
        local limb = character:FindFirstChild(limb_name)
        if limb then
            local ragdoll_limb_part = limb:FindFirstChild("RagdollLimbPart")
            if ragdoll_limb_part and ragdoll_limb_part:IsA("BasePart") then
                ragdoll_limb_part.CanCollide = true
            end
        end
    end
end

local function ragdoll_character(character_or_part)
   local character
   if character_or_part.ClassName == "Model" then
       character = character_or_part
   else
       character = character_or_part.Parent
   end

   if not character then return false end
   local humanoid_root_part = character:FindFirstChild("HumanoidRootPart")
   if not humanoid_root_part then return false end
   local original_position = humanoid_root_part.CFrame
   local success = pcall(function()
       if not is_character_ragdolled(character) then
           humanoid_root_part.AssemblyLinearVelocity = Vector3.new(0, -3000, 0)
           wait(0.2)
           humanoid_root_part.CFrame = original_position
       end
   end)
   return success
end

local function bypass_house_barrier()
    local grabbed_object = get_grabbed_object()
    if not grabbed_object then return end
    
    local character = grabbed_object.Parent
    if not is_npc(character) then return end
    
    local humanoid = character:FindFirstChild("Humanoid")
    local torso = character:FindFirstChild("Torso")
    local head = character:FindFirstChild("Head")
    
    if humanoid and torso then
        -- Store original values for restoration
        npc_bypass_data[character] = {
            requires_neck = humanoid.RequiresNeck,
            ragdoll_neck_constraint = nil,
            collisions_disabled = true
        }
        
        humanoid.RequiresNeck = false
        
        ragdoll_character(grabbed_object)
        
        wait(0.4)
        
        local ball_socket_constraint = head:FindFirstChild("BallSocketConstraint")
        if ball_socket_constraint then
            npc_bypass_data[character].ragdoll_neck_constraint = {
                constraint = ball_socket_constraint,
                enabled = ball_socket_constraint.Enabled
            }
            ball_socket_constraint.Enabled = false
        end
        
        -- Initial collision disable
        disable_npc_collisions(character)
        
        -- Set up continuous collision disabling (like noclip grab)
        bypass_active_character = character
        
        if bypass_connection then
            bypass_connection:Disconnect()
        end
        
        bypass_connection = game:GetService("RunService").Heartbeat:Connect(function()
            if bypass_active_character and bypass_active_character.Parent then
                -- Continuously enforce CanCollide = false (to override server changes)
                for _, part in pairs(bypass_active_character:GetDescendants()) do
                    if part:IsA("BasePart") and part.Parent == bypass_active_character then
                        part.CanCollide = false
                    end
                end
            else
                -- Character was destroyed, clean up
                if bypass_connection then
                    bypass_connection:Disconnect()
                    bypass_connection = nil
                end
                bypass_active_character = nil
            end
        end)
        
        table.insert(getgenv().script_connections, bypass_connection)
    end
end

local function restore_npc_state(character)
    local stored_data = npc_bypass_data[character]
    if not stored_data then return end
    
    -- Stop continuous collision disabling for this character
    if bypass_active_character == character then
        if bypass_connection then
            bypass_connection:Disconnect()
            bypass_connection = nil
        end
        bypass_active_character = nil
    end
    
    local humanoid = character:FindFirstChild("Humanoid")
    local torso = character:FindFirstChild("Torso")
    
    if humanoid then
        -- Restore RequiresNeck
        humanoid.RequiresNeck = stored_data.requires_neck
    end
    
    if torso then
        -- Re-enable RagdollNeck0 attachment
        local ragdoll_neck = torso:FindFirstChild("RagdollNeck0")
        if ragdoll_neck and stored_data.ragdoll_neck_enabled ~= nil then
            ragdoll_neck.Enabled = stored_data.ragdoll_neck_enabled
        end
    end
    
    -- Re-enable collisions
    if stored_data.collisions_disabled then
        enable_npc_collisions(character)
    end
    
    -- Clean up stored data
    npc_bypass_data[character] = nil
end

local function ground_shove_character(character_or_part)
   local character
   if character_or_part.ClassName == "Model" then
       character = character_or_part
   else
       character = character_or_part.Parent
   end
   if not character then return false end
   local humanoid_root_part = character:FindFirstChild("HumanoidRootPart")
   if not humanoid_root_part then return false end
   local original_position = humanoid_root_part.CFrame
   local success = pcall(function()
       if not is_character_ragdolled(character) then
           humanoid_root_part.AssemblyLinearVelocity = Vector3.new(0, -3000, 0)
           wait(0.2)
           humanoid_root_part.CFrame = original_position
        else
           humanoid_root_part.CFrame = CFrame.new(original_position.Position.X, -20, original_position.Position.Z)
           wait(0.15)
           humanoid_root_part.CFrame = original_position
       end
   end)
   return success
end

local function create_hack_prompts_gui(target_part)
   local player_gui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
   local existing_gui = player_gui:FindFirstChild("HackPromptsGui")
   if existing_gui then
       existing_gui:Destroy()
   end
   
   local character = target_part.Parent
   local is_npc_character = is_npc(character)
   
   local screen_gui = Instance.new("ScreenGui")
   screen_gui.Name = "HackPromptsGui"
   screen_gui.ResetOnSpawn = false
   screen_gui.Parent = player_gui
   
   -- Adjust main frame size based on whether it's an NPC
   local frame_width = is_npc_character and 335 or 230
   local main_frame = Instance.new("Frame")
   main_frame.Size = UDim2.new(0, frame_width, 0, 26)
   main_frame.Position = UDim2.new(0.5, -frame_width/2, 0, 10)
   main_frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
   main_frame.BackgroundTransparency = 0
   main_frame.BorderSizePixel = 0
   main_frame.Parent = screen_gui
   
   local corner = Instance.new("UICorner")
   corner.CornerRadius = UDim.new(0, 4)
   corner.Parent = main_frame
   
   local kill_button = Instance.new("TextButton")
   kill_button.Size = UDim2.new(0, 47, 1, 0)
   kill_button.Position = UDim2.new(0, 2, 0, 0)
   kill_button.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
   kill_button.Text = "Kill (G)"
   kill_button.TextColor3 = Color3.fromRGB(255, 255, 255)
   kill_button.TextSize = 12
   kill_button.Font = Enum.Font.SourceSansBold
   kill_button.BorderSizePixel = 0
   kill_button.Parent = main_frame
   
   local kill_corner = Instance.new("UICorner")
   kill_corner.CornerRadius = UDim.new(0, 2)
   kill_corner.Parent = kill_button
   
   local separator1 = Instance.new("Frame")
   separator1.Size = UDim2.new(0, 2, 1, 0)
   separator1.Position = UDim2.new(0, 49, 0, 0)
   separator1.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
   separator1.BorderSizePixel = 0
   separator1.ZIndex = 10
   separator1.Parent = main_frame
   
   local fidget_button = Instance.new("TextButton")
   fidget_button.Size = UDim2.new(0, 50, 1, 0)
   fidget_button.Position = UDim2.new(0, 51, 0, 0)
   fidget_button.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
   fidget_button.Text = fidget_spinner_active and "Stop (H)" or "Spin (H)"
   fidget_button.TextColor3 = Color3.fromRGB(255, 255, 255)
   fidget_button.TextSize = 12
   fidget_button.Font = Enum.Font.SourceSansBold
   fidget_button.BorderSizePixel = 0
   fidget_button.Parent = main_frame
   
   local fidget_corner = Instance.new("UICorner")
   fidget_corner.CornerRadius = UDim.new(0, 2)
   fidget_corner.Parent = fidget_button
   
   local separator2 = Instance.new("Frame")
   separator2.Size = UDim2.new(0, 2, 1, 0)
   separator2.Position = UDim2.new(0, 101, 0, 0)
   separator2.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
   separator2.BorderSizePixel = 0
   separator2.ZIndex = 10
   separator2.Parent = main_frame
   
   local ragdoll_button = Instance.new("TextButton")
   ragdoll_button.Size = UDim2.new(0, 62, 1, 0)
   ragdoll_button.Position = UDim2.new(0, 103, 0, 0)
   ragdoll_button.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
   ragdoll_button.Text = "Ragdoll (T)"
   ragdoll_button.TextColor3 = Color3.fromRGB(255, 255, 255)
   ragdoll_button.TextSize = 12
   ragdoll_button.Font = Enum.Font.SourceSansBold
   ragdoll_button.BorderSizePixel = 0
   ragdoll_button.Parent = main_frame
   
   local ragdoll_corner = Instance.new("UICorner")
   ragdoll_corner.CornerRadius = UDim.new(0, 2)
   ragdoll_corner.Parent = ragdoll_button
   
   local separator3 = Instance.new("Frame")
   separator3.Size = UDim2.new(0, 2, 1, 0)
   separator3.Position = UDim2.new(0, 165, 0, 0)
   separator3.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
   separator3.BorderSizePixel = 0
   separator3.ZIndex = 10
   separator3.Parent = main_frame
   
   local ground_shove_button = Instance.new("TextButton")
   ground_shove_button.Size = UDim2.new(0, 62, 1, 0)
   ground_shove_button.Position = UDim2.new(0, 167, 0, 0)
   ground_shove_button.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
   ground_shove_button.Text = "Shove (V)"
   ground_shove_button.TextColor3 = Color3.fromRGB(255, 255, 255)
   ground_shove_button.TextSize = 12
   ground_shove_button.Font = Enum.Font.SourceSansBold
   ground_shove_button.BorderSizePixel = 0
   ground_shove_button.Parent = main_frame
   
   local ground_shove_corner = Instance.new("UICorner")
   ground_shove_corner.CornerRadius = UDim.new(0, 2)
   ground_shove_corner.Parent = ground_shove_button
   
   -- Add NPC Bypass button if it's an NPC
   local bypass_button = nil
   if is_npc_character then
       local separator4 = Instance.new("Frame")
       separator4.Size = UDim2.new(0, 2, 1, 0)
       separator4.Position = UDim2.new(0, 229, 0, 0)
       separator4.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
       separator4.BorderSizePixel = 0
       separator4.ZIndex = 10
       separator4.Parent = main_frame
       
       bypass_button = Instance.new("TextButton")
       bypass_button.Size = UDim2.new(0, 104, 1, 0)
       bypass_button.Position = UDim2.new(0, 231, 0, 0)
       bypass_button.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
       bypass_button.Text = "Bypass Houses (U)"
       bypass_button.TextColor3 = Color3.fromRGB(255, 255, 255)
       bypass_button.TextSize = 12
       bypass_button.Font = Enum.Font.SourceSansBold
       bypass_button.BorderSizePixel = 0
       bypass_button.Parent = main_frame
       
       local bypass_corner = Instance.new("UICorner")
       bypass_corner.CornerRadius = UDim.new(0, 2)
       bypass_corner.Parent = bypass_button
       
       bypass_button.MouseButton1Click:Connect(function()
           bypass_house_barrier()
       end)
   end
   
   kill_button.MouseButton1Click:Connect(function()
   	kill_grabbed_character()
   end)
   
   fidget_button.MouseButton1Click:Connect(function()
   	if fidget_spinner_active then
   		stop_fidget_spinner()
   	else
   		start_fidget_spinner()
   	end
   end)
   
   ragdoll_button.MouseButton1Click:Connect(function()
   	ragdoll_grabbed_character()
   end)
   
   ground_shove_button.MouseButton1Click:Connect(function()
   	ground_shove_grabbed_character()
   end)
   
   return screen_gui
end

local function kill_grabbed_character()
   local grabbed_object = get_grabbed_object()
   if not grabbed_object then return end
   local parent = grabbed_object.Parent
   local humanoid = parent:FindFirstChild("Humanoid")
   if humanoid then
   	humanoid.Health = 0
   	local grab_parts = workspace:FindFirstChild("GrabParts")
   	if grab_parts then
   		grab_parts:Destroy()
   	end
    mouse1click()
   end
end

local function ragdoll_grabbed_character()
   local grabbed_object = get_grabbed_object()
   if not grabbed_object then return end
   ragdoll_character(grabbed_object)
end

local function ground_shove_grabbed_character()
   local grabbed_object = get_grabbed_object()
   if not grabbed_object then return end
   ground_shove_character(grabbed_object)
end

local function stop_fidget_spinner()
   for _, angular_velocity in pairs(fidget_angular_velocities) do
   	if angular_velocity then
   		angular_velocity:Destroy()
   	end
   end
   fidget_angular_velocities = {}
   fidget_spinner_active = false
   if hack_prompts_gui then
       hack_prompts_gui:Destroy()
       local grabbed_object = get_grabbed_object()
       if grabbed_object then
           hack_prompts_gui = create_hack_prompts_gui(grabbed_object)
       end
   end
end

local function start_fidget_spinner()
   local grabbed_object = get_grabbed_object()
   if not grabbed_object then return end
   local parent = grabbed_object.Parent
   local limbs = {"Right Arm", "Left Arm", "Right Leg", "Left Leg"}
   stop_fidget_spinner()
   for _, limb_name in pairs(limbs) do
   	local limb = parent:FindFirstChild(limb_name)
   	if limb then
   		local ball_socket = limb:FindFirstChild("BallSocketConstraint")
   		if ball_socket then
   			ball_socket.TwistLowerAngle = -180
   			ball_socket.TwistUpperAngle = 180
   			local body_angular_velocity = Instance.new("BodyAngularVelocity")
   			body_angular_velocity.AngularVelocity = Vector3.new(0, 50, 0)
   			body_angular_velocity.MaxTorque = Vector3.new(0, math.huge, 0)
   			body_angular_velocity.Parent = limb
   			table.insert(fidget_angular_velocities, body_angular_velocity)
   		end
   	end
   end
   fidget_spinner_active = true
   if hack_prompts_gui then
       hack_prompts_gui:Destroy()
       hack_prompts_gui = create_hack_prompts_gui(grabbed_object)
   end
end

local function update_hack_prompts()
   if not hack_prompts_enabled then return end
   local grabbed_object = get_grabbed_object()
   
   -- Check if GrabParts was deleted (NPC released)
   if not workspace:FindFirstChild("GrabParts") and current_grabbed_object then
       local character = current_grabbed_object.Parent
       if is_npc(character) then
           restore_npc_state(character)
       end
   end
   
   if not grabbed_object or not workspace:FindFirstChild("GrabParts") then
   	if hack_prompts_gui then
   		hack_prompts_gui:Destroy()
   		hack_prompts_gui = nil
   	end
   	current_grabbed_object = nil
   	return
   end
   
   if grabbed_object.Parent:FindFirstChild("Humanoid") then
   	if not hack_prompts_gui or current_grabbed_object ~= grabbed_object then
   		if hack_prompts_gui then
   			hack_prompts_gui:Destroy()
   		end
   		hack_prompts_gui = create_hack_prompts_gui(grabbed_object)
   	end
   	current_grabbed_object = grabbed_object
   else
   	if hack_prompts_gui then
   		hack_prompts_gui:Destroy()
   		hack_prompts_gui = nil
   	end
   	current_grabbed_object = nil
   end
end

local hack_prompts_keybind_connection = UserInputService.InputBegan:Connect(function(input, game_processed)
   if game_processed or not hack_prompts_enabled or not getgenv().script_running then return end
   if input.KeyCode == Enum.KeyCode.G then
   	kill_grabbed_character()
   elseif input.KeyCode == Enum.KeyCode.H then
   	if fidget_spinner_active then
   		stop_fidget_spinner()
   	else
   		start_fidget_spinner()
   	end
   elseif input.KeyCode == Enum.KeyCode.T then
   	ragdoll_grabbed_character()
   elseif input.KeyCode == Enum.KeyCode.V then
   	ground_shove_grabbed_character()
   elseif input.KeyCode == Enum.KeyCode.U then
   	bypass_house_barrier()
   elseif input.KeyCode == Enum.KeyCode.J then
   	stop_fidget_spinner()
   end
end)

table.insert(getgenv().script_connections, hack_prompts_keybind_connection)

local hack_section = misc_tab:CreateSection("Hack Prompts")

local hack_prompts_toggle = misc_tab:CreateToggle({
   Name = "Hack Prompts",
   CurrentValue = false,
   Flag = "hack_prompts",
   Callback = function(value)
   	hack_prompts_enabled = value
   	if value then
   		hack_monitor_connection = game:GetService("RunService").Heartbeat:Connect(function()
   			if hack_prompts_enabled and getgenv().script_running then
   				update_hack_prompts()
   			end
   		end)
   		table.insert(getgenv().script_connections, hack_monitor_connection)
   	else
   		if hack_monitor_connection then
   			hack_monitor_connection:Disconnect()
   			hack_monitor_connection = nil
   		end
   		if hack_prompts_gui then
   			hack_prompts_gui:Destroy()
   			hack_prompts_gui = nil
   		end
   		stop_fidget_spinner()
   		-- Clean up bypass connection when hack prompts are disabled
   		if bypass_connection then
   			bypass_connection:Disconnect()
   			bypass_connection = nil
   		end
   		bypass_active_character = nil
   		-- Clean up any stored NPC data
   		npc_bypass_data = {}
   	end
   end,
})