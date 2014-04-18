  /**
 * DropDownMenu.as
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
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.text.TextField;
import core.ui.CoreUI;
import core.ui.components.DropDownListItemRenderer;
import core.ui.events.ItemEditorEvent;
import core.ui.events.ListEvent;
import core.ui.util.Scale9GridUtil;

@:meta(Event(type="flash.events.Event",name="change"))
class DropDownMenu extends UIComponent
{
    public var selectedItem(get, set) : Dynamic;
    public var dataProvider(get, set) : ArrayCollection;
    public var maxVisibleItems(get, set) : Int;
	
	// Settable properties  
	
	private var _maxVisibleItems : Int = 8;
	private var _dataProvider : ArrayCollection;
	private var _selectedItem : Dynamic;  
	
	// Child elements  
	
	private var skin : MovieClip;
	private var labelField : TextField;
	private var list : List;  
	
	// Internal vars  
	
	private var buttonWidth : Int;
	
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
		skin = new DropDownMenuSkin();
		
		if (!skin.scale9Grid) {
			Scale9GridUtil.setScale9Grid(skin, CoreUI.defaultDropDownMenuSkinScale9Grid);
        }
		
		addChild(skin);
		var right : Float = (skin.scale9Grid) ? skin.scale9Grid.right : 0;
		buttonWidth = skin.width - right;
		_height = skin.height;
		_width = skin.width;
		labelField = TextStyles.createTextField();
		labelField.text = "Label Label Label Label";
		addChild(labelField);
		skin.addEventListener(MouseEvent.ROLL_OVER, rollOverSkinHandler);
		skin.addEventListener(MouseEvent.ROLL_OUT, rollOutSkinHandler);
		skin.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownSkinHandler);
		list = new List(); 
		list.focusEnabled = false;
		list.itemRendererClass = DropDownListItemRenderer;
		list.allowMultipleSelection = false;
		list.clickSelect = true;
		list.addEventListener(ListEvent.ITEM_SELECT, listSelectHandler);
    }
	
	override private function validate() : Void
	{
		skin.width = _width;
		skin.height = _height;
		labelField.x = 4;
		labelField.width = _width - (buttonWidth + 4);
		labelField.height = Math.min(labelField.textHeight + 4, _height);
		labelField.y = (_height - (labelField.height)) >> 1;
		var pt : Point = new Point(0, _height);
		pt = localToGlobal(pt);
		list.x = pt.x;
		list.y = pt.y;
		list.width = _width;
		updateListHeight();
		list.validateNow();
    }
	
	private function updateListHeight() : Void
	{
		if (list.stage == null) return;
		if (_dataProvider == null) return;
		var maxHeight : Int = _maxVisibleItems * list.itemRendererHeight + list.padding * 2;
		var currentHeight : Int = _dataProvider.length * list.itemRendererHeight + list.padding * 2;
		list.height = Math.min(maxHeight, currentHeight);
    }
	
	private function updateLabel() : Void
	{
		if (selectedItem == null) {
			labelField.text = "<No Selection>";
        } else {
			labelField.text = list.dataDescriptor.getLabel(selectedItem);
        }
    }
	
	private function openList() : Void
	{
		if (list.stage) return;
		stage.addChild(list);
		invalidate();
		stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDownStage);
    }
	
	private function closeList() : Void
	{
		if (list.parent == null) return;
		list.parent.removeChild(list);
		list.selectedItems = [];
		invalidate();
    }
	
	override public function onLoseComponentFocus() : Void
	{
		closeList();
		dispatchEvent(new ItemEditorEvent(ItemEditorEvent.COMMIT_VALUE, _selectedItem, "selectedItem"));
    }  
	
	////////////////////////////////////////////////    
	// Event handlers   
	////////////////////////////////////////////////  
	
	private function onMouseDownStage(event : MouseEvent) : Void
	{
		if (!list.stage) return;
		if (list.hitTestPoint(event.stageX, event.stageY)) return;
		if (hitTestPoint(event.stageX, event.stageY)) return;
		closeList();
    }
	
	private function listSelectHandler(event : ListEvent) : Void
	{
		if (event.target != list) return;
		_selectedItem = event.item;
		updateLabel();
		closeList();
		dispatchEvent(new Event(Event.CHANGE));
		dispatchEvent(new ItemEditorEvent(ItemEditorEvent.COMMIT_VALUE, _selectedItem, "selectedItem"));
    }
	
	private function rollOverSkinHandler(event : MouseEvent) : Void
	{
		skin.gotoAndPlay("Over");
    }
	
	private function rollOutSkinHandler(event : MouseEvent) : Void
	{
		skin.gotoAndPlay("Up");
    }
	
	private function mouseDownSkinHandler(event : MouseEvent) : Void
	{
		skin.gotoAndPlay("Down");(list.stage) ? closeList() : openList();
    }  
	
	////////////////////////////////////////////////    
	// Getters/Setters    
	////////////////////////////////////////////////  
	
	private function set_SelectedItem(value : Dynamic) : Dynamic
	{
		if (value == _selectedItem) return;
		_selectedItem = value;
		updateLabel();
        return value;
    }
	
	private function get_SelectedItem() : Dynamic
	{
		return _selectedItem;
    }
	
	private function set_DataProvider(value : ArrayCollection) : ArrayCollection
	{
		_dataProvider = value;
		list.dataProvider = _dataProvider;  
		// Auto-select the first item  
		_selectedItem = ((_dataProvider != null && _dataProvider.length > 0)) ? _dataProvider[0] : null;
		updateLabel();
        return value;
    }
	
	private function get_DataProvider() : ArrayCollection
	{
		return _dataProvider;
    }
	
	private function set_MaxVisibleItems(value : Int) : Int
	{
		if (value == _maxVisibleItems) return;
		_maxVisibleItems = value;
		updateListHeight();
        return value;
    }
	
	private function get_MaxVisibleItems() : Int
	{
		return _maxVisibleItems;
    }
}