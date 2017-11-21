package com.traffic.util.debugging {
    import com.adobe.cairngorm.contract.Contract;

    import mx.utils.StringUtil;

    public class StackTraceProcessor
    {
        /**
         * E.g.:
         Error
         at Function/flashx.textLayout.container:ContainerController/http://ns.adobe.com/textLayout/internal/2008::setRootElement/flashx.textLayout.container:innerFunctionOfSetRootElement()[C:\Users\evolverine\Adobe Flash Builder 4.7\TFC-10695\src\flashx\textLayout\container\ContainerController.as:501]
         at flashx.textLayout.container::ContainerController/http://ns.adobe.com/textLayout/internal/2008::setRootElement()[C:\Users\evolverine\Adobe Flash Builder 4.7\TFC-10695\src\flashx\textLayout\container\ContainerController.as:512]
         at flashx.textLayout.compose::StandardFlowComposer/http://ns.adobe.com/textLayout/internal/2008::attachAllContainers()[/Users/aharui/git/flex/master/flex-tlf/textLayout/src/flashx/textLayout/compose/StandardFlowComposer.as:208]
         at flashx.textLayout.compose::StandardFlowComposer/addController()[/Users/aharui/git/flex/master/flex-tlf/textLayout/src/flashx/textLayout/compose/StandardFlowComposer.as:265]
         at flashx.textLayout.container::TextContainerManager/http://ns.adobe.com/textLayout/internal/2008::convertToTextFlowWithComposer()[/Users/aharui/git/flex/master/flex-tlf/textLayout/src/flashx/textLayout/container/TextContainerManager.as:1663]
         at spark.components::RichEditableText/updateDisplayList()[/Users/aharui/release4.13.0/frameworks/projects/spark/src/spark/components/RichEditableText.as:2948]
         at mx.core::UIComponent/validateDisplayList()[/Users/aharui/release4.13.0/frameworks/projects/framework/src/mx/core/UIComponent.as:9531]
         at DeleteTextMemento()[/Users/aharui/git/flex/master/flex-tlf/textLayout/src/flashx/textLayout/edit/ModelEdit.as:255]
         at mx.managers::LayoutManager/validateDisplayList()[/Users/aharui/release4.13.0/frameworks/projects/framework/src/mx/managers/LayoutManager.as:744]
         at mx.managers::LayoutManager/doPhasedInstantiation()[/Users/aharui/release4.13.0/frameworks/projects/framework/src/mx/managers/LayoutManager.as:809]
         at mx.managers::LayoutManager/doPhasedInstantiationCallback()[/Users/aharui/release4.13.0/frameworks/projects/framework/src/mx/managers/LayoutManager.as:1188]
         */
        public function getFunctionsFromStackTrace(stackTrace:String, abbreviateClassNames:Boolean = false, avoidClassNamesWhenIdentical:Boolean = true, excludeLastItemsNo:int = 1):Array
        {
            var previousClass:String = "";

            function adjustClassNameBasedOnUserSettings(className:String, abbreviateClassNames:Boolean, avoidClassNamesWhenIdentical:Boolean):String
            {
                function turnClassNameIntoAbbreviation(className:String):String
                {
                    return className.replace(/[a-z_]/g, "");
                }

                if (abbreviateClassNames)
                    className = turnClassNameIntoAbbreviation(className);

                if (avoidClassNamesWhenIdentical)
                {
                    var currentClass:String = className;
                    if (previousClass == currentClass)
                        className = "";

                    previousClass = currentClass;
                }
                return className;
            }

            function clearEmptyLinesAtBothEnds(lines:Array):void
            {
                if(lines.length)
                {
                    if(!StringUtil.trim(lines[0]))
                        lines.shift();
                    if(!StringUtil.trim(lines[lines.length - 1]))
                        lines.pop();
                }
            }

            function removeErrorName(stackLines:Array):void
            {
                //remove error info. E.g. "ReferenceError: Error #1069: Property mx_internal_uid not found on ... and there is no default value."
                stackLines.pop();
            }

            function stackTraceLineToClassDotFunction(item:*, index:int, array:Array):String
            {
                if(index >= array.length - excludeLastItemsNo)
                    return ""; //we don't print the last function (usually in this class), nor the caller (when it's centralized)

                var line:StackTraceLine = new StackTraceLine(item as String);
                return adjustClassNameBasedOnUserSettings(line.className, abbreviateClassNames, avoidClassNamesWhenIdentical) + "." + line.functionName;
            }

            function excludeEmptyLines(item:*, index:int, array:Array):Boolean
            {
                return (item as String).length > 0;
            }

            const lines:Array = stackTrace ? stackTrace.split("\n").reverse() : [];
            clearEmptyLinesAtBothEnds(lines);
            removeErrorName(lines);

            const functions:Array = lines.map(stackTraceLineToClassDotFunction).filter(excludeEmptyLines);
            Contract.postcondition(functions != null);
            return functions;
        }
    }
}

import com.traffic.util.debugging.StringUtils;

