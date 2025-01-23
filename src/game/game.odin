package game

// import "core:fmt"
import rl "../../raylib"
import "core:time"
import "core:strings"

ORANGE :: rl.Color{244, 96, 54, 255}
YELLOW :: rl.Color{255, 210, 63, 255}

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
    enter_tutorial: bool,

    player_hitbox: HitBox,
    player_to_mouse_dir: Vec2,
    player_dash_dir: Vec2,   // Saves player_to_mouse_dir at the time of start of dash
    player_attack_dir: Vec2, // Saves player_to_mouse_dir at the time of start of attack
    player_attack_pos: Vec2,

    spirits:     [dynamic]Spirit,

    camera: rl.Camera2D,

    spirit_mode_on: bool,
    spirits_should_attack: bool,
}

PLAYER_PHYSICAL_ATTACK_RADIUS: f32 : 8/2
PLAYER_SPIRIT_ATTACK_RADIUS:   f32 : 16/2

SpiritVariant :: enum { Sad, Crazy }
Spirit :: struct {
    hitbox: HitBox,
    variant: SpiritVariant,
    attack_stopwatch: time.Stopwatch,
    attack_cooldown: time.Duration,
    attack_direction: Vec2,
}

// Spirithand AI
spirit_do_physical_AI :: proc(spirit: ^Spirit, dt: f32) {
    follow_radius_inner:f32 = 36 // spirit will try to stay at this distance from the player
    follow_radius_outer:f32 = 68 // spirit will not follow if player is further away
    _ = follow_radius_outer

    vec_to_player := Vec2_GetVectorTo(spirit.hitbox.pos, g_state.player_hitbox.pos)
    length := Vec2_GetLength(vec_to_player)

    // Resolve collisions among spirits:
    for &s in g_state.spirits {
        // Can skip itself (both are pointers)
        if spirit == &s {
            continue
        }

        v := Vec2_GetVectorTo(spirit.hitbox.pos, s.hitbox.pos)
        if Vec2_GetLength(v) < spirit.hitbox.r + s.hitbox.r {
            overlap := (spirit.hitbox.r + s.hitbox.r) - Vec2_GetLength(v)

            spirit.hitbox.pos += Vec2_GetScaled(-v, overlap/2)
            s.hitbox.pos      += Vec2_GetScaled( v, overlap/2)
        }
    }

    // When the wpirit it far away, no need to do anything
    if length >= follow_radius_outer {
        return
    }

    // When the spirit is close enough to the hand, no need to move it around (prevent jiggling)
    if abs(length - follow_radius_inner) < 1 {
        return
    }

    Vec2_Normalize(&vec_to_player)
    
    // If the spirit is too far away, make it go closer
    // If the spirit is too close, make it go backwards
    vec_to_inner_radius := vec_to_player if (length >= follow_radius_inner) else vec_to_player * -1.0

    Vec2_Scale(&vec_to_inner_radius, 100)
    spirit.hitbox.pos += vec_to_inner_radius * dt
}

GameplayState :: enum {
    IntroText,    // First X seconds of gameplay
    Gameplay,     // Active gameplay
    PauseForText, // Pausing for tutorial text
}

tutorial_text_counter := 0
tutorial_texts := [?]string{
    "Move around with AWSD, dodge danger with [space]",

    "An angry spirit is attacking! Dodge with [space]!",

    "Now whack it with [left click]!",

    "You gained some spirit energy. Gather enough to enter the spirit world!",

    "Press E to enter the spirit world for a limited time!",

    "In the spirit world you can fight spirits face on! Good luck! :)",
}

// General purpose stopwatch (Used for intro & texts)
stopwatch := time.Stopwatch{}

// Stopwatch for the player dash, and it's cooldown
player_dash_stopwatch := time.Stopwatch{}
DASH_DURATION :: time.Duration(0.1 * f32(time.Second))
DASH_COOLDOWN :: time.Duration(0.8 * f32(time.Second))

// Stopwatch for attack, and it's cooldown
player_attack_stopwatch := time.Stopwatch{}
ATTACK_DURATON  :: time.Duration(0.15 * f32(time.Second))
ATTACK_COOLDOWN :: time.Duration(0.50 * f32(time.Second))

