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
import flash.display.Sprite;
import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.TextEvent;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFieldType;
import flash.text.TextFormat;
import core.ui.CoreUI;
import core.ui.events.ItemEditorEvent;
import core.ui.managers.FocusManager;
import core.ui.util.Scale9GridUtil;
import core.ui.util.SelectionColor;

class TextArea extends UIComponent
{
    public var text(get, set) : String;
    public var textAlign(get, set) : String;
    public var fontColor(get, set) : Int;
    public var embedFonts(get, set) : Bool;
    public var fontFamily(get, set) : String;
    public var fontSize(get, set) : Float;
    public var bold(get, set) : Bool;
    public var editable(get, set) : Bool;
    public var multiline(get, set) : Bool;
    public var showBorder(get, set) : Bool;
    public var padding(get, set) : Int;
    public var restrict(get, set) : String;
    public var maxChars(get, set) : Int;
  
	// Properties  
	
	private var _padding : Int = 2;
	private var _editable : Bool = false;  
	
	// Child elements  
	
	private var border : Sprite;
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
		border = new TextAreaSkin();
		
		if (!border.scale9Grid) {
			Scale9GridUtil.setScale9Grid(border, CoreUI.defaultTextAreaSkinScale9Grid);
        }
		
		addChild(border);
		_width = border.width;
		_height = border.height;
		textField = TextStyles.createTextField();
		textField.wordWrap = true;
		textField.addEventListener(FocusEvent.FOCUS_IN, textFieldFocusInHandler);
		textField.addEventListener(Event.CHANGE, textFieldChangeHandler);
		textField.addEventListener(FocusEvent.KEY_FOCUS_CHANGE, textKeyFocusChangeHandler);
		multiline = true;  
		//SelectionColor.setFieldSelectionColor(textField, 0xFFFFFF);//0xCCCCCC);  
		addChild(textField);
    }
	
	override private function validate() : Void
	{
		textField.x = textField.y = _padding;
		textField.width = _width - _padding * 2;
		
		if (_resizeToContentHeight) {
			textField.autoSize = TextFieldAutoSize.LEFT;
			_height = textField.height + _padding * 2;
        } else {
			textField.autoSize = TextFieldAutoSize.NONE;
			textField.height = _height - _padding * 2;
        }
		
		border.width = _width;
		border.height = _height;
    }
	
	private function commitValue() : Void
	{
		dispatchEvent(new ItemEditorEvent(ItemEditorEvent.COMMIT_VALUE, text, "text"));
    }
	
	override public function onGainComponentFocus() : Void
	{
		if (!_editable) return;
		stage.focus = textField;
    }
	
	override public function onLoseComponentFocus() : Void
	{
		commitValue();
    }  
	
	////////////////////////////////////////////////    
	// Event handlers    
	////////////////////////////////////////////////  
	
	private function textKeyFocusChangeHandler(e : FocusEvent) : Void
	{
		e.preventDefault(); 
		textField.replaceText(textField.caretIndex, textField.caretIndex, "\t");
		textField.setSelection(textField.caretIndex + 1, textField.caretIndex + 1);
    }
	
	private function textFieldFocusInHandler(event : FocusEvent) : Void
	{
		FocusManager.setFocus(this);
    }
	
	private function textFieldChangeHandler(event : Event) : Void
	{
		event.stopImmediatePropagation();
		dispatchEvent(new Event(Event.CHANGE));
    }  
	
	////////////////////////////////////////////////    
	// Getters/Setters    
	////////////////////////////////////////////////  
	
	private function set_Text(value : String) : String
	{
		textField.text = Std.string(value == (null) ? "" : value);
        return value;
    }
	
	private function get_Text() : String
	{
		return textField.text;
    }
	
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
	
	private function get_FontColor() : Int
	{
		return Int(textField.defaultTextFormat.color);
    }
	
	private function set_EmbedFonts(value : Bool) : Bool
	{
		textField.embedFonts = value;
        return value;
    }
	
	private function get_EmbedFonts() : Bool
	{
		return textField.embedFonts;
    }
	
	private function set_FontFamily(value : String) : String
	{
		var tf : TextFormat = textField.defaultTextFormat;
		tf.font = value; 
		textField.defaultTextFormat = tf;
		textField.setTextFormat(tf);
        return value;
    }
	
	private function get_FontFamily() : String
	{
		return textField.defaultTextFormat.font;
    }
	
	private function set_FontColor(value : Int) : Int
	{
		var tf : TextFormat = textField.defaultTextFormat;
		tf.color = value;
		textField.defaultTextFormat = tf;
		textField.setTextFormat(tf);
        return value;
    }
	
	private function get_FontSize() : Float
	{
		return Std.parseFloat(textField.defaultTextFormat.size);
    }
	
	private function set_FontSize(value : Float) : Float
	{
		var tf : TextFormat = textField.defaultTextFormat;
		tf.size = value;
		textField.defaultTextFormat = tf;
		textField.setTextFormat(tf);
        return value;
    }
	
	private function get_Bold() : Bool
	{
		return textField.defaultTextFormat.bold;
    }
	
	private function set_Bold(value : Bool) : Bool
	{
		var tf : TextFormat = textField.defaultTextFormat;
		tf.bold = value;
		textField.defaultTextFormat = tf;
		textField.setTextFormat(tf);
        return value;
    }
	
	private function set_Editable(value : Bool) : Bool
	{
		if (value == _editable) return;
		_editable = value;
		textField.type = (_editable) ? TextFieldType.INPUT : TextFieldType.DYNAMIC;
		textField.selectable = _editable;
		focusEnabled = _editable;textField.mouseEnabled = _editable;
        return value;
    }
	
	private function get_Editable() : Bool
	{
		return _editable;
    }
	
	private function set_Multiline(value : Bool) : Bool
	{
		if (value == textField.multiline) return;
		textField.multiline = value;
		textField.type = (_editable) ? TextFieldType.INPUT : TextFieldType.DYNAMIC;
		textField.selectable = _editable;
        return value;
    }
	
	private function get_Multiline() : Bool
	{
		return textField.multiline;
    }
	
	private function set_ShowBorder(value : Bool) : Bool
	{
		border.visible = value;
        return value;
    }
	
	private function get_ShowBorder() : Bool
	{
		return border.visible;
    }
	
	private function get_Padding() : Int
	{
		return _padding;
    }
	
	private function set_Padding(value : Int) : Int
	{
		if (value == _padding) return;
		_padding = value;
		invalidate();
        return value;
    }
	
	private function set_Restrict(value : String) : String
	{
		textField.restrict = value;
        return value;
    }
	
	private function get_Restrict() : String
	{
		return textField.restrict;
    }
	
	private function set_MaxChars(value : Int) : Int
	{
		textField.maxChars = value;
        return value;
    }
	
	private function get_MaxChars() : Int
	{
		return textField.maxChars;
    }
}