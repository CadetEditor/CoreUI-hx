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
 */  package core.ui.components;

import core.ui.components.TreeEvent;
import nme.errors.Error;
import nme.display.DisplayObject;import nme.events.Event;import nme.utils.Dictionary;import core.data.ArrayCollection;import core.events.ArrayCollectionEvent;import core.ui.events.DragAndDropEvent;import core.ui.events.TreeEvent;import core.ui.components.IItemRenderer;@:meta(Event(type="core.ui.events.TreeEvent",name="itemOpen"))
@:meta(Event(type="core.ui.events.TreeEvent",name="itemClose"))
class Tree extends List
{
    public var showRoot(get, set) : Bool;
  // Properties  private var _showRoot : Bool = true;  // Internal vars  private var isOpenedTable : Dictionary;private var depthTable : Dictionary;public function new()
    {
        super();
    }  ////////////////////////////////////////////////    // Public methods    ////////////////////////////////////////////////  public function openToItem(item : Dynamic) : Void{var parent : Dynamic = getParent(item, false);while (parent){setItemOpened(parent, true);parent = getParent(parent, false);
        }
    }public function setItemOpened(item : Dynamic, opened : Bool, dispatchEvent : Bool = false) : Void{if (Reflect.field(isOpenedTable, Std.string(item)) == opened)             return;Reflect.setField(isOpenedTable, Std.string(item), opened);var itemRenderer : ITreeItemRenderer = cast((getItemRendererForData(item)), ITreeItemRenderer);if (itemRenderer != null) {itemRenderer.opened = opened;
        }invalidate();if (dispatchEvent) {this.dispatchEvent(new TreeEvent((opened) ? TreeEvent.ITEM_OPEN : TreeEvent.ITEM_CLOSE, item));
        }
    }public function getItemOpened(item : Dynamic) : Bool{return Reflect.field(isOpenedTable, Std.string(item));
    }  /**
		 * Given a data item, this function will return its logical parent. Ie, the object with a 'children' collection containing the item.
		 * @param	item				The item to return the parent for.
		 * @param	searchOnlyVisible	By default, this function only searches visible items (ie opened). Pass false for a fully recursive search.
		 * @return						The parent of the item, or null if none found.
		 */  public function getParent(item : Dynamic, searchOnlyVisible : Bool = true) : Dynamic{var itemsToSearch : Array<Dynamic> = (_dataProvider != null) ? [_dataProvider] : [];while (itemsToSearch.length > 0){var currentItem : Dynamic = itemsToSearch.pop();if (_dataDescriptor.hasChildren(currentItem) == false)                 continue;if (searchOnlyVisible && Reflect.field(isOpenedTable, Std.string(currentItem)) != true)                 continue;var children : ArrayCollection = _dataDescriptor.getChildren(currentItem);if (Std.is(item, ArrayCollection)) {if (children == item)                     return currentItem;
            }
            else if (children.getItemIndex(item) != -1) {return currentItem;
            }itemsToSearch = itemsToSearch.concat(children.source);
        }return null;
    }  ////////////////////////////////////////////////    // Protected methods    ////////////////////////////////////////////////  override private function init() : Void{super.init();isOpenedTable = new Dictionary(true);_itemRendererClass = TreeItemRenderer;content.addEventListener(Event.CHANGE, itemRendererChangeHandler);
    }override private function calculateFlattenedData() : Void{if (_showRoot == false && _dataProvider != null) {Reflect.setField(isOpenedTable, Std.string(_dataProvider), true);
        }flattenedData = [];var dataToParse : Array<Dynamic>;dataToParse = _dataProvider == (null) ? [] : [_dataProvider];depthTable = new Dictionary(true);while (dataToParse.length > 0){var data : Dynamic = dataToParse.shift();if (_filterFunction != null && _filterFunction(data) == false) {continue;
            }var depth : Int = Reflect.field(depthTable, Std.string(data));if (data != _dataProvider || showRoot) {flattenedData.push(data);
            }if (_dataDescriptor.hasChildren(data) == false)                 continue;if (Reflect.field(isOpenedTable, Std.string(data)) != true)                 continue;var children : ArrayCollection = _dataDescriptor.getChildren(data);children.addEventListener(ArrayCollectionEvent.CHANGE, dataProviderChangeHandler, false, 0, true);var childrenSource : Array<Dynamic> = children.source;for (i in 0...childrenSource.length){Reflect.setField(depthTable, Std.string(childrenSource[i]), depth + 1);
            }dataToParse = childrenSource.concat(dataToParse);
        }
    }override private function initVisibleItemRenderers() : Void{for (i in 0...visibleItemRenderers.length){var itemRenderer : ITreeItemRenderer = cast((visibleItemRenderers[i]), ITreeItemRenderer);itemRenderer.depth = depthTable[itemRenderer.data] + ((showRoot) ? 0 : -1);itemRenderer.opened = isOpenedTable[itemRenderer.data];
        }
    }  ////////////////////////////////////////////////    // Drag and drop protected methods    ////////////////////////////////////////////////  override private function updateDropTarget() : Void{var newDropTargetCollection : ArrayCollection;var newDropTargetIndex : Int = -1;for (itemRenderer in visibleItemRenderers){if (cast((itemRenderer), DisplayObject).hitTestPoint(stage.mouseX, stage.mouseY) == false)                 continue;var after : Bool = cast((itemRenderer), DisplayObject).mouseY > (itemRenderer.height >> 1);var hasChildren : Bool = _dataDescriptor.hasChildren(itemRenderer.data);if (after && hasChildren && isOpenedTable[itemRenderer.data] == true) {newDropTargetCollection = _dataDescriptor.getChildren(itemRenderer.data);newDropTargetIndex = 0;
            }
            else {var dropTargetParent : Dynamic = getParent(itemRenderer.data);newDropTargetCollection = _dataDescriptor.getChildren(dropTargetParent);newDropTargetIndex = newDropTargetCollection.getItemIndex(itemRenderer.data);if (after) {newDropTargetIndex++;
                }
            }break;
        }  // Dissallow adding as child of oneself.  if (isParentOf(cast((draggedItemRenderer), IItemRenderer).data, newDropTargetCollection)) {dropTargetCollection = null;dropTargetIndex - -1;return;
        }if (newDropTargetCollection == dropTargetCollection && newDropTargetIndex == dropTargetIndex)             return;var event : DragAndDropEvent = new DragAndDropEvent(DragAndDropEvent.DRAG_OVER, cast((draggedItemRenderer), IItemRenderer).data, newDropTargetCollection, newDropTargetIndex);dispatchEvent(event);if (event.isDefaultPrevented()) {dropTargetCollection = null;dropTargetIndex = -1;return;
        }dropTargetCollection = newDropTargetCollection;dropTargetIndex = newDropTargetIndex;
    }override private function updateDropIndicator(dropTargetCollection : ArrayCollection, dropTargetIndex : Int) : Void{var after : Bool = dropTargetIndex >= dropTargetCollection.length;var dropTargetData : Dynamic = dropTargetCollection[(after) ? dropTargetIndex - 1 : dropTargetIndex];var itemRenderer : ITreeItemRenderer = cast((getItemRendererForData(dropTargetData)), ITreeItemRenderer);if (itemRenderer != null) {dropIndicator.x = itemRenderer.depth * 16;
        }super.updateDropIndicator(dropTargetCollection, dropTargetIndex);
    }override private function handleDrop(draggedItem : Dynamic, targetCollection : ArrayCollection, targetIndex : Int) : Void{var event : DragAndDropEvent = new DragAndDropEvent(DragAndDropEvent.DRAG_DROP, draggedItem, targetCollection, targetIndex);dispatchEvent(event);if (event.isDefaultPrevented())             return  // Removed the item from the data provider and re-insert it at the proper index  ;var sourceCollection : ArrayCollection = _dataDescriptor.getChildren(getParent(draggedItem));var draggedItemIndex : Int = sourceCollection.getItemIndex(draggedItem);sourceCollection.removeItemAt(draggedItemIndex);if (sourceCollection == targetCollection && draggedItemIndex < targetIndex) {targetIndex--;
        }targetCollection.addItemAt(draggedItem, targetIndex);
    }private function isParentOf(parent : Dynamic, item : Dynamic) : Bool{while (item){if (parent == item)                 return true;item = getParent(item);
        }return false;
    }  ////////////////////////////////////////////////    // Event handlers    ////////////////////////////////////////////////  private function itemRendererChangeHandler(event : Event) : Void{var itemRenderer : ITreeItemRenderer = cast((event.target), ITreeItemRenderer);setItemOpened(itemRenderer.data, itemRenderer.opened, true);
    }  ////////////////////////////////////////////////    // Getters/Setters    ////////////////////////////////////////////////  override private function set_DataProvider(value : Dynamic) : Dynamic{if (Std.is(value, ArrayCollection)) {throw (new Error("Tree control does not support ArrayCollection as its root node. Pass an object with children instead."));return;
        }_dataProvider = value;_selectedItems = [];invalidate();
        return value;
    }private function set_ShowRoot(value : Bool) : Bool{if (value == _showRoot)             return;_showRoot = value;_selectedItems = [];invalidate();
        return value;
    }private function get_ShowRoot() : Bool{return _showRoot;
    }
}