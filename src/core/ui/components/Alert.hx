/**
 * Alert.as
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

import flash.events.MouseEvent;
import flash.geom.Rectangle;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import core.ui.events.AlertEvent;
import core.ui.events.SelectEvent;
import core.ui.layouts.HorizontalLayout;
import core.ui.layouts.LayoutAlign;
import core.ui.managers.PopUpManager;

@:meta(Event(type="core.ui.events.AlertEvent",name="alertClose"))
class Alert extends Panel
{
    public var text(get, set) : String;
    public var mainIcon(get, set) : Dynamic;
	
	////////////////////////////////////////////////    
	// Static methods    
	////////////////////////////////////////////////  
	
	public static function show(title : String, text : String, buttons : Array<Dynamic>, defaultButton : String = null, icon : Class<Dynamic> = null, modal : Bool = true, closeHandler : Dynamic = null) : Void
	{
		var alert : Alert = new Alert();
		alert.label = title; 
		alert.text = text;
		alert.mainIcon = icon;
		
		if (closeHandler != null) {
			alert.addEventListener(AlertEvent.ALERT_CLOSE, closeHandler);
        }
		
		cast((alert.controlBar.layout), HorizontalLayout).horizontalAlign = LayoutAlign.CENTRE;
		
		for (i in 0...buttons.length) {
			var btn : Button = new Button();
			btn.label = buttons[i]; 
			alert.controlBar.addChild(btn);
			if (btn.label == defaultButton) {
				alert.defaultButton = btn;
            }
        }
		
		alert.validateNow();
		PopUpManager.AddPopUp(alert, modal, true);
    }  
	
	// Child elements  
	private var textField : TextField; 
	private var mainIconImage : Image;
	
	public function new()
    {
        super();
    }  
	
	////////////////////////////////////////////////    
	// Protected methods    
	////////////////////////////////////////////////  
	
	override private function init() : Void {
		super.init();
		showCloseButton = false;
		dragEnabled = true;
		_controlBar.padding = 10;
		_controlBar.addEventListener(SelectEvent.SELECT, selectControlBarHandler);
		padding = 20;
		mainIconImage = new Image();
		addRawChild(mainIconImage);
		textField = TextStyles.createTextField();
		var tf : TextFormat = textField.defaultTextFormat;
		tf.align = TextFormatAlign.CENTER;
		textField.multiline = true;
		textField.wordWrap = true;
		textField.autoSize = TextFieldAutoSize.CENTER;
		textField.defaultTextFormat = tf;
		addRawChild(textField);
		_width = 300;
		_height = 140;
    }
	
	override private function validate() : Void
	{
		var layoutRect : Rectangle = getChildrenLayoutArea();
		mainIconImage.validateNow();
		mainIconImage.x = layoutRect.x;
		textField.x = mainIconImage.x + mainIconImage.width + 4;
		textField.width = layoutRect.width - textField.x;
		_height = _titleBarHeight + textField.height + 80; 
		super.validate();
		layoutRect = getChildrenLayoutArea();
		textField.y = layoutRect.y + (Std.int(layoutRect.height - textField.height) >> 1);
		mainIconImage.y = layoutRect.y + (Std.int(layoutRect.height - mainIconImage.height) >> 1);
    }  
	
	////////////////////////////////////////////////    
	// Event Handlers    
	////////////////////////////////////////////////  
	
	private function selectControlBarHandler(event : SelectEvent) : Void
	{
		var button : Button = try cast(event.target, Button) catch (e:Dynamic) null;
		
		if (button == null) return;
		
		PopUpManager.RemovePopUp(this);
		dispatchEvent(new AlertEvent(AlertEvent.ALERT_CLOSE, button.label));
    }  
	
	////////////////////////////////////////////////    
	// Getters/Setters    
	////////////////////////////////////////////////  
	
	private function set_text(value : String) : String
	{
		textField.text = value;
        return value;
    }
	
	private function get_text() : String
	{
		return textField.text;
    }
	
	private function set_mainIcon(value : Dynamic) : Dynamic
	{
		if (value != mainIconImage.source) return null;
		mainIconImage.source = value;
		invalidate();
        return value;
    }
	
	private function get_mainIcon() : Dynamic
	{
		return mainIconImage.source;
    }
}