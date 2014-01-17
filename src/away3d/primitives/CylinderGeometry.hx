/**
 * A Cylinder primitive mesh.
 */
package away3d.primitives;


import flash.Vector;
import away3d.core.base.CompactSubGeometry;

class CylinderGeometry extends PrimitiveBase {
    public var topRadius(get_topRadius, set_topRadius):Float;
    public var bottomRadius(get_bottomRadius, set_bottomRadius):Float;
    public var height(get_height, set_height):Float;
    public var segmentsW(get_segmentsW, set_segmentsW):Int;
    public var segmentsH(get_segmentsH, set_segmentsH):Int;
    public var topClosed(get_topClosed, set_topClosed):Bool;
    public var bottomClosed(get_bottomClosed, set_bottomClosed):Bool;
    public var yUp(get_yUp, set_yUp):Bool;

    private var _topRadius:Float;
    private var _bottomRadius:Float;
    private var _height:Float;
    private var _segmentsW:Int;
    private var _segmentsH:Int;
    private var _topClosed:Bool;
    private var _bottomClosed:Bool;
    private var _surfaceClosed:Bool;
    private var _yUp:Bool;
    private var _rawData:Vector<Float>;
    private var _rawIndices:Vector<UInt>;
    private var _nextVertexIndex:Int;
    private var _currentIndex:Int;
    private var _currentTriangleIndex:Int;
    private var _numVertices:Int;
    private var _stride:Int;
    private var _vertexOffset:Int;

    private function addVertex(px:Float, py:Float, pz:Float, nx:Float, ny:Float, nz:Float, tx:Float, ty:Float, tz:Float):Void {
        var compVertInd:Int = _vertexOffset + _nextVertexIndex * _stride;
// current component vertex index
        _rawData[compVertInd++] = px;
        _rawData[compVertInd++] = py;
        _rawData[compVertInd++] = pz;
        _rawData[compVertInd++] = nx;
        _rawData[compVertInd++] = ny;
        _rawData[compVertInd++] = nz;
        _rawData[compVertInd++] = tx;
        _rawData[compVertInd++] = ty;
        _rawData[compVertInd++] = tz;
        _nextVertexIndex++;
    }

    private function addTriangleClockWise(cwVertexIndex0:Int, cwVertexIndex1:Int, cwVertexIndex2:Int):Void {
        _rawIndices[_currentIndex++] = cwVertexIndex0;
        _rawIndices[_currentIndex++] = cwVertexIndex1;
        _rawIndices[_currentIndex++] = cwVertexIndex2;
        _currentTriangleIndex++;
    }

/**
	 * @inheritDoc
	 */

