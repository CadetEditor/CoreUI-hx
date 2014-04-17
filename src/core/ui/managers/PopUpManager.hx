  /**
 * PopUpManager.as
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

import core.ui.managers.Dictionary;
import core.ui.managers.Sprite;
import nme.display.Bitmap;import nme.display.DisplayObject;import nme.display.Sprite;import nme.display.Stage;import nme.events.Event;import nme.events.EventDispatcher;import nme.utils.Dictionary;import core.ui.components.Application;import core.ui.components.UIComponent;class PopUpManager extends EventDispatcher
{private static var instance : PopUpManager;private var app : Application;private var modalCover : Sprite;private var isModalTable : Dictionary;public var modal : Bool;public function new(app : Application)
    {
        super();if (instance != null)             return;instance = this;this.app = app;app.stage.addEventListener(Event.RESIZE, resizeStageHandler);isModalTable = new Dictionary(true);modalCover = new Sprite();
    }public function addPopUp(popUp : DisplayObject, modal : Bool = false, center : Bool = true) : Void{Reflect.setField(isModalTable, Std.string(popUp), modal);app.popUpContainer.addChild(popUp);if (modal) {if (modalCover.parent) {modalCover.parent.removeChild(modalCover);
            }var index : Int = app.popUpContainer.getChildIndex(popUp);app.popUpContainer.addChildAt(modalCover, index);updateModalCover();if (Std.is(popUp, UIComponent) && cast((popUp), UIComponent).focusEnabled) {FocusManager.setFocus(cast((popUp), UIComponent));
            }
        }if (center) {popUp.x = (app.stage.stageWidth - popUp.width) >> 1;popUp.y = (app.stage.stageHeight - popUp.height) >> 1;
        }
        // Limit to stage
        else {popUp.x = Math.min(app.stage.stageWidth - popUp.width, popUp.x);popUp.x = Math.max(0, popUp.x);popUp.y = Math.min(app.stage.stageHeight - popUp.height, popUp.y);popUp.y = Math.max(0, popUp.y);
        }this.modal = modal;dispatchEvent(new Event(Event.CHANGE));
    }public function removePopUp(popUp : DisplayObject) : Void{app.popUpContainer.removeChild(popUp);;var stillModal : Bool = false;for (i in 0...app.popUpContainer.numChildren){var child : DisplayObject = app.popUpContainer.getChildAt(i);var isModal : Bool = Reflect.field(isModalTable, Std.string(child));if (isModal) {stillModal = true;if (!modalCover.stage) {app.popUpContainer.addChildAt(modalCover, i);
                }break;
            }
        }if (!stillModal && modalCover.stage) {app.popUpContainer.removeChild(modalCover);
        }modal = stillModal;dispatchEvent(new Event(Event.CHANGE));
    }private function resizeStageHandler(event : Event) : Void{if (event.target != app.stage)             return;updateModalCover();
    }private function updateModalCover() : Void{if (modalCover.stage == null)             return;modalCover.graphics.clear();modalCover.graphics.beginFill(0x000000, 0.4);modalCover.graphics.drawRect(0, 0, app.stage.stageWidth, app.stage.stageHeight);
    }public static function addPopUp(popUp : DisplayObject, modal : Bool = false, center : Bool = true) : Void{instance.addPopUp(popUp, modal, center);
    }public static function removePopUp(popUp : DisplayObject) : Void{instance.removePopUp(popUp);
    }
}