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
 */  package core.ui.components;

import core.ui.components.ComponentFocusEvent;
import core.ui.components.PanelSkin;
import nme.display.MovieClip;import nme.events.Event;import nme.events.KeyboardEvent;import nme.events.MouseEvent;import nme.geom.Point;import nme.geom.Rectangle;import nme.text.TextField;import nme.ui.Keyboard;import core.ui.CoreUI;import core.ui.events.ComponentFocusEvent;import core.ui.events.SelectEvent;import core.ui.layouts.HorizontalLayout;import core.ui.layouts.LayoutAlign;import core.ui.managers.FocusManager;import core.ui.util.Scale9GridUtil;import flux.skins.PanelCloseBtnSkin;import flux.skins.PanelSkin;@:meta(Event(type="flash.events.Event",name="close"))
class Panel extends Container
{
    public var defaultButton(get, set) : Button;
    public var controlBar(get, never) : Container;
    public var titleBarHeight(get, set) : Int;
    public var showCloseButton(get, set) : Bool;
  // Properties  public var dragEnabled : Bool = false;private var _titleBarHeight : Int;private var _defaultButton : Button;  // Child elements  private var border : MovieClip;private var _controlBar : Container;private var titleField : TextField;private var closeBtn : Button;private var iconImage : Image;public function new()
    {
        super();
    }  ////////////////////////////////////////////////    // Protected methods    ////////////////////////////////////////////////  override private function init() : Void{border = new PanelSkin();if (!border.scale9Grid) {Scale9GridUtil.setScale9Grid(border, CoreUI.defaultPanelSkinScale9Grid);
        }_titleBarHeight = (border.scale9Grid) ? border.scale9Grid.top : 0;_minHeight = _titleBarHeight;addRawChild(border);super.init();_controlBar = new Container();_controlBar.layout = new HorizontalLayout(4, LayoutAlign.RIGHT);_controlBar.padding = 4;addRawChild(_controlBar);titleField = TextStyles.createTextField(true);addRawChild(titleField);closeBtn = new Button(PanelCloseBtnSkin);addRawChild(closeBtn);closeBtn.addEventListener(MouseEvent.CLICK, clickCloseBtnHandler);iconImage = new Image();addRawChild(iconImage);_width = border.width;_height = border.height;border.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownBackgroundHandler);showCloseButton = false;padding = 4;FocusManager.getInstance().addEventListener(ComponentFocusEvent.COMPONENT_FOCUS_IN, componentFocusInHandler);addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);addEventListener(Event.REMOVED_FROM_STAGE, removedFromStageHandler);
    }override private function validate() : Void{_controlBar.resizeToContentWidth = true;_controlBar.resizeToContentHeight = true;super.validate();iconImage.source = _icon;iconImage.validateNow();iconImage.y = (_titleBarHeight - iconImage.height) >> 1;iconImage.x = iconImage.y;_controlBar.resizeToContentWidth = false;_controlBar.resizeToContentHeight = false;_controlBar.width = _width;_controlBar.validateNow();_controlBar.y = _height - _controlBar.height;border.width = _width;border.height = _height;titleField.width = _width - (_paddingLeft + _paddingRight);titleField.text = _label;titleField.height = Math.min(titleField.textHeight + 4, _height);titleField.y = (_titleBarHeight - (titleField.height)) >> 1;titleField.x = iconImage.width > (0) ? iconImage.x + iconImage.width + 6 : titleField.y;closeBtn.y = (_titleBarHeight - closeBtn.height) >> 1;closeBtn.x = _width - closeBtn.width - closeBtn.y;
    }override private function getChildrenLayoutArea() : Rectangle{var rect : Rectangle = new Rectangle(_paddingLeft, _paddingTop, _width - (_paddingRight + _paddingLeft), _height - (_paddingBottom + _paddingTop));_controlBar.validateNow();rect.top += titleBarHeight;rect.bottom -= _controlBar.numChildren == (0) ? 0 : _controlBar.height;return rect;
    }public function componentFocusInHandler(event : ComponentFocusEvent) : Void{if (FocusManager.isFocusedItemAChildOf(this)) {border.gotoAndPlay("Active");
        }
        else {border.gotoAndPlay("Default");
        }
    }  ////////////////////////////////////////////////    // Event handlers    ////////////////////////////////////////////////  private function addedToStageHandler(event : Event) : Void{stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
    }private function removedFromStageHandler(event : Event) : Void{stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
    }private function keyDownHandler(event : KeyboardEvent) : Void{if (_defaultButton == null)             return;if (FocusManager.isFocusedItemAChildOf(this) == false)             return;if (event.keyCode == Keyboard.ENTER) {_defaultButton.dispatchEvent(new SelectEvent(SelectEvent.SELECT, null, true));
        }
    }private function mouseDownBackgroundHandler(event : MouseEvent) : Void{if (dragEnabled == false)             return;if (mouseY > _titleBarHeight)             return;var ptA : Point = new Point(0, 0);ptA = parent.globalToLocal(ptA);startDrag(false, new Rectangle(ptA.x, ptA.y, stage.width - _width, stage.height - _height));stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpStageHandler);
    }private function mouseUpStageHandler(event : MouseEvent) : Void{stopDrag();
    }private function clickCloseBtnHandler(event : MouseEvent) : Void{event.stopImmediatePropagation();dispatchEvent(new Event(Event.CLOSE));
    }  ////////////////////////////////////////////////    // Getters/Setters    ////////////////////////////////////////////////  private function set_DefaultButton(value : Button) : Button{_defaultButton = value;
        return value;
    }private function get_DefaultButton() : Button{return _defaultButton;
    }private function get_ControlBar() : Container{return _controlBar;
    }private function set_TitleBarHeight(value : Int) : Int{_titleBarHeight = value;invalidate();
        return value;
    }private function get_TitleBarHeight() : Int{return _titleBarHeight;
    }private function set_ShowCloseButton(value : Bool) : Bool{closeBtn.visible = value;
        return value;
    }private function get_ShowCloseButton() : Bool{return closeBtn.visible;
    }
}