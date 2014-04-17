  /**
 * IUIComponent.as
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

import core.ui.components.IEventDispatcher;
import nme.events.IEventDispatcher;

interface IUIComponent extends IEventDispatcher
{
    var x(get, set) : Float;    
	var y(get, set) : Float;    
	var label(get, set) : String;    
	var toolTip(get, set) : String;    
	var icon(get, set) : Dynamic;    
	var width(get, set) : Float;    
	var height(get, set) : Float;    
	var enabled(get, set) : Bool;    
	var percentWidth(get, set) : Float;    
	var percentHeight(get, set) : Float;    
	var excludeFromLayout(get, set) : Bool;    
	var resizeToContentWidth(get, set) : Bool;    
	var resizeToContentHeight(get, set) : Bool;
	function validateNow() : Void;
	function isInvalid() : Bool;
}