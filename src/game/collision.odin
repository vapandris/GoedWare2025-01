package game

resolve_tilecollision :: proc(hitBox: ^HitBox, rect: Vec4) {
    closest_point: Vec2
    closest_point.x = clamp(rect.x, rect.x + rect[2], hitBox.pos.x)
    closest_point.y = clamp(rect.y, rect.y + rect[3], hitBox.pos.y)

    vector_to_cpoint := Vec2_GetVectorTo(hitBox.pos, closest_point)
    if Vec2_GetLength(vector_to_cpoint) < hitBox.r {
        hitBox.pos += (-Vec2_GetNormal(vector_to_cpoint)) * (hitBox.r - Vec2_GetLength(vector_to_cpoint))
    }
}