  /**
 * Checkbox.as
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

import core.ui.components.ItemEditorEvent;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import core.ui.events.ItemEditorEvent;
import flux.skins.CheckBoxSkin;

class CheckBox extends Button
{
    public var indeterminate(get, set) : Bool;
	
	// Properties  
	
	private var _indeterminate : Bool = false;
	
	public function new()
    {
		super(CheckBoxSkin);
    }  
	
	////////////////////////////////////////////////    
	// Protected methods    
	////////////////////////////////////////////////  
	
	override private function init() : Void
	{
		super.init();
		_toggle = true;
		var textFormat : TextFormat = labelField.defaultTextFormat;
		textFormat.align = TextFormatAlign.LEFT;
		labelField.defaultTextFormat = textFormat;
		labelField.autoSize = TextFieldAutoSize.LEFT;
		iconImage.visible = false;
    }
	
	override private function validate() : Void
	{
		_height = labelField.height;
		skin.y = (_height - skin.height) >> 1;
		labelField.x = skin.x + skin.width + 4;
		labelField.height = Math.min(labelField.textHeight + 4, _height);
		labelField.y = (_height - (labelField.height)) >> 1;
		_width = labelField.x + labelField.width;
    }
	
	private function updateSkinState() : Void
	{
		if (!_selected && !_indeterminate) {
			(_down) ? skin.gotoAndPlay("Down") : (_over) ? skin.gotoAndPlay("Over") : skin.gotoAndPlay("Up");
        } else if (_selected && !_indeterminate) {
			(_down) ? skin.gotoAndPlay("SelectedDown") : (_over) ? skin.gotoAndPlay("SelectedOver") : skin.gotoAndPlay("SelectedUp");
        } else {
			(_down) ? skin.gotoAndPlay("IndeterminateDown") : (_over) ? skin.gotoAndPlay("IndeterminateOver") : skin.gotoAndPlay("IndeterminateUp");
        }
    }  
	
	////////////////////////////////////////////////    
	// Event Handlers    
	////////////////////////////////////////////////  
	
	override private function rollOverHandler(event : MouseEvent) : Void
	{
		_over = true; 
		updateSkinState();
		addEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
    }
	
	override private function rollOutHandler(event : MouseEvent) : Void
	{
		_over = false;
		(_indeterminate) ? skin.gotoAndPlay("IndeterminateUp") : (_selected) ? skin.gotoAndPlay("SelectedUp") : skin.gotoAndPlay("Up");
		removeEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
    }
	
	override private function mouseDownHandler(event : MouseEvent) : Void
	{
		_down = true; 
		updateSkinState();
		stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
    }
	
	override private function mouseUpHandler(event : MouseEvent) : Void
	{
		if (_over) { 
			_selected = !_selected;
			_indeterminate = false;
			dispatchEvent(new Event(Event.CHANGE));
			dispatchEvent(new ItemEditorEvent(ItemEditorEvent.COMMIT_VALUE, _selected, "selected"));
        }
		
		_down = false;
		updateSkinState();
		stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
    }  
	
	////////////////////////////////////////////////    
	// Getters/Setters    
	////////////////////////////////////////////////  
	
	private function set_Indeterminate(value : Bool) : Bool
	{
		_indeterminate = value;
		updateSkinState();
        return value;
    }
	
	private function get_Indeterminate() : Bool
	{
		return _indeterminate;
    }
}