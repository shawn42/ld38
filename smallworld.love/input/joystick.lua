
-- TODO: this state should be per-joystick, but we're currently treating
-- all joystick input as if it came from one place, and there can be only
-- one joystick
AxisState={leftx=0, lefty=0, rightx=0, righty=0}

local Mappings = {
  ['Generic   USB  Joystick'] = 'generic'
}

local Layouts = {}

Layouts["generic"] = {
  axes = {
    [1]="leftx",
    [2]="lefty",
    [3]="unknown",
    [4]="rightx",
    [5]="righty",
  },
  buttons = {
    [1] = "face1",
    [2] = "face2",
    [3] = "face3",
    [4] = "face4",
    [5] = "l2",
    [6] = "r2",
    [7] = "l1",
    [8] = "r2",
    [9] = "select",
    [10] = "start",
    [11] = "l3",
    [12] = "r3",
  }
}

-- NOTE
-- This implementation ignores the difference between one joystick and another.
-- (Incoming action.id is a placeholder set to TODO for now.)
-- Because of this, we're mapping ALL joystick input to the given controllerId
local function handleJoystick(action, controllerId, input)
  local layout = Layouts["generic"]
  local axis, value, changed, button
  if action.controlType == 'axis' then
    axis = layout.axes[action.control]
    if not axis then return end
    value = math.round1(action.value)
    changed = false
    if AxisState[axis] ~= value then
      AxisState[axis] = value
      changed = true
    end
    if changed then
      addInputEvent(input, {type='controller', id=controllerId, input=axis, action=value})
    end

  elseif action.controlType == 'button' then
    button = layout.buttons[action.control]
    if button then
      addInputEvent(input, {type='controller', id=controllerId, input=button, action=value})
    else
      print("UNHANDLED JOYSTICK BUTTON"..tdebug(action))
    end
  end
end

return {
  handleJoystick=handleJoystick
}
