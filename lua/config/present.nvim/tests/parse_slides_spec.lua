local parse = require("present")._parse_slides

describe("preent.parse_slides", function()
    it("test", function()
        ---@type present.Slides
        local expected = {

            slides = {
                {
                    title = "# Test",
                    body = {
                        "something",
                        "something else"
                    }
                },
                {
                    title = "# Test 2",
                    body = {
                        "something 2",
                        "something else 2"
                    }
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

        assert.are.same(expected, actual)
    end)
end)
