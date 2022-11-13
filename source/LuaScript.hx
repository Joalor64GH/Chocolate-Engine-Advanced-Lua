package;

#if desktop
import llua.*;
import llua.Lua.Lua_helper;
#end

import openfl.utils.Assets;

using StringTools;

#if desktop
class LuaScript
{
    // Lua is not my fortue tbh
    var virtualMachine:State = LuaL.newstate();

	public function new()
	{
        LuaL.openlibs(virtualMachine);
        Lua.init_callbacks(virtualMachine);
		// just for security reasons
		LuaL.dostring(lua, "
            os.execute, os.getenv, os.rename, os.remove, os.tmpname = nil, nil, nil, nil, nil
            io, load, loadfile, loadstring, dofile = nil, nil, nil, nil, nil
            require, module, package = nil, nil, nil
            setfenv, getfenv = nil, nil
            newproxy = nil
            gcinfo = nil
            debug = nil
            jit = nil
        ");

        var result:Null<Int> = LuaL.dofile(virtualMachine, fileName);
        var resultStr:String = LuaL.tostring(virtualMachine, fileName);

        if (resultStr != null && result != 0)
            return;

        Lua_helper.add_callback(virtualMachine, 'trace', function(v:Dynamic) trace(v));
	}

    // yeah, this isn't my cup of tea as you can tell
    // It might compile, but idk if it'll work
    function loadLuaScript(fileName:String, luaVar:Dynamic):Void
    {
        var daLuaFile:Dynamic = null;
        if (Assets.exists(fileName)) {
            if (LuaL.dostring(virtualMachine, Assets.getText(fileName)) != 0){
                var error = LuaL.tostring(virtualMachine, -1);
                trace('$error');
                // return null;
            }
            else {
                daLuaFile = LuaL.dofile(virtualMachine, fileName);
                Lua.getglobal(virtualMachine, luaVar); // I wish there was documentation on Linc_Luajit
                return daLuaFile;
            }
        } else {
            trace('$fileName', 'does not exist');
        }
        return null;
    }

    public inline function addCallback(name:String, func:Function){
        return Lua_helper.add_callback(virtualMachine, name, func);
    }
}
#end