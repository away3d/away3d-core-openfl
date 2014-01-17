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
 * Dispatched when an image asset dimensions are not a power of 2
 *
 * @eventType away3d.events.AssetEvent
 */
//[Event(name="textureSizeError", type="away3d.events.AssetEvent")]
/**
 * Loader3D can load any file format that Away3D supports (or for which a third-party parser
 * has been plugged in) and be added directly to the scene. As assets are encountered
 * they are added to the Loader3D container. Assets that can not be displayed in the scene
 * graph (e.g. unused bitmaps/materials/skeletons etc) will be ignored.
 *
 * This provides a fast and easy way to load models (no need for event listeners) but is not
 * very versatile since many types of assets are ignored.
 *
 * Loader3D by default uses the AssetLibrary to load all assets, which means that they also
 * ends up in the library. To circumvent this, Loader3D can be configured to not use the
 * AssetLibrary in which case it will use the AssetLoader directly.
 *
 * @see away3d.loaders.AssetLoader
 * @see away3d.library.AssetLibrary
 */
package away3d.loaders;


import flash.events.Event;
import away3d.events.ParserEvent;
import away3d.entities.SegmentSet;
import away3d.cameras.Camera3D;
import away3d.entities.TextureProjector;
import away3d.primitives.SkyBox;
import away3d.entities.Mesh;
import away3d.lights.LightBase;
import away3d.library.assets.AssetType;
import flash.events.EventDispatcher;
import away3d.loaders.misc.SingleFileLoader;
import away3d.events.LoaderEvent;
import away3d.events.AssetEvent;
import flash.net.URLRequest;
import away3d.loaders.misc.AssetLoaderContext;
import away3d.loaders.parsers.ParserBase;
import away3d.loaders.misc.AssetLoaderToken;
import away3d.library.AssetLibraryBundle;
import flash.Vector;
import away3d.containers.ObjectContainer3D;
class Loader3D extends ObjectContainer3D {

    private var _loadingSessions:Vector<AssetLoader>;
    private var _useAssetLib:Bool;
    private var _assetLibId:String;

    public function new(useAssetLibrary:Bool = true, assetLibraryId:String = null) {
        super();
        _loadingSessions = new Vector<AssetLoader>();
        _useAssetLib = useAssetLibrary;
        _assetLibId = assetLibraryId;
    }

/**
	 * Loads a file and (optionally) all of its dependencies.
	 *
	 * @param req The URLRequest object containing the URL of the file to be loaded.
	 * @param context An optional context object providing additional parameters for loading
	 * @param ns An optional namespace string under which the file is to be loaded, allowing the differentiation of two resources with identical assets
	 * @param parser An optional parser object for translating the loaded data into a usable resource. If not provided, AssetLoader will attempt to auto-detect the file type.
	 */

    public function load(req:URLRequest, context:AssetLoaderContext = null, ns:String = null, parser:ParserBase = null):AssetLoaderToken {
        var token:AssetLoaderToken;
        if (_useAssetLib) {
            var lib:AssetLibraryBundle;
            lib = AssetLibraryBundle.getInstance(_assetLibId);
            token = lib.load(req, context, ns, parser);
        }

        else {
            var loader:AssetLoader = new AssetLoader();
            _loadingSessions.push(loader);
            token = loader.load(req, context, ns, parser);
        }

        token.addEventListener(LoaderEvent.RESOURCE_COMPLETE, onResourceComplete);
        token.addEventListener(AssetEvent.ASSET_COMPLETE, onAssetComplete);
        token.addEventListener(AssetEvent.ANIMATION_SET_COMPLETE, onAssetComplete);
        token.addEventListener(AssetEvent.ANIMATION_STATE_COMPLETE, onAssetComplete);
        token.addEventListener(AssetEvent.ANIMATION_NODE_COMPLETE, onAssetComplete);
        token.addEventListener(AssetEvent.STATE_TRANSITION_COMPLETE, onAssetComplete);
        token.addEventListener(AssetEvent.TEXTURE_COMPLETE, onAssetComplete);
        token.addEventListener(AssetEvent.CONTAINER_COMPLETE, onAssetComplete);
        token.addEventListener(AssetEvent.GEOMETRY_COMPLETE, onAssetComplete);
        token.addEventListener(AssetEvent.MATERIAL_COMPLETE, onAssetComplete);
        token.addEventListener(AssetEvent.MESH_COMPLETE, onAssetComplete);
        token.addEventListener(AssetEvent.ENTITY_COMPLETE, onAssetComplete);
        token.addEventListener(AssetEvent.SKELETON_COMPLETE, onAssetComplete);
        token.addEventListener(AssetEvent.SKELETON_POSE_COMPLETE, onAssetComplete);
// Error are handled separately (see documentation for addErrorHandler)
        token._loader.addErrorHandler(onLoadError);
        return token;
    }

/**
	 * Loads a resource from already loaded data.
	 *
	 * @param data The data object containing all resource information.
	 * @param context An optional context object providing additional parameters for loading
	 * @param ns An optional namespace string under which the file is to be loaded, allowing the differentiation of two resources with identical assets
	 * @param parser An optional parser object for translating the loaded data into a usable resource. If not provided, AssetLoader will attempt to auto-detect the file type.
	 */

