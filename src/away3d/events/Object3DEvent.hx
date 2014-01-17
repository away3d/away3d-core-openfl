/**
 * Passed as a parameter when a 3d object event occurs
 */
package away3d.events;

import away3d.core.base.Object3D;
import flash.events.Event;

class Object3DEvent extends Event {

/**
	 * Defines the value of the type property of a visiblityUpdated event object.
	 */
    static public var VISIBLITY_UPDATED:String = "visiblityUpdated";
/**
	 * Defines the value of the type property of a scenetransformChanged event object.
	 */
    static public var SCENETRANSFORM_CHANGED:String = "scenetransformChanged";
/**
	 * Defines the value of the type property of a sceneChanged event object.
	 */
    static public var SCENE_CHANGED:String = "sceneChanged";
/**
	 * Defines the value of the type property of a positionChanged event object.
	 */
    static public var POSITION_CHANGED:String = "positionChanged";
/**
	 * Defines the value of the type property of a rotationChanged event object.
	 */
    static public var ROTATION_CHANGED:String = "rotationChanged";
/**
	 * Defines the value of the type property of a scaleChanged event object.
	 */
    static public var SCALE_CHANGED:String = "scaleChanged";
/**
	 * A reference to the 3d object that is relevant to the event.
	 */
    public var object:Object3D;
/**
	 * Creates a new <code>MaterialEvent</code> object.
	 *
	 * @param    type        The type of the event. Possible values are: <code>Object3DEvent.TRANSFORM_CHANGED</code>, <code>Object3DEvent.SCENETRANSFORM_CHANGED</code>, <code>Object3DEvent.SCENE_CHANGED</code>, <code>Object3DEvent.RADIUS_CHANGED</code> and <code>Object3DEvent.DIMENSIONS_CHANGED</code>.
	 * @param    object        A reference to the 3d object that is relevant to the event.
	 */

    public function new(type:String, object:Object3D) {
        super(type);
        this.object = object;
    }

/**
	 * Creates a copy of the Object3DEvent object and sets the value of each property to match that of the original.
	 */

    override public function clone():Event {
        return new Object3DEvent(type, object);
    }

}

