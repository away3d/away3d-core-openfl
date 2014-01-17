package away3d.tools.utils;

import flash.geom.Vector3D;

class Ray {
    public var orig(get_orig, set_orig):Vector3D;
    public var dir(get_dir, set_dir):Vector3D;
    public var planeNormal(get_planeNormal, never):Vector3D;

    private var _orig:Vector3D;
    private var _dir:Vector3D;
    private var _tu:Vector3D;
    private var _tv:Vector3D;
    private var _w:Vector3D;
    private var _pn:Vector3D;
    private var _npn:Vector3D;
    private var _a:Float;
    private var _b:Float;
    private var _c:Float;
    private var _d:Float;

    function new() {
        _orig = new Vector3D(0.0, 0.0, 0.0);
        _dir = new Vector3D(0.0, 0.0, 0.0);
        _tu = new Vector3D(0.0, 0.0, 0.0);
        _tv = new Vector3D(0.0, 0.0, 0.0);
        _w = new Vector3D(0.0, 0.0, 0.0);
        _pn = new Vector3D(0.0, 0.0, 0.0);
        _npn = new Vector3D(0.0, 0.0, 0.0);
    }

/**
	 * Defines the origin point of the Ray object
	 * @return    Vector3D        The origin point of the Ray object
	 */

    public function set_orig(o:Vector3D):Vector3D {
        _orig.x = o.x;
        _orig.y = o.y;
        _orig.z = o.z;
        return o;
    }

    public function get_orig():Vector3D {
        return _orig;
    }

/**
	 * Defines the directional vector of the Ray object
	 * @return    Vector3D        The directional vector
	 */

    public function set_dir(n:Vector3D):Vector3D {
        _dir.x = n.x;
        _dir.y = n.y;
        _dir.z = n.z;
        return n;
    }

    public function get_dir():Vector3D {
        return _dir;
    }

/**
	 * Defines the directional normal of the Ray object
	 * @return    Vector3D        The normal of the plane
	 */

    public function get_planeNormal():Vector3D {
        return _pn;
    }

/**
	 * Checks if a ray intersects a sphere.
	 *@param        pOrig            Vector3D.    The origin vector of the ray.
	 *@param        dir                Vector3D. The normalized direction vector of the ray.
	 *@param        sPos            Vector3D. The position of the sphere.
	 *@param        radius        Number. The radius of the sphere.
	 *
	 * @return        Boolean        If the ray intersects the sphere
	 */

    public function intersectsSphere(pOrig:Vector3D, dir:Vector3D, sPos:Vector3D, radius:Float):Bool {
        return cast((hasSphereIntersection(pOrig, dir, sPos, radius) > 0), Boolean);
    }

/**
	 * Returns a Vector3D where the ray intersects a sphere. Return null if the ray misses the sphere
	 *
	 *@param        pOrig            Vector3D.        The origin of the ray.
	 *@param        dir                Vector3D.        The direction of the ray.
	 *@param        sPos            Vector3D.        The position of the sphere.
	 *@param        radius        Number.        The radius of the sphere.
	 *@param        bNearest    [optional] Boolean. If the ray traverses the sphere and if true the returned hit is the nearest to ray origin. Default is true.
	 *@param        bNormal        [optional] Boolean. If the returned vector is the normal of the hitpoint. Default is false.
	 *
	 * @return        Vector3D    The intersection vector3D or the normal vector3D of the hitpoint. Default is false.
	 *
	 * example of a ray triggered from mouse
	 var pMouse:Vector3D = _view.unproject(_view.mouseX, _view.mouseY, 1);
	 var cam:Vector3D = _view.camera.position;
	 var dir:Vector3D = new Vector3D( pMouse.x-cam.x,  pMouse.y-cam.y, pMouse.z-cam.z);
	 dir.normalize();
	
	 var spherePosition:Vector3D = new Vector3D(200, 200, 200);
	
	 //hittest
	 trace("Ray intersects sphere :"+ _ray.intersectsSphere(pMouse, dir, spherePosition, 500) );
	
	 var sintersect:Vector3D = _ray.getRayToSphereIntersection(pMouse, dir, spherePosition, 500, true, false);
	 if sintersect == null no hit, else sintersect = intersection vector3d or the normal of the intersection
	 */

