package module.shop.widgets
{
   import com.qzone.qui.controls.Label;
   import com.qzone.qui.controls.scrollClasses.ScrollPolicy;
   import common.Language;
   import common.view.window.WindowLabelMaker;
   import flash.display.DisplayObjectContainer;
   import flash.display.Sprite;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import framework.base.BasePage;
   
   public class DiyPage extends BasePage
   {
      
      private var _top:int = 22;
      
      public function DiyPage(param1:DisplayObjectContainer, param2:int, param3:int)
      {
         super(param1,param2,param3);
         this.addText();
      }
      
      private function addline() : Sprite
      {
         var _loc1_:Sprite = new Sprite();
         _loc1_.graphics.beginFill(16777215,1);
         _loc1_.graphics.drawRect(0,0,this.width - 4,1);
         _loc1_.graphics.endFill();
         addChild(_loc1_);
         return _loc1_;
      }
      
      private function initTitle() : void
      {
         var _loc1_:TextField = null;
         var _loc3_:TextField = null;
         _loc1_ = this.addChildTitle(Language.L["背景"]);
         _loc1_.selectable = false;
         _loc1_.x = 5;
         _loc1_.y = this._top;
         var _loc2_:TextField = this.addChildTitle(Language.L["房子"]);
         _loc2_.selectable = false;
         _loc2_.x = 115;
         _loc2_.y = this._top;
         _loc3_ = this.addChildTitle(Language.L["狗窝"]);
         _loc3_.selectable = false;
         _loc3_.x = 346;
         _loc3_.y = this._top;
         var _loc4_:TextField = this.addChildTitle(Language.L["栅栏"]);
         _loc4_.selectable = false;
         _loc4_.x = 235;
         _loc4_.y = this._top;
         var _loc5_:Sprite = this.addline();
         _loc5_.x = 2;
         _loc5_.y = this._top + 20;
      }
      
      override protected function onCreateTile() : void
      {
         if(_tile != null)
         {
            _tile.tileWidth = 105;
            _tile.tileHeight = 120;
            _tile.paddingH = 30;
            _tile.itemRenderer = DiyItem;
            _tile.y = this._top + 21;
            _tile.height = 285;
            _tile.width = 495;
            _tile.defaultSkin = null;
            _tile.horizontalScrollPolicy = ScrollPolicy.OFF;
         }
      }
      
      private function addChildTitle(param1:String) : TextField
      {
         var _loc2_:TextField = new TextField();
         _loc2_.text = param1;
         _loc2_.setTextFormat(new TextFormat("Verdana",14,3355443,null,null,null,null,null,"center"));
         _loc2_.width = 100;
         _loc2_.height = 25;
         addChild(_loc2_);
         return _loc2_;
      }
      
      private function addText() : void
      {
         var _loc1_:Label = new Label(Language.L["diyTileDirection"]);
         _loc1_.width = 500 - 4;
         _loc1_.x = 1;
         WindowLabelMaker.addTarget(_loc1_);
         addChild(_loc1_);
         this.initTitle();
      }
   }
}

