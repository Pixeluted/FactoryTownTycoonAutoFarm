local LogsFolder = workspace.Logs

local function findOurLogs()
    local list = {}
    
    for _,theLog in pairs(workspace.Logs:GetChildren()) do
        print("checking")
        if theLog.Name == "Log" then 
           if theLog.Log.Owner.Value == game.Players.LocalPlayer.UserId then
                print("found our log")
                table.insert(list, theLog)
            end 
        end
    end
    
    return list
end

local function findOurFireLogs()
    local list = {}
    
    for _,theLog in pairs(LogsFolder:GetChildren()) do
        if theLog.FireLog.Owner.Value == game.Players.LocalPlayer.UserId then 
            table.insert(list, theLog)
        end
    end
    
    return list
end

local function findClickDetectorInLog(theLog)
    for _,v in pairs(theLog.Log:GetChildren()) do
        if v:IsA("ClickDetector") then
            return v 
        end
    end
end

local function findGrabEventInLog(theLog)
    for _,v in pairs(theLog.Log:GetChildren()) do
        if v:IsA("RemoteEvent") then
            return v 
        end
    end
end

local function findClickDetectorInVendor(theVendor)
    for _,v in pairs(theVendor.Box:GetChildren()) do 
        if v:IsA("ClickDetector") then 
            return v
        end 
    end
end

local function findClickDetectorInSharpening()
    for _,v in pairs(game:GetService("Workspace")["Area_Sharpening"].Workbench.Box:GetChildren()) do 
        if v:IsA("ClickDetector") then 
            return v    
        end
    end
end

local function teleportLogsToMe()
    local ourLogs = findOurLogs()

    for _,theLog in pairs(ourLogs) do
        local theClickDetector = findClickDetectorInLog(theLog)
        
        fireclickdetector(theClickDetector)
        task.wait(0.1)
        local theGrabEvent = findGrabEventInLog(theLog)
        theGrabEvent:FireServer()
        task.wait(0.3)
        
        if game.Players.LocalPlayer.Character:FindFirstChild("grab") then
            game.Players.LocalPlayer.Character:FindFirstChild("grab"):Destroy()    
        end
    end
end

function findSomeTree(treeType)
    local TreesFolder = workspace.Trees 
    local categoryWeLookingFor = TreesFolder[treeType]
    
    if categoryWeLookingFor then
        return categoryWeLookingFor:GetChildren()[math.random(1, #categoryWeLookingFor:GetChildren())]
    end
end

local function getAllToolsIn(parent)
    local list = {}
    
    for _,v in pairs(parent:GetChildren()) do
        if v:IsA("Tool") then
            table.insert(list, v)    
        end
    end
    
    return list
end

function findOurAxe()
    local foundAxe    
    
    local toolsInBackpack = getAllToolsIn(game.Players.LocalPlayer.Backpack)
    local toolsInCharacter = getAllToolsIn(game.Players.LocalPlayer.Character)
    
    if #toolsInBackpack >= 2 then
        
        print("Should be in backpack")
        for _,tool in pairs(toolsInBackpack) do 
            if string.find(tool.Name, "Axe") then 
                foundAxe = tool 
                print("found")
                break
            end
        end
            
    else 
        
        for _,tool in pairs(toolsInCharacter) do 
            if string.find(tool.Name, "Axe") then 
                foundAxe = tool 
                break
            end
        end
        
    end
    
    return foundAxe
end

function findAllLogsInDistance(distance)
    local ourLogs = findOurLogs()
    local list = {}
    
    for _,Thelog in pairs(ourLogs) do 
        if (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - Thelog.Position).Magnitude <= distance then 
            table.insert(list, Thelog)
        end
    end
    
    return list
end

function chopDownTree(theTree)
    local ourAxe = findOurAxe()
    print(ourAxe.Parent)
    
    ourAxe.Parent = game.Players.LocalPlayer.Character
    
    local theTreeModel = theTree:GetChildren()[1]
    local lastPos = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
    local TrunkPart = theTreeModel.Trunk
    local previousTreeModelParent = theTreeModel.Parent
    
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = theTree.CFrame
    fireclickdetector(findClickDetectorInSharpening())
    
    repeat 
        ourAxe.attacking.Value = true 
        TrunkPart.CutEvent:FireServer()
        task.wait()
    until TrunkPart.Parent.Parent ~= previousTreeModelParent
    
    task.wait(2)
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = TrunkPart.CFrame + Vector3.new(2, 0, 0)
    
    repeat 
        ourAxe.attacking.Value = true 
        TrunkPart.CutEvent:FireServer()
        task.wait()
    until TrunkPart.Parent == nil 
    print("done for small")
    
    task.wait(2)
    
    if #theTreeModel.Logs:GetChildren() ~= 0 then
        for _,treeLog in pairs(theTreeModel.Logs:GetChildren()) do 
             game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = treeLog.CFrame + Vector3.new(2, 0, 0)
             
             repeat 
                ourAxe.attacking.Value = true 
                treeLog.CutEvent:FireServer()
                task.wait()
             until treeLog.Parent == nil 
             
        end
    end
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = lastPos
    teleportLogsToMe()
end

function sellAllLogs()
    local allLogs = findOurLogs()
    local sellClickDetector = findClickDetectorInVendor(game:GetService("Workspace").Vendor["Vendor Logs TEMPLATE"])
    
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game:GetService("Workspace").Vendor["Vendor Logs TEMPLATE"].Box.CFrame
    for _,theLog in pairs(allLogs) do 
        local theClickDetector = findClickDetectorInLog(theLog)
        
        fireclickdetector(theClickDetector)
        fireclickdetector(sellClickDetector)
        task.wait(0.5)
    end
end

while task.wait() do 
    chopDownTree(findSomeTree("Oak"))
    task.wait(1)
    sellAllLogs()    
end
