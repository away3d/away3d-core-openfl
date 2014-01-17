/**
 * Picks a 3d object from a view or scene by performing a separate render pass on the scene around the area being picked using key color values,
 * then reading back the color value of the pixel in the render representing the picking ray. Requires multiple passes and readbacks for retriving details
 * on an entity that has its shaderPickingDetails property set to true.
 *
 * A read-back operation from any GPU is not a very efficient process, and the amount of processing used can vary significantly between different hardware.
 *
 * @see away3d.entities.Entity#shaderPickingDetails
 */
package away3d.core.pick;


import away3d.tools.utils.GeomUtil;
import away3d.core.base.ISubGeometry;
import away3d.core.base.SubMesh;
import flash.display3D.Context3DClearMask;
import flash.display3D.shaders.AGLSLShaderUtils;
import flash.display3D.Context3DTriangleFace;
import away3d.core.data.RenderableListItem;
import flash.geom.Matrix3D;
import away3d.core.math.Matrix3DUtils;
import flash.display3D.Context3DProgramType;
import flash.display3D.Context3DCompareMode;
import away3d.containers.Scene3D;
import flash.display3D.textures.TextureBase;
import away3d.cameras.Camera3D;
import flash.display3D.Context3DBlendFactor;
import away3d.core.traverse.EntityCollector;
import away3d.containers.View3D;
import away3d.entities.Entity;
import flash.geom.Point;
import flash.geom.Vector3D;
import flash.geom.Rectangle;
import away3d.core.base.IRenderable;
import flash.Vector;
import away3d.core.managers.Stage3DProxy;
import flash.display3D.Context3D;
import flash.display3D.Program3D;
import flash.display.BitmapData;
#if (cpp || neko || js)
using away3d.Stage3DUtils;
#end
class ShaderPicker implements IPicker {
    public var onlyMouseEnabled(get_onlyMouseEnabled, set_onlyMouseEnabled):Bool;

    private var _stage3DProxy:Stage3DProxy;
    private var _context:Context3D;
    private var _onlyMouseEnabled:Bool;
    private var _objectProgram3D:Program3D;
    private var _triangleProgram3D:Program3D;
    private var _bitmapData:BitmapData;
    private var _viewportData:Vector<Float>;
    private var _boundOffsetScale:Vector<Float>;
    private var _id:Vector<Float>;
    private var _interactives:Vector<IRenderable>;
    private var _interactiveId:Int;
    private var _hitColor:Int;
    private var _projX:Float;
    private var _projY:Float;
    private var _hitRenderable:IRenderable;
    private var _hitEntity:Entity;
    private var _localHitPosition:Vector3D;
    private var _hitUV:Point;
    private var _faceIndex:Int;
    private var _subGeometryIndex:Int;
    private var _localHitNormal:Vector3D;
    private var _rayPos:Vector3D;
    private var _rayDir:Vector3D;
    private var _potentialFound:Bool;
    static private var MOUSE_SCISSOR_RECT:Rectangle = new Rectangle(0, 0, 1, 1);
/**
	 * @inheritDoc
	 */

    public function get_onlyMouseEnabled():Bool {
        return _onlyMouseEnabled;
    }

    public function set_onlyMouseEnabled(value:Bool):Bool {
        _onlyMouseEnabled = value;
        return value;
    }

/**
	 * Creates a new <code>ShaderPicker</code> object.
	 */

    public function new() {
        _onlyMouseEnabled = true;
        _interactives = new Vector<IRenderable>();
        _localHitPosition = new Vector3D();
        _hitUV = new Point();
        _localHitNormal = new Vector3D();
        _rayPos = new Vector3D();
        _rayDir = new Vector3D();
        _id = new Vector<Float>(4, true);
        _viewportData = new Vector<Float>(4, true);
// first 2 contain scale, last 2 translation
        _boundOffsetScale = new Vector<Float>(8, true);
// first 2 contain scale, last 2 translation
        _boundOffsetScale[3] = 0;
        _boundOffsetScale[7] = 1;
    }

/**
	 * @inheritDoc
	 */

