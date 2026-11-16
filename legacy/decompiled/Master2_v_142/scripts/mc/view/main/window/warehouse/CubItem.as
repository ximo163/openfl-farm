package mc.view.main.window.warehouse
{
   import com.minutes.ui.collections.LipiListChild;
   import com.qzone.qui.controls.Label;
   import com.qzone.qui.styles.Style;
   import common.MaterialLib;
   import flash.display.MovieClip;
   import flash.display.Shape;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.text.TextFormatAlign;
   import mc.control.ViewControl;
   import mc.events.TipEvent;
   import mc.view.ViewEvent;
   import mc.view.common.MaterialLoaderProxy;
   import mc.view.farm.GetCropID;
   
   public class CubItem extends LipiListChild
   {
      
      public static var CHILD_OVER:String = "childOver";
      
      public static var CHILD_OUT:String = "childOut";
      
      public static var CHILD_MOVE:String = "childMove";
      
      private var amountText:TextField;
      
      public var _material:MaterialLoaderProxy;
      
      protected var _levelLabel:Label;
      
      public function CubItem()
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
         _loc2_.tipArgument = Boolean(data["lock"]) || Boolean(data["isLock"]) ? data["cName"] + " 已锁定不能卖出" : data["cName"];
         ViewControl.getInstance().dispatchEvent(_loc2_);
      }
      
      override public function set data(param1:Object) : void
      {
         var _loc4_:MovieClip = null;
         super.data = param1;
         this.amountText.text = param1["amount"];
         this._material.setContent("9",param1["cId"]);
         if(Boolean(this._levelLabel) && param1["lv"] != undefined)
         {
            this._levelLabel.text = param1["lv"] + "级";
            addChild(this._levelLabel);
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
            _loc4_ = MaterialLib.getInstance().getMaterial("ActivityIcon") as MovieClip;
            addChild(_loc4_);
            _loc4_.x = 35;
            _loc4_.y = 0;
         }
      }
   }
}

