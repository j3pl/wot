require "nokogiri"
require "json"
require "open-uri"

@url_base = "http://worldoftanks.com/"

@type_map = {
  "Light Tanks" => "lt",
  "Medium Tanks" => "mt",
  "Heavy Tanks" => "ht",
  "Tank Destroyers" => "td",
  "SPGs" => "spg"
}

@tier_map = {
  "I" => 1,
  "II" => 2,
  "III" => 3,
  "IV" => 4,
  "V" => 5,
  "VI" => 6,
  "VII" => 7,
  "VIII" => 8,
  "IX" => 9,
  "X" => 10
}

@matchmaker = {
  :by_tank => {
    "bison_i"         => [3, 5],
    "t2_lt"           => [2, 4],
    "m3_stuart_ll"    => [3, 4],
    "bt-sv"           => [3, 4],
    "pzii_j"          => [3, 4],
    "t-127"           => [3, 4],
    "t-50"            => [5, 9],
    "vk1602"          => [5, 9],
    "valentine_ll"    => [4, 4],
    "b-1bis_captured" => [4, 4],
    "a-32"            => [4, 5],
    "amx40"           => [4, 6],
    "gb04_valentine"  => [4, 6],
    "gb60_covenanter" => [4, 6],
    "elc_amx"         => [6, 9],
    "pziv_hydro"      => [5, 6],
    "churchill_ll"    => [5, 6],
    "matilda_ii_ll"   => [5, 6],
    "t14"             => [5, 6],
    "kv-220"          => [5, 6],
    "m4a2e4"          => [5, 6],
    "gb20_crusader"   => [5, 7],
    "pzv_pziv"        => [6, 7],
    "gb63_tog_ii"     => [6, 7],
    "panther_m10"     => [7, 8],
    "kv-5"            => [8, 9],
    "object252"       => [8, 9],
    "fcm_50t"         => [8, 9],
    "ch01_type59"     => [8, 9],
    "jagdtiger_sdkfz_185" => [8, 9],
    "t26_e4_superpershing" => [8, 9],
    "gb68_matilda_black_prince" => [5, 6],
    "pzv_pziv_ausf_alfa" => [6, 7]
  },
  :by_type => {
    "lt" => [
             [1, 2],
             [2, 3],
             [3, 5],
             [4, 8],
             [7, 12],
             [7, 10],
             [8, 11],
             [9, 12],
             nil,
             nil
            ],
    "mt" => [
             [1, 2],
             [2, 3],
             [3, 5],
             [4, 6],
             [5, 7],
             [6, 8],
             [7, 9],
             [8, 10],
             [9, 11],
             [10, 12]
            ],
    "ht" => [
             nil,
             [2, 3],
             [3, 5],
             [4, 5],
             [5, 7],
             [6, 8],
             [7, 9],
             [8, 10],
             [9, 11],
             [10, 12]
            ],
    "td" => [
             nil,
             [2, 3],
             [3, 5],
             [4, 6],
             [5, 7],
             [6, 8],
             [7, 9],
             [8, 10],
             [9, 11],
             [10, 12]
            ],
    "spg" => [
              nil,
              [3, 4],
              [4, 6],
              [5, 8],
              [7, 9],
              [9, 10],
              [10, 11],
              [11, 12],
              nil,
              nil
             ]
  }
}

def tank_battle_tiers(id, type, tier)
  @matchmaker[:by_tank][id] || @matchmaker[:by_type][type][tier - 1]
end

def parse_tank(type, tank_node)
  name = tank_node.xpath(".//*[contains(@class, 'b-encyclopedia-list_name')]").first.text.strip
  relative_url = tank_node.xpath(".//a[contains(@class, 'b-encyclopedia-list_linc')]/@href").first.text
  tier_text = tank_node.xpath(".//*[contains(@class, 'b-encyclopedia-list_level')]").first.text
  
  id = relative_url.split("/").last.downcase
  url = "#{@url_base}#{relative_url}"
  tier = @tier_map[tier_text]

  (bt_min, bt_max) = tank_battle_tiers(id, type, tier)
  
  {
    :id => id,
    :name => name,
    :type => type,
    :tier => tier,
    :url => url,
    :battle_tier_min => bt_min,
    :battle_tier_max => bt_max
  }
end

def parse_tank_data(html)
  doc = Nokogiri::HTML(html)
  type_nodes = doc.xpath("//*[contains(@class, 'b-encyclopedia-type')]")
  type_nodes.collect do |type_node|
    type = @type_map[type_node.text.strip]
    tank_nodes = type_node.xpath("following-sibling::*//*[contains(@class, 'b-encyclopedia-list_point')]")
    tanks = tank_nodes.collect {|tank_node| parse_tank(type, tank_node) }
  end.flatten
end

html = open("wot-encyclopedia.html").read
tanks = parse_tank_data(html)

puts tanks.to_json
