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

import core.ui.components.ButtonSkin;
import core.ui.components.Image;
import core.ui.components.MovieClip;
import core.ui.components.PropertyChangeEvent;
import core.ui.components.SkinClass;
import core.ui.components.UIComponent;
import nme.display.MovieClip;
import nme.events.Event;
import nme.events.MouseEvent;
import nme.geom.Rectangle;
import nme.text.TextField;
import nme.text.TextFieldAutoSize;
import nme.text.TextFormat;
import nme.text.TextFormatAlign;
import core.events.PropertyChangeEvent;
import core.ui.CoreUI;
import core.ui.events.SelectEvent;
import core.ui.util.Scale9GridUtil;
import flux.skins.ButtonSkin;

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
	private var _labelAlign : String = TextFormatAlign.CENTER;
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
		this.skinClass = skinClass;super();
    }  
	
	////////////////////////////////////////////////    
	// Protected methods    
	////////////////////////////////////////////////  
	
	override private function init() : Void
	{
		focusEnabled = true;
		skin = skinClass == (null) ? new ButtonSkin() : Type.createInstance(skinClass, []);
		
		if (!skin.scale9Grid) {  
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
		labelField.height = Math.min(labelField.textHeight + 4, _height);
		labelField.y = (_height - (labelField.height)) >> 1;
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
				var newX : Int = ((_width - labelField.x) - labelField.textWidth) >> 1;
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
	
	override private function set_Label(str : String) : String {
		_label = str; 
		labelField.text = (_label) ? _label : "";
		if (_resizeToContentWidth) {
			invalidate();
        }
        return str;
    }
	
	override private function set_Icon(value : Dynamic) : Dynamic
	{
		if (_icon == value) return;
		_icon = value;
		iconImage.source = value;
		invalidate();
        return value;
    }
	
	private function set_Selected(value : Bool) : Bool
	{
		if (_selected == value) return;
		var oldValue : Bool = _selected;
		_selected = value;
		var event : Event = new Event(Event.CHANGE, false, true);
		dispatchEvent(event);
		
		if (event.isDefaultPrevented()) {
			_selected = oldValue;
			return;
        }
		
		(_selected) ? skin.gotoAndPlay("SelectedUp") : skin.gotoAndPlay("Up");
		dispatchEvent(new PropertyChangeEvent("propertyChange_selected", oldValue, _selected));
		invalidate();
        return value;
    }
	
	private function get_Selected() : Bool
	{
		return _selected;
    }
	
	private function set_Toggle(value : Bool) : Bool
	{
		_toggle = value;
        return value;
    }
	
	private function get_Toggle() : Bool
	{
		return _toggle;
    }
	
	private function get_Over() : Bool
	{
		return _over;
    }
	
	private function get_Down() : Bool
	{
		return _down;
    }
	
	private function set_LabelAlign(v : String) : String
	{
		if (_labelAlign == v) return;
		_labelAlign = v;
		invalidate();
        return v;
    }
	
	private function get_LabelAlign() : String
	{
		return _labelAlign;
    }
}