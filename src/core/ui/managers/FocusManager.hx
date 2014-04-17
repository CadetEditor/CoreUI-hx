  /**
 * InputField.as
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
 */  package core.ui.managers;

import core.ui.managers.ComponentFocusEvent;
import core.ui.managers.DisplayObject;
import core.ui.managers.Event;
import core.ui.managers.EventDispatcher;
import core.ui.managers.UIComponent;
import nme.display.DisplayObject;import nme.display.Stage;import nme.events.Event;import nme.events.EventDispatcher;import core.ui.components.Application;import core.ui.components.UIComponent;import core.ui.events.ComponentFocusEvent;class FocusManager extends EventDispatcher
{private static var instance : FocusManager;public static function getInstance() : FocusManager{return instance;
    }private var focusedComponent : UIComponent;public function new()
    {
        super();if (instance != null)             return;instance = this;
    }public static function setFocus(value : UIComponent) : Void{instance.setFocus(value);
    }public static function getCurrentFocus() : UIComponent{return instance.getCurrentFocus();
    }public static function isFocusedItemAChildOf(parent : UIComponent) : Bool{return instance.isFocusedItemAChildOf(parent);
    }public function setFocus(value : UIComponent) : Void{  // Walk up the display list until we hit a component that can be focused.  var comp : DisplayObject = value;while (true){if (comp == null)                 return;if (Std.is(comp, UIComponent) == false) {comp = comp.parent;continue;
            }if (cast((comp), UIComponent).focusEnabled == false) {comp = comp.parent;continue;
            }break;
        }value = cast((comp), UIComponent);if (value == focusedComponent)             return;trace("FocusManager.setFocus() : " + value);  //trace(value);  var previouslyFocusedComponent : UIComponent = focusedComponent;if (previouslyFocusedComponent != null) {focusedComponent.removeEventListener(Event.REMOVED_FROM_STAGE, focusedComponentRemovedFromStageHandler);previouslyFocusedComponent.onLoseComponentFocus();previouslyFocusedComponent.dispatchEvent(new ComponentFocusEvent(ComponentFocusEvent.COMPONENT_FOCUS_OUT, value, false, false));dispatchEvent(new ComponentFocusEvent(ComponentFocusEvent.COMPONENT_FOCUS_OUT, previouslyFocusedComponent, false, false));
        }focusedComponent = value;if (focusedComponent != null) {focusedComponent.onGainComponentFocus();focusedComponent.dispatchEvent(new ComponentFocusEvent(ComponentFocusEvent.COMPONENT_FOCUS_IN, previouslyFocusedComponent, false, false));focusedComponent.addEventListener(Event.REMOVED_FROM_STAGE, focusedComponentRemovedFromStageHandler);dispatchEvent(new ComponentFocusEvent(ComponentFocusEvent.COMPONENT_FOCUS_IN, focusedComponent, false, false));
        }
    }public function getCurrentFocus() : UIComponent{return focusedComponent;
    }public function isFocusedItemAChildOf(parent : UIComponent) : Bool{if (focusedComponent == null)             return false;var currentItem : DisplayObject = focusedComponent;while (currentItem){if (currentItem == parent)                 return true;currentItem = currentItem.parent;
        }return false;
    }private function focusedComponentRemovedFromStageHandler(event : Event) : Void{setFocus(null);
    }
}