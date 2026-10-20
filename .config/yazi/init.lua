-- Vue « Détails » de l'Explorateur : date de modification, type, puis taille (vide pour les dossiers).
function Linemode:details()
	local f = self._file
	local time = math.floor(f.cha.mtime or 0)
	local size = f:size()
	local ext = f.name:match("^.+%.([^.]+)$")
	local kind = f.cha.is_dir and "Dossier" or ext and ("Fichier " .. ext:upper()) or "Fichier"
	return string.format(
		"%s  %-14s %9s",
		time > 0 and os.date("%d/%m/%Y %H:%M", time) or "",
		kind:sub(1, 14),
		size and ya.readable_size(size) or ""
	)
end

-- Barre d'outils cliquable façon Explorateur, devant le chemin : icône (Nerd Font), commande, arguments.
local HOME = os.getenv("HOME")
local TOOLBAR = {
	{ "\u{f060}", "back" }, -- précédent
	{ "\u{f061}", "forward" }, -- suivant
	{ "\u{f062}", "leave" }, -- dossier parent
	{ "│" },
	{ "\u{f0c4}", "yank", { cut = true } }, -- couper
	{ "\u{f0c5}", "yank" }, -- copier
	{ "\u{f0ea}", "paste" }, -- coller
	{ "\u{f0455}", "rename", { cursor = "before_ext" } }, -- renommer
	{ "│" },
	{ "\u{f02b6}", "cd", { HOME .. "/GoogleDrive" } }, -- Google Drive
	{ "│" },
	{ "\u{f002}", "search", { via = "fd" } }, -- rechercher dans ce dossier et ses sous-dossiers (Ctrl + F)
	{ "│" },
}

