/**
 * Distributed under Apache License v2.0. For more information
 * see LICENSE.
 */

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
                className = abbreviateClassNames ? StringUtils.toAbbreviation(className) : className;

                if (avoidClassNamesWhenIdentical)
                {
                    var currentClass:String = className;
                    if (previousClass == currentClass)
                        className = "";

                    previousClass = currentClass;
                }

                return className;
            }

            function clearEmptyLinesAtBothEnds(lines:Array):Array
            {
                if(lines.length)
                {
                    if(!StringUtil.trim(lines[0]))
                        lines.shift();
                    if(!StringUtil.trim(lines[lines.length - 1]))
                        lines.pop();
                }

                return lines;
            }

            function removeErrorName(stackLines:Array):Array
            {
                //remove error info. E.g. "ReferenceError: Error #1069: Property mx_internal_uid not found on ... and there is no default value."
                stackLines.pop();
                return lines;
            }

            function stackTraceLineToClassDotFunction(item:*, index:int, array:Array):String
            {
                if(index >= array.length - excludeLastItemsNo)
                    return ""; //we don't print the last function (because it's usually in this class), nor the caller (when it's centralized)

                line.originalLine = item as String;
                return adjustClassNameBasedOnUserSettings(line.className, abbreviateClassNames, avoidClassNamesWhenIdentical) + "." + line.functionName;
            }

            var line:StackTraceLine = new StackTraceLine();
            const lines:Array = stackTrace ? stackTrace.split("\n").reverse() : [];
            const functions:Array = removeErrorName(clearEmptyLinesAtBothEnds(lines)).map(stackTraceLineToClassDotFunction).filter(ArrayUtils.excludeEmptyLines);

            Contract.postcondition(functions != null);
            return functions;
        }
    }
}

import com.traffic.util.debugging.ArrayUtils;
import com.traffic.util.debugging.StringUtils;

import mx.utils.StringUtil;

class StackTraceLine
{
    private static const INITIAL_AT_PREFIX:String = "at ";
    private static const FUNCTION_CLASS_PREFIX:String = "Function/";
    private static const FUNCTION_APPLY:String = "apply";
    private static const FUNCTION_CALL:String = "call";

    private var _originalLine:String;
    private var _codeInfo:String = "";
    private var _className:String;
    private var _functionName:String;
    private var _codeInfoWithoutFunctionEdgeCase:String;

    public function set originalLine(value:String):void
    {
        if(_originalLine != value)
        {
            _originalLine = value;
            reset();
        }
    }

    private function reset():void
    {
        _codeInfo = "";
        _codeInfoWithoutFunctionEdgeCase = "";
        _className = "";
        _functionName = "";
    }

    public function get className():String
    {
        //inner classes are represented like this:
        //StackTraceProcessor.as$41:StackTraceLine
        function parseInnerClassOrPackageAndClassName(innerClassOrPackageAndClass:String):String
        {
            const packageClassSeparator:String = isFunctionPrefixed ? ":" : "::";
            const locationOfSeparator:int = innerClassOrPackageAndClass.indexOf(packageClassSeparator);

            if(locationOfSeparator == -1)
            {
                return innerClassOrPackageAndClass;
            }
            else
            {
                const locationOfDollarSign:int = innerClassOrPackageAndClass.indexOf("$");
                const isInnerClass:Boolean = locationOfDollarSign != -1;
                const theClassName:String = innerClassOrPackageAndClass.substr(locationOfSeparator + packageClassSeparator.length);
                return isInnerClass ? stripCommonFileExtensions(innerClassOrPackageAndClass.substring(0, locationOfDollarSign) + "." + theClassName) : theClassName;
            }
        }

        if(!_className)
        {
            if (isFunctionApplyOrCall)
            {
                _className = "Function";
            }
            else
            {
                const firstSlash:int = codeInfoWithoutFunctionEdgeCase.indexOf("/");
                _className = parseInnerClassOrPackageAndClassName(codeInfoWithoutFunctionEdgeCase.substring(0, firstSlash != -1 ? firstSlash : 0x7fffffff));
            }
        }

        return _className;
    }

    private static function stripCommonFileExtensions(innerClassOrPackageAndClass:String):String
    {
        return innerClassOrPackageAndClass.replace(".as", "").replace(".mxml", "");
    }

    public function get functionName():String
    {
        function accessorAndFunctionToFunction(item:*, index:int, array:Array):String
        {
            const accessorAndFunction:String = item as String;
            const accessorInformationEndsAt:int = accessorAndFunction.indexOf(":");
            const isAccessorPresent:Boolean = accessorInformationEndsAt != -1;
            return isAccessorPresent ? accessorAndFunction.substr(accessorInformationEndsAt + 1) : accessorAndFunction;
        }

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
                const accessorClassAndFunctionSplit:Array = accessorAndFunction.split("::");
                var functionNames:String = accessorClassAndFunctionSplit.length == 1 ? accessorClassAndFunctionSplit[0] : accessorClassAndFunctionSplit[1];

                //inner functions will have their parent function(s) in the name, together with the package again, as such:
                //- setRootElement/flashx.textLayout.container:innerFunctionOfSetRootElement or
                //- com.traffic.util.debugging:tdtTest/test_location_tracing_with_arguments_in_inner_function_of_inner_function/com.traffic.util.debugging:locationTracingWithTwoArguments/com.traffic.util.debugging:sum
                _functionName = sanitizeGettersAndSetters(functionNames.split("/").map(accessorAndFunctionToFunction).filter(ArrayUtils.excludeEmptyLines)).join(".");
            }
        }

        return _functionName;
    }

    //getters and setters appear between /, which means they will be processed as separate functions
    //eg StackTraceProcessor.as$41:StackTraceLine/functionName/get/StackTraceProcessor.as$41:accessorAndFunctionToFunction()
    private function sanitizeGettersAndSetters(functionNames:Array):Array
    {
        function isAnythingButGetOrSet(item:*, index:int = -1, array:Array = null):Boolean
        {
            var str:String = item as String;
            return str != "get" && str != "set";
        }

        function moveGetAndSetKeywordsToPreviousItem(item:*, index:int, array:Array):String
        {
            var nextItem:String = index < array.length ? array[index+1] : null;
            return isAnythingButGetOrSet(nextItem) ? item : nextItem + " " + item;
        }

        return functionNames.map(moveGetAndSetKeywordsToPreviousItem).filter(isAnythingButGetOrSet);
    }

    //as opposed to the file info part of the stack trace line
    //eg. at flashx.textLayout.compose::StandardFlowComposer/http://ns.adobe.com/textLayout/internal/2008::attachAllContainers()[/Users/aharui/git/flex/master/flex-tlf/textLayout/src/flashx/textLayout/compose/StandardFlowComposer.as:208]
    public function get codeInfo():String
    {
        if(!_codeInfo)
        {
            //remove white space and the initial "at ", then split at "()", where the code info part ends and file info begins
            _codeInfo = StringUtils.trimSubstringLeft(StringUtil.trim(_originalLine), INITIAL_AT_PREFIX).split("()")[0];
        }

        return _codeInfo;
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