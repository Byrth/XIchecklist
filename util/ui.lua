texts = require('util/texts')
-- UI CONSTANTS
UI_SCALE		= tonumber(trackermenusettings.ui_scale) or 1
FONT_SIZE		= function() return 12 * UI_SCALE end
LINE_HEIGHT		= function() return 16 * UI_SCALE end
PADDING			= function() return 8 * UI_SCALE end
CHAR_WIDTH		= function() return (FONT_SIZE()/(2*UI_SCALE)) * UI_SCALE end
VISIBLE_ROWS	= 15
-- UI WINDOW STATE
active_tab		= 1
scroll			= 0
selected		= 1
-- UI DATA
tabs = {
    {
        name = 'Main',
        items = {}
    },
    {
        name = 'Story',
        items = {}
    },
    {
        name = 'Campaign',
        items = {}
    },
	{
        name = 'Fish',
        items = {}
    },
	{
        name = 'Key Items',
        items = {}
    },
	{
        name = 'Magic',
        items = {}
    },
	{
        name = 'Warps',
        items = {}
    },
	{
        name = 'Monstrosity',
        items = {}
    },
	{
        name = 'Titles',
        items = {}
    },
	{
        name = 'RoE',
        items = {}
    },
	{
        name = 'Battle Content',
        items = {}
    },
}

-- UI TEXT OBJECT
ui = {}
ui.menu = texts.new('', {
    pos = { x = trackermenusettings.pos.x, y = trackermenusettings.pos.y },
    text = {
        font = 'Arial',
        size = FONT_SIZE(),
        red = 255, green = 255, blue = 255,
    },
    bg = {
        red = 25, green = 25, blue = 25,
        alpha = 200,
    },
    padding = PADDING(),
})

initiate_tabs = function()
	for i, tab in ipairs(tabs) do
		tabs[i].button = texts.new('', {
			pos = { x = ui.menu:pos_x(), y = ui.menu:pos_y()},
			text = {
				font = 'Arial',
				size = FONT_SIZE(),
				red = 255, green = 255, blue = 255,
			},
			bg = {
				red = 25, green = 25, blue = 25,
				alpha = 200,
			},
			padding = PADDING(),
			flags = {
				draggable = false,
			},
		})
		tabs[i].button:text(tab.name)
		tabs[i].button:register_event('left_click', function()
			active_tab = i
			selected = 1
			scroll = 0
			draw()
		end)
	end
end

draw_tabs = function()
	local total_xextent, total_yextent = 0, 0
	for i, tab in ipairs(tabs) do
		tabs[i].button:pos(ui.menu:pos_x()+total_xextent, ui.menu:pos_y())
		tabs[i].button:visible(ui.menu:visible())
		tabs[i].button:size(FONT_SIZE())
		tabs[i].button:pad(PADDING())
		if active_tab == i then
			tabs[i].button:bg_color(70, 130, 200)
			tabs[i].button:bg_alpha(220)
		else
			tabs[i].button:bg_color(25, 25, 25)
			tabs[i].button:bg_alpha(200)
		end
		local xextent, yextent = tabs[i].button:extents()
		total_xextent = total_xextent + xextent
	end
	ui.width = total_xextent
end

append_items = function(dst, src)
    if type(dst) ~= 'table' or type(src) ~= 'table' then
        return
    end
    for _, item in ipairs(src) do
		local text = item.text
		local display = true
		local menucolor = '(255,255,0)'
		if (item.completed == true and trackermenusettings.showcompleted == false) then
			display = false
		end
		if item.completed == true then
			menucolor = '(0,255,0)'
		end
		if item.obtainmethod ~= nil then
			local obtainmethod = '\\cs(255,255,255)[' .. item.obtainmethod .. ']\\cr\\cs'..menucolor
			if item.category == 'Titles' then
				text = obtainmethod..' '..text
			else
				text = text..' '..obtainmethod
			end
		end
		if item.category ~= nil then 
			text = '['..item.category..'] '..text
		end
		local text = '\\cs'..menucolor..text..'\\cr'
		if (display == true) then
			table.insert(dst, text)
		end
    end
end

append_maintab = function(text, ...)
	local args = {...}
	local menulinecolor = '(255,255,0)'
	if (args[1]==args[2]) then menulinecolor = '(0,255,0)' end
	table.insert(tabs[1].items, '\\cs'..menulinecolor..'-'..text:format(...)..'\\cr')
end

append_header = function(tab, text, ...)
	args = {...}
	local menulinecolor = '(255,255,255)'
	if (args[1]==args[2]) then menulinecolor = '(0,255,0)' end
	text = '==== '..text..' ===='
	table.insert(tabs[tab].items, '\\cs'..menulinecolor..text:format(...)..'\\cr')
	if args[2] == 0 then
		table.insert(tabs[tab].items, '\\cs(235,0,0)You must zone to update.\\cr')
	end
end

append_addonhelp = function(tab, text, condition)
	if not (condition and trackermenusettings.showcompleted) then
		append_items(tabs[tab].items, {util.list_item('Addon Help', '\\cs(235,0,0)'..text..'\\cr', condition)})
	end
end

-- UI HELPERS
inside = function(mx, my, x, y, width, h)
	return mx >= x and mx <= x + width
		and my >= y and my <= y + h
end

clamp_scroll = function(count)
	if selected < scroll + 1 then
		scroll = selected - 1
	elseif selected > scroll + VISIBLE_ROWS then
		scroll = selected - VISIBLE_ROWS
	end
	scroll = math.max(0, math.min(scroll, count - VISIBLE_ROWS))
end

draw = function()
	local text = ''
	--text = text .. '\n'.. '─':rep((PADDING()/CHAR_WIDTH())+(ui.width/CHAR_WIDTH())) .. '\n'
	text = text .. '\n───────────────────────────────────────────────────────────────────\n'
	-- List
	local items = tabs[active_tab].items
	local count = #items
	if count == 0 then
		-- add active_tab helper text here
		items = {'\\cs(128,128,128)Change zones to update Quests / Campaigns / Warps / Monstrosity \\cr', '\\cs(128,128,128)Check the README or "//xic help" to register NPC-related data \\cr'}
		count = 1
	end
	clamp_scroll(count)
	for i = 1, VISIBLE_ROWS do
		local idx = i + scroll
		if items[idx] then
			text = text .. (idx == selected and '\\cs(255,0,0)> ' or '  ') .. items[idx] .. '\\cr\n'
		end
	end
	ui.menu:text(text)
	ui.menu:pos(trackermenusettings.pos.x, trackermenusettings.pos.y)
end

initiate_tabs()

-------------------------------------------------
windower.register_event('prerender', function()
	draw_tabs()
end)

windower.register_event('mouse', function(type, x, y, delta, blocked)
	if (ui.menu:visible() == false) then return end
    local px, py = ui.menu:pos()
    local items = tabs[active_tab].items
    local count = #items
	-- save new UI pos if changed
	if (px ~= trackermenusettings.pos.x) and (py ~= trackermenusettings.pos.y) then
		trackermenusettings.pos.x = px
		trackermenusettings.pos.y = py
		trackermenusettings:save()
	end
	-- mouse scroll up down
	if delta and delta ~= 0 then
		if ui.menu:hover(x, y) then
			if delta > 0 then
				selected = math.max(1, selected - 1)
				clamp_scroll(count)
			else
				selected = math.min(count, selected - delta)
				clamp_scroll(count)
			end
			draw()
			return true
		end
	end
end)