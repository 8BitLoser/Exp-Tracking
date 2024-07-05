local ch = require "BeefStranger.Exp Tracking.configHelper"
local configPath = "Exp Tracking"

local cfg = {
    slider = {},
}

---@class bsExpTracking<K, V>: { [K]: V }
local defaults = {
    blacklist = {
        Acrobatics = false,
        Alchemy = false,
    },
    selectedSkill = tes3.skill["handToHand"],
    timer = 5
}


---@class bsExpTracking
local config = mwse.loadConfig(configPath, defaults)

local function registerModConfig()
    local template = mwse.mcm.createTemplate({ name = configPath })
        template:saveOnClose(configPath, config)

    local settings = template:createPage({ label = "Settings" })

    cfg.slider.timer = settings:createSlider({
        label = "How Long the Exp Bar is Visible Before it Fades  ",
        min = 0, max = 60, step = 1, jump = 5,
        variable = ch.tVar{ id ="timer", table = config},
        convertToLabelValue = function (self, variableValue)
            return string.format("%s Seconds", variableValue)
        end
    })

    cfg.exclusion = template:createExclusionsPage({
        label = "Excluded Skills",
        variable = ch.tVar{ id = "blacklist", table = config},
        filters = {
            {label = "Skills", callback = cfg.getSkills}
        },
    })

    template:register()
end
event.register(tes3.event.modConfigReady, registerModConfig)

function cfg.getSkills()
    local skills = {}

    ch.inspect(config.blacklist)

   for key, value in pairs(tes3.skill) do
        -- debug.log(key)
        -- debug.log(value)
        table.insert(skills, tes3.skillName[value])
   end
   table.sort(skills)
   return skills
end

cfg.getSkills()

return config