import tables

import ./utils

type
  Tile* = ref object of RootObj

  Chunk* = TableRef[Point, Tile]

method tile_name*(t: Tile): string {.base.} =
  quit "Tile type must override tile_name"

proc newChunk*(): Chunk = newTable[Point, Tile]()
