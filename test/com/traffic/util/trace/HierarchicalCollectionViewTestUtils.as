////////////////////////////////////////////////////////////////////////////////
//
//  Licensed to the Apache Software Foundation (ASF) under one or more
//  contributor license agreements.  See the NOTICE file distributed with
//  this work for additional information regarding copyright ownership.
//  The ASF licenses this file to You under the Apache License, Version 2.0
//  (the "License"); you may not use this file except in compliance with
//  the License.  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
////////////////////////////////////////////////////////////////////////////////

package com.traffic.util.trace
{
    import mx.collections.ArrayCollection;
    import mx.collections.HierarchicalCollectionView;
    import mx.collections.HierarchicalCollectionViewCursor;
    import mx.collections.HierarchicalData;
    import mx.utils.StringUtil;
    import mx.utils.UIDUtil;

    public class HierarchicalCollectionViewTestUtils
	{
		//assumes the root is an ArrayCollection of DataNodes
		private var _allNodes:Object = {};
		
		public function generateOpenHierarchyFromRootList(root:ArrayCollection):HierarchicalCollectionView
		{
			var hcv:HierarchicalCollectionView = generateHCV(root, false);
			openAllNodes(hcv);
			return hcv;
		}

		public function generateHCV(rootCollection:ArrayCollection, useAllNodes:Boolean = false):HierarchicalCollectionView
		{
			return new HierarchicalCollectionView(new HierarchicalData(rootCollection), useAllNodes ? _allNodes : null);
		}
		
		public static function openAllNodes(hcv:HierarchicalCollectionView):void
		{
			var cursor:HierarchicalCollectionViewCursor = hcv.createCursor() as HierarchicalCollectionViewCursor;
			while(!cursor.afterLast)
			{
				hcv.openNode(cursor.current);
				cursor.moveNext();
			}
		}

        public function createSimpleNode(label:String):DataNode
		{
			var node:DataNode = new DataNode(label);
			_allNodes[UIDUtil.getUID(node)] = node;
            return node;
        }

		public function generateHierarchySourceFromString(source:String):ArrayCollection
		{
			var rootCollection:ArrayCollection = new ArrayCollection();
			var alreadyCreatedNodes:Array = [];
			var node:DataNode;
			
			var lines:Array = source.split("\n");
			for each(var line:String in lines)
			{
				if(!line)
					continue;
				
				var currentLabel:String = "";
				var previousNode:DataNode = null;
				var nodesOnThisLine:Array = StringUtil.trim(line).split("->");
				for each(var nodeName:String in nodesOnThisLine)
				{
					if(!nodeName)
						continue;
					
					currentLabel += currentLabel ? "->" + nodeName : nodeName;
					
					var nodeAlreadyCreated:Boolean = alreadyCreatedNodes[currentLabel] != undefined;
					
					if(nodeAlreadyCreated)
						node = alreadyCreatedNodes[currentLabel];
					else {
						node = createSimpleNode(currentLabel);
						alreadyCreatedNodes[currentLabel] = node;
					}
					
					if(!nodeAlreadyCreated) {
						if (previousNode)
							previousNode.addChild(node);
						else
							rootCollection.addItem(node);
					}
					
					previousNode = node;
				}
			}
			
			return rootCollection;
		}
	}
}