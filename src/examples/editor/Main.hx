/**
 * FloxEditor.as
 *
 * This example provides a simple text input field where you can type Flux XML, 
 * and on the right the view will update instantly to show you the result of
 * deserializing that XML.
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

package examples.editor; 

import core.ui.components.Application;
import core.ui.components.Container;
import core.ui.components.TextArea;
import core.ui.components.TextInput;
import flash.errors.Error;
import flash.events.Event;

@:meta(SWF(width="800",height="600",backgroundColor="0x101010",frameRate="60"))
class Main extends Application
{
	private var textInput : TextInput;
	private var output : Container;
	private var errorOutput : TextArea;
	
	public function new()
    {
        super();
    }
	
	override private function init() : Void
	{
		super.init();
		layout = new HorizontalLayout();
		var vBox : VBox = new VBox();
		vBox.percentWidth = 100;
		vBox.percentHeight = 100;
		addChild(vBox);
		textInput = new TextInput();
		textInput.editable = true;
		textInput.multiline = true;
		textInput.percentWidth = 100;
		textInput.percentHeight = 100;
		textInput.addEventListener(Event.CHANGE, changeTextHandler);
		textInput.fontFamily = "_typewriter";
		textInput.embedFonts = false;
		textInput.fontSize = 11;
		vBox.addChild(textInput);
		errorOutput = new TextArea();
		errorOutput.percentWidth = 100;
		errorOutput.height = 100;
		vBox.addChild(errorOutput);
		output = new Container();
		output.percentWidth = 100;
		output.percentHeight = 100;
		addChild(output);
		var exampleXML : FastXML = FastXML.parse("<VBox width=\"100%\" height=\"100%\">
				<Button label=\"Button A\" />
				<Button label=\"Button B\" toggle=\"true\" />
				<Button label=\"Button C\" selected=\"true\" />
			</VBox>");
		textInput.text = exampleXML.node.toXMLString.innerData();
		textInput.dispatchEvent(new Event(Event.CHANGE));
    }
	
	private function changeTextHandler(event : Event) : Void
	{
		errorOutput.text = "";
		try {
			var xml : FastXML = cast((textInput.text), XML);
			var component : UIComponent = FloxDeserializer.deserialize(xml);
			while (output.numChildren > 0) {
				output.removeChildAt(0);
            }
			output.addChild(component);
        } catch (e : Error) {
			errorOutput.text = e.message;
			if (textInput.text == "") {
				while (output.numChildren > 0) {
					output.removeChildAt(0);
                }
            }
        }
    }
}