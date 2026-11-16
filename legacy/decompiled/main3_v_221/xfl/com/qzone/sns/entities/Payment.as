package com.qzone.sns.entities
{
   import flash.utils.getTimer;
   
   public final class Payment
   {
      
      public static var BILL_SEQ:uint = 1;
      
      public var _stamp:int;
      
      public var callback:Function;
      
      public var num:int;
      
      public var bill:int;
      
      public var shopType:int;
      
      public var misc:Object;
      
      public var type:int;
      
      public var id:int;
      
      public function Payment(param1:uint, param2:int, param3:uint, param4:int)
      {
         super();
         this.bill = BILL_SEQ++;
         this.misc = null;
         this.callback = null;
         this.id = param1;
         this.type = param2;
         this.shopType = param4;
         this.num = param3;
         this._stamp = getTimer();
      }
      
      public static function nextSeq() : uint
      {
         return BILL_SEQ++;
      }
      
      public function notify(param1:int, param2:Boolean, param3:*) : void
      {
         if(this.callback != null)
         {
            this.callback(param1,param2,this,param3);
         }
      }
      
      public function buildCheckParams() : Object
      {
         return {
            "clientBill":this.bill,
            "itemId":this.id,
            "itemType":this.type,
            "itemNum":this.num,
            "shopType":this.shopType
         };
      }
   }
}

