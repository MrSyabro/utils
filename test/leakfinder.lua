local lf = require "leakfinder"

test1 = {
    test = {}
}

lf(_G, test1.test)