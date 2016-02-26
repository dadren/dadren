import json
import math
import sdl2
import marshal
import tables
import strutils

from dadren/namedatlases import newNamedAtlasManager, load, render
from dadren/scenes import Scene
from dadren/application import App, newApp, getLogicalSize, run
from dadren/camera import Camera, newCamera, render, attach
from dadren/chunks import Tile
from dadren/generators import Generator, SimpleGenerator
from dadren/tilesets import loadPack, get
from dadren/tilemap import newTilemap, Tilemap, clear
from dadren/utils import Point, Region
from dadren/magic import aggregate

type
    GameTile = ref object of Tile
        name: string

    Position = object
        x, y: int

    Velocity = object
        dx, dy: float

    Size = object
        dx, dy: int

    Icon = object
        rune: string

aggregate(Ball, [Position, Velocity, Icon])
aggregate(Paddle, [Position, Icon, Size])

converter tuple2position(p: tuple[x, y: int]): Position =
    Position(x: p.x, y: p.y)

converter paddle2region(p: Paddle): Region =
    result.x = p.position.x
    result.y = p.position.y
    result.w = p.size.dx
    result.h = p.size.dy


let ballDef = json.parseJson("""
{
    "ball": {
        "Position": {"x": 10, "y": 10},
        "Velocity": {"dx": 1.0, "dy": 0.0},
        "Icon": {"rune": "shroom"}

    }
}
""")

let paddlesDef = json.parseJson("""
{
    "left_paddle": {
        "Position": {"x": 1, "y": 1},
        "Icon": {"rune": "shroom"},
        "Size": {"dx": 1, "dy": 10}
    },
    "right_paddle": {
        "Icon": {"rune": "shroom"},
        "Position": {"x": 20, "y": 1},
        "Size": {"dx": 1, "dy": 10}
    }
}
""")


type
    Gamestate = ref object
        ball: Ball
        left_paddle: Paddle
        right_paddle: Paddle
        last_moved_ball: float
        ball_speed: tuple[x, y: float]

    GameScene = ref object of Scene
        app: App
        camera: Camera[GameTile]
        state: Gamestate
        tilemap: Tilemap[GameTile]


proc contains(r: Region, p: Position): bool =
    (r.x <= p.x and p.x < r.x + r.w) and (r.y <= p.y and p.y < r.y + r.h)


proc newGamestate(): Gamestate =
    var bm = newBallManager()
    bm.load(ballDef)
    var pm = newPaddleManager()
    pm.load(paddlesDef)

    return Gamestate(
        ball: bm.create("ball"),
        left_paddle: pm.create("left_paddle"),
        right_paddle: pm.create("right_paddle"),
        last_moved_ball: 0)

proc is_paddle(state: Gamestate, pos: Position): bool =
    paddle2region(state.left_paddle).contains(pos) or paddle2region(state.right_paddle).contains(pos)

proc is_ball(state: Gamestate, pos: Position): bool =
    state.ball.position[] == pos

proc move_down(state: Gamestate) =
    state.left_paddle.position.y += 1

proc move_up(state: Gamestate) =
    state.left_paddle.position.y -= 1

proc update_ball(state: Gamestate, dt: float) =
    if state.last_moved_ball + dt > 0.1:
        let ball = state.ball

        ball.position.x = int(float(ball.position.x) + ball.velocity.dx)
        ball.position.y = int(float(ball.position.y) + ball.velocity.dy)
        state.last_moved_ball = 0

        let
            left = state.left_paddle
            right = state.right_paddle
            bounce_left = ball.position.x == left.position.x and ball.velocity.dx < 0
            bounce_right = ball.position.x == right.position.x and ball.velocity.dx > 0

        if bounce_left or bounce_right:
            ball.velocity.dx = -ball.velocity.dx
            if math.random(1.0) < 0.5:
                ball.velocity.dy = -1
            else:
                ball.velocity.dy = 1

        if ball.position.y <= 0 and ball.velocity.dy < 0:
            ball.velocity.dy = -ball.velocity.dy

    state.last_moved_ball += dt


proc newPongGenerator(gamestate: Gamestate): Generator[GameTile] =
    let ballTile: GameTile = GameTile(name: "ball")
    let paddleTile: GameTile = GameTile(name: "paddle")
    let emptyTile: GameTile = GameTile(name: "empty")

    SimpleGenerator() do (x, y: int)-> GameTile:
        if gamestate.is_ball((x, y)):
            ballTile
        elif gamestate.is_paddle((x, y)):
            paddleTile
        else:
            emptyTile


proc newGameScene(app: App): GameScene =
    app.resources.tilesets.loadPack("pong.json")
    let tileset = app.resources.tilesets.get("pong")
    let state = newGamestate()
    let tilemap = newTilemap(
        chunk_size=(8, 8),
        generator=newPongGenerator(state))

    let camera = newCamera[GameTile](
        position=(0, 0),
        size=app.getLogicalSize(),
        tileset=tileset)

    camera.attach(tilemap)

    return GameScene(
        app: app,
        camera: camera,
        state: state,
        tilemap: tilemap)


method tile_name(self: GameTile): string =
    self.name

method draw(self: GameScene) =
    self.camera.render(self.app.display)

method update(self: GameScene, t, dt: float) =
    let keys = sdl2.getKeyboardState()

    if keys[sdl2.SDL_SCANCODE_ESCAPE.cint] != 0:
        self.app.running = false
    elif keys[sdl2.SDL_SCANCODE_DOWN.cint] != 0:
        self.state.move_down()
    elif keys[sdl2.SDL_SCANCODE_UP.cint] != 0:
        self.state.move_up()

    self.tilemap.clear()
    self.state.update_ball(dt)


let
    app = newApp(
        width=800,
        height=640,
        title="Pong example (ESC to exit)")
    scene = newGameScene(app)

scene.draw()
app.run(scene)
