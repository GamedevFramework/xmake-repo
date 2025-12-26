package("gamedevframework2")
    set_homepage("https://github.com/GamedevFramework/gf2")
    set_description("Gamedev Framework (gf) is a framework to build 2D games in C++20. It is based on SDL3 and provides high-level constructions to easily build games.")
    set_license("Zlib")

    set_urls("https://github.com/GamedevFramework/gf2.git")

    add_configs("graphics", {description = "Use gf2 'graphics' component", default = true, type = "boolean"})
    add_configs("network", {description = "Use gf2 'network' component", default = true, type = "boolean"})
    add_configs("audio", {description = "Use gf2 'audio' component", default = true, type = "boolean"})
    add_configs("physics", {description = "Use gf2 'physics' component", default = true, type = "boolean"})
    add_configs("imgui", {description = "Use gf2 'imgui' component", default = true, type = "boolean"})
    add_configs("framework", {description = "Use gf2 'framework' component", default = true, type = "boolean"})

    on_component("core", function (package, component)
        component:add("links", "gf2core0")
    end)

    on_component("graphics", function (package, component)
        component:add("links", "gf2graphics0")
        component:add("deps", "core")
    end)

    on_component("network", function (package, component)
        component:add("links", "gf2network0")
        component:add("deps", "core")
        if package:is_plat("windows") then
            component:add("syslinks", "ws2_32")
        end
    end)

    on_component("audio", function (package, component)
        component:add("links", "gf2audio0")
        component:add("deps", "core")
        if package:is_plat("linux") then
            component:add("syslinks", "dl")
        end
    end)

    on_component("physics", function (package, component)
        component:add("links", "gf2physics0")
        component:add("deps", "core")
    end)

    on_component("imgui", function (package, component)
        component:add("links", "gf2imgui0")
        component:add("deps", "core", "graphics")
    end)

    on_component("framework", function (package, component)
        component:add("links", "gf2framework0")
        component:add("deps", "core", "graphics", "audio", "physics")
    end)

    on_load("windows", "linux", function (package)
        package:add("components", "core")
        package:add("deps", "fmt", "zlib")
        package:add("deps", "freetype", "pugixml", "stb")

        if package:config("graphics") then
            package:add("deps", "harfbuzz")
            package:add("deps", "libsdl3")
        end

        if package:config("audio") then
            package:add("deps", "miniaudio", "stb")
        end

        if package:config("physics") then
            package:add("deps", "box2d")
        end

        if package:config("imgui") then
            package:add("deps", "imgui")
        end

        if not package:config("shared") then
            package:add("defines", "GF_CORE_STATIC")
        end

        for _, component in ipairs({"graphics", "network", "audio", "physics", "imgui", "framework"}) do
            if package:config(component) then
                package:add("components", component)

                if not package:config("shared") then
                    package:add("defines", "GF_" .. component:upper() .. "_STATIC")
                end
            end
        end

    end)

    on_install("windows", "linux", function (package)
        local configs = {}
        configs.binaries = false
        configs.examples = false
        configs.tests = false
        configs.games = false
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
        #include <gf2/graphics/Scene.h>
        #include <gf2/graphics/SceneManager.h>

        int test()
        {
          gf::SingleSceneManager scene_manager("test", gf::vec(1600, 900));
          gf::Scene scene;
          return scene_manager.run(&scene);
        }
        ]]}, {configs = {languages = "cxx20"}}))
    end)
