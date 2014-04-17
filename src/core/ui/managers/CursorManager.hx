/**
 * CursorManager.as
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
 */package core.ui.managers;

import core.ui.managers.Application;
import core.ui.managers.Image;
import core.ui.managers.MouseEvent;
import nme.display.Stage;import nme.events.MouseEvent;import nme.ui.Mouse;import core.ui.components.Application;import core.ui.components.Image;import flux.cursors.BusyCursor;class CursorManager
{private static var instance : CursorManager;private var app : Application;private var cursor : Image;public function new(app : Application)
    {if (instance != null)             return;instance = this;this.app = app;app.cursorContainer.mouseEnabled = false;app.cursorContainer.mouseChildren = false;cursor = new Image();
    }public static function setCursor(source : Class<Dynamic>) : Void{instance.setCursor(source);
    }private function setCursor(source : Class<Dynamic>) : Void{cursor.source = source;if (source == null) {if (cursor.stage) {app.cursorContainer.removeChild(cursor);app.stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler, true);Mouse.show();return;
            }
        }if (cursor.stage == null && source != null) {app.cursorContainer.addChild(cursor);app.stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler, true);cursor.x = app.mouseX;cursor.y = app.mouseY;Mouse.hide();
        }
    }private function mouseMoveHandler(event : MouseEvent) : Void{cursor.x = app.mouseX;cursor.y = app.mouseY;event.updateAfterEvent();
    }
    private static var init = {
        BusyCursor;
    }

}