/**
 * BindingUtil.as
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

import flash.events.IEventDispatcher;
import flash.utils.Dictionary;

class BindingUtil
{
	private static var propertiesForSourceTable : Dictionary = new Dictionary(true);
	
	public static function bind(source : IEventDispatcher, sourceProperty : String, target : Dynamic, targetProperty : String, handler : Function = null) : Void
	{
		var propertiesForThisSource : Dynamic = Reflect.field(propertiesForSourceTable, Std.string(source));
		if (propertiesForThisSource == null) {
			propertiesForThisSource = Reflect.setField(propertiesForSourceTable, Std.string(source), new Dictionary(true));
        }
		var targetDataForThisPropertyOnThisSource : Array<Dynamic> = Reflect.field(propertiesForThisSource, sourceProperty);
		if (targetDataForThisPropertyOnThisSource == null) {
			targetDataForThisPropertyOnThisSource = Reflect.setField(propertiesForThisSource, sourceProperty, []);source.addEventListener("propertyChange_" + sourceProperty, propertyChangeHandler, false, 0, true);
        }
		targetDataForThisPropertyOnThisSource.push({
			target : target,
			targetProperty : targetProperty,
			handler : handler
        });
		
		Reflect.setField(target, targetProperty, Reflect.field(source, sourceProperty));
    }
	
	public static function bindTwoWay(objectA : IEventDispatcher, propertyA : String, objectB : IEventDispatcher, propertyB : String) : Void
	{
		bind(objectA, propertyA, objectB, propertyB);
		bind(objectB, propertyB, objectA, propertyA);
    }
	
	public static function unbind(source : IEventDispatcher, sourceProperty : String, target : Dynamic, targetProperty : String) : Void
	{
		var propertiesForThisSource : Dynamic = Reflect.field(propertiesForSourceTable, Std.string(source));
		if (propertiesForThisSource == null) return;
		var targetDataForThisPropertyOnThisSource : Array<Dynamic> = Reflect.field(propertiesForThisSource, sourceProperty);
		if (targetDataForThisPropertyOnThisSource == null) return;
		
		for (i in 0...targetDataForThisPropertyOnThisSource.length) {
			var targetData : Dynamic = targetDataForThisPropertyOnThisSource[i];
			if (targetData.target == target && targetData.targetProperty == targetProperty) {
				targetDataForThisPropertyOnThisSource.splice(i, 1);
				i--;
            }
        }
		
		if (targetDataForThisPropertyOnThisSource.length == 0) {
			Reflect.setField(propertiesForThisSource, sourceProperty, null);
			source.removeEventListener("propertyChange_" + sourceProperty, propertyChangeHandler);
        }
    }
	
	public static function unbindTwoWay(objectA : IEventDispatcher, propertyA : String, objectB : IEventDispatcher, propertyB : String) : Void
	{
		unbind(objectA, propertyA, objectB, propertyB);
		unbind(objectB, propertyB, objectA, propertyA);
    }  
	
	// This number is incremented each time we enter this function, and decremented when we leave.    
	// Because we may set a property that ends up calling this handler during a previous call, this number    
	// will reflect the length of the binding chain.    
	// We keep track of which objects we've already set which proeprties on, to protect against infinite loops.    
	// This table is cleared when the depth == 0 when exiting, as by this point we will have visited every object    
	// affected by the property change.  
	
	private static var depth : Int;
	private static var visitedObjects : Dictionary;
	
	private static function propertyChangeHandler(event : PropertyChangeEvent) : Void
	{
		if (visitedObjects == null) { 
			visitedObjects = new Dictionary(true);
			depth = 0;
        }
		depth++;
		var propertiesForThisSource : Dynamic = propertiesForSourceTable[event.target];
		var targetDataForThisPropertyOnThisSource : Dynamic = propertiesForThisSource[event.propertyName];
		
		for (targetData/* AS3HX WARNING could not determine type for var: targetData exp: EIdent(targetDataForThisPropertyOnThisSource) type: Dynamic */ in targetDataForThisPropertyOnThisSource) {
			var setProperties : Dynamic = visitedObjects[targetData.target];
			if (setProperties == null) {
				setProperties = visitedObjects[targetData.target] = { };
            }
			if (setProperties[targetData.targetProperty]) {
				continue;
            }
			setProperties[targetData.targetProperty] = true;
			targetData.target[targetData.targetProperty] = event.newValue;
        }
		
		if (targetDataForThisPropertyOnThisSource.handler) {
			targetDataForThisPropertyOnThisSource.handler(event);
        }
		depth--;
		if (depth == 0) {
			visitedObjects = new Dictionary(true);
        }
    }

    public function new()
    {
    }
}