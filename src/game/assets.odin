package game

import rl "../../raylib"

ASSETS_PATH :: "assets/"
TITLE_PATH  :: ASSETS_PATH + "GW-title.png"
GRASS_PATH  :: ASSETS_PATH + "GW-grass.png"
WATER_PATH  :: ASSETS_PATH + "GW-water.png"
SHAMAN_PATH :: ASSETS_PATH + "GW-shaman.png"

title_textr:  rl.Texture2D
grass_textr:  rl.Texture2D
water_textr:  rl.Texture2D
shaman_textr: rl.Texture2D

assets_init :: proc() {
    title_textr = rl.LoadTexture(TITLE_PATH)
    grass_textr = rl.LoadTexture(GRASS_PATH)
    water_textr = rl.LoadTexture(WATER_PATH)
    shaman_textr = rl.LoadTexture(SHAMAN_PATH)

    if title_textr.id  <= 0 do panic("invalid path: " + TITLE_PATH)    
    if grass_textr.id  <= 0 do panic("invalid path: " + GRASS_PATH)
    if water_textr.id  <= 0 do panic("invalid path: " + WATER_PATH)
    if shaman_textr.id <= 0 do panic("invalid path: " + SHAMAN_PATH)
}

grass_tile_spiritOffsetX := 32
grass_tile_positions := [8]rl.Rectangle{
    { 0,  0, 16, 16},
    { 0, 16, 16, 16},
    { 0, 32, 16, 16},
    { 0, 48, 16, 16},
    {16,  0, 16, 16},
    {16, 16, 16, 16},
    {16, 32, 16, 16},
    {16, 48, 16, 16},
}

water_tile_spiritOffsetX := 32
water_tile_positions := [8]rl.Rectangle{
    { 0,  0, 16, 16},
    { 0, 16, 16, 16},
    { 0, 32, 16, 16},
    {16,  0, 16, 16},
    {16, 16, 16, 16},
    {16, 32, 16, 16},
    {},
    {},
}