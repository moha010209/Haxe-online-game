// 
// THIS FILE HAS BEEN GENERATED AUTOMATICALLY
// DO NOT CHANGE IT MANUALLY UNLESS YOU KNOW WHAT YOU'RE DOING
// 
// GENERATED USING @colyseus/schema 2.0.29
// 
package schema;

import io.colyseus.serializer.schema.Schema;
import io.colyseus.serializer.schema.types.*;

class Sprite extends Schema {
	@:type("string")
	public var type: String = "";

	@:type("number")
	public var x: Dynamic = 0;

	@:type("number")
	public var y: Dynamic = 0;

	@:type("string")
	public var imagePath: String = "";

	@:type("number")
	public var width: Dynamic = 0;

	@:type("number")
	public var height: Dynamic = 0;

	@:type("number")
	public var angle: Dynamic = 0;

	@:type("number")
	public var alpha: Dynamic = 0;

	@:type("boolean")
	public var flipX: Bool = false;

	@:type("array", "number")
	public var skewPos:ArraySchema<Dynamic> = new ArraySchema<Dynamic>();

	@:type("string")
	public var animation: String = "";

	@:type("map", Animation)
	public var animations: MapSchema<Animation> = new MapSchema<Animation>();

	@:type("boolean")
	public var animated:Bool = false;

}
