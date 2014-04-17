  /**
 * Container.as
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

import core.ui.components.ColorPickerBrightnessCursorSkin;
import core.ui.components.ColorPickerColorCursorSkin;
import core.ui.components.ColorPickerSkin;
import core.ui.components.Matrix;
import core.ui.components.Shape;
import core.ui.components.TextInput;
import core.ui.components.UIComponent;
import nme.display.BlendMode;
import nme.display.GradientType;
import nme.display.Shape;
import nme.display.Sprite;
import nme.events.Event;
import nme.events.MouseEvent;
import nme.geom.Matrix;
import nme.text.TextField;
import nme.text.TextFieldAutoSize;
import core.ui.CoreUI;
import core.ui.util.Scale9GridUtil;
import flux.skins.ColorPickerBrightnessCursorSkin;
import flux.skins.ColorPickerColorCursorSkin;
import flux.skins.ColorPickerSkin;

class ColorPicker extends UIComponent
{
    public var showBorder(get, set) : Bool;
    public var color(get, set) : Int;
    public var padding(get, set) : Int;
    public var innerPadding(get, set) : Int;
    public var brightnessSliderWidth(get, set) : Int;
    public var gap(get, set) : Int;
	
	// Styles  
	
	public static var stylePadding : Int = 4;
	public static var styleInnerPadding : Int = 2;
	public static var styleBrightnessSliderWidth : Int = 20;
	public static var styleGap : Int = 4;  
	
	// Properties  
	
	private var _color : Int;
	private var _padding : Int = stylePadding;
	private var _innerPadding : Int = styleInnerPadding;
	private var _brightnessSliderWidth : Int = styleBrightnessSliderWidth;
	private var _gap : Int = styleGap;  
	
	// Child elements  
	
	private var border : Sprite;
	private var hueSaturationBorder : Sprite;
	private var hueSaturationGradient : Shape;
	private var brightnessBorder : Sprite;
	private var brightnessGradient : Shape;
	private var colorCursor : Sprite;
	private var brightnessCursor : Sprite;
	private var swatchBorder : Sprite;
	private var swatch : Shape;
	private var inputField : TextInput;
	private var hexLabel : TextField;  
	
	// Internal vars  
	
	private var m : Matrix;
	private var selectedHue : Float;
	private var selectedSaturation : Float;
	private var selectedBrightness : Float;
	
	public function new()
    {
        super();
    }  
	
	////////////////////////////////////////////////    
	// Protected methods    
	////////////////////////////////////////////////  
	
	override private function init() : Void
	{
		focusEnabled = true;
		border = new ColorPickerSkin();
		
		if (!border.scale9Grid) {
			Scale9GridUtil.setScale9Grid(border, CoreUI.defaultColorPickerSkinScale9Grid);
        }
		
		addChild(border);
		_width = border.width;
		_height = border.height;
		hueSaturationBorder = new ColorPickerSkin();
		
		if (!hueSaturationBorder.scale9Grid) {
			Scale9GridUtil.setScale9Grid(hueSaturationBorder, CoreUI.defaultColorPickerSkinScale9Grid);
        }
		
		addChild(hueSaturationBorder);
		hueSaturationGradient = new Shape();
		addChild(hueSaturationGradient);
		brightnessBorder = new ColorPickerSkin();
		
		if (!brightnessBorder.scale9Grid) {
			Scale9GridUtil.setScale9Grid(brightnessBorder, CoreUI.defaultColorPickerSkinScale9Grid);
        }
		
		addChild(brightnessBorder);
		brightnessGradient = new Shape();
		addChild(brightnessGradient);
		colorCursor = new ColorPickerColorCursorSkin();
		colorCursor.blendMode = BlendMode.DIFFERENCE;
		addChild(colorCursor);
		brightnessCursor = new ColorPickerBrightnessCursorSkin();
		brightnessCursor.blendMode = BlendMode.DIFFERENCE;
		addChild(brightnessCursor);
		var colours : Array<Dynamic> = [];
		var ratios : Array<Dynamic> = [];
		var alphas : Array<Dynamic> = [];
		var numSteps : Int = 16;
		
		for (i in 0...numSteps) {
			var ratio : Float = i / (numSteps - 1);
			var rgb : Int = hsl2rgb(ratio, 1, 0.5);
			colours[i] = rgb;
			ratios[i] = ratio * 255;
			alphas[i] = 1;
        }
		
		m = new Matrix();
		m.createGradientBox(100, 100);
		hueSaturationGradient.graphics.beginGradientFill(GradientType.LINEAR, colours, alphas, ratios, m);
		hueSaturationGradient.graphics.drawRect(0, 0, 100, 100);
		m.createGradientBox(100, 100, Math.PI * 0.5);
		colours = [0x999999, 0x999999];
		ratios = [0, 255];
		alphas = [0, 1];
		hueSaturationGradient.graphics.beginGradientFill(GradientType.LINEAR, colours, alphas, ratios, m);
		hueSaturationGradient.graphics.drawRect(0, 0, 100, 100);
		hueSaturationBorder.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownColorAreaHandler);
		brightnessBorder.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownBrightnessAreaHandler);
		inputField = new TextInput();
		inputField.maxChars = 6;
		inputField.width = 60;
		inputField.addEventListener(Event.CHANGE, changeInputFieldHandler);
		inputField.focusEnabled = true;
		addChild(inputField);
		hexLabel = TextStyles.createTextField();
		hexLabel.text = "#";
		hexLabel.autoSize = TextFieldAutoSize.LEFT; addChild(hexLabel);
		swatchBorder = new ColorPickerSkin();
		
		if (!swatchBorder.scale9Grid) {
			Scale9GridUtil.setScale9Grid(swatchBorder, CoreUI.defaultColorPickerSkinScale9Grid);
        }
		
		swatchBorder.height = inputField.height;
		addChild(swatchBorder);
		swatch = new Shape();
		addChild(swatch);
		color = 0xFF0000;
		updateInputField();
    }
	
	override private function validate() : Void
	{
		border.width = _width;
		border.height = _height;
		hueSaturationBorder.x = hueSaturationBorder.y = _padding; hueSaturationBorder.width = _width - ((_padding << 1) + gap + _brightnessSliderWidth);
		hueSaturationBorder.height = _height - ((_padding << 1) + inputField.height + _gap);
		hueSaturationGradient.x = hueSaturationGradient.y = _padding + _innerPadding;
		hueSaturationGradient.width = hueSaturationBorder.width - (_innerPadding * 2); 
		hueSaturationGradient.height = hueSaturationBorder.height - (_innerPadding * 2);
		brightnessBorder.x = hueSaturationBorder.x + hueSaturationBorder.width + _gap;
		brightnessBorder.y = hueSaturationBorder.y;
		brightnessBorder.width = _width - (brightnessBorder.x + _padding);
		brightnessBorder.height = hueSaturationBorder.height;
		brightnessGradient.x = brightnessBorder.x + _innerPadding;
		brightnessGradient.y = brightnessBorder.y + _innerPadding;
		var w : Int = brightnessBorder.width - _innerPadding * 2;
		var h : Int = brightnessBorder.height - _innerPadding * 2;
		m.createGradientBox(w, h, Math.PI * 0.5);
		var ratios : Array<Dynamic> = [0, 128, 255];
		var selectedColor : Int = hsl2rgb(selectedHue, selectedSaturation, 0.5);
		var colors : Array<Dynamic> = [0xFFFFFF, selectedColor, 0x000000];
		var alphas : Array<Dynamic> = [1, 1, 1]; 
		brightnessGradient.graphics.clear();
		brightnessGradient.graphics.beginGradientFill(GradientType.LINEAR, colors, alphas, ratios, m);
		brightnessGradient.graphics.drawRect(0, 0, w, h);
		colorCursor.x = as3hx.Compat.parseInt(hueSaturationGradient.x + selectedHue * hueSaturationGradient.width);
		colorCursor.y = as3hx.Compat.parseInt(hueSaturationGradient.y + (1 - selectedSaturation) * hueSaturationGradient.height);
		brightnessCursor.x = brightnessGradient.x; brightnessCursor.width = brightnessGradient.width; brightnessCursor.y = brightnessGradient.y + (1 - selectedBrightness) * brightnessGradient.height;
		inputField.x = _width - _padding - inputField.width; inputField.y = brightnessBorder.y + brightnessBorder.height + _gap;
		hexLabel.x = inputField.x - hexLabel.width;
		hexLabel.y = inputField.y + ((inputField.height - hexLabel.height) >> 1);
		swatchBorder.x = _padding;
		swatchBorder.y = inputField.y;
		swatchBorder.width = hexLabel.x - _padding * 2;
		swatch.x = swatchBorder.x + _innerPadding;
		swatch.y = swatchBorder.y + _innerPadding;
		swatch.graphics.clear();
		swatch.graphics.beginFill(_color);
		swatch.graphics.drawRect(0, 0, swatchBorder.width - _innerPadding * 2, swatchBorder.height - _innerPadding * 2);
    }
	
	private function updateInputField() : Void
	{
		var str : String = Std.string(_color).toUpperCase();
		
		while (str.length < 6) {
			str = "0" + str;
        }
		
		inputField.text = str;
    }  
	
	////////////////////////////////////////////////    
	// Event handlers    
	////////////////////////////////////////////////  
	private function mouseDownColorAreaHandler(event : MouseEvent) : Void 
	{ 
		stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpColorAreaHandler);
		stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveColorAreaHandler);
		mouseMoveColorAreaHandler(null);
    }
	
	private function mouseMoveColorAreaHandler(event : MouseEvent) : Void
	{
		var xRatio : Float = hueSaturationGradient.mouseX / hueSaturationGradient.width * hueSaturationGradient.scaleX;
		var yRatio : Float = hueSaturationGradient.mouseY / hueSaturationGradient.height * hueSaturationGradient.scaleY;
		xRatio = xRatio < (0) ? 0 : xRatio > (1) ? 1 : xRatio;yRatio = yRatio < (0) ? 0 : yRatio > (1) ? 1 : yRatio;
		selectedHue = xRatio;
		selectedSaturation = 1 - yRatio; 
		_color = hsl2rgb(selectedHue, selectedSaturation, selectedBrightness);
		inputField.removeEventListener(Event.CHANGE, changeInputFieldHandler);
		updateInputField();
		inputField.addEventListener(Event.CHANGE, changeInputFieldHandler);
		invalidate();dispatchEvent(new Event(Event.CHANGE));
    }
	
	private function mouseUpColorAreaHandler(event : MouseEvent) : Void
	{
		stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveColorAreaHandler);
		stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpColorAreaHandler);
    }
	
	private function mouseDownBrightnessAreaHandler(event : MouseEvent) : Void
	{
		stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpBrightnessAreaHandler);
		stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveBrightnessAreaHandler);
		mouseMoveBrightnessAreaHandler(null);
    }
	
	private function mouseMoveBrightnessAreaHandler(event : MouseEvent) : Void
	{
		var yRatio : Float = brightnessGradient.mouseY / brightnessGradient.height * brightnessGradient.scaleY; yRatio = yRatio < (0) ? 0 : yRatio > (1) ? 1 : yRatio;selectedBrightness = 1 - yRatio;
		_color = hsl2rgb(selectedHue, selectedSaturation, selectedBrightness);
		inputField.removeEventListener(Event.CHANGE, changeInputFieldHandler);
		updateInputField();
		inputField.addEventListener(Event.CHANGE, changeInputFieldHandler);
		invalidate();
		dispatchEvent(new Event(Event.CHANGE));
    }
	
	private function mouseUpBrightnessAreaHandler(event : MouseEvent) : Void
	{
		stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveBrightnessAreaHandler);
		stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpBrightnessAreaHandler);
    }
	
	private function changeInputFieldHandler(event : Event) : Void
	{
		color = Int("0x" + inputField.text);
		dispatchEvent(new Event(Event.CHANGE));
    }  
	
	////////////////////////////////////////////////    
	// Getters/Setters    
	////////////////////////////////////////////////  
	
	private function set_ShowBorder(value : Bool) : Bool
	{
		border.visible = value;
        return value;
    }
	
	private function get_ShowBorder() : Bool
	{
		return border.visible;
    }
	
	private function set_Color(value : Int) : Int
	{
		if (value == _color) return;
		_color = value;
		var hsl : Array<Dynamic> = rgb2hsl(_color); 
		selectedHue = hsl[0];
		selectedSaturation = hsl[1];
		selectedBrightness = hsl[2];
		updateInputField();
		invalidate();
        return value;
    }
	
	private function get_Color() : Int
	{
		return _color;
    }
	
	private function set_Padding(value : Int) : Int
	{
		if (_padding == value) return;
		_padding = value;
		invalidate();
        return value;
    }
	
	private function get_Padding() : Int
	{
		return _padding;
    }
	
	private function set_InnerPadding(value : Int) : Int
	{
		if (_innerPadding == value) return;
		_innerPadding = value;
		invalidate();
        return value;
    }
	
	private function get_InnerPadding() : Int
	{
		return _innerPadding;
    }
	
	private function set_BrightnessSliderWidth(value : Int) : Int
	{
		if (_brightnessSliderWidth == value) return;
		_brightnessSliderWidth = value;
		invalidate();
        return value;
    }
	
	private function get_BrightnessSliderWidth() : Int
	{
		return _brightnessSliderWidth;
    }
	
	private function set_Gap(value : Int) : Int
	{
		if (_gap == value) return;
		_gap = value;
		invalidate();
        return value;
    }
	
	private function get_Gap() : Int
	{
		return _gap;
    }  
	
	////////////////////////////////////////////////    
	// Private static methods    
	////////////////////////////////////////////////  
	
	private static function hsl2rgb(H : Float, S : Float, L : Float) : Int
	{
		var r : Int;
        var g : Int;
        var b : Int;
		
		if (S == 0) {
			r = L * 255;
			g = L * 255;
			b = L * 255;
        } else {
			var v2 : Float = L < (0.5) ? L * (1 + S) : (L + S) - (S * L);
			var v1 : Float = 2 * L - v2;
			r = 255 * hue2rgb(v1, v2, H + (1 / 3));
			g = 255 * hue2rgb(v1, v2, H);
			b = 255 * hue2rgb(v1, v2, H - (1 / 3));
        }
		
		return (r << 16) | (g << 8) | b;
    }
	
	private static function hue2rgb(v1 : Float, v2 : Float, vH : Float) : Float
	{
		if (vH < 0) vH += 1;
		if (vH > 1) vH -= 1;
		if ((6 * vH) < 1) return (v1 + (v2 - v1) * 6 * vH);
		if ((2 * vH) < 1) return (v2);
		if ((3 * vH) < 2) return (v1 + (v2 - v1) * ((2 / 3) - vH) * 6);
		return v1;
    }
	
	private static function rgb2hsl(rgb : Int) : Array<Dynamic>
	{
		var r : Float = ((rgb & 0xFF0000) >> 16) / 255;
		var g : Float = ((rgb & 0x00FF00) >> 8) / 255;
		var b : Float = (rgb & 0x0000FF) / 255;
		var min : Float = Math.min(r, g, b);
		var max : Float = Math.max(r, g, b);
		var delta : Float = max - min;
		var H : Float; 
		var S : Float;
		var L : Float = (max + min) / 2;
		if (delta == 0) {
			H = 0;S = 1;
        } else {
			S = L < (0.5) ? delta / (max + min) : delta / (2 - max - min);
			var deltaR : Float = (((max - r) / 6) + (delta / 2)) / delta;
			var deltaG : Float = (((max - g) / 6) + (delta / 2)) / delta;
			var deltaB : Float = (((max - b) / 6) + (delta / 2)) / delta;
			if (r == max) H = deltaB - deltaG
            else if (g == max) H = (1 / 3) + deltaR - deltaB
            else if (b == max) H = (2 / 3) + deltaG - deltaR;
			H = H < (0) ? H + 1 : H;
			H = H > (1) ? H - 1 : H;
        }
		return [H, S, L];
    }
}