    override private function buildGeometry(target:CompactSubGeometry):Void {
        var i:Int = 0;
        var j:Int = 0;
        var x:Float = 0;
        var y:Float = 0;
        var z:Float = 0;
        var radius:Float = 0;
        var revolutionAngle:Float = 0;
        var dr:Float = 0;
        var latNormElev:Float = 0;
        var latNormBase:Float = 0;
        var numTriangles:Int = 0;
        var comp1:Float = 0;
        var comp2:Float = 0;
        var startIndex:Int = 0;
//numvert:uint = 0;
        var t1:Float = 0;
        var t2:Float = 0;
        _stride = target.vertexStride;
        _vertexOffset = target.vertexOffset;
// reset utility variables
        _numVertices = 0;
        _nextVertexIndex = 0;
        _currentIndex = 0;
        _currentTriangleIndex = 0;
// evaluate target number of vertices, triangles and indices
        if (_surfaceClosed) {
            _numVertices += (_segmentsH + 1) * (_segmentsW + 1);
// segmentsH + 1 because of closure, segmentsW + 1 because of UV unwrapping
            numTriangles += _segmentsH * _segmentsW * 2;
// each level has segmentW quads, each of 2 triangles
        }
        if (_topClosed) {
            _numVertices += 2 * (_segmentsW + 1);
// segmentsW + 1 because of unwrapping
            numTriangles += _segmentsW;
// one triangle for each segment
        }
        if (_bottomClosed) {
            _numVertices += 2 * (_segmentsW + 1);
            numTriangles += _segmentsW;
        }
        if (_numVertices == target.numVertices) {
            _rawData = target.vertexData;
            _rawIndices = target.indexData;
            if (_rawIndices == null)_rawIndices = new Vector<UInt>(numTriangles * 3, true);
        }

        else {
            var numVertComponents:Int = _numVertices * _stride;
            _rawData = new Vector<Float>(numVertComponents, true);
            _rawIndices = new Vector<UInt>(numTriangles * 3, true);
        }

// evaluate revolution steps
        var revolutionAngleDelta:Float = 2 * Math.PI / _segmentsW;
// top
        if (_topClosed && _topRadius > 0) {
            z = -0.5 * _height;
            i = 0;
            while (i <= _segmentsW) {
// central vertex
                if (_yUp) {
                    t1 = 1;
                    t2 = 0;
                    comp1 = -z;
                    comp2 = 0;
                }

                else {
                    t1 = 0;
                    t2 = -1;
                    comp1 = 0;
                    comp2 = z;
                }

                addVertex(0, comp1, comp2, 0, t1, t2, 1, 0, 0);
// revolution vertex
                revolutionAngle = i * revolutionAngleDelta;
                x = _topRadius * Math.cos(revolutionAngle);
                y = _topRadius * Math.sin(revolutionAngle);
                if (_yUp) {
                    comp1 = -z;
                    comp2 = y;
                }

                else {
                    comp1 = y;
                    comp2 = z;
                }

                if (i == _segmentsW) addVertex(_rawData[startIndex + _stride], _rawData[startIndex + _stride + 1], _rawData[startIndex + _stride + 2], 0, t1, t2, 1, 0, 0)
                else addVertex(x, comp1, comp2, 0, t1, t2, 1, 0, 0);
                if (i > 0) // add triangle

                    addTriangleClockWise(_nextVertexIndex - 1, _nextVertexIndex - 3, _nextVertexIndex - 2);
                ++i;
            }
        }
        if (_bottomClosed && _bottomRadius > 0) {
            z = 0.5 * _height;
            startIndex = _vertexOffset + _nextVertexIndex * _stride;
            i = 0;
            while (i <= _segmentsW) {
                if (_yUp) {
                    t1 = -1;
                    t2 = 0;
                    comp1 = -z;
                    comp2 = 0;
                }

                else {
                    t1 = 0;
                    t2 = 1;
                    comp1 = 0;
                    comp2 = z;
                }

                addVertex(0, comp1, comp2, 0, t1, t2, 1, 0, 0);
// revolution vertex
                revolutionAngle = i * revolutionAngleDelta;
                x = _bottomRadius * Math.cos(revolutionAngle);
                y = _bottomRadius * Math.sin(revolutionAngle);
                if (_yUp) {
                    comp1 = -z;
                    comp2 = y;
                }

                else {
                    comp1 = y;
                    comp2 = z;
                }

                if (i == _segmentsW) addVertex(x, _rawData[startIndex + 1], _rawData[startIndex + 2], 0, t1, t2, 1, 0, 0)
                else addVertex(x, comp1, comp2, 0, t1, t2, 1, 0, 0);
                if (i > 0) // add triangle

                    addTriangleClockWise(_nextVertexIndex - 2, _nextVertexIndex - 3, _nextVertexIndex - 1);
                ++i;
            }
        }
        dr = (_bottomRadius - _topRadius);
        latNormElev = dr / _height;
        latNormBase = ((latNormElev == 0)) ? 1 : _height / dr;
// lateral surface
        if (_surfaceClosed) {
            var a:Int;
            var b:Int;
            var c:Int;
            var d:Int;
            var na0:Float;
            var na1:Float;
            var naComp1:Float;
            var naComp2:Float;
            j = 0;
            while (j <= _segmentsH) {
                radius = _topRadius - ((j / _segmentsH) * (_topRadius - _bottomRadius));
                z = -(_height / 2) + (j / _segmentsH * _height);
                startIndex = _vertexOffset + _nextVertexIndex * _stride;
                i = 0;
                while (i <= _segmentsW) {
// revolution vertex
                    revolutionAngle = i * revolutionAngleDelta;
                    x = radius * Math.cos(revolutionAngle);
                    y = radius * Math.sin(revolutionAngle);
                    na0 = latNormBase * Math.cos(revolutionAngle);
                    na1 = latNormBase * Math.sin(revolutionAngle);
                    if (_yUp) {
                        t1 = 0;
                        t2 = -na0;
                        comp1 = -z;
                        comp2 = y;
                        naComp1 = latNormElev;
                        naComp2 = na1;
                    }

                    else {
                        t1 = -na0;
                        t2 = 0;
                        comp1 = y;
                        comp2 = z;
                        naComp1 = na1;
                        naComp2 = latNormElev;
                    }

                    if (i == _segmentsW) {
                        addVertex(_rawData[startIndex], _rawData[startIndex + 1], _rawData[startIndex + 2], na0, latNormElev, na1, na1, t1, t2);
                    }

                    else {
                        addVertex(x, comp1, comp2, na0, naComp1, naComp2, -na1, t1, t2);
                    }

// close triangle
                    if (i > 0 && j > 0) {
                        a = _nextVertexIndex - 1;
// current
                        b = _nextVertexIndex - 2;
// previous
                        c = b - _segmentsW - 1;
// previous of last level
                        d = a - _segmentsW - 1;
// current of last level
                        addTriangleClockWise(a, b, c);
                        addTriangleClockWise(a, c, d);
                    }
                    ++i;
                }
                ++j;
            }
        }
        target.updateData(_rawData);
        target.updateIndexData(_rawIndices);
    }

/**
	 * @inheritDoc
	 */

