package com.traffic.util.debugging
{
	import com.adobe.cairngorm.contract.Contract;
	import com.sohnar.traffic.util.StringUtils;
	import com.sohnar.traffic.util.array.ArrayUtils;
	
	import flash.utils.Dictionary;
	
	import mx.core.FlexGlobals;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	import mx.formatters.DateFormatter;
	import mx.managers.ISystemManager;
	import mx.utils.StringUtil;
	

	public class d
	{
		public static const PRINT_IMMEDIATELY:String = "printImmediately";
		public static const PRINT_ON_IDLE:String = "printOnIdle";
		public static const PRINT_MANUAL:String = "printWhenUserRequestsIt";
		
		private static const _dateFormatter:DateFormatter = new DateFormatter("NN:SS.QQQ");
		
		private static var _paths:Array = [];
		private static var _activityByPath:Dictionary = new Dictionary(false);
		private static var _streams:Array = [];
		
		private static var _abbreviateClassNames:Boolean = false;
		private static var _skipClassNamesWhenIdentical:Boolean = true;
		private static var _excludeLastItemsNo:int = 1;
		private static var _whenToPrint:String = PRINT_ON_IDLE;
		private static var _isDisabled:Boolean = false;
		
		public static function setUp(abbreviateClassNames:Boolean = false, skipClassNamesWhenIdentical:Boolean = true, excludeLastItemsNo:int = 1, whenToPrint:String = PRINT_ON_IDLE):void
		{
			_abbreviateClassNames = abbreviateClassNames;
			_skipClassNamesWhenIdentical = skipClassNamesWhenIdentical;
			_excludeLastItemsNo = excludeLastItemsNo;
			_whenToPrint = whenToPrint;
		}
		
		public static function debug(activity:String = "", stackTrace:String = "", printImmediately:Boolean = false):void
		{
			if(_isDisabled)
				return;

            if(!stackTrace)
                stackTrace = new Error().getStackTrace();

			var previousPaths:Array = _paths.length ? _paths[_paths.length - 1] : [];
			
			const stackFunctions:Array = getFunctionsFromStackTrace(stackTrace, _abbreviateClassNames, _skipClassNamesWhenIdentical, _excludeLastItemsNo);

            if(!activity)
                activity = stackFunctions[stackFunctions.length - 1];

			_paths.push(stackFunctions);
			_activityByPath[stackFunctions] = _dateFormatter.format(new Date()) + " " + activity;
			
			
			var previousFirstFunc:String = previousPaths.length ? previousPaths[0] : "";
			if(stackFunctions[0] != previousFirstFunc)
				_streams.push([]);

			_streams[_streams.length - 1].push(stackFunctions);

            if(printImmediately || _whenToPrint == PRINT_IMMEDIATELY)
                printActivityStreams();
			else if(_whenToPrint == PRINT_ON_IDLE)
				addIdleListeners();
		}
		
		public static function debugSimilar(activity:String, stackTrace:String = "", printImmediately:Boolean = false):void
		{
            if(!stackTrace)
                stackTrace = new Error().getStackTrace();

            var stackTraceFunctions:Array = getFunctionsFromStackTrace(stackTrace, _abbreviateClassNames, _skipClassNamesWhenIdentical, _excludeLastItemsNo);

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
		
		public static function clearActivities():void
		{
			_paths = [];
			_streams = [];
			_activityByPath = new Dictionary(false);
		}
		
		public static function printActivityStreams(thenClearActivities:Boolean = true):void
		{
			trace(getPrettyPrintedActivityStreams());
			
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
					streams += _activityByPath[currentStack];
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
		
		public static function prettyPrintPath(pathElements:Array, noTabs:int = 0):String
		{
			var path:String = StringUtils.repeatString("\t", noTabs);
			
			for(var j:int = 0; j < pathElements.length; j++)
			{
				path += "[" + pathElements[j] + "]" + (j == pathElements.length - 1 ? "" : " -> ");
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
			
			for (var i:int = 0; i < lines.length; i++)
			{
				if(i == lines.length - 1) //last line is not a function
					continue;
				
				if(i >= lines.length - (excludeLastItemsNo + 1))
					break; //we don't print the last function (usually in this class), nor the caller (when it's centralized)
				
				var functionAndFile:Array = lines[i].split("()");
				if(functionAndFile.length == 2)
				{
                    var functionInfo:String = functionAndFile[0];
                    var firstSlash:int = functionInfo.indexOf("/");

                    var classAndPackage:String = functionInfo.substring(0, firstSlash);
                    var classAndPackageSplit:Array = classAndPackage.split("::");
                    var className:String = classAndPackageSplit.length == 1 ? classAndPackageSplit[0] : classAndPackageSplit[1];

                    var accessorAndFunction:String = functionInfo.substring(firstSlash + 1);
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
			}
			
			Contract.postcondition(functions != null);
			return functions;
		}
		
		public static function turnClassNameIntoAbbreviation(className:String):String
		{
			return className.replace(/[a-z_]/g, "");
		}
	}
}