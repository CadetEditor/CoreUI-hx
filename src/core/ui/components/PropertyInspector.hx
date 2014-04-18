package core.ui.components;

import core.ui.components.PropertyInspectorItemRenderer;
import core.ui.components.ScrollBar;
import core.ui.components.UIComponent;
import core.ui.components.VBox;
import flash.errors.Error;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.utils.Dictionary;
import core.ui.CoreUI;
import core.ui.data.DefaultPropertyInspectorDataDescriptor;
import core.ui.data.IPropertyInspectorDataDescriptor;
import core.ui.data.PropertyInspectorField;
import core.ui.events.ItemEditorEvent;
import core.ui.events.PropertyInspectorEvent;
import core.ui.util.Scale9GridUtil;

@:meta(Event(type="core.ui.events.PropertyInspectorEvent",name="commitValue"))
class PropertyInspector extends UIComponent
{
    public var dataProvider(get, set) : ArrayCollection;
    public var dataDescriptor(get, set) : IPropertyInspectorDataDescriptor;
    public var showBorder(get, set) : Bool;
    public var padding(get, set) : Int;
  
	// Children  
	
	private var border : Sprite;
	private var container : VBox;
	private var scrollBar : ScrollBar;  
	
	// Properties  
	
	private var _dataProvider : ArrayCollection;
	private var _dataDescriptor : IPropertyInspectorDataDescriptor;
	private var editorDescriptorTable : Dynamic;
	private var dataIsInvalid : Bool;
	private var itemRendererVisInvalid : Bool;
	private var itemRenderers : Array<PropertyInspectorItemRenderer>;
	
	public function new()
    {
		super();
    }  
	
	////////////////////////////////////////////////    
	// Public methods    
	////////////////////////////////////////////////    
	
	/**
	 *
	 * @param	id					The id of the editor. This is how the property inspector matches up inspectable properties with an editor.
	 * 								For example, the metatdata
	 * 								[Inspectable(editor="ColorPicker")]
	 * 								Will cause the PropertyInspector to look for a EditorDescriptor with an id =="ColorPicker"
	 * @param	type				The type of the editor.
	 * @param	valueField			The name of the property on the editor that contains the value being edited (eg NumericStepper's is "value"))
	 * @param	itemsField			(Optional) The name of the property on the editor that should be set with an array of the items being edited.
	 * @param	itemsPropertyField	(Optional) The name of the property on the editor that should be set with the name of the property on the items being edited .
	 */  
	
	public function registerEditor(id : String, type : Class<Dynamic>, valueField : String, itemsField : String = null, itemsPropertyField : String = null, autoCommitValue : Bool = true, changeEventType : String = "change", commitEventType : String = "commitValue") : Void
	{
		var descriptor : EditorDescriptor = new EditorDescriptor(id, type, valueField, itemsField, itemsPropertyField, autoCommitValue, changeEventType, commitEventType);
		Reflect.setField(editorDescriptorTable, id, descriptor);
    }  
	
	////////////////////////////////////////////////    
	// Getters/Setters    
	////////////////////////////////////////////////  
	
	private function set_DataProvider(value : ArrayCollection) : ArrayCollection
	{
		if (_dataProvider != null) {
			_dataProvider.removeEventListener(ArrayCollectionEvent.CHANGE, changeDataProviderHandler);
        }
		
		_dataProvider = value;
		
		if (_dataProvider != null) {
			_dataProvider.addEventListener(ArrayCollectionEvent.CHANGE, changeDataProviderHandler);
        }
		
		dataIsInvalid = true;
		invalidate();
        return value;
    }
	
	private function get_DataProvider() : ArrayCollection
	{
		return _dataProvider;
    }
	
	private function get_DataDescriptor() : IPropertyInspectorDataDescriptor
	{
		return _dataDescriptor;
    }
	
	private function set_DataDescriptor(value : IPropertyInspectorDataDescriptor) : IPropertyInspectorDataDescriptor
	{
		if (value == null) {
			throw (new Error("Value must not be null"));
			return;
        }
		
		_dataDescriptor = value;
		dataIsInvalid = true;
		invalidate();
        return value;
    }  
	
