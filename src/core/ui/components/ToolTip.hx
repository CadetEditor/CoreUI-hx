  /**
 * Tree.as
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

import flash.display.Sprite;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import core.ui.CoreUI;
import core.ui.util.Scale9GridUtil;

class ToolTip extends UIComponent
{
    public var text(get, set) : String;
  
	// Styles  
	
	public static var stylePaddingLeft : Int = 2;
	public static var stylePaddingRight : Int = 4;
	public static var stylePaddingTop : Int = 2;
	public static var stylePaddingBottom : Int = 4;  
	
	// Properties  
	
	private var _paddingLeft : Int = stylePaddingLeft;
	private var _paddingRight : Int = stylePaddingRight;
	private var _paddingTop : Int = stylePaddingTop;
	private var _paddingBottom : Int = stylePaddingBottom;  
	
	// Child elements  
	
	private var skin : Sprite;
	private var textField : TextField;
	
	public function new()
    {
        super();
    }  
	
	////////////////////////////////////////////////    
	// Protected methods    
	////////////////////////////////////////////////  
	
	override private function init() : Void
	{
		skin = new ToolTipSkin();
		if (skin.scale9Grid == null) {
			Scale9GridUtil.setScale9Grid(skin, CoreUI.defaultToolTipSkinScale9Grid);
        }
		skin.height = _height;
		addChild(skin);
		textField = TextStyles.createTextField();
		textField.autoSize = TextFieldAutoSize.LEFT;
		addChild(textField); 
		mouseEnabled = false;
		mouseChildren = false;
    }
	
	override private function validate() : Void
	{
		textField.x = _paddingLeft;
		textField.y = _paddingTop;
		_width = textField.x + textField.width + _paddingRight;
		_height = textField.y + textField.height + _paddingBottom;
		skin.width = _width;skin.height = _height;
    }  
	
	////////////////////////////////////////////////    
	// Getters/Setters    
	////////////////////////////////////////////////  
	
	private function set_text(value : String) : String
	{
		textField.text = value;
		invalidate();
        return value;
    }
	
	private function get_text() : String
	{
		return textField.text;
    }
}