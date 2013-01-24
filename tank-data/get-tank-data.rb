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

def parse_tank_data(html)
  doc = Nokogiri::HTML(html)
  doc.xpath("//*[contains(@class, 'b-encyclopedia-type')]").collect do |type|
    tanks = type.xpath("following-sibling::*//*[contains(@class, 'b-encyclopedia-list_point')]").collect do |tank|
      url  = tank.xpath(".//a[contains(@class, 'b-encyclopedia-list_linc')]/@href").first.text
      tier = tank.xpath(".//*[contains(@class, 'b-encyclopedia-list_level')]").first.text
      name = tank.xpath(".//*[contains(@class, 'b-encyclopedia-list_name')]").first.text
      {
        :name => name.strip,
        :tier => @tier_map[tier],
        :url => "#{@url_base}#{url}",
        :type => @type_map[type.text.strip]
      }
    end
  end.flatten
end

html = open("wot-encyclopedia.html").read
tanks = parse_tank_data(html)

puts tanks.to_json
