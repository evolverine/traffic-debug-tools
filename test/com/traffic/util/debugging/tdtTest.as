package com.traffic.util.debugging
{
    import flash.events.Event;

    import mx.logging.Log;

    import org.flexunit.assertThat;

    import org.flexunit.asserts.assertEquals;
    import org.flexunit.asserts.assertFalse;
    import org.flexunit.asserts.assertNotNull;
    import org.flexunit.asserts.assertTrue;

	public class tdtTest
	{
		[Test]
		public function test_getFunctionsFromStackTrace_with_simple_stack_trace():void
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
			
			//when
			var stackFunctions:Array = tdt.getFunctionsFromStackTrace(testStack, true, true, 1);
			
			//then
			assertTrue(arraysEqual(stackFunctions, expected));
		}

        [Test]
        public function test_getFunctionsFromStackTrace_with_complex_stack_trace():void
        {
            //given
            const testUnrealisticButComplexStack:String = ( <![CDATA[
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
        ]]> ).toString();

            const expected:Array = [
                "LM.doPhasedInstantiationCallback",
                ".doPhasedInstantiation",
                ".validateDisplayList",
                "DTM.()",
                "UIC.validateDisplayList",
                "RET.updateDisplayList",
                "TCM.convertToTextFlowWithComposer",
                "SFC.addController",
                ".attachAllContainers",
                "CC.setRootElement"
            ];

            //when
            var stackFunctions:Array = tdt.getFunctionsFromStackTrace(testUnrealisticButComplexStack, true, true, 0);

            //then
            assertTrue(arraysEqual(stackFunctions, expected));
        }

        [Test]
        public function test_unique_instance_tracking():void
        {
            //given
            const obj1:Object = {};
            const obj2:Object = {};

            //when
            var idObj1:String = tdt.getId(obj1);
            var idObj2:String = tdt.getId(obj2);

            //then
            assertFalse(idObj1 == idObj2);
            assertEquals(idObj1, tdt.getId(obj1));
        }

        [Test]
        public function test_event_dispatching():void
        {
            //given
            var eventDispatched:Boolean = false;

            const eventListener:Function = function(event:Event):void {
                eventDispatched = true;
            };

            //when
            tdt.addEventListener(Event.ACTIVATE, eventListener);
            tdt.dispatchEvent(new Event(Event.ACTIVATE));

            //then
            assertThat(eventDispatched);

            //when 2
            eventDispatched = false;
            tdt.removeEventListener(Event.ACTIVATE, eventListener);
            tdt.dispatchEvent(new Event(Event.ACTIVATE));

            //then 2
            assertFalse(eventDispatched);
        }

        [Test]
        public function test_log_output_includes_activity():void
        {
            //given
            var logTarget:StringLogTarget = new StringLogTarget();
            Log.addTarget(logTarget);
            const activity:String = "hello world!";

            //when
            tdt.setUp(false, true, tdt.PRINT_IMMEDIATELY);
            tdt.debug(activity);

            //then
            assertThat(logTarget.log.indexOf(activity) != -1);
        }

        [Test]
        public function test_log_output_includes_stack_functions_in_correct_order():void
        {
            //given
            var logTarget:StringLogTarget = new StringLogTarget();
            Log.addTarget(logTarget);
            const activity:String = "hello world!";

            var stackFunctions:Array = tdt.getFunctionsFromStackTrace(new Error().getStackTrace(), false, true, 0);

            //when
            tdt.setUp(false, true, tdt.PRINT_IMMEDIATELY);
            tdt.debug(activity);

            //then
            var logCopy:String = logTarget.log;
            for(var i:int = 0; i < stackFunctions.length; i++)
            {
                var stackFunction:String = stackFunctions[i];
                var positionOfFunctionInTrace:int = logCopy.indexOf(stackFunction);
                assertThat(positionOfFunctionInTrace != -1);
                logCopy = logCopy.substr(positionOfFunctionInTrace + stackFunction.length);
            }
        }
		
		private static function arraysEqual(a1:Array, a2:Array):Boolean
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