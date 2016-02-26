import unittest
import sequtils

include ../dadren/textures

echo "textures.nim"

suite "textures.nim":
  setup:
    let
      tm = newTextureManager(nil, nil)
      temp_dir = getCurrentDir() / "tmp"
      textures_dir = temp_dir / "textures"
      example = "example_image.png"
      pack_filename = temp_dir / "textures.json"
      incomplete_filename = temp_dir / "incomplete_textures.json"

    let texture_pack = %*
      {
        "assets": {
          "example_image": {
            "filename": "textures" / example,
            "description": "A texture used as an example",
            "authors": ["foo", "bar"]
          }
        }
      }

    let incomplete_pack = %*
      {
        "assets": {
          "example_image": {
            "description": "A texture used as an example",
            "authors": ["foo", "bar"]
          }
        }
      }

    createDir(temp_dir)
    createDir(textures_dir)
    writeFile(pack_filename, $(texture_pack))
    writeFile(incomplete_filename, $(incomplete_pack))
    copyFile(example, textures_dir / example)

  teardown:
    removeDir(temp_dir)

  test "texture packs":
    expect Exception:
      tm.loadPack(pack_filename)

  test "requires filename":
    expect InvalidResourceError:
      tm.loadPack(incomplete_filename)
