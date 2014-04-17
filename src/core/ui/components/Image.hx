  /**
 * Icon.as
 *
 * Copyright (c) 2011 Jonathan Pace
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */  
  
package core.ui.components;

import core.ui.components.Bitmap;
import core.ui.components.ImgClass;
import core.ui.components.Source;
import core.ui.components.UIComponent;
import nme.errors.Error;
import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.display.DisplayObject;
import nme.geom.Rectangle;
import core.ui.events.ResizeEvent;

class Image extends UIComponent
{
    public var source(get, set) : Dynamic;
    public var scaleMode(get, set) : String;
    public var maxScale(get, set) : Float;
    public var minScale(get, set) : Float;
  
	// Scale modes  
	
	public static inline var SCALE_MODE_ORIGINAL : String = "original";
	public static inline var SCALE_MODE_FIT : String = "fit";
	public static inline var SCALE_MODE_FILL : String = "fill";
	public static inline var SCALE_MODE_STRETCH : String = "stretch";  
	
	// Properties  
	
	private var _source : Dynamic;
	private var _scaleMode : String = SCALE_MODE_ORIGINAL;
	private var _maxScale : Float = 1;
	private var _minScale : Float = 0;  
	
	// Child elements  
	
	private var child : DisplayObject;
	
	public function new()
    {
        super();
    }
	
	override private function validate() : Void
	{
		if (child != null) {
			removeChild(child);
			child = null;
        }
		
		if (_source == null) {
			_width = 0;
			_height = 0;
			return;
        }
		
		if (Std.is(_source, DisplayObject)) {
			child = cast((_source), DisplayObject);
        } else if (Std.is(_source, BitmapData)) {
			child = new Bitmap(cast((_source), BitmapData), "auto", true);
        } else {
			try {
				var instance : Dynamic = new Source();
				if (Std.is(instance, DisplayObject)) {
					child = cast((instance), DisplayObject);
                } else if (Std.is(instance, BitmapData)) {
					child = new Bitmap(cast((instance), BitmapData));
                }
            } catch (e : Error){  
				//return;  
            }  
			
			// if the source has been passed in via the MXML flavoured XML.  
			
			if (child == null && Std.is(_source, String)) {
				var imgClass : Class<Dynamic>;
				if (_source.indexOf("::")) {
					var arr : Array<Dynamic> = _source.split("::");
					var icons : Class<Dynamic> = Type.getClass(Type.resolveClass(arr[0]));
					imgClass = Reflect.field(icons, Std.string(arr[1]));
                } else {
					imgClass = Type.getClass(Type.resolveClass(Std.string(_source)));
                } if (imgClass != null) {
					child = Type.createInstance(imgClass, []);
                }
            } if (child == null) return;
        }
		
		addChild(child);
		child.scaleX = child.scaleY = 1;
		child.scrollRect = null;

        switch (_scaleMode)
        {
			case SCALE_MODE_ORIGINAL:
				_width = child.width;
				_height = child.height;
			case SCALE_MODE_STRETCH:
				child.width = _width;
				child.height = _height;
			case SCALE_MODE_FIT:
				var minRatio : Float = Math.min(_width / child.width, _height / child.height);
				minRatio = minRatio < (_minScale != 0) ? _minScale : minRatio > (_maxScale != 0) ? _maxScale : minRatio;
				child.width *= minRatio;child.height *= minRatio;
				child.x = (_width - child.width) * 0.5;child.y = (_height - child.height) * 0.5;
			case SCALE_MODE_FILL:
				var maxRatio : Float = Math.max(_width / child.width, _height / child.height);
				maxRatio = maxRatio < (_minScale != 0) ? _minScale : maxRatio > (_maxScale != 0) ? _maxScale : maxRatio;
				child.width *= maxRatio;
				child.height *= maxRatio;  
				//child.x = (_width - child.width) * 0.5;    
				//child.y = (_height - child.height) * 0.5;    
				//minRatio = Math.min( _width / child.width, _height / child.height );  
				child.scrollRect = new Rectangle((_width - child.width) * 0.5, (_height - child.height) * 0.5, _width * (1 / maxRatio), _height * (1 / maxRatio));
        }
		
		dispatchEvent(new ResizeEvent(ResizeEvent.RESIZE));
    }
	
	private function set_Source(value : Dynamic) : Dynamic
	{
		if (value == _source) return;
		_source = value;
		invalidate();
        return value;
    }
	
	private function get_Source() : Dynamic
	{
		return _source;
    }
	
	private function get_ScaleMode() : String
	{
		return _scaleMode;
    }
	
	private function set_ScaleMode(value : String) : String
	{
		if (value == _scaleMode) return;
		invalidate();
		_scaleMode = value;
        return value;
    }
	
	private function get_MaxScale() : Float
	{
		return _maxScale;
    }
	
	private function set_MaxScale(value : Float) : Float
	{
		if (_maxScale == value) return;
		invalidate();
		_maxScale = value;
        return value;
    }
	
	private function get_MinScale() : Float
	{
		return _minScale;
    }
	
	private function set_MinScale(value : Float) : Float
	{
		if (_minScale == value) return;
		invalidate();
		_minScale = value;
        return value;
    }
}