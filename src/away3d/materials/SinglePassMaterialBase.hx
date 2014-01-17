/**
 * SinglePassMaterialBase forms an abstract base class for the default single-pass materials provided by Away3D,
 * using material methods to define their appearance.
 */
package away3d.materials;


import flash.errors.Error;
import flash.display3D.Context3DCompareMode;
import away3d.cameras.Camera3D;
import away3d.core.managers.Stage3DProxy;
import away3d.materials.lightpickers.LightPickerBase;
import away3d.materials.methods.BasicAmbientMethod;
import away3d.materials.methods.BasicDiffuseMethod;
import away3d.materials.methods.BasicNormalMethod;
import away3d.materials.methods.BasicSpecularMethod;
import away3d.materials.methods.EffectMethodBase;
import away3d.materials.methods.ShadowMapMethodBase;
import away3d.materials.passes.SuperShaderPass;
import away3d.textures.Texture2DBase;
import flash.display.BlendMode;
import flash.display3D.Context3D;
import flash.geom.ColorTransform;

class SinglePassMaterialBase extends MaterialBase {
    public var enableLightFallOff(get_enableLightFallOff, set_enableLightFallOff):Bool;
    public var alphaThreshold(get_alphaThreshold, set_alphaThreshold):Float;
    public var specularLightSources(get_specularLightSources, set_specularLightSources):Int;
    public var diffuseLightSources(get_diffuseLightSources, set_diffuseLightSources):Int;
    public var colorTransform(get_colorTransform, set_colorTransform):ColorTransform;
    public var ambientMethod(get_ambientMethod, set_ambientMethod):BasicAmbientMethod;
    public var shadowMethod(get_shadowMethod, set_shadowMethod):ShadowMapMethodBase;
    public var diffuseMethod(get_diffuseMethod, set_diffuseMethod):BasicDiffuseMethod;
    public var normalMethod(get_normalMethod, set_normalMethod):BasicNormalMethod;
    public var specularMethod(get_specularMethod, set_specularMethod):BasicSpecularMethod;
    public var numMethods(get_numMethods, never):Int;
    public var normalMap(get_normalMap, set_normalMap):Texture2DBase;
    public var specularMap(get_specularMap, set_specularMap):Texture2DBase;
    public var gloss(get_gloss, set_gloss):Float;
    public var ambient(get_ambient, set_ambient):Float;
    public var specular(get_specular, set_specular):Float;
    public var ambientColor(get_ambientColor, set_ambientColor):Int;
    public var specularColor(get_specularColor, set_specularColor):Int;
    public var alphaBlending(get_alphaBlending, set_alphaBlending):Bool;

    private var _screenPass:SuperShaderPass;
    private var _alphaBlending:Bool;
/**
	 * Creates a new SinglePassMaterialBase object.
	 */

    public function new() {
        super();
        addPass(_screenPass = new SuperShaderPass(this));
    }

/**
	 * Whether or not to use fallOff and radius properties for lights. This can be used to improve performance and
	 * compatibility for constrained mode.
	 */

    public function get_enableLightFallOff():Bool {
        return _screenPass.enableLightFallOff;
    }

    public function set_enableLightFallOff(value:Bool):Bool {
        _screenPass.enableLightFallOff = value;
        return value;
    }

/**
	 * The minimum alpha value for which pixels should be drawn. This is used for transparency that is either
	 * invisible or entirely opaque, often used with textures for foliage, etc.
	 * Recommended values are 0 to disable alpha, or 0.5 to create smooth edges. Default value is 0 (disabled).
	 */

    public function get_alphaThreshold():Float {
        return _screenPass.diffuseMethod.alphaThreshold;
    }

    public function set_alphaThreshold(value:Float):Float {
        _screenPass.diffuseMethod.alphaThreshold = value;
        _depthPass.alphaThreshold = value;
        _distancePass.alphaThreshold = value;
        return value;
    }

/**
	 * @inheritDoc
	 */

    override public function set_blendMode(value:BlendMode):BlendMode {
        super.blendMode = value;
        _screenPass.setBlendMode(blendMode == BlendMode.NORMAL && (requiresBlending) ? BlendMode.LAYER : blendMode);
        return value;
    }

/**
	 * @inheritDoc
	 */

    override public function set_depthCompareMode(value:Context3DCompareMode):Context3DCompareMode {
        super.depthCompareMode = value;
        _screenPass.depthCompareMode = value;
        return value;
    }

/**
	 * @inheritDoc
	 */

