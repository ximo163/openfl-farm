package module.messages.widgets
{
   import common.Consts;
   import common.Language;
   import common.misc.Utils;
   import common.view.tip.Tip;
   import flash.display.Sprite;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   
   public class HistoryItemTip extends Tip
   {
      
      private var _tipBg:Sprite;
      
      private var _text1:TextField;
      
      private var _text2:TextField;
      
      private var _cName:TextField;
      
      private var _label2:TextField;
      
      public function HistoryItemTip()
      {
         var _loc1_:TextField = null;
         super();
         _tipName = Consts.TIP_NAME_PROFILE_HISTORY;
         this._tipBg = Utils.getMaterial("TipBg") as Sprite;
         this._tipBg.width = 140;
         this._tipBg.height = 70;
         this._tipBg.x = -20;
         this._tipBg.y = 15;
         addChild(this._tipBg);
         this._cName = new TextField();
         this._cName.x = -5;
         this._cName.y = 20;
         this._cName.width = 90;
         this._cName.height = 22;
         this._cName.defaultTextFormat = new TextFormat("Verdana",14,3355443,true);
         this._cName.text = "";
         addChild(this._cName);
         _loc1_ = new TextField();
         _loc1_.autoSize = TextFieldAutoSize.LEFT;
         _loc1_.x = -10;
         _loc1_.y = 45;
         _loc1_.height = 22;
         _loc1_.defaultTextFormat = new TextFormat("Verdana",12,3355443);
         _loc1_.text = Language.L["累计收获:"];
         addChild(_loc1_);
         var _loc2_:TextField = new TextField();
         _loc2_.autoSize = TextFieldAutoSize.LEFT;
         _loc2_.x = -10;
         _loc2_.y = 60;
         _loc2_.width = 90;
         _loc2_.height = 22;
         _loc2_.defaultTextFormat = new TextFormat("Verdana",12,3355443);
         _loc2_.text = Language.L["累计偷窃:"];
         addChild(_loc2_);
         this._label2 = _loc2_;
         this._text1 = new TextField();
         this._text1.x = _loc1_.x + _loc1_.width + 3;
         this._text1.y = 45;
         this._text1.width = 90;
         this._text1.height = 22;
         this._text1.defaultTextFormat = new TextFormat("Verdana",12,3355443);
         this._text1.text = "111";
         addChild(this._text1);
         this._text2 = new TextField();
         this._text2.x = _loc2_.x + _loc2_.width + 3;
         this._text2.y = 60;
         this._text2.width = 90;
         this._text2.height = 22;
         this._text2.defaultTextFormat = new TextFormat("Verdana",12,3355443);
         this._text2.text = "111";
         addChild(this._text2);
      }
      
      override public function set data(param1:Object) : void
      {
         super.data = param1;
         if(param1 == null)
         {
            param1 = "";
         }
         this._cName.text = param1["cName"];
         if(param1["harvestNumber"] != undefined)
         {
            this._text1.text = param1["harvestNumber"];
            this._text2.text = param1["scroungeNumber"];
            this._label2.text = Language.L["累计偷窃:"];
         }
         else
         {
            this._text1.text = param1["hn"];
            this._text2.text = param1["sn"];
            this._label2.text = "累计摘取:";
         }
      }
      
      override public function set mX(param1:Number) : void
      {
         super.mX = param1;
         x = param1 - 5;
      }
      
      override public function set mY(param1:Number) : void
      {
         super.mY = param1;
         y = param1 + 15;
      }
   }
}

