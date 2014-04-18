package util;

import util.EventDispatcher;
import util.PropertyChangeEvent;
import flash.events.EventDispatcher;
import core.events.PropertyChangeEvent;

class InspectableObject extends EventDispatcher
{
    public var string(get, set) : String;
    public var integer(get, set) : Int;
    public var number(get, set) : Float;
    public var number2(get, set) : Float;
    public var number3(get, set) : Float;
    public var boolean(get, set) : Bool;
    public var color(get, set) : Int;
	private var _string : String = "I'm a string!";
	private var _integer : Int;
	private var _number : Float;
	private var _number2 : Float;
	private var _number3 : Float;
	private var _color : Int;
	private var _boolean : Bool;
	
	public function new()
    {
        super();
    }
	
	@:meta(Inspectable())
	private function get_string() : String
	{
		return _string;
    }
	
	private function set_string(value : String) : String
	{
		var oldValue : Dynamic = _string; 
		_string = value;
		dispatchEvent(new PropertyChangeEvent("propertyChange_string", oldValue, _string));
        return value;
    }
	
	@:meta(Inspectable(editor="NumericStepper"))
	private function get_integer() : Int
	{
		return _integer;
    }
	
	private function set_integer(value : Int) : Int
	{
		var oldValue : Dynamic = _integer;
		_integer = value;
		dispatchEvent(new PropertyChangeEvent("propertyChange_integer", oldValue, _integer));
        return value;
    }
	
	@:meta(Inspectable())
	private function get_number() : Float
	{
		return _number;
    }
	
	private function set_number(value : Float) : Float
	{
		var oldValue : Dynamic = _number;
		_number = value;
		dispatchEvent(new PropertyChangeEvent("propertyChange_number", oldValue, _number));
        return value;
    }
	
	@:meta(Inspectable())
	@:meta(Inspectable(editor="Slider",min="-10",max="10",snapInterval="1"))
	private function get_number2() : Float
	{
		return _number2;
    }
	
	private function set_number2(value : Float) : Float
	{
		var oldValue : Dynamic = _number2;
		_number2 = value;
		dispatchEvent(new PropertyChangeEvent("propertyChange_number2", oldValue, _number2));
        return value;
    }
	
	@:meta(Inspectable(editor="Slider",min="-10",max="10",snapInterval="1"))
	private function get_number3() : Float
	{
		return _number3;
    }
	
	private function set_number3(value : Float) : Float
	{
		var oldValue : Dynamic = _number3;
		_number3 = value;
		dispatchEvent(new PropertyChangeEvent("propertyChange_number3", oldValue, _number3));
        return value;
    }
	
	@:meta(Inspectable())
	private function get_boolean() : Bool
	{
		return _boolean;
    }
	
	private function set_boolean(value : Bool) : Bool
	{
		var oldValue : Dynamic = _boolean;
		_boolean = value;
		dispatchEvent(new PropertyChangeEvent("propertyChange_boolean", oldValue, _boolean));
        return value;
    }
	
	@:meta(Inspectable(editor="ColorPicker"))
	private function get_color() : Int
	{
		return _color;
    }
	
	private function set_color(value : Int) : Int
	{
		_color = value;
		dispatchEvent(new PropertyChangeEvent("propertyChange_color", null, _color));
        return value;
    }
}