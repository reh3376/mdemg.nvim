local M = {}

--- Load a JSON fixture file from tests/fixtures/responses/
--- @param name string Fixture name (without .json extension)
--- @return table Decoded JSON content
function M.load_fixture(name)
	local path = "tests/fixtures/responses/" .. name .. ".json"
	local f = io.open(path, "r")
	if not f then
		error("Fixture not found: " .. path)
	end
	local content = f:read("*a")
	f:close()
	return vim.json.decode(content)
end

return M
