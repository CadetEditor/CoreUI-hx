  /**
 * Application.as
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
  
package core.ui.components;

import core.ui.components.Container;
import core.ui.components.CursorManager;
import core.ui.components.Event;
import core.ui.components.FocusManager;
import core.ui.components.Sprite;
import core.ui.components.ToolTipManager;
import nme.errors.Error;
import nme.display.Sprite;
import nme.display.StageAlign;
import nme.display.StageScaleMode;
import nme.events.Event;
import nme.system.ApplicationDomain;
import core.ui.managers.CursorManager;
import core.ui.managers.FocusManager;
import core.ui.managers.PopUpManager;
import core.ui.managers.ToolTipManager;

class Application extends Container
{
    public var popUpContainer(get, never) : Sprite;
    public var toolTipContainer(get, never) : Sprite;
    public var cursorContainer(get, never) : Sprite;
	private static var instance : Application;
	
	public static function getInstance() : Application
	{
		return instance;
    }  
	
	// Properties  
	public var focusManager : FocusManager;
	public var cursorManager : CursorManager;
	public var toolTipManager : ToolTipManager;
	public var popUpManager : PopUpManager;  
	
	// Child elements  
	private var _popUpContainer : Sprite;
	private var _toolTipContainer : Sprite;
	private var disableSheet : Sprite;
	private var _cursorContainer : Sprite;
	
	public function new()
    {
        super();
    }
	
	override private function init() : Void
	{
		if (instance != null) {
			throw (new Error("Only one instance of Application allowed"));
			return;
        }
		
		instance = this; 
		super.init();
		_popUpContainer = new Sprite();
		_toolTipContainer = new Sprite();
		disableSheet = new Sprite();
		disableSheet.graphics.beginFill(0, 0);
		disableSheet.graphics.drawRect(0, 0, 10, 10);
		disableSheet.visible = false;
		_cursorContainer = new Sprite();
		addRawChild(_popUpContainer);
		addRawChild(_toolTipContainer);
		addRawChild(disableSheet);
		addRawChild(_cursorContainer);
		
		if (stage) {
			init2();
        } else {
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
        }
		
    }
	
	override private function validate() : Void
	{
		super.validate();
		disableSheet.width = _width;
		disableSheet.height = _height;
    }
	
	private function addedToStageHandler(event : Event) : Void
	{
		if (event.target != this) return;
		removeEventListener(Event.ADDED, addedToStageHandler);
		init2();
    }
	
	private function init2() : Void
	{
		popUpManager = new PopUpManager(this);
		toolTipManager = new ToolTipManager(this);
		cursorManager = new CursorManager(this);
		focusManager = new FocusManager();
		stage.scaleMode = StageScaleMode.NO_SCALE;
		stage.align = StageAlign.TOP_LEFT;
		stage.addEventListener(Event.RESIZE, stageResizeHandler);
		stageResizeHandler();
    }
	
	private function stageResizeHandler(event : Event = null) : Void
	{
		if (event != null && event.target != stage) return;
		_width = stage.stageWidth; _height = stage.stageHeight;
		invalidate();
		validateNow();
    }
	
	private function get_PopUpContainer() : Sprite
	{
		return _popUpContainer;
    }
	
	private function get_ToolTipContainer() : Sprite
	{
		return _toolTipContainer;
    }
	
	private function get_CursorContainer() : Sprite
	{
		return _cursorContainer;
    }
	
	override private function set_Enabled(value : Bool) : Bool
	{
		if (value == _enabled) return;
		_enabled = value;
		
		if (_enabled) {
			disableSheet.visible = !_enabled;invalidate();
        }
        return value;
    }
}