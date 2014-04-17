/**
 * AbsoluteLayout.as
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
 */package core.ui.layouts;

import core.ui.layouts.DisplayObject;
import core.ui.layouts.DisplayObjectContainer;
import core.ui.layouts.ILayout;
import core.ui.layouts.Rectangle;
import core.ui.layouts.UIComponent;
import nme.display.DisplayObject;import nme.display.DisplayObjectContainer;import nme.geom.Rectangle;import core.ui.components.UIComponent;class AbsoluteLayout implements ILayout
{public function new()
    {
    }public function layout(content : DisplayObjectContainer, visibleWidth : Float, visibleHeight : Float, allowProportional : Bool = true) : Rectangle{var contentSize : Rectangle = new Rectangle();for (i in 0...content.numChildren){var child : DisplayObject = content.getChildAt(i);var component : UIComponent = try cast(child, UIComponent) catch(e:Dynamic) null;if (component != null && component.excludeFromLayout)                 {i++;continue;
            };if (component != null && allowProportional) {if (Math.isNaN(component.percentWidth) == false) {child.width = visibleWidth - child.x;
                }if (Math.isNaN(component.percentHeight) == false) {child.height = visibleHeight - child.y;
                }
            }if (component != null) {component.validateNow();
            }if (child.x + child.width > contentSize.width)                 contentSize.width += child.width;if (child.y + child.height > contentSize.height)                 contentSize.height += child.height;
        }return contentSize;
    }
}