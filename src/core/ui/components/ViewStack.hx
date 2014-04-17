  /**
 * ViewStack.as
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
 */  package core.ui.components;

import core.ui.components.IndexChangeEvent;
import nme.errors.Error;
import nme.display.DisplayObject;import nme.events.Event;import core.ui.events.IndexChangeEvent;@:meta(Event(type="flash.events.Event",name="change"))
@:meta(Event(type="core.ui.events.IndexChangeEvent",name="indexChange"))
class ViewStack extends Container
{
    public var visibleIndex(get, set) : Int;
  // Properties  private var _visibleIndex : Int = -1;public function new()
    {
        super();
    }  ////////////////////////////////////////////////    // Protected methods    ////////////////////////////////////////////////  override private function validate() : Void{for (i in 0...content.numChildren){var child : UIComponent = cast((content.getChildAt(i)), UIComponent);child.visible = i == _visibleIndex;child.excludeFromLayout = !child.visible;
        }super.validate();
    }  ////////////////////////////////////////////////    // Event handlers    ////////////////////////////////////////////////  override private function onChildrenChanged(child : DisplayObject, index : Int, added : Bool) : Void{if (added && content.numChildren == 1 && _visibleIndex == -1) {visibleIndex = 0;
        }
        else if (index <= _visibleIndex) {var temp : Int = _visibleIndex;if (numChildren == 0) {visibleIndex = -1;return;
            }_visibleIndex = -1;visibleIndex = (added) ? temp + 1 : temp - 1;
        }
    }  ////////////////////////////////////////////////    // Getters/Setters    ////////////////////////////////////////////////  private function set_VisibleIndex(value : Int) : Int{if (value < -1 || value >= content.numChildren) {throw (new Error("Index out of bounds"));return;
        }if (_visibleIndex == value)             return;var oldIndex : Int = _visibleIndex;_visibleIndex = value;invalidate();dispatchEvent(new IndexChangeEvent(IndexChangeEvent.INDEX_CHANGE, oldIndex, _visibleIndex, false, false));dispatchEvent(new Event(Event.CHANGE));
        return value;
    }private function get_VisibleIndex() : Int{return _visibleIndex;
    }
}