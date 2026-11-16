package entities
{
   import common.misc.Utils;
   
   public final class Weather
   {
      
      public var _weatherId:int;
      
      public var _weatherDesc:String;
      
      public function Weather(param1:*)
      {
         super();
         this.importObject(param1);
      }
      
      public function importObject(param1:*) : void
      {
         if(param1 == null)
         {
            return;
         }
         this._weatherDesc = Utils.getStrAttribute(param1,"weatherDesc");
         this._weatherId = Utils.getIntAttribute(param1,"weatherId");
      }
   }
}

