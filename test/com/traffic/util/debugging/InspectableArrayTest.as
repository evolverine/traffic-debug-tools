/**
 * Distributed under Apache License v2.0. For more information
 * see LICENSE.
 */

package com.traffic.util.debugging {
    import com.traffic.util.logging.StringLogTarget;

    import mx.logging.Log;

    import org.flexunit.assertThat;
    import org.flexunit.asserts.assertEquals;
    import org.flexunit.asserts.assertNotNull;

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
            tdt.printActivityStreams(true);

            //then
            assertThat(logTarget.log.indexOf(pushedString) != -1);
        }

        [Test]
        public function test_pop_traces_popped_object():void
        {
            //given
            const pushedString:String = "pushedString";
            _sut.push(pushedString);

            var logTarget:StringLogTarget = new StringLogTarget();
            Log.addTarget(logTarget);

            //when
            _sut.pop();
            tdt.printActivityStreams(true);

            //then
            assertThat(logTarget.log.indexOf(pushedString) != -1);
        }

        [Test]
        public function test_array_is_cloned_correctly():void
        {
            //given
            const source:Array = [];
            source["hey"] = "you";
            source[null] = "null?";
            source[2] = undefined;
            source[undefined] = 12345;
            source[-999] = "ok";

            //when
            const inspectableArray:InspectableArray = InspectableArray.fromArray(source);

            //then
            for(var s:String in source)
            {
                assertEquals("item not copied correctly in the destination", source[s], inspectableArray[s]);
            }
        }

        [Test]
        public function test_splice_works_as_in_default_array():void
        {
            //given
            var obj1:NamedObject = new NamedObject("hello");

            //when
            _sut.splice(0, 0, obj1);

            //then
            assertEquals(1, _sut.length);
            assertEquals(obj1, _sut[0]);

            //when 2
            var removed:Array = _sut.splice(0, 1);

            //then 2
            assertEquals(0, _sut.length);
            assertEquals(1, removed.length);
            assertEquals(obj1, removed[0]);
        }

        [Test]
        public function test_splice_replaces_normal_arrays_with_inspectable_arrays():void
        {
            //given
            var array:Array = ["hello"];

            //when
            _sut.splice(0, 0, array);

            //then
            assertEquals(1, _sut.length);
            assertThat(array != _sut[0]);

            //when 2
            var removed:Array = _sut.splice(0, 1);

            //then 2
            assertEquals(0, _sut.length);
            assertEquals(1, removed.length);
            assertEquals(array, removed[0]);
        }

        [Test]
        public function test_splice_traces_operation():void
        {
            //given
            const spliceTracePrefix:String = "splicing";
            var newlyAddedItem:String = "newlyAddedString";

            var logTarget:StringLogTarget = new StringLogTarget();
            Log.addTarget(logTarget);

            //when
            _sut.splice(0, 0, newlyAddedItem);
            tdt.printActivityStreams(true);

            //then
            assertNotNull(logTarget.log);
            assertThat(logTarget.log.indexOf(newlyAddedItem) != -1);
            assertThat(logTarget.log.indexOf(spliceTracePrefix) != -1);
        }
    }
}

class NamedObject
{
    private static var _nextId:int = 0;
    private var _name:String;
    public var _id:int;

    public function NamedObject(name:String)
    {
        _id = _nextId++;
        _name = name;
    }

    public function get name():String
    {
        return _name;
    }


    public function toString():String
    {
        return "NamedObject{_name=" + String(_name) + ",_id=" + String(_id) + "}";
    }
}