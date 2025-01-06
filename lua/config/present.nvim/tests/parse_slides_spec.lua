local parse = require("present")._parse_slides
local eq = assert.are.same

describe("present.parse_slides", function()
    it("should be empty slides", function()
        ---@type present.Slides
        local expected = {
            slides = {
                {
                    title = "",
                    body = {},
                    blocks = {}
                }
            }
        }

        local actual = parse({})

        eq(expected, actual)
    end)
end)

describe("preent.parse_slides", function()
    it("Multiple sides with content", function()
        ---@type present.Slides
        local expected = {
            slides = {
                {
                    title = "# Test",
                    body = {
                        "something",
                        "something else"
                    },
                    blocks = {}
                },
                {
                    title = "# Test 2",
                    body = {
                        "something 2",
                        "something else 2"
                    },
                    blocks = {}
                }
            }
        }

        local actual = parse({
            "# Test",
            "something",
            "something else",
            "# Test 2",
            "something 2",
            "something else 2",
        })

        eq(expected, actual)
    end)
end)

describe("present.parse_slides", function()
    it("should parse a file with one slide, and a block", function()
        ---@type present.Slides
        local expected = {
            slides = {
                {
                    title = "# Test",
                    body = {
                        "This is the body",
                        "```lua",
                        "print('hi')",
                        "```",
                    },
                    blocks = {
                        {
                            language = "lua",
                            body = "print('hi')\n"
                        }
                    }
                }
            }
        }

        local actual = parse({
            "# Test",
            "This is the body",
            "```lua",
            "print('hi')",
            "```",
        })

        eq(expected.slides[1].title, actual.slides[1].title)
        eq(expected.slides[1].body, actual.slides[1].body)
        eq(expected.slides[1].blocks[1].body, actual.slides[1].blocks[1].body)
        eq(expected.slides[1].blocks[1].language, actual.slides[1].blocks[1].language)
    end)
end)
