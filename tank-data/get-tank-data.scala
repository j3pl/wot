import scala.io.Source
import scala.util.parsing.json.JSON

val type_map = Map(
  "Light Tanks" -> "lt",
  "Medium Tanks" -> "mt",
  "Heavy Tanks" -> "ht",
  "Tank Destroyers" -> "td",
  "SPGs" -> "spg"
)

val tier_map = Map(
  "I" -> 1,
  "II" -> 2,
  "III" -> 3,
  "IV" -> 4,
  "V" -> 5,
  "VI" -> 6,
  "VII" -> 7,
  "VIII" -> 8,
  "IX" -> 9,
  "X" -> 10
)

JSON.globalNumberParser = {input : String => input.toInt}
val matchmaker_json = Source.fromFile("matchmaker-0.8.3.json").mkString

println(1)
val matchmaker = JSON.parseFull(matchmaker_json) match {
  case Some(m: Map[String, Any]) => println(m)
  case _ => ()
}
