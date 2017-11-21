package com.traffic.util.debugging {
    import com.adobe.cairngorm.contract.Contract;

    import mx.utils.StringUtil;

    public class StackTraceProcessor
    {
        private static const FUNCTION_CLASS_PREFIX:String = "Function/";
        private static const FUNCTION_APPLY:String = "apply";
        private static const FUNCTION_CALL:String = "call";
        private static const INITIAL_AT_PREFIX:String = "at ";


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
                function getClassName(packageClassAccessorFunction:String):String
                {
                    var packageClassSeparator:String = "::";

                    //both inner functions and function.apply() start with "Function/".
                    //When this happens for inner functions, simply remove this prefix
                    const functionPrefix:Boolean = packageClassAccessorFunction.indexOf(FUNCTION_CLASS_PREFIX) == 0;
                    const applyOrCall:Boolean = StringUtils.endsWith(packageClassAccessorFunction, FUNCTION_APPLY) || StringUtils.endsWith(packageClassAccessorFunction, FUNCTION_CALL);
                    if (functionPrefix && applyOrCall)
                    {
                        return "Function";
                    }
                    else
                    {
                        if(functionPrefix)
                        {
                            packageClassAccessorFunction = StringUtils.trimSubstringLeft(packageClassAccessorFunction, FUNCTION_CLASS_PREFIX);
                            packageClassSeparator = ":";
                        }

                        const firstSlash:int = packageClassAccessorFunction.indexOf("/");
                        const constructor:Boolean = firstSlash == -1;
                        const classAndPackage:String = constructor ? packageClassAccessorFunction : packageClassAccessorFunction.substring(0, firstSlash);
                        const classAndPackageSplit:Array = classAndPackage.split(packageClassSeparator);
                        const defaultPackage:Boolean = classAndPackageSplit.length == 1;
                        return defaultPackage ? classAndPackageSplit[0] : classAndPackageSplit[1];
                    }
                }

                function getFunctionName(packageClassAccessorFunction:String):String
                {
                    var functionName:String = "";

                    //both inner functions and function.apply() start with "Function/".
                    //When this happens for inner functions, simply remove this prefix
                    const functionPrefix:Boolean = packageClassAccessorFunction.indexOf(FUNCTION_CLASS_PREFIX) == 0;
                    const applyOrCall:Boolean = StringUtils.endsWith(packageClassAccessorFunction, FUNCTION_APPLY) || StringUtils.endsWith(packageClassAccessorFunction, FUNCTION_CALL);
                    if (functionPrefix && applyOrCall)
                    {
                        functionName = packageClassAccessorFunction.split("::").pop() as String;
                    }
                    else
                    {
                        if(functionPrefix)
                        {
                            packageClassAccessorFunction = StringUtils.trimSubstringLeft(packageClassAccessorFunction, FUNCTION_CLASS_PREFIX);
                        }

                        const firstSlash:int = packageClassAccessorFunction.indexOf("/");
                        const constructor:Boolean = firstSlash == -1;
                        const accessorAndFunction:String = constructor ? "()" : packageClassAccessorFunction.substring(firstSlash + 1);
                        const accessorAndFunctionSplit:Array = accessorAndFunction.split("::");
                        functionName = accessorAndFunctionSplit.length == 1 ? accessorAndFunctionSplit[0] : accessorAndFunctionSplit[1];

                        //inner functions will have their parent function in the name, together with the package again, as such:
                        //setRootElement/flashx.textLayout.container:innerFunctionOfSetRootElement()
                        const locationOfColon:int = functionName.indexOf(":");
                        const innerFunctionPresent:Boolean = locationOfColon != -1;
                        if (innerFunctionPresent)
                        {
                            const firstFunctionSlash:int = functionName.indexOf("/");
                            functionName = functionName.substring(0, firstFunctionSlash) + "." + functionName.substr(locationOfColon + 1);
                        }
                    }

                    return functionName;
                }


                if(index >= array.length - excludeLastItemsNo)
                    return ""; //we don't print the last function (usually in this class), nor the caller (when it's centralized)

                //remove white space and initial "at "
                const currentLine:String = StringUtils.trimSubstringLeft(StringUtil.trim(item as String), INITIAL_AT_PREFIX);

                const functionAndDebugInfo:Array = currentLine.split("()");
                var packageClassAccessorFunction:String = functionAndDebugInfo[0];

                return adjustClassNameBasedOnUserSettings(getClassName(packageClassAccessorFunction), abbreviateClassNames, avoidClassNamesWhenIdentical) + "." + getFunctionName(packageClassAccessorFunction);
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
