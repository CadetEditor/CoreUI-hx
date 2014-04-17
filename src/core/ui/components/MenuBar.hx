  /**
 * MenuBar.as
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

import core.ui.components.MenuBarSkin;
import core.ui.components.UIComponent;
import nme.display.Sprite;
import nme.events.MouseEvent;
import nme.geom.Point;
import core.data.ArrayCollection;
import core.events.ArrayCollectionEvent;
import core.ui.CoreUI;
import core.ui.components.IItemRenderer;
import core.ui.data.DefaultDataDescriptor;
import core.ui.data.IDataDescriptor;
import core.ui.events.SelectEvent;
import core.ui.layouts.HorizontalLayout;
import core.ui.util.Scale9GridUtil;
import flux.skins.MenuBarButtonSkin;
import flux.skins.MenuBarSkin;

@:meta(Event(type="core.ui.events.SelectEvent",name="select"))
class MenuBar extends UIComponent
{
    public var dataProvider(get, set) : ArrayCollection;
    public var dataDescriptor(get, set) : IDataDescriptor;
  
	// Properties  
	
	private var _dataProvider : ArrayCollection;
	private var _dataDescriptor : IDataDescriptor;  
	
	// Child elements  
	
	private var background : Sprite;
	private var buttonBar : Container;
	private var list : List;  
	
	// Internal vars  
	
	private var selectedData : Dynamic;
	
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
		background = new MenuBarSkin();
		addChild(background);
		_height = background.height;
		_width = background.width;
		buttonBar = new Container();
		buttonBar.layout = new HorizontalLayout(0);
		addChild(buttonBar);
		list = new List();
		list.itemRendererClass = DropDownListItemRenderer;
		list.resizeToContentWidth = true;
		list.resizeToContentHeight = true;
		list.clickSelect = true;
		list.focusEnabled = false;
		_dataDescriptor = new DefaultDataDescriptor();
		list.dataDescriptor = _dataDescriptor;
		buttonBar.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownButtonBarHandler);
		buttonBar.addEventListener(SelectEvent.SELECT, selectButtonBarHandler);
    }
	
	override private function validate() : Void
	{
		var dataProviderLength : Int = (_dataProvider != null) ? _dataProvider.length : 0;
		var maxLength : Int = Math.max(dataProviderLength, buttonBar.numChildren);
		
		for (i in 0...dataProviderLength) {
			var data : Dynamic = _dataProvider[i];
			var btn : Button;  
			// Re-use existing button if possible  
			if (buttonBar.numChildren > i) {
				btn = cast((buttonBar.getChildAt(i)), Button);
            } else {
				btn = new Button(MenuBarButtonSkin);
				if (!btn.scale9Grid) {
					Scale9GridUtil.setScale9Grid(btn, CoreUI.defaultMenuBarButtonSkinScale9Grid);
                }
				btn.focusEnabled = false;
				btn.resizeToContentWidth = true;
				buttonBar.addChild(btn);
            }
			btn.label = _dataDescriptor.getLabel(data);
        }  
		
		// Remove any left-over buttons  
		while (buttonBar.numChildren > dataProviderLength) {
			buttonBar.removeChildAt(dataProviderLength);
        }
		
		background.width = _width;
		background.height = _height;
		buttonBar.width = _width;
		buttonBar.height = _height;
		buttonBar.validateNow();
    }
	
	private function openList() : Void
	{
		var selectedBtn : Button = cast((buttonBar.getChildAt(_dataProvider.source.indexOf(selectedData))), Button);
		if (list.stage == null) {
			stage.addChild(list);
        }
		
		var pt : Point = new Point(selectedBtn.x, buttonBar.height);
		pt = localToGlobal(pt);
		list.x = pt.x;
		list.y = pt.y;
		var dp : ArrayCollection = _dataDescriptor.getChildren(selectedData);
		list.dataProvider = dp;
		list.visible = dp != null && dp.length > 0;
		
		for (i in 0...buttonBar.numChildren) {
			var child : Button = cast((buttonBar.getChildAt(i)), Button);
			child.selected = child == selectedBtn;
        }
		
		buttonBar.addEventListener(MouseEvent.MOUSE_OVER, mouseOverButtonBarHandler);
		list.addEventListener(MouseEvent.MOUSE_UP, mouseUpListHandler);
    }
	
	private function closeList() : Void
	{
		if (selectedData == null) return;
		if (list.stage == null) return;
		
		stage.removeChild(list);
		
		for (i in 0...buttonBar.numChildren) {
			var child : Button = cast((buttonBar.getChildAt(i)), Button);
			child.selected = false;
        }
		
		selectedData = null;
		buttonBar.removeEventListener(MouseEvent.MOUSE_OVER, mouseOverButtonBarHandler);
		list.removeEventListener(MouseEvent.MOUSE_UP, mouseUpListHandler);
    }
	
	override public function onLoseComponentFocus() : Void
	{
		closeList();
    }  
	
	////////////////////////////////////////////////    
	// Event handlers    
	////////////////////////////////////////////////  
	
	private function selectButtonBarHandler(event : SelectEvent) : Void
	{
		event.stopImmediatePropagation();
    }
	
	private function mouseDownButtonBarHandler(event : MouseEvent) : Void
	{
		var btn : Button = try cast(event.target, Button) catch (e:Dynamic) null;
		if (btn == null) return;
		if (selectedData != null) {
			closeList();
        } else {
			var index : Int = buttonBar.getChildIndex(btn);
			selectedData = _dataProvider[index];
			openList();
        }
    }
	
	private function mouseOverButtonBarHandler(event : MouseEvent) : Void
	{
		var btn : Button = try cast(event.target, Button) catch (e:Dynamic) null;
		if (btn == null) return;
		var index : Int = buttonBar.getChildIndex(btn);
		selectedData = _dataProvider[index];
		openList();
    }
	
	private function mouseUpListHandler(event : MouseEvent) : Void
	{
		var itemRenderer : IItemRenderer = try cast(event.target, IItemRenderer) catch (e:Dynamic) null;
		if (itemRenderer == null) return;
		if (list.dataDescriptor.getEnabled(itemRenderer.data) == false) return;
		dispatchEvent(new SelectEvent(SelectEvent.SELECT, itemRenderer.data, true, false));
		closeList();
    }  
	
	////////////////////////////////////////////////    
	// Getters/Setters    
	////////////////////////////////////////////////  
	
	private function set_DataProvider(value : ArrayCollection) : ArrayCollection
	{
		if (_dataProvider != null) {
			_dataProvider.removeEventListener(ArrayCollectionEvent.CHANGE, dataProviderChangeHandler);
        }
		
		_dataProvider = value;
		
		if (_dataProvider != null) {
			_dataProvider.addEventListener(ArrayCollectionEvent.CHANGE, dataProviderChangeHandler);
        }
		
		closeList();		
		invalidate();
        return value;
    }
	
	private function get_DataProvider() : ArrayCollection
	{
		return _dataProvider;
    }
	
	private function dataProviderChangeHandler(event : ArrayCollectionEvent) : Void
	{
		invalidate();
    }
	
	private function set_DataDescriptor(value : IDataDescriptor) : IDataDescriptor
	{
		if (value == _dataDescriptor) return;		
		_dataDescriptor = value;
		list.dataDescriptor = _dataDescriptor;
        return value;
    }
	
	private function get_DataDescriptor() : IDataDescriptor
	{
		return _dataDescriptor;
    }
}