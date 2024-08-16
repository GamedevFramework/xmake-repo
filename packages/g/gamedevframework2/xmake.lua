package("gamedevframework2")
    set_homepage("https://github.com/GamedevFramework/gf2")
    set_description("Gamedev Framework (gf) is a framework to build 2D games in C++17. It is based on SDL3 and Vulkan 1.3 and provides high-level constructions to easily build games.")
    set_license("Zlib")

    set_urls("https://github.com/GamedevFramework/gf2.git")

    add_components("core", "graphics", "network", "audio", "physics", "imgui", "framework")

    on_component("core", function (package, component)
        component:add("links", "gf2core0")
        package:add("deps", "fmt", "freetype", "pugixml", "stb", "zlib")
    end)

    on_component("graphics", function (package, component)
        component:add("links", "gf2graphics0")
        component:add("deps", "core")
        package:add("deps", "harfbuzz", "libsdl", "vk-bootstrap", "volk", "vulkan-headers", "vulkan-memory-allocator")
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
        package:add("deps", "miniaudio", "stb")
        if package:is_plat("linux") then
            component:add("syslinks", "dl")
        end
    end)

    on_component("physics", function (package, component)
        component:add("links", "gf2physics0")
        component:add("deps", "core")
        package:add("deps", "chipmunk2d")
    end)

    on_component("imgui", function (package, component)
        component:add("links", "gf2imgui0")
        component:add("deps", "core", "graphics")
        package:add("deps", "imgui")
    end)

    on_component("framework", function (package, component)
        component:add("links", "gf2framework0")
        component:add("deps", "core", "graphics", "audio")
    end)

    on_fetch(function (package, opt)
        if not opt.system then
            return
        end

        local gf2 = os.getenv("GF2_PATH")

        if not gf2 or not os.isdir(gf2) then
            return
        end

        local info = {
          sysincludedirs = { path.join(gf2, "include") },
          linkdirs = path.join(gf2, "build", package:plat(), package:arch(), package:mode()),
          links = { "gf2framework0", "gf2imgui0", "gf2audio0", "gf2network0", "gf2graphics0", "gf2core0" }
        }

        return info
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
        ]]}, {configs = {languages = "c++17"}}))
    end)
