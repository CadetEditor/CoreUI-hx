  /**
 * VBox.as
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

import core.ui.layouts.HorizontalLayout;
import core.ui.layouts.VerticalLayout;

class VBox extends Container
{
    public var spacing(get, set) : Int;
    public var verticalAlign(get, set) : String;
    public var horizontalAlign(get, set) : String;
	
	public function new()
    {
        super();
    }  
	
	////////////////////////////////////////////////    
	// Properted methods    
	////////////////////////////////////////////////  
	
	override private function init() : Void
	{
		super.init();
		_layout = new VerticalLayout();
    }  
	
	////////////////////////////////////////////////    
	// Getters/Setters    
	////////////////////////////////////////////////  
	
	private function set_Spacing(value : Int) : Int
	{
		cast((_layout), VerticalLayout).spacing = value;
        return value;
    }
	
	private function get_Spacing() : Int
	{
		return cast((_layout), VerticalLayout).spacing;
    }
	
	private function set_VerticalAlign(value : String) : String
	{
		cast((_layout), VerticalLayout).verticalAlign = value;
        return value;
    }
	
	private function get_VerticalAlign() : String
	{
		return cast((_layout), VerticalLayout).verticalAlign;
    }
	
	private function set_HorizontalAlign(value : String) : String
	{
		cast((_layout), VerticalLayout).horizontalAlign = value;
        return value;
    }
	
	private function get_HorizontalAlign() : String
	{
		return cast((_layout), VerticalLayout).horizontalAlign;
    }
}