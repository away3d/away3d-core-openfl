package away3d.materials.utils;

import String;
import flash.display.Sprite;
import flash.events.AsyncErrorEvent;
import flash.events.IOErrorEvent;
import flash.events.NetStatusEvent;
import flash.events.SecurityErrorEvent;
import flash.media.SoundTransform;
import flash.media.Video;
import flash.net.NetConnection;
import flash.net.NetStream;

class SimpleVideoPlayer implements IVideoPlayer {
    public var source(get_source, set_source):String;
    public var loop(get_loop, set_loop):Bool;
    public var volume(get_volume, set_volume):Float;
    public var pan(get_pan, set_pan):Float;
    public var mute(get_mute, set_mute):Bool;
    public var soundTransform(get_soundTransform, set_soundTransform):SoundTransform;
    public var width(get_width, set_width):Int;
    public var height(get_height, set_height):Int;
    public var container(get_container, never):Sprite;
    public var time(get_time, never):Float;
    public var playing(get_playing, never):Bool;
    public var paused(get_paused, never):Bool;

    private var _src:String;
    private var _video:Video;
    private var _ns:NetStream;
    private var _nc:NetConnection;
    private var _nsClient:Dynamic;
    private var _soundTransform:SoundTransform;
    private var _loop:Bool;
    private var _playing:Bool;
    private var _paused:Bool;
    private var _lastVolume:Float;
    private var _container:Sprite;

    public function new() {
// default values
        _soundTransform = new SoundTransform();
        _loop = false;
        _playing = false;
        _paused = false;
        _lastVolume = 1;
// client object that'll redirect various calls from the video stream
        _nsClient = {"onCuePoint":metaDataHandler,
        "onMetaData":metaDataHandler,
        "onBWDone":onBWDone,
        "close":streamClose};
// NetConnection
        _nc = new NetConnection();
        _nc.client = _nsClient;
        _nc.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler, false, 0, true);
        _nc.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler, false, 0, true);
        _nc.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler, false, 0, true);
        _nc.addEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandler, false, 0, true);
        _nc.connect(null);
// NetStream
        _ns = new NetStream(_nc);
        _ns.checkPolicyFile = true;
        _ns.client = _nsClient;
        _ns.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler, false, 0, true);
        _ns.addEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandler, false, 0, true);
        _ns.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler, false, 0, true);
// video
        _video = new Video();
        _video.attachNetStream(_ns);
// container
        _container = new Sprite();
        _container.addChild(_video);
    }

//////////////////////////////////////////////////////
// public methods
//////////////////////////////////////////////////////

    public function play():Void {
        if (_src == null) {
            trace("Video source not set.");
            return;
        }
        if (_paused) {
            _ns.resume();
            _paused = false;
            _playing = true;
        }

        else if (!_playing) {
            _ns.play(_src);
            _playing = true;
            _paused = false;
        }
    }

    public function pause():Void {
        if (!_paused) {
            _ns.pause();
            _paused = true;
        }
    }

    public function seek(val:Float):Void {
        pause();
        _ns.seek(val);
        _ns.resume();
    }

    public function stop():Void {
        _ns.close();
        _playing = false;
        _paused = false;
    }

    public function dispose():Void {
        _ns.close();
        _video.attachNetStream(null);
        _ns.removeEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
        _ns.removeEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandler);
        _ns.removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
        _nc.removeEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
        _nc.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
        _nc.removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
        _nc.removeEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandler);

        _container.removeChild(_video);
        _container = null;
        _src = null;
        _ns = null;
        _nc = null;
        _nsClient = null;
        _video = null;
        _soundTransform = null;
        _playing = false;
        _paused = false;
    }

//////////////////////////////////////////////////////
// event handlers
//////////////////////////////////////////////////////

    private function asyncErrorHandler(event:AsyncErrorEvent):Void {
// Must be present to prevent errors, but won't do anything
    }

    private function metaDataHandler(oData:Dynamic = null):Void {
// Offers info such as oData.duration, oData.width, oData.height, oData.framerate and more (if encoded into the FLV)
//this.dispatchEvent( new VideoEvent(VideoEvent.METADATA,_netStream,file,oData) );
    }

    private function ioErrorHandler(e:IOErrorEvent):Void {
        trace("An IOerror occured: " + e.text);
    }

    private function securityErrorHandler(e:SecurityErrorEvent):Void {
        trace("A security error occured: " + e.text + " Remember that the FLV must be in the same security sandbox as your SWF.");
    }

    private function onBWDone():Void {
// Must be present to prevent errors for RTMP, but won't do anything
    }

    private function streamClose():Void {
        trace("The stream was closed. Incorrect URL?");
    }

    private function netStatusHandler(e:NetStatusEvent):Void {

        var _sw0_:String = Reflect.field(e.info, "code");
        switch(_sw0_) {
            case "NetStream.Play.Stop":
//this.dispatchEvent( new VideoEvent(VideoEvent.STOP,_netStream, file) );
                if (loop) _ns.play(_src);
            case "NetStream.Play.Play":
//this.dispatchEvent( new VideoEvent(VideoEvent.PLAY,_netStream, file) );
            case "NetStream.Play.StreamNotFound":
                trace("The file " + _src + " was not found", e);
            case "NetConnection.Connect.Success":
                trace("Connected to stream", e);
        }
    }

//////////////////////////////////////////////////////
// get / set functions
//////////////////////////////////////////////////////

    public function get_source():String {
        return _src;
    }

    public function set_source(src:String):String {
        _src = src;
        if (_playing) _ns.play(_src);
        return src;
    }

    public function get_loop():Bool {
        return _loop;
    }

    public function set_loop(val:Bool):Bool {
        _loop = val;
        return val;
    }

    public function get_volume():Float {
        return _ns.soundTransform.volume;
    }

    public function set_volume(val:Float):Float {
        _soundTransform.volume = val;
        _ns.soundTransform = _soundTransform;
        _lastVolume = val;
        return val;
    }

    public function get_pan():Float {
        return _ns.soundTransform.pan;
    }

    public function set_pan(val:Float):Float {
        _soundTransform.pan = pan;
        _ns.soundTransform = _soundTransform;
        return val;
    }

    public function get_mute():Bool {
        return _ns.soundTransform.volume == 0;
    }

    public function set_mute(val:Bool):Bool {
        _soundTransform.volume = ((val)) ? 0 : _lastVolume;
        _ns.soundTransform = _soundTransform;
        return val;
    }

    public function get_soundTransform():SoundTransform {
        return _ns.soundTransform;
    }

    public function set_soundTransform(val:SoundTransform):SoundTransform {
        _ns.soundTransform = val;
        return val;
    }

    public function get_width():Int {
        return Std.int(_video.width);
    }

    public function set_width(val:Int):Int {
        _video.width = val;
        return val;
    }

    public function get_height():Int {
        return Std.int(_video.height);
    }

    public function set_height(val:Int):Int {
        _video.height = val;
        return val;
    }

//////////////////////////////////////////////////////
// read-only vars
//////////////////////////////////////////////////////

    public function get_container():Sprite {
        return _container;
    }

    public function get_time():Float {
        return _ns.time;
    }

    public function get_playing():Bool {
        return _playing;
    }

    public function get_paused():Bool {
        return _paused;
    }

}

