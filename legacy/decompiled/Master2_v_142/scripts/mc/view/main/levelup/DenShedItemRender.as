package mc.view.main.levelup
{
   import common.MaterialLib;
   import flash.display.Loader;
   import flash.display.LoaderInfo;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.net.URLRequest;
   import mc.view.farm.GetCropID;
   
   public class DenShedItemRender extends Sprite
   {
      
      private var _ui:Sprite;
      
      private var _data:Object;
      
      public function DenShedItemRender(param1:Object)
      {
         super();
         this._data = param1;
         this._ui = MaterialLib.getInstance().getMaterial("Update.denShedRender") as Sprite;
         this.setData();
      }
      
      private function __onComplete(param1:Event) : void
      {
         var _loc2_:Loader = (param1.target as LoaderInfo).loader;
         var _loc3_:Sprite = this._ui["holder"];
         AlignUtils.scale_TO_Height_D(_loc2_,120);
         AlignUtils.align_BOTTOM_CENTER(_loc3_,_loc2_);
         _loc2_.x += _loc3_.x;
         _loc2_.y += _loc3_.y;
         this._ui.addChildAt(_loc2_,0);
      }
      
      private function setData() : void
      {
         var _loc1_:String = null;
         var _loc2_:String = null;
         if(this._data.level <= 8)
         {
            _loc2_ = ".jpg";
         }
         else
         {
            _loc2_ = ".png";
         }
         if(this._data.isDen)
         {
            _loc1_ = "up_w" + this._data.level + _loc2_;
         }
         else
         {
            _loc1_ = "up_p" + this._data.level + _loc2_;
         }
         var _loc3_:String = GetCropID.getSwfUrl() + "farm/diy/" + _loc1_;
         var _loc4_:Loader = new Loader();
         _loc4_.contentLoaderInfo.addEventListener(Event.COMPLETE,this.__onComplete,false,0,true);
         _loc4_.load(new URLRequest(_loc3_));
         if(this._data.isDen)
         {
            this._ui["denShedTxt"].htmlText = "<font color=\'#AA6D23\'>您可以升到第<font color=\'#FF6600\'>" + this._data.level + "</font>级窝</font>";
            if(this._data.level > 8)
            {
               this._ui["numChangeTxt"].text = this._data.level - 8 + "级科研";
            }
            else
            {
               this._ui["numChangeTxt"].text = "可饲养动物+" + this._data.addNum;
            }
         }
         else
         {
            this._ui["denShedTxt"].htmlText = "<font color=\'#AA6D23\'>您可以升到第<font color=\'#FF6600\'>" + this._data.level + "</font>级棚</font>";
            if(this._data.level > 8)
            {
               this._ui["numChangeTxt"].text = this._data.level - 8 + "级科研";
            }
            else
            {
               this._ui["numChangeTxt"].text = "可饲养动物+" + this._data.addNum;
            }
         }
         addChild(this._ui);
      }
   }
}

