import sdl2


proc handleEvents*(): bool =
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

