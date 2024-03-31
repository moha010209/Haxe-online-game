// 
// THIS FILE HAS BEEN GENERATED AUTOMATICALLY
// DO NOT CHANGE IT MANUALLY UNLESS YOU KNOW WHAT YOU'RE DOING
// 
// GENERATED USING @colyseus/schema 2.0.29
// 
package schema;

import io.colyseus.serializer.schema.Schema;
import io.colyseus.serializer.schema.types.*;

class GameState extends Schema {
	@:type("map", Player)
	public var players: MapSchema<Player> = new MapSchema<Player>();

	@:type("map", Sprite)
	public var objects:MapSchema<Sprite> = new MapSchema<Sprite>();
}
