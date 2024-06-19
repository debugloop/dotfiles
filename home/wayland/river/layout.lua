-- You can define your global state here
local default_main_size = 0.65
local default_main_count = 1
local default_gravity = "left"
local default_state = {
	main_size = default_main_size,
	main_count = default_main_count,
	gravity = default_gravity,
}

-- This is used to save our per tag state
local state = {}

-- The most important function - the actual layout generator
--
-- The argument is a table with:
--  * Focused tags (`args.tags`)
--  * Window count (`args.count`)
--  * Output width (`args.width`)
--  * Output height (`args.height`)
--  * Output name (`args.output`)
--
-- The return value must be a table with exactly `count` entries. Each entry is a table with four
-- numbers:
--  * X coordinate
--  * Y coordinate
--  * Window width
--  * Window height
function handle_layout(args)
	local saved_state = state[args.tags]
	if saved_state == nil then
		state[args.tags] = default_state
		saved_state = default_state
	end
	local state = saved_state

	local retval = {}
	if args.count <= state.main_count then
		for i = 0, args.count - 1, 1 do
			table.insert(retval, { i * args.width / args.count, 0, args.width / args.count, args.height })
		end
	else
		local main_w = args.width * state.main_size
		local side_w = args.width - main_w
		local side_column, main_column
		if state.gravity == "left" then
			main_column = 0
			side_column = main_w
		elseif state.gravity == "right" then
			main_column = side_w
			side_column = 0
		end
		local side_h = args.height / (args.count - state.main_count)
		for i = 0, state.main_count - 1, 1 do
			table.insert(
				retval,
				{ main_column + (i * main_w / state.main_count), 0, main_w / state.main_count, args.height }
			)
		end
		for i = 0, args.count - state.main_count - 1 do
			table.insert(retval, {
				side_column,
				i * side_h,
				side_w,
				side_h,
			})
		end
	end
	return retval
end

-- This optional function returns the metadata for the current layout.
-- Currently only `name` is supported, the name of the layout. It get's passed
-- the same `args` as handle_layout()
function handle_metadata(args)
	local saved_state = state[args.tags]
	if saved_state == nil then
		saved_state = default_state
	end
	local number, direction, partial
	if saved_state.main_count == 1 then
		number = ""
	elseif saved_state.main_count == 2 then
		number = ""
	else
		number = "󰐖"
	end
	if saved_state.gravity == "left" then
		return { name = number .. " " .. 100 - saved_state.main_size * 100 .. "%" }
	else
		return { name = 100 - saved_state.main_size * 100 .. "%" .. " " .. number }
	end
end

-- Run those with `riverctl send-layout-cmd luatile "gravity_right()"`
function gravity_right()
	local state = state[CMD_TAGS]
	state.gravity = "right"
end

function gravity_left()
	local state = state[CMD_TAGS]
	state.gravity = "left"
end

function gravity_mirror()
	local state = state[CMD_TAGS]
	if state.gravity == "right" then
		state.gravity = "left"
	elseif state.gravity == "left" then
		state.gravity = "right"
	end
end

function main_count_increase()
	local state = state[CMD_TAGS]
	state.main_count = state.main_count + 1
end

function main_count_decrease()
	local state = state[CMD_TAGS]
	state.main_count = state.main_count - 1
	if state.main_count < 1 then
		state.main_count = 1
	end
end

function main_size_increase()
	local state = state[CMD_TAGS]
	state.main_size = state.main_size + 0.05
	if state.main_size > 0.9 then
		state.main_size = 0.9
	end
end

function main_size_decrease()
	local state = state[CMD_TAGS]
	state.main_size = state.main_size - 0.05
	if state.main_size < 0.3 then
		state.main_size = 0.3
	end
end
