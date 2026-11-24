package com.qzone.allianceActivity.arborDayActivity.model
{
   import com.qzone.allianceActivity.AllianceActivityAssetInfo;
   import com.qzone.allianceActivity.AllianceActivityInfo;
   
   public class ArborDayActivityConfig extends AllianceActivityInfo
   {
      
      public var exchangeSuccessMsg:String;
      
      public var exchangeFaultMsg:String;
      
      public var detailLinkUrl:String = "";
      
      public var presentBagScore:int = 400;
      
      public var presentBagQpoint:int = 100;
      
      public var iconTips:String = "";
      
      public var getPresentSuccessMsg:String;
      
      public var getPresentFaultMsg:String;
      
      public function ArborDayActivityConfig()
      {
         super();
      }
      
      public function getAssetUrl(param1:String) : String
      {
         var _loc2_:AllianceActivityAssetInfo = null;
         if(Boolean(this.assets) && Boolean(this.assets.length))
         {
            for each(_loc2_ in this.assets)
            {
               if(_loc2_.id == param1)
               {
                  return _loc2_.src;
               }
            }
         }
         return "";
      }
      
      public function parserConfigNode() : void
      {
         var _loc1_:XML = this.source.config[0];
         this.exchangeSuccessMsg = _loc1_.exchangeSuccessMsg;
         this.exchangeFaultMsg = _loc1_.exchangeFaultMsg;
         this.getPresentSuccessMsg = _loc1_.getPresentSuccessMsg;
         this.getPresentFaultMsg = _loc1_.getPresentFaultMsg;
         this.detailLinkUrl = _loc1_.detailLink;
         this.iconTips = _loc1_.iconTips;
         this.presentBagScore = parseInt(_loc1_.presentBagScore);
         this.presentBagQpoint = parseInt(_loc1_.presentBagQpoint);
      }
   }
}

