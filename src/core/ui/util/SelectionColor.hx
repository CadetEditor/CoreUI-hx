 /**
 * SelectionColor.as
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
 
package core.ui.util;

import flash.geom.ColorTransform;
import flash.text.TextField;

class SelectionColor
{
	public static function setFieldSelectionColor(field : TextField, color : Int) : Void
	{
		field.backgroundColor = invert(field.backgroundColor);
		field.borderColor = invert(field.borderColor);
		field.textColor = invert(field.textColor);
		var colorTrans : ColorTransform = field.transform.colorTransform;
		colorTrans.color = color; 
		colorTrans.redMultiplier = -1;
		colorTrans.greenMultiplier = -1;
		colorTrans.blueMultiplier = -1;
		field.transform.colorTransform = colorTrans;
    }
	
	private static function invert(color : Int) : Int
	{
		var ct : ColorTransform = new ColorTransform();
		ct.color = color;

		ct.redMultiplier = -ct.redMultiplier; 
		ct.greenMultiplier = -ct.greenMultiplier; 
		ct.blueMultiplier = -ct.blueMultiplier; 
		ct.redOffset = 255 - ct.redOffset;
		ct.greenOffset = 255 - ct.greenOffset;
		ct.blueOffset = 255 - ct.blueOffset;

		return ct.color;
    }

    public function new()
    {
    }
}