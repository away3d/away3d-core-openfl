package away3d.tools.utils;

import flash.Vector;
import flash.display.BitmapData;
import flash.events.Event;
import flash.events.EventDispatcher;

class ColorHitMap extends EventDispatcher {
    public var offsetX(get_offsetX, set_offsetX):Float;
    public var offsetY(get_offsetY, set_offsetY):Float;
    public var scaleX(get_scaleX, set_scaleX):Float;
    public var scaleY(get_scaleY, set_scaleY):Float;
    public var bitmapData(get_bitmapData, set_bitmapData):BitmapData;

    private var _colorMap:BitmapData;
    private var _colorObjects:Vector<ColorObject>;
    private var _scaleX:Float;
    private var _scaleY:Float;
    private var _offsetX:Float;
    private var _offsetY:Float;
/**
	 * Creates a new <code>ColorHitMap</code>
	 *
	 * @param    bitmapData        The bitmapdata with color regions to act as trigger.
	 * @param    scaleX                [optional]    A factor scale along the X axis. Default is 1.
	 * @param    scaleY                [optional]    A factor scale along the Y axis. Default is 1.
	 *
	 * Note that by default the class is considered as centered, like a plane at 0,0,0.
	 * Also by default coordinates offset are set. If a map of 256x256 is set, and no custom offsets are set.
	 * The read method using the camera position -128 x and -128 z would return the color value found at 0,0 on the map.
	 */

    public function new(bitmapData:BitmapData, scaleX:Float = 1, scaleY:Float = 1) {
        _colorMap = bitmapData;
        _scaleX = scaleX;
        _scaleY = scaleY;
        _offsetX = _colorMap.width * .5;
        _offsetY = _colorMap.height * .5;
    }

/**
	 * If at the given coordinates a color is found that matches a defined color event, the color event will be triggered.
	 *
	 * @param    x            X coordinate on the source bmd
	 * @param    y            Y coordinate on the source bmd
	 */

    public function read(x:Float, y:Float):Void {
        if (!_colorObjects) return;
        var color:Int = _colorMap.getPixel((x / _scaleX) + _offsetX, (y / _scaleY) + _offsetY);
        var co:ColorObject;
        var i:Int = 0;
        while (i < _colorObjects.length) {
            co = cast((_colorObjects[i]), ColorObject);
            if (co.color == color) {
                fireColorEvent(co.eventID);
                break;
            }
            ++i;
        }
    }

/**
	 * returns the color at x,y coordinates.
	 * This method is made to test if the color is indeed the expected one, (the one you set for an event), as due to compression
	 * for instance using the Flash IDE library, compression might have altered the color values.
	 *
	 * @param    x            X coordinate on the source bitmapData
	 * @param    y            Y coordinate on the source bitmapData
	 *
	 * @return        A uint, the color value at coordinates x, y
	 * @see        plotAt
	 */

    public function getColorAt(x:Float, y:Float):Int {
        return _colorMap.getPixel((x / _scaleX) + _offsetX, (y / _scaleY) + _offsetY);
    }

/**
	 * Another method for debug, if you addChild your bitmapdata on screen, this method will colour a pixel at the coordinates
	 * helping you to visualize if your scale factors or entered coordinates are correct.
	 * @param    x            X coordinate on the source bitmapData
	 * @param    y            Y coordinate on the source bitmapData
	 */

    public function plotAt(x:Float, y:Float, color:Int = 0xFF0000):Void {
        _colorMap.setPixel((x / _scaleX) + _offsetX, (y / _scaleY) + _offsetY, color);
    }

/**
	 * Defines a color event for this class.
	 * If read method is called, and the target pixel color has the same value as a previously set listener, an event is triggered.
	 *
	 * @param    color            A color Number
	 * @param    eventID        A string to identify that event
	 * @param    listener        The function  that must be triggered
	 */

    public function addColorEvent(color:Float, eventID:String, listener:Dynamic -> Void):Void {
        if (!_colorObjects) _colorObjects = new Vector<ColorObject>();
        var colorObject:ColorObject = new ColorObject();
        colorObject.color = color;
        colorObject.eventID = eventID;
        colorObject.listener = listener;
        _colorObjects.push(colorObject);
        addEventListener(eventID, listener, false, 0, false);
    }

/**
	 * removes a color event by its id
	 *
	 * @param  eventID  The Event id
	 */

    public function removeColorEvent(eventID:String):Void {
        if (!_colorObjects) return;
        var co:ColorObject;
        var i:Int = 0;
        while (i < _colorObjects.length) {
            co = cast((_colorObjects[i]), ColorObject);
            if (co.eventID == eventID) {
                if (hasEventListener(eventID)) removeEventListener(eventID, co.listener);
                _colorObjects.splice(i, 1);
                break;
            }
            ++i;
        }
    }

/**
	 * The offsetX, offsetY
	 * by default offsetX and offsetY represent the center of the map.
	 */

    public function set_offsetX(value:Float):Float {
        _offsetX = value;
        return value;
    }

    public function set_offsetY(value:Float):Float {
        _offsetY = value;
        return value;
    }

    public function get_offsetX():Float {
        return _offsetX;
    }

    public function get_offsetY():Float {
        return _offsetY;
    }

/**
	 * defines the  scaleX and scaleY. Defines the ratio map to the 3d world
	 */

    public function set_scaleX(value:Float):Float {
        _scaleX = value;
        return value;
    }

    public function set_scaleY(value:Float):Float {
        _scaleY = value;
        return value;
    }

    public function get_scaleX():Float {
        return _scaleX;
    }

    public function get_scaleY():Float {
        return _scaleY;
    }

/**
	 * The source bitmapdata uses for colour readings
	 */

    public function set_bitmapData(map:BitmapData):BitmapData {
        _colorMap = map;
        _offsetX = _colorMap.width * .5;
        _offsetY = _colorMap.height * .5;
        return map;
    }

    public function get_bitmapData():BitmapData {
        return _colorMap;
    }

    private function fireColorEvent(eventID:String):Void {
        dispatchEvent(new Event(eventID));
    }

}

class ColorObject {

    public var color:Int;
    public var eventID:String;
    public var listener:Dynamic -> Void;
}

