package("gamedevframework1")
    set_homepage("https://github.com/GamedevFramework/gf")
    set_description("Gamedev Framework (gf) is a framework to build 2D games in C++17. It is based on SDL and OpenGL ES 2.0, and presents an API that is very similar to the graphics module of SFML with additional features.")
    set_license("Zlib")

    set_urls("https://github.com/GamedevFramework/gf.git")

    add_deps("cmake")
    add_deps("freetype", "libsdl2", "opengl-headers", "pugixml", "stb", "zlib")
    add_deps("boost", { configs = { container = true }})

    add_configs("shared", { description = "Build shared library.", default = false, type = "boolean" })

    on_load("windows", "linux", function (package)
        package:add("links", "gf0", "gfnet0", "gfcore0")

        if not package:config("shared") then
            package:add("defines", "GF_STATIC")
        end
    end)

    on_install("windows", "linux", function (package)
        local configs = {}
        configs.tests = false
        import("package.tools.xmake").install(package, configs)
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
