package entities
{
   import common.misc.Utils;
   
   public final class AdItem
   {
      
      public var _img:String;
      
      public var _rl:String;
      
      public var _acurl:String;
      
      public function AdItem(param1:Object)
      {
         super();
         this.importObject(param1);
      }
      
      public function importFromCache(param1:Object) : void
      {
         if(param1 == null)
         {
            return;
         }
         this._img = param1._img;
         this._rl = param1._rl;
         this._acurl = param1._acurl;
      }
      
      public function importObject(param1:Object) : void
      {
         if(param1 == null)
         {
            return;
         }
         this._img = Utils.getStrAttribute(param1,"img");
         this._rl = Utils.getStrAttribute(param1,"rl");
         this._acurl = Utils.getStrAttribute(param1,"acurl");
      }
   }
}