Header:children_add(function()
	local spans = {}
	for _, b in ipairs(TOOLBAR) do
		spans[#spans + 1] = ui.Span(" " .. b[1] .. " "):style(b[2] and th.mgr.cwd or th.mgr.border_style)
	end
	return ui.Line(spans)
end, 500, Header.LEFT)

function Header:click(event, up)
	if up or not event.is_left then
		return
	end

	local x, w = event.x - self._area.x, 0
	for _, b in ipairs(TOOLBAR) do
		w = w + ui.Line(" " .. b[1] .. " "):width()
		if x < w then
			return b[2] and ya.emit(b[2], b[3] or {})
		end
	end

	-- Fil d'Ariane : un clic sur un dossier du chemin y va.
	-- ponytail: suppose le chemin non tronqué ; à recalculer si les chemins très longs posent problème
	local path = ya.readable_path(tostring(self._current.cwd))
	for i in path:gmatch("()/") do
		if x - w < ui.Line(path:sub(1, i)):width() then
			return ya.emit("cd", { (path:sub(1, i):gsub("^~", HOME)) })
		end
	end
end

-- Menus du clic droit façon Explorateur : libellé, commande yazi, arguments, raccourci affiché.
-- Sur un élément :
local MENU_FILE = {
	{ "Ouvrir", "open", { hovered = true }, "Entrée" },
	{ "Ouvrir avec…", "open", { hovered = true, interactive = true }, "" },
	{},
	{ "Couper", "yank", { cut = true }, "Ctrl+X" },
	{ "Copier", "yank", {}, "Ctrl+C" },
	{ "Coller", "paste", {}, "Ctrl+V" },
	{},
	{ "Renommer", "rename", { cursor = "before_ext" }, "F2" },
	{ "Supprimer", "remove", {}, "Suppr" },
	{},
	{ "Nouveau dossier", "create", { dir = true }, "Ctrl+Maj+N" },
	{ "Copier le chemin d'accès", "copy", { "path" }, "" },
	{},
	{ "Propriétés", "spot", {}, "Alt+Entrée" },
}
-- Dans le vide :
local MENU_EMPTY = {
	{ "Coller", "paste", {}, "Ctrl+V" },
	{},
	{ "Nouveau dossier", "create", { dir = true }, "Ctrl+Maj+N" },
	{ "Nouveau fichier", "create", {}, "" },
	{},
	{ "Trier par nom", "sort", { "natural", reverse = false }, "" },
	{ "Trier par date", "sort", { "mtime", reverse = true }, "" },
	{ "Trier par taille", "sort", { "size", reverse = true }, "" },
	{ "Éléments masqués", "hidden", { "toggle" }, "" },
	{ "Actualiser", "refresh", {}, "F5" },
	{},
	{ "Ouvrir dans le terminal", "shell", { "uwsm app -- ghostty", orphan = true }, "" },
	{ "Copier le chemin d'accès", "copy", { "dirname" }, "" },
}
local menu, press -- menu ouvert { x, y, w, h, url, items } ; dernier clic gauche { url, x, y }

local preset_redraw = Current.redraw
function Current:redraw()
	local elements = preset_redraw(self)
	-- Déplacer le curseur au clavier referme le menu (une fois le curseur arrivé sur l'élément cliqué).
	local h = self._folder.hovered
	if menu and h then
		if tostring(h.url) == menu.url then
			menu.seen = true
		elseif menu.seen then
			menu = nil
		end
	end
	if not menu then
		return elements
	end

	local m = menu
	elements[#elements + 1] = ui.Clear(ui.Rect { x = m.x, y = m.y, w = m.w, h = m.h })
	elements[#elements + 1] = ui.Border(ui.Edge.ALL):area(ui.Rect { x = m.x, y = m.y, w = m.w, h = m.h }):style(th.mgr.border_style)
	for i, item in ipairs(m.items) do
		local row = ui.Rect { x = m.x + 1, y = m.y + i, w = m.w - 2, h = 1 }
		if item[1] then
			elements[#elements + 1] = ui.Line(" " .. item[1]):area(row)
			elements[#elements + 1] = ui.Line(item[4] .. " "):area(row):align(ui.Align.RIGHT):style(th.mgr.border_style)
		else
			elements[#elements + 1] = ui.Line(string.rep("─", m.w - 2)):area(row):style(th.mgr.border_style)
		end
	end
	return elements
end

-- Clic gauche : ouvre le dossier ou le fichier (au relâchement, pour ne pas gêner le glisser-déposer).
-- Clic droit : menu contextuel à l'endroit du clic.
function Current:click(event, up)
	if event.is_middle then
		return
	end

	if menu and not up then
		local m, item = menu, menu.items[event.y - menu.y]
		menu = nil
		if item and item[1] and event.x > m.x and event.x < m.x + m.w - 1 then
			ya.emit(item[2], item[3])
		end
		return ui.render()
	end

	local file = self._folder.window[event.y - self._area.y + 1]
	local url = file and tostring(file.url)
	if up then
		if event.is_left and url and press and press.url == url and math.abs(event.x - press.x) <= 2 then
			ya.emit("open", { hovered = true })
		end
		press = nil
		return
	end

	if file then
		ya.emit("reveal", { file.url })
	end
	if event.is_right then
		local h = self._folder.hovered
		local items = file and MENU_FILE or MENU_EMPTY
		local w, ht = 34, #items + 2
		menu = {
			items = items,
			x = math.max(self._area.x, math.min(event.x, self._area.x + self._area.w - w)),
			y = math.max(self._area.y, math.min(event.y, self._area.y + self._area.h - ht)),
			w = w,
			h = ht,
			url = url or (h and tostring(h.url)) or "",
		}
		return ui.render()
	end
	press = url and { url = url, x = event.x }
end

-- Volet de navigation de l'Explorateur à la place du dossier parent : Accès rapide et Ce PC, un clic y va.
local PLACES = {
	{ "Accès rapide" },
	{ "\u{f108}", "Bureau", HOME .. "/Desktop" },
	{ "\u{f019}", "Téléchargements", HOME .. "/Downloads" },
	{ "\u{f15c}", "Documents", HOME .. "/Documents" },
	{ "\u{f03e}", "Images", HOME .. "/Pictures" },
	{ "\u{f001}", "Musique", HOME .. "/Music" },
	{ "\u{f03d}", "Vidéos", HOME .. "/Videos" },
	{ "\u{f02b6}", "Google Drive", HOME .. "/GoogleDrive" },
	{ "" },
	{ "Ce PC" },
	{ "\u{f015}", "Dossier personnel", HOME },
	{ "\u{f0a0}", "Disque local (/)", "/" },
}

function Parent:redraw()
	local cwd = tostring(self._tab.current.cwd)
	local lines = {}
	for i, p in ipairs(PLACES) do
		if p[3] then
			lines[i] = ui.Line(" " .. p[1] .. "  " .. p[2])
			if p[3] == cwd then
				lines[i] = lines[i]:style(th.indicator.current)
			end
		else
			lines[i] = ui.Line(p[1]):style(ui.Style():bold())
		end
	end
	return { ui.List(lines):area(self._area) }
end

function Parent:click(event, up)
	local p = not up and event.is_left and PLACES[event.y - self._area.y + 1]
	if p and p[3] then
		ya.emit("cd", { p[3] })
	end
end

-- Barre d'état de l'Explorateur : nombre d'éléments, sélection, taille du fichier survolé.
function Status:redraw()
	local n, sel, h = #self._current.files, #self._tab.selected, self._current.hovered
	local parts = { string.format(" %d élément%s", n, n > 1 and "s" or "") }
	if sel > 0 then
		local s = sel > 1 and "s" or ""
		parts[#parts + 1] = string.format("%d élément%s sélectionné%s", sel, s, s)
	end
	if h and not h.cha.is_dir then
		parts[#parts + 1] = ya.readable_size(h.cha.len)
	end
	return {
		ui.Text(""):area(self._area):style(th.status.overall),
		ui.Line(table.concat(parts, "  │  ")):area(self._area),
		table.unpack(ui.redraw(Progress:new(self._area, 0))),
	}
end
