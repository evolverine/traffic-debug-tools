package com.sohnar.traffic.util.debugging
{
	import com.adobe.cairngorm.contract.Contract;
	
	import mx.core.IVisualElement;
	import mx.core.IVisualElementContainer;
	import mx.core.mx_internal;
	
	import spark.components.Group;
	import spark.components.Scroller;

	public class VisualElementInfiltrator
	{
		private var _root:IVisualElementContainer;
		
		public function VisualElementInfiltrator(rootElement:IVisualElementContainer)
		{
			_root = rootElement;
		}
		
		
		public function infiltrate(newMXMLContent:Array, findFunction:Function, factoryFunction:Function):Array
		{
			Contract.precondition(newMXMLContent != null && findFunction != null && factoryFunction != null);
			
			var existingElementAndItsParent:Array = findElementAndParent(newMXMLContent, findFunction);
			if(!existingElementAndItsParent)
				return null;
			
			var existingElement:IVisualElement = existingElementAndItsParent[0];
			var dgParent:Group = existingElementAndItsParent[1];

			var infiltratedElement:IVisualElement = factoryFunction(existingElement, dgParent);
			
			var infiltratedMXML:Array = generateInfiltratedMXML(dgParent, existingElement, infiltratedElement);
			if(!infiltratedMXML)
				return null;
			
			if(dgParent == _root)
				throw new InfiltrationError(infiltratedMXML);
			
			dgParent.mxmlContent = infiltratedMXML;
				
			return infiltratedMXML;
		}
		
		public function findElementAndParent(newMXMLContent:Array, criteriaFunction:Function):Array
		{
			return findElementAndParentImpl(newMXMLContent, criteriaFunction, _root);
		}
		
		public function generateInfiltratedMXML(parent:Group, real:IVisualElement, fake:IVisualElement):Array
		{
			var infiltratedMXML:Array = parent.mx_internal::getMXMLContent();
			var index:int = infiltratedMXML.indexOf(real);
			if(index == -1)
				return null;
			
			infiltratedMXML.splice(index, 1, fake);
			return infiltratedMXML;
		}
		
		private function findElementAndParentImpl(mxmlContent:Array, findFunction:Function, theParent:IVisualElementContainer):Array
		{
			Contract.precondition(findFunction != null);
			
			for each(var component:IVisualElement in mxmlContent)
			{
				if(findFunction(component))
					return [component, theParent];
				
				while(component is Scroller)
				{
					component = Scroller(component).viewport;
				}
				
				if(component is Group)
				{
					var dgAndParent:Array = findElementAndParentImpl(Group(component).mx_internal::getMXMLContent(), findFunction, Group(component));
					if(dgAndParent)
						return dgAndParent;
				}
			}
			
			return null;
		}
	}
}