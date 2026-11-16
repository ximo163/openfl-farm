package mc.view.main.window.diy
{
   import com.minutes.ui.collections.LipiListChild;
   import common.MaterialLib;
   import flash.display.*;
   import flash.events.MouseEvent;
   import flash.net.URLRequest;
   import mc.control.ViewControl;
   import mc.events.TipEvent;
   import mc.model.DiyData;
   import mc.view.ViewEvent;
   import mc.view.farm.GetCropID;
   
   public class DiyItem extends LipiListChild
   {
      
      public static var CHILD_OVER:String = "childOver";
      
      public static var CHILD_OUT:String = "childOut";
      
      public static var CHILD_MOVE:String = "childMove";
      
      private var picLoader:Loader;
      
      private var diyUsedIcon:Sprite;
      
      private var line:Sprite = MaterialLib.getInstance().getMaterial("DiyLine") as Sprite;
      
      private var _used:Boolean = false;
      
      public function DiyItem()
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
         this.picLoader.load(new URLRequest(GetCropID.getShopDiyUrl(data["itemId"])));
         addChild(this.line);
         this.used = data["status"];
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
         var _loc3_:String = data["itemValidTime"] == 0 ? "无限期" : this.dateFormat(data["itemValidTime"]);
         _loc2_.tipArgument = _loc2_.tipArgument = data["itemName"] + "\n" + "到期时间：" + _loc3_;
         ViewControl.getInstance().dispatchEvent(_loc2_);
      }
      
      public function set used(param1:Boolean) : void
      {
         if(DiyData.getInstance().currentDiy)
         {
            return;
         }
         this._used = param1;
         if(this._used)
         {
            if(!this.diyUsedIcon)
            {
               this.diyUsedIcon = MaterialLib.getInstance().getMaterial("DiyUsedIcon") as Sprite;
            }
            addChild(this.diyUsedIcon);
         }
         else if(Boolean(this.diyUsedIcon) && contains(this.diyUsedIcon))
         {
            removeChild(this.diyUsedIcon);
         }
      }
      
      public function get used() : Boolean
      {
         return this._used;
      }
   }
}