    public function getViewCollision(x:Float, y:Float, view:View3D):PickingCollisionVO {
        var collector:EntityCollector = view.entityCollector;
        _stage3DProxy = view.stage3DProxy;
        if (_stage3DProxy == null) return null;
        _context = _stage3DProxy._context3D;
        _viewportData[0] = view.width;
        _viewportData[1] = view.height;
        _viewportData[2] = -(_projX = 2 * x / view.width - 1);
        _viewportData[3] = _projY = 2 * y / view.height - 1;
// _potentialFound will be set to true if any object is actually rendered
        _potentialFound = false;
        draw(collector, null);
// clear buffers
        _context.setVertexBufferAt(0, null);
        if (_context == null || !_potentialFound) return null;
        if (_bitmapData == null) _bitmapData = new BitmapData(1, 1, false, 0);
        _context.drawToBitmapData(_bitmapData);
        _hitColor = _bitmapData.getPixel(0, 0);
        if (_hitColor == 0) {
            _context.present();
            return null;
        }
        _hitRenderable = _interactives[_hitColor - 1];
        _hitEntity = _hitRenderable.sourceEntity;
        if (_onlyMouseEnabled && (!_hitEntity._ancestorsAllowMouseEnabled || !_hitEntity.mouseEnabled)) return null;
        var _collisionVO:PickingCollisionVO = _hitEntity.pickingCollisionVO;
        if (_hitRenderable.shaderPickingDetails) {
            getHitDetails(view.camera);
            _collisionVO.localPosition = _localHitPosition;
            _collisionVO.localNormal = _localHitNormal;
            _collisionVO.uv = _hitUV;
            _collisionVO.index = _faceIndex;
            _collisionVO.subGeometryIndex = _subGeometryIndex;
        }

        else {
            _collisionVO.localPosition = null;
            _collisionVO.localNormal = null;
            _collisionVO.uv = null;
            _collisionVO.index = 0;
            _collisionVO.subGeometryIndex = 0;
        }

        return _collisionVO;
    }

/**
	 * @inheritDoc
	 */

    public function getSceneCollision(position:Vector3D, direction:Vector3D, scene:Scene3D):PickingCollisionVO {
        return null;
    }

/**
	 * @inheritDoc
	 */

    private function draw(entityCollector:EntityCollector, target:TextureBase):Void {
        var camera:Camera3D = entityCollector.camera;
        _context.clear(0, 0, 0, 1);
        _stage3DProxy.scissorRect = MOUSE_SCISSOR_RECT;
        _interactives.length = _interactiveId = 0;
        if (_objectProgram3D == null) initObjectProgram3D();
        _context.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ZERO);
        _context.setDepthTest(true, Context3DCompareMode.LESS);
        _context.setProgram(_objectProgram3D);
        _context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 4, _viewportData, 1);
        drawRenderables(entityCollector.opaqueRenderableHead, camera);
        drawRenderables(entityCollector.blendedRenderableHead, camera);
    }

/**
	 * Draw a list of renderables.
	 * @param renderables The renderables to draw.
	 * @param camera The camera for which to render.
	 */

    private function drawRenderables(item:RenderableListItem, camera:Camera3D):Void {
        var matrix:Matrix3D = Matrix3DUtils.CALCULATION_MATRIX;
        var renderable:IRenderable;
        var viewProjection:Matrix3D = camera.viewProjection;
        while (item != null) {
            renderable = item.renderable;
// it's possible that the renderable was already removed from the scene
            if (renderable.sourceEntity.scene == null || (!renderable.mouseEnabled && _onlyMouseEnabled)) {
                item = item.next;
                continue;
            }
            _potentialFound = true;
            _context.setCulling(((renderable.material != null && renderable.material.bothSides)) ? Context3DTriangleFace.NONE : Context3DTriangleFace.BACK);
            _interactives[_interactiveId++] = renderable;
// color code so that reading from bitmapdata will contain the correct value
            _id[1] = (_interactiveId >> 8) / 255;
// on green channel
            _id[2] = (_interactiveId & 0xff) / 255;
// on blue channel
            matrix.copyFrom(renderable.getRenderSceneTransform(camera));
            matrix.append(viewProjection);
            _context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, matrix, true);
            _context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, _id, 1);
            renderable.activateVertexBuffer(0, _stage3DProxy);
            _context.drawTriangles(renderable.getIndexBuffer(_stage3DProxy), 0, renderable.numTriangles);
            item = item.next;
        }

    }

    private function updateRay(camera:Camera3D):Void {
        _rayPos = camera.scenePosition;
        _rayDir = camera.getRay(_projX, _projY, 1);
        _rayDir.normalize();
    }

