 /**
 * HorizontalLayout.as
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
 
package core.ui.layouts;

import core.ui.layouts.ILayout;
import nme.display.DisplayObject;
import nme.display.DisplayObjectContainer;
import nme.geom.Rectangle;
import core.ui.components.UIComponent;

class HorizontalLayout implements ILayout
{
	
	public var spacing : Int;
	public var horizontalAlign : String;
	public var verticalAlign : String;
	
	public function new(spacing : Int = 2, horizontalAlign : String = "left", verticalAlign : String = "none")
    {
		this.spacing = spacing;
		this.horizontalAlign = horizontalAlign;
		this.verticalAlign = verticalAlign;
    }
	
	public function layout(content : DisplayObjectContainer, visibleWidth : Float, visibleHeight : Float, allowProportional : Bool = true) : Rectangle
	{
		var pos : Int = 0;
		var proportionalSlotSize : Float = 0;
		var contentSize : Rectangle = new Rectangle();
		
		if (allowProportional) {  
			// Sum up the total height of all children with explicit heights.    
			// We can then share the remainder amongst children with percentHeight defined.  
			var totalExplicitSize : Int = 0;
			var numProportionalChildren : Int = 0;
			
			for (i in 0...content.numChildren) {
				var child : DisplayObject = content.getChildAt(i);
				var component : UIComponent = try cast(child, UIComponent) catch (e:Dynamic) null;
				if (component != null) { 
					if (component.excludeFromLayout) {
						continue;
					}
				}
				if (Math.isNaN(component.percentWidth)) {
					component.validateNow();
					totalExplicitSize += child.width;
				} else {
					numProportionalChildren++;
				}
			}
        }
		
		var proportionalSpaceRemaining : Int = (visibleWidth - (spacing * (content.numChildren - 1))) - totalExplicitSize;proportionalSlotSize = proportionalSpaceRemaining / numProportionalChildren;
    }  
	
	// Because components have integer x/y width/height properties, we need to track how much of the real 
	// fractional value we're losing along the way. We then append this to the next item to ensure
	// proportional values sum up to the correct value.

	var errorAccumulator : Float = 0;
	
	for (content.numChildren) {
		child = content.getChildAt(i);
		component = try cast(child, UIComponent) catch (e:Dynamic) null;
		var isProportionalWidth : Bool = false;
		var isProportionalHeight : Bool = false;
		if (component) {
			if (component.excludeFromLayout) {
				continue;
            }
			isProportionalWidth = allowProportional && Math.isNaN(component.percentWidth) == false;
			isProportionalHeight = allowProportional && Math.isNaN(component.percentHeight) == false;
        }

        switch (verticalAlign)
        {
			case LayoutAlign.TOP:
				child.y = 0;
				if (isProportionalHeight) {
					child.height = (visibleHeight - child.y) * component.percentHeight * 0.01;
                }
			case LayoutAlign.BOTTOM:
				if (isProportionalHeight) {
					child.height = visibleHeight * component.percentHeight * 0.01;
                }
				child.y = visibleHeight - child.height;
			case LayoutAlign.CENTRE:
				if (isProportionalHeight) {
					child.height = visibleHeight * component.percentHeight * 0.01;
                }
				child.y = (visibleHeight - child.height) * 0.5;
			default:
				if (isProportionalHeight) {
					child.height = (visibleHeight - child.y) * component.percentHeight * 0.01;
                }
        }
		
		if (isProportionalWidth) {
			var fractionalValue : Float = proportionalSlotSize * component.percentWidth * 0.01 + errorAccumulator;
			var roundedValue : Int = Math.round(fractionalValue);
			child.width = roundedValue;
			errorAccumulator = fractionalValue - roundedValue;
        }
			
		child.x = pos;
		
		if (component) {
			component.validateNow();
        }
		
		pos += child.width + spacing;
		contentSize.width = child.x + child.width > (contentSize.width) ? child.x + child.width : contentSize.width;
		contentSize.height = child.y + child.height > (contentSize.height) ? child.y + child.height : contentSize.height;
    }
		
		
	if (horizontalAlign != LayoutAlign.NONE) {
		var shift : Int = 0;
        
		switch (horizontalAlign)
        {
			case LayoutAlign.RIGHT:
				shift = visibleWidth - contentSize.width;
			case LayoutAlign.CENTRE:
				shift = (visibleWidth - contentSize.width) >> 1;
        }
			
		for (content.numChildren) {
			child = cast((content.getChildAt(i)), UIComponent);
			child.x += shift;
        }
    }
	
	return contentSize;
}