/**
 * Distributed under Apache License v2.0. For more information
 * see LICENSE.
 */

package com.traffic.util.trace {
    import flash.events.Event;

    import mockolate.mock;
    import mockolate.nice;
    import mockolate.prepare;
    import mockolate.received;

    import org.flexunit.assertThat;
    import org.flexunit.asserts.assertEquals;
    import org.flexunit.async.Async;

    public class UnspecializedTracerTest {
        private var _sut:UnspecializedTracer;

        [Before(async, timeout=5000)]
        public function setUp():void
        {
            _sut = new UnspecializedTracer();
            Async.proceedOnEvent(this, prepare(DataNode), Event.COMPLETE);
        }

        [After]
        public function tearDown():void
        {
            _sut = null;
        }

        [Test]
        public function test_toString_used_with_mock_object():void
        {
            //given
            const NODE_DETAILS:String = "test";
            var node:DataNode = nice(DataNode);
            mock(node).method("toString").returns(NODE_DETAILS);

            //when
            var nodeDetails:String = _sut.trace(node);

            //then
            assertEquals(NODE_DETAILS, nodeDetails);
            assertThat(node, received().method("toString"));
        }

        [Test]
        public function test_toString_used_with_empty_object():void
        {
            //given
            var node:Object = {};

            //when
            var nodeDetails:String = _sut.trace(node);

            //then
            assertEquals("[object Object]", nodeDetails);
        }

        [Test]
        public function test_toString_used_with_dynamic_object():void
        {
            //given
            var node:Object = {name:"Alice"};

            //when
            var nodeDetails:String = _sut.trace(node);

            //then
            assertEquals('{name:"Alice"}', nodeDetails);
        }
    }
}