package com.traffic.util.debugging
{
	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertTrue;

	public class tdtTest
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
                "ADG.mouseUpHandler",
                "ADGBE.mouseUpHandler",
                "UIC.dispatchEvent",
                "ED.dispatchEvent",
                ".dispatchEventFunction",
                "HCVC.collectionChangeHandler",
                ".findFirst",
				];
			
			//when
			var stackFunctions:Array = tdt.getFunctionsFromStackTrace(testStack, true, true, 1);
			
			//then
			trace(stackFunctions);
			assertTrue(arraysEqual(stackFunctions, expected));
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