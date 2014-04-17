  /**
 * TabNavigatorTab.as
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
import nme.events.MouseEvent;
import core.ui.CoreUI;
import core.ui.util.Scale9GridUtil;
import flux.skins.TabNavigatorTabCloseBtnSkin;
import flux.skins.TabNavigatorTabSkin;

class TabNavigatorTab extends Button
{
    public var showCloseButton(get, set) : Bool;
  
	// Properties  
	
	private var _showCloseBtn : Bool = true;  
	
	// Child elements  
	
	private var closeBtn : Button;
	
	public function new()
    {
		super(TabNavigatorTabSkin);
    }  
	
	////////////////////////////////////////////////    
	// Protected methods    
	////////////////////////////////////////////////  
	
	override private function init() : Void
	{
		super.init();
		focusEnabled = false;
		resizeToContentWidth = true;
		closeBtn = new Button(TabNavigatorTabCloseBtnSkin);
		closeBtn.addEventListener(MouseEvent.CLICK, clickCloseHandler);
		addChild(closeBtn);
		if (!skin.scale9Grid) {
			Scale9GridUtil.setScale9Grid(skin, CoreUI.defaultTabNavigatorTabSkinScale9Grid);
        }
    }
	
	override private function validate() : Void
	{
		super.validate();
		if (closeBtn.visible) {
			closeBtn.x = labelField.x + labelField.width + 0;
			closeBtn.y = (_height - closeBtn.height) >> 1;
			_width = closeBtn.x + closeBtn.width + 4;
        }
		skin.width = _width;
		skin.height = _height;
    }  
	
	////////////////////////////////////////////////    
	// Event handlers    
	////////////////////////////////////////////////  
	
	private function clickCloseHandler(event : MouseEvent) : Void
	{
		dispatchEvent(new Event(Event.CLOSE, true, true));
    }  
	
	////////////////////////////////////////////////    
	// Getters/Setters    
	////////////////////////////////////////////////  
	
	private function set_ShowCloseButton(value : Bool) : Bool
	{
		if (closeBtn.visible == value) return;
		closeBtn.visible = value;invalidate();
        return value;
    }
	
	private function get_ShowCloseButton() : Bool
	{
		return closeBtn.visible;
    }
}