  /**
 * TextStyles.as
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
 * * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 * Components with text make use of the font Pixel Arial by Max
 * This is a free font obtained from http://www.dafont.com/pixel-arial-11.font
 */  
  
package core.ui.components;

import flash.text.AntiAliasType;
import flash.text.TextField;
import flash.text.TextFormat;

class TextStyles
{  
	// NOTE: Flex 4 introduces DefineFont4, which is used by default and does not work in native text fields.    
	// Use the embedAsCFF="false" param to switch back to DefineFont4. In earlier Flex 4 SDKs this was cff="false".    
	// So if you are using the Flex 3.x sdk compiler, remove the embedAsCFF="false" parameter.    
	//[Embed(source="../assets/PixelArial.ttf", embedAsCFF="false", fontName="Pixel Arial 11", mimeType="application/x-font")]    
	//protected static var PixelArial:Class;    
	//[Embed(source="../assets/PixelArialBold.ttf", embedAsCFF="false", fontWeight="bold",  fontName="Pixel Arial 11", mimeType="application/x-font")]   
	//protected static var PixelArialBold:Class;  
	
	public static var embedFonts : Bool = false;
	public static var fontFace : String = "Verdana";
	public static var fontSize : Int = 11;
	public static var fontColor : Int = 0xC0C0C0;
	public static var fontColorDimmed : Int = 0x999999;
	
	public static function createTextField(bold : Bool = false) : TextField
	{ 
		var field : TextField = new TextField();
		field.defaultTextFormat = new TextFormat(fontFace, fontSize, fontColor, bold);
		field.embedFonts = embedFonts; 
		field.antiAliasType = AntiAliasType.ADVANCED;
		field.selectable = false;
		field.multiline = false;
		field.tabEnabled = false;
		field.mouseEnabled = false;
		return field;
    }

    public function new()
    {
    }
}