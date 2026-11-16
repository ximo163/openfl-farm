package mc.view.main.leftInfo.FlopGift
{
   import mc.model.MData;
   import mc.view.main.WindowControl.WControl;
   
   public class FlopGiftControl
   {
      
      public static const HAVEFLOPDATA:String = "haveFlopData";
      
      public static const FLOPDATA:String = "flopData";
      
      public static const FLOP_ICON_CLICK:String = "flopIconClick";
      
      public static const FLOP_ITEM_CLICK:String = "flopItemClick";
      
      public static const FLOP_GET_DATE:String = "flopGetDate";
      
      public static const FLOP_CGI_GIFT:String = "flopCgiGift";
      
      public static const LAST_FLOP_TIME:String = "lastFlopTime";
      
      private var _flopData:FlopGiftData;
      
      private var host:Object;
      
      public function FlopGiftControl()
      {
         super();
         this._flopData = FlopGiftData.gi();
      }
      
      public function hasFlopToWin(param1:int) : void
      {
         this.host = MData.getInstance().mainData.host;
         if(this.host["yellowstatus"] == 0)
         {
            this._flopData.flopTime = FlopGiftData.SINGLE_FLOP_NUM - param1;
         }
         else
         {
            this._flopData.flopTime = FlopGiftData.YELLOW_FLOP_NUM - param1;
         }
         if(this._flopData.flopTime > 0 || this._flopData.flopGetGift != 0)
         {
            this.showFlopWindow();
         }
      }
      
      private function showFlopWindow() : void
      {
         var _loc1_:FlopGiftWindow = new FlopGiftWindow();
         WControl.open(_loc1_);
      }
      
      public function hasFlopTime(param1:int) : void
      {
         this.host = MData.getInstance().mainData.host;
         if(this.host["yellowstatus"] == 0)
         {
            this._flopData.flopTime = FlopGiftData.SINGLE_FLOP_NUM - param1;
         }
         else
         {
            this._flopData.flopTime = FlopGiftData.YELLOW_FLOP_NUM - param1;
         }
      }
   }
}

