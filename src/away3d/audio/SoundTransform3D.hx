/**
 * SoundTransform3D is a convinience class that helps adjust a Soundtransform's volume and pan according
 * position and distance of a listener and emitter object. See SimplePanVolumeDriver for the limitations
 * of this method.
 */
package away3d.audio;

import away3d.containers.ObjectContainer3D;
import flash.geom.Matrix3D;
import flash.geom.Vector3D;
import flash.media.SoundTransform;

class SoundTransform3D {
    public var soundTransform(get_soundTransform, set_soundTransform):SoundTransform;
    public var scale(get_scale, set_scale):Float;
    public var volume(get_volume, set_volume):Float;
    public var emitter(get_emitter, set_emitter):ObjectContainer3D;
    public var listener(get_listener, set_listener):ObjectContainer3D;

    private var _scale:Float;
    private var _volume:Float;
    private var _soundTransform:SoundTransform;
    private var _emitter:ObjectContainer3D;
    private var _listener:ObjectContainer3D;
    private var _refv:Vector3D;
    private var _inv_ref_mtx:Matrix3D;
    private var _r:Float;
    private var _r2:Float;
    private var _azimuth:Float;
/**
	 * Creates a new SoundTransform3D.
	 * @param emitter the ObjectContainer3D from which the sound originates.
	 * @param listener the ObjectContainer3D considered to be to position of the listener (usually, the camera)
	 * @param volume the maximum volume used.
	 * @param scale the distance that the sound covers.
	 *
	 */

    public function new(emitter:ObjectContainer3D = null, listener:ObjectContainer3D = null, volume:Float = 1, scale:Float = 1000) {
        _emitter = emitter;
        _listener = listener;
        _volume = volume;
        _scale = scale;
        _inv_ref_mtx = new Matrix3D();
        _refv = new Vector3D();
        _soundTransform = new SoundTransform(volume);
        _r = 0;
        _r2 = 0;
        _azimuth = 0;
    }

/**
	 * updates the SoundTransform based on the emitter and listener.
	 */

    public function update():Void {
        if (_emitter != null && _listener != null) {
            _inv_ref_mtx.rawData = _listener.sceneTransform.rawData;
            _inv_ref_mtx.invert();
            _refv = _inv_ref_mtx.deltaTransformVector(_listener.position);
            _refv = _emitter.scenePosition.subtract(_refv);
        }
        updateFromVector3D(_refv);
    }

/**
	 * udpates the SoundTransform based on the vector representing the distance and
	 * angle between the emitter and listener.
	 *
	 * @param v Vector3D
	 *
	 */

    public function updateFromVector3D(v:Vector3D):Void {
        _azimuth = Math.atan2(v.x, v.z);
        if (_azimuth < -1.5707963) _azimuth = -(1.5707963 + (_azimuth % 1.5707963))
        else if (_azimuth > 1.5707963) _azimuth = 1.5707963 - (_azimuth % 1.5707963);
        _soundTransform.pan = (_azimuth / 1.7);
// Offset radius so that max value for volume curve is 1,
// (i.e. y~=1 for r=0.) Also scale according to configured
// driver scale value.
        _r = (v.length / _scale) + 0.28209479;
        _r2 = _r * _r;
// Volume is calculated according to the formula for
// sound intensity, I = P / (4 * pi * r^2)
// Avoid division by zero.
        if (_r2 > 0) _soundTransform.volume = (1 / (12.566 * _r2))
        else _soundTransform.volume = 1;
// Alter according to user-specified volume
        _soundTransform.volume *= _volume;
    }

    public function get_soundTransform():SoundTransform {
        return _soundTransform;
    }

    public function set_soundTransform(value:SoundTransform):SoundTransform {
        _soundTransform = value;
        update();
        return value;
    }

    public function get_scale():Float {
        return _scale;
    }

    public function set_scale(value:Float):Float {
        _scale = value;
        update();
        return value;
    }

    public function get_volume():Float {
        return _volume;
    }

    public function set_volume(value:Float):Float {
        _volume = value;
        update();
        return value;
    }

    public function get_emitter():ObjectContainer3D {
        return _emitter;
    }

    public function set_emitter(value:ObjectContainer3D):ObjectContainer3D {
        _emitter = value;
        update();
        return value;
    }

    public function get_listener():ObjectContainer3D {
        return _listener;
    }

    public function set_listener(value:ObjectContainer3D):ObjectContainer3D {
        _listener = value;
        update();
        return value;
    }

}