	////////////////////////////////////////////////    
	// Protected methods    
	////////////////////////////////////////////////  
	
	override private function init() : Void
	{
		border = new PropertyInspectorSkin();
		
		if (!border.scale9Grid) {
			Scale9GridUtil.setScale9Grid(border, CoreUI.defaultPropertyInspectorSkinScale9Grid);
        }
		
		addChild(border);
		_dataDescriptor = new DefaultPropertyInspectorDataDescriptor();
		container = new VBox();
		container.padding = 6;
		container.resizeToContentHeight = true;
		addChild(container);
		scrollBar = new ScrollBar();
		scrollBar.addEventListener(Event.CHANGE, changeScrollBarHandler);
		addChild(scrollBar);
		addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
		itemRenderers = new Array<PropertyInspectorItemRenderer>();
		editorDescriptorTable = { };
		registerEditor("TextInput", TextInput, "text");
		registerEditor("NumberInput", NumberInput, "value");
		registerEditor("DropDownMenu", DropDownMenu, "selectedItem");
		registerEditor("NumericStepper", NumericStepper, "value");
		registerEditor("Slider", HSlider, "value");
		registerEditor("ColorPicker", ColorPickerItemEditor, "color");
		registerEditor("CheckBox", CheckBox, "selected");
    }
	
	override private function validate() : Void
	{
		border.width = _width;
		border.height = _height;
		
		if (dataIsInvalid) {
			validateData();
			container.validateNow();
			dataIsInvalid = false;
        }
		
		scrollBar.height = _height;
		scrollBar.visible = container.height > _height;
		scrollBar.max = container.height - _height;
		scrollBar.thumbSizeRatio = _height / container.height;
		scrollBar.validateNow();
		
		if (scrollBar.visible) {
			container.width = _width - scrollBar.width;
			scrollBar.x = _width - scrollBar.width;
        } else {
			container.width = _width;
        }
		
		container.y = -scrollBar.value;
		container.validateNow();
		validateItemRendererVisibility();
    }
	
	private function validateData() : Void
	{  
		// Remove all existing item renderers  
		for (itemRenderer in itemRenderers) {
			itemRenderer.dispose();
			container.removeChild(itemRenderer);
        }
		
		itemRenderers = new Array<PropertyInspectorItemRenderer>();
		
		if (_dataProvider == null) return  
		
		// Generate and sort an array of 'fields'. Each field will become the data provider for a single item renderer.  
		
		var fields : Array<Dynamic> = [];
		var fieldPropertiesByType : Dictionary = new Dictionary();
		
		for (i in 0..._dataProvider.length) {
			var newFields : Array<Dynamic> = _dataDescriptor.getFields(_dataProvider[i]);
			for (j in 0...newFields.length) {
				var newField : PropertyInspectorField = newFields[j];
				var newFieldHostType : Class<Dynamic> = getType(newField.hosts[0]);
				var existingFieldProperties : Dynamic = Reflect.field(fieldPropertiesByType, Std.string(newFieldHostType));
				
				if (existingFieldProperties == null) {
					existingFieldProperties = Reflect.setField(fieldPropertiesByType, Std.string(newFieldHostType), { });
                }
				
				var existingField : PropertyInspectorField = existingFieldProperties[newField.property];
				
				if (existingField != null) {
					existingField.hosts.push(newField.hosts[0]);
                } else {
					fields.push(newField);
					existingFieldProperties[newField.property] = newField;
					if (newField.category == null) {
						newField.category = getClassName(newFieldHostType);
                    }
                }
            }
        }
		
		fields.sortOn(["category", "priority", "property"]);  
		
		// Create new item renderers 
		
		var currentCategory : String;
		
		for (fields.length) {
			var field : PropertyInspectorField = fields[i];
			
			if (field.category != currentCategory) {
				currentCategory = field.category;
				itemRenderer = new PropertyInspectorItemRenderer();
				container.addChild(itemRenderer);
				var categoryField : PropertyInspectorField = new PropertyInspectorField();
				categoryField.label = currentCategory; 
				categoryField.isCategory = true;
				itemRenderer.data = categoryField;
				itemRenderers.push(itemRenderer);
            }
			
			field.editorDescriptor = editorDescriptorTable[field.editorID];
			
			if (field.editorDescriptor == null) {
				throw (new Error("No editor descriptor found for editorID : " + field.editorID));
				continue;
            }
			
			itemRenderer = new PropertyInspectorItemRenderer();
			container.addChild(itemRenderer);
			itemRenderer.data = field;
			itemRenderers.push(itemRenderer);
			itemRenderer.addEventListener(ItemEditorEvent.CHANGE, onChangeValue);
			itemRenderer.addEventListener(ItemEditorEvent.COMMIT_VALUE, onCommitValue);
        }
    }
	
