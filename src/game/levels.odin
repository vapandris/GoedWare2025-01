package game

// A-F = water
// 1-8 = land

// Tutorial:
PLAYER_START_POS :: Vec2{390, 912}
spirit_positions := [?]Vec2{
    {390, 912 - 10*16}, // 10 tile above the player start pos (and so on)
    
    {360, 912 - 18*16},
    {420, 912 - 18*16},

    {310, 912 - 26*16},
    {360, 912 - 25*16},
    {350, 912 - 27*16},

    {600, 912 - 24*16},
    {612, 912 - 29*16},
}
lvl0 := [?]string {
    "DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDBDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDCDDDDDDDDDDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDDDDDDDDDDDDDDDFDDDDDDDDD58585812D328766412DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD88435284356D41254216753817DDDDDDDDDDDDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD8678642624168D5512182742753343DDDDDDDDDDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD5625818741313D8471851388264516DDDDDDDDDDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD762183478351AE7428732563368254DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDA36333671816D3865562784386332ADFDDDDDDDDDDDDDDDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDAAAAA16AAAAD741775626188767ADDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD516111476832358652282347188DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDBDD54553163684315455621367713ADDD11DDDDDDDDDDDDDDDDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDA5863338871463283555427AAADD3714DDDDDDDDDDDDDDDDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD7125717653378668721444DDDDDAAAADDDDDDDDDDDDDDDDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDA715657166342783AAA7577755412247DDDDDDDDDDDDDDDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDDDDDDDDDDDDDDFDDDDDDDDA447864387267516DFAA8713673273845527DDDDDDDDDDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD81541385126865145647168216232765211634DDDDDDDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD348373265852235672778561454322252262775DDDDDDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDA723773377457745237216623425887768316111273DDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDAAA173367142342666174517458535554623634323DDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDCDDDDDDDDDDAAAAAAAAAA276411155287171488681565346AADDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDCDDDDDDDDDDDDAAAAAAAA1313356284344811617DDDDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDA7533872A2442377836DDDDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD36272361822762DDDDDDDDDDDDDDD12364AADA325624563DDDDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDDDDDDDDDD1554142256284811856336674444814884DDDA1513DFDDA153846822DDDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDDDD7768284375163734811573414663125245227811674434415DD872317743AADDDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDD8485125361423213685854778272842585711447812266637276461471175747DDDDDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDD82467335863286721813762874772144275383116623721376252888571664624DDDDDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDD15432532272873661876428425614224881648326678746326873175711874AAADDDDDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDAAA43813478578515654653443864344763816886441673322315466AAAAAADDDDDDDDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDDAA658615253652518228526428265AAAAAA34AAAAAA128125AAAADDDDDDDDDDDDDDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDDDDA6322458762246675165AAAAAAADDDDDD2361DDD451312ADDFDDDDDDDDDDDDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDFDD457656111852536AAAAADDDDDDDDDDDDDAA567112316AADDDDDDDDDDDDDDDDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDDD8421136534355AAADDDDDDDDDDDDDDFDDDDDA637125AADDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDDD825237213763ADDDDDDD11DDDDDDDDDDDDDDDAAAAAADDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDDD732724551331DCDDDD821513DDDDDDDDBDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDDD113413376566DDDDDDAA314ADDDDDDDDDDDDDDDDDDEDDDDDDDDDDDDDDDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDD1455628468377415DDDDDAAADDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDD2265582561644622DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDBDDD7821724535883565DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDD5331211223383268DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDDA55312133487335ADDDCDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDDD45174877755615DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDDD33782284821343DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDDD18758237628487DDDDDDDDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDDDA16443377287AADDDDDDDDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDDDDAA77848385ADDDDDDDDDDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDDDDDDA3518AAADDDDDDDDDDDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDFDDDDD418ADDDDDDDDDDDDDDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDDDDDDDA23DDDDCDDDDDDDDDDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDDDD82184322DDDDDDDDDDDDDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDD73268377154826DDDDDDDDDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDD31817224547586DDDDDDDDDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDDAA64287333363ADDDDDDDDDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDEDDDDA56485723AADDDDDDDDDDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDDDDDAAAAAAAADDDDCDDDDDDDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDDDDDDDDDDDDDBDDDDDDDDDDDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDCDDDDDD",
    "DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD",
    "DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD",
}