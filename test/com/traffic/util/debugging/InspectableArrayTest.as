package com.traffic.util.debugging {
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


        [Ignore]
        [Test]
        public function test_push_traces_pushed_objects():void
        {
            //will be able to implement this once ticket #8 is done
        }

        [Ignore]
        [Test]
        public function test_pop_traces_popped_object():void
        {
            //will be able to implement this once ticket #8 is done
        }
    }
}
