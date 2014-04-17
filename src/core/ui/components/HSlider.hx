  /**
 * HSlider.as
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

import core.ui.components.SliderMarkerSkin;
import core.ui.components.SliderThumbSkin;
import core.ui.components.SliderTrackSkin;
import core.ui.components.ToolTip;
import core.ui.components.UIComponent;
import nme.display.Sprite;
import nme.events.Event;
import nme.events.MouseEvent;
import nme.geom.Point;
import core.events.PropertyChangeEvent;
import core.ui.CoreUI;
import core.ui.events.ItemEditorEvent;
import core.ui.util.Scale9GridUtil;
import flux.skins.SliderMarkerSkin;
import flux.skins.SliderThumbSkin;
import flux.skins.SliderTrackSkin;

class HSlider extends UIComponent
{
    public var value(get, set) : Float;
    public var min(get, set) : Float;
    public var max(get, set) : Float;
    public var snapInterval(get, set) : Float;
    public var showMarkers(get, set) : Bool;
  
	// Properties  
	
	private var _value : Float = 0;
	private var _min : Float = 0;
	private var _max : Float = 10;
	private var _snapInterval : Float = 0;
	private var _showMarkers : Bool = false;  
	
	// Child elements  
	
	private var track : Sprite;
	private var thumb : Sprite;
	private var markerContainer : Sprite;
	private var markers : Array<Dynamic>;
	private var toolTipComp : ToolTip;
	
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
		track = new SliderTrackSkin();
		
		if (!track.scale9Grid) {
			Scale9GridUtil.setScale9Grid(track, CoreUI.defaultSliderTrackSkinScale9Grid);
        }
		
		addChild(track);
		_width = track.width;
		_height = track.height;
		markerContainer = new Sprite();
		addChild(markerContainer);
		thumb = new SliderThumbSkin();
		addChild(thumb);
		toolTipComp = new ToolTip();
		markers = [];
		addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
    }
	
	override private function validate() : Void
	{
		track.width = _width;
		track.height = _height;
		var range : Float = (_max - _min);
		thumb.x = as3hx.Compat.parseInt(_width * ((_value - _min) / range));
		var numMarkers : Int = ((showMarkers && _snapInterval > 0)) ? range / _snapInterval : 0;
		var stepWidth : Float = (_snapInterval / range) * _width;
		var leftOver : Float = (range % _snapInterval) * stepWidth;
		
		for (i in 0...numMarkers) {
			var marker : Sprite;
			if (i >= markers.length) {
				marker = markers[i] = new SliderMarkerSkin();markerContainer.addChild(marker);
            } else {
				marker = markers[i];
            }
			marker.x = as3hx.Compat.parseInt(leftOver + i * stepWidth);
        }
		
		while (markers.length > numMarkers) {
			markerContainer.removeChild(markers.pop());
        }
		
		toolTipComp.text = Std.string(as3hx.Compat.parseInt(_value * 1000) / 1000);
		toolTipComp.validateNow();
		var pt : Point = new Point(thumb.x, thumb.y);
		pt = localToGlobal(pt);
		pt = Application.getInstance().globalToLocal(pt);
		toolTipComp.x = pt.x - (toolTipComp.width >> 1);
		toolTipComp.y = pt.y - toolTipComp.height;
    }
	
	private function beginDrag() : Void
	{
		stage.addEventListener(MouseEvent.MOUSE_UP, stageMouseUpHandler);
		stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
		Application.getInstance().toolTipContainer.addChild(toolTipComp);
		invalidate();
    }
	
	private function endDrag() : Void
	{
		stage.removeEventListener(MouseEvent.MOUSE_UP, stageMouseUpHandler);
		stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
		toolTipComp.parent.removeChild(toolTipComp);
    }
	
	private function updateDrag() : Void
	{
		var ratio : Float = mouseX / _width;value = _min + ratio * (_max - _min);
    }
	
	private function commitValue() : Void
	{
		dispatchEvent(new ItemEditorEvent(ItemEditorEvent.COMMIT_VALUE, _value, "value"));
    }
	
	override public function onLoseComponentFocus() : Void
	{
		commitValue();
    }  
	
	////////////////////////////////////////////////    
	// Event handlers    
	////////////////////////////////////////////////  
	
	private function mouseDownHandler(event : MouseEvent) : Void
	{
		beginDrag();
		updateDrag();
    }
	
	private function mouseMoveHandler(event : MouseEvent) : Void
	{
		updateDrag();
    }
	
	private function stageMouseUpHandler(event : MouseEvent) : Void
	{
		endDrag();
    }  
	
	////////////////////////////////////////////////    
	// Getters/Setters    
	////////////////////////////////////////////////  
	
	private function get_Value() : Float
	{
		return _value;
    }
	
	private function set_Value(v : Float) : Float
	{  
		// Snap the value to the interval  
		if (_snapInterval > 0) {
			var a : Float = 1 / _snapInterval;v = Math.round(v * a) / a;
        }
		
		v = v < (_min != 0) ? _min : v > (_max != 0) ? _max : v;
		if (_value == v) return;
		var oldValue : Float = _value;
		_value = v;
		invalidate();
		dispatchEvent(new Event(Event.CHANGE));
		dispatchEvent(new PropertyChangeEvent("propertyChange_value", oldValue, _value));
        return v;
    }
	
	private function get_Min() : Float
	{
		return _min;
    }
	
	private function set_Min(v : Float) : Float
	{
		v = v > (_max != 0) ? _max : v;
		if (_min == v) return;
		_min = v;
		value = _value;
        return v;
    }
	
	private function get_Max() : Float
	{
		return _max;
    }
	
	private function set_Max(v : Float) : Float
	{
		v = v < (_min != 0) ? _min : v;
		if (_max == v) return;
		_max = v;
		value = _value;
        return v;
    }
	
	private function get_SnapInterval() : Float
	{
		return _snapInterval;
    }
	
	private function set_SnapInterval(v : Float) : Float
	{
		v = v < (0) ? 0 : v;
		if (_snapInterval == v) return;
		_snapInterval = v;
		value = _value;
        return v;
    }
	
	private function get_ShowMarkers() : Bool
	{
		return _showMarkers;
    }
	
	private function set_ShowMarkers(v : Bool) : Bool
	{
		if (_showMarkers == v) return;
		_showMarkers = v;
		invalidate();
        return v;
    }
}