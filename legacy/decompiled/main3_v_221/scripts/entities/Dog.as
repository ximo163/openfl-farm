package entities
{
   import common.misc.Utils;
   
   public final class Dog
   {
      
      public var _isHungry:int;
      
      public var _dogId:int;
      
      public var _validTime:int;
      
      public function Dog(param1:Object)
      {
         super();
         this.importObject(param1);
      }
      
      public function importObject(param1:Object) : void
      {
         if(param1 == null)
         {
            return;
         }
         this._dogId = Utils.getIntAttribute(param1,"dogId");
         this._isHungry = Utils.getIntAttribute(param1,"isHungry");
         this._validTime = Utils.getIntAttribute(param1,"validTime");
      }
   }
}

