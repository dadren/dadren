
import sdl2
from dadren/namedatlases import newNamedAtlasManager, load, render

proc handleEvents(): bool =
    var event = sdl2.defaultEvent
    while sdl2.pollEvent(event):
        case event.kind
        of sdl2.QuitEvent:
            return true
        of sdl2.KeyDown:
            var keyEvent = cast[sdl2.KeyboardEventPtr](addr(event))
            if keyEvent.keysym.scancode == sdl2.SDL_SCANCODE_ESCAPE:
                return true
        else:
            discard
    return false



sdl2.init(sdl2.INIT_EVERYTHING)

let
    window = sdl2.createWindow("Texture loader", 0, 0, 640, 480, sdl2.SDL_WINDOW_SHOWN)
    display = sdl2.createRenderer(window, -1, sdl2.Renderer_Accelerated)
    nam = newNamedAtlasManager(window, display)
    plants = nam.load("plants", "plants.png",
        width=20,
        height=20,
        names= @["grass", "tallgrass", "weed", "pine", "bush", "cedar", "oak", "shroom"]
    )

while true:

    display.render(plants,
        name="shroom",
        dx=0, dy=0)

    sdl2.present(display)

    if handleEvents():
        break


sdl2.quit()
