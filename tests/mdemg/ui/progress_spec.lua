describe("mdemg.ui.progress", function()
	local progress

	before_each(function()
		package.loaded["mdemg.ui.progress"] = nil
		package.loaded["mdemg.ui.float"] = nil
		progress = require("mdemg.ui.progress")
	end)

	it("starts with empty active table", function()
		assert.same({}, progress._active)
	end)

	it("update is no-op for unknown job", function()
		-- Should not error
		progress.update("unknown-job", { progress = { percentage = 50 } })
		assert.same({}, progress._active)
	end)

	it("complete is no-op for unknown job", function()
		-- Should not error
		progress.complete("unknown-job", "done")
		assert.same({}, progress._active)
	end)

	it("error is no-op for unknown job", function()
		-- Should not error
		progress.error("unknown-job", "something failed")
		assert.same({}, progress._active)
	end)
end)
