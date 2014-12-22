package com.traffic.util.debugging {
    import mx.logging.Log;

    import org.flexunit.assertThat;

    import org.flexunit.asserts.assertEquals;

    public class InspectableArrayTest {
        private var _sut:InspectableArray;

        [Before]
        public function setUp():void
        {
            _sut = new InspectableArray();
        }


        [After]
        public function tearDown():void
        {
            _sut = null;
        }


        [Test]
        public function test_push_and_pop_work_as_in_default_array():void
        {
            //given
            var obj1:Object = {};

            //when
            _sut.push(obj1);

            //then
            assertEquals(1, _sut.length);
            assertEquals(obj1, _sut[0]);

            //when 2
            var obj2:Object = _sut.pop();

            //then 2
            assertEquals(0, _sut.length);
            assertEquals(obj2, obj1);
        }


        [Test]
        public function test_push_traces_pushed_object_immediately():void
        {
            //given
            var logTarget:StringLogTarget = new StringLogTarget();
            Log.addTarget(logTarget);
            const pushedString:String = "pushedString";

            //when
            _sut.push(pushedString);

            //then
            assertThat(logTarget.log.indexOf(pushedString) != -1);
        }

        [Test]
        public function test_pop_traces_popped_object_immediately():void
        {
            //given
            const pushedString:String = "pushedString";
            _sut.push(pushedString);

            var logTarget:StringLogTarget = new StringLogTarget();
            Log.addTarget(logTarget);

            //when
            _sut.pop();

            //then
            assertThat(logTarget.log.indexOf(pushedString) != -1);
        }
    }
}
