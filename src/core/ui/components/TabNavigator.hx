  /**
 * TabNavigator.as
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

import core.ui.components.TabNavigatorTab;
import core.ui.components.ViewStack;
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Rectangle;
import core.ui.CoreUI;
import core.ui.events.TabNavigatorEvent;
import core.ui.layouts.HorizontalLayout;
import core.ui.layouts.LayoutAlign;
import core.ui.managers.FocusManager;
import core.ui.util.BindingUtil;
import core.ui.util.Scale9GridUtil;

@:meta(Event(type="core.ui.events.TabNavigatorEvent",name="closeTab"))
class TabNavigator extends ViewStack
{
    public var showCloseButtons(get, set) : Bool;
  
	// Properties  
	
	private var _showCloseButtons : Bool = true;  
	
	// Child elements  
	
	private var tabBar : Container;	
	private var background : Sprite;
	
	public function new()
    {
        super();
    }  
	
	////////////////////////////////////////////////    
	// Protected methods    
	////////////////////////////////////////////////  
	
	override private function init() : Void
	{
		background = new TabNavigatorSkin();
		
		if (!background.scale9Grid) {
			Scale9GridUtil.setScale9Grid(background, CoreUI.defaultTabNavigatorSkinScale9Grid);
        }
		
		addRawChild(background);
		super.init();
		_width = background.width;
		_height = background.height;
		var testTab : TabNavigatorTab = new TabNavigatorTab();
		tabBar = new Container();
		tabBar.focusEnabled = true;
		tabBar.height = testTab.height;
		tabBar.layout = new HorizontalLayout( -1, LayoutAlign.BOTTOM); 
		addRawChild(tabBar);
		tabBar.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownTabHandler);
		tabBar.addEventListener(Event.CLOSE, closeTabHandler);
    }
	
	override private function validate() : Void
	{
		super.validate();
		var layoutArea : Rectangle = getChildrenLayoutArea();
		background.width = _width;
		background.y = (tabBar.height - 1);
		background.height = _height - (tabBar.height - 1);
		tabBar.width = _width;
		
		for (i in 0...tabBar.numChildren) {
			var tab : TabNavigatorTab = cast((tabBar.getChildAt(i)), TabNavigatorTab);
			tab.selected = i == _visibleIndex;
			tab.showCloseButton = _showCloseButtons;
        }
		
		tabBar.validateNow();
    }
	
	override private function getChildrenLayoutArea() : Rectangle
	{
		return new Rectangle(_paddingLeft, _paddingTop + (tabBar.height - 1), _width - (_paddingRight + _paddingLeft), _height - ((_paddingBottom + _paddingTop) + (tabBar.height - 1)));
    }  
	
	////////////////////////////////////////////////    
	// Event handlers    
	////////////////////////////////////////////////  
	
	override private function onChildrenChanged(child : DisplayObject, index : Int, added : Bool) : Void
	{
		super.onChildrenChanged(child, index, added);
		if (added) {
			var tab : TabNavigatorTab = new TabNavigatorTab();
			tab.width = 100; 
			tab.percentHeight = 100;
			if (Std.is(child, IUIComponent)) {
				BindingUtil.bind(child, "label", tab, "label");
				BindingUtil.bind(child, "icon", tab, "icon");
            }
			tabBar.addChildAt(tab, index);
        } else {
			if (Std.is(child, IUIComponent)) {
				BindingUtil.unbind(child, "label", tab, "label");
				BindingUtil.unbind(child, "icon", tab, "icon");
            }
			tabBar.removeChildAt(index);
        }
    }
	
	private function mouseDownTabHandler(event : MouseEvent) : Void
	{
		var tab : TabNavigatorTab = try cast(event.target, TabNavigatorTab) catch (e:Dynamic) null;
		if (tab == null) return; 
		// Looks like we've click the background, or some other chrome.  
		var index : Int = tabBar.getChildIndex(tab);
		visibleIndex = index;
    }
	
	private function closeTabHandler(event : Event) : Void
	{
		var tab : TabNavigatorTab = cast((event.target), TabNavigatorTab);
		event.stopImmediatePropagation();
		var index : Int = tabBar.getChildIndex(tab);
		dispatchEvent(new TabNavigatorEvent(TabNavigatorEvent.CLOSE_TAB, index, true));
    }  
	
	////////////////////////////////////////////////    
	// Getters/Setters    	
	////////////////////////////////////////////////  
	
	private function set_ShowCloseButtons(value : Bool) : Bool
	{
		if (_showCloseButtons == value) return;
		_showCloseButtons = value;
		invalidate();
        return value;
    }
	
	private function get_ShowCloseButtons() : Bool
	{
		return _showCloseButtons;
    }
}