package com.traffic.util.trace {
import mx.collections.ArrayCollection;

public class DataNode {
    private var _label:String;
    private var _children:ArrayCollection;

    public function DataNode(label:String)
    {
        _label = label;
    }

    public function get children():ArrayCollection {
        return _children;
    }

    public function get label():String {
        return _label;
    }

    public function toString():String
    {
        return label;
    }

    public function addChild(node:DataNode):void {
        if(!_children)
            _children = new ArrayCollection();

        _children.addItem(node);
    }

    public function clone():DataNode
    {
        var newNode:DataNode = new DataNode(_label);
        for each(var childNode:DataNode in children)
        {
            newNode.addChild(childNode.clone());
        }

        return newNode;
    }
}
}
