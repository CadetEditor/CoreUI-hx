  /**
 * ScrollPane.as
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

import nme.events.Event;import nme.events.MouseEvent;import nme.geom.Rectangle;class ScrollPane extends Container
{
    public var scrollBarPadding(get, set) : Int;
    public var maxScrollX(get, never) : Int;
    public var maxScrollY(get, never) : Int;
    public var scrollX(get, set) : Int;
    public var scrollY(get, set) : Int;
  // Styles  public static var styleScrollBarPadding : Int = 2;  // Properties  private var _scrollBarPadding : Int = styleScrollBarPadding;private var _autoHideVScrollBar : Bool = true;private var _autoHideHScrollBar : Bool = true;  // Child elements  private var vScrollBar : ScrollBar;private var hScrollBar : ScrollBar;public function new()
    {
        super();
    }  ////////////////////////////////////////////////    // Protected methods    ////////////////////////////////////////////////  override private function init() : Void{super.init();vScrollBar = new ScrollBar();vScrollBar.scrollSpeed = 20;vScrollBar.pageScrollSpeed = 60;addRawChild(vScrollBar);hScrollBar = new ScrollBar();hScrollBar.rotation = -90;hScrollBar.scrollSpeed = 20;hScrollBar.pageScrollSpeed = 60;addRawChild(hScrollBar);addEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelHandler);
    }override private function validate() : Void{var layoutArea : Rectangle = getChildrenLayoutArea();var extraPaddingForVScrollBar : Float = (_autoHideVScrollBar) ? 0 : (vScrollBar.width - _paddingRight) + _scrollBarPadding;var extraPaddingForHScrollBar : Float = (_autoHideHScrollBar) ? 0 : (hScrollBar.width - _paddingBottom) + _scrollBarPadding;layoutArea.width -= extraPaddingForVScrollBar;layoutArea.height -= extraPaddingForHScrollBar;var contentSize : Rectangle = _layout.layout(content, layoutArea.width, layoutArea.height);var needReLayout : Bool = false;var requiresHScrollBar : Bool = contentSize.width > layoutArea.width;if (requiresHScrollBar && _autoHideHScrollBar) {layoutArea.height -= (hScrollBar.width - _paddingBottom) + _scrollBarPadding;contentSize = _layout.layout(content, layoutArea.width, layoutArea.height);
        }var requiresVScrollBar : Bool = contentSize.height > layoutArea.height;if (requiresVScrollBar && _autoHideVScrollBar) {layoutArea.width -= (vScrollBar.width - _paddingRight) + _scrollBarPadding;contentSize = _layout.layout(content, layoutArea.width, layoutArea.height);
        }requiresHScrollBar = contentSize.width > layoutArea.width;requiresVScrollBar = contentSize.height > layoutArea.height;vScrollBar.visible = _autoHideVScrollBar == false || requiresVScrollBar;hScrollBar.visible = _autoHideHScrollBar == false || requiresHScrollBar;vScrollBar.removeEventListener(Event.CHANGE, onChangeVScrollBar);vScrollBar.x = _width - vScrollBar.width;vScrollBar.height = _height;vScrollBar.max = contentSize.height - layoutArea.height;vScrollBar.thumbSizeRatio = (layoutArea.height / contentSize.height);vScrollBar.validateNow();vScrollBar.addEventListener(Event.CHANGE, onChangeVScrollBar);hScrollBar.removeEventListener(Event.CHANGE, onChangeHScrollBar);hScrollBar.y = _height;hScrollBar.height = _width;hScrollBar.max = Math.max(0, contentSize.width - layoutArea.width);hScrollBar.thumbSizeRatio = (layoutArea.width / contentSize.width);hScrollBar.validateNow();hScrollBar.addEventListener(Event.CHANGE, onChangeHScrollBar);content.x = layoutArea.x;content.y = layoutArea.y;var scrollRect : Rectangle = content.scrollRect;scrollRect.width = layoutArea.width;scrollRect.height = layoutArea.height;scrollRect.x = hScrollBar.value;scrollRect.y = vScrollBar.value;content.scrollRect = scrollRect;
    }  ////////////////////////////////////////////////    // Event handlers    ////////////////////////////////////////////////  private function onChangeVScrollBar(event : Event) : Void{invalidate();
    }private function onChangeHScrollBar(event : Event) : Void{invalidate();
    }private function mouseWheelHandler(event : MouseEvent) : Void{vScrollBar.value += vScrollBar.scrollSpeed * (event.delta < (0) ? 1 : -1);
    }  ////////////////////////////////////////////////    // Getters/Setters    ////////////////////////////////////////////////  private function set_ScrollBarPadding(value : Int) : Int{if (_scrollBarPadding == value)             return;_scrollBarPadding = value;invalidate();
        return value;
    }private function get_ScrollBarPadding() : Int{return _scrollBarPadding;
    }private function get_MaxScrollX() : Int{return hScrollBar.max;
    }private function get_MaxScrollY() : Int{return vScrollBar.max;
    }private function set_ScrollX(value : Int) : Int{hScrollBar.value = value;
        return value;
    }private function get_ScrollX() : Int{return hScrollBar.value;
    }private function set_ScrollY(value : Int) : Int{vScrollBar.value = value;
        return value;
    }private function get_ScrollY() : Int{return vScrollBar.value;
    }
}