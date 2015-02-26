package com.traffic.util.debugging
{
    import flash.events.Event;

    import mx.logging.Log;

    import org.flexunit.assertThat;
    import org.flexunit.asserts.assertEquals;
    import org.flexunit.asserts.assertFalse;
    import org.flexunit.asserts.assertTrue;

    public class tdtTest
	{
		[Test]
		public function test_getFunctionsFromStackTrace_with_simple_stack_trace():void
		{
			//given
			const testStack:String = ( <![CDATA[
			ReferenceError: Error #1069: Property mx_internal_uid not found on com.... and there is no default value.
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
			assertTrue(arraysEqual(expected, stackFunctions));
		}

        [Test]
        public function test_getFunctionsFromStackTrace_with_complex_and_repetitive_stack_trace():void
        {
            //given
            const complexStackWithRepetitions:String = ( <![CDATA[
                    Error
            at com.traffic.util.debugging::tdtTest/test_log_output_includes_stack_functions_in_correct_order()[C:\Users\evolverine\Adobe Flash Builder 4.7\traffic-debug-tools\test\com\traffic\util\debugging\tdtTest.as:175]
            at Function/http://adobe.com/AS3/2006/builtin::apply()
            at flex.lang.reflect::Method/apply()[C:\Users\Developer1\workspace\flexunit\FlexUnit4\src\flex\lang\reflect\Method.as:244]
            at org.flexunit.runners.model::FrameworkMethod/invokeExplosively()[C:\Users\Developer1\workspace\flexunit\FlexUnit4\src\org\flexunit\runners\model\FrameworkMethod.as:201]
            at org.flexunit.internals.runners.statements::InvokeMethod/evaluate()[C:\Users\Developer1\workspace\flexunit\FlexUnit4\src\org\flexunit\internals\runners\statements\InvokeMethod.as:72]
            at org.flexunit.internals.runners.statements::StackAndFrameManagement/evaluate()[C:\Users\Developer1\workspace\flexunit\FlexUnit4\src\org\flexunit\internals\runners\statements\StackAndFrameManagement.as:126]
            at org.flexunit.runners::BlockFlexUnit4ClassRunner/runChild()[C:\Users\Developer1\workspace\flexunit\FlexUnit4\src\org\flexunit\runners\BlockFlexUnit4ClassRunner.as:153]
            at org.flexunit.internals.runners::ChildRunnerSequencer/executeStep()[C:\Users\Developer1\workspace\flexunit\FlexUnit4\src\org\flexunit\internals\runners\ChildRunnerSequencer.as:82]
            at org.flexunit.internals.runners.statements::StatementSequencer/handleChildExecuteComplete()[C:\Users\Developer1\workspace\flexunit\FlexUnit4\src\org\flexunit\internals\runners\statements\StatementSequencer.as:141]
            at org.flexunit.token::AsyncTestToken/sendResult()[C:\Users\Developer1\workspace\flexunit\FlexUnit4\src\org\flexunit\token\AsyncTestToken.as:107]
            at org.flexunit.runners::BlockFlexUnit4ClassRunner/handleBlockComplete()[C:\Users\Developer1\workspace\flexunit\FlexUnit4\src\org\flexunit\runners\BlockFlexUnit4ClassRunner.as:190]
            at org.flexunit.token::AsyncTestToken/sendResult()[C:\Users\Developer1\workspace\flexunit\FlexUnit4\src\org\flexunit\token\AsyncTestToken.as:107]
            at org.flexunit.internals.runners.statements::StackAndFrameManagement/handleNextExecuteComplete()[C:\Users\Developer1\workspace\flexunit\FlexUnit4\src\org\flexunit\internals\runners\statements\StackAndFrameManagement.as:148]
            at org.flexunit.token::AsyncTestToken/sendResult()[C:\Users\Developer1\workspace\flexunit\FlexUnit4\src\org\flexunit\token\AsyncTestToken.as:107]
            at org.flexunit.internals.runners.statements::InvokeMethod/evaluate()[C:\Users\Developer1\workspace\flexunit\FlexUnit4\src\org\flexunit\internals\runners\statements\InvokeMethod.as:73]
            at org.flexunit.internals.runners.statements::StackAndFrameManagement/evaluate()[C:\Users\Developer1\workspace\flexunit\FlexUnit4\src\org\flexunit\internals\runners\statements\StackAndFrameManagement.as:126]
            at org.flexunit.runners::BlockFlexUnit4ClassRunner/runChild()[C:\Users\Developer1\workspace\flexunit\FlexUnit4\src\org\flexunit\runners\BlockFlexUnit4ClassRunner.as:153]
            at org.flexunit.internals.runners::ChildRunnerSequencer/executeStep()[C:\Users\Developer1\workspace\flexunit\FlexUnit4\src\org\flexunit\internals\runners\ChildRunnerSequencer.as:82]
            at org.flexunit.internals.runners.statements::StatementSequencer/handleChildExecuteComplete()[C:\Users\Developer1\workspace\flexunit\FlexUnit4\src\org\flexunit\internals\runners\statements\StatementSequencer.as:141]
            at org.flexunit.token::AsyncTestToken/sendResult()[C:\Users\Developer1\workspace\flexunit\FlexUnit4\src\org\flexunit\token\AsyncTestToken.as:107]
            at org.flexunit.runners::BlockFlexUnit4ClassRunner/handleBlockComplete()[C:\Users\Developer1\workspace\flexunit\FlexUnit4\src\org\flexunit\runners\BlockFlexUnit4ClassRunner.as:190]
            at org.flexunit.token::AsyncTestToken/sendResult()[C:\Users\Developer1\workspace\flexunit\FlexUnit4\src\org\flexunit\token\AsyncTestToken.as:107]
            at org.flexunit.internals.runners.statements::StackAndFrameManagement/handleNextExecuteComplete()[C:\Users\Developer1\workspace\flexunit\FlexUnit4\src\org\flexunit\internals\runners\statements\StackAndFrameManagement.as:148]
            at org.flexunit.token::AsyncTestToken/sendResult()[C:\Users\Developer1\workspace\flexunit\FlexUnit4\src\org\flexunit\token\AsyncTestToken.as:107]
            at org.flexunit.internals.runners.statements::InvokeMethod/evaluate()[C:\Users\Developer1\workspace\flexunit\FlexUnit4\src\org\flexunit\internals\runners\statements\InvokeMethod.as:73]
            at org.flexunit.internals.runners.statements::StackAndFrameManagement/evaluate()[C:\Users\Developer1\workspace\flexunit\FlexUnit4\src\org\flexunit\internals\runners\statements\StackAndFrameManagement.as:126]
            at org.flexunit.runners::BlockFlexUnit4ClassRunner/runChild()[C:\Users\Developer1\workspace\flexunit\FlexUnit4\src\org\flexunit\runners\BlockFlexUnit4ClassRunner.as:153]
            at org.flexunit.internals.runners::ChildRunnerSequencer/executeStep()[C:\Users\Developer1\workspace\flexunit\FlexUnit4\src\org\flexunit\internals\runners\ChildRunnerSequencer.as:82]
            at org.flexunit.internals.runners.statements::StatementSequencer/handleChildExecuteComplete()[C:\Users\Developer1\workspace\flexunit\FlexUnit4\src\org\flexunit\internals\runners\statements\StatementSequencer.as:141]
            at org.flexunit.token::AsyncTestToken/sendResult()[C:\Users\Developer1\workspace\flexunit\FlexUnit4\src\org\flexunit\token\AsyncTestToken.as:107]
            at org.flexunit.runners::BlockFlexUnit4ClassRunner/handleBlockComplete()[C:\Users\Developer1\workspace\flexunit\FlexUnit4\src\org\flexunit\runners\BlockFlexUnit4ClassRunner.as:190]
            at org.flexunit.token::AsyncTestToken/sendResult()[C:\Users\Developer1\workspace\flexunit\FlexUnit4\src\org\flexunit\token\AsyncTestToken.as:107]
            at org.flexunit.internals.runners.statements::StackAndFrameManagement/handleNextExecuteComplete()[C:\Users\Developer1\workspace\flexunit\FlexUnit4\src\org\flexunit\internals\runners\statements\StackAndFrameManagement.as:148]
            at org.flexunit.token::AsyncTestToken/sendResult()[C:\Users\Developer1\workspace\flexunit\FlexUnit4\src\org\flexunit\token\AsyncTestToken.as:107]
            at org.flexunit.internals.runners.statements::InvokeMethod/evaluate()[C:\Users\Developer1\workspace\flexunit\FlexUnit4\src\org\flexunit\internals\runners\statements\InvokeMethod.as:73]
            at org.flexunit.internals.runners.statements::StackAndFrameManagement/evaluate()[C:\Users\Developer1\workspace\flexunit\FlexUnit4\src\org\flexunit\internals\runners\statements\StackAndFrameManagement.as:126]
            at org.flexunit.runners::BlockFlexUnit4ClassRunner/runChild()[C:\Users\Developer1\workspace\flexunit\FlexUnit4\src\org\flexunit\runners\BlockFlexUnit4ClassRunner.as:153]
            at org.flexunit.internals.runners::ChildRunnerSequencer/executeStep()[C:\Users\Developer1\workspace\flexunit\FlexUnit4\src\org\flexunit\internals\runners\ChildRunnerSequencer.as:82]
            at org.flexunit.internals.runners.statements::StatementSequencer/handleChildExecuteComplete()[C:\Users\Developer1\workspace\flexunit\FlexUnit4\src\org\flexunit\internals\runners\statements\StatementSequencer.as:141]
            at org.flexunit.token::AsyncTestToken/sendResult()[C:\Users\Developer1\workspace\flexunit\FlexUnit4\src\org\flexunit\token\AsyncTestToken.as:107]
            at org.flexunit.runners::BlockFlexUnit4ClassRunner/handleBlockComplete()[C:\Users\Developer1\workspace\flexunit\FlexUnit4\src\org\flexunit\runners\BlockFlexUnit4ClassRunner.as:190]
            at org.flexunit.token::AsyncTestToken/sendResult()[C:\Users\Developer1\workspace\flexunit\FlexUnit4\src\org\flexunit\token\AsyncTestToken.as:107]
            at org.flexunit.internals.runners.statements::StackAndFrameManagement/handleNextExecuteComplete()[C:\Users\Developer1\workspace\flexunit\FlexUnit4\src\org\flexunit\internals\runners\statements\StackAndFrameManagement.as:148]
            at org.flexunit.token::AsyncTestToken/sendResult()[C:\Users\Developer1\workspace\flexunit\FlexUnit4\src\org\flexunit\token\AsyncTestToken.as:107]
            at org.flexunit.internals.runners.statements::InvokeMethod/evaluate()[C:\Users\Developer1\workspace\flexunit\FlexUnit4\src\org\flexunit\internals\runners\statements\InvokeMethod.as:73]
            at org.flexunit.internals.runners.statements::StackAndFrameManagement/evaluate()[C:\Users\Developer1\workspace\flexunit\FlexUnit4\src\org\flexunit\internals\runners\statements\StackAndFrameManagement.as:126]
            at org.flexunit.runners::BlockFlexUnit4ClassRunner/runChild()[C:\Users\Developer1\workspace\flexunit\FlexUnit4\src\org\flexunit\runners\BlockFlexUnit4ClassRunner.as:153]
            at org.flexunit.internals.runners::ChildRunnerSequencer/executeStep()[C:\Users\Developer1\workspace\flexunit\FlexUnit4\src\org\flexunit\internals\runners\ChildRunnerSequencer.as:82]
            at org.flexunit.internals.runners.statements::StatementSequencer/handleChildExecuteComplete()[C:\Users\Developer1\workspace\flexunit\FlexUnit4\src\org\flexunit\internals\runners\statements\StatementSequencer.as:141]
            at org.flexunit.internals.runners.statements::StatementSequencer/evaluate()[C:\Users\Developer1\workspace\flexunit\FlexUnit4\src\org\flexunit\internals\runners\statements\StatementSequencer.as:109]
            at org.flexunit.internals.runners.statements::StatementSequencer/executeStep()[C:\Users\Developer1\workspace\flexunit\FlexUnit4\src\org\flexunit\internals\runners\statements\StatementSequencer.as:98]
            at org.flexunit.internals.runners.statements::StatementSequencer/handleChildExecuteComplete()[C:\Users\Developer1\workspace\flexunit\FlexUnit4\src\org\flexunit\internals\runners\statements\StatementSequencer.as:141]
            at org.flexunit.token::AsyncTestToken/sendResult()[C:\Users\Developer1\workspace\flexunit\FlexUnit4\src\org\flexunit\token\AsyncTestToken.as:107]
            at org.flexunit.internals.runners.statements::AsyncStatementBase/sendComplete()[C:\Users\Developer1\workspace\flexunit\FlexUnit4\src\org\flexunit\internals\runners\statements\AsyncStatementBase.as:76]
            at org.flexunit.internals.runners.statements::StatementSequencer/sendComplete()[C:\Users\Developer1\workspace\flexunit\FlexUnit4\src\org\flexunit\internals\runners\statements\StatementSequencer.as:172]
            at org.flexunit.internals.runners.statements::StatementSequencer/handleChildExecuteComplete()[C:\Users\Developer1\workspace\flexunit\FlexUnit4\src\org\flexunit\internals\runners\statements\StatementSequencer.as:145]
            at org.flexunit.token::AsyncTestToken/sendResult()[C:\Users\Developer1\workspace\flexunit\FlexUnit4\src\org\flexunit\token\AsyncTestToken.as:107]
            at org.flexunit.internals.runners.statements::InvokeMethod/evaluate()[C:\Users\Developer1\workspace\flexunit\FlexUnit4\src\org\flexunit\internals\runners\statements\InvokeMethod.as:73]
            at org.flexunit.internals.runners.statements::SequencerWithDecoration/executeStep()[C:\Users\Developer1\workspace\flexunit\FlexUnit4\src\org\flexunit\internals\runners\statements\SequencerWithDecoration.as:100]
            at org.flexunit.internals.runners.statements::StatementSequencer/handleChildExecuteComplete()[C:\Users\Developer1\workspace\flexunit\FlexUnit4\src\org\flexunit\internals\runners\statements\StatementSequencer.as:141]
            at org.flexunit.internals.runners.statements::StatementSequencer/evaluate()[C:\Users\Developer1\workspace\flexunit\FlexUnit4\src\org\flexunit\internals\runners\statements\StatementSequencer.as:109]
            at org.flexunit.internals.runners.statements::StatementSequencer/executeStep()[C:\Users\Developer1\workspace\flexunit\FlexUnit4\src\org\flexunit\internals\runners\statements\StatementSequencer.as:98]
            at org.flexunit.internals.runners.statements::StatementSequencer/handleChildExecuteComplete()[C:\Users\Developer1\workspace\flexunit\FlexUnit4\src\org\flexunit\internals\runners\statements\StatementSequencer.as:141]
            at org.flexunit.internals.runners.statements::StatementSequencer/evaluate()[C:\Users\Developer1\workspace\flexunit\FlexUnit4\src\org\flexunit\internals\runners\statements\StatementSequencer.as:109]
        ]]> ).toString();

            const expected:Array = [
                "StatementSequencer.evaluate",
                ".handleChildExecuteComplete",
                ".executeStep",
                ".evaluate",
                ".handleChildExecuteComplete",
                "SequencerWithDecoration.executeStep",
                "InvokeMethod.evaluate",
                "AsyncTestToken.sendResult",
                "StatementSequencer.handleChildExecuteComplete",
                ".sendComplete",
                "AsyncStatementBase.sendComplete",
                "AsyncTestToken.sendResult",
                "StatementSequencer.handleChildExecuteComplete",
                ".executeStep",
                ".evaluate",
                ".handleChildExecuteComplete",
                "ChildRunnerSequencer.executeStep",
                "BlockFlexUnit4ClassRunner.runChild",
                "StackAndFrameManagement.evaluate",
                "InvokeMethod.evaluate",
                "AsyncTestToken.sendResult",
                "StackAndFrameManagement.handleNextExecuteComplete",
                "AsyncTestToken.sendResult",
                "BlockFlexUnit4ClassRunner.handleBlockComplete",
                "AsyncTestToken.sendResult",
                "StatementSequencer.handleChildExecuteComplete",
                "ChildRunnerSequencer.executeStep",
                "BlockFlexUnit4ClassRunner.runChild",
                "StackAndFrameManagement.evaluate",
                "InvokeMethod.evaluate",
                "AsyncTestToken.sendResult",
                "StackAndFrameManagement.handleNextExecuteComplete",
                "AsyncTestToken.sendResult",
                "BlockFlexUnit4ClassRunner.handleBlockComplete",
                "AsyncTestToken.sendResult",
                "StatementSequencer.handleChildExecuteComplete",
                "ChildRunnerSequencer.executeStep",
                "BlockFlexUnit4ClassRunner.runChild",
                "StackAndFrameManagement.evaluate",
                "InvokeMethod.evaluate",
                "AsyncTestToken.sendResult",
                "StackAndFrameManagement.handleNextExecuteComplete",
                "AsyncTestToken.sendResult",
                "BlockFlexUnit4ClassRunner.handleBlockComplete",
                "AsyncTestToken.sendResult",
                "StatementSequencer.handleChildExecuteComplete",
                "ChildRunnerSequencer.executeStep",
                "BlockFlexUnit4ClassRunner.runChild",
                "StackAndFrameManagement.evaluate",
                "InvokeMethod.evaluate",
                "AsyncTestToken.sendResult",
                "StackAndFrameManagement.handleNextExecuteComplete",
                "AsyncTestToken.sendResult",
                "BlockFlexUnit4ClassRunner.handleBlockComplete",
                "AsyncTestToken.sendResult",
                "StatementSequencer.handleChildExecuteComplete",
                "ChildRunnerSequencer.executeStep",
                "BlockFlexUnit4ClassRunner.runChild",
                "StackAndFrameManagement.evaluate",
                "InvokeMethod.evaluate",
                "FrameworkMethod.invokeExplosively",
                "Method.apply",
                "Function.apply",
                "tdtTest.test_log_output_includes_stack_functions_in_correct_order"
            ];

            //when
            var stackFunctions:Array = tdt.getFunctionsFromStackTrace(complexStackWithRepetitions, false, true, 0);

            //then
            assertTrue(arraysEqual(expected, stackFunctions));
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

            const currentStackTrace:String = new Error().getStackTrace();
            var stackFunctions:Array = tdt.getFunctionsFromStackTrace(currentStackTrace, false, true, 0);

            //when
            tdt.setUp(false, true, tdt.PRINT_IMMEDIATELY);
            tdt.debug(activity);

            //then
            var logCopy:String = logTarget.log;

            for(var i:int = stackFunctions.length >= 64 ? 1 : 0; i < stackFunctions.length; i++)
            {
                var stackFunction:String = stackFunctions[i];
                var positionOfFunctionInTrace:int = logCopy.indexOf(stackFunction);
                assertThat("The function " + stackFunction + " doesn't exist in the log!\nLOG: " + logTarget.log + "CURRENT STACK TRACE: " + currentStackTrace, positionOfFunctionInTrace != -1);
                logCopy = logCopy.substr(positionOfFunctionInTrace + stackFunction.length);
            }
        }
		
		private static function arraysEqual(a1:Array, a2:Array):Boolean
		{
            assertEquals("array lengths are different!", a1.length, a2.length);

			for (var i:int=0; i < a1.length; i++) {
				if (a1[i] != a2[i])
					return false;
			}
			return true;
		}
	}
}