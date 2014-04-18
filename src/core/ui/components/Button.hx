  /**
 * Button.as
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

import core.layout.TextAlign;
import flash.display.MovieClip;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Rectangle;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import core.ui.CoreUI;
import core.ui.events.SelectEvent;
import core.ui.util.Scale9GridUtil;

@:meta(Event(type="flash.events.Event",name="change"))
@:meta(Event(type="core.ui.events.SelectEvent",name="select"))
class Button extends UIComponent
{
    public var selected(get, set) : Bool;
    public var toggle(get, set) : Bool;
    public var over(get, never) : Bool;
    public var down(get, never) : Bool;
    public var labelAlign(get, set) : String;
	
	// Properties  
	private var _over : Bool = false;
	private var _down : Bool = false;
	private var _selected : Bool = false;
	private var _toggle : Bool = false;
	private var _labelAlign : TextFormatAlign = TextFormatAlign.CENTER;
	public var selectMode : String = ButtonSelectMode.CLICK;
	public var userData : Dynamic;  
	
	// Child elements  
	private var skin : MovieClip;
	private var iconImage : Image;
	private var labelField : TextField;  
	
	// Internal vars  
	private var skinClass : Class<Dynamic>;
	
	public function new(skinClass : Class<Dynamic> = null)
    {
		this.skinClass = skinClass;
		super();
    }  
	
	////////////////////////////////////////////////    
	// Protected methods    
	////////////////////////////////////////////////  
	
	override private function init() : Void
	{
		focusEnabled = true;
		skin = skinClass == (null) ? new ButtonSkin() : Type.createInstance(skinClass, []);
		
		if (skin.scale9Grid == null) {  
			//var s9g:Rectangle = FloxUI.getDefaultButtonSkinScale9Grid();    
			//skin.scale9Grid = new Rectangle();  
			Scale9GridUtil.setScale9Grid(skin, CoreUI.defaultButtonSkinScale9Grid);
        }
		
		_width = skin.width;
		_height = skin.height;
		skin.mouseEnabled = false;
		addChild(skin);
		labelField = TextStyles.createTextField();
		addChild(labelField);
		iconImage = new Image();
		iconImage.mouseEnabled = false;
		iconImage.mouseChildren = false;
		iconImage.scaleMode = Image.SCALE_MODE_FIT;
		addChild(iconImage);
		addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
		addEventListener(MouseEvent.ROLL_OVER, rollOverHandler);
		addEventListener(Event.REMOVED_FROM_STAGE, removedFromStageHandler);
    }
	
	override private function validate() : Void 
	{ 
		iconImage.validateNow();
		iconImage.width = iconImage.height = _height;  // - 6;  
		iconImage.x = iconImage.y = 0;  
		/*
		if ( labelField.text == "" ){
			iconImage.x = (_width - iconImage.width) >> 1;
		} else {
			iconImage.x = 6;
		}
		*/  
		labelField.x = iconImage.source == (null) ? 4 : iconImage.x + iconImage.width + 4;
		labelField.height = Math.min(Std.int(labelField.textHeight) + 4, _height);
		labelField.y = Std.int(_height - labelField.height) >> 1;
		var tf : TextFormat = labelField.defaultTextFormat; tf.align = _labelAlign;
		
		if (_resizeToContentWidth) {
			tf.align = TextFormatAlign.LEFT;
			labelField.autoSize = TextFieldAutoSize.LEFT;
			_width = labelField.x + labelField.width + 4;
        } else {
			labelField.autoSize = TextFieldAutoSize.NONE;
			labelField.width = Math.max(0, _width - (labelField.x + 4));  
			// Special case for CENTER alignment. Manually center textfield rather than using    
			// TextFormat.align = CENTER to avoid text aliasing.  
			if (_labelAlign == TextFormatAlign.CENTER) {
				tf.align = TextFormatAlign.LEFT;
				var newX : Int = Std.int((_width - labelField.x) - labelField.textWidth) >> 1;
				labelField.x = newX > (labelField.x) ? newX : labelField.x;
            }
        }
		
		labelField.defaultTextFormat = tf;
		labelField.setTextFormat(tf);
		skin.width = _width;
		skin.height = _height;
		
		if ((_down && _over) || _selected) {
			labelField.y += 1;
			iconImage.y += 1;
        }
    }  
	
	////////////////////////////////////////////////    
	// Event handlers    
	////////////////////////////////////////////////  
	
	private function removedFromStageHandler(event : Event) : Void
	{
		stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
		_over = false;
		_down = false;
		(_selected) ? skin.gotoAndPlay("SelectedUp") : skin.gotoAndPlay("Up");
    }
	
	private function rollOverHandler(event : MouseEvent) : Void
	{
		if (event.target != this) return;
		_over = true;
		(_selected) ? ((_down) ? skin.gotoAndPlay("SelectedDown") : skin.gotoAndPlay("SelectedOver")) : ((_down) ? skin.gotoAndPlay("Down") : skin.gotoAndPlay("Over"));
		addEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
		invalidate();
    }
	
	private function rollOutHandler(event : MouseEvent) : Void
	{
		if (event.target != this) return;
		_over = false;
		(_selected) ? skin.gotoAndPlay("SelectedUp") : skin.gotoAndPlay("Up");
		removeEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
		invalidate();
    }
	
	private function mouseDownHandler(event : MouseEvent) : Void
	{
		if (event.target != this) return;
		_down = true;
		stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
		
		if (selectMode == ButtonSelectMode.MOUSE_DOWN) {
			if (toggle) { 
				selected = !_selected;
				if (_selected) {
					dispatchEvent(new SelectEvent(SelectEvent.SELECT, null, true));
                }
            } else {
				dispatchEvent(new SelectEvent(SelectEvent.SELECT, null, true));
            }
        }
		
		(_selected) ? skin.gotoAndPlay("SelectedDown") : skin.gotoAndPlay("Down");
		invalidate();
    }
	
	private function mouseUpHandler(event : MouseEvent) : Void
	{
		stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
		if (selectMode == ButtonSelectMode.CLICK) {
			if (toggle && _over) {
				selected = !_selected;
				if (_selected) {
					dispatchEvent(new SelectEvent(SelectEvent.SELECT, null, true));
                }
            } else if (_over) {
				dispatchEvent(new SelectEvent(SelectEvent.SELECT, null, true));
            }
        }
		
		_down = false;
		(_selected) ? ((_over) ? skin.gotoAndPlay("SelectedOver") : skin.gotoAndPlay("SelectedUp")) : ((_over) ? skin.gotoAndPlay("Over") : skin.gotoAndPlay("Up"));
		invalidate();
    }  
	
	////////////////////////////////////////////////    
	// Getters/Setters    
	////////////////////////////////////////////////  
	
	override private function set_label(str : String) : String {
		_label = str; 
		labelField.text = (_label != null) ? _label : "";
		if (_resizeToContentWidth) {
			invalidate();
        }
        return str;
    }
	
	override private function set_icon(value : Dynamic) : Dynamic
	{
		if (_icon == value) return null;
		_icon = value;
		iconImage.source = value;
		invalidate();
        return value;
    }
	
	private function set_selected(value : Bool) : Bool
	{
		if (_selected == value) return null;
		var oldValue : Bool = _selected;
		_selected = value;
		var event : Event = new Event(Event.CHANGE, false, true);
		dispatchEvent(event);
		
		if (event.isDefaultPrevented()) {
			_selected = oldValue;
			return null;
        }
		
		(_selected) ? skin.gotoAndPlay("SelectedUp") : skin.gotoAndPlay("Up");
		dispatchEvent(new PropertyChangeEvent("propertyChange_selected", oldValue, _selected));
		invalidate();
        return value;
    }
	
	private function get_selected() : Bool
	{
		return _selected;
    }
	
	private function set_toggle(value : Bool) : Bool
	{
		_toggle = value;
        return value;
    }
	
	private function get_toggle() : Bool
	{
		return _toggle;
    }
	
	private function get_over() : Bool
	{
		return _over;
    }
	
	private function get_down() : Bool
	{
		return _down;
    }
	
	private function set_labelAlign(v : TextFormatAlign) : TextFormatAlign
	{
		if (_labelAlign == v) return null;
		_labelAlign = v;
		invalidate();
        return v;
    }
	
	private function get_labelAlign() : TextFormatAlign
	{
		return _labelAlign;
    }
}