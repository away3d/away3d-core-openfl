/**
 * Helper Class for Mesh objects <code>MeshDebugger</code>
 * Displays the normals, tangents and vertexNormals of a given mesh.
 */
package away3d.tools.helpers;

import flash.Vector;
import away3d.containers.Scene3D;
import away3d.containers.ObjectContainer3D;
import away3d.entities.Mesh;
import away3d.tools.helpers.data.MeshDebug;

class MeshDebugger {
    public var colorNormals(get_colorNormals, set_colorNormals):Int;
    public var colorVertexNormals(get_colorVertexNormals, set_colorVertexNormals):Int;
    public var colorTangents(get_colorTangents, set_colorTangents):Int;
    public var lengthVertexNormals(get_lengthVertexNormals, set_lengthVertexNormals):Float;
    public var lengthNormals(get_lengthNormals, set_lengthNormals):Float;
    public var lengthTangents(get_lengthTangents, set_lengthTangents):Float;

    private var _meshesData:Vector<MeshDebugData>;
    private var _colorNormals:Int;
    private var _colorVertexNormals:Int;
    private var _colorTangents:Int;
    private var _lengthNormals:Float;
    private var _lengthTangents:Float;
    private var _lengthVertexNormals:Float;
    private var _dirty:Bool;

    public function new() {
        _meshesData = new Vector<MeshDebugData>();
        _colorNormals = 0xFF3399;
        _colorVertexNormals = 0x66CCFF;
        _colorTangents = 0xFFCC00;
        _lengthNormals = 50;
        _lengthTangents = 50;
        _lengthVertexNormals = 50;
    }

/*
	 * To set a mesh into debug state
	 *@param	mesh							Mesh. The mesh to debug.
	 *@param	scene							Scene3D. The scene where the mesh is addChilded.
	 *@param	displayNormals			Boolean. If true the mesh normals are displayed (calculated, not from mesh vector normals).
	 *@param	displayVertexNormals	Boolean. If true the mesh vertexnormals are displayed.
	 *@param	displayTangents			Boolean. If true the mesh tangents are displayed.
	 */

    public function debug(mesh:Mesh, scene:Scene3D, displayNormals:Bool = true, displayVertexNormals:Bool = false, displayTangents:Bool = false):MeshDebugData {
        var meshDebugData:MeshDebugData = isMeshDebug(mesh);
        if (!meshDebugData) {
            meshDebugData = new MeshDebugData();
            meshDebugData.meshDebug = new MeshDebug();
            meshDebugData.mesh = mesh;
            meshDebugData.scene = scene;
            meshDebugData.displayNormals = displayNormals;
            meshDebugData.displayVertexNormals = displayVertexNormals;
            meshDebugData.displayTangents = displayTangents;
            if (displayNormals) meshDebugData.meshDebug.displayNormals(mesh, _colorNormals, _lengthNormals);
            if (displayVertexNormals) meshDebugData.meshDebug.displayVertexNormals(mesh, _colorVertexNormals, _lengthVertexNormals);
            if (displayTangents) meshDebugData.meshDebug.displayTangents(mesh, _colorTangents, _lengthTangents);
            if (displayNormals || displayVertexNormals || displayTangents) {
                meshDebugData.addChilded = true;
                scene.addChild(meshDebugData.meshDebug);
            }
            meshDebugData.meshDebug.transform = meshDebugData.mesh.transform;
            _meshesData.push(meshDebugData);
        }
        return meshDebugData;
    }

/*
	 * To set an ObjectContainer3D into debug state. All its children Meshes are then debugged
	 *@param	object						Mesh. The ObjectContainer3D to debug.
	 *@param	scene							Scene3D. The scene where the mesh is addChilded.
	 *@param	displayNormals			Boolean. If true the mesh normals are displayed (calculated, not from mesh vector normals).
	 *@param	displayVertexNormals	Boolean. If true the mesh vertexnormals are displayed.
	 *@param	displayTangents			Boolean. If true the mesh tangents are displayed.
	 */

    public function debugContainer(object:ObjectContainer3D, scene:Scene3D, displayNormals:Bool = true, displayVertexNormals:Bool = false, displayTangents:Bool = false):Void {
        parse(object, scene, displayNormals, displayVertexNormals, displayTangents);
    }

/*
	 * To set a the color of the normals display. Default is 0xFF3399.
	 */

    public function set_colorNormals(val:Int):Int {
        _colorNormals = val;
        invalidate();
        return val;
    }

    public function get_colorNormals():Int {
        return _colorNormals;
    }

/*
	 * To set a the color of the vertexnormals display. Default is 0x66CCFF.
	 */

    public function set_colorVertexNormals(val:Int):Int {
        _colorVertexNormals = val;
        invalidate();
        return val;
    }

    public function get_colorVertexNormals():Int {
        return _colorVertexNormals;
    }

/*
	 * To set a the color of the tangent display. Default is 0xFFCC00.
	 */

    public function set_colorTangents(val:Int):Int {
        _colorTangents = val;
        invalidate();
        return val;
    }

    public function get_colorTangents():Int {
        return _colorTangents;
    }

/*
	 * To set a the length of the vertexnormals segments. Default is 50.
	 */

