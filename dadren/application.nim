#
## The application module contains the central type to the Dadren engine the `AppObj` and its Ref type `App`.

## The App serves a few primary roles for the game author:

## - Loading configuration and assets
## - Running the main loop
## - Calling user event handlers

## The App is initialized by passing the filename of a settings file which contains the needed information.

import os
import future
import strutils

import sdl2

import ./settings
import ./resources
import ./clock
import ./scenes
import ./utils

type
  AppSettings* = object
    title*: string
    scale*: float
    vsync: bool
    accelerated: bool
    resolution*: Resolution
  AppObj* = object
    settings*: AppSettings
    resources*: ResourceManager
    scenes*: SceneManager
    window*: WindowPtr
    display*: RendererPtr
    clock*: Clock
    running*: bool
  App* = ref AppObj

proc setLogicalSize(app: App, width, height: cint) =
  discard app.display.setLogicalSize(cint(width.float / app.settings.scale),
                                     cint(height.float / app.settings.scale))

proc setLogicalSize(app: App) =
  if app.settings.resolution.width == -1 and app.settings.resolution.height == -1:
    var dm = DisplayMode()
    discard getCurrentDisplayMode(0, dm)
    app.setLogicalSize(dm.w, dm.h)
  else:
    app.setLogicalSize(app.settings.resolution.width,
                       app.settings.resolution.height)

proc getLogicalSize*(app: App): Size =
  var width, height: cint
  app.display.getLogicalSize(width, height)
  (width.int, height.int)

proc getDisplayFlags(vsync=true, accelerated=true): cint =
  if vsync:
    result = result or Renderer_PresentVsync

  if accelerated:
    result = result or Renderer_Accelerated
  else:
    result = result or Renderer_Software

proc getDisplayFlags(app: App): cint =
  getDisplayFlags(app.settings.vsync, app.settings.accelerated)

proc getCurrentDisplayMode(): DisplayMode =
  result = DisplayMode()
  discard getCurrentDisplayMode(0, result)

proc newApp*(settings: AppSettings): App =
  sdl2.init(INIT_EVERYTHING)
  let dm = getCurrentDisplayMode()

  let
    width = settings.resolution.width
    height = settings.resolution.height
    window_flags = (SDL_WINDOW_SHOWN or
                    SDL_WINDOW_ALLOW_HIGHDPI or
                    SDL_WINDOW_RESIZABLE)
    render_flags = getDisplayFlags(settings.vsync, settings.accelerated)

  new(result)
  result.settings = settings
  result.clock = newClock(1.0 / 60.0)
  result.scenes = newSceneManager()
  result.window = createWindow(settings.title, 0, 0, width, height, window_flags)
  result.display = createRenderer(result.window, -1, render_flags)
  result.resources = newResourceManager(result.window, result.display)
  result.running = true

  if not (result.settings.scale > 0.0):
    result.settings.scale = 1.0

  result.setLogicalSize()

proc newApp*(width, height: int, title: string,
             scale = 1.0, vsync = true, accelerated = true): App =
  newApp(AppSettings(
    title:title, scale:scale, vsync:vsync, accelerated:accelerated,
    resolution:Resolution(width:width, height:height)
  ))

proc clear*(app: App, r, g, b: uint8) =
  app.display.setDrawColor(r, g, b, 0)
  app.display.clear

proc updateFrame(app: App) =
  app.clock.tick()
  app.scenes.current.update(app.clock.current, app.clock.delta)

proc handleEvents(app: App) =
    var event = defaultEvent
    # poll for any pending events
    while pollEvent(event):
      case event.kind
      of QuitEvent:
        app.running = false
        break
      of WindowEvent:
        if event.window.event == WindowEvent_Resized:
          app.setLogicalSize(event.window.data1, event.window.data2)
      else:
        # call the user's event handler
        app.scenes.current.handle(event)

proc drawFrame(app: App) =
  # app.display.setRenderTarget(nil) # set window as render target
  # app.setLogicalSize() # configure the logical render size (output scaling)
  # app.clear(0, 0, 0)
  app.scenes.current.draw()
  app.display.present

proc run*(app: App, first_scene: Scene) =
  app.scenes.set_scene(first_scene)

  while app.running:
    app.updateFrame()
    app.handleEvents()
    app.drawFrame()

  # clean up
  destroy app.resources
  destroy app.display
  destroy app.window
  sdl2.quit()

