package util;

import util.EventDispatcher;
import util.PropertyChangeEvent;
import nme.events.EventDispatcher;import core.events.PropertyChangeEvent;class InspectableObject extends EventDispatcher
{
    public var string(get, set) : String;
    public var integer(get, set) : Int;
    public var number(get, set) : Float;
    public var number2(get, set) : Float;
    public var number3(get, set) : Float;
    public var boolean(get, set) : Bool;
    public var color(get, set) : Int;
private var _string : String = "I'm a string!";private var _integer : Int;private var _number : Float;private var _number2 : Float;private var _number3 : Float;private var _color : Int;private var _boolean : Bool;public function new()
    {
        super();
    }@:meta(Inspectable())
private function get_String() : String{return _string;
    }private function set_String(value : String) : String{var oldValue : Dynamic = _string;_string = value;dispatchEvent(new PropertyChangeEvent("propertyChange_string", oldValue, _string));
        return value;
    }@:meta(Inspectable(editor="NumericStepper"))
private function get_Integer() : Int{return _integer;
    }private function set_Integer(value : Int) : Int{var oldValue : Dynamic = _integer;_integer = value;dispatchEvent(new PropertyChangeEvent("propertyChange_integer", oldValue, _integer));
        return value;
    }@:meta(Inspectable())
private function get_Number() : Float{return _number;
    }private function set_Number(value : Float) : Float{var oldValue : Dynamic = _number;_number = value;dispatchEvent(new PropertyChangeEvent("propertyChange_number", oldValue, _number));
        return value;
    }@:meta(Inspectable())
@:meta(Inspectable(editor="Slider",min="-10",max="10",snapInterval="1"))
private function get_Number2() : Float{return _number2;
    }private function set_Number2(value : Float) : Float{var oldValue : Dynamic = _number2;_number2 = value;dispatchEvent(new PropertyChangeEvent("propertyChange_number2", oldValue, _number2));
        return value;
    }@:meta(Inspectable(editor="Slider",min="-10",max="10",snapInterval="1"))
private function get_Number3() : Float{return _number3;
    }private function set_Number3(value : Float) : Float{var oldValue : Dynamic = _number3;_number3 = value;dispatchEvent(new PropertyChangeEvent("propertyChange_number3", oldValue, _number3));
        return value;
    }@:meta(Inspectable())
private function get_Boolean() : Bool{return _boolean;
    }private function set_Boolean(value : Bool) : Bool{var oldValue : Dynamic = _boolean;_boolean = value;dispatchEvent(new PropertyChangeEvent("propertyChange_boolean", oldValue, _boolean));
        return value;
    }@:meta(Inspectable(editor="ColorPicker"))
private function get_Color() : Int{return _color;
    }private function set_Color(value : Int) : Int{_color = value;dispatchEvent(new PropertyChangeEvent("propertyChange_color", null, _color));
        return value;
    }
}