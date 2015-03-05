package com.traffic.util.trace {
    import com.traffic.util.debugging.StringLogTarget;

    import mx.collections.HierarchicalCollectionView;

    import mx.logging.Log;
    import mx.utils.StringUtil;

    import org.flexunit.asserts.assertEquals;

    public class TracerTest {
        private var _sut:Tracer;

        [After]
        public function tearDown():void
        {
            _sut = null;
        }

        [Test]
        public function test_tracer_does_basic_object_trace():void
        {
            //given
            const objectToTrace:Object = {name:"Steve"};
            _sut = new Tracer(objectToTrace);

            //when
            var objectTraceOut:String = _sut.trace();

            //then
            assertEquals(objectToTrace.toString(), objectTraceOut);
        }
    }
}
