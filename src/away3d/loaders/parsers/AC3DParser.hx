/**
 * AC3DParser provides a parser for the AC3D data type.
 *
 * unsupported tags: "numsurf","crease","texrep","refs lines of","url","data" and "numvert lines of":
 */
package away3d.loaders.parsers;

import flash.Vector;
import flash.geom.Vector3D;
import flash.net.URLRequest;
import flash.utils.ByteArray;
import haxe.ds.StringMap;

import away3d.containers.ObjectContainer3D;
import away3d.core.base.CompactSubGeometry;
import away3d.core.base.Geometry;
import away3d.core.base.data.UV;
import away3d.core.base.data.Vertex;
import away3d.entities.Mesh;
import away3d.loaders.misc.ResourceDependency;
import away3d.loaders.parsers.utils.ParserUtil;
import away3d.materials.ColorMaterial;
import away3d.materials.ColorMultiPassMaterial;
import away3d.materials.MaterialBase;
import away3d.materials.TextureMaterial;
import away3d.materials.TextureMultiPassMaterial;
import away3d.materials.utils.DefaultMaterialManager;
import away3d.textures.Texture2DBase;

import haxe.ds.StringMap;


using StringTools;

/**
 * AC3DParser provides a parser for the AC3D data type.
 *
 * unsupported tags: "numsurf","crease","texrep","refs lines of","url","data" and "numvert lines of":
 */
class AC3DParser extends ParserBase {
    private var LIMIT:Int = 65535;
    private var CR:String = String.fromCharCode(10);

    private var _textData:String;
    private var _startedParsing:Bool;
    private var _activeContainer:ObjectContainer3D;
    private var _meshList:Vector<Mesh>;
    private var _trunk:Array<String>;
    private var _containersList:Array<ObjectContainer3D>;
    private var _tmpcontainerpos:Vector3D;
    private var _tmpos:Vector3D;
    private var _kidsCount:Int = 0;
    private var _activeMesh:Mesh;
    private var _vertices:Vector<Vertex>;
    private var _uvs:Array<Dynamic>;
    private var _parsesV:Bool;
    private var _isQuad:Bool;
    private var _quadCount:Int;
    private var _lastType:String = "";
    private var _charIndex:Int;
    private var _oldIndex:Int;
    private var _stringLen:Int;
    private var _materialList:Array<MaterialBase>;

    private var _groupCount:Int;

/**
	 * Creates a new AC3DParser object.
	 * @param uri The url or id of the data or file to be parsed.
	 * @param extra The holder for extra contextual data that the parser might need.
	 */

    public function new() {
        super(ParserDataFormat.PLAIN_TEXT);

        _containersList = [];
        _tmpcontainerpos = new Vector3D(0.0, 0.0, 0.0);
        _tmpos = new Vector3D(0.0, 0.0, 0.0);
    }

/**
	 * Indicates whether or not a given file extension is supported by the parser.
	 * @param extension The file extension of a potential file to be parsed.
	 * @return Whether or not the given file type is supported.
	 */

    public static function supportsType(extension:String):Bool {
        extension = extension.toLowerCase();
        return extension == "ac";
    }

/**
	 * Tests whether a data block can be parsed by the parser.
	 * @param data The data block to potentially be parsed.
	 * @return Whether or not the given data is supported.
	 */

    public static function supportsData(data:Dynamic):Bool {
        var ba:ByteArray;
        var str:String;

        ba = ParserUtil.toByteArray(data);
        if (ba != null) {
            ba.position = 0;
            str = ba.readUTFBytes(4);
        }
        else {
            str = Std.is(data, String) ? cast(data, String).substr(0, 4) : null;
        }

        if (str == 'AC3D')
            return true;

        return false;
    }

/**
	 * @inheritDoc
	 */

    override public function resolveDependency(resourceDependency:ResourceDependency):Void {
        var mesh:Mesh = null;
        var asset:Texture2DBase = null;

        if (resourceDependency.assets.length == 1) {
            asset = cast(resourceDependency.assets[0], Texture2DBase);
            mesh = retrieveMeshFromID(resourceDependency.id);
        }
        if (mesh != null && asset != null)
        if (materialMode < 2)
            cast(mesh.material, TextureMaterial).texture = asset;
        else
            cast(mesh.material, TextureMultiPassMaterial).texture = asset;
    }

