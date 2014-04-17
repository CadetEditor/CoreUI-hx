  /**
 * ListItemRenderer.as
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

import nme.events.Event;
import nme.events.IEventDispatcher;
import nme.text.TextFormatAlign;
import flux.skins.ListItemRendererSkin;
import core.ui.components.IItemRenderer;

class ListItemRenderer extends Button implements IItemRenderer
{
    public var data(get, set) : Dynamic;
    public var list(get, set) : List;
  
	// Internal vars  
	
	private var _list : List;
	private var _data : Dynamic;
	private var changeEventTypes : Array<Dynamic>;
	
	public function new(skinClass : Class<Dynamic> = null)
    {
		super(skinClass == (null) ? ListItemRendererSkin : skinClass);
    }  
	
	////////////////////////////////////////////////    
	// Protected methods    
	////////////////////////////////////////////////  
	
	override private function init() : Void
	{
		super.init();
		doubleClickEnabled = true;
		focusEnabled = false;
		_labelAlign = TextFormatAlign.LEFT;
    }  
	
	////////////////////////////////////////////////    
	// Getters/Setters    
	////////////////////////////////////////////////  
	
	private function set_Data(value : Dynamic) : Dynamic
	{
		if (_data != null && Std.is(_data, IEventDispatcher)) {
			for (changeEventType in changeEventTypes) {
				cast((_data), IEventDispatcher).removeEventListener(changeEventType, dataChangeHandler);
            }
        }
		_data = value;
		
		if (_data != null) {
			label = list.dataDescriptor.getLabel(_data);
			icon = list.dataDescriptor.getIcon(_data);
			enabled = list.dataDescriptor.getEnabled(_data);
			
			if (Std.is(_data, IEventDispatcher)) {
				changeEventTypes = list.dataDescriptor.getChangeEventTypes(_data);
				for (changeEventType in changeEventTypes) {
					cast((_data), IEventDispatcher).addEventListener(changeEventType, dataChangeHandler);
                }
            }
        }
        else {
			label = "<No Selection>";
			icon = null;
			enabled = true;
        }
        return value;
    }
	
	private function get_Data() : Dynamic {
		return _data;
    }
	
	private function set_List(value : List) : List {
		_list = value;
        return value;
    }
	
	private function get_List() : List {
		return _list;
    }
	
	private function dataChangeHandler(event : Event) : Void {
		data = _data;
    }
}