/**
	 * Creates the Program3D that color-codes objects.
	 */

    private function initObjectProgram3D():Void {
        var vertexCode:String;
        var fragmentCode:String;
        _objectProgram3D = _context.createProgram();
        vertexCode = "m44 vt0, va0, vc0			\n" + "mul vt1.xy, vt0.w, vc4.zw	\n" + "add vt0.xy, vt0.xy, vt1.xy	\n" + "mul vt0.xy, vt0.xy, vc4.xy	\n" + "mov op, vt0	\n";
        fragmentCode = "mov oc, fc0";
// write identifier

        _objectProgram3D.upload(AGLSLShaderUtils.createShader(Context3DProgramType.VERTEX, vertexCode), AGLSLShaderUtils.createShader(Context3DProgramType.FRAGMENT, fragmentCode));
    }

/**
	 * Creates the Program3D that renders positions.
	 */

    private function initTriangleProgram3D():Void {
        var vertexCode:String;
        var fragmentCode:String;
        _triangleProgram3D = _context.createProgram();
// todo: add animation code
        vertexCode = "add vt0, va0, vc5 			\n" + "mul vt0, vt0, vc6 			\n" + "mov v0, vt0				\n" + "m44 vt0, va0, vc0			\n" + "mul vt1.xy, vt0.w, vc4.zw	\n" + "add vt0.xy, vt0.xy, vt1.xy	\n" + "mul vt0.xy, vt0.xy, vc4.xy	\n" + "mov op, vt0	\n";
        fragmentCode = "mov oc, v0";
// write identifier
        _triangleProgram3D.upload(AGLSLShaderUtils.createShader(Context3DProgramType.VERTEX, vertexCode), AGLSLShaderUtils.createShader(Context3DProgramType.FRAGMENT, fragmentCode));
    }

/**
	 * Gets more detailed information about the hir position, if required.
	 * @param camera The camera used to view the hit object.
	 */

    private function getHitDetails(camera:Camera3D):Void {
        getApproximatePosition(camera);
        getPreciseDetails(camera);
    }

/**
	 * Finds a first-guess approximate position about the hit position.
	 * @param camera The camera used to view the hit object.
	 */

    private function getApproximatePosition(camera:Camera3D):Void {
        var entity:Entity = _hitRenderable.sourceEntity;
        var col:Int;
        var scX:Float;
        var scY:Float;
        var scZ:Float;
        var offsX:Float;
        var offsY:Float;
        var offsZ:Float;
        var localViewProjection:Matrix3D = Matrix3DUtils.CALCULATION_MATRIX;
        localViewProjection.copyFrom(_hitRenderable.getRenderSceneTransform(camera));
        localViewProjection.append(camera.viewProjection);
        if (_triangleProgram3D == null) initTriangleProgram3D();
        _boundOffsetScale[4] = 1 / (scX = entity.maxX - entity.minX);
        _boundOffsetScale[5] = 1 / (scY = entity.maxY - entity.minY);
        _boundOffsetScale[6] = 1 / (scZ = entity.maxZ - entity.minZ);
        _boundOffsetScale[0] = offsX = -entity.minX;
        _boundOffsetScale[1] = offsY = -entity.minY;
        _boundOffsetScale[2] = offsZ = -entity.minZ;
        _context.setProgram(_triangleProgram3D);
        _context.clear(0, 0, 0, 0, 1, 0, Context3DClearMask.DEPTH);
        _context.setScissorRectangle(MOUSE_SCISSOR_RECT);
        _context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, localViewProjection, true);
        _context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 5, _boundOffsetScale, 2);
        _hitRenderable.activateVertexBuffer(0, _stage3DProxy);
        _context.drawTriangles(_hitRenderable.getIndexBuffer(_stage3DProxy), 0, _hitRenderable.numTriangles);
        _context.drawToBitmapData(_bitmapData);
        col = _bitmapData.getPixel(0, 0);
        _localHitPosition.x = ((col >> 16) & 0xff) * scX / 255 - offsX;
        _localHitPosition.y = ((col >> 8) & 0xff) * scY / 255 - offsY;
        _localHitPosition.z = (col & 0xff) * scZ / 255 - offsZ;
    }

