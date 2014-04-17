  /**
 * VDividedBox.as
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
 * * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */  
  
package core.ui.components;

import core.ui.components.HDividerThumbSkin;
import nme.display.DisplayObject;
import nme.display.Sprite;
import nme.events.Event;
import nme.events.MouseEvent;
import nme.geom.Rectangle;
import nme.ui.Mouse;
import nme.ui.MouseCursor;
import core.ui.events.ResizeEvent;
import core.ui.layouts.VerticalLayout;
import core.ui.managers.CursorManager;
import flux.cursors.VerticalResizeCursor;
import flux.skins.HDividerThumbSkin;

class VDividedBox extends VBox
{  
	
	// Child elements  
	
	private var dividers : Sprite;  
	
	// Internal vars  
	
	private var mouseDownPos : Int;
	private var storedChildSize : Int;
	private var storedPercentSize : Int;
	private var draggedChild : DisplayObject;
	private var isProportionalDrag : Bool;
	private var _over : Bool = false;
	
	public function new()
    {
        super();
    }
	
	override private function init() : Void
	{
		super.init();
		cast((_layout), VerticalLayout).spacing = 10;
		dividers = new Sprite();
		addRawChild(dividers);
		dividers.addEventListener(MouseEvent.ROLL_OVER, rollOverDividersHandler);
		dividers.addEventListener(MouseEvent.ROLL_OUT, rollOutDividersHandler);
		dividers.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownDividersHandler);
    }
	
	override private function validate() : Void
	{
		super.validate();
		dividers.x = content.x;
		dividers.y = content.y;
		
		for (i in 0...numChildren) {
			var child : DisplayObject = getChildAt(i);
			var divider : Sprite; 
			var thumb : Sprite;
			if (i >= dividers.numChildren) {
				divider = cast((dividers.addChild(new Sprite())), Sprite);
				thumb = new HDividerThumbSkin();
				thumb.mouseEnabled = false;
				divider.addChild(thumb);
            } else {
				divider = cast((dividers.getChildAt(i)), Sprite);
				thumb = cast((divider.getChildAt(0)), Sprite);
            }
			var dividerHeight : Int = cast((_layout), VerticalLayout).spacing; 
			divider.y = child.y + child.height;
			divider.graphics.clear();
			divider.graphics.beginFill(0xFF0000, 0);
			divider.graphics.drawRect(0, 0, _width, dividerHeight);
			thumb.x = (_width - thumb.width) >> 1;
			thumb.y = (dividerHeight - thumb.height) >> 1;
        } 
		
		while (dividers.numChildren > numChildren) {
			dividers.removeChildAt(dividers.numChildren - 1);
        }
		
		_height += numChildren > (0) ? cast((_layout), VerticalLayout).spacing : 0;
    }
	
	private function rollOverDividersHandler(event : MouseEvent) : Void
	{
		_over = true;
		CursorManager.setCursor(VerticalResizeCursor);
    }
	
	private function rollOutDividersHandler(event : MouseEvent) : Void
	{
		_over = false; 
		if (draggedChild == null) {
			draggedChild = null;CursorManager.setCursor(null);
        }
    }
	
	private function mouseDownDividersHandler(event : MouseEvent) : Void
	{
		var draggedDividerIndex : Int = dividers.getChildIndex(cast((event.target), Sprite));
		draggedChild = getChildAt(draggedDividerIndex);
		
		if (Std.is(draggedChild, UIComponent) && Math.isNaN(cast((draggedChild), UIComponent).percentHeight) == false) {
			isProportionalDrag = true;
			storedPercentSize = cast((draggedChild), UIComponent).percentHeight;
        } else {
			isProportionalDrag = false;
        }
		
		storedChildSize = draggedChild.height;
		mouseDownPos = stage.mouseY;
		stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
		stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpStageHandler);
    }
	
	private function mouseMoveHandler(event : MouseEvent) : Void
	{
		var delta : Float = (stage.mouseY - mouseDownPos);
		if (isProportionalDrag) {
			var newHeight : Float = storedChildSize + delta;
			var ratio : Float = newHeight / storedChildSize;cast((draggedChild), UIComponent).percentHeight = storedPercentSize * ratio;
        } else {
			draggedChild.height = storedChildSize + delta;
        }
		invalidate();
		validateNow();
		dispatchEvent(new ResizeEvent(ResizeEvent.RESIZE, true));
    }
	
	private function mouseUpStageHandler(event : MouseEvent) : Void
	{
		if (!_over) {
			CursorManager.setCursor(null);
        }
		draggedChild = null;
		stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
		stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpStageHandler);
    }
}