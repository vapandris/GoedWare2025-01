package game

Vec2 :: [2]f32
Vec4 :: [4]f32

HitBox :: struct {
    pos: Vec2,
    r: f32, //radius
}

// Vec2:
Vec2_GetLength :: proc(v: Vec2) -> f32 {
    return sqrt(sq(v.x) + sq(v.y))
}

Vec2_GetNormal :: proc(v: Vec2) -> Vec2 {
    if v == {} do return v

    length := Vec2_GetLength(v)
    return {
        v.x / length,
        v.y / length,
    }
}

Vec2_Normalize :: proc(v: ^Vec2) {
    normal := Vec2_GetNormal(v^)
    if normal == {} do return

    v^ = normal
}


Vec2_GetScaled :: proc(v: Vec2, scaler: f32) -> Vec2 {
    scaled := Vec2_GetNormal(v)
    scaled.x *= scaler
    scaled.y *= scaler

    return scaled
}

Vec2_Scale :: proc(v: ^Vec2, scaler: f32) {
    v^ = Vec2_GetScaled(v^, scaler)
}

Vec2_GetVectorTo :: proc(start: Vec2, end: Vec2) -> Vec2 {
    return  end - start
}

Vec2_GetDistance :: proc(p1: Vec2, p2: Vec2) -> f32 {
    return Vec2_GetLength(p1 - p2)
}

// Math:
sqrt :: proc(num: f32) -> f32 {
    num := num
    if num < 0 do num *= -1
  
    i: i32
    x, y: f32
  
    x = num * 0.5
    y = num
    i = (cast(^i32)&y)^
    i = 0x5f3759df - (i >> 1)
    y = (cast(^f32)&i)^
    y = y * (1.5 - (x * y * y))
    y = y * (1.5 - (x * y * y))
  
    return num * y
}
  
sq :: proc(num: f32) -> f32 {
    return num * num
}

clamp :: proc(bot: f32, top: f32, num: f32) -> f32 {
    return max(bot, min(num, top))
}