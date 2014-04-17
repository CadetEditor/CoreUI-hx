  /**
 * PropertyChangeEvent.as
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
 */  package core.ui.events;

import nme.events.Event;class ItemEditorEvent extends Event
{
    public var value(get, never) : Dynamic;
    public var property(get, never) : String;
public static var CHANGE : String = "change";public static var COMMIT_VALUE : String = "commitValue";private var _value : Dynamic;private var _property : String;public function new(type : String, value : Dynamic, property : String, bubbles : Bool = false, cancelable : Bool = false)
    {super(type, bubbles, cancelable);_value = value;_property = property;
    }override public function clone() : Event{return new ItemEditorEvent(type, _value, _property, bubbles, cancelable);
    }private function get_Value() : Dynamic{return _value;
    }private function get_Property() : String{return _property;
    }
}