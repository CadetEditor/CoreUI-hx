  /**
 * Tree.as
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
  
package core.ui.managers;

import flash.display.Stage;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.utils.Timer;
import core.ui.components.Application;
import core.ui.components.ToolTip;
import core.ui.components.UIComponent;

class ToolTipManager
{
	private var app : Application;
	private var toolTip : ToolTip;
	private var delayTimer : Timer;
	private var rolledOverComponent : UIComponent;
	private var rollOutTime : Int;
	
	public function new(app : Application)
    {
		this.app = app;
		app.stage.addEventListener(MouseEvent.ROLL_OVER, rollOverHandler, true);
		app.stage.addEventListener(MouseEvent.ROLL_OUT, rollOutHandler, true);
		toolTip = new ToolTip();
		delayTimer = new Timer(400, 1);
		delayTimer.addEventListener(TimerEvent.TIMER_COMPLETE, delayCompleteHandler);
    }
	
	private function rollOverHandler(event : MouseEvent) : Void
	{
		if (Std.is(event.target, UIComponent) == false) return;
		var comp : UIComponent = cast((event.target), UIComponent);
		if (comp.toolTip == "" || comp.toolTip == null) return;
		rolledOverComponent = comp;
		if ((Math.round(haxe.Timer.stamp() * 1000) - rollOutTime) < 100) {
			delayCompleteHandler(null);
			return;
        }
		delayTimer.reset();
		delayTimer.start();
    }
	
	private function rollOutHandler(event : MouseEvent) : Void
	{
		if (Std.is(event.target, UIComponent) == false) return;
		rolledOverComponent = null;
		delayTimer.stop();
		if (toolTip.stage != null) {
			app.toolTipContainer.removeChild(toolTip);
			rollOutTime = Math.round(haxe.Timer.stamp() * 1000);
        }
    }
	
	private function delayCompleteHandler(event : TimerEvent) : Void
	{
		toolTip.text = rolledOverComponent.toolTip;
		toolTip.validateNow();
		app.toolTipContainer.addChild(toolTip);
		toolTip.x = app.mouseX + 16;
		toolTip.y = app.mouseY + 20;
		toolTip.x = Math.min(toolTip.x, app.stage.stageWidth - toolTip.width);
		toolTip.y = Math.min(toolTip.y, app.stage.stageHeight - toolTip.height);
    }
}