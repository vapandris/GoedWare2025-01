package game

import rl "../../raylib"

ASSETS_PATH :: "assets/"
TITLE_PATH  :: ASSETS_PATH + "GW-title.png"
GRASS_PATH  :: ASSETS_PATH + "GW-grass.png"
WATER_PATH  :: ASSETS_PATH + "GW-water.png"
SHAMAN_PATH :: ASSETS_PATH + "GW-shaman.png"
SPIRIT_1    :: ASSETS_PATH + "GW-spirit1.png"
SPIRIT_2    :: ASSETS_PATH + "GW-spirit2.png"

SHAMAN_WHACK        :: ASSETS_PATH + "GW-shaman-whack.png"
SHAMAN_SWIPE        :: ASSETS_PATH + "GW-shaman-swipe.png"
SPIRIT_HAND_WARNING :: ASSETS_PATH + "GW-spirit-hand-warning.png"
SPIRIT_HAND         :: ASSETS_PATH + "GW-spirit-hand.png"

title_textr:  rl.Texture2D
grass_textr:  rl.Texture2D
water_textr:  rl.Texture2D
shaman_textr: rl.Texture2D
spirit_textrs: [2]rl.Texture2D

shaman_whack_textr:        rl.Texture2D
shaman_swipe_textr:        rl.Texture2D
spirit_hand_warning_textr: rl.Texture2D
spirit_hand:               rl.Texture2D

assets_init :: proc() {
    title_textr = rl.LoadTexture(TITLE_PATH)
    grass_textr = rl.LoadTexture(GRASS_PATH)
    water_textr = rl.LoadTexture(WATER_PATH)
    shaman_textr = rl.LoadTexture(SHAMAN_PATH)
    spirit_textrs[0] = rl.LoadTexture(SPIRIT_1)
    spirit_textrs[1] = rl.LoadTexture(SPIRIT_2)
    
    shaman_whack_textr = rl.LoadTexture(SHAMAN_WHACK)
    shaman_swipe_textr = rl.LoadTexture(SHAMAN_SWIPE)
    spirit_hand_warning_textr = rl.LoadTexture(SPIRIT_HAND_WARNING)
    spirit_hand = rl.LoadTexture(SPIRIT_HAND)

    if title_textr.id  <= 0     do panic("invalid path: " + TITLE_PATH)    
    if grass_textr.id  <= 0     do panic("invalid path: " + GRASS_PATH)
    if water_textr.id  <= 0     do panic("invalid path: " + WATER_PATH)
    if shaman_textr.id <= 0     do panic("invalid path: " + SHAMAN_PATH)
    if spirit_textrs[0].id <= 0 do panic("invalid path: " + SPIRIT_1)
    if spirit_textrs[1].id <= 0 do panic("invalid path: " + SPIRIT_2)

    if shaman_whack_textr.id <= 0 do panic("invalid path: " + SHAMAN_WHACK)
    if shaman_swipe_textr.id <= 0 do panic("invalid path: " + SHAMAN_SWIPE)
    if spirit_hand_warning_textr.id <= 0 do panic("invalid path: " + SPIRIT_HAND_WARNING)
    if spirit_hand.id <= 0 do panic("invalid path: " + SPIRIT_HAND)
}

// Tiles
tile_spiritOffsetX:f32 = 32.0
grass_tile_positions := [?]rl.Rectangle{
    { 0,  0, 16, 16},
    { 0, 16, 16, 16},
    { 0, 32, 16, 16},
    { 0, 48, 16, 16},
    {16,  0, 16, 16},
    {16, 16, 16, 16},
    {16, 32, 16, 16},
    {16, 48, 16, 16},
}

water_tile_positions := [?]rl.Rectangle{
    { 0,  0, 16, 16},
    { 0, 16, 16, 16},
    { 0, 32, 16, 16},
    {16,  0, 16, 16},
    {16, 16, 16, 16},
    {16, 32, 16, 16},
}

// Shaman
shaman_spiritOffsetX: f32 = 16.0
shaman_sprite_position  := rl.Rectangle{ 0, 0, 16, 27}
shaman_sprite_origin    := Vec2{0, -3}