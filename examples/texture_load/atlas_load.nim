
import sdl2
from dadren/atlases import newAtlasManager, load, render

from ./exampleutils import handleEvents


sdl2.init(sdl2.INIT_EVERYTHING)

let
    window = sdl2.createWindow("Atlas loader (ESC to exit)", 0, 0, 640, 480, sdl2.SDL_WINDOW_SHOWN)
    display = sdl2.createRenderer(window, -1, sdl2.Renderer_Accelerated)
    am = newAtlasManager(window, display)
    plants = am.load("plants", "plants.png", width=20, height=20)

while true:

    display.render(plants,
        rx=1, ry=1,
        dx=0, dy=0)

    sdl2.present(display)

    if handleEvents():
        break


sdl2.quit()