    override public function resolveDependencyFailure(resourceDependency:ResourceDependency):Void {
//handled with default material
    }

/**
	 * @inheritDoc
	 */

    override private function proceedParsing():Bool {
        var line:String;

        if (!_startedParsing) {
            _groupCount = 0;
            _activeContainer = null;

            _textData = getTextData();
            var re:EReg = new EReg(String.fromCharCode(13), "g");
            _textData = re.replace(_textData, "");
            _materialList = [];
            _startedParsing = true;

            _meshList = new Vector<Mesh>();
            _stringLen = _textData.length;
            _charIndex = _textData.indexOf(CR, 0);
            _oldIndex = _charIndex;
//skip the version header line
//version ac3d --> AC3D[b] --> hex value for file format
//If we once need to check version in future
//line = _textData.substring(0, _charIndex-1);
//var version:String = line.substring(line.length-1, line.length);
//ac3d version = getVersionFromHex(version);
        }

        var nameid:String;
        var refscount:Int;
        var tUrl:String = "";
//var m:Mesh;
        var cont:ObjectContainer3D;
        var nextObject:Int;
        var nextSurface:Int;

        while (_charIndex < _stringLen && hasTime()) {

            _charIndex = _textData.indexOf(CR, _oldIndex);

            if (_charIndex == -1)
                _charIndex = _stringLen;

            line = _textData.substring(_oldIndex, _charIndex);

            if (line.indexOf("texture ") != -1)
                tUrl = line.substring(line.indexOf('"') + 1, line.length - 1);
            _trunk = line.replace("  ", " ").replace("  ", " ").replace("  ", " ").split(" ");

            if (_charIndex != _stringLen)
                _oldIndex = _charIndex + 1;

            switch (_trunk[0])
            {
                case "MATERIAL":
                    generateMaterial(line);
                case "numsurf", "crease", "texrep", "refs lines of", "url", "data", "numvert lines of", "SURF": //0x30

                case "kids": //howmany children in the upcomming object. Probably need it later on, to couple with container/group generation
                    _kidsCount = Std.parseInt(_trunk[1]);

                    if (_lastType == "group")
                        _groupCount = _kidsCount;

                case "OBJECT":

                    if (_activeMesh != null) {
                        buildMeshGeometry(_activeMesh);
                        _tmpos.x = _tmpos.y = _tmpos.z = 0;
                        _activeMesh = null;
                    }

                    if (_trunk[1] == "world") {
                        _lastType = "world";

                    }
                    else if (_trunk[1] == "group") {
                        cont = new ObjectContainer3D();
                        if (_activeContainer != null)
                            _activeContainer.addChild(cont);
                        cont.name = "c_" + _containersList.length;
                        _containersList.push(cont);
                        _activeContainer = cont;

                        finalizeAsset(cont);

                        _lastType = "group";

                    }
                    else {
//validate if it's a definition that we can use
                        nextObject = _textData.indexOf("OBJECT", _oldIndex);
                        nextSurface = _textData.indexOf("numsurf", _oldIndex);

                        if (nextSurface == -1 || nextSurface > _stringLen) {
//we're done here, we do not need the following stuff anyway
                            _charIndex = _oldIndex = _stringLen;
                            break;

                        }
                        else if (nextObject < nextSurface) {
//some floating vertex/line lets skip this part
                            _charIndex = _oldIndex = nextObject - 1;
                            break;
                        }
                    }

                    if (_trunk[1] == "poly") {
                        var geometry:Geometry = new Geometry();
                        _activeMesh = new Mesh(geometry, null);
                        if (_vertices != null)
                            cleanUpBuffers();
                        _vertices = new Vector<Vertex>();
                        _uvs = [];
                        _activeMesh.name = "m_" + _meshList.length;
                        _meshList[_meshList.length] = _activeMesh;
//in case of groups, numvert might not be there
                        _parsesV = true;
                        _lastType = "poly";
                    }

                case "name":
                    nameid = line.substring(6, line.length - 1);
                    if (_lastType == "poly") {
                        _activeMesh.name = nameid;
                    }
                    else {
                        _activeContainer.name = nameid;
                    }

                case "numvert":
                    if (Std.parseInt(_trunk[1]) >= 3)
                        _parsesV = true;

                case "refs":
                    refscount = Std.parseInt(_trunk[1]);
                    if (refscount == 4) {
                        _isQuad = true;
                        _quadCount = 0;
                    }
                    else if (refscount < 3 || refscount > 4) {
                        continue;
                    }
                    else {
                        _isQuad = false;
                    }
                    _parsesV = false;

                case "mat":
                    if (_activeMesh.material == null)
                        _activeMesh.material = _materialList[Std.parseInt(_trunk[1])];

                case "texture":
                    if (materialMode < 2)
                        _activeMesh.material = new TextureMaterial(DefaultMaterialManager.getDefaultTexture());
                    else
                        _activeMesh.material = new TextureMultiPassMaterial(DefaultMaterialManager.getDefaultTexture());
                    _activeMesh.material.name = "m_" + _activeMesh.name;
                    addDependency((_meshList.length - 1) + "", new URLRequest(tUrl));

                case "loc": //%f %f %f
/*
					The translation of the object.  Effectively the definition of the centre of the object.  This is
					relative to the parent - i.e. not a global position.  If this is not found then
					the default centre of the object will be 0, 0, 0.
					*/

                    if (_lastType == "group") {
                        _tmpcontainerpos.x = Std.parseFloat(_trunk[1]);
                        _tmpcontainerpos.y = Std.parseFloat(_trunk[2]);
                        _tmpcontainerpos.z = Std.parseFloat(_trunk[3]);

                    }
                    else {
                        _tmpos.x = Std.parseFloat(_trunk[1]);
                        _tmpos.y = Std.parseFloat(_trunk[2]);
                        _tmpos.z = Std.parseFloat(_trunk[3]);
                    }

                case "rot": //%f %f %f  %f %f %f  %f %f %f
/*The 3x3 rotation matrix for this objects vertices.  Note that the rotation is relative
					to the object's parent i.e. it is not a global rotation matrix.  If this token
					is not specified then the default rotation matrix is 1 0 0, 0 1 0, 0 0 1 */
//Not required as ac 3d applys rotation to _vertices during export
//Might be required for containers later on
//matrix = new Matrix3D();

/*matrix.rawData = Vector.<Number>([parseFloat(_trunk[1]),parseFloat(_trunk[2]),parseFloat(_trunk[3]),0,
					parseFloat(_trunk[4]),parseFloat(_trunk[5]),parseFloat(_trunk[6]),0,
					parseFloat(_trunk[7]),parseFloat(_trunk[8]),parseFloat(_trunk[9]),0,
					0,0,0,1]);*/

//_activeMesh.transform = matrix;
                default:
                    if (_trunk[0] == "")
                        break;

                    if (_parsesV) {
                        _vertices.push(new Vertex(-(Std.parseFloat(_trunk[0])), Std.parseFloat(_trunk[1]), Std.parseFloat(_trunk[2])));

                    }
                    else {

                        if (_isQuad) {
                            _quadCount++;
                            if (_quadCount == 4) {
                                _uvs.push(_uvs[_uvs.length - 2]);
                                _uvs.push(_uvs[_uvs.length - 1]);
                                _uvs.push(Std.parseInt(_trunk[0]));
                                _uvs.push(new UV(Std.parseFloat(_trunk[1]), 1 - Std.parseFloat(_trunk[2])));
                                _uvs.push(_uvs[_uvs.length - 10]);
                                _uvs.push(_uvs[_uvs.length - 9]);

                            }
                            else {
                                _uvs.push(Std.parseInt(_trunk[0]));
                                _uvs.push(new UV(Std.parseFloat(_trunk[1]), 1 - Std.parseFloat(_trunk[2])));
                            }

                        }
                        else {
                            _uvs.push(Std.parseInt(_trunk[0]));
                            _uvs.push(new UV(Std.parseFloat(_trunk[1]), 1 - Std.parseFloat(_trunk[2])));
                        }
                    }
            }

        }

        if (_charIndex >= _stringLen) {

            if (_activeMesh != null)
                buildMeshGeometry(_activeMesh);

//finalizeAsset(_container);
            cleanUP();

            return ParserBase.PARSING_DONE;
        }

        return ParserBase.MORE_TO_PARSE;
    }

