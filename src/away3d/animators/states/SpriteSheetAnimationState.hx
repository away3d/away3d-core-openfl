package away3d.animators.states;

import flash.Vector;
import away3d.animators.data.SpriteSheetAnimationFrame;
import away3d.animators.nodes.SpriteSheetClipNode;

class SpriteSheetAnimationState extends AnimationClipState implements ISpriteSheetAnimationState {
    public var reverse(never, set_reverse):Bool;
    public var backAndForth(never, set_backAndForth):Bool;
    public var currentFrameData(get_currentFrameData, never):SpriteSheetAnimationFrame;
    public var currentFrameNumber(get_currentFrameNumber, set_currentFrameNumber):Int;
    public var totalFrames(get_totalFrames, never):Int;

    private var _frames:Vector<SpriteSheetAnimationFrame>;
    private var _clipNode:SpriteSheetClipNode;
    private var _currentFrameID:Int;
    private var _reverse:Bool;
    private var _back:Bool;
    private var _backAndForth:Bool;
    private var _forcedFrame:Bool;

    function new(animator:IAnimator, clipNode:SpriteSheetClipNode) {
        _currentFrameID = 0;
        super(animator, clipNode);
        _clipNode = clipNode;
        _frames = _clipNode.frames;
    }

    public function set_reverse(b:Bool):Bool {
        _back = false;
        _reverse = b;
        return b;
    }

    public function set_backAndForth(b:Bool):Bool {
        if (b) _reverse = false;
        _back = false;
        _backAndForth = b;
        return b;
    }

/**
	 * @inheritDoc
	 */

    public function get_currentFrameData():SpriteSheetAnimationFrame {
        if (_framesDirty) updateFrames();
        return _frames[_currentFrameID];
    }

/**
	 * returns current frame index of the animation.
	 * The index is zero based and counts from first frame of the defined animation.
	 */

    public function get_currentFrameNumber():Int {
        return _currentFrameID;
    }

    public function set_currentFrameNumber(frameNumber:Int):Int {
        _currentFrameID = ((frameNumber > _frames.length - 1)) ? _frames.length - 1 : frameNumber;
        _forcedFrame = true;
        return frameNumber;
    }

/**
	 * returns the total frames for the current animation.
	 */

    private function get_totalFrames():Int {
        return ((_frames == null)) ? 0 : _frames.length;
    }

/**
	 * @inheritDoc
	 */

    override private function updateFrames():Void {
        if (_forcedFrame) {
            _forcedFrame = false;
            return;
        }
        super.updateFrames();
        if (_reverse) {
            if (_currentFrameID - 1 > -1) _currentFrameID--
            else {
                if (_clipNode.looping) {
                    if (_backAndForth) {
                        _reverse = false;
                        _currentFrameID++;
                    }

                    else _currentFrameID = _frames.length - 1;
                }
                cast((_animator), SpriteSheetAnimator).dispatchCycleEvent();
            }

        }

        else {
            if (_currentFrameID < _frames.length - 1) _currentFrameID++
            else {
                if (_clipNode.looping) {
                    if (_backAndForth) {
                        _reverse = true;
                        _currentFrameID--;
                    }

                    else _currentFrameID = 0;
                }
                cast((_animator), SpriteSheetAnimator).dispatchCycleEvent();
            }

        }

    }

}

