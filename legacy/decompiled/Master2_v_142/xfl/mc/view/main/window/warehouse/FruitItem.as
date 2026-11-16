package mc.view.main.window.warehouse
{
   import com.minutes.ui.collections.LipiListChild;
   import com.qzone.qfa.managers.LoadManager;
   import com.qzone.qfa.managers.events.LoaderEvent;
   import com.qzone.qui.controls.Label;
   import com.qzone.qui.styles.Style;
   import common.MaterialLib;
   import flash.display.Bitmap;
   import flash.display.MovieClip;
   import flash.display.Shape;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.text.TextFormatAlign;
   import mc.control.ViewControl;
   import mc.events.TipEvent;
   import mc.model.MData;
   import mc.model.MainData;
   import mc.view.ViewEvent;
   import mc.view.common.MaterialLoaderProxy;
   import mc.view.farm.GetCropID;
   
   public class FruitItem extends LipiListChild
   {
      
      public static var CHILD_OVER:String = "childOver";
      
      public static var CHILD_OUT:String = "childOut";
      
      public static var CHILD_MOVE:String = "childMove";
      
      private var lockIcon:MovieClip;
      
      private var amountText:TextField;
      
      public var _material:MaterialLoaderProxy;
      
      private var isFirstSetLock:Boolean = true;
      
      protected var _levelLabel:Label;
      
      public function FruitItem()
      {
         super();
         this.buttonMode = true;
         this.useHandCursor = true;
         this.amountText = new TextField();
         this.amountText.defaultTextFormat = new TextFormat("Arial",16,15886653,true,null,null,null,null,TextFormatAlign.CENTER);
         this.amountText.selectable = false;
         this.amountText.mouseEnabled = false;
         this.amountText.width = 61;
         this.amountText.height = 23;
         this.amountText.x = 0;
         this.amountText.y = 61;
         this.amountText.text = "20";
         addChild(this.amountText);
         var _loc1_:Shape = new Shape();
         _loc1_.graphics.beginFill(0,0);
         _loc1_.graphics.drawRect(0,0,10,1);
         _loc1_.graphics.endFill();
         _loc1_.y = 90;
         addChild(_loc1_);
         this._material = new MaterialLoaderProxy();
         addChild(this._material);
         addEventListener(MouseEvent.CLICK,this.onClick);
         addEventListener(MouseEvent.ROLL_OVER,this.onOver);
         addEventListener(MouseEvent.ROLL_OUT,this.onOut);
         this._levelLabel = new Label("");
         addChild(this._levelLabel);
         this._levelLabel.textField.defaultTextFormat = new TextFormat("Verdana",12,294944);
         this._levelLabel.textField.filters = Style.getTextGlowFilter();
         this._levelLabel.x = 0;
         this._levelLabel.y = this.height - 48;
         var _loc2_:MovieClip = MaterialLib.getInstance().getMaterial("SellLockIcon") as MovieClip;
         _loc2_.name = "LockIcon";
         addChild(_loc2_);
         var _loc3_:MainData = MData.getInstance().mainData;
         _loc3_.addEventListener(MainData.UNLOCK_LOCK_CROP,this.whenLockStatusChange);
         _loc3_.addEventListener(MainData.USER_MATERIAL_RELOAD,this.onUserMaterialReload);
         _loc2_ = getChildByName("LockIcon") as MovieClip;
      }
      
      private function onLoadCompete(param1:Event) : void
      {
      }
      
      private function whenLockStatusChange(param1:Event = null) : void
      {
         if(this.lockIcon)
         {
            this.lockIcon.gotoAndStop(Boolean(data["lock"]) || Boolean(data["isLock"]) ? "lock" : "unlock");
         }
      }
      
      private function onClick(param1:MouseEvent) : void
      {
         var _loc2_:ViewEvent = new ViewEvent(ViewEvent.CHILD_CLICK,true);
         _loc2_.data = data;
         dispatchEvent(_loc2_);
      }
      
      private function onOut(param1:MouseEvent) : void
      {
         var _loc2_:TipEvent = new TipEvent(TipEvent.TIP_HIDE);
         _loc2_.tipType = "MouseTip";
         ViewControl.getInstance().dispatchEvent(_loc2_);
      }
      
      private function onUserMaterialReload(param1:Event) : void
      {
         this.isFirstSetLock = true;
      }
      
      override public function set data(param1:Object) : void
      {
         var _loc4_:MainData = null;
         var _loc5_:LoadManager = null;
         var _loc6_:Bitmap = null;
         var _loc7_:MovieClip = null;
         super.data = param1;
         this.amountText.text = param1["amount"];
         if(param1["type"] == "11")
         {
            this._material.setContent("11",param1["cId"]);
         }
         else if(param1["type"] == "9")
         {
            this._material.setContent("wild_drop",param1["cId"],param1);
         }
         else
         {
            this._material.setContent("2",param1["cId"]);
         }
         if(data.hasOwnProperty("isvip"))
         {
            if(data["isvip"].toString() == "1")
            {
               _loc4_ = MData.getInstance().mainData;
               if(_loc4_.vipIcon == null)
               {
                  _loc5_ = new LoadManager();
                  _loc5_.add(GetCropID.getVipAnimalURL("VipIcon.png"));
                  _loc5_.addEventListener(LoaderEvent.COMPLETE,this.completeHandler);
                  _loc5_.start();
               }
               else
               {
                  _loc6_ = new Bitmap(_loc4_.vipIcon.bitmapData);
                  _loc6_.scaleX = _loc6_.scaleY = 0.7;
                  addChild(_loc6_);
               }
            }
         }
         if(Boolean(this._levelLabel) && param1["lv"] != undefined)
         {
            this._levelLabel.text = param1["lv"] + "级";
            addChild(this._levelLabel);
         }
         this.lockIcon = getChildByName("LockIcon") as MovieClip;
         addChild(this.lockIcon);
         if(param1["type"] == "11")
         {
            if(param1["isLock"] == "2")
            {
               data["isLock"] = 0;
            }
            else if(param1["isLock"] == "1")
            {
               data["isLock"] = 1;
            }
            else if(this.isFirstSetLock)
            {
               data["isLock"] = GetCropID.idToCardLockStatus(param1["cId"]);
            }
            else
            {
               data["isLock"] = 0;
            }
            this.isFirstSetLock = false;
         }
         if(this.lockIcon)
         {
            this.lockIcon.gotoAndStop(Boolean(param1["lock"]) || Boolean(param1["isLock"]) ? "lock" : "unlock");
         }
         var _loc2_:int = parseInt(param1["cId"]);
         var _loc3_:Boolean = false;
         if(_loc2_ > 10000)
         {
            _loc2_ -= 10000;
            _loc3_ = GetCropID.getActivity(_loc2_.toString());
         }
         else
         {
            _loc3_ = GetCropID.getActivity(_loc2_.toString(),true);
         }
         if(_loc3_)
         {
            _loc7_ = MaterialLib.getInstance().getMaterial("ActivityIcon") as MovieClip;
            addChild(_loc7_);
            _loc7_.x = 35;
            _loc7_.y = 0;
         }
      }
      
      private function completeHandler(param1:LoaderEvent) : void
      {
         var _loc2_:MainData = null;
         var _loc3_:Bitmap = null;
         if(param1.type == LoaderEvent.COMPLETE)
         {
            _loc2_ = MData.getInstance().mainData;
            _loc2_.vipIcon = param1.item.data as Bitmap;
            _loc3_ = new Bitmap(_loc2_.vipIcon.bitmapData);
            _loc3_.scaleX = _loc3_.scaleY = 0.7;
            addChild(_loc3_);
         }
      }
      
      private function onOver(param1:MouseEvent) : void
      {
         var _loc2_:TipEvent = new TipEvent(TipEvent.TIP_SHOW);
         _loc2_.tipType = "MouseTip";
         _loc2_.tipArgument = Boolean(data["lock"]) || Boolean(data["isLock"]) ? data["cName"] + " 已锁定不能卖出" : data["cName"];
         ViewControl.getInstance().dispatchEvent(_loc2_);
      }
   }
}

