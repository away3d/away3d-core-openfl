package away3d.filters;

import away3d.cameras.Camera3D;
import away3d.containers.ObjectContainer3D;
import away3d.core.managers.Stage3DProxy;
import away3d.filters.tasks.Filter3DHDepthOfFFieldTask;
import away3d.filters.tasks.Filter3DVDepthOfFFieldTask;
import flash.display3D.textures.Texture;
import flash.geom.Vector3D;

class DepthOfFieldFilter3D extends Filter3DBase {
    public var stepSize(get_stepSize, set_stepSize):Int;
    public var focusTarget(get_focusTarget, set_focusTarget):ObjectContainer3D;
    public var focusDistance(get_focusDistance, set_focusDistance):Float;
    public var range(get_range, set_range):Float;
    public var maxBlurX(get_maxBlurX, set_maxBlurX):Int;
    public var maxBlurY(get_maxBlurY, set_maxBlurY):Int;

    private var _focusTarget:ObjectContainer3D;
    private var _hDofTask:Filter3DHDepthOfFFieldTask;
    private var _vDofTask:Filter3DVDepthOfFFieldTask;
/**
	 * Creates a new DepthOfFieldFilter3D object.
	 * @param blurX The maximum amount of horizontal blur to apply
	 * @param blurY The maximum amount of vertical blur to apply
	 * @param stepSize The distance between samples. Set to -1 to auto-detect with acceptable quality.
	 */

    public function new(maxBlurX:Int = 3, maxBlurY:Int = 3, stepSize:Int = -1) {
        super();
        _hDofTask = new Filter3DHDepthOfFFieldTask(maxBlurX, stepSize);
        _vDofTask = new Filter3DVDepthOfFFieldTask(maxBlurY, stepSize);
        addTask(_hDofTask);
        addTask(_vDofTask);
    }

/**
	 * The amount of pixels between each sample.
	 */

    public function get_stepSize():Int {
        return _hDofTask.stepSize;
    }

    public function set_stepSize(value:Int):Int {
        _vDofTask.stepSize = _hDofTask.stepSize = value;
        return value;
    }

/**
	 * An optional target ObjectContainer3D that will be used to auto-focus on.
	 */

    public function get_focusTarget():ObjectContainer3D {
        return _focusTarget;
    }

    public function set_focusTarget(value:ObjectContainer3D):ObjectContainer3D {
        _focusTarget = value;
        return value;
    }

/**
	 * The distance from the camera to the point that is in focus.
	 */

    public function get_focusDistance():Float {
        return _hDofTask.focusDistance;
    }

    public function set_focusDistance(value:Float):Float {
        _hDofTask.focusDistance = _vDofTask.focusDistance = value;
        return value;
    }

/**
	 * The distance between the focus point and the maximum amount of blur.
	 */

    public function get_range():Float {
        return _hDofTask.range;
    }

    public function set_range(value:Float):Float {
        _vDofTask.range = _hDofTask.range = value;
        return value;
    }

/**
	 * The maximum amount of horizontal blur.
	 */

    public function get_maxBlurX():Int {
        return _hDofTask.maxBlur;
    }

    public function set_maxBlurX(value:Int):Int {
        _hDofTask.maxBlur = value;
        return value;
    }

/**
	 * The maximum amount of vertical blur.
	 */

    public function get_maxBlurY():Int {
        return _vDofTask.maxBlur;
    }

    public function set_maxBlurY(value:Int):Int {
        _vDofTask.maxBlur = value;
        return value;
    }

    override public function update(stage:Stage3DProxy, camera:Camera3D):Void {
        if (_focusTarget != null) updateFocus(camera);
    }

    private function updateFocus(camera:Camera3D):Void {
        var target:Vector3D = camera.inverseSceneTransform.transformVector(_focusTarget.scenePosition);
        _hDofTask.focusDistance = _vDofTask.focusDistance = target.z;
    }

    override public function setRenderTargets(mainTarget:Texture, stage3DProxy:Stage3DProxy):Void {
        super.setRenderTargets(mainTarget, stage3DProxy);
        _hDofTask.target = _vDofTask.getMainInputTexture(stage3DProxy);
    }

}

