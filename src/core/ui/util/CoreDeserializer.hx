  /**
 * CoreDeserializer.as
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
 */  package core.ui.util;

import core.ui.util.ILayout;
import core.ui.util.LayoutType;
import core.ui.util.UIComponent;
import nme.errors.Error;
import core.ui.components.*;import core.ui.layouts.*;class CoreDeserializer
{public static function deserialize(xml : FastXML, topLevel : UIComponent = null, searchPackages : Array<Dynamic> = null) : UIComponent{searchPackages = searchPackages == (null) ? [] : searchPackages;searchPackages = ["core.ui.components"].concat(searchPackages);return parseComp(xml, topLevel, null, topLevel, searchPackages);
    }private static function parseComp(xml : FastXML, topLevel : UIComponent, parent : UIComponent = null, instance : UIComponent = null, searchPackages : Array<Dynamic> = null) : UIComponent{if (instance == null) {var nodeName : String = xml.node.name.innerData();var type : Class<Dynamic>;for (j in 0...searchPackages.length){try{type = cast((Type.resolveClass(searchPackages[j] + "." + nodeName)), Class);
                }                catch (e : Error){ };if (type != null)                     break;
            }if (type == null) {throw (new Error("Cannot find type for node name : " + nodeName + ". After searching these packages : " + Std.string(searchPackages)));return null;
            }instance = Type.createInstance(type, []);
        }if (topLevel == null) {topLevel = instance;
        }parseAttributes(xml, instance, topLevel);if (parent != null && instance.stage == null) {parent.addChild(instance);
        }var childNodes : FastXMLList = xml.node.children.innerData();for (i in 0...childNodes.length()){var childNode : FastXML = childNodes.get(i);var childNodeName : String = childNode.node.name.innerData();if (instance.exists(childNodeName)) {var child : Dynamic = Reflect.field(instance, childNodeName);if (Std.is(child, ILayout)) {var layoutInstanceNode : FastXML = childNode.nodes.children()[0];var layoutType : Class<Dynamic> = cast((Type.resolveClass("core.ui.layouts." + layoutInstanceNode.node.name.innerData())), Class);var layoutInstance : ILayout = Type.createInstance(layoutType, []);parseAttributes(layoutInstanceNode, layoutInstance, topLevel);Reflect.setField(instance, childNodeName, layoutInstance);{i++;continue;
                    }
                }
                else if (Std.is(child, UIComponent)) {parseComp(childNode, topLevel, null, cast((child), UIComponent), searchPackages);{i++;continue;
                    }
                }
            }  // Assume it's a child component  parseComp(childNode, topLevel, instance, null, searchPackages);
        }return instance;
    }private static function parseAttributes(xml : FastXML, instance : Dynamic, topLevel : UIComponent) : Void{for (attribute/* AS3HX WARNING could not determine type for var: attribute exp: ECall(EField(EIdent(xml),attributes),[]) type: null */ in xml.nodes.attributes()){var prop : String = attribute.name();var value : String = Std.string(attribute);if (prop == "id") {if (topLevel.exists(value)) {Reflect.setField(topLevel, value, instance);
                }continue;
            }  // Handle special case of width="100%" syntax  if (prop == "width" || prop == "height") {if (value.charAt(value.length - 1) == "%") {instance[prop == ("width") ? "percentWidth" : "percentHeight"] = Std.parseFloat(value.substring(0, value.length - 1));
                }
                else {if (prop == "width")                         instance.percentWidth = NaN;if (prop == "height")                         instance.percentHeight = NaN;Reflect.setField(instance, prop, Std.parseFloat(value));
                }
            }
            else if (Std.is(Reflect.field(instance, prop), Bool)) {Reflect.setField(instance, prop, value == "true");
            }
            else if (Std.is(Reflect.field(instance, prop), Float)) {Reflect.setField(instance, prop, Std.parseFloat(value));
            }
            else {try{var definition : Class<Dynamic> = Type.getClass(Type.resolveClass(value));Reflect.setField(instance, prop, definition);
                }                catch (e : Error){Reflect.setField(instance, prop, value);
                }
            }
        }
    }

    public function new()
    {
    }
    private static var init = {
        CheckBox;
        ColorPicker;
        DropDownMenu;
        HBox;
        HorizontalLayout;
        HRule;
        Label;
        NumericStepper;
        MenuBar;
        Panel;
        CollapsiblePanel;
        ProgressBar;
        PropertyInspector;
        RadioButton;
        RadioButtonGroup;
        ScrollPane;
        HSlider;
        TabNavigator;
        TextArea;
        TextInput;
        Tree;
        VBox;
        VDividedBox;
        VerticalLayout;
        VRule;
    }

}