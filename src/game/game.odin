package game

import rl "../../raylib"
import "core:time"

ORANGE :: rl.Color{244, 96, 54, 255}

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
    player_to_mouse_dir: Vec2,
    player_dash_dir: Vec2, // Saves player_to_mouse_dir at the time of start of dash

    camera: rl.Camera2D,

    spirit_mode_on: bool,
    spirits_should_attack: bool,
}

GameplayState :: enum {
    IntroText,    // First X seconds of gameplay
    Gameplay,     // Active gameplay
    PauseForText, // Pausing for tutorial text
}

// General purpose stopwatch (Used for intro & texts)
stopwatch := time.Stopwatch{}

// Stopwatch for the player dash, and it's cooldown
player_dash_stopwatch := time.Stopwatch{}
DASH_DURATION :: time.Duration(0.1 *  f32(time.Second))
DASH_COOLDOWN :: time.Duration(1   *  f32(time.Second))

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
}

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
                    g_state.player_to_mouse_dir = Vec2_GetNormal(
                        Vec2_GetVectorTo(
                            g_state.player_hitbox.xy,
                            rl.GetScreenToWorld2D(rl.GetMousePosition(), g_state.camera)
                        )
                    )
                    

                    // Process movement input:
                    {
                        dash_in_progress := false
                        if rl.IsKeyPressed(.SPACE) {
                            // Start the dash only if it is not already running
                            if player_dash_stopwatch.running == false {
                                time.stopwatch_start(&player_dash_stopwatch)
                                dash_in_progress = true
                                g_state.player_dash_dir = g_state.player_to_mouse_dir
                            }
                        }

                        if player_dash_stopwatch.running == true && time.stopwatch_duration(player_dash_stopwatch) <= DASH_DURATION {
                            direction := Vec2_GetScaled(g_state.player_dash_dir, 350)

                            g_state.player_hitbox.x += direction.x * dt
                            g_state.player_hitbox.y += direction.y * dt
                        }

                        if time.stopwatch_duration(player_dash_stopwatch) >= DASH_COOLDOWN {
                            time.stopwatch_reset(&player_dash_stopwatch)
                            g_state.player_dash_dir = {}
                        }
                        
                        if dash_in_progress == false {
                            direction := Vec2{}
                            if rl.IsKeyDown(.S) do direction.y =  1
                            if rl.IsKeyDown(.W) do direction.y = -1
                            if rl.IsKeyDown(.D) do direction.x =  1
                            if rl.IsKeyDown(.A) do direction.x = -1

                            Vec2_Scale(&direction, 100)
    
                            g_state.player_hitbox.x += direction.x * dt
                            g_state.player_hitbox.y += direction.y * dt
                        }
                    }


                    if rl.IsKeyPressed(.ESCAPE) do g_state.menu_state = .Paused

                    g_state.spirits_should_attack = g_state.player_hitbox.y <= 800
                
                    g_state.camera.target.x = g_state.player_hitbox.x
                    g_state.camera.target.y = g_state.player_hitbox.y
                }
                case .IntroText: {
                    // If stopwatch is started, this will do nothing.
                    time.stopwatch_start(&stopwatch)

                    if rl.IsKeyPressed(.S) {
                        g_state.gameplay_state = .Gameplay
                        time.stopwatch_reset(&stopwatch)
                    }

                    // After a few seconds allow to skip
                    if time.stopwatch_duration(stopwatch) >= time.Duration(13 * time.Second) {
                        if rl.IsKeyPressed(.SPACE) {
                            g_state.gameplay_state = .Gameplay
                            time.stopwatch_reset(&stopwatch)
                        }
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
                    if time.stopwatch_duration(stopwatch) >= time.Duration( 1 * time.Second) do rl.DrawText("Lately.. the spirits have gone crazy. The whole world has.", 50, 70, 32,  ORANGE)
                    if time.stopwatch_duration(stopwatch) >= time.Duration( 4 * time.Second) do rl.DrawText("They started attacking people. This can't keep up.",         50, 120, 32, ORANGE)
                    if time.stopwatch_duration(stopwatch) >= time.Duration( 7 * time.Second) do rl.DrawText("I swore to keep the balance between our world and spirits.",    50, 170, 32, ORANGE)
                    if time.stopwatch_duration(stopwatch) >= time.Duration(10 * time.Second) do rl.DrawText("But now I have no option. I must protect the humans.",       50, 220, 32, ORANGE)
                    
                    // After a few seconds notice to skip
                    if time.stopwatch_duration(stopwatch) >= time.Duration(13 * time.Second) {
                        rl.DrawText("Press [space] to continue", 100, 270, 32, rl.WHITE)
                    }
                    
                }
            }

            if g_state.menu_state == .Paused {
                rl.DrawRectangle(0, 0, rl.GetScreenWidth(), rl.GetScreenHeight(), rl.Color{0, 0, 0, 255/3})

                rl.DrawText("Unpause with [Esc]", 10, 10, 32, rl.WHITE)
                rl.DrawText("Exit with [Q]\n",    10, 50, 32, rl.WHITE)
            } else if g_state.gameplay_state == .Gameplay{
                rl.DrawText("Pause with [Esc]", 10, 10, 32, rl.WHITE)
            }
        }
    }
}