    override public function activateForDepth(stage3DProxy:Stage3DProxy, camera:Camera3D, distanceBased:Bool = false):Void {
        if (distanceBased) _distancePass.alphaMask = _screenPass.diffuseMethod.texture
        else _depthPass.alphaMask = _screenPass.diffuseMethod.texture;
        super.activateForDepth(stage3DProxy, camera, distanceBased);
    }

/**
	 * Define which light source types to use for specular reflections. This allows choosing between regular lights
	 * and/or light probes for specular reflections.
	 *
	 * @see away3d.materials.LightSources
	 */

    public function get_specularLightSources():Int {
        return _screenPass.specularLightSources;
    }

    public function set_specularLightSources(value:Int):Int {
        _screenPass.specularLightSources = value;
        return value;
    }

/**
	 * Define which light source types to use for diffuse reflections. This allows choosing between regular lights
	 * and/or light probes for diffuse reflections.
	 *
	 * @see away3d.materials.LightSources
	 */

    public function get_diffuseLightSources():Int {
        return _screenPass.diffuseLightSources;
    }

    public function set_diffuseLightSources(value:Int):Int {
        _screenPass.diffuseLightSources = value;
        return value;
    }

/**
	 * @inheritDoc
	 */

    override public function get_requiresBlending():Bool {
        return super.requiresBlending || _alphaBlending || (_screenPass.colorTransform != null && _screenPass.colorTransform.alphaMultiplier < 1);
    }

/**
	 * The ColorTransform object to transform the colour of the material with. Defaults to null.
	 */

    public function get_colorTransform():ColorTransform {
        return _screenPass.colorTransform;
    }

    public function set_colorTransform(value:ColorTransform):ColorTransform {
        _screenPass.colorTransform = value;
        return value;
    }

/**
	 * The method that provides the ambient lighting contribution. Defaults to BasicAmbientMethod.
	 */

    public function get_ambientMethod():BasicAmbientMethod {
        return _screenPass.ambientMethod;
    }

    public function set_ambientMethod(value:BasicAmbientMethod):BasicAmbientMethod {
        _screenPass.ambientMethod = value;
        return value;
    }

/**
	 * The method used to render shadows cast on this surface, or null if no shadows are to be rendered. Defaults to null.
	 */

    public function get_shadowMethod():ShadowMapMethodBase {
        return _screenPass.shadowMethod;
    }

    public function set_shadowMethod(value:ShadowMapMethodBase):ShadowMapMethodBase {
        _screenPass.shadowMethod = value;
        return value;
    }

/**
	 * The method that provides the diffuse lighting contribution. Defaults to BasicDiffuseMethod.
	 */

    public function get_diffuseMethod():BasicDiffuseMethod {
        return _screenPass.diffuseMethod;
    }

    public function set_diffuseMethod(value:BasicDiffuseMethod):BasicDiffuseMethod {
        _screenPass.diffuseMethod = value;
        return value;
    }

/**
	 * The method used to generate the per-pixel normals. Defaults to BasicNormalMethod.
	 */

    public function get_normalMethod():BasicNormalMethod {
        return _screenPass.normalMethod;
    }

    public function set_normalMethod(value:BasicNormalMethod):BasicNormalMethod {
        _screenPass.normalMethod = value;
        return value;
    }

/**
	 * The method that provides the specular lighting contribution. Defaults to BasicSpecularMethod.
	 */

    public function get_specularMethod():BasicSpecularMethod {
        return _screenPass.specularMethod;
    }

    public function set_specularMethod(value:BasicSpecularMethod):BasicSpecularMethod {
        _screenPass.specularMethod = value;
        return value;
    }

/**
	 * Appends an "effect" shading method to the shader. Effect methods are those that do not influence the lighting
	 * but modulate the shaded colour, used for fog, outlines, etc. The method will be applied to the result of the
	 * methods added prior.
	 */

    public function addMethod(method:EffectMethodBase):Void {
        _screenPass.addMethod(method);
    }

/**
	 * The number of "effect" methods added to the material.
	 */

    public function get_numMethods():Int {
        return _screenPass.numMethods;
    }

/**
	 * Queries whether a given effect method was added to the material.
	 *
	 * @param method The method to be queried.
	 * @return true if the method was added to the material, false otherwise.
	 */

    public function hasMethod(method:EffectMethodBase):Bool {
        return _screenPass.hasMethod(method);
    }

/**
	 * Returns the method added at the given index.
	 * @param index The index of the method to retrieve.
	 * @return The method at the given index.
	 */