	private function getClassName(object : Dynamic) : String
	{
		var classPath : String = flash.utils.getQualifiedClassName(object).replace("::", ".");
		if (classPath.indexOf(".") == -1) return classPath; 
		var split : Array<Dynamic> = classPath.split("."); 
		return split[split.length - 1];
    }
	
	private function getClassPath(object : Dynamic) : String
	{
		return flash.utils.getQualifiedClassName(object).replace("::", ".");
    }
	
	private function getType(object : Dynamic) : Class<Dynamic>
	{
		var classPath : String = getClassPath(object);
		return cast((flash.utils.getDefinitionByName(classPath)), Class);
    }
	
	private function validateItemRendererVisibility() : Void
	{
		var visibleTop : Int = -container.y;
		var visibleBottom : Int = visibleTop + _height;
		for (itemRenderer in itemRenderers) {
			if (itemRenderer.y + itemRenderer.height >= visibleTop && itemRenderer.y <= visibleBottom) {
				itemRenderer.enable();
            } else {
				itemRenderer.disable();
            }
        }
    }  
	
	////////////////////////////////////////////////    
	// Handlers    
	////////////////////////////////////////////////  
	
	private function onChangeValue(event : ItemEditorEvent) : Void
	{
    }
	
	private function onCommitValue(event : ItemEditorEvent) : Void
	{
		var itemRenderer : PropertyInspectorItemRenderer = cast((event.target), PropertyInspectorItemRenderer);
		dispatchEvent(new PropertyInspectorEvent(PropertyInspectorEvent.COMMIT_VALUE, itemRenderer.data.hosts, event.property, itemRenderer.data.storedValues, event.value));
    }
	
	private function changeDataProviderHandler(event : ArrayCollectionEvent) : Void
	{
		dataIsInvalid = true;
		invalidate();
    }
	
	private function onMouseWheel(event : MouseEvent) : Void
	{
		scrollBar.value += scrollBar.scrollSpeed * (event.delta < (0) ? 1 : -1);
    }
	
	private function changeScrollBarHandler(event : Event) : Void
	{
		container.y = -scrollBar.value;validateItemRendererVisibility();
    }  
	
	////////////////////////////////////////////////    
	// Getters/Setters    
	////////////////////////////////////////////////  
	
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
		container.padding = value;
		invalidate();
        return value;
    }
	
	private function get_Padding() : Int
	{
		return container.padding;
    }
}

class EditorDescriptor
{
	public var id : String;
	public var type : Class<Dynamic>;
	public var valueField : String;
	public var itemsField : String;
	public var itemsPropertyField : String;
	public var autoCommitValue : Bool;
	public var changeEventType : String;
	public var commitEventType : String;
	
	@:allow(core.ui.components)
    private function new(id : String, type : Class<Dynamic>, valueField : String, itemsField : String = null, itemsPropertyField : String = null, autoCommitValue : Bool = true, changeEventType : String = "change", commitEventType : String = "commitValue")
    {
		this.id = id;
		this.type = type;
		this.valueField = valueField;
		this.itemsField = itemsField;
		this.itemsPropertyField = itemsPropertyField;
		this.autoCommitValue = autoCommitValue;
		this.changeEventType = changeEventType;
		this.commitEventType = commitEventType;
    }
}