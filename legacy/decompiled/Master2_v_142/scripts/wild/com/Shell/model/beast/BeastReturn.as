package wild.com.Shell.model.beast
{
   public dynamic class BeastReturn extends Array
   {
      
      public function BeastReturn()
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

