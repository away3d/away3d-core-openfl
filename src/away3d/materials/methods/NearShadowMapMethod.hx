// TODO: shadow mappers references in materials should be an interface so that this class should NOT extend ShadowMapMethodBase just for some delegation work
/**
 * NearShadowMapMethod provides a shadow map method that restricts the shadowed area near the camera to optimize
 * shadow map usage. This method needs to be used in conjunction with a NearDirectionalShadowMapper.
 *
 * @see away3d.lights.shadowmaps.NearDirectionalShadowMapper
 */
package away3d.materials.methods;


import away3d.materials.compilation.ShaderRegisterData;
import away3d.cameras.Camera3D;
import away3d.core.base.IRenderable;
import away3d.core.managers.Stage3DProxy;
import away3d.materials.compilation.ShaderRegisterCache;
import away3d.materials.compilation.ShaderRegisterElement;
import flash.Vector;
import away3d.events.ShadingMethodEvent;
import flash.errors.Error;
import away3d.lights.shadowmaps.NearDirectionalShadowMapper;
class NearShadowMapMethod extends SimpleShadowMapMethodBase {
    public var baseMethod(get_baseMethod, set_baseMethod):SimpleShadowMapMethodBase;
    public var fadeRatio(get_fadeRatio, set_fadeRatio):Float;

    private var _baseMethod:SimpleShadowMapMethodBase;
    private var _fadeRatio:Float;
    private var _nearShadowMapper:NearDirectionalShadowMapper;
/**
	 * Creates a new NearShadowMapMethod object.
	 * @param baseMethod The shadow map sampling method used to sample individual cascades (fe: HardShadowMapMethod, SoftShadowMapMethod)
	 * @param fadeRatio The amount of shadow fading to the outer shadow area. A value of 1 would mean the shadows start fading from the camera's near plane.
	 */

    public function new(baseMethod:SimpleShadowMapMethodBase, fadeRatio:Float = .1) {
        super(baseMethod.castingLight);
        _baseMethod = baseMethod;
        _fadeRatio = fadeRatio;
        _nearShadowMapper = cast(_castingLight.shadowMapper, NearDirectionalShadowMapper) ;
        if (_nearShadowMapper == null) throw new Error("NearShadowMapMethod requires a light that has a NearDirectionalShadowMapper instance assigned to shadowMapper.");
        _baseMethod.addEventListener(ShadingMethodEvent.SHADER_INVALIDATED, onShaderInvalidated);
    }

/**
	 * The base shadow map method on which this method's shading is based.
	 */

    public function get_baseMethod():SimpleShadowMapMethodBase {
        return _baseMethod;
    }

    public function set_baseMethod(value:SimpleShadowMapMethodBase):SimpleShadowMapMethodBase {
        if (_baseMethod == value) return value;
        _baseMethod.removeEventListener(ShadingMethodEvent.SHADER_INVALIDATED, onShaderInvalidated);
        _baseMethod = value;
        _baseMethod.addEventListener(ShadingMethodEvent.SHADER_INVALIDATED, onShaderInvalidated, false, 0, true);
        invalidateShaderProgram();
        return value;
    }

/**
	 * @inheritDoc
	 */

    override public function initConstants(vo:MethodVO):Void {
        super.initConstants(vo);
        _baseMethod.initConstants(vo);
        var fragmentData:Vector<Float> = vo.fragmentData;
        var index:Int = vo.secondaryFragmentConstantsIndex;
        fragmentData[index + 2] = 0;
        fragmentData[index + 3] = 1;
    }

/**
	 * @inheritDoc
	 */

    override public function initVO(vo:MethodVO):Void {
        _baseMethod.initVO(vo);
        vo.needsProjection = true;
    }

/**
	 * @inheritDoc
	 */

    override public function dispose():Void {
        _baseMethod.removeEventListener(ShadingMethodEvent.SHADER_INVALIDATED, onShaderInvalidated);
    }

/**
	 * @inheritDoc
	 */

    override public function get_alpha():Float {
        return _baseMethod.alpha;
    }

