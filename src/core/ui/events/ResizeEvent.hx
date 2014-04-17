package core.ui.events;

import nme.events.Event;

class ResizeEvent extends Event
{
	public static inline var RESIZE : String = "core_resize";
	public var oldHeight : Float;
	public var oldWidth : Float;
	
	public function new(type : String, bubbles : Bool = false, cancelable : Bool = false, oldWidth : Float = NaN, oldHeight : Float = NaN)
    {
		this.oldWidth = oldWidth;
		this.oldHeight = oldHeight;
		super(type, bubbles, cancelable);
    }
	
	override public function clone() : Event
	{
		return new ResizeEvent(type, bubbles, cancelable, oldWidth, oldHeight);
    }
}