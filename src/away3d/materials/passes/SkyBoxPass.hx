/**
 * SkyBoxPass provides a material pass exclusively used to render sky boxes from a cube texture.
 */
package away3d.materials.passes;


import flash.Vector;
import flash.Vector;
import away3d.cameras.Camera3D;
import away3d.core.base.IRenderable;
import away3d.core.managers.Stage3DProxy;
import away3d.textures.CubeTextureBase;
import flash.display3D.Context3D;
import flash.display3D.Context3DCompareMode;
import flash.display3D.Context3DProgramType;
import flash.display3D.Context3DTextureFormat;
import flash.geom.Matrix3D;
import flash.geom.Vector3D;

class SkyBoxPass extends MaterialPassBase {
    public var cubeTexture(get_cubeTexture, set_cubeTexture):CubeTextureBase;

    private var _cubeTexture:CubeTextureBase;
    private var _vertexData:Vector<Float>;
/**
	 * Creates a new SkyBoxPass object.
	 */

    public function new() {
        super();
        mipmap = false;
        _numUsedTextures = 1;
        var tmp:Array<Float >= [0, 0, 0, 0, 1, 1, 1, 1];
        _vertexData = Vector.ofArray(tmp);
    }

/**
	 * The cube texture to use as the skybox.
	 */

    public function get_cubeTexture():CubeTextureBase {
        return _cubeTexture;
    }

    public function set_cubeTexture(value:CubeTextureBase):CubeTextureBase {
        _cubeTexture = value;
        return value;
    }

/**
	 * @inheritDoc
	 */

    override public function getVertexCode():String {
        return "mul vt0, va0, vc5		\n" + "add vt0, vt0, vc4		\n" + "m44 op, vt0, vc0		\n" + "mov v0, va0\n";
    }

/**
	 * @inheritDoc
	 */

    override public function getFragmentCode(animationCode:String):String {
        var format:String;
        var _sw2_ = (_cubeTexture.format);
        switch(_sw2_) {
            case Context3DTextureFormat.COMPRESSED:
                format = "dxt1,";
            case Context3DTextureFormat.COMPRESSED_ALPHA:
                format = "dxt5,";
            default:
                format = "";
        }
        var mip:String = ",mipnone";
        if (_cubeTexture.hasMipMaps) mip = ",miplinear";
        return "tex ft0, v0, fs0 <cube," + format + "linear,clamp" + mip + ">	\n" + "mov oc, ft0							\n";
    }

/**
	 * @inheritDoc
	 */

    override public function render(renderable:IRenderable, stage3DProxy:Stage3DProxy, camera:Camera3D, viewProjection:Matrix3D):Void {
        var context:Context3D = stage3DProxy._context3D;
        var pos:Vector3D = camera.scenePosition;
        _vertexData[0] = pos.x;
        _vertexData[1] = pos.y;
        _vertexData[2] = pos.z;
        _vertexData[4] = _vertexData[5] = _vertexData[6] = camera.lens.far / Math.sqrt(3);
        context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, viewProjection, true);
        context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 4, _vertexData, 2);
        renderable.activateVertexBuffer(0, stage3DProxy);
        context.drawTriangles(renderable.getIndexBuffer(stage3DProxy), 0, renderable.numTriangles);
    }

/**
	 * @inheritDoc
	 */

    override public function activate(stage3DProxy:Stage3DProxy, camera:Camera3D):Void {
        super.activate(stage3DProxy, camera);
        var context:Context3D = stage3DProxy._context3D;
        context.setDepthTest(false, Context3DCompareMode.LESS);
        context.setTextureAt(0, _cubeTexture.getTextureForStage3D(stage3DProxy));
    }

}

