/**
 * ImageParser provides a "parser" for natively supported image types (jpg, png). While it simply loads bytes into
 * a loader object, it wraps it in a BitmapDataResource so resource management can happen consistently without
 * exception cases.
 */
package away3d.loaders.parsers;


import away3d.events.AssetEvent;
import away3d.library.assets.BitmapDataAsset;
import away3d.textures.ATFTexture;
import away3d.textures.BitmapTexture;
import away3d.textures.Texture2DBase;
import away3d.tools.utils.TextureUtils;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Loader;
import flash.events.Event;
import flash.utils.ByteArray;

class ImageParser extends ParserBase {

    private var _byteData:ByteArray;
    private var _startedParsing:Bool;
    private var _doneParsing:Bool;
    private var _loader:Loader;
/**
	 * Creates a new ImageParser object.
	 * @param uri The url or id of the data or file to be parsed.
	 * @param extra The holder for extra contextual data that the parser might need.
	 */

    public function new() {
        super(ParserDataFormat.BINARY);
    }

/**
	 * Indicates whether or not a given file extension is supported by the parser.
	 * @param extension The file extension of a potential file to be parsed.
	 * @return Whether or not the given file type is supported.
	 */

    static public function supportsType(extension:String):Bool {
        extension = extension.toLowerCase();
        return extension == "jpg" || extension == "jpeg" || extension == "png" || extension == "gif" || extension == "bmp" || extension == "atf";
    }

/**
	 * Tests whether a data block can be parsed by the parser.
	 * @param data The data block to potentially be parsed.
	 * @return Whether or not the given data is supported.
	 */

    static public function supportsData(data:Dynamic):Bool {
//shortcut if asset is IFlexAsset
        if (Std.is(data, Bitmap)) return true;
        if (Std.is(data, BitmapData)) return true;
        if (!(Std.is(data, ByteArray))) return false;
        var ba:ByteArray = cast(data, ByteArray) ;
        ba.position = 0;
        if (ba.readUnsignedShort() == 0xffd8) return true;
        ba.position = 0;
        if (ba.readShort() == 0x424D) return true;
        ba.position = 1;
        if (ba.readUTFBytes(3) == "PNG") return true;
        ba.position = 0;
        if (ba.readUTFBytes(3) == "GIF" && ba.readShort() == 0x3839 && ba.readByte() == 0x61) return true;
        ba.position = 0;
        if (ba.readUTFBytes(3) == "ATF") return true;
        return false;
    }

/**
	 * @inheritDoc
	 */

    override private function proceedParsing():Bool {
        var asset:Texture2DBase;
        if (Std.is(_data, Bitmap)) {
            asset = new BitmapTexture(cast((_data), Bitmap).bitmapData);
            finalizeAsset(asset, _fileName);
            return ParserBase.PARSING_DONE;
        }
        if (Std.is(_data, BitmapData)) {
            asset = new BitmapTexture( cast(_data, BitmapData) );
            finalizeAsset(asset, _fileName);
            return ParserBase.PARSING_DONE;
        }
        _byteData = getByteData();
        if (!_startedParsing) {
            _byteData.position = 0;
            if (_byteData.readUTFBytes(3) == "ATF") {
                _byteData.position = 0;
                asset = new ATFTexture(_byteData);
                finalizeAsset(asset, _fileName);
                return ParserBase.PARSING_DONE;
            }

            else {
                _loader = new Loader();
                _loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadComplete);
                _loader.loadBytes(_byteData);
                _startedParsing = true;
            }

        }
        return _doneParsing;
    }

/**
	 * Called when "loading" is complete.
	 */

    private function onLoadComplete(event:Event):Void {
        var bmp:BitmapData = cast((_loader.content), Bitmap).bitmapData;
        var asset:BitmapTexture;
        _loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLoadComplete);
        if (!TextureUtils.isBitmapDataValid(bmp)) {
            var bmdAsset:BitmapDataAsset = new BitmapDataAsset(bmp);
            bmdAsset.name = _fileName;
            dispatchEvent(new AssetEvent(AssetEvent.TEXTURE_SIZE_ERROR, bmdAsset));
            bmp = new BitmapData(8, 8, false, 0x0);
//create chekerboard for this texture rather than a new Default Material
            var i:Int;
            var j:Int;
            i = 0;
            while (i < 8) {
                j = 0;
                while (j < 8) {
                    if ((j & 1) ^ (i & 1) == 1) bmp.setPixel(i, j, 0xFFFFFF);
                    j++;
                }
                i++;
            }
        }
        asset = new BitmapTexture(bmp);
        finalizeAsset(asset, _fileName);
        _doneParsing = true;
    }

}

