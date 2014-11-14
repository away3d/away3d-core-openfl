package away3d.core.base;

import away3d.core.managers.Stage3DProxy;
import openfl.display3D.IndexBuffer3D;
import openfl.geom.Matrix3D;
import openfl.utils.Float32Array;
import openfl.utils.Int16Array;


interface ISubGeometry {
    var numVertices(get_numVertices, never):Int;
    var numTriangles(get_numTriangles, never):Int;
    var vertexStride(get_vertexStride, never):Int;
    var vertexNormalStride(get_vertexNormalStride, never):Int;
    var vertexTangentStride(get_vertexTangentStride, never):Int;
    var UVStride(get_UVStride, never):Int;
    var secondaryUVStride(get_secondaryUVStride, never):Int;
    var vertexData(get_vertexData, never):Float32Array;
    var vertexNormalData(get_vertexNormalData, never):Float32Array;
    var vertexTangentData(get_vertexTangentData, never):Float32Array;
    var vertexOffset(get_vertexOffset, never):Int;
    var vertexNormalOffset(get_vertexNormalOffset, never):Int;
    var vertexTangentOffset(get_vertexTangentOffset, never):Int;
    var UVOffset(get_UVOffset, never):Int;
    var secondaryUVOffset(get_secondaryUVOffset, never):Int;
    var indexData(get_indexData, never):Int16Array;
    var UVData(get_UVData, never):Float32Array;
    var scaleU(get_scaleU, never):Float;
    var scaleV(get_scaleV, never):Float;
    var parentGeometry(get_parentGeometry, set_parentGeometry):Geometry;
    var faceNormals(get_faceNormals, never):Float32Array;
    var autoDeriveVertexNormals(get_autoDeriveVertexNormals, set_autoDeriveVertexNormals):Bool;
    var autoDeriveVertexTangents(get_autoDeriveVertexTangents, set_autoDeriveVertexTangents):Bool;
    var vertexPositionData(get_vertexPositionData, never):Float32Array;

    /**
	 * The total amount of vertices in the SubGeometry.
	 */
    function get_numVertices():Int;

    /**
	 * The amount of triangles that comprise the IRenderable geometry.
	 */
    function get_numTriangles():Int;

    /**
	 * The distance between two consecutive vertex, normal or tangent elements
	 * This always applies to vertices, normals and tangents.
	 */
    function get_vertexStride():Int;

    /**
	 * The distance between two consecutive normal elements
	 * This always applies to vertices, normals and tangents.
	 */
    function get_vertexNormalStride():Int;

    /**
	 * The distance between two consecutive tangent elements
	 * This always applies to vertices, normals and tangents.
	 */
    function get_vertexTangentStride():Int;

    /**
	 * The distance between two consecutive UV elements
	 */
    function get_UVStride():Int;

    /**
	 * The distance between two secondary UV elements
	 */
    function get_secondaryUVStride():Int;
    
    /**
	 * Assigns the attribute stream for vertex positions.
	 * @param index The attribute stream index for the vertex shader
	 * @param stage3DProxy The Stage3DProxy to assign the stream to
	 */
    function activateVertexBuffer(index:Int, stage3DProxy:Stage3DProxy):Void;

    /**
	 * Assigns the attribute stream for UV coordinates
	 * @param index The attribute stream index for the vertex shader
	 * @param stage3DProxy The Stage3DProxy to assign the stream to
	 */
    function activateUVBuffer(index:Int, stage3DProxy:Stage3DProxy):Void;

    /**
	 * Assigns the attribute stream for a secondary set of UV coordinates
	 * @param index The attribute stream index for the vertex shader
	 * @param stage3DProxy The Stage3DProxy to assign the stream to
	 */
    function activateSecondaryUVBuffer(index:Int, stage3DProxy:Stage3DProxy):Void;

    /**
	 * Assigns the attribute stream for vertex normals
	 * @param index The attribute stream index for the vertex shader
	 * @param stage3DProxy The Stage3DProxy to assign the stream to
	 */
    function activateVertexNormalBuffer(index:Int, stage3DProxy:Stage3DProxy):Void;

    /**
	 * Assigns the attribute stream for vertex tangents
	 * @param index The attribute stream index for the vertex shader
	 * @param stage3DProxy The Stage3DProxy to assign the stream to
	 */
    function activateVertexTangentBuffer(index:Int, stage3DProxy:Stage3DProxy):Void;

    /**
	 * Retrieves the IndexBuffer3D object that contains triangle indices.
	 * @param context The Context3D for which we request the buffer
	 * @return The VertexBuffer3D object that contains triangle indices.
	 */
    function getIndexBuffer(stage3DProxy:Stage3DProxy):IndexBuffer3D;

    /**
	 * Retrieves the object's vertices as a Number array.
	 */
    function get_vertexData():Float32Array;

    /**
	 * Retrieves the object's normals as a Number array.
	 */
    function get_vertexNormalData():Float32Array;

    /**
	 * Retrieves the object's tangents as a Number array.
	 */
    function get_vertexTangentData():Float32Array;

    /**
	 * The offset into vertexData where the vertices are placed
	 */
    function get_vertexOffset():Int;

    /**
	 * The offset into vertexNormalData where the normals are placed
	 */
    function get_vertexNormalOffset():Int;

    /**
	 * The offset into vertexTangentData where the tangents are placed
	 */
    function get_vertexTangentOffset():Int;

    /**
	 * The offset into UVData vector where the UVs are placed
	 */
    function get_UVOffset():Int;

    /**
	 * The offset into SecondaryUVData vector where the UVs are placed
	 */
    function get_secondaryUVOffset():Int;
    
    /**
	 * Retrieves the object's indices as a uint array.
	 */
    function get_indexData():Int16Array;

    /**
	 * Retrieves the object's uvs as a Number array.
	 */
    function get_UVData():Float32Array;
    function applyTransformation(transform:Matrix3D):Void;
    function scale(scale:Float):Void;
    function dispose():Void;
    function clone():ISubGeometry;
    function get_scaleU():Float;
    function get_scaleV():Float;
    function scaleUV(scaleU:Float = 1, scaleV:Float = 1):Void;
    function get_parentGeometry():Geometry;
    function set_parentGeometry(value:Geometry):Geometry;
    function get_faceNormals():Float32Array;
    function cloneWithSeperateBuffers():SubGeometry;
    function get_autoDeriveVertexNormals():Bool;
    function set_autoDeriveVertexNormals(value:Bool):Bool;
    function get_autoDeriveVertexTangents():Bool;
    function set_autoDeriveVertexTangents(value:Bool):Bool;
    function fromVectors(vertices:Float32Array, uvs:Float32Array, normals:Float32Array, tangents:Float32Array):Void;
    function get_vertexPositionData():Float32Array;
}

