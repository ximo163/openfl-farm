package mc.model
{
   public class DiyData
   {
      
      private static var instance:DiyData;
      
      public var currentDiy:Boolean = false;
      
      public function DiyData()
      {
         super();
      }
      
      public static function getInstance() : DiyData
      {
         if(instance == null)
         {
            instance = new DiyData();
         }
         return instance;
      }
   }
}

