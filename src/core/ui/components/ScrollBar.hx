  /**
 * ScrollBar.as
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

import core.ui.components.UIComponent;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.utils.Timer;
import core.ui.CoreUI;
import core.ui.util.Scale9GridUtil;

class ScrollBar extends UIComponent
{
    public var value(get, set) : Float;
    public var max(get, set) : Float;
    public var thumbSizeRatio(get, set) : Float;
    public var scrollSpeed(get, set) : Float;
    public var pageScrollSpeed(get, set) : Float;
    public var thumbVerticalPadding(get, set) : Int;
	
	private static inline var DELAY_TIME : Int = 400;
	private static inline var REPEAT_TIME : Int = 80;  
	
	// Styles  
	
	public static var styleThumbVerticalPadding : Int = -1;  
	
	// Properties  
	
	private var _value : Float = 0;
	private var _max : Float = 10;
	private var _thumbSizeRatio : Float = 0.5;
	private var _scrollSpeed : Float = 1;
	private var _pageScrollSpeed : Float = 4;
	private var _thumbVerticalPadding : Int = styleThumbVerticalPadding;  
	
	// Child elements  
	
	private var track : Sprite;
	private var thumb : Button;
	private var upBtn : Button;
	private var downBtn : Button;  
	
	// Internal vars  
	
	private var repeatSpeed : Int;
	private var dragStartRatio : Float;
	private var dragStartValue : Int;
	private var delayTimer : Timer;
	private var repeatTimer : Timer;
	private var defaultUpBtnHeight : Float;
	private var defaultDownBtnHeight : Float;
	
	public function new()
    {
        super();
    }  
	
	////////////////////////////////////////////////    
	// Protected methods    
	////////////////////////////////////////////////  
	
	override private function init() : Void
	{
		track = new ScrollBarTrackSkin();
		addChild(track);
		_width = track.width;
		_height = track.height;
		track.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownTrackHandler);
		thumb = new Button(ScrollBarThumbSkin);
		
		if (!thumb.scale9Grid) {
			Scale9GridUtil.setScale9Grid(thumb, CoreUI.defaultScrollBarThumbSkinScale9Grid);
        }
		
		thumb.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownThumbHandler);
		thumb.focusEnabled = false; addChild(thumb);
		upBtn = new Button(ScrollBarUpButtonSkin);
		upBtn.focusEnabled = false;
		defaultUpBtnHeight = upBtn.height; 
		addChild(upBtn);
		downBtn = new Button(ScrollBarDownButtonSkin);
		downBtn.focusEnabled = false;
		defaultDownBtnHeight = downBtn.height;
		addChild(downBtn);
		upBtn.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownBtnHandler);
		upBtn.addEventListener(MouseEvent.ROLL_OUT, endScrollRepeatHandler);
		downBtn.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownBtnHandler);
		downBtn.addEventListener(MouseEvent.ROLL_OUT, endScrollRepeatHandler);
		delayTimer = new Timer(DELAY_TIME, 1);
		delayTimer.addEventListener(TimerEvent.TIMER_COMPLETE, delayCompleteHandler);
		repeatTimer = new Timer(REPEAT_TIME, 0);
		repeatTimer.addEventListener(TimerEvent.TIMER, repeatHandler);
    }
	
	override private function validate() : Void
	{
		if (_height < defaultUpBtnHeight + defaultDownBtnHeight) {
			var ratio : Float = _height / (defaultUpBtnHeight + defaultDownBtnHeight);
			upBtn.height = defaultUpBtnHeight * ratio;downBtn.height = _height - upBtn.height;
        } else {
			upBtn.height = defaultUpBtnHeight;
			downBtn.height = defaultDownBtnHeight;
        }
		
		track.y = upBtn.height;
		track.height = _height - (upBtn.height + downBtn.height);
		downBtn.y = track.y + track.height;
		thumb.height = track.height * _thumbSizeRatio;
		thumb.validateNow();
		var lineRatio : Float = _value / _max;
		lineRatio = (Math.isNaN(lineRatio)) ? 0 : lineRatio;thumb.y = (upBtn.height + _thumbVerticalPadding) + (track.height - thumb.height - _thumbVerticalPadding * 2) * lineRatio;
    }  
	
	////////////////////////////////////////////////    
	// Event handlers    
	////////////////////////////////////////////////  
	
	private function mouseDownBtnHandler(event : MouseEvent) : Void
	{
		repeatSpeed = event.target == (upBtn != null) ? -_scrollSpeed : _scrollSpeed; value += repeatSpeed; delayTimer.start();
		stage.addEventListener(MouseEvent.MOUSE_UP, endScrollRepeatHandler);
    }
	
	private function mouseDownTrackHandler(event : MouseEvent) : Void
	{
		repeatSpeed = mouseY < (thumb.y) ? -_pageScrollSpeed : _pageScrollSpeed;
		value += repeatSpeed; 
		delayTimer.start();
		track.addEventListener(MouseEvent.ROLL_OUT, endScrollRepeatHandler);
		stage.addEventListener(MouseEvent.MOUSE_UP, endScrollRepeatHandler);
    }
	
	private function endScrollRepeatHandler(event : MouseEvent) : Void
	{
		track.removeEventListener(MouseEvent.ROLL_OUT, endScrollRepeatHandler);
		stage.removeEventListener(MouseEvent.MOUSE_UP, endScrollRepeatHandler);
		delayTimer.stop();repeatTimer.stop();
    }
	
	private function mouseDownThumbHandler(event : MouseEvent) : Void
	{
		dragStartValue = _value;
		dragStartRatio = (mouseY - track.y) / (track.height - thumb.height);
		dragStartRatio = Math.isNaN(dragStartRatio) || dragStartRatio == Infinity || dragStartRatio == -(Infinity) ? 0 : dragStartRatio;
		stage.addEventListener(MouseEvent.MOUSE_UP, endThumbDragHandler);
		stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
    }
	
	private function mouseMoveHandler(event : MouseEvent) : Void
	{
		var currentDragRatio : Float = (mouseY - track.y) / (track.height - thumb.height);
		currentDragRatio = Math.isNaN(currentDragRatio) || currentDragRatio == Infinity || currentDragRatio == -(Infinity) ? 0 : currentDragRatio;
		var ratioOffset : Float = currentDragRatio - dragStartRatio;
		value = dragStartValue + ratioOffset * _max;event.updateAfterEvent();
    }
	
	private function endThumbDragHandler(event : MouseEvent) : Void
	{
		if (stage == null) return;
		stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
		stage.removeEventListener(MouseEvent.MOUSE_UP, endScrollRepeatHandler);
		stage.removeEventListener(MouseEvent.MOUSE_UP, endThumbDragHandler);
    }
	
	private function delayCompleteHandler(event : TimerEvent) : Void
	{
		repeatTimer.start();
    }
	
	private function repeatHandler(event : TimerEvent) : Void
	{
		value += repeatSpeed;
    }  
	
	////////////////////////////////////////////////    
	// Getters/Setters    
	////////////////////////////////////////////////  
	
	private function set_Value(v : Float) : Float
	{
		v = v < (0) ? 0 : v > (_max != 0) ? _max : v;
		if (v == _value) return;
		_value = v;
		invalidate();
		dispatchEvent(new Event(Event.CHANGE));
        return v;
    }
	
	private function get_Value() : Float
	{
		return _value;
    }
	
	private function set_Max(v : Float) : Float
	{
		v = v < (0) ? 0 : v;
		if (v == _max) return;
		_max = v;
		if (_value > _max) {
			_value = _max;
        }
		invalidate();
        return v;
    }
	
	private function get_Max() : Float
	{
		return _max;
    }
	
	private function set_ThumbSizeRatio(v : Float) : Float
	{
		v = v < (0) ? 0 : v > (1) ? 1 : v;
		if (v == _thumbSizeRatio) return;
		_thumbSizeRatio = v;
		invalidate();
        return v;
    }
	
	private function get_ThumbSizeRatio() : Float
	{
		return _thumbSizeRatio;
    }
	
	private function set_ScrollSpeed(v : Float) : Float
	{
		if (v < 0) return;
		_scrollSpeed = v;
        return v;
    }
	
	private function get_ScrollSpeed() : Float
	{
		return _scrollSpeed;
    }
	
	private function set_PageScrollSpeed(v : Float) : Float
	{
		if (v < 0) return;
		_pageScrollSpeed = v;
        return v;
    }
	
	private function get_PageScrollSpeed() : Float
	{
		return _pageScrollSpeed;
    }
	
	private function get_ThumbVerticalPadding() : Int
	{
		return _thumbVerticalPadding;
    }
	
	private function set_ThumbVerticalPadding(value : Int) : Int
	{
		if (value == _thumbVerticalPadding) return;
		_thumbVerticalPadding = value;
		invalidate();
        return value;
    }
}