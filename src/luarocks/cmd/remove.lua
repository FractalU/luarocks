local _tl_compat; if (tonumber((_VERSION or ''):match('[%d.]*$')) or 0) < 5.3 then local p, m = pcall(require, 'compat53.module'); if p then _tl_compat = m end end; local string = _tl_compat and _tl_compat.string or string


local cmd_remove = {}



local remove = require("luarocks.remove")
local util = require("luarocks.util")
local cfg = require("luarocks.core.cfg")
local search = require("luarocks.search")
local path = require("luarocks.path")
local deps = require("luarocks.deps")
local queries = require("luarocks.queries")





function cmd_remove.add_to_parser(parser)

   local cmd = parser:command("remove", [[
Uninstall a rock.

If a version is not given, try to remove all versions at once.
Will only perform the removal if it does not break dependencies.
To override this check and force the removal, use --force or --force-fast.]],
   util.see_also()):
   summary("Uninstall a rock.")


   cmd:argument("rock", "Name of the rock to be uninstalled."):
   action(util.namespaced_name_action)
   cmd:argument("version", "Version of the rock to uninstall."):
   args("?")

   cmd:flag("--force", "Force removal if it would break dependencies.")
   cmd:flag("--force-fast", "Perform a forced removal without reporting dependency issues.")
   util.deps_mode_option(cmd)
end




function cmd_remove.command(args)
   local name = args.rock
   local deps_mode = deps.get_deps_mode(args)

   local rock_type = name:match("%.(rock)$") or name:match("%.(rockspec)$")
   local version = args.version
   local filename = name
   if rock_type then
      name, version = path.parse_name(filename)
      if not name then return nil, "Invalid " .. rock_type .. " filename: " .. filename end
   end

   name = name:lower()

   local results = {}
   search.local_manifest_search(results, cfg.rocks_dir, queries.new(name, args.namespace, version))
   if not results[name] then
      local rock = util.format_rock_name(name, args.namespace, version)
      return nil, "Could not find rock '" .. rock .. "' in " .. path.rocks_tree_to_string(cfg.root_dir)
   end

   local ok, err = remove.remove_search_results(results, name, deps_mode, args.force, args.force_fast)
   if not ok then
      return nil, err
   end

   deps.check_dependencies(nil, deps.get_deps_mode(args))
   return true
end

cmd_remove.needs_lock = function() return true end

return cmd_remove
