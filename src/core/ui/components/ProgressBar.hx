  /**
 * ProgressBar.as
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

import core.ui.components.UIComponent;
import flash.display.MovieClip;
import flash.display.Sprite;
import core.ui.CoreUI;
import core.ui.util.Scale9GridUtil;

class ProgressBar extends UIComponent
{
    public var progress(get, set) : Float;
    public var indeterminate(get, set) : Bool;
  
	// Styles  
	
	public static var styleBorderThickness : Int = 2;  
	
	// Properties  
	
	private var _progress : Float = 0;
	private var _indeterminate : Bool = false;
	private var _borderThickness : Int;  
	
	// Child elements  
	
	private var border : Sprite;
	private var bar : Sprite;
	private var indeterminateBar : MovieClip;
	
	public function new()
    {
        super();
    }  
	
	////////////////////////////////////////////////    
	// Protected methods    
	////////////////////////////////////////////////  
	
	override private function init() : Void
	{
		border = new ProgressBarBorderSkin();
		
		if (!border.scale9Grid) {
			Scale9GridUtil.setScale9Grid(border, CoreUI.defaultProgressBarBorderSkinScale9Grid);
        }
		
		addChild(border);
		_width = border.width;
		_height = border.height;
		bar = new ProgressBarSkin();
		
		if (!bar.scale9Grid) {
			Scale9GridUtil.setScale9Grid(bar, CoreUI.defaultProgressBarSkinScale9Grid);
        }
		
		addChild(bar);
		indeterminateBar = new ProgressBarIndeterminateSkin();
		indeterminateBar.stop();
		addChild(indeterminateBar);
		_borderThickness = styleBorderThickness;
		indeterminate = false;
    }
	
	override private function validate() : Void
	{
		border.width = _width;
		border.height = _height;
		bar.x = bar.y = indeterminateBar.x = indeterminateBar.y = _borderThickness;
		indeterminateBar.width = _width - (_borderThickness << 1);
		bar.height = indeterminateBar.height = _height - (_borderThickness << 1);
		bar.width = as3hx.Compat.parseInt(_progress * indeterminateBar.width);
    }  
	
	////////////////////////////////////////////////    
	// Getters/Setters    
	////////////////////////////////////////////////  
	
	private function set_Progress(v : Float) : Float
	{
		v = v < (0) ? 0 : v > (1) ? 1 : v;
		if (v == _progress) return;
		_progress = v;
		invalidate();
        return v;
    }
	
	private function get_Progress() : Float
	{
		return _progress;
    }
	
	private function set_Indeterminate(v : Bool) : Bool
	{
		if (_indeterminate == v) return;
		_indeterminate = v;
		
		if (_indeterminate) {
			indeterminateBar.visible = false;
			indeterminateBar.gotoAndPlay(1);
        } else {
			indeterminateBar.stop();
			indeterminateBar.visible = false;
        }
		
		bar.visible = !_indeterminate;
        return v;
    }
	
	private function get_Indeterminate() : Bool
	{
		return _indeterminate;
    }
}