package game

// A-F = water
// 1-8 = land

// Tutorial:
PLAYER_START_POS :: Vec2{390, 816}
lvl0 := [?]string {
    "DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD11111111D111111111DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD11111111111D11111111111111DDDDDDDDDDDDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD1111111111111D1111111111111111DDDDDDDDDDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD1111111111111D1111111111111111DDDDDDDDDDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD111111111111AD1111111111111111DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDA11111111111D1111111111111111ADDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDAAAAA11AAAAD111111111111111ADDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD111111111111111111111111111DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD11111111111111111111111111ADDD11DDDDDDDDDDDDDDDDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDA1111111111111111111111AAADD1111DDDDDDDDDDDDDDDDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD1111111111111111111111DDDDDAAAADDDDDDDDDDDDDDDDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDA111111111111111AAA1111111111111DDDDDDDDDDDDDDDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDA111111111111111DDAA1111111111111111DDDDDDDDDDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD1111111111111111DD11111111111111111111DDDDDDDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD111111111111111111111111111111111111111DDDDDDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDA111111111111111111111111111111111111111111DDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDAAA111111111111111111111111111111111111111DDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDAAAAAAAAAA111111111111111111111111111AADDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDAAAAAAAA1111111111111111111DDDDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDA1111111A1111111111DDDDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD11111111111111DDDDDDDDDDDDDDD11111AADA111111111DDDDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDDDDDDDDDD1111111111111111111111111111111111DDDA1111DDDDA111111111DDDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDDDD1111111111111111111111111111111111111111111111111DD111111111AADDDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDD1111111111111111111111111111111111111111111111111111111111111111DDDDDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDD11111111111111111111111111111111111111111111111111111111111111111DDDDDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDD11111111111111111111111111111111111111111111111111111111111111AAADDDDDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDAAA11111111111111111111111111111111111111111111111111111AAAAAADDDDDDDDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDDAA111111111111111111111111111AAAAAA11AAAAAA111111AAAADDDDDDDDDDDDDDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDDDDA1111111111111111111AAAAAAADDDDDD1111DDD111111ADDDDDDDDDDDDDDDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDDDD111111111111111AAAAADDDDDDDDDDDDDAA111111111AADDDDDDDDDDDDDDDDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDDD1111111111111AAADDDDDDDDDDDDDDDDDDDDA111111AADDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDDD111111111111ADDDDDDD11DDDDDDDDDDDDDDDAAAAAADDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDDD111111111111DDDDDD111111DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDDD111111111111DDDDDDAA111ADDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDD1111111111111111DDDDDAAADDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDD1111111111111111DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDD1111111111111111DDDDDDDDDDDDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDD1111111111111111DDDDDDDDDDDDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDDA11111111111111ADDDDDDDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDDD11111111111111DDDDDDDDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDDD11111111111111DDDDDDDDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDDD11111111111111DDDDDDDDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDDDA11111111111AADDDDDDDDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDDDDAA11111111ADDDDDDDDDDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDDDDDDA1111AAADDDDDDDDDDDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDDDDDDD111ADDDDDDDDDDDDDDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDDDDDDDA11DDDDDDDDDDDDDDDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDDDD11111111DDDDDDDDDDDDDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDD11111111111111DDDDDDDDDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDD11111111111111DDDDDDDDDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDDAA11111111111ADDDDDDDDDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDDDDA11111111AADDDDDDDDDDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDDDDDAAAAAAAADDDDDDDDDDDDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD",
}