
import sdl2
from dadren/namedatlases import newNamedAtlasManager, load, render
from dadren/scenes import Scene
from dadren/application import App, newApp, getLogicalSize, run
from dadren/camera import Camera, newCamera, render, attach
from dadren/chunks import Tile
from dadren/generators import newStaticGenerator
from dadren/tilesets import loadPack, get
from dadren/tilemap import newTilemap

type
    GameTile = ref object of Tile
        name: string

    GameScene = ref object of Scene
        app: App
        camera: Camera[Tile]



proc newGameScene(app: App): GameScene =
    app.resources.tilesets.loadPack("plants.json")
    let tileset = app.resources.tilesets.get("plants")
    let tilemap = newTilemap(
        chunk_size=(8, 8),
        generator=newStaticGenerator(GameTile(name: "oak")))

    let camera = newCamera[GameTile](
        position=(0, 0),
        size=app.getLogicalSize(),
        tileset=tileset)

    camera.attach(tilemap)

    return GameScene(
        app: app,
        camera: camera)


method tile_name(self: GameTile): string =
    self.name

method draw(self: GameScene) =
  self.camera.render(self.app.display)

method update(self: GameScene, t, dt: float) =
    let keys = sdl2.getKeyboardState()

    if keys[sdl2.SDL_SCANCODE_ESCAPE.cint] != 0:
        self.app.running = false


let
    app = newApp(
        width=800,
        height=640,
        title="Tileset example (ESC to exit)")
    scene = newGameScene(app)


scene.draw()
app.run(scene)