    private function checkGroup(mesh:Mesh):Void {
        if (_groupCount > 0)
            _groupCount--;

        if (_activeContainer != null)
            _activeContainer.addChild(_activeMesh);

        if (_activeContainer != null && _groupCount == 0) {
            _activeContainer = null;
            _tmpcontainerpos.x = _tmpcontainerpos.y = _tmpcontainerpos.z = 0;
        }
    }

    private function buildMeshGeometry(mesh:Mesh):Void {
        var v0:Vertex;
        var v1:Vertex;
        var v2:Vertex;

        var uv0:UV;
        var uv1:UV;
        var uv2:UV;

        var vertices:Vector<Float> = new Vector<Float>();
        var indices:Vector<UInt> = new Vector<UInt>();
        var uvs:Vector<Float> = new Vector<Float>();

        var subGeomsData:Array<Dynamic> = [vertices, indices, uvs];
//var j:uint;
        var dic:StringMap<Int> = new StringMap<Int>();
        var ref:String;

        var i:Int = 0;
        while (i < _uvs.length) {
            if (indices.length + 3 > LIMIT) {
                vertices = new Vector<Float>();
                indices = new Vector<UInt>();
                uvs = new Vector<Float>();
                subGeomsData.push(vertices);
                subGeomsData.push(indices);
                subGeomsData.push(uvs);
                dic = null;
                dic = new StringMap<Int>();
            }

            uv0 = _uvs[i + 1];
            uv1 = _uvs[i + 3];
            uv2 = _uvs[i + 5];

            v0 = _vertices[_uvs[i]];
            v1 = _vertices[_uvs[i + 2]];
            v2 = _vertices[_uvs[i + 4]];

//face order other than away
            ref = v1.toString() + uv1.toString();
            if (dic.exists(ref)) {
                indices.push(dic.get(ref));
            }
            else {
                dic.set(ref, Std.int(vertices.length / 3));
                indices.push(dic.get(ref));
                vertices.push(v1.x);
                vertices.push(v1.y);
                vertices.push(v1.z);
                uvs.push(uv1.u);
                uvs.push(uv1.v);
            }

            ref = v0.toString() + uv0.toString();
            if (dic.exists(ref)) {
                indices.push(dic.get(ref));
            }
            else {
                dic.set(ref, Std.int(vertices.length / 3));
                indices.push(dic.get(ref));
                vertices.push(v0.x);
                vertices.push(v0.y);
                vertices.push(v0.z);
                uvs.push(uv0.u);
                uvs.push(uv0.v);
            }

            ref = v2.toString() + uv2.toString();
            if (dic.exists(ref)) {
                indices.push(dic.get(ref));
            }
            else {
                dic.set(ref, Std.int(vertices.length / 3));
                indices.push(dic.get(ref));
                vertices.push(v2.x);
                vertices.push(v2.y);
                vertices.push(v2.z);
                uvs.push(uv2.u);
                uvs.push(uv2.v);
            }

            i += 6;
        }

        var sub_geom:CompactSubGeometry;
        var geom:Geometry = mesh.geometry;

        i = 0;
        while (i < subGeomsData.length) {
            sub_geom = new CompactSubGeometry();
            sub_geom.fromVectors(subGeomsData[i], subGeomsData[i + 2], null, null);
            sub_geom.updateIndexData(subGeomsData[i + 1]);
            geom.addSubGeometry(sub_geom);
            i += 3;
        }

        mesh.x = -_tmpos.x;
        mesh.y = _tmpos.y;
        mesh.z = _tmpos.z;

        mesh.x -= _tmpcontainerpos.x;
        mesh.y += _tmpcontainerpos.y;
        mesh.z += _tmpcontainerpos.z;

        checkGroup(_activeMesh);

        finalizeAsset(mesh);

        dic = null;
    }

