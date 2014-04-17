  /**
 * NumberInputField.as
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

import core.ui.components.KeyboardEvent;
import core.ui.components.TextEvent;
import core.ui.components.TextInput;
import nme.events.Event;
import nme.events.FocusEvent;
import nme.events.KeyboardEvent;
import nme.events.TextEvent;
import nme.ui.Keyboard;
import core.ui.events.ItemEditorEvent;

class NumberInput extends TextInput
{
    public var value(get, set) : Float;
    public var min(get, set) : Float;
    public var max(get, set) : Float;
    public var numDecimalPlaces(get, set) : Int;
  
	// Properties  
	
	private var _value : String = "0";
	private var _min : Float = -Float.MAX_VALUE;
	private var _max : Float = Float.MAX_VALUE;
	private var _numDecimalPlaces : Int = 3;
	
	public function new()
    {
        super();
    }  
	
	////////////////////////////////////////////////    
	// Protected methods    
	////////////////////////////////////////////////  
	
	override private function init() : Void
	{
		super.init();
		textField.restrict = "\-0-9.";
		textField.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
		textField.addEventListener(TextEvent.TEXT_INPUT, onTextInput);
		value = 0;
    }
	
	override private function commitValue() : Void
	{
		if (textField.text == "") {
			value = 0;
			return;
        }
		
		var oldValue : String = _value;
		value = Std.parseFloat(textField.text);
		textField.text = _value;
		if (_value != oldValue) {
			dispatchEvent(new ItemEditorEvent(ItemEditorEvent.COMMIT_VALUE, _value, "value"));
        }
    }  
	
	////////////////////////////////////////////////    
	// Event Handlers    
	////////////////////////////////////////////////  
	
	override public function onLoseComponentFocus() : Void
	{
		commitValue();
    }
	
	private function onTextInput(event : TextEvent) : Void
	{  
		// Stop two '.' characters from entering the field. 
		if (event.text.indexOf(".") != -1) {
			if (textField.text.indexOf(".") != -1) {
				event.preventDefault();
				event.stopImmediatePropagation();
				return;
            }
        }  
		
		// Stop two '-' characters from entering the field, and ensure it can only appear at the start of the string  
		if (event.text.indexOf("-") != -1) {
			if (textField.text.indexOf("-") != -1) {
				event.preventDefault();
				event.stopImmediatePropagation();
				return;
            }
			
			if (textField.caretIndex != 0) {
				event.preventDefault();
				event.stopImmediatePropagation();
				return;
            }
        }
    }
	
	private function keyDownHandler(event : KeyboardEvent) : Void
	{
		if (event.keyCode == Keyboard.ENTER) {
			commitValue();
        }
    }
	
	private function set_Value(v : Float) : Float
	{
		if (Math.isNaN(v)) v = 0;
		v = v < (_min != 0) ? _min : v > (_max != 0) ? _max : v;
		var newValue : String = Std.string(v);
		if (_numDecimalPlaces > 0 && newValue.indexOf(".") != -1) {
			var index : Int = newValue.indexOf(".");
			var wholeNumber : String = newValue.substring(0, index);
			var fraction : String = newValue.substr(index, _numDecimalPlaces + 1);
			newValue = wholeNumber + fraction;
        } else {
			newValue = Std.string(as3hx.Compat.parseInt(v));
        }
		
		if (newValue != _value) {
			_value = newValue; 
			textField.text = _value;
			dispatchEvent(new Event(Event.CHANGE));
        }
        return v;
    }  
	
	////////////////////////////////////////////////    
	// Getters/Setters    
	////////////////////////////////////////////////  
	
	private function get_Value() : Float
	{
		return Std.parseFloat(_value);
    }
	
	private function set_Min(v : Float) : Float
	{
		_min = v;
		value = v < (_min != 0) ? _min : v;
        return v;
    }
	
	private function get_Min() : Float
	{
		return _min;
    }
	
	private function set_Max(v : Float) : Float
	{
		_max = v;
		value = v > (_max != 0) ? _max : v;
        return v;
    }
	
	private function get_Max() : Float
	{
		return _max;
    }
	
	private function set_NumDecimalPlaces(v : Int) : Int
	{
		_numDecimalPlaces = v;
		value = value;
        return v;
    }
	
	private function get_NumDecimalPlaces() : Int
	{
		return _numDecimalPlaces;
    }
}