/**
	 * Use the approximate position info to find the face under the mouse position from which we can derive the precise
	 * ray-face intersection point, then use barycentric coordinates to figure out the uv coordinates, etc.
	 * @param camera The camera used to view the hit object.
	 */

    private function getPreciseDetails(camera:Camera3D):Void {
        var subGeom:ISubGeometry = cast((_hitRenderable), SubMesh).subGeometry;
        var indices:Vector<UInt> = subGeom.indexData;
        var vertices:Vector<Float> = subGeom.vertexData;
        var len:Int = indices.length;
        var x1:Float;
        var y1:Float;
        var z1:Float;
        var x2:Float;
        var y2:Float;
        var z2:Float;
        var x3:Float;
        var y3:Float;
        var z3:Float;
        var i:Int = 0;
        var j:Int = 1;
        var k:Int = 2;
        var t1:Int;
        var t2:Int;
        var t3:Int;
        var v0x:Float;
        var v0y:Float;
        var v0z:Float;
        var v1x:Float;
        var v1y:Float;
        var v1z:Float;
        var v2x:Float;
        var v2y:Float;
        var v2z:Float;
        var dot00:Float;
        var dot01:Float;
        var dot02:Float;
        var dot11:Float;
        var dot12:Float;
        var s:Float;
        var t:Float;
        var invDenom:Float;
        var uvs:Vector<Float> = subGeom.UVData;
        var normals:Vector<Float> = subGeom.faceNormals;
        var x:Float = _localHitPosition.x;
        var y:Float = _localHitPosition.y;
        var z:Float = _localHitPosition.z;
        var u:Float;
        var v:Float;
        var ui1:Int;
        var ui2:Int;
        var ui3:Int;
        var s0x:Float;
        var s0y:Float;
        var s0z:Float;
        var s1x:Float;
        var s1y:Float;
        var s1z:Float;
        var nl:Float;
        var stride:Int = subGeom.vertexStride;
        var vertexOffset:Int = subGeom.vertexOffset;
        updateRay(camera);
        while (i < len) {
            t1 = vertexOffset + indices[i] * stride;
            t2 = vertexOffset + indices[j] * stride;
            t3 = vertexOffset + indices[k] * stride;
            x1 = vertices[t1];
            y1 = vertices[t1 + 1];
            z1 = vertices[t1 + 2];
            x2 = vertices[t2];
            y2 = vertices[t2 + 1];
            z2 = vertices[t2 + 2];
            x3 = vertices[t3];
            y3 = vertices[t3 + 1];
            z3 = vertices[t3 + 2];
// if within bounds
            if (!((x < x1 && x < x2 && x < x3) || (y < y1 && y < y2 && y < y3) || (z < z1 && z < z2 && z < z3) || (x > x1 && x > x2 && x > x3) || (y > y1 && y > y2 && y > y3) || (z > z1 && z > z2 && z > z3))) {
// calculate barycentric coords for approximated position
                v0x = x3 - x1;
                v0y = y3 - y1;
                v0z = z3 - z1;
                v1x = x2 - x1;
                v1y = y2 - y1;
                v1z = z2 - z1;
                v2x = x - x1;
                v2y = y - y1;
                v2z = z - z1;
                dot00 = v0x * v0x + v0y * v0y + v0z * v0z;
                dot01 = v0x * v1x + v0y * v1y + v0z * v1z;
                dot02 = v0x * v2x + v0y * v2y + v0z * v2z;
                dot11 = v1x * v1x + v1y * v1y + v1z * v1z;
                dot12 = v1x * v2x + v1y * v2y + v1z * v2z;
                invDenom = 1 / (dot00 * dot11 - dot01 * dot01);
                s = (dot11 * dot02 - dot01 * dot12) * invDenom;
                t = (dot00 * dot12 - dot01 * dot02) * invDenom;
// if inside the current triangle, fetch details hit information
                if (s >= 0 && t >= 0 && (s + t) <= 1) {
// this is def the triangle, now calculate precise coords
                    getPrecisePosition(_hitRenderable.inverseSceneTransform, normals[i], normals[i + 1], normals[i + 2], x1, y1, z1);
                    v2x = _localHitPosition.x - x1;
                    v2y = _localHitPosition.y - y1;
                    v2z = _localHitPosition.z - z1;
                    s0x = x2 - x1;
// s0 = p1 - p0
                    s0y = y2 - y1;
                    s0z = z2 - z1;
                    s1x = x3 - x1;
// s1 = p2 - p0
                    s1y = y3 - y1;
                    s1z = z3 - z1;
                    _localHitNormal.x = s0y * s1z - s0z * s1y;
// n = s0 x s1
                    _localHitNormal.y = s0z * s1x - s0x * s1z;
                    _localHitNormal.z = s0x * s1y - s0y * s1x;
                    nl = 1 / Math.sqrt(_localHitNormal.x * _localHitNormal.x + _localHitNormal.y * _localHitNormal.y + _localHitNormal.z * _localHitNormal.z);
// normalize n
                    _localHitNormal.x *= nl;
                    _localHitNormal.y *= nl;
                    _localHitNormal.z *= nl;
                    dot02 = v0x * v2x + v0y * v2y + v0z * v2z;
                    dot12 = v1x * v2x + v1y * v2y + v1z * v2z;
                    s = (dot11 * dot02 - dot01 * dot12) * invDenom;
                    t = (dot00 * dot12 - dot01 * dot02) * invDenom;
                    ui1 = indices[i] << 1;
                    ui2 = indices[j] << 1;
                    ui3 = indices[k] << 1;
                    u = uvs[ui1];
                    v = uvs[ui1 + 1];
                    _hitUV.x = u + t * (uvs[ui2] - u) + s * (uvs[ui3] - u);
                    _hitUV.y = v + t * (uvs[ui2 + 1] - v) + s * (uvs[ui3 + 1] - v);
                    _faceIndex = i;
                    _subGeometryIndex = GeomUtil.getMeshSubMeshIndex(cast((_hitRenderable), SubMesh));
                    return;
                }
            }
            i += 3;
            j += 3;
            k += 3;
        }

    }

