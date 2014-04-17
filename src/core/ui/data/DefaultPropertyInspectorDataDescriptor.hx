package core.ui.data;

import core.ui.data.IPropertyInspectorDataDescriptor;
import core.ui.data.PropertyInspectorField;
import nme.utils.Proxy;import nme.utils.DescribeType;import core.data.ArrayCollection;class DefaultPropertyInspectorDataDescriptor implements IPropertyInspectorDataDescriptor
{public function new()
    {
    }public function getFields(object : Dynamic) : Array<Dynamic>{var description : FastXML = describeType(object);var fields : Array<Dynamic> = [];for (node/* AS3HX WARNING could not determine type for var: node exp: ECall(EField(EIdent(description),children),[]) type: null */ in description.nodes.children()){if (node.name() != "accessor" && node.name() != "variable")                 continue;var metadata : FastXML = FastXML.filterNodes(node.metadata, function(x:FastXML) {
                if(x.att.name == "Inspectable")
                    return true;
                return false;

            }).get(0);if (metadata == null)                 continue;var field : PropertyInspectorField = new PropertyInspectorField();field.category = getClassName(object);field.property = Std.string(node.att.name);field.hosts = [object];  // If the property is an inspectable list, then populate the fields with the children of that list too.  if (Std.is(object[field.property], Proxy)) {var children : Dynamic = cast((object[field.property]), Proxy);for (children.length){var child : Dynamic = children[i];var childFields : Array<Dynamic> = getFields(child);childFields = childFields.sortOn("property");fields = fields.concat(childFields);
                }
            }
            else {  // Parse each metadata argument into the field  for (i in 0...metadata.nodes.arg.length()){var argNode : FastXML = metadata.nodes.arg.get(i);var key : String = Std.string(argNode.att.key);var value : String = Std.string(argNode.att.value);  // 'editorType' is special, and is id for mapping a property to an editor  if (key == "editor") {field.editorID = value;
                    }
                    else if (key == "label") {field.label = value;
                    }
                    else if (key == "category") {field.category = value;
                    }
                    else if (key == "priority") {field.priority = as3hx.Compat.parseInt(value);
                    }
                    // Everything else gets parsed into the editorParameters object. These
                    // values then get passed to the editor when created.
                    else {if (value == "true") {field.editorParameters[key] = true;
                        }
                        else if (value == "false") {field.editorParameters[key] = false;
                        }
                        else if (Math.isNaN(Std.parseFloat(value)) == false) {field.editorParameters[key] = Std.parseFloat(value);
                        }
                        else if (value.charAt(0) == "[" && value.charAt(value.length - 1) == "]") {value = value.substr(1, value.length - 2);field.editorParameters[key] = new ArrayCollection(value.split(","));
                        }
                        else {field.editorParameters[key] = value;
                        }
                    }
                }if (field.editorID == null || field.editorID == "") {var value2 : Dynamic = object[field.property];if (Std.is(value2, Float)) {field.editorID = "NumberInput";
                    }
                    else if (Std.is(value2, Bool)) {field.editorID = "CheckBox";
                    }
                    else {field.editorID = "TextInput";
                    }
                }fields.push(field);
            }
        }return fields;
    }private static function getClassName(object : Dynamic) : String{var classPath : String = flash.utils.getQualifiedClassName(object).replace("::", ".");if (classPath.indexOf(".") == -1)             return classPath;var split : Array<Dynamic> = classPath.split(".");return split[split.length - 1];
    }
}