package com.traffic.util.trace {
    import avmplus.getQualifiedClassName;

    import flash.events.Event;

    import mockolate.mock;
    import mockolate.nice;
    import mockolate.prepare;
    import mockolate.received;

    import org.flexunit.assertThat;
    import org.flexunit.asserts.assertEquals;
    import org.flexunit.async.Async;

    public class TracerTest {
        private var _sut:Tracer;

        [Before(async, timeout=5000)]
        public function setUp():void
        {
            Async.proceedOnEvent(this, prepare(UnspecializedTracer, ObjectTracerCache), Event.COMPLETE);
        }

        [After]
        public function tearDown():void
        {
            _sut = null;
        }

        [Test]
        public function test_tracer_does_basic_object_trace():void
        {
            //given
            const NAME:String = "Steve";
            var unspecializedTracer:UnspecializedTracer = nice(UnspecializedTracer);

            const objectToTrace:Object = {name:NAME};
            var tracerCache:ObjectTracerCache = nice(ObjectTracerCache);
            mock(tracerCache).method("getTracer").args(getQualifiedClassName(objectToTrace)).returns(unspecializedTracer);
            mock(unspecializedTracer).method("trace").args(objectToTrace).returns(NAME);

            _sut = new Tracer(tracerCache);

            //when
            var objectTrace:String = _sut.trace(objectToTrace);

            //then
            assertEquals(objectTrace, NAME);
            assertThat(unspecializedTracer, received().method("trace").args(objectToTrace));
        }
    }
}
