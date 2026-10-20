--- @sync entry
-- Alt + P : affiche ou masque le volet de visualisation, comme dans l'Explorateur.
return {
	entry = function(st)
		st.on = not st.on
		Tab.layout = function(self)
			local r = rt.mgr.ratio
			local c = st.on and { r[1], 4, 2 } or { r[1], r[2], r[3] }
			local all = c[1] + c[2] + c[3]
			self._chunks = ui.Layout()
				:direction(ui.Layout.HORIZONTAL)
				:constraints({
					ui.Constraint.Ratio(c[1], all),
					ui.Constraint.Ratio(c[2], all),
					ui.Constraint.Ratio(c[3], all),
				})
				:split(self._area)
		end
		ya.emit("app:resize", {})
	end,
}
