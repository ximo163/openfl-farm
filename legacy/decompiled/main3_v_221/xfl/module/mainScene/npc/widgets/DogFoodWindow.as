package module.mainScene.npc.widgets
{
   import common.Consts;
   import common.Language;
   import common.misc.Utils;
   import common.view.window.AddButtonWindow;
   import entities.Item;
   import events.CommonEvent;
   import flash.display.Sprite;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.text.TextFormatAlign;
   import interfaces.IMsgCenter;
   import module.mainScene.npc.NPCController;
   import module.mainScene.npc.NPCView;
   import report.UserActionRecorder;
   
   public class DogFoodWindow extends AddButtonWindow
   {
      
      private var m_parent:NPCView;
      
      private var m_leftime:TextField;
      
      public function DogFoodWindow(param1:NPCView)
      {
         super(param1.controller.module.app as IMsgCenter);
         this.width = 400;
         this.height = 250;
         this.title = Language.L["狗狗粮食"];
         this.mode = true;
         this.m_parent = param1;
         this.m_leftime = null;
      }
      
      private function get controller() : NPCController
      {
         if(this.m_parent == null)
         {
            return null;
         }
         return this.m_parent.controller;
      }
      
      private function addFood() : void
      {
         super.close();
         var _loc1_:Item = new Item(null);
         _loc1_._id = 9002;
         _loc1_._type = 909090;
         _loc1_._name = "狗粮5送2礼包";
         _loc1_._desc = "一次性购买5天狗粮，可额外获赠2天狗粮，让狗狗为您看守农场一周。";
         _loc1_._effect = "";
         _loc1_._price = 0;
         _loc1_._fb = 20;
         _loc1_._yfb = 16;
         _loc1_._timeLimit = 0;
         _loc1_._saleOut = false;
         var _loc2_:* = this.controller.model.selfDogFood;
         if(_loc2_ != null && _loc2_["saleOut"] != undefined)
         {
            _loc1_._saleOut = _loc2_["saleOut"] as Boolean;
         }
         this.controller.module.app.dispatchEvent(new CommonEvent(Consts.MSG_SHOW_BUY_DOG_FOOD,_loc1_));
         UserActionRecorder.recordAction(UserActionRecorder.HF_DOGFOODWINDOW_BUY_CLICKED);
      }
      
      override protected function init() : void
      {
         var _loc5_:Sprite = null;
         var _loc6_:TextField = null;
         removeAllButton();
         addButton("购买狗粮","ButtonOrange",65,25,this.addFood);
         addButton(Language.L["取消"],"ButtonBlue",60,25,super.close);
         var _loc1_:String = "DogFoodNull";
         if(this.controller.model.dogHungry == 0)
         {
            _loc1_ = "DogFood";
         }
         var _loc2_:Sprite = Utils.getMaterial(_loc1_) as Sprite;
         addChild(_loc2_);
         _loc2_.x = 30;
         _loc2_.y = 70;
         addWindowChild(_loc2_);
         var _loc3_:Class = Utils.getClass("ItemBorder");
         var _loc4_:Sprite = new _loc3_() as Sprite;
         _loc5_ = new _loc3_() as Sprite;
         _loc4_.x = 20;
         _loc4_.y = 45;
         _loc5_.x = 20;
         _loc5_.y = 45;
         _loc4_.width = 120;
         _loc4_.height = 120;
         _loc5_.width = 120;
         _loc5_.height = 120;
         _loc2_.mask = _loc4_;
         addWindowChild(_loc4_);
         addWindowChild(_loc5_);
         _loc6_ = new TextField();
         _loc6_.height = 50;
         _loc6_.wordWrap = true;
         _loc6_.text = Language.L["剩余狗粮还可以给狗狗吃"];
         _loc6_.setTextFormat(new TextFormat("Verdana",14,3355443,false,null,null,null,null,TextFormatAlign.LEFT));
         _loc6_.width = 200;
         _loc6_.x = 170;
         _loc6_.y = 45;
         _loc6_.selectable = false;
         addWindowChild(_loc6_);
         this.m_leftime = new TextField();
         this.m_leftime.width = 200;
         this.m_leftime.x = 170;
         this.m_leftime.y = 80;
         this.m_leftime.selectable = false;
         this.m_leftime.wordWrap = true;
         this.m_leftime.multiline = true;
         addWindowChild(this.m_leftime);
         super.init();
      }
      
      override protected function setData() : void
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         if(this.m_leftime == null)
         {
            return;
         }
         this.graphics.clear();
         var _loc1_:Object = super.data;
         var _loc2_:String = "";
         if(_loc1_["hours"] != undefined)
         {
            _loc3_ = parseInt(_loc1_["hours"]);
            _loc4_ = int(_loc3_ / 24);
            _loc2_ = "<p align=\"left\"><font size=\"11\" face=\"Verdana\" color=\"#FF6600\"><b>" + _loc4_ + "</b></font> 天 <font  face=\"Verdana\" size=\"11\" color=\"#FF6600\"><b>" + _loc3_ % 24 + "</b></font> 小时 </font><br><br>";
            if(_loc3_ < 24)
            {
               _loc2_ += "<font size=\"14\" face=\"Verdana\" color=\"0x333333\">您的狗粮不足,赶紧购买吧!</font></p>";
            }
            else
            {
               _loc2_ += "<font size=\"14\" face=\"Verdana\" color=\"0x333333\">记得及时给自己的狗买狗粮！</font></p>";
            }
         }
         this.m_leftime.htmlText = _loc2_;
      }
   }
}