import mx.utils.StringUtil;

class StackTraceLine
{
    private static const INITIAL_AT_PREFIX:String = "at ";
    private static const FUNCTION_CLASS_PREFIX:String = "Function/";
    private static const FUNCTION_APPLY:String = "apply";
    private static const FUNCTION_CALL:String = "call";

    private var _originalLine:String;
    private var _packageClassAccessorFunction:String = "";
    private var _className:String;
    private var _functionName:String;
    private var _codeInfoWithoutFunctionEdgeCase:String;


    public function StackTraceLine(line:String)
    {
        _originalLine = line;
    }

    public function get className():String
    {
        if(!_className)
        {
            var packageClassSeparator:String = "::";

            if (isFunctionApplyOrCall)
            {
                _className = "Function";
            }
            else
            {
                if (isFunctionPrefixed)
                {
                    packageClassSeparator = ":";
                }

                const firstSlash:int = codeInfoWithoutFunctionEdgeCase.indexOf("/");
                const constructor:Boolean = firstSlash == -1;
                const classAndPackage:String = constructor ? codeInfoWithoutFunctionEdgeCase : codeInfoWithoutFunctionEdgeCase.substring(0, firstSlash);
                const classAndPackageSplit:Array = classAndPackage.split(packageClassSeparator);
                const defaultPackage:Boolean = classAndPackageSplit.length == 1;
                _className = defaultPackage ? classAndPackageSplit[0] : classAndPackageSplit[1];
            }
        }

        return _className;
    }

    public function get functionName():String
    {
        if(!_functionName)
        {
            if (isFunctionApplyOrCall)
            {
                _functionName = codeInfo.split("::").pop() as String;
            }
            else
            {
                const firstSlash:int = codeInfoWithoutFunctionEdgeCase.indexOf("/");
                const constructor:Boolean = firstSlash == -1;
                const accessorAndFunction:String = constructor ? "()" : codeInfoWithoutFunctionEdgeCase.substring(firstSlash + 1);
                const accessorAndFunctionSplit:Array = accessorAndFunction.split("::");
                _functionName = accessorAndFunctionSplit.length == 1 ? accessorAndFunctionSplit[0] : accessorAndFunctionSplit[1];

                //inner functions will have their parent function in the name, together with the package again, as such:
                //setRootElement/flashx.textLayout.container:innerFunctionOfSetRootElement()
                const locationOfColon:int = _functionName.indexOf(":");
                const innerFunctionPresent:Boolean = locationOfColon != -1;
                if (innerFunctionPresent)
                {
                    const firstFunctionSlash:int = _functionName.indexOf("/");
                    _functionName = _functionName.substring(0, firstFunctionSlash) + "." + _functionName.substr(locationOfColon + 1);
                }
            }
        }

        return _functionName;
    }

    //as opposed to the file info part of the stack trace line
    //eg. at flashx.textLayout.compose::StandardFlowComposer/http://ns.adobe.com/textLayout/internal/2008::attachAllContainers()[/Users/aharui/git/flex/master/flex-tlf/textLayout/src/flashx/textLayout/compose/StandardFlowComposer.as:208]
    public function get codeInfo():String
    {
        if(!_packageClassAccessorFunction)
        {
            //remove white space and the initial "at ", then split at "()", where the code info part ends and file info begins
            const functionAndDebugInfo:Array = StringUtils.trimSubstringLeft(StringUtil.trim(_originalLine), INITIAL_AT_PREFIX).split("()");
            _packageClassAccessorFunction = functionAndDebugInfo[0];
        }

        return _packageClassAccessorFunction;
    }

    public function get codeInfoWithoutFunctionEdgeCase():String
    {
        if(isFunctionPrefixed)
        {
            if (!_codeInfoWithoutFunctionEdgeCase)
            {
                _codeInfoWithoutFunctionEdgeCase = StringUtils.trimSubstringLeft(codeInfo, FUNCTION_CLASS_PREFIX);
            }

            return _codeInfoWithoutFunctionEdgeCase;
        }

        return codeInfo;
    }

    //eg. at Function/flashx.textLayout.container:ContainerController/http://ns.adobe.com/textLayout/internal/2008::setRootElement/flashx.textLayout.container:innerFunctionOfSetRootElement()[C:\Users\evolverine\Adobe Flash Builder 4.7\TFC-10695\src\flashx\textLayout\container\ContainerController.as:501]
    public function get isFunctionApplyOrCall():Boolean
    {
        //both inner functions and function.apply() start with "Function/".
        //When this happens for inner functions, simply remove this prefix
        const endsWithApplyOrCall:Boolean = StringUtils.endsWith(codeInfo, FUNCTION_APPLY) || StringUtils.endsWith(codeInfo, FUNCTION_CALL);
        return endsWithApplyOrCall && isFunctionPrefixed;
    }

    public function get isFunctionPrefixed():Boolean
    {
        return StringUtils.startsWith(codeInfo, FUNCTION_CLASS_PREFIX);
    }
}