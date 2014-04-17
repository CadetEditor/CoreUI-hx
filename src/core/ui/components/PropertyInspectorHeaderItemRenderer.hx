package core.ui.components;

import core.ui.components.UIComponent;
import core.ui.events.ItemEditorEvent;

class PropertyInspectorHeaderItemRenderer extends UIComponent
{
    public var data(get, set) : Dynamic;
	private var _data : Dynamic;
	private var labelField : Label;
	
	public function new()
    {
		super();
    }
	
	override private function init() : Void
	{
		percentWidth = 100;
		height = 26;
		labelField = new Label();
		addChild(labelField);
    }
	
	override private function validate() : Void
	{
		if (_data != null) {
			labelField.text = _data.label;
        }
		
		labelField.width = _width;
		labelField.y = (height - labelField.height) * 0.5;
		labelField.validateNow();
    }
	
	private function set_Data(value : Dynamic) : Dynamic
	{
		_data = value;
		invalidate();
        return value;
    }
	
	private function get_Data() : Dynamic
	{
		return _data;
    }
}