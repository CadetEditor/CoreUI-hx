  /**
 * NumericStepper.as
 * 
 * Wraps a NumberInputField and provides up/down buttons for changing the value with the mouse.
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

import core.ui.components.Timer;
import core.ui.components.TimerEvent;
import core.ui.components.UIComponent;
import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.utils.Timer;
import core.ui.events.ItemEditorEvent;
import core.events.PropertyChangeEvent;
import core.ui.managers.FocusManager;
import flux.skins.NumericStepperDownBtnSkin;
import flux.skins.NumericStepperUpBtnSkin;

class NumericStepper extends UIComponent
{
    public var stepSize(get, set) : Float;
    public var value(get, set) : Float;
    public var min(get, set) : Float;
    public var max(get, set) : Float;
    public var numDecimalPlaces(get, set) : Int;
    public var gap(get, set) : Int;
	
	private static inline var DELAY_TIME : Int = 500;
	private static inline var REPEAT_TIME : Int = 100;  
	
	// Styles  
	
	public static var styleGap : Int = -1;  
	
	// Properties  
	
	private var _stepSize : Float = 1;
	private var _gap : Int = styleGap;  
	
	// Child elements  
	
	private var inputField : NumberInput;	
	private var upBtn : Button;
	private var downBtn : Button;  
	
	// Internal vars  
	
	private var delayTimer : Timer;
	private var repeatTimer : Timer;
	private var repeatDirection : Float;
	
	public function new()
    {
        super();
    }  
	
	////////////////////////////////////////////////    
	// Protected methods    
	////////////////////////////////////////////////  
	
	override private function init() : Void
	{
		focusEnabled = true;
		inputField = new NumberInput();
		inputField.focusEnabled = false;
		inputField.addEventListener(Event.CHANGE, onInputFieldChange);
		inputField.addEventListener(ItemEditorEvent.COMMIT_VALUE, onInputFieldCommitValue);
		addChild(inputField);
		_width = inputField.width;
		_height = inputField.height;
		upBtn = new Button(NumericStepperUpBtnSkin);
		upBtn.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownButtonHandler);
		upBtn.focusEnabled = false; 
		addChild(upBtn);
		downBtn = new Button(NumericStepperDownBtnSkin);
		downBtn.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownButtonHandler);
		downBtn.focusEnabled = false; 
		addChild(downBtn);
		delayTimer = new Timer(DELAY_TIME, 1);
		delayTimer.addEventListener(TimerEvent.TIMER_COMPLETE, delayCompleteHandler);
		repeatTimer = new Timer(REPEAT_TIME, 0);
		repeatTimer.addEventListener(TimerEvent.TIMER, repeatHandler);
    }
	
	override private function validate() : Void
	{
		inputField.width = (_width - upBtn.width) - _gap;
		inputField.height = _height;
		inputField.validateNow();
		upBtn.height = _height >> 1;
		upBtn.x = inputField.width + _gap;
		downBtn.height = _height - upBtn.height;
		downBtn.x = upBtn.x;
		downBtn.y = upBtn.height;
    }
	
	override public function onGainComponentFocus() : Void
	{
		inputField.onGainComponentFocus();
    }
	
	override public function onLoseComponentFocus() : Void
	{
		inputField.onLoseComponentFocus();
    }  
	
	////////////////////////////////////////////////    
	// Event Handlers    
	////////////////////////////////////////////////  
	
	private function onInputFieldChange(event : Event) : Void
	{
		dispatchEvent(new Event(Event.CHANGE));
    }
	
	private function onInputFieldCommitValue(event : ItemEditorEvent) : Void
	{
		dispatchEvent(new ItemEditorEvent(ItemEditorEvent.COMMIT_VALUE, event.value, "value"));
    }
	
	private function mouseDownButtonHandler(event : MouseEvent) : Void
	{
		repeatDirection = event.target == (upBtn != null) ? 1 : -1;
		value += repeatDirection * _stepSize;
		delayTimer.start();
		stage.addEventListener(MouseEvent.MOUSE_UP, endRepeatHandler);
		event.target.addEventListener(MouseEvent.ROLL_OUT, endRepeatHandler);
    }
	
	private function endRepeatHandler(event : MouseEvent) : Void
	{
		upBtn.removeEventListener(MouseEvent.ROLL_OUT, endRepeatHandler);
		downBtn.removeEventListener(MouseEvent.ROLL_OUT, endRepeatHandler);
		stage.removeEventListener(MouseEvent.MOUSE_UP, endRepeatHandler);
		delayTimer.stop();
		repeatTimer.stop();
    }
	
	private function delayCompleteHandler(event : TimerEvent) : Void
	{
		repeatTimer.start();
    }
	
	private function repeatHandler(event : TimerEvent) : Void
	{
		value += repeatDirection * _stepSize;
    }  
	
	////////////////////////////////////////////////    
	// Getters/Setters    
	////////////////////////////////////////////////  
	
	private function set_StepSize(v : Float) : Float
	{
		_stepSize = v;
        return v;
    }
	
	private function get_StepSize() : Float
	{
		return _stepSize;
    }
	
	private function set_Value(v : Float) : Float
	{
		if (v == inputField.value) return;
		var oldValue : Float = inputField.value;
		inputField.value = v;
		if (inputField.value == oldValue) return;
		dispatchEvent(new Event(Event.CHANGE));
		dispatchEvent(new PropertyChangeEvent("propertyChange_value", oldValue, inputField.value));
        return v;
    }
	
	private function get_Value() : Float
	{
		return inputField.value;
    }
	
	private function set_Min(v : Float) : Float
	{
		inputField.min = v;
        return v;
    }
	
	private function get_Min() : Float
	{
		return inputField.min;
    }
	
	private function set_Max(v : Float) : Float
	{
		inputField.max = v;
        return v;
    }
	
	private function get_Max() : Float
	{
		return inputField.max;
    }
	
	private function set_NumDecimalPlaces(v : Int) : Int
	{
		inputField.numDecimalPlaces = v;
        return v;
    }
	
	private function get_NumDecimalPlaces() : Int
	{
		return inputField.numDecimalPlaces;
    }
	private function get_Gap() : Int
	{
		return _gap;
    }
	
	private function set_Gap(value : Int) : Int
	{
		if (value == _gap) return;
		_gap = value;
		invalidate();
        return value;
    }
}