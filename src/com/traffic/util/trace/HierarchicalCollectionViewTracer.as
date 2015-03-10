/**
 * Distributed under Apache License v2.0. For more information
 * see LICENSE.
 */

package com.traffic.util.trace {
    import com.adobe.cairngorm.contract.Contract;
    import com.traffic.util.debugging.tdt;

    import mx.collections.HierarchicalCollectionView;
    import mx.collections.HierarchicalCollectionViewCursor;

    import mx.logging.ILogger;

    /**
     * Note that currently the HierarchicalCollectionViewTracer is very simple, and only
     * traces each node on a separate line, regardless of depth. It can definitely be
     * improved.
     */
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
                result += tdt.traceObject(cursor.current) + "\n";
                cursor.moveNext();
            }

            Contract.postcondition(result != null);
            return result;
        }
    }
}
