  /**
 * DragAndDropEvent.as
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

class DragAndDropEvent extends Event
{
    public var item(get, never) : Dynamic;
    public var targetCollection(get, never) : ArrayCollection;
    public var index(get, never) : Int;
	public static inline var DRAG_START : String = "dragStart";
	public static inline var DRAG_OVER : String = "dragOver";
	public static inline var DRAG_DROP : String = "dragDrop";
	private var _item : Dynamic;
	private var _targetCollection : ArrayCollection;
	private var _index : Int;
	
	public function new(type : String, item : Dynamic, targetCollection : ArrayCollection = null, index : Int = -1)
    {
		super(type, false, true);_item = item;_targetCollection = targetCollection;_index = index;
    }
	
	override public function clone() : Event
	{
		return new DragAndDropEvent(type, _item, _targetCollection, _index);
    }
	
	private function get_Item() : Dynamic
	{
		return _item;
    }
	
	private function get_TargetCollection() : ArrayCollection
	{
		return _targetCollection;
    }
	
	private function get_Index() : Int
	{
		return _index;
    }
}