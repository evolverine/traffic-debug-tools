package com.sohnar.traffic.util.debugging
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
	

	public class ErrorUtils
	{
		public static const PRINT_IMMEDIATELY:String = "printImmediately";
		public static const PRINT_ON_IDLE:String = "printOnIdle";
		public static const PRINT_MANUAL:String = "printWhenUserRequestsIt";
		
		private static const _dateFormatter:DateFormatter = new DateFormatter("NN:SS.QQQ");
		
		private static var _paths:Array = [];
		private static var _activityByPath:Dictionary = new Dictionary(false);
		private static var _streams:Array = [];
		
		private static var _abbreviateClassNames:Boolean = false;
		private static var _skipClassNamesWhenIdentical:Boolean = true
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
		
		public static function debug(activity:String, stackTrace:String = "", printImmediately:Boolean = false):void
		{
			if(_isDisabled)
				return;
			
			var previousPaths:Array = _paths.length ? _paths[_paths.length - 1] : [];
			
			const stackFunctions:Array = getFunctionsFromStackTrace(stackTrace, _abbreviateClassNames, _skipClassNamesWhenIdentical, _excludeLastItemsNo);
			_paths.push(stackFunctions);
			_activityByPath[stackFunctions] = _dateFormatter.format(new Date()) + " " + activity;
			
			
			var previousFirstFunc:String = previousPaths.length ? previousPaths[0] : "";
			if(stackFunctions[0] != previousFirstFunc)
			{
				_streams.push([]);
			}
			_streams[_streams.length - 1].push(stackFunctions);

            if(printImmediately || _whenToPrint == PRINT_IMMEDIATELY)
                printActivityStreams();
			else if(_whenToPrint == PRINT_ON_IDLE)
				addIdleListeners();
		}
		
		public static function debugSimilar(activity:String, stackTrace:String = "", printImmediately:Boolean = false):void
		{
			if(isSameStackAndActivityAsLatestActivity(activity, getFunctionsFromStackTrace(stackTrace, _abbreviateClassNames, _skipClassNamesWhenIdentical, _excludeLastItemsNo)))
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
			const FUNCTIONS_PER_LINE:int = 5;
			var path:String = StringUtils.repeatString("\t", noTabs);
			
			for(var j:int = 0; j < pathElements.length; j++)
			{
				if(j != 0 && j % (FUNCTIONS_PER_LINE-1) == 0)
					path += "\n" + StringUtils.repeatString("\t", noTabs);
				path += "[" + pathElements[j] + "]" + (j == pathElements.length - 1 ? "" : " -> ");
			}
			
			return path;
		}
		
		/**
		 * E.g.:
		 * 
		 * ReferenceError: Error #1069: Property mx_internal_uid not found on com.sohnar.trafficlite.vos.TimesheetEmployeeEntryVO and there is no default value.
		 at mx.collections::HierarchicalCollectionViewCursor/findAny()[C:\Users\Developer1\workspace\RLTrafficMainApplication\src\as3\mx\collections\HierarchicalCollectionViewCursor.as:341]
		 at mx.collections::HierarchicalCollectionViewCursor/findFirst()[C:\Users\Developer1\workspace\RLTrafficMainApplication\src\as3\mx\collections\HierarchicalCollectionViewCursor.as:370]
		 at mx.collections::HierarchicalCollectionViewCursor/collectionChangeHandler()[C:\Users\Developer1\workspace\RLTrafficMainApplication\src\as3\mx\collections\HierarchicalCollectionViewCursor.as:1339]
		 at flash.events::EventDispatcher/dispatchEventFunction()
		 at flash.events::EventDispatcher/dispatchEvent()
		 at mx.collections::HierarchicalCollectionView/internalRefresh()[/Users/justinmclean/Documents/ApacheFlex4.11.0/frameworks/projects/advancedgrids/src/mx/collections/HierarchicalCollectionView.as:1256]
		 at mx.collections::HierarchicalCollectionView/refresh()[/Users/justinmclean/Documents/ApacheFlex4.11.0/frameworks/projects/advancedgrids/src/mx/collections/HierarchicalCollectionView.as:483]
		 at mx.controls::AdvancedDataGridBaseEx/sortHandler()[C:\Users\Developer1\workspace\RLTrafficMainApplication\src\as3\mx\controls\AdvancedDataGridBaseEx.as:8204]
		 at mx.controls::AdvancedDataGrid/sortHandler()[/Users/justinmclean/Documents/ApacheFlex4.11.0/frameworks/projects/advancedgrids/src/mx/controls/AdvancedDataGrid.as:8646]
		 at flash.events::EventDispatcher/dispatchEventFunction()
		 at flash.events::EventDispatcher/dispatchEvent()
		 at mx.core::UIComponent/dispatchEvent()[/Users/justinmclean/Documents/ApacheFlex4.11.0/frameworks/projects/framework/src/mx/core/UIComponent.as:13413]
		 at mx.controls::AdvancedDataGrid/headerReleaseHandler()[/Users/justinmclean/Documents/ApacheFlex4.11.0/frameworks/projects/advancedgrids/src/mx/controls/AdvancedDataGrid.as:8691]
		 at flash.events::EventDispatcher/dispatchEventFunction()
		 at flash.events::EventDispatcher/dispatchEvent()
		 at mx.core::UIComponent/dispatchEvent()[/Users/justinmclean/Documents/ApacheFlex4.11.0/frameworks/projects/framework/src/mx/core/UIComponent.as:13413]
		 at mx.controls::AdvancedDataGridBaseEx/mouseUpHandler()[C:\Users\Developer1\workspace\RLTrafficMainApplication\src\as3\mx\controls\AdvancedDataGridBaseEx.as:7325]
		 at mx.controls::AdvancedDataGrid/mouseUpHandler()[/Users/justinmclean/Documents/ApacheFlex4.11.0/frameworks/projects/advancedgrids/src/mx/controls/AdvancedDataGrid.as:8734]
		 * 
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
				
				var packageAndFunction:Array = lines[i].split("::");
				if(packageAndFunction.length == 2)
				{
					var classAndFunctionInfo:String = packageAndFunction[1];
					var classAndFunction:String = classAndFunctionInfo.substring(0, classAndFunctionInfo.indexOf("()")).replace("/", ".");
					
					if(abbreviateClassNames)
					{
						var positionOfDot:int = classAndFunction.indexOf(".");
						classAndFunction = turnClassNameIntoAbbreviation(classAndFunction.substring(0, positionOfDot)) + classAndFunction.substr(positionOfDot);
					}
					
					if(avoidClassNamesWhenIdentical)
					{
						positionOfDot = classAndFunction.indexOf(".");
						
						var currentClass:String = classAndFunction.substring(0, positionOfDot);
						if(previousClass == currentClass)
							classAndFunction = classAndFunction.substr(positionOfDot);
						
						previousClass = currentClass;
					}
					
					functions.push(classAndFunction);
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