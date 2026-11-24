package module.cardsgame
{
   import com.qzone.utils.DisplayUtil;
   import common.Settings;
   import common.misc.Utils;
   import common.view.MaterialProxy;
   import events.ViewEvent;
   import flash.display.SimpleButton;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.filters.GlowFilter;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.text.TextFormatAlign;
   
   public class CardsGameWindowItem extends Sprite
   {
      
      public static const CHILD_CLICK:String = "childClick";
      
      public static const CHILD_OUT:String = "childOut";
      
      public static const CHILD_OVER:String = "childOver";
      
      private var _giftName:String = "";
      
      protected var _material:MaterialProxy;
      
      private var _num:String = "";
      
      protected var _mask:Sprite;
      
      private var _storeName:String = "";
      
      private var _btn:SimpleButton;
      
      private var _per:String = "";
      
      private var _numTxt:TextField;
      
      protected var _bg:Sprite;
      
      protected var _item:Object;
      
      public function CardsGameWindowItem()
      {
         super();
         buttonMode = true;
         useHandCursor = true;
         mouseChildren = true;
         this._material = new MaterialProxy(MaterialProxy.CARDSGAME);
         this._material.x = 5;
         this._material.y = 1;
         addChild(this._material);
         this._bg = null;
         this._mask = null;
         this._item = null;
         this._btn = null;
         this.registerListeners();
      }
      
      public function returnTips(param1:Boolean) : String
      {
         var _loc2_:String = "";
         if(param1)
         {
            _loc2_ = this._num + this._per + this._giftName + "，已放入您的" + this._storeName;
         }
         else
         {
            _loc2_ = this._num + this._per + this._giftName + "，继续努力，明天再来试试吧！";
         }
         return _loc2_;
      }
      
      public function setMatetialContent(param1:String) : void
      {
         addChild(this._material);
         var _loc2_:Object = Settings.getInstance().getCardsGameReward(param1);
         var _loc3_:String = _loc2_["type"];
         var _loc4_:int = parseInt(_loc2_["cId"]);
         this._material.setContent(_loc3_,_loc4_);
         this._giftName = _loc2_["name"];
         this._storeName = _loc2_["store"];
         this._num = _loc2_["num"];
         this._per = _loc2_["per"];
         var _loc5_:TextFormat = new TextFormat();
         _loc5_.align = TextFormatAlign.CENTER;
         _loc5_.size = 16;
         _loc5_.bold = true;
         _loc5_.font = "方正粗圆简体";
         this._numTxt = new TextField();
         this._numTxt.textColor = 4358144;
         this._numTxt.defaultTextFormat = _loc5_;
         this._numTxt.x = 14;
         this._numTxt.y = 53;
         this._numTxt.selectable = false;
         this._numTxt.filters = [new GlowFilter(16447723,1,3,3,5,1)];
         addChild(this._numTxt);
         this._numTxt.htmlText = "×" + this._num;
      }
      
      private function onOver(param1:MouseEvent) : void
      {
         var _loc2_:ViewEvent = new ViewEvent(CHILD_OVER,true);
         _loc2_.data = this._item;
         dispatchEvent(_loc2_);
      }
      
      public function addTurnOverBg(param1:int) : void
      {
         if(this._bg != null)
         {
            return;
         }
         if(param1 == 1)
         {
            this._bg = Utils.getMaterial("TurnOverBg1") as Sprite;
         }
         else
         {
            this._bg = Utils.getMaterial("TurnOverBg2") as Sprite;
         }
         DisplayUtil.removeChild(this,this._btn);
         addChild(this._bg);
      }
      
      protected function registerListeners() : void
      {
         addEventListener(MouseEvent.CLICK,this.onClick,false,0,true);
         addEventListener(MouseEvent.MOUSE_OVER,this.onOver,false,0,true);
         addEventListener(MouseEvent.ROLL_OUT,this.onOut,false,0,true);
      }
      
      public function get data() : Object
      {
         return this._item;
      }
      
      private function onOut(param1:MouseEvent) : void
      {
         var _loc2_:ViewEvent = new ViewEvent(CHILD_OUT,true);
         _loc2_.data = this._item;
         dispatchEvent(_loc2_);
      }
      
      private function onClick(param1:MouseEvent) : void
      {
         var _loc2_:ViewEvent = new ViewEvent(CHILD_CLICK,true);
         _loc2_.data = this._item;
         dispatchEvent(_loc2_);
      }
      
      public function addButton() : void
      {
         if(this._btn != null)
         {
            return;
         }
         this._btn = new SimpleButton();
         var _loc1_:Sprite = Utils.getMaterial("BoxButton_1") as Sprite;
         var _loc2_:Sprite = Utils.getMaterial("BoxButton_2") as Sprite;
         this._btn.upState = _loc1_;
         this._btn.overState = _loc2_;
         this._btn.downState = _loc2_;
         this._btn.hitTestState = _loc2_;
         addChild(this._btn);
      }
   }
}

