package com.traffic.util.debugging
{
    import avmplus.getQualifiedClassName;

    import com.adobe.cairngorm.contract.Contract;
    import com.traffic.util.trace.ObjectTracerCache;
    import com.traffic.util.trace.Tracer;

    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.utils.Dictionary;
    import flash.xml.XMLDocument;
    import flash.xml.XMLNode;

    import mx.core.FlexGlobals;
    import mx.core.UIComponent;
    import mx.events.FlexEvent;
    import mx.formatters.DateFormatter;
    import mx.logging.ILogger;
    import mx.logging.Log;
    import mx.logging.targets.TraceTarget;
    import mx.managers.ISystemManager;
    import mx.utils.StringUtil;

    public class tdt
	{
		public static const PRINT_IMMEDIATELY:String = "printImmediately";
		public static const PRINT_ON_IDLE:String = "printOnIdle";
		public static const PRINT_MANUAL:String = "printWhenUserRequestsIt";

		public static const FORMAT_XML:String = "format_XML";
		public static const FORMAT_STRING:String = "format_String";

        private static const _eventDispatcher:EventDispatcher = new EventDispatcher(null);
		private static const _allInstances:Array = [];

        private static const _instancesCounter:Array = [];
		private static const _dateFormatter:DateFormatter = new DateFormatter("NN:SS.QQQ");

        private static var _paths:Array = [];
		private static var _activityByPath:Dictionary = new Dictionary(false);
		private static var _streams:Array = [];
		private static var _abbreviateClassNames:Boolean = false;
		private static var _skipClassNamesWhenIdentical:Boolean = true;
		private static var _whenToPrint:String = PRINT_ON_IDLE;
		private static var _isDisabled:Boolean = false;
		private static var _logger:ILogger;
        private static var _tracer:Tracer = new Tracer(new ObjectTracerCache());
        private static var _printFormat:String = FORMAT_STRING;

		{
			_logger = Log.getLogger("traffic-debug-tools");
			Log.addTarget(new TraceTarget());
		}

		public static function setUp(abbreviateClassNames:Boolean = false, skipClassNamesWhenIdentical:Boolean = true, whenToPrint:String = PRINT_ON_IDLE, printFormat:String = FORMAT_STRING):void
		{
			_abbreviateClassNames = abbreviateClassNames;
			_skipClassNamesWhenIdentical = skipClassNamesWhenIdentical;
			_whenToPrint = whenToPrint;
			_printFormat = printFormat;
		}

		public static function debug(activity:String = "", stackTrace:String = "", printImmediately:Boolean = false):void
		{
			if(_isDisabled)
				return;

            if(!stackTrace)
                stackTrace = new Error().getStackTrace();

			var previousPaths:Array = _paths.length ? _paths[_paths.length - 1] : [];
			
			const stackFunctions:Array = getFunctionsFromStackTrace(stackTrace, _abbreviateClassNames, _skipClassNamesWhenIdentical);

            if(!activity)
                activity = stackFunctions[stackFunctions.length - 1] + "()";

			_paths.push(stackFunctions);
			_activityByPath[stackFunctions] = {time:_dateFormatter.format(new Date()), activity:activity};
			
			
			var previousFirstFunc:String = previousPaths.length ? previousPaths[0] : "";
			if(stackFunctions[0] != previousFirstFunc)
				_streams.push([]);

			_streams[_streams.length - 1].push(stackFunctions);

            if(printImmediately || _whenToPrint == PRINT_IMMEDIATELY)
                printActivityStreams();
			else if(_whenToPrint == PRINT_ON_IDLE)
				addIdleListeners();
		}
		
		public static function debugSimilar(activity:String = "", stackTrace:String = "", printImmediately:Boolean = false):void
		{
            if(!stackTrace)
                stackTrace = new Error().getStackTrace();

            var stackTraceFunctions:Array = getFunctionsFromStackTrace(stackTrace, _abbreviateClassNames, _skipClassNamesWhenIdentical);

            if(!activity)
                activity = stackTraceFunctions[stackTraceFunctions.length - 1];

			if(isSameStackAndActivityAsLatestActivity(activity, stackTraceFunctions))
			{
				if(_paths.length)
					_activityByPath[_paths[_paths.length - 1]] += "+";
				return;
			}
			
			debug(activity, stackTrace, printImmediately);
		}
		
		public static function enable():void
		{
			_isDisabled = false;
		}
		
		public static function disable():void
		{
			_isDisabled = true;
		}
		
		private static function isSameStackAndActivityAsLatestActivity(activity:String, stack:Array):Boolean
		{
			if(_paths.length)
				return isSameActivityAsRegisteredActivity(activity, _activityByPath[_paths[_paths.length - 1]]) && areStacksEqual(stack, _paths[_paths.length - 1]);
			
			return false;
		}
		
		private static function isSameActivityAsRegisteredActivity(unregisteredActivity:String, registeredActivity:String):Boolean
		{
			var positionOfFirstSpace:int = registeredActivity.indexOf(" ");
			return registeredActivity.indexOf(unregisteredActivity) == positionOfFirstSpace + 1;
		}
		
		private static function areStacksEqual(stackA:Array, stackB:Array):Boolean
		{
			Contract.precondition(stackA != null && stackB != null);
			return ArrayUtils.intersectionFromBeginning(stackA, stackB).length == stackA.length;
		}
		
		private static function addIdleListeners():void
		{
			if(systemManager)
				systemManager.addEventListener(FlexEvent.IDLE, onApplicationIdle);
		}
		
		private static function removeIdleListeners():void
		{
			if(systemManager)
				systemManager.removeEventListener(FlexEvent.IDLE, onApplicationIdle);
		}
		
		private static function onApplicationIdle(event:FlexEvent):void
		{
			if(_paths.length)
				printActivityStreams();
			else
				removeIdleListeners();
		}
		
		private static function get systemManager():ISystemManager
		{
			var app:UIComponent = FlexGlobals.topLevelApplication as UIComponent;
			return app ? app.systemManager : null;
		}
		
		private static function clearActivities():void
		{
			_paths = [];
			_streams = [];
			_activityByPath = new Dictionary(false);
		}
		
		public static function printActivityStreams(thenClearActivities:Boolean = true):void
		{
			_logger.debug(getPrettyPrintedActivityStreams());
			
			if(thenClearActivities)
				clearActivities();
		}
		
		
		/**
		 * E.g.
		 * 
		 *  ==================================
		 *	[LM.doPhasedInstantiationCallback] -> [.doPhasedInstantiation] ->
		 *  ==================================
		 *		-> [.validateSize]
		 *		:validateSize for important object A
		 *		-> [.validateDisplayList]
		 *		:validateDisplayList for important object B
		 *	:LM update complete
		 * 
		 */
		public static function getPrettyPrintedActivityStreams():String
		{
			if(_printFormat == FORMAT_STRING)
                return getActivityStreamsAsString();
            else if(_printFormat == FORMAT_XML)
                return getActivityStreamsAsXMLString();
            return "";
		}

        private static function getActivityStreamsAsXMLString():String
        {
            var streams:XMLDocument = new XMLDocument();
            var rootNode:XMLNode = new XMLNode(1, "debug");
            streams.appendChild(rootNode);

            var previousNode:XMLNode = rootNode;
            var previousPathVariation:String = "";

            for each(var stream:Array in _streams)
            {
                var headerPath:Array = getCommonPath(stream);
                var noHeaderFunctions:int = headerPath.length;

                var nodesForHeader:Object = createNestedNodes(headerPath, "call");
                previousNode.appendChild(nodesForHeader.parent);
                previousNode = nodesForHeader.lastChild;

                for each(var currentStack:Array in stream)
                {
                    var pathVariation:Array = currentStack.slice(noHeaderFunctions);
                    var pathVariationString:String = pathVariation.join();
                    var pathDifferentFromHeaderPath:Boolean = noHeaderFunctions < currentStack.length;

                    if (pathDifferentFromHeaderPath && pathVariation.join() != previousPathVariation)
                    {
                        var nodesForVariation:Object = createNestedNodes(pathVariation, "call");
                        previousNode.appendChild(nodesForVariation.parent);
                        previousNode = nodesForVariation.lastChild;
                    }

                    var activityNode:XMLNode = new XMLNode(1, "activity");
                    activityNode.attributes = {time: _activityByPath[currentStack].time};
                    activityNode.appendChild(new XMLNode(3, _activityByPath[currentStack].activity));
                    previousNode.appendChild(activityNode);

                    previousPathVariation = pathVariationString;
                }

                previousNode = rootNode;
            }

            return streams.toString();
        }

        private static function createNestedNodes(stringsArray:Array, nodesName:String):Object
        {
            var parentNode:XMLNode;
            var previousNode:XMLNode;
            for (var i:int = 0; i < stringsArray.length; i++)
            {
                var node:XMLNode = new XMLNode(1, nodesName);
                node.attributes = {name : stringsArray[i]};

                if(!parentNode)
                    parentNode = node;

                if(previousNode)
                    previousNode.appendChild(node);

                previousNode = node;
            }

            return {parent:parentNode, lastChild:previousNode};
        }

        private static function getActivityStreamsAsString():String
        {
            var streams:String = "";
            var previousPathVariation:String = "";

            for each(var stream:Array in _streams)
            {
                var headerPath:Array = getCommonPath(stream);
                if(headerPath && headerPath.length)
                {
                    streams += "\n==================================\n";
                    streams += prettyPrintPath(headerPath);
                    streams += "\n==================================\n";
                }

                for each(var currentStack:Array in stream)
                {
                    var pathVariation:Array = currentStack.slice(headerPath.length);
                    var pathVariationString:String = pathVariation.join();
                    var pathDifferentFromHeaderPath:Boolean = headerPath.length < currentStack.length;

                    if(pathDifferentFromHeaderPath && pathVariation.join() != previousPathVariation)
                        streams += "\n-> " + prettyPrintPath(pathVariation, 3) + "\n" + StringUtils.repeatString("\t", 2);
                    else if(streams)
                        streams += "\n\t";
                    streams += _activityByPath[currentStack].time + " " + _activityByPath[currentStack].activity;
                    if(streams)
                        streams += "\n";

                    previousPathVariation = pathVariationString;
                }

                if(streams)
                    streams += "\n";
            }

            return streams;
        }

		
		private static function getCommonPath(paths:Array):Array
		{
			if(!paths || !paths.length)
				return [];
			
			if(paths.length == 1)
				return paths[0].concat();
			
			var commonPath:Array = paths[0];
			var i:int = 0;
			while(++i < paths.length)
			{
				commonPath = ArrayUtils.intersectionFromBeginning(paths[i], commonPath);
			}
			
			return commonPath;
		}
		
		public static function prettyPrintPath(pathElements:Array, noTabs:int = 0, separator:String = " -> "):String
		{
			var path:String = StringUtils.repeatString("\t", noTabs);
			
			for(var j:int = 0; j < pathElements.length; j++)
			{
				path += "[" + pathElements[j] + "]" + (j == pathElements.length - 1 ? "" : separator);
			}
			
			return path;
		}
		
		/**
		 * E.g.:
         Error
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
		public static function getFunctionsFromStackTrace(stackTrace:String, abbreviateClassNames:Boolean = false, avoidClassNamesWhenIdentical:Boolean = true, excludeLastItemsNo:int = 1):Array
		{
			var functions:Array = [];
			var previousClass:String = "";
			var lines:Array = stackTrace ? stackTrace.split("\n").reverse() : [];
			
			if(lines.length)
			{
				if(!StringUtil.trim(lines[0]))
					lines.shift();
				if(!StringUtil.trim(lines[lines.length - 1]))
					lines.pop();
			}

            //remove error info. E.g. "ReferenceError: Error #1069: Property mx_internal_uid not found on ... and there is no default value."
            lines.pop();

			for (var i:int = 0; i < lines.length; i++)
			{
				if(i >= lines.length - excludeLastItemsNo)
					break; //we don't print the last function (usually in this class), nor the caller (when it's centralized)
				
				var functionAndDebugInfo:Array = lines[i].split("()");
                var packageClassAccessorFunction:String = functionAndDebugInfo[0];

                var firstSlash:int = packageClassAccessorFunction.indexOf("/");
                var constructor:Boolean = firstSlash == -1;
                var classAndPackage:String = constructor ? packageClassAccessorFunction : packageClassAccessorFunction.substring(0, firstSlash);
                var classAndPackageSplit:Array = classAndPackage.split("::");
                var defaultPackage:Boolean = classAndPackageSplit.length == 1;
                var className:String = defaultPackage ? classAndPackageSplit[0].substr(classAndPackageSplit[0].indexOf("at ") + 3) : classAndPackageSplit[1];

                var accessorAndFunction:String = constructor ? "()" : packageClassAccessorFunction.substring(firstSlash + 1);
                var accessorAndFunctionSplit:Array = accessorAndFunction.split("::");
                var functionName:String = accessorAndFunctionSplit.length == 1 ? accessorAndFunctionSplit[0] : accessorAndFunctionSplit[1];

                if(abbreviateClassNames)
                    className = turnClassNameIntoAbbreviation(className);

                if(avoidClassNamesWhenIdentical)
                {
                    var currentClass:String = className;
                    if(previousClass == currentClass)
                        className = "";

                    previousClass = currentClass;
                }

                functions.push(className + "." + functionName);
			}
			
			Contract.postcondition(functions != null);
			return functions;
		}

		public static function whereAmI(separator:String = " -> "):String
		{
			return prettyPrintPath(getFunctionsFromStackTrace(new Error().getStackTrace(), _abbreviateClassNames, _skipClassNamesWhenIdentical, 1), 0, separator);
		}


		public static function turnClassNameIntoAbbreviation(className:String):String
		{
			return className.replace(/[a-z_]/g, "");
		}

        public static function dispatchEvent(event:Event):void
        {
            _eventDispatcher.dispatchEvent(event);
        }

        public static function addEventListener(listenerType:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void
        {
            _eventDispatcher.addEventListener(listenerType, listener, useCapture, priority, useWeakReference);
        }

        public static function removeEventListener(listenerType:String, listener:Function, useCapture:Boolean = false):void
        {
            _eventDispatcher.removeEventListener(listenerType, listener, useCapture);
        }

        public static function traceObject(object:Object):String
        {
            return _tracer.trace(object);
        }

        /**
         * Note that the tracer class needs to implement IObjectTracer.
         * */
        public static function registerNewObjectTracer(classOfTracedObject:Class, tracer:Class):void
        {
            _tracer.register(classOfTracedObject, tracer);
        }

        public static function trackNewInstance(instance:Object, log:Boolean = false):String
        {
            var className:String = instance ? getQualifiedClassName(instance) : "Null";

            if(!_allInstances[className])
                trackNewClass(className);

            var instancesOfThisClass:Dictionary = _allInstances[className];
            if(!instancesOfThisClass[instance])
            {
                var classComponents:Array = className.split("::");
                instancesOfThisClass[instance] = classComponents[classComponents.length - 1] + "-" + _instancesCounter[className]++;

                if(log)
                    debug("New instance tracked as " + instancesOfThisClass[instance]);
            }

            return className;
        }

        public static function getId(instance:Object):String
        {
            if(!instance)
                return "Unknown";

            return _allInstances[trackNewInstance(instance)][instance];
        }

        private static function trackNewClass(className:String):void
        {
            _allInstances[className] = new Dictionary(false);
            _instancesCounter[className] = 0;
        }
	}
}