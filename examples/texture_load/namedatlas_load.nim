
import sdl2
from dadren/namedatlases import newNamedAtlasManager, load, render

from ./exampleutils import handleEvents


sdl2.init(sdl2.INIT_EVERYTHING)

let
    window = sdl2.createWindow("Named atlas loader (ESC to exit)", 0, 0, 640, 480, sdl2.SDL_WINDOW_SHOWN)
    display = sdl2.createRenderer(window, -1, sdl2.Renderer_Accelerated)
    nam = newNamedAtlasManager(window, display)
    plants = nam.load("plants", "plants.png",
        width=20,
        height=20,
        names=(@["grass", "tallgrass", "weed", "pine", "bush", "cedar", "oak", "shroom"])
    )

while true:

    display.render(plants,
        name="shroom",
        dx=0, dy=0)

    sdl2.present(display)

    if handleEvents():
        break


sdl2.quit()
