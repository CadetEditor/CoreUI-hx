  /**
 * Panel.as
 *
 * Container component with a title bar and control bar.
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

import core.ui.components.Panel;
import core.ui.components.ResizeEvent;
import flash.events.Event;
import flash.events.MouseEvent;
import core.ui.events.ResizeEvent;

class CollapsiblePanel extends Panel
{
    public var opened(get, set) : Bool;
	
	// Properties  
	
	private var _opened : Bool = true; 
	
	// Internal vars  
	
	private var openedHeight : Int = 0;
	
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
		openedHeight = _height;
		addEventListener(MouseEvent.CLICK, mouseClickHandler);
    }  
	
	////////////////////////////////////////////////    
	// Event handlers    
	////////////////////////////////////////////////  
	
	private function mouseClickHandler(event : MouseEvent) : Void
	{
		if (event.target != border) return;
		
		if (mouseY < _titleBarHeight) {
			opened = !_opened;
        }
    }  
	
	////////////////////////////////////////////////    
	// Getters/Setters    
	////////////////////////////////////////////////  
	
	private function set_Opened(value : Bool) : Bool
	{
		if (value == _opened) return;
		_opened = value;
		_height = (_opened) ? openedHeight : _titleBarHeight; dispatchEvent(new ResizeEvent(ResizeEvent.RESIZE, true));
		invalidate();
        return value;
    }
	
	private function get_Opened() : Bool
	{
		return _opened;
    }
	
	override private function set_Height(value : Float) : Float
	{
		super.height = value;
		openedHeight = Math.max(_minHeight, value);
		_opened = _height > _minHeight;
        return value;
    }
}