package game

import rl "../../raylib"
import "core:time"

RESOLUTION_HEIGHT: f32 : 180
RESOLUTION_WIDTH : f32 : 320

PLAYER_HITBOX_DIAMETER:f32 : 12

MenuState :: enum {
    MainMenu,
    Game,
    Paused,
}
GameState :: struct {
    menu_state: MenuState,
    gameplay_state: GameplayState,

    player_hitbox: Vec4,
    camera: rl.Camera2D,
    spirit_mode_on: bool,
}

GameplayState :: enum {
    IntroText,    // First X seconds of gameplay
    Gameplay,     // Active gameplay
    PauseForText, // Pausing for tutorial text
}

stopwatch := time.Stopwatch{}

tutorial_text_counter := 0
TUTORIAL_TEXTS :: [?]string{
    "Move around with AWSD, dodge danger with [space]",
    "An angry spirit is attacking! Dodge with [space]!",
    "Now whack it with [left click]!",
    "You gained some spirit energy.",
    "Gather enough to enter the spirit world!",
    "Press E to enter the spirit world!",
    "In the spirit world you can fight spirits face on! Good luck! :)",
}

g_state: ^GameState

init :: proc() {
    g_state^ = GameState {
        menu_state = .MainMenu,
        gameplay_state = .IntroText,
        player_hitbox = {PLAYER_START_POS.x, PLAYER_START_POS.y, shaman_sprite_position.width, shaman_sprite_position.height},
        camera = {
            offset = Vec2{
                cast(f32)rl.GetScreenWidth()  / 2,
                cast(f32)rl.GetScreenHeight() / 2,
            },
            target = {},
            zoom = cast(f32)rl.GetScreenWidth() / RESOLUTION_WIDTH,
        }
    }
    assets_init()
    time.stopwatch_start(&stopwatch)
}
import "core:fmt"
update :: proc() {
    switch g_state.menu_state {
        case .MainMenu: {
            if rl.IsKeyPressed(.SPACE) do g_state.menu_state = .Game
        }
        case .Game: {
            switch g_state.gameplay_state {
                case .Gameplay: {
                    g_state.spirit_mode_on = false
                    dt := rl.GetFrameTime()
                    if rl.IsKeyDown(.S) do g_state.player_hitbox.y += 100 * dt
                    if rl.IsKeyDown(.W) do g_state.player_hitbox.y -= 100 * dt
                    if rl.IsKeyDown(.D) do g_state.player_hitbox.x += 100 * dt
                    if rl.IsKeyDown(.A) do g_state.player_hitbox.x -= 100 * dt
                    if rl.IsKeyPressed(.ESCAPE) do g_state.menu_state = .Paused
                
                    g_state.camera.target.x = g_state.player_hitbox.x
                    g_state.camera.target.y = g_state.player_hitbox.y
                }
                case .IntroText: {
                    // If stopwatch is started will do nothing.
                    time.stopwatch_start(&stopwatch)
                    fmt.println(time.stopwatch_duration(stopwatch))

                    if time.stopwatch_duration(stopwatch) >= time.Duration(5 * time.Second) {
                        g_state.gameplay_state = .Gameplay
                        time.stopwatch_reset(&stopwatch)
                    }
                }
                case .PauseForText: {

                }
            }
        }
        case .Paused: {
            if rl.IsKeyPressed(.ESCAPE) do g_state.menu_state = .Game
            if rl.IsKeyPressed(.Q)      do game_should_exit = true
        }
    }
}

draw :: proc() {
    switch g_state.menu_state {
        case .MainMenu: {
            rl.BeginDrawing()
            defer rl.EndDrawing()
        
            rl.ClearBackground(rl.BLACK)

            scale := f32(rl.GetScreenHeight()) / RESOLUTION_HEIGHT
            rl.DrawTextureEx(
                title_textr, Vec2{},
                0.0, scale, rl.WHITE
            )
            rl.DrawRectangle(0, 0, rl.GetScreenWidth(), rl.GetScreenHeight(), rl.Color{0, 0, 0, 255/5})

            rl.DrawText("press [space] to play", rl.GetScreenWidth()/2, rl.GetScreenHeight()/2, 32, rl.WHITE)
        }
        case .Game, .Paused: {
            rl.BeginDrawing()
            defer rl.EndDrawing()
        
            rl.ClearBackground(rl.BLACK)
            
            switch g_state.gameplay_state
            {
                case .Gameplay, .PauseForText: {
                    rl.BeginMode2D(g_state.camera)
                    defer rl.EndMode2D()
                
                    tile_size:f32 = 16.0
                    tile_pos := Vec2{}
                
                    current_tile_offset_x: f32 = 0.0
                    current_shaman_offset_x: f32 = 0.0
                    if g_state.spirit_mode_on {
                        current_tile_offset_x   = tile_spiritOffsetX
                        current_shaman_offset_x = shaman_spiritOffsetX
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
                                {tile_positions[index].x + current_tile_offset_x, tile_positions[index].y, tile_positions[index].width, tile_positions[index].height},
                                {tile_pos.x, tile_pos.y, 16, 16},
                                {}, 0, rl.WHITE
                            )
                
                            rl.DrawTexturePro(
                                shaman_textr,
                                {shaman_sprite_position.x + current_shaman_offset_x, shaman_sprite_position.y, shaman_sprite_position.width, shaman_sprite_position.height},
                                {g_state.player_hitbox.x, g_state.player_hitbox.y, shaman_sprite_position.width, shaman_sprite_position.height},
                                shaman_sprite_origin, 0, rl.WHITE
                            )
                
                            tile_pos.x += tile_size
                        }
                        tile_pos.x = 0
                        tile_pos.y += tile_size
                    }
                }
                case .IntroText: {
                    
                }
            }

            if g_state.menu_state == .Paused {
                rl.DrawRectangle(0, 0, rl.GetScreenWidth(), rl.GetScreenHeight(), rl.Color{0, 0, 0, 255/3})

                rl.DrawText("Unpause with [Esc]", 10, 10, 32, rl.WHITE)
                rl.DrawText("Exit with [Q]\n",    10, 50, 32, rl.WHITE)
            } else {
                rl.DrawText("Pause with [Esc]", 10, 10, 32, rl.WHITE)
            }
        }
    }
}
