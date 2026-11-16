package mc.view.main.leftInfo.FlopGift
{
   import com.minutes.ui.control.LipiButton;
   import com.minutes.ui.core.LipiSkin;
   import common.INI;
   import common.MaterialLib;
   import flash.display.DisplayObject;
   import flash.display.Loader;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import flash.text.TextFormatAlign;
   import mc.view.common.BaseWindow;
   import mc.view.common.MaterialLoaderProxy;
   import mc.view.farm.toolBar.ToolBase;
   import mc.view.main.tip.TipControl;
   
   public class FlopCardsGift extends BaseWindow
   {
      
      private var _data:Object;
      
      public function FlopCardsGift()
      {
         super();
         this.width = 400;
         this.height = 250;
         this.titleIMG = MaterialLib.getInstance().getClass("AlertWindowTitle") as Class;
      }
      
      private function setPhoto(param1:int) : void
      {
         var iniData:XML = null;
         var i:int = 0;
         var _material:DisplayObject = null;
         var id:int = param1;
         iniData = INI.getInstance().data.flopGifts[0];
         var toolbase:ToolBase = new ToolBase();
         _material = new (MaterialLib.getInstance().getClass(iniData.gift.(@id == id).@cla) as Class)();
         toolbase.addChild(_material);
         addChild(toolbase);
         toolbase.tipText = iniData.gift.(@id == id).@name;
         toolbase.x = this.width / 2 - _material.height / 2;
         toolbase.y = this.height - _material.height - 65;
         toolbase.buttonMode = true;
         toolbase.addEventListener(MouseEvent.ROLL_OVER,this.RollOver);
         toolbase.addEventListener(MouseEvent.ROLL_OUT,this.RollOut);
      }
      
      private function RollOver(param1:MouseEvent) : void
      {
         TipControl.show("MouseTip",(param1.currentTarget as ToolBase).tipText);
      }
      
      private function setButton() : void
      {
         var _loc1_:LipiButton = new LipiButton();
         _loc1_.bgAlpha = 0;
         _loc1_.bgSkin = new LipiSkin(MaterialLib.getInstance().getClass("ButtonOrange"));
         _loc1_.width = 64;
         _loc1_.height = 25;
         _loc1_.x = width / 2 - _loc1_.width / 2;
         _loc1_.y = height - 45;
         _loc1_.label = "确定";
         _loc1_.textColor = 16777215;
         _loc1_.addEventListener(MouseEvent.CLICK,this.confirmButtonClick);
         addChild(_loc1_);
      }
      
      private function confirmButtonClick(param1:MouseEvent) : void
      {
         this.closeHandler();
      }
      
      public function set dataList(param1:Object) : void
      {
         this._data = param1;
         this.setText(this._data.text);
         this.setPhoto(this._data.sid);
         this.setButton();
      }
      
      private function RollOut(param1:MouseEvent) : void
      {
         TipControl.hide();
      }
      
      private function addGiftPhoto(param1:int) : MaterialLoaderProxy
      {
         var _loc3_:DisplayObject = null;
         var _loc2_:MaterialLoaderProxy = new MaterialLoaderProxy();
         if(_loc2_.numChildren > 1)
         {
            _loc3_ = _loc2_.getChildAt(1) as DisplayObject;
            if(_loc3_ is Loader)
            {
               (_loc3_ as Loader).unload();
            }
            _loc2_.removeChild(_loc3_);
            _loc3_ = null;
         }
         _loc2_.setContent("1",param1);
         return _loc2_;
      }
      
      private function setText(param1:String) : void
      {
         var _loc2_:TextField = null;
         _loc2_ = new TextField();
         _loc2_.x = 25;
         _loc2_.y = 55;
         _loc2_.autoSize = TextFieldAutoSize.LEFT;
         _loc2_.width = 350;
         _loc2_.text = param1;
         _loc2_.setTextFormat(new TextFormat("Verdana",15,7426359,null,null,null,null,null,TextFormatAlign.LEFT));
         _loc2_.wordWrap = true;
         addChild(_loc2_);
      }
   }
}

