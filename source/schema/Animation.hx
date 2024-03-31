// 
// THIS FILE HAS BEEN GENERATED AUTOMATICALLY
// DO NOT CHANGE IT MANUALLY UNLESS YOU KNOW WHAT YOU'RE DOING
// 
// GENERATED USING @colyseus/schema 2.0.29
// 
package schema;

import io.colyseus.serializer.schema.Schema;
import io.colyseus.serializer.schema.types.*;

class Animation extends Schema {
	@:type("string")
	public var name: String = "";

	@:type("string")
	public var frameName: String = "";

	@:type("number")
	public var frameRate: Dynamic = 0;

}
