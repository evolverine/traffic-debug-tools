package com.sohnar.traffic.util.debugging
{
	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertTrue;

	public class ErrorUtilsTest
	{
		[Test]
		public function test_getFunctionsFromStackTrace():void
		{
			//given
			const testStack:String = ( <![CDATA[
			ReferenceError: Error #1069: Property mx_internal_uid not found on com.sohnar.trafficlite.vos.TimesheetEmployeeEntryVO and there is no default value.
		 at mx.collections::HierarchicalCollectionViewCursor/findAny()[C:\Users\Developer1\workspace\RLTrafficMainApplication\src\as3\mx\collections\HierarchicalCollectionViewCursor.as:341]
		 at mx.collections::HierarchicalCollectionViewCursor/findFirst()[C:\Users\Developer1\workspace\RLTrafficMainApplication\src\as3\mx\collections\HierarchicalCollectionViewCursor.as:370]
		 at mx.collections::HierarchicalCollectionViewCursor/collectionChangeHandler()[C:\Users\Developer1\workspace\RLTrafficMainApplication\src\as3\mx\collections\HierarchicalCollectionViewCursor.as:1339]
		 at flash.events::EventDispatcher/dispatchEventFunction()
		 at flash.events::EventDispatcher/dispatchEvent()
		 at mx.core::UIComponent/dispatchEvent()[/Users/justinmclean/Documents/ApacheFlex4.11.0/frameworks/projects/framework/src/mx/core/UIComponent.as:13413]
		 at mx.controls::AdvancedDataGridBaseEx/mouseUpHandler()[C:\Users\Developer1\workspace\RLTrafficMainApplication\src\as3\mx\controls\AdvancedDataGridBaseEx.as:7325]
		 at mx.controls::AdvancedDataGrid/mouseUpHandler()[/Users/justinmclean/Documents/ApacheFlex4.11.0/frameworks/projects/advancedgrids/src/mx/controls/AdvancedDataGrid.as:8734]
			]]> ).toString();
			
			const expected:Array = [
				".findFirst",
				"HCVC.collectionChangeHandler",
				".dispatchEventFunction",
				"ED.dispatchEvent",
				"UIC.dispatchEvent",
				"ADGBE.mouseUpHandler",
				"ADG.mouseUpHandler",
				];
			
			//when
			var stackFunctions:Array = ErrorUtils.getFunctionsFromStackTrace(testStack, true, true, 1);
			
			//then
			trace(stackFunctions);
			assertTrue(arraysEqual(stackFunctions, expected));
		}
		
		[Test]
		public function test_prettyPrint():void
		{
			//given
			const testStack:String = ( <![CDATA[
			ReferenceError: Error #1069: Property mx_internal_uid not found on com.sohnar.trafficlite.vos.TimesheetEmployeeEntryVO and there is no default value.
		 at mx.collections::HierarchicalCollectionViewCursor/findAny()[C:\Users\Developer1\workspace\RLTrafficMainApplication\src\as3\mx\collections\HierarchicalCollectionViewCursor.as:341]
		 at mx.collections::HierarchicalCollectionViewCursor/findFirst()[C:\Users\Developer1\workspace\RLTrafficMainApplication\src\as3\mx\collections\HierarchicalCollectionViewCursor.as:370]
		 at mx.collections::HierarchicalCollectionViewCursor/collectionChangeHandler()[C:\Users\Developer1\workspace\RLTrafficMainApplication\src\as3\mx\collections\HierarchicalCollectionViewCursor.as:1339]
		 at flash.events::EventDispatcher/dispatchEventFunction()
		 at flash.events::EventDispatcher/dispatchEvent()
		 at mx.core::UIComponent/dispatchEvent()[/Users/justinmclean/Documents/ApacheFlex4.11.0/frameworks/projects/framework/src/mx/core/UIComponent.as:13413]
		 at mx.controls::AdvancedDataGridBaseEx/mouseUpHandler()[C:\Users\Developer1\workspace\RLTrafficMainApplication\src\as3\mx\controls\AdvancedDataGridBaseEx.as:7325]
		 at mx.controls::AdvancedDataGrid/mouseUpHandler()[/Users/justinmclean/Documents/ApacheFlex4.11.0/frameworks/projects/advancedgrids/src/mx/controls/AdvancedDataGrid.as:8734]
			]]> ).toString();
			
			const expected:Array = [
				"ADG.mouseUpHandler",
				"ADGBE.mouseUpHandler",
				"UIC.dispatchEvent",
				"ED.dispatchEvent",
				".dispatchEventFunction",
				"HCVC.collectionChangeHandler",
				".findFirst"
				];
			
			const ACTIVITY1:String = "activity1";
			const ACTIVITY2:String = "activity2";
			ErrorUtils.setUp(true, true, 1, ErrorUtils.PRINT_MANUAL);
			
			//when
			ErrorUtils.debug(ACTIVITY1, testStack, false);
			ErrorUtils.debug(ACTIVITY2, testStack, false);
			var prettyPrint:String = ErrorUtils.getPrettyPrintedActivityStreams();
			var prettyPrintLines:Array = prettyPrint.split("\n");
			
			//then
			trace(prettyPrint);
			assertEquals(3, prettyPrintLines.length);
			assertEquals(ACTIVITY2, prettyPrintLines[prettyPrintLines.length - 1]);
			assertEquals(ACTIVITY1, prettyPrintLines[prettyPrintLines.length - 2]);
		}
		
		private function arraysEqual(a1:Array, a2:Array):Boolean
		{
			if (a1.length != a2.length) 
				return false;
			
			for (var i:int=0; i < a1.length; i++) {
				if (a1[i] != a2[i])
				{
					trace(a1[i] + "!=" + a2[i] + "!");
					return false;
				}
			}
			return true;
		}
	}
}