/**
	 * Finds the precise hit position by unprojecting the screen coordinate back unto the hit face's plane and
	 * calculating the intersection point.
	 * @param camera The camera used to render the object.
	 * @param invSceneTransform The inverse scene transformation of the hit object.
	 * @param nx The x-coordinate of the face's plane normal.
	 * @param ny The y-coordinate of the face plane normal.
	 * @param nz The z-coordinate of the face plane normal.
	 * @param px The x-coordinate of a point on the face's plane (ie a face vertex)
	 * @param py The y-coordinate of a point on the face's plane (ie a face vertex)
	 * @param pz The z-coordinate of a point on the face's plane (ie a face vertex)
	 */

    private function getPrecisePosition(invSceneTransform:Matrix3D, nx:Float, ny:Float, nz:Float, px:Float, py:Float, pz:Float):Void {
// calculate screen ray and find exact intersection position with triangle
        var rx:Float;
        var ry:Float;
        var rz:Float;
        var ox:Float;
        var oy:Float;
        var oz:Float;
        var t:Float;
        var raw:Vector<Float> = Matrix3DUtils.RAW_DATA_CONTAINER;
        var cx:Float = _rayPos.x;
        var cy:Float = _rayPos.y;
        var cz:Float = _rayPos.z;
// unprojected projection point, gives ray dir in cam space
        ox = _rayDir.x;
        oy = _rayDir.y;
        oz = _rayDir.z;
// transform ray dir and origin (cam pos) to object space
        invSceneTransform.copyRawDataTo(raw);
        rx = raw[0] * ox + raw[4] * oy + raw[8] * oz;
        ry = raw[1] * ox + raw[5] * oy + raw[9] * oz;
        rz = raw[2] * ox + raw[6] * oy + raw[10] * oz;
        ox = raw[0] * cx + raw[4] * cy + raw[8] * cz + raw[12];
        oy = raw[1] * cx + raw[5] * cy + raw[9] * cz + raw[13];
        oz = raw[2] * cx + raw[6] * cy + raw[10] * cz + raw[14];
        t = ((px - ox) * nx + (py - oy) * ny + (pz - oz) * nz) / (rx * nx + ry * ny + rz * nz);
        _localHitPosition.x = ox + rx * t;
        _localHitPosition.y = oy + ry * t;
        _localHitPosition.z = oz + rz * t;
    }

    public function dispose():Void {
        _bitmapData.dispose();
        if (_triangleProgram3D != null) _triangleProgram3D.dispose();
        if (_objectProgram3D != null) _objectProgram3D.dispose();
        _triangleProgram3D = null;
        _objectProgram3D = null;
        _bitmapData = null;
        _hitRenderable = null;
        _hitEntity = null;
    }

}

