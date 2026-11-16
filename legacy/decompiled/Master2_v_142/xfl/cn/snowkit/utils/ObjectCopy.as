package cn.snowkit.utils
{
   import flash.utils.ByteArray;
   
   public class ObjectCopy
   {
      
      public function ObjectCopy()
      {
         super();
      }
      
      public static function copy(param1:Object) : Object
      {
         var _loc2_:ByteArray = new ByteArray();
         _loc2_.writeObject(param1);
         _loc2_.position = 0;
         return _loc2_.readObject();
      }
   }
}

