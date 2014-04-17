  /**
 * RadioButtonGroup.as
 * 
 * Only capable of containing Buttons. Enforces mutually exclusive selection behaviour.
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

import nme.errors.Error;
import nme.display.DisplayObject;
import nme.events.Event;

@:meta(Event(name="change",type="flash.events.Event"))
class RadioButtonGroup extends Container
{
    public var selectedIndex(get, set) : Int;
  
	// Properties  
	
	private var _selectedChild : Button;
	
	public function new()
    {
        super();
    }
	
	override private function onChildrenChanged(child : DisplayObject, index : Int, added : Bool) : Void
	{
		if (added && Std.is(child, Button) == false) {
			throw (new Error("RadioButtonGroup only supports Button children"));
			return;
        }
		
		var btn : Button = cast((child), Button);
		if (added) { btn.addEventListener(Event.CHANGE, changeButtonHandler); 
			btn.toggle = true;
			btn.selectMode = ButtonSelectMode.MOUSE_DOWN;
        } else {
			btn.removeEventListener(Event.CHANGE, changeButtonHandler);
        }
    }
	
	private function changeButtonHandler(event : Event) : Void
	{
		var changedChild : Button = cast((event.target), Button);
		if (changedChild.selected == false) {
			event.preventDefault();
			return;
        }
		for (i in 0...content.numChildren) {
			var child : Button = cast((content.getChildAt(i)), Button);
			if (child == changedChild) {
				_selectedChild = changedChild;
				continue;
            }
			child.removeEventListener(Event.CHANGE, changeButtonHandler);
			child.selected = false;
			child.addEventListener(Event.CHANGE, changeButtonHandler);
        }
		dispatchEvent(new Event(Event.CHANGE));
    }
	
	private function set_SelectedIndex(value : Int) : Int
	{
		var child : Button = cast((getChildAt(value)), Button);
		child.selected = true;
        return value;
    }
	
	private function get_SelectedIndex() : Int
	{
		if (_selectedChild == null) return -1;
		return getChildIndex(_selectedChild);
    }
}