package mc.view.main.window.profile
{
   import com.minutes.ui.control.LipiTextArea;
   import common.LocalData;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.text.TextField;
   import flash.text.TextFieldType;
   import flash.text.TextFormat;
   import mc.control.Command;
   import mc.model.MData;
   import mc.model.MainData;
   import mc.view.ViewEvent;
   import mc.view.common.DataLoading;
   
   public class ProfileCost extends Sprite
   {
      
      private var mainData:MainData;
      
      private var costArr:Array;
      
      private const FN_MILL_COST:int = 1;
      
      public var requireReload:Boolean = true;
      
      private var dataLoading:DataLoading;
      
      private var aLipiList:LipiTextArea;
      
      private var bGetFarmAnimalCost:Boolean;
      
      private var bGetMillCost:Boolean;
      
      private const FN_FARM_ANIMAL_COST:int = 0;
      
      public function ProfileCost()
      {
         super();
         this.addEventListener(Event.ADDED_TO_STAGE,this.init);
         this.aLipiList = new LipiTextArea();
         this.aLipiList.bgAlpha = 0;
         this.aLipiList.vLipiScrollBar.visible = false;
         this.aLipiList.width = 470;
         this.aLipiList.height = 190;
         this.aLipiList.x = 20;
         this.aLipiList.y = 20;
         this.aLipiList.type = TextFieldType.DYNAMIC;
         addChild(this.aLipiList);
         var _loc1_:Shape = new Shape();
         _loc1_.graphics.lineStyle(1,16777215);
         _loc1_.graphics.moveTo(0,0);
         _loc1_.graphics.lineTo(490,0);
         _loc1_.y = 195;
         _loc1_.x = 3;
         addChild(_loc1_);
         this.mainData = MData.getInstance().mainData;
         this.dataLoading = new DataLoading();
         this.dataLoading.addEventListener(ViewEvent.LINK_CLICK,this.linkClick);
         this.dataLoading.visible = this.mainData.profileLoading;
         this.dataLoading.x = width / 2;
         this.dataLoading.y = height / 2;
         addChild(this.dataLoading);
         var _loc2_:TextField = new TextField();
         var _loc3_:TextFormat = new TextFormat("Verdana",12,8999699,null,null,null,null,null,"center");
         _loc2_.backgroundColor = 16777176;
         _loc2_.background = true;
         _loc2_.width = 493;
         _loc2_.height = 18;
         _loc2_.selectable = false;
         addChild(_loc2_);
         _loc2_.defaultTextFormat = _loc3_;
         _loc2_.htmlText = "";
      }
      
      private function setGetCost() : void
      {
         this.costArr = [];
         this.bGetFarmAnimalCost = false;
         this.bGetMillCost = false;
      }
      
      private function compareDate(param1:Date, param2:Date) : int
      {
         param1 = new Date(param1.getFullYear(),param1.getMonth(),param1.getDate());
         param2 = new Date(param2.getFullYear(),param2.getMonth(),param2.getDate());
         var _loc3_:int = Math.abs(param2.getTime() - param1.getTime());
         return _loc3_ / 3600 / 24 / 1000;
      }
      
      private function init(param1:Event) : void
      {
         if(this.requireReload)
         {
            this.dataLoading.visible = true;
            this.setGetCost();
            Command.getInstance().mainCommand.getCostInfo(this.getCostInfoFn1,this.getCostInfoFn2);
         }
      }
      
      private function genMsg(param1:Object) : String
      {
         var _loc8_:String = null;
         var _loc12_:String = null;
         var _loc2_:String = "";
         var _loc3_:String = String(param1["msg"]);
         var _loc4_:String = param1["uid"];
         var _loc5_:String = param1["uin"];
         var _loc6_:Array = MData.getInstance().mainData.friendList;
         var _loc7_:String = "";
         var _loc9_:String = "";
         var _loc10_:Array = ["","空间","校友"];
         if(LocalData.mode == "qzone")
         {
            _loc10_[1] = "";
         }
         else
         {
            _loc10_[2] = "";
         }
         if(param1.hasOwnProperty("domain"))
         {
            _loc9_ = _loc10_[param1["domain"]];
         }
         _loc8_ = _loc9_ + _loc3_;
         var _loc11_:Date = new Date(Number(param1["time"]) * 1000);
         var _loc13_:String = this.twoData(_loc11_.getHours());
         var _loc14_:String = this.twoData(_loc11_.getMinutes());
         if(this.compareDate(_loc11_,new Date()) == 0)
         {
            _loc12_ = "    " + "今天" + _loc13_ + ":" + _loc14_;
         }
         else if(this.compareDate(_loc11_,new Date()) == 1)
         {
            _loc12_ = "    " + "昨天" + _loc13_ + ":" + _loc14_;
         }
         else if(this.compareDate(_loc11_,new Date()) == 2)
         {
            _loc12_ = "    " + "前天" + _loc13_ + ":" + _loc14_;
         }
         else
         {
            _loc12_ = this.twoData(_loc11_.getMonth() + 1) + "-" + this.twoData(_loc11_.getDate()) + " " + _loc13_ + ":" + _loc14_;
         }
         return "<b>" + _loc12_ + "</b>  " + _loc8_ + "<br>";
      }
      
      private function twoData(param1:int) : String
      {
         if(param1 < 10)
         {
            return "0" + String(param1);
         }
         return String(param1);
      }
      
      public function set dataList(param1:Array) : void
      {
         var _loc3_:Object = null;
         var _loc2_:String = "";
         for each(_loc3_ in param1)
         {
            _loc2_ += this.genMsg(_loc3_);
         }
         this.aLipiList.htmlText = "<textformat leading=\'8\'><font face=\'Verdana\'>" + _loc2_ + "</font></textformat>";
         if(this.aLipiList.textField.numLines > 9)
         {
            this.aLipiList.vLipiScrollBar.visible = true;
         }
         else
         {
            this.aLipiList.vLipiScrollBar.visible = false;
         }
      }
      
      private function getCostInfoFn1(param1:Object) : void
      {
         this.getCostInfoFn(param1,this.FN_FARM_ANIMAL_COST);
      }
      
      private function setCostInfo() : void
      {
         if(this.bGetFarmAnimalCost && this.bGetMillCost)
         {
            this.requireReload = false;
            this.dataLoading.visible = false;
            this.costArr.sortOn("time",Array.DESCENDING);
            this.dataList = this.costArr;
         }
      }
      
      private function getCostInfoFn2(param1:Object) : void
      {
         this.getCostInfoFn(param1,this.FN_MILL_COST);
      }
      
      private function linkClick(param1:ViewEvent) : void
      {
         if(param1.data == "reload")
         {
            this.dataLoading.visible = true;
            this.setGetCost();
            Command.getInstance().mainCommand.getCostInfo(this.getCostInfoFn1,this.getCostInfoFn2);
         }
      }
      
      private function getCostInfoFn(param1:Object, param2:int) : void
      {
         if(param1["code"] == 1)
         {
            if(this.FN_FARM_ANIMAL_COST == param2)
            {
               this.bGetFarmAnimalCost = true;
            }
            else if(this.FN_MILL_COST == param2)
            {
               this.bGetMillCost = true;
            }
            if(!param1["cost"])
            {
               param1["cost"] = [];
            }
            this.costArr = this.costArr.concat(param1["cost"]);
            this.setCostInfo();
         }
         else
         {
            this.dataLoading.errorText = "请求超时，" + "<a href=\'event:reload\'><u><font color=\'#ff6600\'>点击重试</font></u></a>";
         }
      }
   }
}