    public function getMethodAt(index:Int):EffectMethodBase {
        return _screenPass.getMethodAt(index);
    }

/**
	 * Adds an effect method at the specified index amongst the methods already added to the material. Effect
	 * methods are those that do not influence the lighting but modulate the shaded colour, used for fog, outlines,
	 * etc. The method will be applied to the result of the methods with a lower index.
	 */

    public function addMethodAt(method:EffectMethodBase, index:Int):Void {
        _screenPass.addMethodAt(method, index);
    }

/**
	 * Removes an effect method from the material.
	 * @param method The method to be removed.
	 */

    public function removeMethod(method:EffectMethodBase):Void {
        _screenPass.removeMethod(method);
    }

/**
	 * @inheritDoc
	 */

    override public function set_mipmap(value:Bool):Bool {
        if (_mipmap == value) return value;
        super.mipmap = value;
        return value;
    }

/**
	 * The normal map to modulate the direction of the surface for each texel. The default normal method expects
	 * tangent-space normal maps, but others could expect object-space maps.
	 */

    public function get_normalMap():Texture2DBase {
        return _screenPass.normalMap;
    }

    public function set_normalMap(value:Texture2DBase):Texture2DBase {
        _screenPass.normalMap = value;
        return value;
    }

/**
	 * A specular map that defines the strength of specular reflections for each texel in the red channel,
	 * and the gloss factor in the green channel. You can use SpecularBitmapTexture if you want to easily set
	 * specular and gloss maps from grayscale images, but correctly authored images are preferred.
	 */

    public function get_specularMap():Texture2DBase {
        return _screenPass.specularMethod.texture;
    }

    public function set_specularMap(value:Texture2DBase):Texture2DBase {
        if (_screenPass.specularMethod != null) _screenPass.specularMethod.texture = value
        else throw new Error("No specular method was set to assign the specularGlossMap to");
        return value;
    }

/**
	 * The glossiness of the material (sharpness of the specular highlight).
	 */

    public function get_gloss():Float {
        return (_screenPass.specularMethod != null ) ? _screenPass.specularMethod.gloss : 0;
    }

    public function set_gloss(value:Float):Float {
        if (_screenPass.specularMethod != null) _screenPass.specularMethod.gloss = value;
        return value;
    }

/**
	 * The strength of the ambient reflection.
	 */

    public function get_ambient():Float {
        return _screenPass.ambientMethod.ambient;
    }

    public function set_ambient(value:Float):Float {
        _screenPass.ambientMethod.ambient = value;
        return value;
    }

/**
	 * The overall strength of the specular reflection.
	 */

    public function get_specular():Float {
        return (_screenPass.specularMethod != null ) ? _screenPass.specularMethod.specular : 0;
    }

    public function set_specular(value:Float):Float {
        if (_screenPass.specularMethod != null) _screenPass.specularMethod.specular = value;
        return value;
    }

/**
	 * The colour of the ambient reflection.
	 */

    public function get_ambientColor():Int {
        return _screenPass.ambientMethod.ambientColor;
    }

    public function set_ambientColor(value:Int):Int {
        _screenPass.ambientMethod.ambientColor = value;
        return value;
    }

/**
	 * The colour of the specular reflection.
	 */

    public function get_specularColor():Int {
        return _screenPass.specularMethod.specularColor;
    }

    public function set_specularColor(value:Int):Int {
        _screenPass.specularMethod.specularColor = value;
        return value;
    }

/**
	 * Indicates whether or not the material has transparency. If binary transparency is sufficient, for
	 * example when using textures of foliage, consider using alphaThreshold instead.
	 */

    public function get_alphaBlending():Bool {
        return _alphaBlending;
    }

    public function set_alphaBlending(value:Bool):Bool {
        _alphaBlending = value;
        _screenPass.setBlendMode(blendMode == BlendMode.NORMAL && (requiresBlending) ? BlendMode.LAYER : blendMode);
        _screenPass.preserveAlpha = requiresBlending;
        return value;
    }

/**
	 * @inheritDoc
	 */

    override public function updateMaterial(context:Context3D):Void {
        if (_screenPass._passesDirty) {
            clearPasses();
            if (_screenPass._passes != null) {
                var len:Int = _screenPass._passes.length;
                var i:Int = 0;
                while (i < len) {
                    addPass(_screenPass._passes[i]);
                    ++i;
                }
            }
            addPass(_screenPass);
            _screenPass._passesDirty = false;
        }
    }

/**
	 * @inheritDoc
	 */

    override public function set_lightPicker(value:LightPickerBase):LightPickerBase {
        super.lightPicker = value;
        _screenPass.lightPicker = value;
        return value;
    }

}

