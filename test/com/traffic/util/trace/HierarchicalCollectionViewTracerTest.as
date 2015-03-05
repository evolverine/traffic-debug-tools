package com.traffic.util.trace {
    import mx.collections.HierarchicalCollectionView;
    import mx.utils.StringUtil;

    import org.flexunit.asserts.assertEquals;

    public class HierarchicalCollectionViewTracerTest {

        private static var _sut:HierarchicalCollectionViewTracer;
        private static var _utils:HierarchicalCollectionViewTestUtils = new HierarchicalCollectionViewTestUtils();

        [Before]
        public function setUp():void
        {
            _sut = new HierarchicalCollectionViewTracer();
        }

        [After]
        public function tearDown():void
        {
            _sut = null;
        }

        [Test]
        public function test_something():void
        {
            //given
            const objectToTrace:HierarchicalCollectionView = generateHierarchyViewWithOpenNodes();

            //when
            var hcvTrace:String = _sut.trace(objectToTrace);

            //then
            var hcvExpectedLines:Array = HIERARCHY_STRING.split("\n");
            var hcvActualLines:Array = hcvTrace.split("\n");
            assertEquals(hcvExpectedLines.length, hcvActualLines.length);
            for(var i:int = 0; i < hcvExpectedLines.length; i++)
                assertEquals(StringUtil.trim(hcvExpectedLines[i]), StringUtil.trim(hcvActualLines[i]));
        }

        private static function generateHierarchyViewWithOpenNodes():HierarchicalCollectionView
        {
            return _utils.generateOpenHierarchyFromRootList(_utils.generateHierarchySourceFromString(HIERARCHY_STRING));
        }

        private static const HIERARCHY_STRING:String = (<![CDATA[Company(1)
        Company(1)->Location(1)
        Company(1)->Location(1)->Department(1)
        Company(1)->Location(1)->Department(2)
        Company(1)->Location(2)
        Company(1)->Location(2)->Department(1)
        Company(1)->Location(2)->Department(2)
        Company(1)->Location(2)->Department(3)
        Company(1)->Location(3)
        Company(2)
        Company(2)->Location(1)
        Company(2)->Location(2)
        Company(2)->Location(2)->Department(1)
        Company(2)->Location(3)
        Company(3)
    ]]>).toString();
    }
}
