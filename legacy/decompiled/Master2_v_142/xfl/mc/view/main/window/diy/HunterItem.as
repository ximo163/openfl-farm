package mc.view.main.window.diy
{
   import com.minutes.ui.collections.LipiListChild;
   import common.MaterialLib;
   import flash.display.*;
   import flash.events.MouseEvent;
   import flash.net.URLRequest;
   import mc.control.ViewControl;
   import mc.events.TipEvent;
   import mc.view.ViewEvent;
   import mc.view.farm.GetCropID;
   
   public class HunterItem extends LipiListChild
   {
      
      public static var CHILD_OVER:String = "childOver";
      
      public static var CHILD_OUT:String = "childOut";
      
      public static var CHILD_MOVE:String = "childMove";
      
      private var picLoader:Loader;
      
      private var diyUsedIcon:Sprite;
      
      private var _used:Boolean = false;
      
      public function HunterItem()
      {
         super();
         this.buttonMode = true;
         this.useHandCursor = true;
         addEventListener(MouseEvent.CLICK,this.onClick);
         addEventListener(MouseEvent.ROLL_OVER,this.onOver);
         addEventListener(MouseEvent.ROLL_OUT,this.onOut);
         var _loc1_:Shape = new Shape();
         _loc1_.graphics.beginFill(16711680,0);
         _loc1_.graphics.drawRect(0,0,10,1);
         _loc1_.graphics.endFill();
         _loc1_.y = 100;
         addChild(_loc1_);
      }
      
      private function doubleString(param1:int) : String
      {
         if(param1 < 10)
         {
            return "0" + param1;
         }
         return param1.toString();
      }
      
      private function dateFormat(param1:int) : String
      {
         var _loc2_:Date = new Date(param1 * 1000);
         return this.doubleString(_loc2_.getFullYear()) + "-" + this.doubleString(_loc2_.getMonth() + 1) + "-" + this.doubleString(_loc2_.getDate()) + " ";
      }
      
      private function onClick(param1:MouseEvent) : void
      {
         var _loc2_:ViewEvent = new ViewEvent(ViewEvent.CHILD_CLICK,true);
         _loc2_.data = data;
         dispatchEvent(_loc2_);
      }
      
      private function expireTime() : String
      {
         var _loc1_:Date = null;
         var _loc2_:String = null;
         if(data.hasOwnProperty("expireTime"))
         {
            _loc1_ = new Date(data["expireTime"] * 1000);
            return "\n到期时间：" + _loc1_.getFullYear() + "年" + (_loc1_.getMonth() + 1) + "月" + _loc1_.getDate() + "日";
         }
         return "";
      }
      
      private function onOut(param1:MouseEvent) : void
      {
         var _loc2_:TipEvent = new TipEvent(TipEvent.TIP_HIDE);
         _loc2_.tipType = "MouseTip";
         ViewControl.getInstance().dispatchEvent(_loc2_);
      }
      
      private function onOver(param1:MouseEvent) : void
      {
         var _loc2_:TipEvent = new TipEvent(TipEvent.TIP_SHOW);
         _loc2_.tipType = "MouseTip";
         _loc2_.tipArgument = data["itemName"] + this.expireTime();
         ViewControl.getInstance().dispatchEvent(_loc2_);
      }
      
      public function set used(param1:Boolean) : void
      {
         this._used = param1;
         if(this._used)
         {
            if(!this.diyUsedIcon)
            {
               this.diyUsedIcon = MaterialLib.getInstance().getMaterial("DiyUsedIcon2") as Sprite;
            }
            addChild(this.diyUsedIcon);
         }
         else if(Boolean(this.diyUsedIcon) && contains(this.diyUsedIcon))
         {
            removeChild(this.diyUsedIcon);
         }
      }
      
      override public function set data(param1:Object) : void
      {
         if(!param1)
         {
            return;
         }
         super.data = param1;
         if(this.picLoader)
         {
            this.picLoader.unload();
            this.picLoader = null;
         }
         this.picLoader = new Loader();
         addChild(this.picLoader);
         this.picLoader.load(new URLRequest(GetCropID.getHunterPicUrl(data["itemId"])));
         this.used = data["status"];
      }
      
      public function get used() : Boolean
      {
         return this._used;
      }
   }
}

