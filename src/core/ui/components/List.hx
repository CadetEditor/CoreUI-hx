  /**
 * List.as
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
import flash.display.DisplayObject;
import flash.display.InteractiveObject;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.utils.Dictionary;
import core.ui.CoreUI;
import core.ui.components.IItemRenderer;
import core.ui.data.DefaultDataDescriptor;
import core.ui.data.IDataDescriptor;
import core.ui.events.DragAndDropEvent;
import core.ui.events.ListEvent;
import core.ui.events.ScrollEvent;
import core.ui.util.Scale9GridUtil;

@:meta(Event(type="flash.events.Event",name="change"))
@:meta(Event(type="core.ui.events.ScrollEvent",name="scrollChange"))
@:meta(Event(type="core.ui.events.DragAndDropEvent",name="dragStart"))
@:meta(Event(type="core.ui.events.DragAndDropEvent",name="dragOver"))
@:meta(Event(type="core.ui.events.DragAndDropEvent",name="dragDrop"))
@:meta(Event(type="core.ui.events.ListEvent",name="itemSelect"))
@:meta(Event(type="core.ui.events.ListEvent",name="itemRollOver"))
@:meta(Event(type="core.ui.events.ListEvent",name="itemRollOut"))

class List extends UIComponent
{
    public var dataProvider(get, set) : Dynamic;
    public var selectedItems(get, set) : Array<Dynamic>;
    public var selectedItem(get, set) : Dynamic;
    public var maxScrollY(get, never) : Int;
    public var scrollY(get, set) : Int;
    public var itemRendererHeight(get, never) : Int;
    public var dataDescriptor(get, set) : IDataDescriptor;
    public var clickSelect(get, set) : Bool;
    public var allowMultipleSelection(get, set) : Bool;
    public var itemRendererClass(get, set) : Class<Dynamic>;
    public var allowDragAndDrop(get, set) : Bool;
    public var filterFunction(get, set) : Function;
    public var showBorder(get, set) : Bool;
    public var padding(get, set) : Int;
  
	// Properties  
	
	private var _dataProvider : Dynamic;
	private var _selectedItems : Array<Dynamic>;
	private var _allowMultipleSelection : Bool = false;
	private var _dataDescriptor : IDataDescriptor;
	private var _filterFunction : Function;
	private var _autoHideVScrollBar : Bool = true;
	private var _autoHideHScrollBar : Bool = true;
	private var _itemRendererClass : Class<Dynamic>;
	private var _clickSelect : Bool = false;
	private var _allowDragAndDrop : Bool = false;
	private var _padding : Int = 4;  
	
	// Child elements  
	
	private var border : Sprite;
	private var content : Sprite;
	private var vScrollBar : ScrollBar;
	private var visibleItemRenderers : Array<IItemRenderer>;
	private var itemRendererPool : Array<IItemRenderer>;
	private var dropIndicator : Sprite;  
	
	// Internal vars  
	
	private var focusedItem : Dynamic;
	private var flattenedData : Array<Dynamic>;
	private var visibleData : Array<Dynamic>;
	private var _itemRendererHeight : Int;
	private var dropTargetCollection : ArrayCollection;
	private var dropTargetIndex : Int;
	private var draggedItemRenderer : DisplayObject;
	private var mouseDownDragStart : Point;
	
	public function new()
    {
        super();
    }  
	
	////////////////////////////////////////////////    
	// Public methods    
	////////////////////////////////////////////////  
	
	public function scrollToItem(item : Dynamic) : Void
	{
		validateNow();
		var index : Int = Lambda.indexOf(flattenedData, item);
		if (index == -1) return;
		vScrollBar.value = index * _itemRendererHeight;
    }
	
	public function getItemRendererForData(data : Dynamic) : IItemRenderer
	{
		for (itemRenderer in visibleItemRenderers) {
			if (itemRenderer.data == data) return itemRenderer;
        }
		
		return null;
    }  
	
	////////////////////////////////////////////////    
	// Protected methods    
	////////////////////////////////////////////////  
	
	override private function init() : Void
	{
		doubleClickEnabled = true;
		border = new ListSkin();
		
		if (!border.scale9Grid) {
			Scale9GridUtil.setScale9Grid(border, CoreUI.defaultListSkinScale9Grid);
        }
		
		addChild(border);
		content = new Sprite();
		content.scrollRect = new Rectangle();
		content.addEventListener(MouseEvent.MOUSE_OVER, rollOverContentHandler);
		content.addEventListener(MouseEvent.MOUSE_OUT, rollOutContentHandler);
		addChild(content);
		focusEnabled = true;
		visibleItemRenderers = new Array<IItemRenderer>();
		itemRendererPool = new Array<IItemRenderer>();
		_itemRendererClass = ListItemRenderer;
		_dataDescriptor = new DefaultDataDescriptor();
		_selectedItems = [];  
		
		// Create an item renderer so we can pluck out its height  
		
		var itemRenderer : IItemRenderer = Type.createInstance(_itemRendererClass, []);
		_itemRendererHeight = cast((itemRenderer), UIComponent).height;
		vScrollBar = new ScrollBar();
		vScrollBar.scrollSpeed = _itemRendererHeight; 
		vScrollBar.pageScrollSpeed = _itemRendererHeight * 4;
		addChild(vScrollBar);
		dropIndicator = new ListDropIndicatorSkin();
		
		if (!dropIndicator.scale9Grid) {
			Scale9GridUtil.setScale9Grid(dropIndicator, CoreUI.defaultListDropIndicatorSkinScale9Grid);
        }
		
		addChild(dropIndicator);
		dropIndicator.visible = false;
		_clickSelect = true;
		clickSelect = false;
		content.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownContentHandler);
		addEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelHandler);
    }
	
	override private function validate() : Void
	{
		calculateFlattenedData();
		
		if (_resizeToContentHeight) {
			_height = flattenedData.length * _itemRendererHeight + _padding * 2;
        }
		
		calculateVisibleData();
		var firstVisibleDataIndex : Int = visibleData.length > (0) ? Lambda.indexOf(flattenedData, visibleData[0]) : 0;  
		
		// First, loop through existing visible item renderers and stick them    
		// on the pool if their data is no longer visible.  
		
		var visibleItemRenderersByData : Dictionary = new Dictionary(true);
		while (visibleItemRenderers.length > 0) {
			var itemRenderer : IItemRenderer = visibleItemRenderers.pop();
			var data : Dynamic = itemRenderer.data;
			if (Lambda.indexOf(visibleData, data) == -1) {
				itemRendererPool.push(itemRenderer);
				itemRenderer.selected = false;
				content.removeChild(cast((itemRenderer), DisplayObject));
            }else {
				Reflect.setField(visibleItemRenderersByData, Std.string(data), itemRenderer);
            }
        }
		
		for (i in 0...visibleData.length) {
			data = visibleData[i]; 
			itemRenderer = Reflect.field(visibleItemRenderersByData, Std.string(data));
			if (itemRenderer == null) {
				if (itemRendererPool.length > 0) {
					itemRenderer = itemRendererPool.pop();
                } else {
					itemRenderer = Type.createInstance(_itemRendererClass, []);
					itemRenderer.list = this;
                }
				Reflect.setField(visibleItemRenderersByData, Std.string(data), itemRenderer);
				itemRenderer.data = data;itemRenderer.resizeToContentWidth = _resizeToContentWidth;itemRenderer.percentWidth = (_resizeToContentWidth) ? NaN : 100;
            }
			
			visibleItemRenderers.push(itemRenderer);
			content.addChild(cast((itemRenderer), DisplayObject));
			itemRenderer.selected = Lambda.indexOf(_selectedItems, data) != -1;
        }
		
		initVisibleItemRenderers();
		var layoutArea : Rectangle = getChildrenLayoutArea();
		if (_resizeToContentWidth) {
			var maxWidth : Int = 0;
			for (visibleData.length) {
				itemRenderer = visibleItemRenderers[i]; 
				itemRenderer.validateNow();
				maxWidth = itemRenderer.width > (maxWidth != 0) ? itemRenderer.width : maxWidth;
            }
			for (visibleData.length) {
				itemRenderer = visibleItemRenderers[i];
				itemRenderer.resizeToContentWidth = false;
            }
			_width = maxWidth + _padding * 2;
			layoutArea.width = maxWidth;
        }
		
		if (_resizeToContentHeight == false) {
			vScrollBar.removeEventListener(Event.CHANGE, onChangeVScrollBar);
			vScrollBar.x = _width - vScrollBar.width;
			vScrollBar.height = _height;
			vScrollBar.validateNow();
			vScrollBar.addEventListener(Event.CHANGE, onChangeVScrollBar);
			vScrollBar.visible = vScrollBar.thumbSizeRatio < 1;
			if (vScrollBar.visible) layoutArea.right = vScrollBar.x;
        } else {
			vScrollBar.visible = false;
        }
		
		content.x = layoutArea.x;
		content.y = layoutArea.y;
		var scrollRect : Rectangle = content.scrollRect;
		scrollRect.width = layoutArea.width;
		scrollRect.height = layoutArea.height;
		scrollRect.y = -Math.round( -vScrollBar.value + firstVisibleDataIndex * _itemRendererHeight);
		content.scrollRect = scrollRect;  
		
		// Finally, layout the item renderers  
		for (visibleItemRenderers.length) {
			itemRenderer = visibleItemRenderers[i];
			itemRenderer.y = i * _itemRendererHeight;
			itemRenderer.width = layoutArea.width;
			itemRenderer.validateNow();
        }
		
		border.width = _width;
		border.height = _height;
    }
	
	private function getChildrenLayoutArea() : Rectangle
	{
		return new Rectangle(_padding, _padding, _width - _padding * 2, _height - _padding * 2);
    }
	
	private function initVisibleItemRenderers() : Void
	{
    }
	
	private function calculateFlattenedData() : Void
	{
		if (Std.is(_dataProvider, ArrayCollection)) {
			flattenedData = cast((_dataProvider), ArrayCollection).source;
        } else {
			flattenedData = [];
        }
		
		if (_filterFunction != null) {
			flattenedData = flattenedData.substring();
			for (i in 0...flattenedData.length) {
				var data : Dynamic = flattenedData[i];
				if (_filterFunction(data) == false) {
					flattenedData.splice(i, 1);i--;
                }
            }
        }
    }
	
	private function calculateVisibleData() : Void
	{
		if (_resizeToContentHeight) {
			vScrollBar.value = 0;
			visibleData = flattenedData.substring();
			return;
        }
		
		var contentHeight : Int = flattenedData.length * _itemRendererHeight;
		var layoutArea : Rectangle = getChildrenLayoutArea();
		vScrollBar.max = contentHeight - layoutArea.height; 
		vScrollBar.thumbSizeRatio = layoutArea.height / contentHeight;
		var startIndex : Int = Math.floor(vScrollBar.value / _itemRendererHeight);
		var endIndex : Int = startIndex + Math.ceil(layoutArea.height / _itemRendererHeight) + 1;
		endIndex = endIndex > (flattenedData.length) ? flattenedData.length : endIndex;
		visibleData = flattenedData.substring(startIndex, endIndex);
    }  
	
	////////////////////////////////////////////////    
	// Drag and drop protected methods    
	////////////////////////////////////////////////  
	
	private function beginDrag() : Void
	{  
		// Find out which item renderer the mouse was over when the user pressed.  
		var pressPos : Point = content.localToGlobal(mouseDownDragStart);
		
		for (i in 0...content.numChildren) {
			var itemRenderer : DisplayObject = content.getChildAt(i);
			if (itemRenderer.hitTestPoint(pressPos.x, pressPos.y) == false) continue;

			// Clone the item renderer and attach it to the mouse.    
			// Begin dragging this item renderer  ;
			
			dropIndicator.visible = true;  
			
			//draggedItemRenderer = new itemRendererClass();    
			//var className:String = getClassName(itemRendererClass);  
			var className : String = flash.utils.getQualifiedClassName(itemRendererClass).replace("::", ".");
			var ClassReference : Class<Dynamic> = Type.getClass(Type.resolveClass(className));
			draggedItemRenderer = Type.createInstance(ClassReference, []);
			cast((draggedItemRenderer), InteractiveObject).mouseEnabled = false;
			cast((draggedItemRenderer), IItemRenderer).list = this;
			cast((draggedItemRenderer), IItemRenderer).data = cast((itemRenderer), IItemRenderer).data;
			cast((draggedItemRenderer), IItemRenderer).selected = cast((itemRenderer), IItemRenderer).selected; 
			draggedItemRenderer.width = itemRenderer.width; 
			draggedItemRenderer.height = itemRenderer.height; 
			draggedItemRenderer.alpha = 0.5;
			cast((draggedItemRenderer), IItemRenderer).validateNow();
			draggedItemRenderer.x = stage.mouseX - itemRenderer.mouseX;
			draggedItemRenderer.y = stage.mouseY - itemRenderer.mouseY;
			cast((draggedItemRenderer), Sprite).startDrag(false);
			stage.addChild(draggedItemRenderer); 
			dispatchEvent(new DragAndDropEvent(DragAndDropEvent.DRAG_START, cast((itemRenderer), IItemRenderer).data));
			return;
        }
    }
	
	private function getClassName(object : Dynamic) : String
	{
		var classPath : String = flash.utils.getQualifiedClassName(object).replace("::", ".");
		if (classPath.indexOf(".") == -1) return classPath;
		var split : Array<Dynamic> = classPath.split(".");
		return split[split.length - 1];
    }
	
	private function updateDropTarget() : Void
	{
		var newDropTargetCollection : ArrayCollection;
		var newDropTargetIndex : Int = -1;
		
		for (itemRenderer in visibleItemRenderers) {
			if (cast((itemRenderer), DisplayObject).hitTestPoint(stage.mouseX, stage.mouseY) == false) continue;
			newDropTargetCollection = cast((_dataProvider), ArrayCollection);
			newDropTargetIndex = dropTargetCollection.getItemIndex(itemRenderer.data);
			if (cast((itemRenderer), DisplayObject).mouseY > (itemRenderer.height >> 1)) {
				dropTargetIndex++;
            }
			break;
        }
		
		if (newDropTargetCollection == dropTargetCollection && newDropTargetIndex == dropTargetIndex) return;
		var event : DragAndDropEvent = new DragAndDropEvent(DragAndDropEvent.DRAG_OVER, cast((draggedItemRenderer), IItemRenderer).data, newDropTargetCollection, newDropTargetIndex);
		dispatchEvent(event);
		
		if (event.isDefaultPrevented()) { 
			dropTargetCollection = null; 
			dropTargetIndex = -1;
			return;
        }
		
		dropTargetCollection = newDropTargetCollection;dropTargetIndex = newDropTargetIndex;
    }
	
	private function updateDropIndicator(dropTargetCollection : ArrayCollection, dropTargetIndex : Int) : Void
	{
		var after : Bool = dropTargetIndex >= dropTargetCollection.length;
		var dropTargetData : Dynamic = dropTargetCollection[(after) ? dropTargetIndex - 1 : dropTargetIndex];
		var itemRenderer : IItemRenderer = getItemRendererForData(dropTargetData);
		
		if (itemRenderer == null) return;
		
		if (after) {
			dropIndicator.y = -content.scrollRect.y + itemRenderer.y + itemRenderer.height;
        } else {
			dropIndicator.y = -content.scrollRect.y + itemRenderer.y;
        }
		
		dropIndicator.width = itemRenderer.width - dropIndicator.x - 10;
    }
	
	private function handleDrop(draggedItem : Dynamic, targetCollection : ArrayCollection, targetIndex : Int) : Void
	{
		var event : DragAndDropEvent = new DragAndDropEvent(DragAndDropEvent.DRAG_DROP, draggedItem, targetCollection, targetIndex);
		dispatchEvent(event);
		
		if (event.isDefaultPrevented()) return;
		
		// Removed the item from the data provider and re-insert it at the proper index  
		var draggedItemIndex : Int = targetCollection.getItemIndex(draggedItem);
		targetCollection.removeItemAt(draggedItemIndex);
		if (draggedItemIndex < targetIndex) {
			targetIndex--;
        }
		targetCollection.addItemAt(draggedItem, targetIndex);
    }  
	
	////////////////////////////////////////////////    
	// Event handlers    
	////////////////////////////////////////////////  
	
	private function rollOverContentHandler(event : MouseEvent) : Void
	{
		var itemRenderer : IItemRenderer = try cast(event.target, IItemRenderer) catch (e:Dynamic) null;
		if (itemRenderer == null) return;
		dispatchEvent(new ListEvent(ListEvent.ITEM_ROLL_OVER, itemRenderer.data));
    }
	
	private function rollOutContentHandler(event : MouseEvent) : Void
	{
		var itemRenderer : IItemRenderer = try cast(event.target, IItemRenderer) catch (e:Dynamic) null;
		if (itemRenderer == null) return;
		dispatchEvent(new ListEvent(ListEvent.ITEM_ROLL_OUT, itemRenderer.data));
    }
	
	private function dataProviderChangeHandler(event : ArrayCollectionEvent) : Void
	{
		if (event.kind == ArrayCollectionChangeKind.RESET) {
			_selectedItems = [];
        } else if (event.kind == ArrayCollectionChangeKind.REMOVE) {
			var selectedIndex : Int = Lambda.indexOf(_selectedItems, event.item);
			if (selectedIndex != -1) {
				_selectedItems.splice(selectedIndex, 1);
            }
        }
		
		invalidate();
    }
	
	private function mouseSelectContentHandler(event : MouseEvent) : Void
	{  
		// Determine the selected index into the flattedData array  
		var firstVisibleDataIndex : Int = visibleData.length > (0) ? Lambda.indexOf(flattenedData, visibleData[0]) : 0;
		var selectedVisibleIndex : Int = (content.mouseY / _itemRendererHeight);
		var index : Int = firstVisibleDataIndex + selectedVisibleIndex;
		
		if (index < 0 || index >= flattenedData.length) return;
		var item : Dynamic = flattenedData[index];
		if (item != null && _dataDescriptor.getEnabled(item) == false) return;  
		
		// The following logic implements the behaviour we expect to see from lists 
		// with various combinations of clicking and CTRL and/or SHIFT.
		// I've lifted this directly from Window's native list behaviour.    

		if (_allowMultipleSelection && (event.shiftKey || event.ctrlKey)) {
			if (event.shiftKey) {  
				// Range select  
				var focusedIndex : Int = Lambda.indexOf(flattenedData, focusedItem); 
				focusedIndex = focusedIndex == -(1) ? 0 : focusedIndex;
				var min : Int = Math.min(focusedIndex, index);
				var max : Int = Math.max(focusedIndex, index);
				var newSelectedItems : Array<Dynamic> = [];
				
				for (i in min...max + 1) {
					newSelectedItems.push(flattenedData[i]);
                }  
				
				// Append the range select  
				if (event.ctrlKey) {
					focusedItem = flattenedData[index];
					selectedItems = _selectedItems.concat(newSelectedItems);
                }
                // Replace selection with range
                else {
					selectedItems = newSelectedItems;
                }
            }
            else if (event.ctrlKey) {  
				// Single click add selected item  
				focusedItem = flattenedData[index];
				if (Lambda.indexOf(_selectedItems, focusedItem) == -1) {
					_selectedItems.push(focusedItem);
                }
                // Single click
                else {
					_selectedItems.splice(Lambda.indexOf(_selectedItems, focusedItem), 1);
                }
            }
        }
        else {
			focusedItem = flattenedData[index];
			_selectedItems = [focusedItem];
        }  
		
		// We use the setter method to ensure the new _selectedItems value is clean of duplicates.  
		
		selectedItems = _selectedItems;
		invalidate();
		dispatchEvent(new ListEvent(ListEvent.ITEM_SELECT, flattenedData[index]));
    }
	
	private function mouseWheelHandler(event : MouseEvent) : Void
	{
		vScrollBar.value += vScrollBar.scrollSpeed * (event.delta < (0) ? 1 : -1);
    }
	
	private function onChangeVScrollBar(event : Event) : Void
	{
		invalidate();
		dispatchEvent(new ScrollEvent(ScrollEvent.CHANGE_SCROLL));
    }
	
	private function mouseDownContentHandler(event : MouseEvent) : Void
	{
		if (_allowDragAndDrop) {
			mouseDownDragStart = new Point(content.mouseX, content.mouseY);
			stage.addEventListener(Event.ENTER_FRAME, dragHandler);
			stage.addEventListener(MouseEvent.MOUSE_UP, endDragHandler);
        }
    }
	
	private function dragHandler(event : Event) : Void
	{  
		// If we're not yet dragging, check to see if we've moved the mouse enough from the press point.  
		if (draggedItemRenderer == null) {
			var dis : Int = Math.abs(content.mouseX - mouseDownDragStart.x) + Math.abs(content.mouseY - mouseDownDragStart.y);
			if (dis > 3) {
				beginDrag();
            }
        }
		if (draggedItemRenderer != null) {
			if (content.mouseY < 20) {
				scrollY -= 2;
            }
            else if (content.mouseY > getChildrenLayoutArea().height - 20) {
				scrollY += 2;
            }
			
			updateDropTarget();
			
			if (dropTargetCollection == null) {
				dropIndicator.visible = false;
            }
            else {
				dropIndicator.visible = true;
				updateDropIndicator(dropTargetCollection, dropTargetIndex);
            }
        }
    }
	
	private function endDragHandler(event : MouseEvent) : Void
	{
		if (draggedItemRenderer != null) {
			if (dropTargetCollection != null) {
				handleDrop(cast((draggedItemRenderer), IItemRenderer).data, dropTargetCollection, dropTargetIndex);
            }
			cast((draggedItemRenderer), Sprite).stopDrag();
			stage.removeChild(draggedItemRenderer);
			draggedItemRenderer = null;
			dropTargetCollection = null;
			dropTargetIndex - -1;
        }
		
		dropIndicator.visible = false;
		stage.removeEventListener(Event.ENTER_FRAME, dragHandler);
		stage.removeEventListener(MouseEvent.MOUSE_UP, endDragHandler);
    }  
	
	////////////////////////////////////////////////    
	// Getters/Setters    
	////////////////////////////////////////////////  
	
	private function set_DataProvider(value : Dynamic) : Dynamic
	{
		if (Std.is(_dataProvider, ArrayCollection)) {
			cast((_dataProvider), ArrayCollection).removeEventListener(ArrayCollectionEvent.CHANGE, dataProviderChangeHandler);
        }
		
		_dataProvider = value;
		
		if (Std.is(_dataProvider, ArrayCollection)) {
			cast((_dataProvider), ArrayCollection).addEventListener(ArrayCollectionEvent.CHANGE, dataProviderChangeHandler);
        }
		
		_selectedItems = [];
		invalidate();
        return value;
    }
	
	private function get_DataProvider() : Dynamic {
		return _dataProvider;
    }
	
	private function set_SelectedItems(value : Array<Dynamic>) : Array<Dynamic>
	{
		_selectedItems = value.substring();  
		
		// Clear the array of duplicates  
		var table : Dictionary = new Dictionary(true);
		for (i in 0..._selectedItems.length) {
			var item : Dynamic = _selectedItems[i];
			
			if (Reflect.field(table, Std.string(item))) {
				_selectedItems.splice(i, 1);i--;
            }
            else {
				Reflect.setField(table, Std.string(item), true);
            }
        }
		
		dispatchEvent(new Event(Event.CHANGE));
		invalidate();
        return value;
    }
	
	private function get_SelectedItems() : Array<Dynamic>
	{
		return _selectedItems.substring();
    }
	
	private function set_SelectedItem(value : Dynamic) : Dynamic
	{
		selectedItems = value == (null) ? [] : [value];
        return value;
    }
	
	private function get_SelectedItem() : Dynamic
	{
		return _selectedItems.length == (0) ? null : _selectedItems[0];
    }
	
	private function get_MaxScrollY() : Int
	{
		return vScrollBar.max;
    }
	
	private function set_ScrollY(value : Int) : Int
	{
		if (value == vScrollBar.value) return;
		vScrollBar.removeEventListener(Event.CHANGE, onChangeVScrollBar);
		vScrollBar.value = value;
		vScrollBar.addEventListener(Event.CHANGE, onChangeVScrollBar);
		invalidate();
		dispatchEvent(new ScrollEvent(ScrollEvent.CHANGE_SCROLL));
        return value;
    }
	
	private function get_ScrollY() : Int
	{
		return vScrollBar.value;
    }
	
	private function get_ItemRendererHeight() : Int
	{
		return _itemRendererHeight;
    }
	
	private function set_DataDescriptor(value : IDataDescriptor) : IDataDescriptor
	{
		_dataDescriptor = value;
        return value;
    }
	
	private function get_DataDescriptor() : IDataDescriptor
	{
		return _dataDescriptor;
    }
	
	private function set_ClickSelect(value : Bool) : Bool
	{
		if (value == _clickSelect) return;
		_clickSelect = value;
		if (_clickSelect) {
			content.addEventListener(MouseEvent.CLICK, mouseSelectContentHandler);
			content.removeEventListener(MouseEvent.MOUSE_DOWN, mouseSelectContentHandler);
        } else {
			content.removeEventListener(MouseEvent.CLICK, mouseSelectContentHandler);
			content.addEventListener(MouseEvent.MOUSE_DOWN, mouseSelectContentHandler);
        }
        return value;
    }
	
	private function get_ClickSelect() : Bool
	{
		return _clickSelect;
    }
	
	private function set_AllowMultipleSelection(value : Bool) : Bool
	{
		if (value == _allowMultipleSelection) return;
		_allowMultipleSelection = value;
		if (!_allowMultipleSelection) {
			if (_selectedItems.length > 1) {
				_selectedItems = [_selectedItems[_selectedItems.length - 1]];
            }
        }
		invalidate();
        return value;
    }
	
	private function get_AllowMultipleSelection() : Bool
	{
		return _allowMultipleSelection;
    }
	
	private function set_ItemRendererClass(value : Class<Dynamic>) : Class<Dynamic>
	{
		if (value == _itemRendererClass) return;
		_itemRendererClass = value;
		visibleItemRenderers = new Array<IItemRenderer>();
		itemRendererPool = new Array<IItemRenderer>();
		
		while (content.numChildren > 0) {
			content.removeChildAt(0);
        }
		
		var itemRenderer : IItemRenderer = Type.createInstance(_itemRendererClass, []);
		_itemRendererHeight = cast((itemRenderer), UIComponent).height;
		invalidate();
        return value;
    }
	
	private function get_ItemRendererClass() : Class<Dynamic>
	{
		return _itemRendererClass;
    }
	
	private function set_AllowDragAndDrop(value : Bool) : Bool
	{
		_allowDragAndDrop = value;
        return value;
    }
	
	private function get_AllowDragAndDrop() : Bool
	{
		return _allowDragAndDrop;
    }
	
	private function get_FilterFunction() : Function
	{
		return _filterFunction;
    }
	
	private function set_FilterFunction(value : Function) : Function
	{
		_filterFunction = value;
		invalidate();
        return value;
    }
	
	private function set_ShowBorder(value : Bool) : Bool
	{
		border.visible = value;
        return value;
    }
	
	private function get_ShowBorder() : Bool
	{
		return border.visible;
    }
	
	private function set_Padding(value : Int) : Int
	{
		_padding = value;
		invalidate();
        return value;
    }
	
	private function get_Padding() : Int
	{
		return _padding;
    }
}