    public function loadData(data:Dynamic, context:AssetLoaderContext = null, ns:String = null, parser:ParserBase = null):AssetLoaderToken {
        var token:AssetLoaderToken;
        if (_useAssetLib) {
            var lib:AssetLibraryBundle;
            lib = AssetLibraryBundle.getInstance(_assetLibId);
            token = lib.loadData(data, context, ns, parser);
        }

        else {
            var loader:AssetLoader = new AssetLoader();
            _loadingSessions.push(loader);
            token = loader.loadData(data, "", context, ns, parser);
        }

        token.addEventListener(LoaderEvent.RESOURCE_COMPLETE, onResourceComplete);
        token.addEventListener(AssetEvent.ASSET_COMPLETE, onAssetComplete);
        token.addEventListener(AssetEvent.ANIMATION_SET_COMPLETE, onAssetComplete);
        token.addEventListener(AssetEvent.ANIMATION_STATE_COMPLETE, onAssetComplete);
        token.addEventListener(AssetEvent.ANIMATION_NODE_COMPLETE, onAssetComplete);
        token.addEventListener(AssetEvent.STATE_TRANSITION_COMPLETE, onAssetComplete);
        token.addEventListener(AssetEvent.TEXTURE_COMPLETE, onAssetComplete);
        token.addEventListener(AssetEvent.CONTAINER_COMPLETE, onAssetComplete);
        token.addEventListener(AssetEvent.GEOMETRY_COMPLETE, onAssetComplete);
        token.addEventListener(AssetEvent.MATERIAL_COMPLETE, onAssetComplete);
        token.addEventListener(AssetEvent.MESH_COMPLETE, onAssetComplete);
        token.addEventListener(AssetEvent.ENTITY_COMPLETE, onAssetComplete);
        token.addEventListener(AssetEvent.SKELETON_COMPLETE, onAssetComplete);
        token.addEventListener(AssetEvent.SKELETON_POSE_COMPLETE, onAssetComplete);
// Error are handled separately (see documentation for addErrorHandler)
        token._loader.addErrorHandler(onLoadError);
        return token;
    }

/**
	 * Stop the current loading/parsing process.
	 */

    public function stopLoad():Void {
        if (_useAssetLib) {
            var lib:AssetLibraryBundle;
            lib = AssetLibraryBundle.getInstance(_assetLibId);
            lib.stopAllLoadingSessions();
            _loadingSessions = null;
            return;
        }
        var i:Int;
        var length:Int = _loadingSessions.length;
        i = 0;
        while (i < length) {
            removeListeners(_loadingSessions[i]);
            _loadingSessions[i].stop();
            _loadingSessions[i] = null;
            i++;
        }
        _loadingSessions = null;
    }

/**
	 * Enables a specific parser. 
	 * When no specific parser is set for a loading/parsing opperation, 
	 * loader3d can autoselect the correct parser to use.
	 * A parser must have been enabled, to be considered when autoselecting the parser.
	 *
	 * @param parserClass The parser class to enable.
	 * @see away3d.loaders.parsers.Parsers
	*/