    override public function set_alpha(value:Float):Float {
        _baseMethod.alpha = value;
        return value;
    }

/**
	 * @inheritDoc
	 */

    override public function get_epsilon():Float {
        return _baseMethod.epsilon;
    }

    override public function set_epsilon(value:Float):Float {
        _baseMethod.epsilon = value;
        return value;
    }

/**
	 * The amount of shadow fading to the outer shadow area. A value of 1 would mean the shadows start fading from the camera's near plane.
	 */

    public function get_fadeRatio():Float {
        return _fadeRatio;
    }

    public function set_fadeRatio(value:Float):Float {
        _fadeRatio = value;
        return value;
    }

/**
	 * @inheritDoc
	 */

    override public function getFragmentCode(vo:MethodVO, regCache:ShaderRegisterCache, targetReg:ShaderRegisterElement):String {
        var code:String = _baseMethod.getFragmentCode(vo, regCache, targetReg);
        var dataReg:ShaderRegisterElement = regCache.getFreeFragmentConstant();
        var temp:ShaderRegisterElement = regCache.getFreeFragmentSingleTemp();
        vo.secondaryFragmentConstantsIndex = dataReg.index * 4;
        code += "abs " + temp + ", " + _sharedRegisters.projectionFragment + ".w\n" + "sub " + temp + ", " + temp + ", " + dataReg + ".x\n" + "mul " + temp + ", " + temp + ", " + dataReg + ".y\n" + "sat " + temp + ", " + temp + "\n" + "sub " + temp + ", " + dataReg + ".w," + temp + "\n" + "sub " + targetReg + ".w, " + dataReg + ".w," + targetReg + ".w\n" + "mul " + targetReg + ".w, " + targetReg + ".w, " + temp + "\n" + "sub " + targetReg + ".w, " + dataReg + ".w," + targetReg + ".w\n";
        return code;
    }

/**
	 * @inheritDoc
	 */

    override public function activate(vo:MethodVO, stage3DProxy:Stage3DProxy):Void {
        _baseMethod.activate(vo, stage3DProxy);
    }

/**
	 * @inheritDoc
	 */

    override public function deactivate(vo:MethodVO, stage3DProxy:Stage3DProxy):Void {
        _baseMethod.deactivate(vo, stage3DProxy);
    }

/**
	 * @inheritDoc
	 */

    override public function setRenderState(vo:MethodVO, renderable:IRenderable, stage3DProxy:Stage3DProxy, camera:Camera3D):Void {
// todo: move this to activate (needs camera)
        var near:Float = camera.lens.near;
        var d:Float = camera.lens.far - near;
        var maxDistance:Float = _nearShadowMapper.coverageRatio;
        var minDistance:Float = maxDistance * (1 - _fadeRatio);
        maxDistance = near + maxDistance * d;
        minDistance = near + minDistance * d;
        var fragmentData:Vector<Float> = vo.fragmentData;
        var index:Int = vo.secondaryFragmentConstantsIndex;
        fragmentData[index] = minDistance;
        fragmentData[index + 1] = 1 / (maxDistance - minDistance);
        _baseMethod.setRenderState(vo, renderable, stage3DProxy, camera);
    }

/**
	 * @inheritDoc
	 */

    override public function getVertexCode(vo:MethodVO, regCache:ShaderRegisterCache):String {
        return _baseMethod.getVertexCode(vo, regCache);
    }

/**
	 * @inheritDoc
	 */

    override public function reset():Void {
        _baseMethod.reset();
    }

/**
	 * @inheritDoc
	 */

    override public function cleanCompilationData():Void {
        super.cleanCompilationData();
        _baseMethod.cleanCompilationData();
    }

/**
	 * @inheritDoc
	 */

    override private function set_sharedRegisters(value:ShaderRegisterData):ShaderRegisterData {
        super.sharedRegisters = _baseMethod.sharedRegisters = value;
        return value;
    }

/**
	 * Called when the base method's shader code is invalidated.
	 */

    private function onShaderInvalidated(event:ShadingMethodEvent):Void {
        invalidateShaderProgram();
    }

}