    public function getRayToSphereIntersection(pOrig:Vector3D, dir:Vector3D, sPos:Vector3D, radius:Float, bNearest:Bool = true, bNormal:Bool = false, outVector3D:Vector3D = null):Vector3D {
        _d = hasSphereIntersection(pOrig, dir, sPos, radius);
// no intersection, ray misses sphere
        if (_d < 0) return null;
        _d = Math.sqrt(_d);
        var t:Float = ((bNearest)) ? (-0.5) * (_b - _d) / _a : (-0.5) * (_b + _d) / _a;
        if (t == 0.0) return null;
        var result:Vector3D = outVector3D || new Vector3D(0.0, 0.0, 0.0);
        result.x = pOrig.x + (_pn.x * t);
        result.y = pOrig.y + (_pn.y * t);
        result.z = pOrig.z + (_pn.z * t);
//todo, add dist return. var dist:Number = Math.sqrt(a)*t;
        if (bNormal) {
            _pn.x = (result.x - sPos.x) / radius;
            _pn.y = (result.y - sPos.y) / radius;
            _pn.z = (result.z - sPos.z) / radius;
            return _pn;
        }
        return result;
    }

/**
	 * Returns a Vector3D where the ray intersects a plane inside a triangle
	 * Returns null if no hit is found.
	 *
	 *@param        p0            Vector3D.        The origin of the ray.
	 *@param        p1            Vector3D.        The end of the ray.
	 *@param        v0            Vector3D.        The first scenespace vertex of the face.
	 *@param        v1            Vector3D.        The second scenespace vertex of the face.
	 *@param        v2            Vector3D.        The third scenespace vertex of the face.
	 *@param        outVector3D    Vector3D.        Optional user defined Vector3D returned with result values
	 *
	 * example: fire a ray from camera position to 0,0,0 and test if it hits the triangle.
	
	 view.camera.x = 100;
	 view.camera.y = 100;
	 view.camera.z = 500;
	
	 var v0:Vector3D = new Vector3D(-200, 100, 60);
	 var v1:Vector3D = new Vector3D(200, 100, 60);
	 var v2:Vector3D = new Vector3D(0, -200, 60);
	
	 var dest: Vector3D = new Vector3D(0, 0, 0);
	
	 var intersect:Vector3D = _ray.getRayToTriangleIntersection(_view.camera.position, dest, v0, v1, v2 );
	 trace("intersect ray: "+intersect);
	
	 *
	 * @return    Vector3D    The intersection point
	 */

    public function getRayToTriangleIntersection(p0:Vector3D, p1:Vector3D, v0:Vector3D, v1:Vector3D, v2:Vector3D, outVector3D:Vector3D = null):Vector3D {
        _tu.x = v1.x - v0.x;
        _tu.y = v1.y - v0.y;
        _tu.z = v1.z - v0.z;
        _tv.x = v2.x - v0.x;
        _tv.y = v2.y - v0.y;
        _tv.z = v2.z - v0.z;
        _pn.x = _tu.y * _tv.z - _tu.z * _tv.y;
        _pn.y = _tu.z * _tv.x - _tu.x * _tv.z;
        _pn.z = _tu.x * _tv.y - _tu.y * _tv.x;
        if (_pn.length == 0) return null;
        _dir.x = p1.x - p0.x;
        _dir.y = p1.y - p0.y;
        _dir.z = p1.z - p0.z;
        _orig.x = p0.x - v0.x;
        _orig.y = p0.y - v0.y;
        _orig.z = p0.z - v0.z;
        _npn.x = -_pn.x;
        _npn.y = -_pn.y;
        _npn.z = -_pn.z;
        var a:Float = _npn.x * _orig.x + _npn.y * _orig.y + _npn.z * _orig.z;
        if (a == 0) return null;
        var b:Float = _pn.x * _dir.x + _pn.y * _dir.y + _pn.z * _dir.z;
        var r:Float = a / b;
        if (r < 0 || r > 1) return null;
        var result:Vector3D = outVector3D || new Vector3D(0.0, 0.0, 0.0);
        result.x = p0.x + (_dir.x * r);
        result.y = p0.y + (_dir.y * r);
        result.z = p0.z + (_dir.z * r);
        var uu:Float = _tu.x * _tu.x + _tu.y * _tu.y + _tu.z * _tu.z;
        var uv:Float = _tu.x * _tv.x + _tu.y * _tv.y + _tu.z * _tv.z;
        var vv:Float = _tv.x * _tv.x + _tv.y * _tv.y + _tv.z * _tv.z;
        _w.x = result.x - v0.x;
        _w.y = result.y - v0.y;
        _w.z = result.z - v0.z;
        var wu:Float = _w.x * _tu.x + _w.y * _tu.y + _w.z * _tu.z;
        var wv:Float = _w.x * _tv.x + _w.y * _tv.y + _w.z * _tv.z;
        var d:Float = uv * uv - uu * vv;
        var v:Float = (uv * wv - vv * wu) / d;
        if (v < 0 || v > 1) return null;
        var t:Float = (uv * wu - uu * wv) / d;
        if (t < 0 || (v + t) > 1.0) return null;
        return result;
    }

    private function hasSphereIntersection(pOrig:Vector3D, dir:Vector3D, sPos:Vector3D, radius:Float):Float {
        _pn.x = -dir.x;
        _pn.y = -dir.y;
        _pn.z = -dir.z;
        dir = _pn;
        _a = _pn.x * _pn.x + _pn.y * _pn.y + _pn.z * _pn.z;
        _b = _pn.x * (2 * (pOrig.x - sPos.x)) + _pn.y * (2 * (pOrig.y - sPos.y)) + _pn.z * (2 * (pOrig.z - sPos.z));
        _c = sPos.x * sPos.x + sPos.y * sPos.y + sPos.z * sPos.z;
        _c += pOrig.x * pOrig.x + pOrig.y * pOrig.y + pOrig.z * pOrig.z;
        _c -= 2 * (sPos.x * pOrig.x + sPos.y * pOrig.y + sPos.z * pOrig.z);
        _c -= radius * radius;
        return _b * _b + (-4.0) * _a * _c;
    }

}

