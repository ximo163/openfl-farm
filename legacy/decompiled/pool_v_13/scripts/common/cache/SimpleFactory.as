package common.cache
{
   public class SimpleFactory implements IObjectPoolFactory
   {
      
      private var _class:Class;
      
      public function SimpleFactory(param1:Class)
      {
         super();
         this._class = param1;
      }
      
      public function create() : *
      {
         if(this._class == null)
         {
            return null;
         }
         return new this._class();
      }
   }
}