    private function retrieveMeshFromID(id:String):Mesh {
        if (_meshList[Std.parseInt(id)] != null)
            return _meshList[Std.parseInt(id)];

        return null;
    }

/*
	private function getVersionFromHex(char:String):int
	{
		switch (char)
		{
			case "A":
			case "a":
				return 10;
			case "B":
			case "b":
				return 11;
			case "C":
			case "c":
				return 12;
			case "D":
			case "d":
				return 13;
			case "E":
			case "e":
				return 14;
			case "F":
			case "f":
				return 15;
			default:
				return new Number(char);
		}
	}
	 *
	 */

    private function generateMaterial(materialString:String):Void {
        _materialList.push(parseMaterialLine(materialString));
    }

    private function parseMaterialLine(materialString:String):MaterialBase {
        var trunk:Array<String> = materialString.split(" ");


        var color:UInt = 0x000000;
        var name:String = "";
        var ambient:Float = 0;
        var specular:Float = 0;
        var gloss:Float = 0;
        var alpha:Float = 0;

        var i:Int = 0;
        while (i < trunk.length) {
            if (trunk[i] == "") {
                i++;
                continue;
            }

            if (trunk[i].indexOf("\"") != -1 || trunk[i].indexOf("\'") != -1) {
                name = trunk[i].substring(1, trunk[i].length - 1);
                i++;
                continue;
            }

            switch (trunk[i])
            {
                case "rgb":
                    var r:Int = Std.int(Std.parseFloat(trunk[i + 1]) * 255);
                    var g:Int = Std.int(Std.parseFloat(trunk[i + 2]) * 255);
                    var b:Int = Std.int(Std.parseFloat(trunk[i + 3]) * 255);
                    i += 3;
                    color = r << 16 | g << 8 | b;
                case "amb":
                    ambient = Std.parseFloat(trunk[i + 1]);
                    i += 2;
                case "spec":
                    specular = Std.parseFloat(trunk[i + 1]);
                    i += 2;
                case "shi":
                    gloss = Std.parseFloat(trunk[i + 1]) / 255;
                    i += 2;
                case "trans":
                    alpha = (1 - Std.parseFloat(trunk[i + 1]));
            }

            i++;
        }

        var colorMaterial:MaterialBase;

        if (materialMode < 2) {
            colorMaterial = new ColorMaterial(0xFFFFFF);
            cast(colorMaterial, ColorMaterial).name = name;
            cast(colorMaterial, ColorMaterial).color = color;
            cast(colorMaterial, ColorMaterial).ambient = ambient;
            cast(colorMaterial, ColorMaterial).specular = specular;
            cast(colorMaterial, ColorMaterial).gloss = gloss;
            cast(colorMaterial, ColorMaterial).alpha = alpha;
        }
        else {
            colorMaterial = new ColorMultiPassMaterial(0xFFFFFF);
            cast(colorMaterial, ColorMultiPassMaterial).name = name;
            cast(colorMaterial, ColorMultiPassMaterial).color = color;
            cast(colorMaterial, ColorMultiPassMaterial).ambient = ambient;
            cast(colorMaterial, ColorMultiPassMaterial).specular = specular;
            cast(colorMaterial, ColorMultiPassMaterial).gloss = gloss;
//cast(colorMaterial,ColorMultiPassMaterial).alpha=alpha;
        }
        return colorMaterial;
    }

    private function cleanUP():Void {
        _materialList = null;
        cleanUpBuffers();
    }

    private function cleanUpBuffers():Void {
        for (i in 0..._vertices.length)
            _vertices[i] = null;

        for (i in 0..._uvs.length)
            _uvs[i] = null;

        _vertices = null;
        _uvs = null;
    }

}
