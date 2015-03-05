package com.traffic.util.trace {
    import com.adobe.cairngorm.contract.Contract;
    import com.traffic.util.debugging.tdt;

    import mx.collections.HierarchicalCollectionView;
    import mx.collections.HierarchicalCollectionViewCursor;

    import mx.logging.ILogger;

    internal class HierarchicalCollectionViewTracer implements IObjectTracer
    {
        public function trace(what:Object):String
        {
            Contract.precondition(what is HierarchicalCollectionView);

            var target:HierarchicalCollectionView = what as HierarchicalCollectionView;
            var result:String = "";

            var cursor:HierarchicalCollectionViewCursor = target.createCursor() as HierarchicalCollectionViewCursor;
            while(!cursor.afterLast)
            {
                result += tdt.printObject(cursor.current) + "\n";
                cursor.moveNext();
            }

            Contract.postcondition(result != null);
            return result;
        }
    }
}