g_state: ^GameState
//import "core:fmt"
// ===========================================================================================================================
// ===========================================================================================================================
// ===========================================================================================================================
init :: proc() {
    g_state^ = GameState {
        menu_state = .MainMenu,
        gameplay_state = .IntroText,
        enter_tutorial = true,
        player_hitbox = {{PLAYER_START_POS.x, PLAYER_START_POS.y}, 8},

        spirits = [dynamic]Spirit{},

        camera = {
            offset = Vec2{
                cast(f32)rl.GetScreenWidth()  / 2,
                cast(f32)rl.GetScreenHeight() / 2,
            },
            target = {},
            zoom = cast(f32)rl.GetScreenWidth() / RESOLUTION_WIDTH,
        }
    }
    now := time.now()
    h, m, s := time.clock_from_time(now)
    rl.SetRandomSeed(u32(h*60*60 + m*60 + s))

    for spirit_pos in spirit_positions {
        append(
            &g_state.spirits,
            Spirit{
                hitbox = HitBox{
                    pos = spirit_pos,
                    r = 4,  
                },
                variant = .Sad if rl.GetRandomValue(0, 1) == 0 else .Crazy,
                attack_cooldown = time.Duration(rl.GetRandomValue(3, 7)) * time.Second
            }
        )
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
                    dt := rl.GetFrameTime()
                    g_state.player_to_mouse_dir = Vec2_GetNormal(
                        Vec2_GetVectorTo(
                            g_state.player_hitbox.pos,
                            rl.GetScreenToWorld2D(rl.GetMousePosition(), g_state.camera)
                        )
                    )

                    if g_state.enter_tutorial {
                        g_state.gameplay_state = .PauseForText
                        time.stopwatch_reset(&stopwatch)
                    }

                    // Process player input:
                    {
                        // Process dash
                        stop_movement := false
                        {
                            // Start the dash only if it is not already in-progress/on-cooldown
                            if rl.IsKeyPressed(.SPACE) && player_dash_stopwatch.running == false {
                                time.stopwatch_start(&player_dash_stopwatch)
                                g_state.player_dash_dir = g_state.player_to_mouse_dir
                            }

                            // Dash is in-progress
                            if time.stopwatch_duration(player_dash_stopwatch) <= DASH_DURATION  && player_dash_stopwatch.running == true {
                                stop_movement = true
                                time.stopwatch_start(&player_dash_stopwatch) // If there was a pause, we need to continue
                                direction := Vec2_GetScaled(g_state.player_dash_dir, 350)

                                g_state.player_hitbox.pos += direction * dt
                            }

                            // Dash is on cooldown
                            if time.stopwatch_duration(player_dash_stopwatch) >= DASH_COOLDOWN {
                                time.stopwatch_reset(&player_dash_stopwatch)

                                g_state.player_dash_dir = {}
                            }
                        }

                        // Process attack
                        {
                            // Start the attack only if it is not already in-progress/on-cooldown
                            if rl.IsMouseButtonPressed(.LEFT) && player_attack_stopwatch.running == false {
                                time.stopwatch_start(&player_attack_stopwatch)
                                g_state.player_attack_dir = g_state.player_to_mouse_dir
                            }

                            // Attack is in-progress
                            if time.stopwatch_duration(player_attack_stopwatch) <= ATTACK_DURATON && player_attack_stopwatch.running == true {
                                g_state.player_attack_pos = g_state.player_hitbox.pos + Vec2_GetScaled(g_state.player_attack_dir, 12)
                                stop_movement = true
                            }

                            // Attack is on cooldown
                            if time.stopwatch_duration(player_attack_stopwatch) >= ATTACK_COOLDOWN {
                                time.stopwatch_reset(&player_attack_stopwatch)

                                g_state.player_attack_dir = {}
                            }
                        }

                        // Spirit mode stuff
                        {
                            if rl.IsKeyPressed(.E) do g_state.spirit_mode_on = !g_state.spirit_mode_on
                        }
                        
                        // Process basic movement
                        if stop_movement == false {
                            direction := Vec2{}
                            if rl.IsKeyDown(.S) do direction.y =  1
                            if rl.IsKeyDown(.W) do direction.y = -1
                            if rl.IsKeyDown(.D) do direction.x =  1
                            if rl.IsKeyDown(.A) do direction.x = -1

                            Vec2_Scale(&direction, 100)
    
                            g_state.player_hitbox.pos += direction * dt
                        }
                    }

                    // Process spirit behaviour
                    {
                        for &spirit in g_state.spirits {
                            spirit_do_physical_AI(&spirit, dt)
                        }
                    }


                    if rl.IsKeyPressed(.ESCAPE) {
                        g_state.menu_state = .Paused
                        time.stopwatch_stop(&player_dash_stopwatch)
                        time.stopwatch_stop(&player_attack_stopwatch)
                    }

                    g_state.spirits_should_attack = g_state.player_hitbox.pos.y <= 800
                
                    g_state.camera.target = g_state.player_hitbox.pos
                }
                case .IntroText: {
                    // If stopwatch is started, this will do nothing.
                    time.stopwatch_start(&stopwatch)

                    if rl.IsKeyPressed(.S) {
                        g_state.gameplay_state = .Gameplay
                        time.stopwatch_reset(&stopwatch)
                    }

                    // After a few seconds allow to skip
                    if time.stopwatch_duration(stopwatch) >= time.Duration(13 * time.Second) &&
                       rl.IsKeyPressed(.SPACE) {
                        g_state.gameplay_state = .Gameplay
                        time.stopwatch_reset(&stopwatch)
                    }
                }
                case .PauseForText: {
                    // If stopwatch is started, this will do nothing.
                    time.stopwatch_start(&stopwatch)

                    // After a few seconds allow to skip
                    if time.stopwatch_duration(stopwatch) >= time.Duration(2 * time.Second) &&
                       rl.IsKeyPressed(.SPACE) {
                        g_state.gameplay_state = .Gameplay
                        g_state.enter_tutorial = false
                        time.stopwatch_reset(&stopwatch)
                    }
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

                            tile_pos.x += tile_size
                        }
                        tile_pos.x = 0
                        tile_pos.y += tile_size
                    }

                    attack_radius := PLAYER_PHYSICAL_ATTACK_RADIUS
                    if g_state.spirit_mode_on do attack_radius = PLAYER_SPIRIT_ATTACK_RADIUS

                    // Draw attack either above or bellow the player based on it's direction
                    if time.stopwatch_duration(player_attack_stopwatch) <= ATTACK_DURATON && player_attack_stopwatch.running == true &&
                       Vec2_GetVectorTo(g_state.player_hitbox.pos, g_state.player_attack_pos).y < 0 {
                        rl.DrawCircle(
                            i32(g_state.player_attack_pos.x), i32(g_state.player_attack_pos.y),
                            attack_radius, rl.WHITE
                        )
                    }

                    rl.DrawTexturePro(
                        shaman_textr,
                        {shaman_sprite_position.x + current_shaman_offset_x, shaman_sprite_position.y, shaman_sprite_position.width, shaman_sprite_position.height},
                        {g_state.player_hitbox.pos.x, g_state.player_hitbox.pos.y, shaman_sprite_position.width, shaman_sprite_position.height},
                        shaman_sprite_origin, 0, rl.WHITE
                    )

                    if time.stopwatch_duration(player_attack_stopwatch) <= ATTACK_DURATON && player_attack_stopwatch.running == true &&
                       Vec2_GetVectorTo(g_state.player_hitbox.pos, g_state.player_attack_pos).y > 0 {
                        rl.DrawCircle(
                            i32(g_state.player_attack_pos.x), i32(g_state.player_attack_pos.y),
                            attack_radius, rl.WHITE
                        )
                    }

                    for spirit in g_state.spirits {
                        rl.DrawCircle(
                            i32(spirit.hitbox.pos.x), i32(spirit.hitbox.pos.y),
                            spirit.hitbox.r, rl.BLACK
                        )
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

            if g_state.menu_state == .Paused || g_state.gameplay_state == .PauseForText {
                rl.DrawRectangle(0, 0, rl.GetScreenWidth(), rl.GetScreenHeight(), rl.Color{0, 0, 0, 255/3})
            }

            if g_state.gameplay_state == .PauseForText {
                if time.stopwatch_duration(stopwatch) >= time.Duration( 0.5 * f32(time.Second)) {
                    rl.DrawText(
                        strings.unsafe_string_to_cstring(tutorial_texts[tutorial_text_counter]),
                        50, 70, 32, YELLOW
                    )
                     rl.DrawText(
                        "Attack with [left click] and enter & leave spirit mode with E.",
                        50, 120, 32, YELLOW
                    )
                    rl.DrawText(
                        "Nothing else to do, it's not finished :/",
                        50, 170, 32, YELLOW
                    )
                }
                
                if time.stopwatch_duration(stopwatch) >= time.Duration( 2 * time.Second) do rl.DrawText("Press [space] to continue", 100, 220, 32, rl.WHITE)
            }
            
            if g_state.menu_state == .Paused {
                rl.DrawText("Unpause with [Esc]", 10, 10, 32, rl.WHITE)
                rl.DrawText("Exit with [Q]\n",    10, 50, 32, rl.WHITE)
            } else if g_state.gameplay_state == .Gameplay{
                rl.DrawText("Pause with [Esc]", 10, 10, 32, rl.WHITE)
            }
        }
    }
}

