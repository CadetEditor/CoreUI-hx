  /**
 * TreeItemRenderer.as
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

import core.ui.components.TreeItemRendererOpenIconSkin;
import nme.display.MovieClip;
import nme.events.Event;
import nme.events.MouseEvent;
import flux.skins.TreeItemRendererOpenIconSkin;

class TreeItemRenderer extends ListItemRenderer implements ITreeItemRenderer
{
    public var opened(get, set) : Bool;
    public var depth(get, set) : Int;
  
	// Properties  
	
	private var _depth : Int = 0;
	private var _opened : Bool = false;  
	
	// Child elements  
	
	private var openIcon : MovieClip;
	
	public function new()
    {
        super();
    }  
	
	////////////////////////////////////////////////    
	// Protected methods    
	////////////////////////////////////////////////  
	
	override private function init() : Void
	{
		super.init();
		openIcon = new TreeItemRendererOpenIconSkin();
		addChild(openIcon);
		openIcon.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownOpenIconHandler);
    }
	
	override private function validate() : Void
	{
		super.validate();
		var offsetLeft : Int = _depth * 16;
		openIcon.x = offsetLeft;
		openIcon.y = Math.round((_height - openIcon.height) * 0.5);
		openIcon.visible = _list && _data && _list.dataDescriptor.hasChildren(_data);
		iconImage.x = openIcon.x + openIcon.width + 2;
		labelField.x = iconImage.x + iconImage.width + 4;
		labelField.width = _width - labelField.x;
    }  
	
	////////////////////////////////////////////////    
	// Event handlers    
	////////////////////////////////////////////////  
	
	private function mouseDownOpenIconHandler(event : MouseEvent) : Void
	{
		opened = !_opened;
		dispatchEvent(new Event(Event.CHANGE, true, false));
    }  
	
	////////////////////////////////////////////////    
	// Getters/Setters    
	////////////////////////////////////////////////  
	
	private function set_Opened(value : Bool) : Bool
	{
		if (value == _opened) return;
		_opened = value; 
		(_opened) ? openIcon.gotoAndPlay("Opened") : openIcon.gotoAndPlay("Closed");
		invalidate();
        return value;
    }
	
	private function get_Opened() : Bool
	{
		return _opened;
    }
	
	private function set_Depth(value : Int) : Int
	{
		if (_depth == value) return;
		_depth = value;
		invalidate();
        return value;
    }
	
	private function get_Depth() : Int
	{
		return _depth;
    }
}