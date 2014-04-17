  /**
 * UIComponent.as
 *
 * Base class for all components
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

import nme.display.Sprite;import nme.events.Event;import nme.events.MouseEvent;import core.events.PropertyChangeEvent;import core.ui.events.ResizeEvent;import core.ui.managers.FocusManager;@:meta(Event(type="flash.events.Event",name="resize"))
@:meta(Event(type="core.ui.events.ComponentFocusEvent",name="componentFocusIn"))
@:meta(Event(type="core.ui.events.ComponentFocusEvent",name="componentFocusOut"))
class UIComponent extends Sprite implements IUIComponent
{
    public var percentWidth(get, set) : Float;
    public var percentHeight(get, set) : Float;
    public var label(get, set) : String;
    public var icon(get, set) : Dynamic;
    public var enabled(get, set) : Bool;
    public var resizeToContentWidth(get, set) : Bool;
    public var resizeToContentHeight(get, set) : Bool;
    public var excludeFromLayout(get, set) : Bool;
    public var focusEnabled(get, set) : Bool;
    public var toolTip(get, set) : String;
  // Properties  private var _width : Float = 0;private var _height : Float = 0;private var _minWidth : Float = 0;private var _minHeight : Float = 0;private var _percentWidth : Float = NaN;private var _percentHeight : Float = NaN;private var _label : String = "";private var _toolTip : String;private var _icon : Dynamic;private var _excludeFromLayout : Bool = false;private var _resizeToContentWidth : Bool = false;private var _resizeToContentHeight : Bool = false;private var _enabled : Bool = true;private var _isInvalid : Bool = false;private var _focusEnabled : Bool = false;public function new()
    {
        super();_init();
    }private function _init() : Void{init();invalidate();
    }  ////////////////////////////////////////////////    // Public methods    ////////////////////////////////////////////////  public function invalidate() : Void{if (_isInvalid)             return;_isInvalid = true;addEventListener(Event.ENTER_FRAME, onInvalidateHandler);
    }public function isInvalid() : Bool{return _isInvalid;
    }public function validateNow() : Void{if (_isInvalid == false)             return;validate();_isInvalid = false;removeEventListener(Event.ENTER_FRAME, onInvalidateHandler);
    }public function onGainComponentFocus() : Void{
    }public function onLoseComponentFocus() : Void{
    }  ////////////////////////////////////////////////    // Protected methods    ////////////////////////////////////////////////    /**
		 * Override this method to perform one-time init logic, such as creating children.
		 */  private function init() : Void{
    }  /**
		 * Override this method to do any work required to validate the component.
		 */  private function validate() : Void{
    }  ////////////////////////////////////////////////    // Event Handlers    ////////////////////////////////////////////////  private function mouseDownHandler(event : MouseEvent) : Void{if (FocusManager.isFocusedItemAChildOf(this))             return;var target : UIComponent = try cast(event.target, UIComponent) catch(e:Dynamic) null;if (target != null && target != this && target.focusEnabled)             return;FocusManager.setFocus(this);
    }private function onInvalidateHandler(event : Event) : Void{validateNow();
    }  ////////////////////////////////////////////////    // Getters/Setters    ////////////////////////////////////////////////  override private function set_Width(value : Float) : Float{value = Math.round(value < (_minWidth != 0) ? _minWidth : value);if (value == _width)             return;_width = value;invalidate();dispatchEvent(new ResizeEvent(ResizeEvent.RESIZE, true));
        return value;
    }override private function get_Width() : Float{return _width;
    }override private function set_Height(value : Float) : Float{value = Math.round(value < (_minHeight != 0) ? _minHeight : value);if (value == _height)             return;_height = value;invalidate();dispatchEvent(new ResizeEvent(ResizeEvent.RESIZE, true));
        return value;
    }override private function get_Height() : Float{return _height;
    }private function set_PercentWidth(value : Float) : Float{if (Math.isNaN(value)) {_percentWidth = NaN;
        }
        else {_percentWidth = value < (0) ? 0 : value;
        }invalidate();dispatchEvent(new ResizeEvent(ResizeEvent.RESIZE, true));
        return value;
    }private function get_PercentWidth() : Float{return _percentWidth;
    }private function set_PercentHeight(value : Float) : Float{if (Math.isNaN(value)) {_percentHeight = NaN;
        }
        else {_percentHeight = value < (0) ? 0 : value;
        }invalidate();dispatchEvent(new ResizeEvent(ResizeEvent.RESIZE, true));
        return value;
    }private function get_PercentHeight() : Float{return _percentHeight;
    }override private function set_X(value : Float) : Float{value = Math.round(value);if (value == x)             return;super.x = value;
        return value;
    }override private function set_Y(value : Float) : Float{value = Math.round(value);if (value == y)             return;super.y = value;
        return value;
    }private function set_Label(value : String) : String{if (_label == value)             return;var oldValue : String = _label;_label = value;invalidate();dispatchEvent(new PropertyChangeEvent("propertyChange_label", oldValue, value));
        return value;
    }private function get_Label() : String{return _label;
    }private function set_Icon(value : Dynamic) : Dynamic{if (_icon == value)             return;var oldValue : Dynamic = _icon;_icon = value;invalidate();dispatchEvent(new PropertyChangeEvent("propertyChange_icon", oldValue, value));
        return value;
    }private function get_Icon() : Dynamic{return _icon;
    }private function set_Enabled(value : Bool) : Bool{if (value == _enabled)             return;_enabled = value;mouseEnabled = value;mouseChildren = value;alpha = (value) ? 1 : 0.5;
        return value;
    }private function get_Enabled() : Bool{return _enabled;
    }private function set_ResizeToContentWidth(value : Bool) : Bool{if (value == _resizeToContentWidth)             return;_resizeToContentWidth = value;invalidate();
        return value;
    }private function get_ResizeToContentWidth() : Bool{return _resizeToContentWidth;
    }private function set_ResizeToContentHeight(value : Bool) : Bool{if (value == _resizeToContentHeight)             return;_resizeToContentHeight = value;invalidate();
        return value;
    }private function get_ResizeToContentHeight() : Bool{return _resizeToContentHeight;
    }private function set_ExcludeFromLayout(value : Bool) : Bool{if (value == _excludeFromLayout)             return;_excludeFromLayout = value;dispatchEvent(new ResizeEvent(ResizeEvent.RESIZE, true));
        return value;
    }private function get_ExcludeFromLayout() : Bool{return _excludeFromLayout;
    }private function set_FocusEnabled(value : Bool) : Bool{if (_focusEnabled == value)             return;_focusEnabled = value;if (_focusEnabled) {addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
        }
        else {removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
        }
        return value;
    }private function get_FocusEnabled() : Bool{return _focusEnabled;
    }private function get_ToolTip() : String{return _toolTip;
    }private function set_ToolTip(value : String) : String{_toolTip = value;
        return value;
    }
}