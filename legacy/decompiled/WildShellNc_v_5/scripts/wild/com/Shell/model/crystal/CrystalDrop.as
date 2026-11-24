package wild.com.Shell.model.crystal
{
   public dynamic class CrystalDrop extends Array
   {
      
      public function CrystalDrop()
      {
         super();
      }
      
      public function parse(param1:Array) : void
      {
         var _loc2_:Object = null;
         for each(_loc2_ in param1)
         {
            push(_loc2_);
         }
      }
   }
}

