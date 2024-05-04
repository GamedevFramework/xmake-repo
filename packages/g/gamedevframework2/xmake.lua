package("gamedevframework2")
    set_homepage("https://github.com/GamedevFramework/gf2")
    set_description("Gamedev Framework (gf) is a framework to build 2D games in C++17. It is based on SDL3 and Vulkan 1.3 and provides high-level constructions to easily build games.")
    set_license("Zlib")
    set_policy("package.librarydeps.strict_compatibility", true)

    set_urls("https://github.com/GamedevFramework/gf2.git")

    add_deps(
      "chipmunk2d",
      "fmt",
      "freetype",
      "harfbuzz",
      "imgui",
      "libsdl",
      "miniaudio",
      "pugixml",
      "stb",
      "vk-bootstrap",
      "volk",
      "vulkan-headers",
      "vulkan-memory-allocator",
      "zlib"
    )

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
          gf::StandardScene scene;
          return scene_manager.run(&scene);
        }
        ]]}, {configs = {languages = "c++17"}}))
    end)
