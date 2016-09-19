import tables

import ./utils

type
  Tile* = ref object of RootObj

  Chunk* = seq[Tile]

method tile_name*(t: Tile): string {.base.} =
  quit "Tile type must override tile_name"

proc newChunk*(size: int): Chunk = newSeq[Tile](size)
