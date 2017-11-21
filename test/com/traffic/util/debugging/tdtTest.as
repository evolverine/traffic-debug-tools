/**
 * Distributed under Apache License v2.0. For more information
 * see LICENSE.
 */

package com.traffic.util.debugging
{
    import com.traffic.util.logging.StringLogTarget;

    import flash.events.Event;

    import mx.logging.Log;

    import org.flexunit.assertThat;
    import org.flexunit.asserts.assertEquals;
    import org.flexunit.asserts.assertFalse;
    import org.flexunit.asserts.assertTrue;

    public class tdtTest
	{
        private static const STACK_TRACE_LIMIT:int = 64;

        [Before]
        public function setUp():void
        {
            tdt.setUp(true, true, tdt.PRINT_MANUAL);
        }


        [After]
        public function tearDown():void
        {
            tdt.clearActivities();
        }

        [Test]
        public function test_clearActivities():void
        {
            //given
            var logTarget:StringLogTarget = new StringLogTarget();
            Log.addTarget(logTarget);

            //then
            assertEquals(0, logTarget.log.length);

            //when
            tdt.debug();
            tdt.printActivityStreams(false);

            //then
            assertTrue(atLeastOneActivityInXML(new XML(logTarget.log)));

            //given
            logTarget = new StringLogTarget();
            Log.addTarget(logTarget);

            //then
            assertEquals(0, logTarget.log.length);

            //when
            tdt.debug();
            tdt.printActivityStreams(false);

            //then
            assertTrue(atLeastOneActivityInXML(new XML(logTarget.log)));

            //given
            logTarget = new StringLogTarget();
            Log.addTarget(logTarget);

            //when
            tdt.clearActivities();
            tdt.printActivityStreams(true);

            //then
            assertActualAndExpectedXMLsMatch(new XML(logTarget.log), <debug/>);
            assertFalse(atLeastOneActivityInXML(new XML(logTarget.log)));
        }

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
			var allStackFunctionsExceptLast:Array = tdt.getFunctionsFromStackTrace(testStack, true, true, 1);

			//then
			assertTrue(arraysEqual(expected, allStackFunctionsExceptLast));
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
        public function test_getFunctionsFromStackTrace_with_complex_stack_trace_including_inner_function():void
        {
            //given
            const testUnrealisticButComplexStack:String = ( <![CDATA[
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
                "CC.setRootElement",
                ".setRootElement.innerFunctionOfSetRootElement"
            ];

            //when
            var actual:Array = tdt.getFunctionsFromStackTrace(testUnrealisticButComplexStack, true, true, 0);

            //then
            assertTrue(arraysEqual(actual, expected));
        }

        [Test]
        public function test_xml_log_for_two_identical_stack_traces_should_include_functions_only_once():void
        {
            //given
            var logTarget:StringLogTarget = new StringLogTarget();
            Log.addTarget(logTarget);

            const stack:String = ( <![CDATA[
                    Error
            at com.traffic.util.debugging::tdt$/debug()[C:\Users\evolverine\Adobe Flash Builder 4.7\traffic-debug-tools\src\com\traffic\util\debugging\tdt.as:63]
            at mx.managers::LayoutManager/validateSize()[C:\Users\evolverine\Adobe Flash Builder 4.7\FLEX-33058\src\mx\managers\LayoutManager.as:651]
            at mx.managers::LayoutManager/doPhasedInstantiation()[C:\Users\evolverine\Adobe Flash Builder 4.7\FLEX-33058\src\mx\managers\LayoutManager.as:799]
            at mx.managers::LayoutManager/doPhasedInstantiationCallback()[C:\Users\evolverine\Adobe Flash Builder 4.7\FLEX-33058\src\mx\managers\LayoutManager.as:1187]
            ]]>).toString();

            const expectedXML:XML = <debug>
                <call name="LM.doPhasedInstantiationCallback">
                    <call name=".doPhasedInstantiation">
                        <call name=".validateSize">
                            <activity time="17:07.759">hello</activity>
                            <activity time="17:07.763">hello</activity>
                        </call>
                    </call>
                </call>
            </debug>;

            //when
            tdt.debug("hello", stack, false);
            tdt.debug("hello", stack, false);
            tdt.printActivityStreams(true);

            //then
            assertActualAndExpectedXMLsMatch(new XML(logTarget.log), expectedXML);
        }

        [Test]
        public function test_xml_log_for_stack_traces_which_share_root():void
        {
            //given
            var logTarget:StringLogTarget = new StringLogTarget();
            Log.addTarget(logTarget);

            const stack1:String = ( <![CDATA[
                    Error
            at com.traffic.util.debugging::tdt$/debug()[C:\Users\evolverine\Adobe Flash Builder 4.7\traffic-debug-tools\src\com\traffic\util\debugging\tdt.as:63]
            at mx.managers::LayoutManager/validateSize()[C:\Users\evolverine\Adobe Flash Builder 4.7\FLEX-33058\src\mx\managers\LayoutManager.as:651]
            at mx.managers::LayoutManager/doPhasedInstantiation()[C:\Users\evolverine\Adobe Flash Builder 4.7\FLEX-33058\src\mx\managers\LayoutManager.as:799]
            at mx.managers::LayoutManager/doPhasedInstantiationCallback()[C:\Users\evolverine\Adobe Flash Builder 4.7\FLEX-33058\src\mx\managers\LayoutManager.as:1187]
            ]]>).toString();

            const stack2:String = ( <![CDATA[
                    Error
            at com.traffic.util.debugging::tdt$/debug()[C:\Users\evolverine\Adobe Flash Builder 4.7\traffic-debug-tools\src\com\traffic\util\debugging\tdt.as:70]
            at spark.components::Group/measure()[C:\Users\evolverine\Adobe Flash Builder 4.7\FLEX-33058\src\spark\components\Group.as:240]
            at mx.core::UIComponent/measureSizes()[C:\Users\evolverine\workspace\flex-sdk\frameworks\projects\framework\src\mx\core\UIComponent.as:9038]
            at mx.core::UIComponent/validateSize()[C:\Users\evolverine\workspace\flex-sdk\frameworks\projects\framework\src\mx\core\UIComponent.as:8962]
            at spark.components::Group/validateSize()[C:\Users\evolverine\Adobe Flash Builder 4.7\FLEX-33058\src\spark\components\Group.as:1082]
            at mx.managers::LayoutManager/validateSize()[C:\Users\evolverine\Adobe Flash Builder 4.7\FLEX-33058\src\mx\managers\LayoutManager.as:672]
            at mx.managers::LayoutManager/doPhasedInstantiation()[C:\Users\evolverine\Adobe Flash Builder 4.7\FLEX-33058\src\mx\managers\LayoutManager.as:799]
            at mx.managers::LayoutManager/doPhasedInstantiationCallback()[C:\Users\evolverine\Adobe Flash Builder 4.7\FLEX-33058\src\mx\managers\LayoutManager.as:1187]
            ]]>).toString();

            const expectedXML:XML = <debug>
                <call name="LM.doPhasedInstantiationCallback">
                    <call name=".doPhasedInstantiation">
                        <call name=".validateSize">
                            <activity time="17:07.759">hello</activity>
                            <call name="G.validateSize">
                                <call name="UIC.validateSize">
                                    <call name=".measureSizes">
                                        <call name="G.measure">
                                            <activity time="17:08.159">measuring</activity>
                                        </call>
                                    </call>
                                </call>
                            </call>
                        </call>
                    </call>
                </call>
            </debug>;

            //when
            tdt.debug("hello", stack1, false);
            tdt.debug("measuring", stack2, false);
            tdt.printActivityStreams(true);

            //then
            assertActualAndExpectedXMLsMatch(new XML(logTarget.log), expectedXML);
        }

        [Test]
        public function test_xml_log_for_more_stack_traces_which_share_root():void
        {
            //given
            var logTarget:StringLogTarget = new StringLogTarget();
            Log.addTarget(logTarget);

            const stack1:String = ( <![CDATA[
                    Error
            at com.traffic.util.debugging::tdt$/debug()[C:\Users\evolverine\Adobe Flash Builder 4.7\traffic-debug-tools\src\com\traffic\util\debugging\tdt.as:63]
            at mx.managers::LayoutManager/validateSize()[C:\Users\evolverine\Adobe Flash Builder 4.7\FLEX-33058\src\mx\managers\LayoutManager.as:651]
            at mx.managers::LayoutManager/doPhasedInstantiation()[C:\Users\evolverine\Adobe Flash Builder 4.7\FLEX-33058\src\mx\managers\LayoutManager.as:799]
            at mx.managers::LayoutManager/doPhasedInstantiationCallback()[C:\Users\evolverine\Adobe Flash Builder 4.7\FLEX-33058\src\mx\managers\LayoutManager.as:1187]
            ]]>).toString();

            const stack2:String = ( <![CDATA[
                    Error
            at com.traffic.util.debugging::tdt$/debug()[C:\Users\evolverine\Adobe Flash Builder 4.7\traffic-debug-tools\src\com\traffic\util\debugging\tdt.as:70]
            at spark.components::Group/measure()[C:\Users\evolverine\Adobe Flash Builder 4.7\FLEX-33058\src\spark\components\Group.as:240]
            at mx.core::UIComponent/measureSizes()[C:\Users\evolverine\workspace\flex-sdk\frameworks\projects\framework\src\mx\core\UIComponent.as:9038]
            at mx.core::UIComponent/validateSize()[C:\Users\evolverine\workspace\flex-sdk\frameworks\projects\framework\src\mx\core\UIComponent.as:8962]
            at spark.components::Group/validateSize()[C:\Users\evolverine\Adobe Flash Builder 4.7\FLEX-33058\src\spark\components\Group.as:1082]
            at mx.managers::LayoutManager/validateSize()[C:\Users\evolverine\Adobe Flash Builder 4.7\FLEX-33058\src\mx\managers\LayoutManager.as:672]
            at mx.managers::LayoutManager/doPhasedInstantiation()[C:\Users\evolverine\Adobe Flash Builder 4.7\FLEX-33058\src\mx\managers\LayoutManager.as:799]
            at mx.managers::LayoutManager/doPhasedInstantiationCallback()[C:\Users\evolverine\Adobe Flash Builder 4.7\FLEX-33058\src\mx\managers\LayoutManager.as:1187]
            ]]>).toString();

            const stack3:String = ( <![CDATA[
                    Error
            at com.traffic.util.debugging::tdt$/debug()[C:\Users\evolverine\Adobe Flash Builder 4.7\traffic-debug-tools\src\com\traffic\util\debugging\tdt.as:70]
            at mx.core::UIComponent/invalidateDisplayList()[C:\Users\evolverine\workspace\flex-sdk\frameworks\projects\framework\src\mx\core\UIComponent.as:8428]
            at mx.core::UIComponent/validateSize()[C:\Users\evolverine\workspace\flex-sdk\frameworks\projects\framework\src\mx\core\UIComponent.as:8962]
            at spark.components::Group/validateSize()[C:\Users\evolverine\Adobe Flash Builder 4.7\FLEX-33058\src\spark\components\Group.as:1082]
            at mx.managers::LayoutManager/validateSize()[C:\Users\evolverine\Adobe Flash Builder 4.7\FLEX-33058\src\mx\managers\LayoutManager.as:672]
            at mx.managers::LayoutManager/doPhasedInstantiation()[C:\Users\evolverine\Adobe Flash Builder 4.7\FLEX-33058\src\mx\managers\LayoutManager.as:799]
            at mx.managers::LayoutManager/doPhasedInstantiationCallback()[C:\Users\evolverine\Adobe Flash Builder 4.7\FLEX-33058\src\mx\managers\LayoutManager.as:1187]
            ]]>).toString();

            const stack4:String = ( <![CDATA[
                    Error
            at com.traffic.util.debugging::tdt$/debug()[C:\Users\evolverine\Adobe Flash Builder 4.7\traffic-debug-tools\src\com\traffic\util\debugging\tdt.as:70]
            at mx.managers::LayoutManager/doPhasedInstantiation()[C:\Users\evolverine\Adobe Flash Builder 4.7\FLEX-33058\src\mx\managers\LayoutManager.as:799]
            at mx.managers::LayoutManager/doPhasedInstantiationCallback()[C:\Users\evolverine\Adobe Flash Builder 4.7\FLEX-33058\src\mx\managers\LayoutManager.as:1187]
            ]]>).toString();

            const expectedXML:XML = <debug>
                <call name="LM.doPhasedInstantiationCallback">
                    <call name=".doPhasedInstantiation">
                        <call name=".validateSize">
                            <activity time="17:07.759">hello</activity>
                            <call name="G.validateSize">
                                <call name="UIC.validateSize">
                                    <call name=".measureSizes">
                                        <call name="G.measure">
                                            <activity time="17:08.159">measuring</activity>
                                            <activity time="17:08.159">measuring2</activity>
                                        </call>
                                    </call>
                                    <call name=".invalidateDisplayList">
                                        <activity time="17:08.159">UIComp</activity>
                                    </call>
                                </call>
                            </call>
                        </call>
                        <activity time="17:09.159">phased</activity>
                    </call>
                </call>
            </debug>;
            const expected:XMLList = expectedXML.descendants();

            //when
            tdt.debug("hello", stack1, false);
            tdt.debug("measuring", stack2, false);
            tdt.debug("measuring2", stack2, false);
            tdt.debug("UIComp", stack3, false);
            tdt.debug("phased", stack4, false);

            tdt.printActivityStreams(true);

            //then
            assertActualAndExpectedXMLsMatch(new XML(logTarget.log), expectedXML);
        }

        [Test]
        public function test_xml_log_for_stack_traces_which_do_not_share_root():void
        {
            //given
            var logTarget:StringLogTarget = new StringLogTarget();
            Log.addTarget(logTarget);

            const stack1:String = ( <![CDATA[
                    Error
            at com.traffic.util.debugging::tdt$/debug()[C:\Users\evolverine\Adobe Flash Builder 4.7\traffic-debug-tools\src\com\traffic\util\debugging\tdt.as:63]
            at mx.managers::LayoutManager/validateSize()[C:\Users\evolverine\Adobe Flash Builder 4.7\FLEX-33058\src\mx\managers\LayoutManager.as:651]
            at mx.managers::LayoutManager/doPhasedInstantiation()[C:\Users\evolverine\Adobe Flash Builder 4.7\FLEX-33058\src\mx\managers\LayoutManager.as:799]
            at mx.managers::LayoutManager/doPhasedInstantiationCallback()[C:\Users\evolverine\Adobe Flash Builder 4.7\FLEX-33058\src\mx\managers\LayoutManager.as:1187]
            ]]>).toString();

            const stack2:String = ( <![CDATA[
                    Error
            at com.traffic.util.debugging::tdt$/debugSimilar()[C:\Users\evolverine\Adobe Flash Builder 4.7\traffic-debug-tools\src\com\traffic\util\debugging\tdt.as:98]
            at mx.managers.systemClasses::ChildManager/initializeTopLevelWindow()[C:\Users\evolverine\workspace\flex-sdk\frameworks\projects\framework\src\mx\managers\systemClasses\ChildManager.as:319]
            at mx.managers::SystemManager/initializeTopLevelWindow()[C:\Users\evolverine\workspace\flex-sdk\frameworks\projects\framework\src\mx\managers\SystemManager.as:3065]
            at flash.events::EventDispatcher/dispatchEventFunction()
            at flash.events::EventDispatcher/dispatchEvent()
            at mx.preloaders::Preloader/timerHandler()[C:\Users\evolverine\workspace\flex-sdk\frameworks\projects\framework\src\mx\preloaders\Preloader.as:572]
            at flash.utils::Timer/_timerDispatch()
            at flash.utils::Timer/tick()
            ]]>).toString();

            const expectedXML:XML = <debug>
                <call name="LM.doPhasedInstantiationCallback">
                    <call name=".doPhasedInstantiation">
                        <call name=".validateSize">
                            <activity time="17:07.759">hello</activity>
                        </call>
                    </call>
                </call>
                <call name="T.tick">
                    <call name="._timerDispatch">
                        <call name="P.timerHandler">
                            <call name="ED.dispatchEvent">
                                <call name=".dispatchEventFunction">
                                    <call name="SM.initializeTopLevelWindow">
                                        <call name="CM.initializeTopLevelWindow">
                                            <activity time="17:08.159">measuring</activity>
                                        </call>
                                    </call>
                                </call>
                            </call>
                        </call>
                    </call>
                </call>
            </debug>;
            const expected:XMLList = expectedXML.descendants();

            //when
            tdt.debug("hello", stack1, false);
            tdt.debug("measuring", stack2, false);
            tdt.printActivityStreams(true);

            //then
            assertActualAndExpectedXMLsMatch(new XML(logTarget.log), expectedXML);
        }

        [Test]
        public function test_location_tracing():void
        {
            //given
            var logTarget:StringLogTarget = new StringLogTarget();
            Log.addTarget(logTarget);

            const expectedXMLFragment:XML = <call name="T.test_location_tracing"><activity time="57:23.452">T.test_location_tracing()</activity></call>;

            //when
            tdt.debugLocation(arguments);
            tdt.printActivityStreams(true);

            //then
            assertFirstActivitiesInIdenticalSubTrees(new XML(logTarget.log), expectedXMLFragment);
        }

        [Test]
        public function test_location_tracing_with_arguments():void
        {
            function locationTracingWithTwoArguments(a:int = 1, b:int = 2):void
            {
                tdt.debugLocation(arguments);
            }

            //given
            var logTarget:StringLogTarget = new StringLogTarget();
            Log.addTarget(logTarget);

            const expectedXMLFragment:XML = <call name="tdtTest.test_location_tracing_with_arguments"><call name="tdtTest.test_location_tracing_with_arguments.locationTracingWithTwoArguments"><activity time="57:23.452">tdtTest.test_location_tracing_with_arguments.locationTracingWithTwoArguments(3,4)</activity></call></call>;

            //when
            tdt.setUp(false, false);
            locationTracingWithTwoArguments(3, 4);
            tdt.printActivityStreams(true);

            //then
            assertFirstActivitiesInIdenticalSubTrees(new XML(logTarget.log), expectedXMLFragment);
        }

        [Test]
        public function test_location_tracing_with_arguments_in_inner_function_of_inner_function():void
        {
            function locationTracingWithTwoArguments(a:int = 1, b:int = 2):void
            {
                function sum(a:int, b:int):int
                {
                    tdt.debugLocation(arguments);
                    return a + b;
                }

                sum(a, b);
            }

            //given
            var logTarget:StringLogTarget = new StringLogTarget();
            Log.addTarget(logTarget);

            const expectedXMLFragment:XML = <call name="tdtTest.test_location_tracing_with_arguments_in_inner_function_of_inner_function"><call name="tdtTest.test_location_tracing_with_arguments_in_inner_function_of_inner_function.locationTracingWithTwoArguments"><call name="tdtTest.test_location_tracing_with_arguments_in_inner_function_of_inner_function.locationTracingWithTwoArguments.sum"><activity time="57:23.452">tdtTest.test_location_tracing_with_arguments_in_inner_function_of_inner_function.locationTracingWithTwoArguments.sum(9, 11)</activity></call></call></call>;

            //when
            tdt.setUp(false, false);
            locationTracingWithTwoArguments(9, 11);
            tdt.printActivityStreams(true);

            //then
            assertFirstActivitiesInIdenticalSubTrees(new XML(logTarget.log), expectedXMLFragment);
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

            for(var i:int = stackFunctions.length >= STACK_TRACE_LIMIT ? 1 : 0; i < stackFunctions.length; i++)
            {
                var stackFunction:String = stackFunctions[i];
                var positionOfFunctionInTrace:int = logCopy.indexOf(stackFunction);
                assertThat("The function " + stackFunction + " doesn't exist in the log!\nLOG: " + logTarget.log + "CURRENT STACK TRACE: " + currentStackTrace, positionOfFunctionInTrace != -1);
                logCopy = logCopy.substr(positionOfFunctionInTrace + stackFunction.length);
            }
        }

        [Test]
        public function test_the_limit_of_stack_traces():void
        {
            //when
            const errorWithLongStackTrace:Error = getErrorWithLongStackTrace();
            const stackTraceLines:Array = errorWithLongStackTrace.getStackTrace().split("\n");
            const actualLimit:int = stackTraceLines.length - 1; //minus the first line, which is the error description

            //then
            assertEquals(STACK_TRACE_LIMIT, actualLimit);
        }

        [Test]
        public function test_setting_and_retrieving_string_value():void
        {
            //when
            tdt.setValue("hello", "world");

            //then
            assertEquals("world", tdt.getValue("hello"));
        }

        [Test]
        public function test_setting_and_retrieving_object():void
        {
            //given
            var world:Object = {universe:2345, galaxy:198324};

            //when
            tdt.setValue("hello", world);

            //then
            assertEquals(world, tdt.getValue("hello"));
        }

        [Test]
        public function test_retrieving_nonexistent_value_returns_undefined():void
        {
            //given
            var world:Object = {universe:2345, galaxy:198324};

            //when
            tdt.setValue("hello", world);

            //then
            assertThat(undefined === tdt.getValue("nonexistent"));
        }



        //returns true if the first activity of the actual fragment, is identical to (except for the time attribute)
        //and also surrounded by exactly the same parents, siblings and children as the first one in the expected fragment
        private static function assertFirstActivitiesInIdenticalSubTrees(actual:XML, expectedFragment:XML):void
        {
            const expectedXMLString:String = removeWhiteSpaceBetweenTags(removeActivityTimesFromTraceXML(expectedFragment.toString()));
            const actualXMLString:String = removeWhiteSpaceBetweenTags(removeActivityTimesFromTraceXML(actual.toString()));

            assertThat("Expected XML not found in actual XML. Expected: \n" + expectedXMLString + "\n.\n.\n. Actual: \n" + actualXMLString,
                    actualXMLString.indexOf(expectedXMLString) != -1);
        }

        private static function removeActivityTimesFromTraceXML(traceXML:String):String
        {
            return traceXML.replace(/<activity time=\"[0-9\.\:]+\"/gi, "<activity");
        }

        private static function removeWhiteSpaceBetweenTags(xmlString:String):String
        {
            return xmlString.replace(/\>[\s]+\</gi, "><");
        }

        private static function atLeastOneActivityInXML(actual:XML):Boolean
        {
            return actual..activity.length() > 0;
        }

        private static function assertActualAndExpectedXMLsMatch(actual:XML, expected:XML):void
        {
            const actualDescendants:XMLList = actual.descendants();
            const expectedDescendants:XMLList = expected.descendants();

            assertEquals(expectedDescendants.length(), actualDescendants.length());

            for(var i:int = 0; i < expectedDescendants.length(); i++)
            {
                var expectedNode:XML = expectedDescendants[i];
                var actualNode:XML = actualDescendants[i];

                if(expectedNode.name() == "call")
                {
                    assertEquals(expectedNode.attribute("name"), actualNode.attribute("name"));
                    assertEquals(expectedNode.descendants().length(), actualNode.descendants().length());
                }
                else if(expectedNode.name() == "activity")
                    assertThat(actualNode.attribute("time").toString().length > 0);
                else
                    assertEquals(expectedNode.toString(), actualNode.toString());
            }
        }

        private function getErrorWithLongStackTrace():Error
        {
            function generateErrorAfterManyRecursions():void
            {
                if(++counter < 100)
                    generateErrorAfterManyRecursions();
                else
                    error = new Error();
            }

            var counter:int = 0;
            var error:Error = null;
            generateErrorAfterManyRecursions();
            return error;
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