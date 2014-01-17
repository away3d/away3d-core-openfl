/**
 * A MouseEvent3D is dispatched when a mouse event occurs over a mouseEnabled object in View3D.
 * todo: we don't have screenZ data, tho this should be easy to implement
 */
package away3d.events;


import away3d.containers.ObjectContainer3D;
import away3d.containers.View3D;
import away3d.core.base.IRenderable;
import away3d.materials.MaterialBase;
import flash.events.Event;
import flash.geom.Point;
import flash.geom.Vector3D;

class MouseEvent3D extends Event {
    public var scenePosition(get_scenePosition, never):Vector3D;
    public var sceneNormal(get_sceneNormal, never):Vector3D;

// Private.
    private var _allowedToPropagate:Bool;
    private var _parentEvent:MouseEvent3D;
/**
	 * Defines the value of the type property of a mouseOver3d event object.
	 */
    static public var MOUSE_OVER:String = "mouseOver3d";
/**
	 * Defines the value of the type property of a mouseOut3d event object.
	 */
    static public var MOUSE_OUT:String = "mouseOut3d";
/**
	 * Defines the value of the type property of a mouseUp3d event object.
	 */
    static public var MOUSE_UP:String = "mouseUp3d";
/**
	 * Defines the value of the type property of a mouseDown3d event object.
	 */
    static public var MOUSE_DOWN:String = "mouseDown3d";
/**
	 * Defines the value of the type property of a mouseMove3d event object.
	 */
    static public var MOUSE_MOVE:String = "mouseMove3d";
/**
	 * Defines the value of the type property of a rollOver3d event object.
	 */
//		public static const ROLL_OVER : String = "rollOver3d";
/**
	 * Defines the value of the type property of a rollOut3d event object.
	 */
//		public static const ROLL_OUT : String = "rollOut3d";
/**
	 * Defines the value of the type property of a click3d event object.
	 */
    static public var CLICK:String = "click3d";
/**
	 * Defines the value of the type property of a doubleClick3d event object.
	 */
    static public var DOUBLE_CLICK:String = "doubleClick3d";
/**
	 * Defines the value of the type property of a mouseWheel3d event object.
	 */
    static public var MOUSE_WHEEL:String = "mouseWheel3d";
/**
	 * The horizontal coordinate at which the event occurred in view coordinates.
	 */
    public var screenX:Float;
/**
	 * The vertical coordinate at which the event occurred in view coordinates.
	 */
    public var screenY:Float;
/**
	 * The view object inside which the event took place.
	 */
    public var view:View3D;
/**
	 * The 3d object inside which the event took place.
	 */
    public var object:ObjectContainer3D;
/**
	 * The renderable inside which the event took place.
	 */
    public var renderable:IRenderable;
/**
	 * The material of the 3d element inside which the event took place.
	 */
    public var material:MaterialBase;
/**
	 * The uv coordinate inside the draw primitive where the event took place.
	 */
    public var uv:Point;
/**
	 * The index of the face where the event took place.
	 */
    public var index:Int;
/**
	 * The index of the subGeometry where the event took place.
	 */
    public var subGeometryIndex:Int;
/**
	 * The position in object space where the event took place
	 */
    public var localPosition:Vector3D;
/**
	 * The normal in object space where the event took place
	 */
    public var localNormal:Vector3D;
/**
	 * Indicates whether the Control key is active (true) or inactive (false).
	 */
    public var ctrlKey:Bool;
/**
	 * Indicates whether the Alt key is active (true) or inactive (false).
	 */
    public var altKey:Bool;
/**
	 * Indicates whether the Shift key is active (true) or inactive (false).
	 */
    public var shiftKey:Bool;
/**
	 * Indicates how many lines should be scrolled for each unit the user rotates the mouse wheel.
	 */
    public var delta:Int;
/**
	 * Create a new MouseEvent3D object.
	 * @param type The type of the MouseEvent3D.
	 */

    public function new(type:String) {
        _allowedToPropagate = true;
        super(type, true, true);
    }

/**
	 * @inheritDoc
	 */
#if flash
    @:getter(bubbles) function get_bubbles():Bool {
        var doesBubble:Bool = super.bubbles && _allowedToPropagate;
        _allowedToPropagate = true;
// Don't bubble if propagation has been stopped.
        return doesBubble;
    }
#end
/**
	 * @inheritDoc
	 */

    override public function stopPropagation():Void {
        super.stopPropagation();
        _allowedToPropagate = false;
        if (_parentEvent != null) _parentEvent.stopPropagation();
    }

/**
	 * @inheritDoc
	 */

    override public function stopImmediatePropagation():Void {
        super.stopImmediatePropagation();
        _allowedToPropagate = false;
        if (_parentEvent != null) _parentEvent.stopImmediatePropagation();
    }

/**
	 * Creates a copy of the MouseEvent3D object and sets the value of each property to match that of the original.
	 */

    override public function clone():Event {
        var result:MouseEvent3D = new MouseEvent3D(type);
#if flash
        if (isDefaultPrevented()) result.preventDefault();
		#end
        result.screenX = screenX;
        result.screenY = screenY;
        result.view = view;
        result.object = object;
        result.renderable = renderable;
        result.material = material;
        result.uv = uv;
        result.localPosition = localPosition;
        result.localNormal = localNormal;
        result.index = index;
        result.subGeometryIndex = subGeometryIndex;
        result.delta = delta;
        result.ctrlKey = ctrlKey;
        result.shiftKey = shiftKey;
        result._parentEvent = this;
        result._allowedToPropagate = _allowedToPropagate;
        return result;
    }

/**
	 * The position in scene space where the event took place
	 */

    public function get_scenePosition():Vector3D {
        if (Std.is(object, ObjectContainer3D)) return cast((object), ObjectContainer3D).sceneTransform.transformVector(localPosition)
        else return localPosition;
    }

/**
	 * The normal in scene space where the event took place
	 */

    public function get_sceneNormal():Vector3D {
        if (Std.is(object, ObjectContainer3D)) {
            var sceneNormal:Vector3D = cast((object), ObjectContainer3D).sceneTransform.deltaTransformVector(localNormal);
            sceneNormal.normalize();
            return sceneNormal;
        }

        else return localNormal;
    }

}

