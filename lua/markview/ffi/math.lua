local ffi = require("ffi")

ffi.cdef[[
    char* latex_to_unicode(const char* input);
    char* latex_to_unicode_block(const char* input);
    char* latex_transform_markdown(const char* input);
    void latex_unicode_free(char* ptr);
]]

local M = {}
local lib = nil

local function get_lib_path()
    local home = os.getenv("HOME")
    local candidates = {
        home .. "/Labs/KpihX-Labs/latex-to-unicode/target/release/liblatex_to_unicode_c_api.so",
        home .. "/.local/lib/liblatex_to_unicode_c_api.so",
        "/usr/local/lib/liblatex_to_unicode_c_api.so",
    }
    for _, path in ipairs(candidates) do
        local f = io.open(path, "r")
        if f then
            f:close()
            return path
        end
    end
    return nil
end

function M.init()
    if lib then return true end
    local path = get_lib_path()
    if not path then
        return false, "liblatex_to_unicode_c_api.so not found"
    end
    local ok, loaded = pcall(ffi.load, path)
    if ok then
        lib = loaded
        return true
    else
        return false, loaded
    end
end

function M.to_unicode(latex_str)
    if not M.init() then return latex_str end
    local c_str = lib.latex_to_unicode(latex_str)
    if c_str == nil then return latex_str end
    local res = ffi.string(c_str)
    lib.latex_unicode_free(c_str)
    return res
end

function M.to_unicode_block(latex_str)
    if not M.init() then return latex_str end
    local c_str = lib.latex_to_unicode_block(latex_str)
    if c_str == nil then return latex_str end
    local res = ffi.string(c_str)
    lib.latex_unicode_free(c_str)
    return res
end

function M.transform_markdown(md_str)
    if not M.init() then return md_str end
    local c_str = lib.latex_transform_markdown(md_str)
    if c_str == nil then return md_str end
    local res = ffi.string(c_str)
    lib.latex_unicode_free(c_str)
    return res
end

return M
