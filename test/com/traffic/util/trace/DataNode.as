/**
 * Distributed under Apache License v2.0. For more information
 * see LICENSE.
 */

package com.traffic.util.trace {
    import mx.collections.ArrayCollection;

    public class DataNode {
        private var _label:String;
        private var _children:ArrayCollection;

        public function DataNode(label:String)
        {
            _label = label;
        }

        public function get children():ArrayCollection
        {
            return _children;
        }

        public function get label():String
        {
            return _label;
        }

        public function toString():String
        {
            return label;
        }

        public function addChild(node:DataNode):void
        {
            if(!_children)
                _children = new ArrayCollection();

            _children.addItem(node);
        }
    }
}
