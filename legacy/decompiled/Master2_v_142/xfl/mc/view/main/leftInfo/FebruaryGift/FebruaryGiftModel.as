package mc.view.main.leftInfo.FebruaryGift
{
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import mc.FBridge.EventRecorder;
   
   public class FebruaryGiftModel extends EventDispatcher
   {
      
      private static var intence:FebruaryGiftModel;
      
      private var _febController:FebruaryGiftControl;
      
      public var canClickIcon:Boolean = true;
      
      public var isBuy9:Boolean = false;
      
      public function FebruaryGiftModel(param1:IEventDispatcher = null)
      {
         super(param1);
         this._febController = new FebruaryGiftControl();
      }
      
      public static function gi() : FebruaryGiftModel
      {
         if(intence == null)
         {
            intence = new FebruaryGiftModel();
         }
         return intence;
      }
      
      public function febIconClick(param1:String) : void
      {
         switch(param1)
         {
            case "__febicon1__":
               this._febController.openWindow1();
               EventRecorder.recordSueecssEvent(EventRecorder.FEBRUARY_GIFT1_CLICK,0,null,10);
               break;
            case "__febicon2__":
               this._febController.openWindow2();
               EventRecorder.recordSueecssEvent(EventRecorder.FEBRUARY_GIFT2_CLICK,0,null,10);
         }
      }
   }
}