    override private function buildUVs(target:CompactSubGeometry):Void {
        var i:Int;
        var j:Int;
        var x:Float;
        var y:Float;
        var revolutionAngle:Float;
        var stride:Int = target.UVStride;
        var skip:Int = stride - 2;
        var UVData:Vector<Float>;
// evaluate num uvs
        var numUvs:Int = _numVertices * stride;
// need to initialize raw array or can be reused?
        if (target.UVData != null && numUvs == target.UVData.length) UVData = target.UVData
        else {
            UVData = new Vector<Float>(numUvs, true);
            invalidateGeometry();
        }

// evaluate revolution steps
        var revolutionAngleDelta:Float = 2 * Math.PI / _segmentsW;
// current uv component index
        var currentUvCompIndex:Int = target.UVOffset;
// top
        if (_topClosed) {
            i = 0;
            while (i <= _segmentsW) {
                revolutionAngle = i * revolutionAngleDelta;
                x = 0.5 + 0.5 * -Math.cos(revolutionAngle);
                y = 0.5 + 0.5 * Math.sin(revolutionAngle);
                UVData[currentUvCompIndex++] = 0.5 * target.scaleU;
// central vertex
                UVData[currentUvCompIndex++] = 0.5 * target.scaleV;
                currentUvCompIndex += skip;
                UVData[currentUvCompIndex++] = x * target.scaleU;
// revolution vertex
                UVData[currentUvCompIndex++] = y * target.scaleV;
                currentUvCompIndex += skip;
                ++i;
            }
        }
        if (_bottomClosed) {
            i = 0;
            while (i <= _segmentsW) {
                revolutionAngle = i * revolutionAngleDelta;
                x = 0.5 + 0.5 * Math.cos(revolutionAngle);
                y = 0.5 + 0.5 * Math.sin(revolutionAngle);
                UVData[currentUvCompIndex++] = 0.5 * target.scaleU;
// central vertex
                UVData[currentUvCompIndex++] = 0.5 * target.scaleV;
                currentUvCompIndex += skip;
                UVData[currentUvCompIndex++] = x * target.scaleU;
// revolution vertex
                UVData[currentUvCompIndex++] = y * target.scaleV;
                currentUvCompIndex += skip;
                ++i;
            }
        }
        if (_surfaceClosed) {
            j = 0;
            while (j <= _segmentsH) {
                i = 0;
                while (i <= _segmentsW) {
// revolution vertex
                    UVData[currentUvCompIndex++] = (i / _segmentsW) * target.scaleU;
                    UVData[currentUvCompIndex++] = (j / _segmentsH) * target.scaleV;
                    currentUvCompIndex += skip;
                    ++i;
                }
                ++j;
            }
        }
        target.updateData(UVData);
    }

/**
	 * The radius of the top end of the cylinder.
	 */

