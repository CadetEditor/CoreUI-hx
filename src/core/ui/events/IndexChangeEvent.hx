  /**
 * IndexChangeEvent.as
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
  
package core.ui.events;

import flash.events.Event;

class IndexChangeEvent extends Event
{
    public var oldIndex(get, never) : Int;
    public var newIndex(get, never) : Int;
	public static inline var INDEX_CHANGE : String = "indexChange";
	private var _oldIndex : Int;
	private var _newIndex : Int;
	
	public function new(type : String, oldIndex : Int, newIndex : Int, bubbles : Bool = false, cancelable : Bool = false)
    {
		super(type, false, cancelable);_oldIndex = oldIndex;_newIndex = newIndex;
    }
	
	override public function clone() : Event
	{
		return new IndexChangeEvent(IndexChangeEvent.INDEX_CHANGE, _oldIndex, _newIndex, bubbles, cancelable);
    }
	
	private function get_OldIndex() : Int
	{
		return _oldIndex;
    }
	
	private function get_NewIndex() : Int
	{
		return _newIndex;
    }
}