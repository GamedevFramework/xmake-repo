package("gamedevframework1")
    set_homepage("https://github.com/GamedevFramework/gf")
    set_description("Gamedev Framework (gf) is a framework to build 2D games in C++17. It is based on SDL and OpenGL ES 2.0, and presents an API that is very similar to the graphics module of SFML with additional features.")
    set_license("Zlib")
    set_policy("package.librarydeps.strict_compatibility", true)

    set_urls("https://github.com/GamedevFramework/gf.git")

    add_versions("1.2.0", "4292920a780978ecc68876667b9733800193fc0f")
    add_versions("1.2.80", "157cc83e9e5c2c59b60d3a27fef13cccfd4031e3") -- pre 1.3.0

    add_deps("cmake")
    add_deps("boost", "freetype", "libsdl", "pugixml", "stb", "zlib")

    on_install("windows", "linux", "macosx", function (package)
        local configs = {"-DBUILD_TESTS=OFF", "-DGF_BUILD_EXAMPLES=OFF", "-DGF_BUILD_DOCUMENTATION=OFF", "-DGF_USE_EMBEDDED_LIBS=ON", "-DCMAKE_UNITY_BUILD=ON"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_STATIC=" .. (package:config("shared") and "OFF" or "ON"))
        import("package.tools.cmake").install(package, configs, {buildir = os.tmpfile() .. ".dir"})
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
        #include <gf/Color.h>
        #include <gf/Event.h>
        #include <gf/RenderWindow.h>
        #include <gf/Window.h>

        void test() {
            gf::Window window("Example", { 640, 480 });
            gf::RenderWindow renderer(window);

            renderer.clear(gf::Color::White);

            while (window.isOpen()) {
                gf::Event event;

                while (window.pollEvent(event)) {
                    switch (event.type) {
                        case gf::EventType::Closed:
                        window.close();
                        break;

                        default:
                        break;
                    }
                }

                renderer.clear();
                renderer.display();
            }
        }
        ]]}, {configs = {languages = "c++17"}}))
    end)
