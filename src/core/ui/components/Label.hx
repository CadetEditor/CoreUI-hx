  /**
 * Label.as
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

import core.ui.components.UIComponent;
import nme.text.TextField;
import nme.text.TextFieldAutoSize;
import nme.text.TextFormat;
import nme.text.TextFormatAlign;

class Label extends UIComponent
{
    public var textAlign(get, set) : String;
    public var text(get, set) : String;
    public var fontColor(get, set) : Int;
    public var fontSize(get, set) : Float;
    public var bold(get, set) : Bool;
  
	// Properties  
	
	private var _fontColor : Int;
	private var _fontSize : Float;
	private var _bold : Bool;  
	
	// Child elements  
	
	private var textField : TextField;
	
	public function new()
    {
        super();
    }  
	
	////////////////////////////////////////////////    
	// Protected methods    
	////////////////////////////////////////////////  
	
	override private function init() : Void
	{
		textField = TextStyles.createTextField();
		_fontColor = Int(textField.defaultTextFormat.color);
		_fontSize = Std.parseFloat(textField.defaultTextFormat.size);
		_bold = textField.defaultTextFormat.bold;
		textField.multiline = false;
		textField.wordWrap = false;
		_resizeToContentWidth = true;
		addChild(textField);
    }
	
	override private function validate() : Void
	{
		if (textAlign == TextFormatAlign.LEFT) {
			if (_resizeToContentWidth) { 
				textField.autoSize = TextFieldAutoSize.LEFT;
				_width = Math.max(_width, textField.width);
            } else {
				textField.autoSize = TextFieldAutoSize.NONE;
				textField.width = _width;
            }
        } else if (textAlign == TextFormatAlign.RIGHT) {
			if (_resizeToContentWidth) {
				textField.autoSize = TextFieldAutoSize.RIGHT;
				_width = Math.max(_width, textField.width);
            } else {
				textField.autoSize = TextFieldAutoSize.NONE;
				textField.width = _width;
            }
        } else {
			textField.width = _width;
			textField.autoSize = TextFieldAutoSize.NONE;
        }
		
		textField.height = textField.textHeight + 4;
		_height = textField.height;
    }  
	
	////////////////////////////////////////////////    
	// Getters/Setters    
	////////////////////////////////////////////////  
	
	private function set_TextAlign(value : String) : String
	{
		if (value == textField.defaultTextFormat.align) return;
		var tf : TextFormat = textField.defaultTextFormat;
		tf.align = value;
		textField.defaultTextFormat = tf;
		textField.setTextFormat(tf);
        return value;
    }
	
	private function get_TextAlign() : String
	{
		return textField.defaultTextFormat.align;
    }
	
	private function set_Text(value : String) : String
	{
		textField.text = value;
		invalidate();
        return value;
    }
	
	private function get_Text() : String
	{
		return textField.text;
    }
	
	private function get_FontColor() : Int
	{
		return _fontColor;
    }
	
	private function set_FontColor(value : Int) : Int
	{
		_fontColor = value;
		var tf : TextFormat = textField.defaultTextFormat;
		tf.color = _fontColor;
		textField.defaultTextFormat = tf;
		textField.setTextFormat(tf);
        return value;
    }
	
	private function get_FontSize() : Float
	{
		return _fontSize;
    }
	
	private function set_FontSize(value : Float) : Float
	{
		_fontSize = value;
		var tf : TextFormat = textField.defaultTextFormat;
		tf.size = _fontSize; 
		textField.defaultTextFormat = tf;
		textField.setTextFormat(tf);
        return value;
    }
	
	private function get_Bold() : Bool
	{
		return _bold;
    }
	
	private function set_Bold(value : Bool) : Bool
	{
		_bold = value;
		var tf : TextFormat = textField.defaultTextFormat;
		tf.bold = _bold;
		textField.defaultTextFormat = tf;
		textField.setTextFormat(tf);
        return value;
    }
}