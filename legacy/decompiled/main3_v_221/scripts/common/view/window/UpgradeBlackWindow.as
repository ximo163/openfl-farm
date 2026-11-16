package common.view.window
{
   import com.qzone.utils.AlignUtil;
   import common.Language;
   import common.misc.QzoneJSAPI;
   import common.misc.Utils;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import interfaces.IMsgCenter;
   
   public class UpgradeBlackWindow extends BaseWindow
   {
      
      private var _shareContent:MovieClip;
      
      public function UpgradeBlackWindow(param1:IMsgCenter)
      {
         super(param1);
         autoLayout = true;
         windowName = "BlackUpgradeShare";
         title = "";
         mode = true;
         this._shareContent = Utils.getMaterial("BlackUpgradeShare") as MovieClip;
         this._shareContent.gotoAndStop(1);
         width = this._shareContent.width + marginL + marginR - 12;
         height = this._shareContent.height + marginT + marginB - 140;
         this._shareContent.x = marginL - 2;
         this._shareContent.y = marginT + 7;
         addChild(this._shareContent);
         if(this._shareContent["btnShare"] != undefined)
         {
            this._shareContent["btnShare"].addEventListener(MouseEvent.CLICK,this.onShare,false,0,true);
         }
         if(this._shareContent["btnCancel"] != undefined)
         {
            this._shareContent["btnCancel"].addEventListener(MouseEvent.CLICK,super.onClose,false,0,true);
         }
      }
      
      private function onShare(param1:MouseEvent) : void
      {
         var _loc2_:int = 21 + data["place"];
         var _loc3_:* = {
            "place":this.data["place"] + 1,
            "rank":this.data["rank"],
            "stat":_loc2_
         };
         var _loc4_:String = "";
         if(data["place"] == 0)
         {
            _loc4_ = Language.replaceText("BlackUpShare1",_loc3_);
         }
         else
         {
            _loc4_ = Language.replaceText("BlackUpShare2",_loc3_);
         }
         var _loc5_:String = "mod=cgi_qzshare_onekey";
         _loc5_ = _loc5_ + ("url=" + encodeURIComponent("" + _loc2_));
         _loc5_ = _loc5_ + ("&desc=" + encodeURIComponent(""));
         _loc5_ = _loc5_ + ("&summary=" + encodeURIComponent(_loc4_));
         _loc5_ = _loc5_ + ("&title=" + encodeURIComponent("点击进农场>>升级黑土地"));
         _loc5_ = _loc5_ + ("&site=" + encodeURIComponent("QQ农场升级黑土地"));
         _loc5_ = _loc5_ + ("&pics=" + encodeURIComponent("module/ui/icons/blackland.jpg"));
         QzoneJSAPI.openWindow(_loc5_);
         super.close();
      }
      
      private function formatNumber(param1:uint) : String
      {
         if(param1 == 0)
         {
            return "";
         }
         var _loc2_:String = param1.toString();
         var _loc3_:uint = uint(_loc2_.length);
         if(_loc3_ > 8)
         {
            _loc2_ = _loc2_.slice(0,_loc3_ - 8) + "," + _loc2_.slice(_loc3_ - 8,_loc3_);
         }
         if(_loc3_ > 4)
         {
            _loc3_ = uint(_loc2_.length);
            _loc2_ = _loc2_.slice(0,_loc3_ - 4) + "," + _loc2_.slice(_loc3_ - 4,_loc3_);
         }
         return _loc2_;
      }
      
      override protected function setSize() : void
      {
         super.setSize();
         panelTitle.x = AlignUtil.middle(_width,panelTitle.width);
      }
      
      override protected function setData() : void
      {
         this.graphics.clear();
         super.setData();
         if(this._shareContent != null)
         {
            if(this.data["place"] == 0)
            {
               this._shareContent.gotoAndStop(1);
            }
            else
            {
               this._shareContent.gotoAndStop(2);
            }
            if(this._shareContent["tfNum"] != undefined)
            {
               this._shareContent["tfNum"].text = this.formatNumber(this.data["rank"]);
            }
            if(this._shareContent["tfPlace"] != undefined)
            {
               this._shareContent["tfPlace"].text = this.data["place"] + 1;
            }
         }
      }
   }
}

