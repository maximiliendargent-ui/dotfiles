-- Vue « Détails » de l'Explorateur : date de modification puis taille (vide pour les dossiers).
function Linemode:details()
	local time = math.floor(self._file.cha.mtime or 0)
	local size = self._file:size()
	return string.format(
		"%s %9s",
		time > 0 and os.date("%d/%m/%Y %H:%M", time) or "",
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

-- Double-clic dans la liste : ouvre le dossier ou le fichier, comme dans l'Explorateur.
local single_click, last_url, last_time = Current.click, nil, 0
function Current:click(event, up)
	single_click(self, event, up)
	if up or not event.is_left then
		return
	end

	local file = self._folder.window[event.y - self._area.y + 1]
	local url, now = file and tostring(file.url), ya.time()
	if url and url == last_url and now - last_time < 0.4 then
		last_url = nil
		ya.emit("open", { hovered = true })
	else
		last_url, last_time = url, now
	end
end