    public function get_topRadius():Float {
        return _topRadius;
    }

    public function set_topRadius(value:Float):Float {
        _topRadius = value;
        invalidateGeometry();
        return value;
    }

/**
	 * The radius of the bottom end of the cylinder.
	 */

    public function get_bottomRadius():Float {
        return _bottomRadius;
    }

    public function set_bottomRadius(value:Float):Float {
        _bottomRadius = value;
        invalidateGeometry();
        return value;
    }

/**
	 * The radius of the top end of the cylinder.
	 */

    public function get_height():Float {
        return _height;
    }

    public function set_height(value:Float):Float {
        _height = value;
        invalidateGeometry();
        return value;
    }

/**
	 * Defines the number of horizontal segments that make up the cylinder. Defaults to 16.
	 */

    public function get_segmentsW():Int {
        return _segmentsW;
    }

    public function set_segmentsW(value:Int):Int {
        _segmentsW = value;
        invalidateGeometry();
        invalidateUVs();
        return value;
    }

/**
	 * Defines the number of vertical segments that make up the cylinder. Defaults to 1.
	 */

    public function get_segmentsH():Int {
        return _segmentsH;
    }

    public function set_segmentsH(value:Int):Int {
        _segmentsH = value;
        invalidateGeometry();
        invalidateUVs();
        return value;
    }

/**
	 * Defines whether the top end of the cylinder is closed (true) or open.
	 */

    public function get_topClosed():Bool {
        return _topClosed;
    }

    public function set_topClosed(value:Bool):Bool {
        _topClosed = value;
        invalidateGeometry();
        return value;
    }

/**
	 * Defines whether the bottom end of the cylinder is closed (true) or open.
	 */

    public function get_bottomClosed():Bool {
        return _bottomClosed;
    }

    public function set_bottomClosed(value:Bool):Bool {
        _bottomClosed = value;
        invalidateGeometry();
        return value;
    }

/**
	 * Defines whether the cylinder poles should lay on the Y-axis (true) or on the Z-axis (false).
	 */

    public function get_yUp():Bool {
        return _yUp;
    }

    public function set_yUp(value:Bool):Bool {
        _yUp = value;
        invalidateGeometry();
        return value;
    }

/**
	 * Creates a new Cylinder object.
	 * @param topRadius The radius of the top end of the cylinder.
	 * @param bottomRadius The radius of the bottom end of the cylinder
	 * @param height The radius of the bottom end of the cylinder
	 * @param segmentsW Defines the number of horizontal segments that make up the cylinder. Defaults to 16.
	 * @param segmentsH Defines the number of vertical segments that make up the cylinder. Defaults to 1.
	 * @param topClosed Defines whether the top end of the cylinder is closed (true) or open.
	 * @param bottomClosed Defines whether the bottom end of the cylinder is closed (true) or open.
	 * @param yUp Defines whether the cone poles should lay on the Y-axis (true) or on the Z-axis (false).
	 */

    public function new(topRadius:Float = 50, bottomRadius:Float = 50, height:Float = 100, segmentsW:Int = 16, segmentsH:Int = 1, topClosed:Bool = true, bottomClosed:Bool = true, surfaceClosed:Bool = true, yUp:Bool = true) {
        super();
        _topRadius = topRadius;
        _bottomRadius = bottomRadius;
        _height = height;
        _segmentsW = segmentsW;
        _segmentsH = segmentsH;
        _topClosed = topClosed;
        _bottomClosed = bottomClosed;
        _surfaceClosed = surfaceClosed;
        _yUp = yUp;
    }

}

