package game

import rl "../../raylib"
import "core:time"
import "core:strings"

import "core:fmt"

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
    player_spirit_energy: f32, // Gains 1.5 when hitting a spirit. Decreases constantly to 0. When above 3.0, can switch to spirit mode. (or something like that)

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
    attack_direction: Vec2,
    // Stopwatch for the attack process (warning & attacking after that)
    attack_stopwatch: time.Stopwatch,
    cooldown_stopwatch: time.Stopwatch,

    attack_cooldown: time.Duration,
    saved_player_pos: Vec2, // Saves player position when starting an attack
    player_pos_saved: bool,
    attacked_player: bool,
    got_attacked: bool,
}

// Between the time that the attack has been declared by a spirit and the time that this Duration is over, a warnign will be displayed
// After this duration is over, the spirit attacks (a saved position of the player)
SPIRIT_WARNING_DURATION         :: time.Duration(0.75 * f32(time.Second))
SPIRIT_SAVE_PLAYER_POS_DURATION :: time.Duration(1.25 * f32(time.Second))
SPIRIT_ATTACK_DURATION          :: time.Duration(2.25 * f32(time.Second))

// Spirithand AI
spirit_do_physical_AI :: proc(spirit: ^Spirit, dt: f32) {
    follow_radius_inner:f32 = 48 // spirit will try to stay at this distance from the player
    follow_radius_outer:f32 = 120 // spirit will not follow if player is further away
    _ = follow_radius_outer

    spirit_speed := f32(150)
    vec_to_player := Vec2_GetVectorTo(spirit.hitbox.pos, g_state.player_hitbox.pos)
    length := Vec2_GetLength(vec_to_player)

    spirit_is_far := length >= follow_radius_outer
    spirit_is_close_to_range := abs(length - follow_radius_inner) < 2

    // When the wpirit it far away, no need to do anything
    if !spirit_is_far {
        attack_is_off_cooldown := time.stopwatch_duration(spirit.cooldown_stopwatch) > spirit.attack_cooldown

        //fmt.println(time.stopwatch_duration(spirit.cooldown_stopwatch))

        Vec2_Normalize(&vec_to_player)
        
        // When the spirit is close enough to the radius-range, start circling the player
        // Also attack the player when the cooldown allows
        if spirit_is_close_to_range {
            if attack_is_off_cooldown {
                time.stopwatch_reset(&spirit.cooldown_stopwatch)
                time.stopwatch_start(&spirit.cooldown_stopwatch)

                time.stopwatch_reset(&spirit.attack_stopwatch)
                time.stopwatch_start(&spirit.attack_stopwatch)

                spirit.player_pos_saved = false
                spirit.attacked_player = false
                spirit.got_attacked = false
            }
            
            if !spirit.attack_stopwatch.running {
                vec_to_player = Vec2{
                    vec_to_player.y,
                    -vec_to_player.x,
                }
                spirit_speed = 75
            } else {
                spirit_speed = 0
            }
        } else if length < follow_radius_inner {
            // If the spirit is too close (and not circling), make it go backwards
            vec_to_player *= -1
        }

        // Attack toward player's saved location
        if time.stopwatch_duration(spirit.attack_stopwatch) > SPIRIT_WARNING_DURATION {
            if !spirit.player_pos_saved &&
               time.stopwatch_duration(spirit.attack_stopwatch) > SPIRIT_SAVE_PLAYER_POS_DURATION {
                spirit.saved_player_pos = g_state.player_hitbox.pos
                spirit.player_pos_saved = true
            }

            // Check for attacks:
            // - if the spirit got hit, it cannot hit back
            // - the player can hit back after getting hit (also gains energy)
            if !spirit.got_attacked {
                attack_radius := PLAYER_PHYSICAL_ATTACK_RADIUS
                if g_state.spirit_mode_on do attack_radius = PLAYER_SPIRIT_ATTACK_RADIUS
                if Vec2_GetDistance(spirit.hitbox.pos, g_state.player_attack_pos) < spirit.hitbox.r + attack_radius {
                    spirit.got_attacked = true
                    fmt.println("Spirit got hit")
                    g_state.player_spirit_energy += 1.5
                }
            } else if !spirit.attacked_player {
                if Vec2_GetDistance(spirit.hitbox.pos, g_state.player_hitbox.pos) < spirit.hitbox.r + g_state.player_hitbox.r {
                    spirit.attacked_player = true
                    fmt.println("A hit")
                }
            }
            vec_to_player = Vec2_GetNormal(Vec2_GetVectorTo(spirit.hitbox.pos, spirit.saved_player_pos))
            
            // If the spirit is already at the saved target location, stay there untill the stopwatch is done
            spirit_speed = 200 if Vec2_GetDistance(spirit.hitbox.pos, spirit.saved_player_pos) > 5 else 0
            // Don't move for a while before attack
            if time.stopwatch_duration(spirit.attack_stopwatch) <= SPIRIT_SAVE_PLAYER_POS_DURATION && spirit.attack_stopwatch.running {
                spirit_speed = 0
            }
        }
        if time.stopwatch_duration(spirit.attack_stopwatch) > SPIRIT_ATTACK_DURATION {
            time.stopwatch_reset(&spirit.attack_stopwatch)
        }
    
        Vec2_Scale(&vec_to_player, spirit_speed)
        spirit.hitbox.pos += vec_to_player * dt
    }

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

// ===========================================================================================================================
// ===========================================================================================================================
// ===========================================================================================================================
init :: proc() {
    fmt.println("Starting...")
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
        new_spirit := Spirit{
            hitbox = HitBox{
                pos = spirit_pos,
                r = 4,  
            },
            variant = .Sad if rl.GetRandomValue(0, 1) == 0 else .Crazy,
            attack_cooldown = time.Duration(rl.GetRandomValue(3, 7)) * time.Second,
            attack_stopwatch = time.Stopwatch{},
            cooldown_stopwatch = time.Stopwatch{},
        }
        time.stopwatch_start(&new_spirit.attack_stopwatch)
        time.stopwatch_start(&new_spirit.cooldown_stopwatch)

        append(&g_state.spirits, new_spirit)
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

                    // Spirit energy upkeep:
                    {
                        g_state.player_spirit_energy -= 0.12 * dt // roughly -1 point every 10 seconds
                        if g_state.player_spirit_energy < 0 do g_state.player_spirit_energy = 0
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

                            Vec2_Scale(&direction, 75)
    
                            g_state.player_hitbox.pos += direction * dt
                        }
                    }

                    // Process spirit behaviour
                    {
                        for &spirit in g_state.spirits {
                            spirit_do_physical_AI(&spirit, dt)
                        }
                    }

                    // Resolve player collisions
                    tile_size:f32 = 16.0
                    tile_pos := Vec2{}
                    for row in lvl0 {
                        for char in row {
                            // Only check for water-tiles & tiles that are close enough
                            if 'A' <= char && char <= 'F' && Vec2_GetDistance(g_state.player_hitbox.pos, tile_pos) <= 30 {
                                resolve_tilecollision(&g_state.player_hitbox, {tile_pos.x, tile_pos.y, tile_size, tile_size})
                            }
                            tile_pos.x += tile_size
                        }
                        tile_pos.x = 0
                        tile_pos.y += tile_size
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
                        if g_state.spirit_mode_on {
                            rl.DrawTexturePro(
                                spirit_textrs[spirit.variant],
                                spirit_position,
                                {spirit.hitbox.pos.x, spirit.hitbox.pos.y, spirit_position.width, spirit_position.height},
                                spirit_origin, 0, rl.WHITE
                            )
                        } else {
                            if spirit.attack_stopwatch.running && time.stopwatch_duration(spirit.attack_stopwatch) <= SPIRIT_WARNING_DURATION {
                                rl.DrawTexturePro(
                                    spirit_hand_warning_textr,
                                    spirit_hand_warning_position,
                                    {spirit.hitbox.pos.x, spirit.hitbox.pos.y, spirit_hand_warning_position.width, spirit_hand_warning_position.height},
                                    spirit_hand_warning_origin,
                                    0,
                                    rl.WHITE
                                )
                            } else if spirit.attack_stopwatch.running && time.stopwatch_duration(spirit.attack_stopwatch) <= SPIRIT_ATTACK_DURATION {
                                rl.DrawTexturePro(
                                    spirit_hand_textr,
                                    spirit_hand_position,
                                    {spirit.hitbox.pos.x, spirit.hitbox.pos.y, spirit_hand_position.width, spirit_hand_position.height},
                                    spirit_hand_origin,
                                    0,
                                    rl.WHITE
                                )
                            }
                        }
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

