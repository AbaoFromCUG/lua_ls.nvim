local utils = require("luals.utils")

describe("merge", function()
    describe("nil", function()
        it("empty", function()
            local merged = utils.merge({}, nil)
            assert.same({}, merged)
        end)
        it("empty2", function()
            local merged = utils.merge(nil, {})
            assert.same({}, merged)
        end)
        it("empty3", function()
            local merged = utils.merge({ foo = 1 }, nil)
            assert.same({ foo = 1 }, merged)
        end)
        it("empty4", function()
            local merged = utils.merge(nil, { foo = 1 })
            assert.same({ foo = 1 }, merged)
        end)
    end)
    describe("single level", function()
        it("empty", function()
            local merged = utils.merge({}, {})
            assert.same({}, merged)
        end)

        it("empty merge to noempty", function()
            local merged = utils.merge({ foo = 1 }, {})
            assert.same({ foo = 1 }, merged)
        end)
        it("nonempty merge to noempty", function()
            local merged = utils.merge({}, { foo = 1 })
            assert.same({ foo = 1 }, merged)
        end)
        it("empty", function()
            local merged = utils.merge({}, { key = { foo = 1 } })
            assert.same({ key = { foo = 1 } }, merged)
        end)
        it("empty", function()
            local merged = utils.merge({ key = { foo = 1 } }, {})
            assert.same({ key = { foo = 1 } }, merged)
        end)
        it("object", function()
            local merged = utils.merge({ foo = 1 }, { test = 2 })
            assert.same({ foo = 1, test = 2 }, merged)
        end)
        it("array", function()
            local merged = utils.merge({ 1 }, { 2 })
            assert.same({ 1, 2 }, merged)
        end)
    end)
    describe("nested", function()
        it("same level object", function()
            local merged = utils.merge({ key = { foo = 1 } }, { key = { test = 2 } })
            assert.same({ key = { foo = 1, test = 2 } }, merged)
        end)
        it("different level object", function()
            local merged = utils.merge({ key = { foo = 1 } }, { key = { test = 2 }, foo = 3 })
            assert.same({ key = { foo = 1, test = 2 }, foo = 3 }, merged)
        end)
        it("array", function()
            local merged = utils.merge({ foo = { 1 } }, { foo = { 2 } })
            assert.same({ foo = { 1, 2 } }, merged)
        end)
        it("test", function()
            local obj = {
                {
                    Lua = {
                        addonManager = {
                            enable = true,
                        },
                        completion = {
                            autoRequire = true,
                            callSnippet = "Replace",
                        },
                        format = {
                            enable = false,
                        },
                        telemetry = {
                            enable = false,
                        },
                    },
                },
                {
                    ["Lua.workspace.library"] = { "/home/abao/.local/share/nvim/luals/addonManager/addons/argparse/module" },
                },
                {
                    ["Lua.workspace.library"] = { "/home/abao/.local/share/nvim/luals/addonManager/addons/nodemcu-esp8266/module" },
                },
            }
            print(utils.merge(unpack(obj)))
        end)
    end)
end)

describe("flatten", function()
    it("simple level", function()
        assert.are.same({}, utils.flatten({}))
        assert.are.same({ id = 12 }, utils.flatten({ id = 12 }))
        assert.are.same({ name = "myname" }, utils.flatten({ name = "myname" }))

        assert.are.same({ name = { id = 12 } }, utils.flatten({ ["name.id"] = 12 }))
        assert.are.same({ first = { second = { third = 12 } } }, utils.flatten({ ["first.second.third"] = 12 }))
    end)
    it("array object mixture", function()
        assert.are.same({ name = { arr = { 1, 2 } } }, utils.flatten({ ["name.arr"] = { 1, 2 } }))
        assert.are.same({ { first = { second = 12 } } }, utils.flatten({ { ["first.second"] = 12 } }))
    end)
    it("nested", function()
        assert.are.same({ foo = { bar = { name = "myname" } } }, utils.flatten({ foo = { ["bar.name"] = "myname" } }))
    end)
end)
