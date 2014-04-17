  /**
 * Container.as
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

import core.ui.components.AbsoluteLayout;
import core.ui.components.ContainerEvent;
import core.ui.components.DisplayObject;
import core.ui.components.ILayout;
import core.ui.components.UIComponent;
import nme.display.DisplayObject;
import nme.display.Sprite;
import nme.events.Event;
import nme.geom.Rectangle;
import core.ui.events.ContainerEvent;
import core.ui.events.ResizeEvent;
import core.ui.layouts.AbsoluteLayout;
import core.ui.layouts.ILayout;

@:meta(Event(type="core.ui.events.ContainerEvent",name="childrenChanged"))
class Container extends UIComponent
{
    public var padding(get, set) : Int;
    public var paddingLeft(get, set) : Int;
    public var paddingRight(get, set) : Int;
    public var paddingTop(get, set) : Int;
    public var paddingBottom(get, set) : Int;
    public var layout(get, set) : ILayout;
	
	// Properties  
	
	private var _paddingLeft : Int = 0;
	private var _paddingRight : Int = 0;
	private var _paddingTop : Int = 0;
	private var _paddingBottom : Int = 0;
	private var _layout : ILayout;  
	
	// Child elements  
	
	private var content : Sprite;
	
	public function new()
    {
        super();
    }  
	
	////////////////////////////////////////////////    
	// Public methods    
	////////////////////////////////////////////////  
	
	override public function addChildAt(child : DisplayObject, index : Int) : DisplayObject
	{
		content.addChildAt(child, index);
		invalidate();
		onChildrenChanged(child, index, true);
		dispatchEvent(new ContainerEvent(ContainerEvent.CHILD_ADDED, child, index));
		return child;
    }
	
	override public function addChild(child : DisplayObject) : DisplayObject
	{
		content.addChild(child);
		invalidate();
		onChildrenChanged(child, content.numChildren - 1, true);
		dispatchEvent(new ContainerEvent(ContainerEvent.CHILD_ADDED, child, content.numChildren - 1));
		return child;
    }
	
	override public function removeChildAt(index : Int) : DisplayObject
	{
		invalidate();
		var child : DisplayObject = content.removeChildAt(index);
		onChildrenChanged(child, index, false);
		dispatchEvent(new ContainerEvent(ContainerEvent.CHILD_REMOVED, child, index));
		return child;
    }
	
	override public function removeChild(child : DisplayObject) : DisplayObject
	{
		var index : Int = content.getChildIndex(child);
		content.removeChild(child);
		invalidate();
		onChildrenChanged(child, index, false);
		dispatchEvent(new ContainerEvent(ContainerEvent.CHILD_REMOVED, child, content.numChildren));
		return child;
    }
	
	override public function getChildAt(index : Int) : DisplayObject
	{
		return content.getChildAt(index);
    }
	
	override public function getChildIndex(child : DisplayObject) : Int
	{
		return content.getChildIndex(child);
    }
	
	override private function get_NumChildren() : Int
	{
		return content.numChildren;
    }  
	
	////////////////////////////////////////////////    
	// Protected methods    
	////////////////////////////////////////////////  
	
	override private function init() : Void
	{
		_layout = new AbsoluteLayout();
		content = new Sprite();
		content.scrollRect = new Rectangle();
		addRawChild(content);
		content.addEventListener(ResizeEvent.RESIZE, resizeHandler);
    }
	
	override private function validate() : Void
	{
		var layoutArea : Rectangle = getChildrenLayoutArea();
		
		if (_resizeToContentWidth || _resizeToContentHeight) {
			var contentSize : Rectangle = _layout.layout(content, layoutArea.width, layoutArea.height, false);
			
			if (_resizeToContentWidth) {
				_width = contentSize.width + _paddingLeft + _paddingRight;layoutArea.width = contentSize.width;
            }
			
			if (_resizeToContentHeight) {
				_height = contentSize.height + _paddingTop + _paddingBottom;
				layoutArea.height = contentSize.height;
            }
        }
		
		if (!_resizeToContentWidth || !_resizeToContentHeight) {
			_layout.layout(content, layoutArea.width, layoutArea.height, true);
        }
		
		content.x = layoutArea.x;
		content.y = layoutArea.y;
		var scrollRect : Rectangle = content.scrollRect;
		scrollRect.width = layoutArea.width;
		scrollRect.height = layoutArea.height;
		content.scrollRect = scrollRect;
    }  
	
	/**
	 * 'Virtual' method. Can be overriden to provide information when children change.
	 * @param	child The child that has been added/removed from the child list.
	 * @param	index The index of the child.
	 * @param	added If true, the child has just been added, otherwise it's just been removed.
	 */  
	
	private function onChildrenChanged(child : DisplayObject, index : Int, added : Bool) : Void
	{  
		// Intentionally blank  
    }  
	
	/**
	 * By default returns a rectangle the same size as the component, minus padding.
	 * Override this for containers that need something more custom, and needs to take into account other chrome elements.
	 * @return
	 */  
	
	private function getChildrenLayoutArea() : Rectangle
	{
		return new Rectangle(_paddingLeft, _paddingTop, _width - (_paddingRight + _paddingLeft), _height - (_paddingBottom + _paddingTop));
    }
	
	private function addRawChild(child : DisplayObject) : DisplayObject
	{
		super.addChild(child);
		return child;
    }
	
	private function removeRawChild(child : DisplayObject) : DisplayObject
	{
		super.removeChild(child);
		return child;
    }  
	
	////////////////////////////////////////////////    
	// Event handlers    
	////////////////////////////////////////////////  
	
	private function resizeHandler(event : Event) : Void
	{
		if (event.target.parent == content) {
			event.stopImmediatePropagation();
			invalidate();
        }
    }  
	
	////////////////////////////////////////////////    
	// Getters/Setters    
	////////////////////////////////////////////////  
	
	private function set_Padding(value : Int) : Int
	{
		_paddingLeft = _paddingRight = _paddingTop = _paddingBottom = value;
		invalidate();
        return value;
    }
	
	private function get_Padding() : Int
	{
		return _paddingLeft;
    }
	
	private function set_PaddingLeft(value : Int) : Int
	{
		_paddingLeft = value;
		invalidate();
        return value;
    }
	
	private function get_PaddingLeft() : Int
	{
		return _paddingLeft;
    }
	
	private function set_PaddingRight(value : Int) : Int
	{
		_paddingRight = value;
		invalidate();
        return value;
    }
	
	private function get_PaddingRight() : Int
	{
		return _paddingRight;
    }
	
	private function set_PaddingTop(value : Int) : Int
	{
		_paddingTop = value;
		invalidate();
        return value;
    }
	
	private function get_PaddingTop() : Int
	{
		return _paddingTop;
    }
	
	private function set_PaddingBottom(value : Int) : Int
	{
		_paddingBottom = value;
		invalidate();
        return value;
    }
	
	private function get_PaddingBottom() : Int
	{
		return _paddingBottom;
    }
	
	private function set_Layout(value : ILayout) : ILayout
	{
		_layout = value;
		if (_layout != null) {
			invalidate();
        }
        return value;
    }
	
	private function get_Layout() : ILayout
	{
		return _layout;
    }
}