    static public function enableParser(parserClass:Class<ParserBase>):Void {
        SingleFileLoader.enableParser(parserClass);
    }

/**
	 * Enables a list of parsers. 
	 * When no specific parser is set for a loading/parsing opperation, 
	 * loader3d can autoselect the correct parser to use.
	 * A parser must have been enabled, to be considered when autoselecting the parser.
	 *
	 * @param parserClasses A Vector of parser classes to enable.
	 * @see away3d.loaders.parsers.Parsers
	 */

    static public function enableParsers(parserClasses:Array<Class<ParserBase>>):Void {
        SingleFileLoader.enableParsers(parserClasses);
    }

    private function removeListeners(dispatcher:EventDispatcher):Void {
        dispatcher.removeEventListener(LoaderEvent.RESOURCE_COMPLETE, onResourceComplete);
        dispatcher.removeEventListener(LoaderEvent.LOAD_ERROR, onLoadError);
        dispatcher.removeEventListener(AssetEvent.ASSET_COMPLETE, onAssetComplete);
        dispatcher.removeEventListener(AssetEvent.ANIMATION_SET_COMPLETE, onAssetComplete);
        dispatcher.removeEventListener(AssetEvent.ANIMATION_STATE_COMPLETE, onAssetComplete);
        dispatcher.removeEventListener(AssetEvent.ANIMATION_NODE_COMPLETE, onAssetComplete);
        dispatcher.removeEventListener(AssetEvent.STATE_TRANSITION_COMPLETE, onAssetComplete);
        dispatcher.removeEventListener(AssetEvent.TEXTURE_COMPLETE, onAssetComplete);
        dispatcher.removeEventListener(AssetEvent.CONTAINER_COMPLETE, onAssetComplete);
        dispatcher.removeEventListener(AssetEvent.GEOMETRY_COMPLETE, onAssetComplete);
        dispatcher.removeEventListener(AssetEvent.MATERIAL_COMPLETE, onAssetComplete);
        dispatcher.removeEventListener(AssetEvent.MESH_COMPLETE, onAssetComplete);
        dispatcher.removeEventListener(AssetEvent.ENTITY_COMPLETE, onAssetComplete);
        dispatcher.removeEventListener(AssetEvent.SKELETON_COMPLETE, onAssetComplete);
        dispatcher.removeEventListener(AssetEvent.SKELETON_POSE_COMPLETE, onAssetComplete);
    }

    private function onAssetComplete(ev:AssetEvent):Void {
        if (ev.type == AssetEvent.ASSET_COMPLETE) {
// TODO: not used
// var type : String = ev.asset.assetType;
            var obj:ObjectContainer3D = null;
            var _sw0_ = (ev.asset.assetType);
            switch(_sw0_) {
                case AssetType.LIGHT:
                    obj = cast((ev.asset), LightBase);
                case AssetType.CONTAINER:
                    obj = cast((ev.asset), ObjectContainer3D);
                case AssetType.MESH:
                    obj = cast((ev.asset), Mesh);
                case AssetType.SKYBOX:
                    obj = cast((ev.asset), SkyBox);
                case AssetType.TEXTURE_PROJECTOR:
                    obj = cast((ev.asset), TextureProjector);
                case AssetType.CAMERA:
                    obj = cast((ev.asset), Camera3D);
                case AssetType.SEGMENT_SET:
                    obj = cast((ev.asset), SegmentSet);
            }
// If asset was of fitting type, and doesn't
// already have a parent, add to loader container
            if (obj != null && obj.parent == null) addChild(obj);
        }
        this.dispatchEvent(ev.clone());
    }

    private function onParseError(ev:ParserEvent):Bool {
        if (hasEventListener(ParserEvent.PARSE_ERROR)) {
            dispatchEvent(ev);
            return true;
        }

        else return false;
    }

    private function onLoadError(ev:LoaderEvent):Bool {
        if (hasEventListener(LoaderEvent.LOAD_ERROR)) {
            dispatchEvent(ev);
            return true;
        }

        else return false;
    }

    private function onResourceComplete(ev:Event):Void {
        removeListeners(cast((ev.currentTarget), EventDispatcher));
        this.dispatchEvent(ev.clone());
    }

}

