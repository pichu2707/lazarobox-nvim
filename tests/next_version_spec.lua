-- scripts/next-version.sh decides the release bump in CI (.github/workflows/version.yml).
-- It reads NUL-separated commit messages (git log --format=%B%x00) on stdin and
-- prints the next version, or nothing when no commit warrants a release.
local root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")
local script = root .. "/scripts/next-version.sh"

local function next_version(current, messages)
	local input = table.concat(messages, "\0")
	if #messages > 0 then
		input = input .. "\0"
	end
	local res = vim.system({ "bash", script, current }, { stdin = input, text = true }):wait()
	return vim.trim(res.stdout or ""), res.code
end

describe("next-version.sh", function()
	it("exists and is executable", function()
		assert_eq(1, vim.fn.executable(script))
	end)

	describe("single commit", function()
		it("feat bumps minor and resets patch", function()
			assert_eq("3.1.0", (next_version("3.0.4", { "feat: add palette" })))
		end)

		it("feat with scope bumps minor", function()
			assert_eq("3.1.0", (next_version("3.0.0", { "feat(ui): add palette" })))
		end)

		it("fix, perf and revert bump patch", function()
			assert_eq("3.0.1", (next_version("3.0.0", { "fix: typo" })))
			assert_eq("3.0.1", (next_version("3.0.0", { "perf(lsp): faster" })))
			assert_eq("3.0.1", (next_version("3.0.0", { "revert: undo x" })))
		end)

		it("type is matched case-insensitively", function()
			assert_eq("3.1.0", (next_version("3.0.0", { "Feat: shout" })))
		end)

		it("any type marked with ! bumps major", function()
			assert_eq("4.0.0", (next_version("3.2.1", { "feat!: drop api" })))
			assert_eq("4.0.0", (next_version("3.2.1", { "chore(deps)!: drop nvim 0.9" })))
		end)

		it("BREAKING CHANGE footer at line start bumps major", function()
			assert_eq("4.0.0", (next_version("3.2.1", { "fix: x\n\nBREAKING CHANGE: removed y" })))
			assert_eq("4.0.0", (next_version("3.2.1", { "docs: x\n\nBREAKING-CHANGE: removed y" })))
		end)

		it("BREAKING CHANGE in prose or lowercase does not bump major", function()
			assert_eq("3.0.1", (next_version("3.0.0", { "fix: x\n\nThis is not a BREAKING CHANGE: really" })))
			assert_eq("3.0.1", (next_version("3.0.0", { "fix: x\n\nbreaking change: nope" })))
		end)

		it("type is read from the subject only, never the body", function()
			assert_eq("", (next_version("3.0.0", { "docs: readme\n\nfeat: squashed line" })))
		end)

		it("non-releasing types produce no output", function()
			for _, subject in ipairs({ "docs: x", "chore: x", "ci: x", "test: x", "style: x", "refactor: x", "plain text" }) do
				assert_eq("", (next_version("3.0.0", { subject })), subject)
			end
		end)

		it("bump(version) commits are ignored", function()
			assert_eq("", (next_version("3.0.0", { "bump(version): v3.0.0" })))
		end)
	end)

	describe("several commits", function()
		it("takes the highest bump across all commits", function()
			assert_eq("3.1.0", (next_version("3.0.0", { "fix: a", "feat: b", "docs: c" })))
			assert_eq("4.0.0", (next_version("3.0.0", { "fix: a", "refactor!: b", "feat: c" })))
		end)

		it("ignores bump(version) commits mixed with real ones", function()
			assert_eq("3.0.1", (next_version("3.0.0", { "bump(version): v9.0.0", "fix: a" })))
		end)

		it("breaking footer on a non-first commit still wins", function()
			assert_eq("4.0.0", (next_version("3.0.0", { "feat: a", "chore: b\n\nBREAKING CHANGE: c" })))
		end)

		it("no commits produce no output", function()
			assert_eq("", (next_version("3.0.0", {})))
		end)

		it("accepts a last message without trailing NUL", function()
			local res = vim.system({ "bash", script, "3.0.0" }, { stdin = "docs: a\0fix: b", text = true }):wait()
			assert_eq("3.0.1", vim.trim(res.stdout))
		end)
	end)

	describe("invalid input", function()
		it("rejects a malformed current version", function()
			local out, code = next_version("3.0", { "feat: a" })
			assert_eq("", out)
			assert_eq(true, code ~= 0, "non-zero exit")
		end)
	end)
end)
