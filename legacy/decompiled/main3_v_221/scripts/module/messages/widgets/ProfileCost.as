package module.messages.widgets
{
   import com.qzone.qui.controls.Label;
   import com.qzone.qui.controls.TextArea;
   import com.qzone.qui.utils.TextFormatUtil;
   import common.Language;
   import common.Settings;
   import common.view.window.WindowLabelMaker;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.text.StyleSheet;
   import module.messages.MessageView;
   
   public class ProfileCost extends Sprite
   {
      
      private var _aLipiList:TextArea;
      
      private var _parent:MessageView;
      
      public function ProfileCost(param1:MessageView)
      {
         super();
         this._parent = param1;
         this._aLipiList = new TextArea();
         this._aLipiList.defaultSkin = null;
         this._aLipiList.selectedSkin = null;
         this._aLipiList.readOnly = true;
         this._aLipiList.width = 470;
         this._aLipiList.height = 190;
         this._aLipiList.x = 20;
         this._aLipiList.y = 20;
         addChild(this._aLipiList);
         var _loc2_:Shape = new Shape();
         _loc2_.graphics.lineStyle(1,16777215);
         _loc2_.graphics.moveTo(0,0);
         _loc2_.graphics.lineTo(490,0);
         _loc2_.y = 195;
         _loc2_.x = 3;
         addChild(_loc2_);
         this.addText();
      }
      
      public function set dataList(param1:Array) : void
      {
         var _loc3_:* = undefined;
         var _loc2_:String = "";
         for each(_loc3_ in param1)
         {
            _loc2_ += this.genMsg(_loc3_);
         }
         this._aLipiList.htmlText = "<textformat leading=\'8\'><font face=\'Verdana\'>" + _loc2_ + "</font></textformat>";
      }
      
      private function genMsg(param1:Object) : String
      {
         var _loc16_:int = 0;
         var _loc2_:String = "";
         var _loc3_:String = param1["msg"] as String;
         var _loc4_:String = param1["uid"];
         var _loc5_:String = param1["uin"];
         var _loc6_:Settings = Settings.getInstance();
         var _loc7_:String = "";
         var _loc8_:String = "";
         var _loc9_:String = "";
         var _loc10_:Array = ["","空间","校友"];
         if(_loc6_.mode == "qzone")
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
         var _loc11_:Date = new Date(parseFloat(param1["time"]) * 1000);
         var _loc12_:String = this.twoData(_loc11_.getHours());
         var _loc13_:String = this.twoData(_loc11_.getMinutes());
         var _loc14_:Date = new Date();
         var _loc15_:String = "";
         if(Language.lang == Language.CN)
         {
            _loc16_ = this.compareDate(_loc11_,new Date());
            if(_loc16_ == 0)
            {
               _loc15_ = "    " + Language.L["今天"] + _loc12_ + ":" + _loc13_;
            }
            else if(_loc16_ == 1)
            {
               _loc15_ = "    " + Language.L["昨天"] + _loc12_ + ":" + _loc13_;
            }
            else if(_loc16_ == 2)
            {
               _loc15_ = "    " + Language.L["前天"] + _loc12_ + ":" + _loc13_;
            }
            else
            {
               _loc15_ = this.twoData(_loc11_.getMonth() + 1) + "-" + this.twoData(_loc11_.getDate()) + " " + _loc12_ + ":" + _loc13_;
            }
         }
         else
         {
            _loc15_ = this.twoData(_loc11_.getMonth() + 1) + "-" + this.twoData(_loc11_.getDate()) + " " + _loc12_ + ":" + _loc13_;
         }
         return "<b>" + _loc15_ + "</b>  " + _loc8_ + "<br>";
      }
      
      private function compareDate(param1:Date, param2:Date) : int
      {
         param1 = new Date(param1.getFullYear(),param1.getMonth(),param1.getDate());
         param2 = new Date(param2.getFullYear(),param2.getMonth(),param2.getDate());
         var _loc3_:int = Math.abs(param2.getTime() - param1.getTime());
         return _loc3_ / 86400000;
      }
      
      private function twoData(param1:int) : String
      {
         if(param1 < 10)
         {
            return "0" + param1.toString();
         }
         return param1.toString();
      }
      
      private function addText() : void
      {
         var _loc1_:Label = new Label();
         _loc1_.mouseChildren = true;
         _loc1_.width = width + 3;
         WindowLabelMaker.addTarget(_loc1_);
         _loc1_.textDefaultFormat = TextFormatUtil.clone(_loc1_.textDefaultFormat);
         _loc1_.textDefaultFormat.color = 11171584;
         _loc1_.text = "";
         _loc1_.x = 2;
         addChild(_loc1_);
         var _loc2_:StyleSheet = new StyleSheet();
         _loc2_.parseCSS("a:link{} a:hover{text-decoration:underline;}");
         _loc1_.textField.styleSheet = _loc2_;
      }
   }
}

