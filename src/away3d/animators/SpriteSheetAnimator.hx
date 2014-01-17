/**
 * Provides an interface for assigning uv-based sprite sheet animation data sets to mesh-based entity objects
 * and controlling the various available states of animation through an interative playhead that can be
 * automatically updated or manually triggered.
 */
package away3d.animators;

import haxe.Timer;
import flash.Lib;
import away3d.materials.passes.MaterialPassBase;
import flash.errors.Error;
import away3d.materials.SpriteSheetMaterial;
import away3d.core.managers.Stage3DProxy;
import away3d.core.base.IRenderable;
import away3d.materials.MaterialBase;
import away3d.materials.TextureMaterial;
import away3d.core.base.SubMesh;
import away3d.animators.data.SpriteSheetAnimationFrame;
import flash.Vector;

import away3d.animators.states.ISpriteSheetAnimationState;
import away3d.animators.states.SpriteSheetAnimationState;
import away3d.animators.transitions.IAnimationTransition;

import away3d.cameras.Camera3D;
import flash.display3D.Context3DProgramType;
class SpriteSheetAnimator extends AnimatorBase implements IAnimator {
    public var fps(get_fps, set_fps):Int;
    public var reverse(get_reverse, set_reverse):Bool;
    public var backAndForth(get_backAndForth, set_backAndForth):Bool;
    public var currentFrameNumber(get_currentFrameNumber, never):Int;
    public var totalFrames(get_totalFrames, never):Int;

    private var _activeSpriteSheetState:ISpriteSheetAnimationState;
    private var _spriteSheetAnimationSet:SpriteSheetAnimationSet;
    private var _frame:SpriteSheetAnimationFrame;
    private var _vectorFrame:Vector<Float>;
    private var _fps:Int;
    private var _ms:Int;
    private var _lastTime:Int;
    private var _reverse:Bool;
    private var _backAndForth:Bool;
    private var _specsDirty:Bool;
    private var _mapDirty:Bool;
/**
	 * Creates a new <code>SpriteSheetAnimator</code> object.
	 * @param spriteSheetAnimationSet  The animation data set containing the sprite sheet animation states used by the animator.
	 */

    public function new(spriteSheetAnimationSet:SpriteSheetAnimationSet) {
        _frame = new SpriteSheetAnimationFrame();
        _fps = 10;
        _ms = 100;
        super(spriteSheetAnimationSet);
        _spriteSheetAnimationSet = spriteSheetAnimationSet;
        _vectorFrame = new Vector<Float>();
    }

/* Set the playrate of the animation in frames per second (not depending on player fps)*/

    public function set_fps(val:Int):Int {
        _ms = Std.int(1000 / val);
        _fps = val;
        return val;
    }

    public function get_fps():Int {
        return _fps;
    }

/* If true, reverse causes the animation to play backwards*/

    public function set_reverse(b:Bool):Bool {
        _reverse = b;
        _specsDirty = true;
        return b;
    }

    public function get_reverse():Bool {
        return _reverse;
    }

/* If true, backAndForth causes the animation to play backwards and forward alternatively. Starting forward.*/

    public function set_backAndForth(b:Bool):Bool {
        _backAndForth = b;
        _specsDirty = true;
        return b;
    }

    public function get_backAndForth():Bool {
        return _backAndForth;
    }

/* sets the animation pointer to a given frame and plays from there. Equivalent to ActionScript, the first frame is at 1, not 0.*/

    public function gotoAndPlay(frameNumber:Int):Void {
        gotoFrame(frameNumber, true);
    }

/* sets the animation pointer to a given frame and stops there. Equivalent to ActionScript, the first frame is at 1, not 0.*/

    public function gotoAndStop(frameNumber:Int):Void {
        gotoFrame(frameNumber, false);
    }

/* returns the current frame*/

    public function get_currentFrameNumber():Int {
        return cast((_activeState), SpriteSheetAnimationState).currentFrameNumber;
    }

/* returns the total amount of frame for the current animation*/

    public function get_totalFrames():Int {
        return cast((_activeState), SpriteSheetAnimationState).totalFrames;
    }

/**
	 * @inheritDoc
	 */

    public function setRenderState(stage3DProxy:Stage3DProxy, renderable:IRenderable, vertexConstantOffset:Int, vertexStreamOffset:Int, camera:Camera3D):Void {
        var material:MaterialBase = renderable.material;
        if (material == null || !Std.is(material, TextureMaterial)) return;
        var subMesh:SubMesh = cast(renderable, SubMesh) ;
        if (subMesh == null) return;
        var swapped:Bool = false;
        if (Std.is(material, SpriteSheetMaterial) && _mapDirty) swapped = cast((material), SpriteSheetMaterial).swap(_frame.mapID);
        if (!swapped) {
            _vectorFrame[0] = _frame.offsetU;
            _vectorFrame[1] = _frame.offsetV;
            _vectorFrame[2] = _frame.scaleU;
            _vectorFrame[3] = _frame.scaleV;
        }
        stage3DProxy._context3D.setProgramConstantsFromVector(Context3DProgramType.VERTEX, vertexConstantOffset, _vectorFrame);
    }

/**
	 * @inheritDoc
	 */

    public function play(name:String, transition:IAnimationTransition = null, ?offset:Float = null):Void {

        if (_activeAnimationName == name) return;
        _activeAnimationName = name;
        if (!_animationSet.hasAnimation(name)) throw new Error("Animation root node " + name + " not found!");
        _activeNode = _animationSet.getAnimation(name);
        _activeState = getAnimationState(_activeNode);
        _frame = cast((_activeState), SpriteSheetAnimationState).currentFrameData;
        _activeSpriteSheetState = cast(_activeState, ISpriteSheetAnimationState) ;
        start();
    }

/**
	 * Applies the calculated time delta to the active animation state node.
	 */

    override private function updateDeltaTime(dt:Int):Void {
        if (_specsDirty) {
            cast((_activeSpriteSheetState), SpriteSheetAnimationState).reverse = _reverse;
            cast((_activeSpriteSheetState), SpriteSheetAnimationState).backAndForth = _backAndForth;
            _specsDirty = false;
        }
        _absoluteTime += dt;
        var now:Int = Lib.getTimer();
        if ((now - _lastTime) > _ms) {
            _mapDirty = true;
            _activeSpriteSheetState.update(_absoluteTime);
            _frame = cast((_activeSpriteSheetState), SpriteSheetAnimationState).currentFrameData;
            _lastTime = now;
        }

        else _mapDirty = false;
    }

    public function testGPUCompatibility(pass:MaterialPassBase):Void {
    }

    public function clone():IAnimator {
        return new SpriteSheetAnimator(_spriteSheetAnimationSet);
    }

    private function gotoFrame(frameNumber:Int, doPlay:Bool):Void {
        if (_activeState == null) return;
        cast((_activeState), SpriteSheetAnimationState).currentFrameNumber = ((frameNumber == 0)) ? frameNumber : frameNumber - 1;
        var currentMapID:Int = _frame.mapID;
        _frame = cast((_activeSpriteSheetState), SpriteSheetAnimationState).currentFrameData;
        if (doPlay) start()
        else {
            if (currentMapID != _frame.mapID) {
                _mapDirty = true;

                Timer.delay(stop, _fps);
            }

            else stop();
        }

    }

}

