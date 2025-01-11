package game

import rl "../../raylib"

GameState :: struct {
    player_pos: Vec2,
    camera: rl.Camera2D,
    spirit_mode_on: bool,
}

g_state: ^GameState

init :: proc() {
    g_state^ = GameState {
        player_pos = {100, 200},
        camera = {
            offset = Vec2{
                cast(f32)rl.GetScreenWidth()  / 2,
                cast(f32)rl.GetScreenHeight() / 2,
            },
            target = {},
            zoom = cast(f32)rl.GetScreenWidth() / 320,
        }
    }
    assets_init()
}

update :: proc() {
    g_state.spirit_mode_on = true
    dt := rl.GetFrameTime()
    if rl.IsKeyDown(.S) do g_state.camera.target.y += 300 * dt
    if rl.IsKeyDown(.W) do g_state.camera.target.y -= 300 * dt
    if rl.IsKeyDown(.D) do g_state.camera.target.x += 300 * dt
    if rl.IsKeyDown(.A) do g_state.camera.target.x -= 300 * dt
}

draw :: proc() {
    rl.BeginDrawing()
    defer rl.EndDrawing()

    rl.ClearBackground(rl.BLACK)

    rl.BeginMode2D(g_state.camera)
    defer rl.EndMode2D()

    tile_size:f32 = 16.0
    tile_pos := Vec2{}

    tile_position_offset_x: f32 = 0.0
    if g_state.spirit_mode_on {
        tile_position_offset_x = tile_spiritOffsetX
    }

    for row in lvl0 {
        for char in row {
            tile_textr: ^rl.Texture2D
            tile_positions: []rl.Rectangle
            index: u8

            if '1' <= char && char <= '8' {
                ascii_offset: u8 = cast(u8)'1'
                tile_textr = &grass_textr
                tile_positions = grass_tile_positions[:]
                index = cast(u8)char - ascii_offset
            } else if 'A' <= char && char <= 'F' {
                ascii_offset: u8 = cast(u8)'A'
                tile_textr = &water_textr
                tile_positions = water_tile_positions[:]
                index = cast(u8)char - ascii_offset
            } else {
                panic("invalid char detected")
            }

            rl.DrawTexturePro(
                tile_textr^,
                {tile_positions[index].x + tile_position_offset_x, tile_positions[index].y, tile_positions[index].width, tile_positions[index].height},
                {tile_pos.x, tile_pos.y, 16, 16},
                {}, 0, rl.WHITE
            )

            tile_pos.x += tile_size
        }
        tile_pos.x = 0
        tile_pos.y += tile_size
    }

    
}
