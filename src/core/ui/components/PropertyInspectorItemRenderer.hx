package core.ui.components;

import core.ui.components.EditorType;
import core.ui.components.UIComponent;
import nme.errors.Error;
import nme.events.Event;
import nme.utils.ClearInterval;
import nme.utils.SetInterval;
import core.layout.TextAlign;
import core.ui.data.PropertyInspectorField;
import core.ui.events.ItemEditorEvent;

@:meta(Event(type="core.ui.events.ItemEditorEvent",name="commitValue"))
class PropertyInspectorItemRenderer extends UIComponent
{
    public var data(get, set) : PropertyInspectorField;
	private var _data : PropertyInspectorField;
	private var labelField : Label;
	private var editor : UIComponent;
	private var isEnabled : Bool;
	private var isEditing : Bool;
	private var interval : Int;
	private var hRuleTop : HRule;
	private var hRuleBottom : HRule;
	
	public function new()
    {
		super();
    }
	
	override private function init() : Void
	{
		percentWidth = 100;
		labelField = new Label();
		labelField.resizeToContentWidth = false;
		addChild(labelField);
    }
	
	override private function validate() : Void
	{
		if (_data != null && _data.isCategory) {
			height = 36;
			labelField.bold = true;
			labelField.x = 6;
			labelField.width = _width - 12;
			labelField.textAlign = TextAlign.LEFT; 
			
			if (hRuleTop == null) {
				hRuleTop = new HRule();
				addChildAt(hRuleTop, 0);
				hRuleBottom = new HRule();
				addChildAt(hRuleBottom, 0);
            }
			
			hRuleTop.visible = true;
			hRuleBottom.visible = true;
			hRuleTop.width = hRuleBottom.width = _width;
			hRuleTop.y = _height - hRuleTop.height;
			hRuleTop.validateNow();
			hRuleBottom.validateNow();
        } else {
			height = 28;
			labelField.bold = false;
			labelField.x = 6;
			labelField.width = 120;
			labelField.textAlign = TextAlign.RIGHT;
			
			if (hRuleTop != null) {
				hRuleTop.visible = false;
				hRuleBottom.visible = false;
            }
        }
		
		labelField.validateNow();
		labelField.y = (height - labelField.height) * 0.5;
		if (editor != null) {
			editor.x = labelField.x + labelField.width + 6;
			editor.y = (_height - editor.height) * 0.5;
			editor.width = _width - editor.x - 4;
			editor.validateNow();
        }
    }
	
	private function set_Data(value : PropertyInspectorField) : PropertyInspectorField
	{
		var wasEnabled : Bool = isEnabled;
		
		if (_data != null) {
			disable();
			if (editor != null) {
				removeChild(editor);
				editor = null;
            }
        }
		
		_data = value;
		
		if (_data != null) {
			labelField.text = _data.label || _data.property;
			
			if (_data.editorDescriptor) {
				createEditor();
            }
        }
		
		if (wasEnabled) {
			enable();
        }
		
		invalidate();
        return value;
    }
	
	private function get_Data() : PropertyInspectorField
	{
		return _data;
    }
	
	private function createEditor() : Void
	{
		var editorType : Class<Dynamic> = _data.editorDescriptor.type;
		editor = cast((Type.createInstance(editorType, [])), UIComponent);
		
		for (editorProperty in Reflect.fields(_data.editorParameters)) {
			if (editor.exists(editorProperty) == false) {
				throw (new Error("Cannot find property '" + editorProperty + "' on editor of type '" + _data.editorID));
				continue;
            }
			Reflect.setField(editor, editorProperty, _data.editorParameters[editorProperty]);
        }
		
		if (_data.editorDescriptor.itemsField) {
			editor[_data.editorDescriptor.itemsField] = _data.hosts;
        }
		
		if (_data.editorDescriptor.itemsPropertyField) {
			editor[_data.editorDescriptor.itemsPropertyField] = _data.property;
        }
		
		addChild(editor);updateEditorValueFromHosts();
    }
	
	public function dispose() : Void
	{
		disable();
    }
	
	public function enable() : Void
	{
		if (isEnabled) return;
		isEnabled = true;
		if (editor == null) return;
		
		if (_data.editorDescriptor.autoCommitValue) {
			editor.addEventListener(_data.editorDescriptor.changeEventType, onEditorChange);
			editor.addEventListener(_data.editorDescriptor.commitEventType, onEditorCommit);
			interval = flash.utils.setInterval(updateEditorValueFromHosts, 30);
        }
    }
	
	public function disable() : Void
	{
		if (!isEnabled) return;
		isEditing = false;
		isEnabled = false;
		if (editor == null) return;
		if (_data.editorDescriptor.autoCommitValue) {
			editor.removeEventListener(_data.editorDescriptor.changeEventType, onEditorChange);
			editor.removeEventListener(_data.editorDescriptor.commitEventType, onEditorCommit);
			flash.utils.clearInterval(interval);
        }
    }
	
	private function updateEditorValueFromHosts() : Void
	{  
		//if ( _data.editorDescriptor.autoCommitValue == false ) return;  
		var allMatch : Bool = true;
		
		for (i in 1..._data.hosts.length) {
			var prevHost : Dynamic = _data.hosts[i - 1];
			var host : Dynamic = _data.hosts[i];
			if (prevHost[_data.property] != host[_data.property]) {
				allMatch = false;
				break;
            }
        }
		
		if (allMatch) {
			editor[_data.editorDescriptor.valueField] = _data.hosts[0][_data.property];
        } else {
			editor[_data.editorDescriptor.valueField] = null;
        }
    }
	
	private function storeValuesIfNeeded() : Void
	{
		if (isEditing) return;
		isEditing = true;
		_data.storedValues = [];
		
		for (i in 0..._data.hosts.length) {
			_data.storedValues[i] = _data.hosts[i][_data.property];
        }
    }
	
	private function onEditorChange(event : Event) : Void
	{
		storeValuesIfNeeded();
		var value : Dynamic = editor[_data.editorDescriptor.valueField];
		if (_data.editorDescriptor.autoCommitValue) {
			for (host/* AS3HX WARNING could not determine type for var: host exp: EField(EIdent(_data),hosts) type: null */ in _data.hosts) {
				host[_data.property] = value;
            }
        }
		dispatchEvent(new ItemEditorEvent(ItemEditorEvent.CHANGE, value, _data.property));
    }
	
	private function onEditorCommit(event : Event) : Void
	{
		storeValuesIfNeeded();
		isEditing = false;
		var value : Dynamic = editor[_data.editorDescriptor.valueField];
		if (_data.editorDescriptor.autoCommitValue) {
			for (host/* AS3HX WARNING could not determine type for var: host exp: EField(EIdent(_data),hosts) type: null */ in _data.hosts) {
				host[_data.property] = value;
            }
        }
		dispatchEvent(new ItemEditorEvent(ItemEditorEvent.COMMIT_VALUE, value, _data.property));
    }
}