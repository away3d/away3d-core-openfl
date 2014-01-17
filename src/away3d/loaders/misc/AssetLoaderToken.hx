/**
 * Dispatched when any asset finishes parsing. Also see specific events for each
 * individual asset type (meshes, materials et c.)
 *
 * @eventType away3d.events.AssetEvent
 */
//[Event(name="assetComplete", type="away3d.events.AssetEvent")]
/**
 * Dispatched when a full resource (including dependencies) finishes loading.
 *
 * @eventType away3d.events.LoaderEvent
 */
//[Event(name="resourceComplete", type="away3d.events.LoaderEvent")]
/**
 * Dispatched when a single dependency (which may be the main file of a resource)
 * finishes loading.
 *
 * @eventType away3d.events.LoaderEvent
 */
//[Event(name="dependencyComplete", type="away3d.events.LoaderEvent")]
/**
 * Dispatched when an error occurs during loading. I
 *
 * @eventType away3d.events.LoaderEvent
 */
//[Event(name="loadError", type="away3d.events.LoaderEvent")]
/**
 * Dispatched when an error occurs during parsing.
 *
 * @eventType away3d.events.ParserEvent
 */
//[Event(name="parseError", type="away3d.events.ParserEvent")]
/**
 * Dispatched when a skybox asset has been costructed from a ressource.
 * 
 * @eventType away3d.events.AssetEvent
 */
//[Event(name="skyboxComplete", type="away3d.events.AssetEvent")]
/**
 * Dispatched when a camera3d asset has been costructed from a ressource.
 * 
 * @eventType away3d.events.AssetEvent
 */
//[Event(name="cameraComplete", type="away3d.events.AssetEvent")]
/**
 * Dispatched when a mesh asset has been costructed from a ressource.
 * 
 * @eventType away3d.events.AssetEvent
 */
//[Event(name="meshComplete", type="away3d.events.AssetEvent")]
/**
 * Dispatched when a geometry asset has been constructed from a resource.
 *
 * @eventType away3d.events.AssetEvent
 */
//[Event(name="geometryComplete", type="away3d.events.AssetEvent")]
/**
 * Dispatched when a skeleton asset has been constructed from a resource.
 *
 * @eventType away3d.events.AssetEvent
 */
//[Event(name="skeletonComplete", type="away3d.events.AssetEvent")]
/**
 * Dispatched when a skeleton pose asset has been constructed from a resource.
 *
 * @eventType away3d.events.AssetEvent
 */
//[Event(name="skeletonPoseComplete", type="away3d.events.AssetEvent")]
/**
 * Dispatched when a container asset has been constructed from a resource.
 *
 * @eventType away3d.events.AssetEvent
 */
//[Event(name="containerComplete", type="away3d.events.AssetEvent")]
/**
 * Dispatched when a texture asset has been constructed from a resource.
 *
 * @eventType away3d.events.AssetEvent
 */
//[Event(name="textureComplete", type="away3d.events.AssetEvent")]
/**
 * Dispatched when a texture projector asset has been constructed from a resource.
 *
 * @eventType away3d.events.AssetEvent
 */
//[Event(name="textureProjectorComplete", type="away3d.events.AssetEvent")]
/**
 * Dispatched when a material asset has been constructed from a resource.
 *
 * @eventType away3d.events.AssetEvent
 */
//[Event(name="materialComplete", type="away3d.events.AssetEvent")]
/**
 * Dispatched when a animator asset has been constructed from a resource.
 *
 * @eventType away3d.events.AssetEvent
 */
//[Event(name="animatorComplete", type="away3d.events.AssetEvent")]
/**
 * Dispatched when an animation set has been constructed from a group of animation state resources.
 *
 * @eventType away3d.events.AssetEvent
 */
//[Event(name="animationSetComplete", type="away3d.events.AssetEvent")]
/**
 * Dispatched when an animation state has been constructed from a group of animation node resources.
 *
 * @eventType away3d.events.AssetEvent
 */
//[Event(name="animationStateComplete", type="away3d.events.AssetEvent")]
/**
 * Dispatched when an animation node has been constructed from a resource.
 *
 * @eventType away3d.events.AssetEvent
 */
//[Event(name="animationNodeComplete", type="away3d.events.AssetEvent")]
/**
 * Dispatched when an animation state transition has been constructed from a group of animation node resources.
 *
 * @eventType away3d.events.AssetEvent
 */
//[Event(name="stateTransitionComplete", type="away3d.events.AssetEvent")]
/**
 * Dispatched when an light asset has been constructed from a resources.
 *
 * @eventType away3d.events.AssetEvent
 */
//[Event(name="lightComplete", type="away3d.events.AssetEvent")]
/**
 * Dispatched when an light picker asset has been constructed from a resources.
 *
 * @eventType away3d.events.AssetEvent
 */
//[Event(name="lightPickerComplete", type="away3d.events.AssetEvent")]
/**
 * Dispatched when an effect method asset has been constructed from a resources.
 *
 * @eventType away3d.events.AssetEvent
 */
//[Event(name="effectMethodComplete", type="away3d.events.AssetEvent")]
/**
 * Dispatched when an shadow map method asset has been constructed from a resources.
 *
 * @eventType away3d.events.AssetEvent
 */
//[Event(name="shadowMapMethodComplete", type="away3d.events.AssetEvent")]
/**
 * Instances of this class are returned as tokens by loading operations
 * to provide an object on which events can be listened for in cases where
 * the actual asset loader is not directly available (e.g. when using the
 * AssetLibrary to perform the load.)
 *
 * By listening for events on this class instead of directly on the
 * AssetLibrary, one can distinguish different loads from each other.
 *
 * The token will dispatch all events that the original AssetLoader dispatches,
 * while not providing an interface to obstruct the load and is as such a
 * safer return value for loader wrappers than the loader itself.
 */
package away3d.loaders.misc;


import away3d.loaders.AssetLoader;
import flash.events.EventDispatcher;

class AssetLoaderToken extends EventDispatcher {

    public var _loader:AssetLoader;

    public function new(loader:AssetLoader) {
        super();
        _loader = loader;
    }

    override public function addEventListener(type:String, listener:Dynamic -> Void, useCapture:Bool = false, priority:Int = 0, useWeakReference:Bool = false):Void {
        _loader.addEventListener(type, listener, useCapture, priority, useWeakReference);
    }

    override public function removeEventListener(type:String, listener:Dynamic -> Void, useCapture:Bool = false):Void {
        _loader.removeEventListener(type, listener, useCapture);
    }

    override public function hasEventListener(type:String):Bool {
        return _loader.hasEventListener(type);
    }

    override public function willTrigger(type:String):Bool {
        return _loader.willTrigger(type);
    }

}