    public function set_lengthVertexNormals(val:Float):Float {
        val = val < (0) ? 1 : val;
        _lengthVertexNormals = val;
        invalidate();
        return val;
    }

    public function get_lengthVertexNormals():Float {
        return _lengthVertexNormals;
    }

/*
	 * To set a the length of the normals segments. Default is 50.
	 */

    public function set_lengthNormals(val:Float):Float {
        val = val < (0) ? 1 : val;
        _lengthNormals = val;
        invalidate();
        return val;
    }

    public function get_lengthNormals():Float {
        return _lengthNormals;
    }

/*
	 * To set a the length of the tangents segments. Default is 50.
	 */

    public function set_lengthTangents(val:Float):Float {
        val = val < (0) ? 1 : val;
        _lengthTangents = val;
        invalidate();
        return val;
    }

    public function get_lengthTangents():Float {
        return _lengthTangents;
    }

/*
	 * To hide temporary the debug of a mesh
	 */

    public function hideDebug(mesh:Mesh):Void {
        var i:Int = 0;
        while (i < _meshesData.length) {
            if (_meshesData[i].mesh == mesh && _meshesData[i].addChilded) {
                _meshesData[i].addChilded = false;
                _meshesData[i].scene.removeChild(_meshesData[i].meshDebug);
                break;
            }
            ++i;
        }
    }

/*
	 * To show the debug of a mesh if it was hidded
	 */

    public function showDebug(mesh:Mesh):Void {
        var i:Int = 0;
        while (i < _meshesData.length) {
            if (_meshesData[i].mesh == mesh && !_meshesData[i].addChilded) {
                _meshesData[i].addChilded = true;
                _meshesData[i].scene.addChild(_meshesData[i].meshDebug);
                break;
            }
            ++i;
        }
    }

/*
	 * To remove totally the debug state of a mesh
	 */

    public function removeDebug(mesh:Mesh):Void {
        var meshDebugData:MeshDebugData;
        var i:Int = 0;
        while (i < _meshesData.length) {
            meshDebugData = _meshesData[i];
            if (meshDebugData.mesh == mesh) {
                if (meshDebugData.addChilded) meshDebugData.scene.removeChild(meshDebugData.meshDebug);
                meshDebugData.meshDebug.clearAll();
                meshDebugData.meshDebug = null;
                meshDebugData = null;
                _meshesData.splice(i, 1);
                break;
            }
            ++i;
        }
    }

    public function hasDebug(mesh:Mesh):Bool {
        return (isMeshDebug(mesh)) ? true : false;
    }

/*
	 * To update the debug geometry to the updated transforms of a mesh
	 */

    public function update():Void {
        var meshDebugData:MeshDebugData;
        var tmpMDD:MeshDebugData;
        var i:Int = 0;
        while (i < _meshesData.length) {
            meshDebugData = _meshesData[i];
            if (!meshDebugData.addChilded) {
                ++i;
                continue;
            }
            ;
            if (_dirty) {
                if (!tmpMDD) tmpMDD = new MeshDebugData();
                tmpMDD.mesh = meshDebugData.mesh;
                tmpMDD.scene = meshDebugData.scene;
                tmpMDD.displayNormals = meshDebugData.displayNormals;
                tmpMDD.displayVertexNormals = meshDebugData.displayVertexNormals;
                tmpMDD.displayTangents = meshDebugData.displayTangents;
                tmpMDD.addChilded = meshDebugData.addChilded;
                removeDebug(meshDebugData.mesh);
                meshDebugData = debug(tmpMDD.mesh, tmpMDD.scene, tmpMDD.displayNormals, tmpMDD.displayVertexNormals, tmpMDD.displayTangents);
                if (!tmpMDD.addChilded) hideDebug(meshDebugData.mesh);
            }
            meshDebugData.meshDebug.transform = meshDebugData.mesh.transform;
            ++i;
        }
        _dirty = false;
    }

    private function isMeshDebug(mesh:Mesh):MeshDebugData {
        var meshDebugData:MeshDebugData;
        var i:Int = 0;
        while (i < _meshesData.length) {
            meshDebugData = _meshesData[i];
            if (meshDebugData.mesh == mesh) return meshDebugData;
            ++i;
        }
        return null;
    }

    private function invalidate():Void {
        if (_dirty || _meshesData.length == 0) return;
        _dirty = true;
    }

    private function parse(object:ObjectContainer3D, scene:Scene3D, displayNormals:Bool, displayVertexNormals:Bool, displayTangents:Bool):Void {
        var child:ObjectContainer3D;
        if (Std.is(object, Mesh && object.numChildren == 0)) debug(cast((object), Mesh), scene, displayNormals, displayVertexNormals, displayTangents);
        var i:Int = 0;
        while (i < object.numChildren) {
            child = object.getChildAt(i);
            parse(child, scene, displayNormals, displayVertexNormals, displayTangents);
            ++i;
        }
    }

}

class MeshDebugData {

    public var mesh:Mesh;
    public var meshDebug:MeshDebug;
    public var scene:Scene3D;
    public var displayNormals:Bool;
    public var displayVertexNormals:Bool;
    public var displayTangents:Bool;
    public var addChilded:Bool;

    public function new() {

    }
}

