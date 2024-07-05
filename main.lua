local cfg = require "BeefStranger.Exp Tracking.config"
local bs = {}
local sf = string.format
local fadeTimer---@type mwseTimer
local softFade---@type mwseTimer
--- @param e loadedEventData
local function loadedCallback(e)
    local multiMenu = bs.multiMenu()
    local resetExp = multiMenu:findChild("Exp")

    if resetExp then
        multiMenu:findChild("Exp"):destroy()
    end
    -- debug.log(multiMenu)

    local exp = multiMenu:createFillBar({ id = "Exp", max = 100})
    exp.contentPath = ""
    exp.ignoreLayoutY = true
    exp.ignoreLayoutX = true
    exp.scaleMode = true
    exp.imageScaleY = 0.01
    exp.flowDirection = tes3.flowDirection.topToBottom

    exp.height = 13
    exp.width = tes3ui.getViewportSize()
    exp.absolutePosAlignY = 1
    exp.visible = false
    exp.color = { 0, 0, 0 }
    exp.children[2].absolutePosAlignY = 0.80
    exp.children[2].text = sf("%s   %s", tes3.skillName[cfg.selectedSkill], exp.children[2].text)
    exp.children[2].alpha = 1
    exp.widget.fillAlpha = 1
end
event.register(tes3.event.loaded, loadedCallback)


---@param e exerciseSkillEventData
local function exerciseSkill(e)
    if not cfg.blacklist[tes3.skillName[e.skill]] then
        local menu = bs.multiMenu():findChild("Exp")
        if menu then
            timer.delayOneFrame(function()
                menu.widget.current = bs.skillProgress(e.skill)
                menu.children[2].text = sf("%s %s  |  %s", tes3.skillName[e.skill], tes3.mobilePlayer:getSkillValue(e.skill), menu.children[2].text)
                menu.visible = true
                menu.children[2].alpha = 1
                menu.widget.fillAlpha = 1

                if fadeTimer then
                    fadeTimer:reset()
                    if softFade then
                        softFade:cancel()
                    end
                else
                   bs.fadeOut(menu)
                end
            end)
        end
    end
end
event.register(tes3.event.exerciseSkill, exerciseSkill)

-----Functions
function bs.multiMenu()
    local multiMenu = tes3ui.findMenu("MenuMulti")
    if multiMenu then
        return multiMenu:findChild("PartNonDragMenu_main")
    end
end

---@param skill tes3.skill
function bs.skillProgress(skill)
    local progress = tes3.mobilePlayer.skillProgress[skill + 1]
    local progressRequirement = tes3.mobilePlayer:getSkillProgressRequirement(skill)
    local normalizedProgress = (progress / progressRequirement) * 100

    return math.floor(normalizedProgress)
end

function bs.softFade(menu) 
    softFade = timer.start {
        duration = 0.1,
        iterations = 20,
        callback = function(e)
            if menu.children[2] and menu.widget.fillAlpha then
                menu.children[2].alpha = menu.children[2].alpha - 0.05
                menu.widget.fillAlpha = menu.widget.fillAlpha - 0.05
            end
        end,
    }
end

function bs.fadeOut(menu) 
    fadeTimer = timer.start {
        duration = cfg.timer,
        callback = function(e)
            -- menu.visible = false
            if softFade then
                softFade:reset()
            else
                bs.softFade(menu)
            end
        end
    }
end

event.register("initialized", function()
    print("[MWSE:Exp Tracking] initialized")
end)