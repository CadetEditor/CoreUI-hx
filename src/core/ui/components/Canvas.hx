  /**
 * Canvas.as
 * 
 * Adds a background to the basic Container class
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

import core.ui.components.Container;
import flash.display.Sprite;
import core.ui.CoreUI;
import core.ui.util.Scale9GridUtil;

class Canvas extends Container
{  
	// Child elements  
	private var background : Sprite;
	
	public function new()
    {
        super();
    }
	
	override private function init() : Void
	{
		background = new CanvasSkin();
		
		if (background.scale9Grid == null) {
			Scale9GridUtil.setScale9Grid(background, CoreUI.defaultCanvasSkinScale9Grid);
        }
		
		addRawChild(background);
		super.init();
		_width = background.width;
		_height = background.height;
    }
	
	override private function validate() : Void
	{
		super.validate();
		background.width = _width;
		background.height = _height;
    }
}