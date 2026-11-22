package module.water
{
   import com.qzone.corelib.net.RSLManager;
   import com.qzone.utils.AlignUtil;
   import common.Consts;
   import common.GetCropID;
   import common.misc.Utils;
   import common.view.window.BaseWindow;
   import entities.PoolFish;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import interfaces.IMsgCenter;
   
   public class PoolInfoWindow extends BaseWindow
   {
      
      private var _infoContent:MovieClip;
      
      public function PoolInfoWindow(param1:IMsgCenter)
      {
         super(param1);
         title = "池塘详情";
         width = 360;
         height = 244;
         windowName = "PoolInfo";
         mode = true;
         this.createWindowContent();
      }
      
      override protected function setSize() : void
      {
         super.setSize();
         panelTitle.x = AlignUtil.middle(_width,panelTitle.width);
      }
      
      private function onLoaded(param1:Array) : void
      {
         if(param1 == null || param1.length != 2)
         {
            return;
         }
         var _loc2_:String = param1[0];
         var _loc3_:DisplayObjectContainer = param1[1];
         if(_loc2_ == null || _loc3_ == null || _loc2_ == "")
         {
            return;
         }
         var _loc4_:Sprite = Utils.getMaterial(_loc2_) as Sprite;
         if(_loc4_ == null)
         {
            return;
         }
         this.graphics.clear();
         _loc4_.x = 2;
         _loc4_.scaleX = _loc4_.scaleY = 34 / _loc4_.width;
         _loc4_.y = (40 - _loc4_.height) * 0.5;
         _loc4_.name = "__fish_icon__";
         _loc3_.addChild(_loc4_);
      }
      
      private function groupFishes(param1:Array) : Array
      {
         var _loc4_:PoolFish = null;
         var _loc5_:* = undefined;
         var _loc6_:* = undefined;
         var _loc2_:Array = [];
         var _loc3_:Boolean = false;
         for each(_loc4_ in param1)
         {
            _loc3_ = false;
            for each(_loc5_ in _loc2_)
            {
               if(_loc4_._type == _loc5_["type"])
               {
                  ++_loc5_["num"];
                  _loc3_ = true;
               }
            }
            if(_loc3_ == false)
            {
               _loc6_ = {
                  "type":_loc4_._type,
                  "name":_loc4_.name,
                  "size":_loc4_.poolSize,
                  "num":1
               };
               _loc6_["icon"] = GetCropID.getFishUrl(_loc6_["type"],true);
               _loc2_.push(_loc6_);
            }
         }
         return _loc2_;
      }
      
      override protected function addedToLayer() : void
      {
         super.addedToLayer();
         if(this._infoContent != null)
         {
            this._infoContent.x = AlignUtil.middle(_width,this._infoContent.width);
            this._infoContent.y = panelTitle.height;
         }
      }
      
      override protected function setData() : void
      {
         var _loc9_:* = undefined;
         var _loc10_:String = null;
         var _loc1_:Object = super.data;
         if(_loc1_ == null)
         {
            return;
         }
         var _loc2_:Array = _loc1_["fishes"] as Array;
         if(_loc2_ == null || _loc2_.length == 0)
         {
            if(this._infoContent != null)
            {
               this._infoContent.gotoAndStop(4);
            }
            this.reset();
            return;
         }
         var _loc3_:Array = this.groupFishes(_loc2_);
         if(_loc3_ == null || _loc3_.length == 0)
         {
            return;
         }
         var _loc4_:int = 0;
         var _loc5_:DisplayObjectContainer = null;
         var _loc6_:DisplayObject = null;
         var _loc7_:RSLManager = RSLManager.getInstance();
         var _loc8_:int = 0;
         for each(_loc9_ in _loc3_)
         {
            _loc5_ = this._infoContent["item" + _loc4_] as DisplayObjectContainer;
            if(_loc5_ != null)
            {
               _loc5_["tfName"].text = _loc9_["name"];
               _loc5_["tfNum"].text = _loc9_["num"];
               _loc5_["tfSize"].text = _loc9_["num"] * _loc9_["size"];
               _loc8_ += _loc9_["num"] * _loc9_["size"];
               if(_loc9_["icon"] != undefined && _loc9_["icon"] != "")
               {
                  _loc10_ = "Fish_" + _loc9_["type"];
                  _loc7_.requestClass(_loc10_,this.onLoaded,_loc9_["icon"],[_loc10_,_loc5_]);
               }
               _loc5_.visible = true;
               _loc4_++;
            }
         }
         this._infoContent["tfSize"].text = _loc8_ + "/" + Consts.FISH_MAX_SIZE;
         if(_loc4_ == 6)
         {
            this._infoContent.gotoAndStop(1);
            height = 244 + 3 * 45;
         }
         else if(_loc4_ == 5)
         {
            this._infoContent.gotoAndStop(2);
            height = 244 + 2 * 45;
         }
         else if(_loc4_ == 4)
         {
            this._infoContent.gotoAndStop(3);
            height = 244 + 1 * 45;
         }
         else
         {
            this._infoContent.gotoAndStop(4);
            height = 244;
         }
      }
      
      private function createWindowContent() : void
      {
         this._infoContent = Utils.getMaterial("PoolInfoContent") as MovieClip;
         this._infoContent.name = "PoolInfoContent";
         this._infoContent.gotoAndPlay(4);
         addChild(this._infoContent);
         this.reset();
      }
      
      private function reset() : void
      {
         if(this._infoContent == null)
         {
            return;
         }
         this._infoContent["tfSize"].text = "0/0";
         var _loc1_:DisplayObjectContainer = null;
         var _loc2_:DisplayObject = null;
         var _loc3_:int = 0;
         while(_loc3_ < 6)
         {
            _loc1_ = this._infoContent["item" + _loc3_] as DisplayObjectContainer;
            if(_loc1_ != null)
            {
               _loc1_["tfName"].text = "";
               _loc1_["tfNum"].text = "";
               _loc1_["tfSize"].text = "";
               _loc2_ = _loc1_.getChildByName("__fish_icon__");
               if(_loc2_ != null)
               {
                  _loc1_.removeChild(_loc2_);
               }
               _loc1_.visible = false;
            }
            _loc3_++;
         }
      }
   }
}

