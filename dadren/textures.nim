## Overview
## ========
## A **Texture** represents raw image data, in GPU memory, ready for drawing. A **TextureManager** can load and cache Textures, index them by name, and make sure they are all destroyed at once. It can also load Texture resource-packs.

import json
import marshal
import os
import strutils
import tables

from sdl2 import WindowPtr, SurfacePtr, RendererPtr, TexturePtr
from sdl2 import getError, createTextureFromSurface, destroy, copy
from sdl2/image import load

from ./exceptions import NoSuchResourceError, InvalidResourceError
from ./packs import loadPack
from ./utils import Size


proc loadSurface(window: WindowPtr, filename: string): SurfacePtr =
  ## Load an image from the disk as a Surface in system memory
  if not existsFile(filename):
    let msg = "The image `" & filename & "` does not exist."
    raise newException(InvalidResourceError, msg)

  result = load(filename)
  if result == nil:
    let
      error = getError()
      msg = "The image `$1` could not be loaded: $2"
    raise newException(InvalidResourceError, msg.format(filename, error))

proc loadTexture(display: RendererPtr, surface: SurfacePtr): TexturePtr =
  ## Load an image from the Surface as a Texture in graphics memory
  result = display.createTextureFromSurface(surface)
  if result == nil:
    let
      error = getError()
      msg = "Texture could not be loaded from surface: $1"
    raise newException(InvalidResourceError, msg.format(error))

type
  TextureInfo* = object
    ## Meta-data describing a Texture
    filename*: string ## filename used to load the Texture
    name*: string ## name of the Texture
    description*: string ## a description of the Texture
    authors*: seq[string] ## authors of the Texture

  Texture* = ref object
    ## Used for rendering image data
    info*: TextureInfo ## meta-data describing the Texture
    width*: int ## width of the Texture in pixels
    height*: int ## height of the Texture in pixels
    handle: TexturePtr ## Pointer to actual Texture

  TextureManager* = ref object
    ## Used for loading and managing Textures
    window: WindowPtr ## window for loading image files
    display: RendererPtr ## display for rendering Textures
    registry: Table[string, Texture] ## Loaded Textures by name

proc destroy(texture: Texture) =
  texture.handle.destroy
  texture.handle = nil

proc destroy*(tm: TextureManager) =
  ## Destroy references to each loaded texture. The TextureManager will have no
  ## loaded Textures after calling this.
  for name, texture in tm.registry.pairs:
    texture.destroy
  tm.registry = initTable[string, Texture]()

proc newTextureManager*(window: WindowPtr, display: RendererPtr): TextureManager =
  new(result)
  result.window = window
  result.display = display
  result.registry = initTable[string, Texture]()

proc contains*(tm: TextureManager, name: string): bool =
  name in tm.registry

proc checkFilename(filename: string) =
  if filename == nil:
    let msg = "Cannot load Texture without filename."
    raise newException(NoSuchResourceError, msg)

  if not existsFile(filename):
    let msg = "The texture image `$1` could not be found."
    raise newException(NoSuchResourceError, msg.format(filename))

proc load*(tm: TextureManager,
           name, filename: string,
           description: string = nil,
           authors: seq[string] = nil): Texture =

  if name in tm:
    return tm.registry[name]

  checkFilename(filename)

  let
    surface = tm.window.loadSurface(filename)
    info = TextureInfo(
      name:name, filename:filename, description:description, authors:authors)
    handle = tm.display.loadTexture(surface)
  result = Texture(info:info,
                   handle:handle,
                   width: surface.w.int,
                   height: surface.h.int)
  tm.registry[name] = result

proc loadPack*(tm: TextureManager, filename: string) =
  ## Load a resource-pack of Textures. Assets inside of a Texture resource-pack
  ## should be objects with at least a **filename** field.
  ##
  ## **Example TextureAsset JSON**
  ##
  ## .. code-block:: nimrod
  ##    "example_texture": {
  ##      "filename": "textures/example_texture.png", # required
  ##      "description": "A texture used as an example",
  ##      "authors": ["foo", "bar"]
  ##    }

  let
    pack = loadPack(filename)
    (path, _, _) = splitFile(filename)
  for name, asset_data in pack:
    var info = to[TextureInfo]($asset_data)

    if info.filename == "" or info.filename == nil:
      raise newException(InvalidResourceError, "Texture assets must specify filename.")

    discard tm.load(name, path / info.filename, info.description, info.authors)

proc get*(tm: TextureManager, name: string): Texture =
  if not tm.registry.hasKey(name):
    let msg = "No texture with name `" & name & "` is loaded."
    raise newException(NoSuchResourceError, msg)
  tm.registry[name]

proc render*(display: RendererPtr, texture: Texture, x, y: int) =
  ## Blit the entire Texture to the target renderer as the specifed coordinates.
  var dst: sdl2.Rect = (x.cint,
                        y.cint,
                        texture.width.cint,
                        texture.height.cint)
  display.copy(texture.handle, cast[ptr sdl2.Rect](nil), dst.addr)

proc render*(display: RendererPtr, texture: Texture,
             sx, sy, dx, dy, width, height: int) =
  ## Blit a specific region of the Texture to the target renderer as the specified
  ## coordinates.
  var
    src = (sx.cint, sy.cint, width.cint, height.cint)
    dst = (dx.cint, dy.cint, width.cint, height.cint)
  display.copy(texture.handle, src.addr, dst.addr)

