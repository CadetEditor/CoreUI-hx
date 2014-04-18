  /**
 * ColorPickerItemEditor.as
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

import core.ui.components.ColorPickerItemEditorSkin;
import core.ui.components.Container;
import core.ui.components.Point;
import core.ui.components.UIComponent;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import core.events.PropertyChangeEvent;
import core.ui.CoreUI;
import core.ui.events.ItemEditorEvent;
import core.ui.managers.PopUpManager;
import core.ui.util.Scale9GridUtil;
import flux.skins.ColorPickerItemEditorSkin;

class ColorPickerItemEditor extends UIComponent
{
    public var color(get, set) : Int;
	
	// Properties  
	
	private var _color : Int = 0;  
	
	// Child elements  
	
	private var background : Sprite;
	private var labelField : TextField;
	private var swatch : Sprite;
	private var panel : Container;
	private var colorPicker : ColorPicker;
	
	public function new()
    {
        super();
    }  
	
	////////////////////////////////////////////////    
	// Protected methods    
	////////////////////////////////////////////////  
	
	override private function init() : Void
	{
		height = 26;
		background = new ColorPickerItemEditorSkin();
		
		if (!background.scale9Grid) {
			Scale9GridUtil.setScale9Grid(background, CoreUI.defaultColorPickerItemEditorSkinScale9Grid);
        }
		
		addChild(background);
		labelField = TextStyles.createTextField();
		labelField.autoSize = TextFieldAutoSize.LEFT;
		addChild(labelField);
		swatch = new Sprite();
		addChild(swatch);
		swatch.addEventListener(MouseEvent.CLICK, clickSwatchHandler);
    }
	
	override private function validate() : Void
	{
		var swatchWidth : Int = _height * 1.61;
		var swatchHeight : Int = _height;
		background.width = swatchWidth;
		background.height = swatchHeight;
		swatch.graphics.clear();
		swatch.graphics.beginFill(_color);
		swatch.graphics.drawRect(0, 0, swatchWidth - 4, swatchHeight - 4); swatch.x = 2;
		swatch.y = 2;
		var str : String = Std.string(_color).toUpperCase();
		
		while (str.length < 6) {
			str = "0" + str;
        }
		
		str = "#" + str;
		labelField.text = str;
		labelField.height = labelField.textHeight + 4;
		labelField.y = (_height - labelField.height) >> 1;
		labelField.x = swatchWidth + 4;
    }  
	
	////////////////////////////////////////////////    
	// Event Handlers    
	////////////////////////////////////////////////  
	
	private function clickSwatchHandler(event : MouseEvent) : Void
	{
		openPanel();
    }
	
	private function onColorPickerChange(event : Event) : Void
	{
		color = colorPicker.color;
		dispatchEvent(new Event(Event.CHANGE));
    }
	
	private function onMouseDownStage(event : MouseEvent) : Void
	{
		if (panel.hitTestPoint(stage.mouseX, stage.mouseY)) {
			return;
        }
		
		event.stopImmediatePropagation();
		closePanel();
		dispatchEvent(new ItemEditorEvent(ItemEditorEvent.COMMIT_VALUE, _color, "color"));
    }
	
	private function onClickStage(event : MouseEvent) : Void
	{
		event.stopImmediatePropagation();
		stage.removeEventListener(MouseEvent.CLICK, onClickStage, true);
		stage.removeEventListener(MouseEvent.CLICK, onClickStage);
    }  
	
	////////////////////////////////////////////////    
	// Private methods    
	////////////////////////////////////////////////  
	
	private function openPanel() : Void
	{
		if (panel != null && panel.stage) return;
		if (panel == null) {
			panel = new Canvas(); 
			panel.padding = 4;
			panel.width = 200;
			panel.height = 200;
			colorPicker = new ColorPicker();
			colorPicker.percentWidth = colorPicker.percentHeight = 100;
			colorPicker.color = _color;
			colorPicker.padding = 0;
			colorPicker.showBorder = false;
			colorPicker.addEventListener(Event.CHANGE, onColorPickerChange);
			panel.addChild(colorPicker);
        }
		
		var pt : Point = new Point(0, 0);
		pt = background.localToGlobal(pt);
		panel.x = pt.x;
		panel.y = pt.y;
		PopUpManager.addPopUp(panel, false, false);
		stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDownStage, true);
		stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDownStage);
		stage.addEventListener(MouseEvent.CLICK, onClickStage, true);
		stage.addEventListener(MouseEvent.CLICK, onClickStage);
    }
	
	private function closePanel() : Void
	{
		if (panel.stage == null) return;
		PopUpManager.removePopUp(panel);
		stage.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDownStage, true);
		stage.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDownStage);
    }  
	
	////////////////////////////////////////////////    
	// Getters/Setters    
	////////////////////////////////////////////////  
	
	private function set_Color(v : Int) : Int
	{
		if (v == _color) return;
		_color = v;
		dispatchEvent(new PropertyChangeEvent("propertyChange_value", null, _color));
		invalidate();
        return v;
    }
	
	private function get_Color() : Int
	{
		return _color;
    }
}