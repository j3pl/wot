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

@matchmaker = JSON.load(open("matchmaker-0.8.3.json"))

def tank_battle_tiers(id, type, tier)
  @matchmaker["by_tank"][id] || @matchmaker["by_type"][type][tier - 1]
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
