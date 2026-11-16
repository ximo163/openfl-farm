package module.messages.widgets
{
   import com.qzone.qui.controls.TextArea;
   import common.Language;
   import common.Session;
   import common.Settings;
   import flash.display.Shape;
   import flash.display.Sprite;
   import module.messages.MessageView;
   
   public class ProfileSystemMsg extends Sprite
   {
      
      private var _log:TextArea;
      
      private var _parent:MessageView;
      
      public function ProfileSystemMsg(param1:MessageView)
      {
         super();
         this._parent = param1;
         var _loc2_:Shape = new Shape();
         _loc2_.graphics.lineStyle(1,16777215);
         _loc2_.graphics.moveTo(0,0);
         _loc2_.graphics.lineTo(490,0);
         _loc2_.y = 195;
         _loc2_.x = 3;
         addChild(_loc2_);
         this._log = new TextArea();
         this._log.width = 470;
         this._log.height = 190;
         this._log.x = 20;
         this._log.y = 2;
         this._log.defaultSkin = null;
         this._log.selectedSkin = null;
         this._log.readOnly = true;
         addChild(this._log);
      }
      
      public function set dataList(param1:Array) : void
      {
         var _loc3_:* = undefined;
         var _loc2_:String = "";
         for each(_loc3_ in param1)
         {
            _loc2_ += this.genMsg(_loc3_);
         }
         this._log.htmlText = "<textformat leading=\'8\'><font face=\'Verdana\'>" + _loc2_ + "</font></textformat>";
      }
      
      private function genMsg(param1:Object) : String
      {
         var _loc13_:int = 0;
         var _loc2_:String = "";
         var _loc3_:String = param1["words"] as String;
         var _loc4_:String = "";
         var _loc5_:String = "";
         var _loc6_:Settings = Settings.getInstance();
         var _loc7_:Session = Session.getInstance();
         var _loc8_:String = param1["color"] || "#DD0000";
         if(param1.hasOwnProperty("opnick") && param1["opnick"] != "")
         {
            _loc5_ = "<font color=\'" + _loc8_ + "\'><b>" + param1["opnick"] + "</b></font>：";
         }
         _loc4_ = _loc5_ + _loc3_;
         var _loc9_:Date = new Date(parseFloat(param1["time"]) * 1000);
         var _loc10_:String = this.twoData(_loc9_.getHours());
         var _loc11_:String = this.twoData(_loc9_.getMinutes());
         var _loc12_:String = "";
         if(Language.lang == Language.CN)
         {
            _loc13_ = this.compareDate(_loc9_,new Date());
            if(_loc13_ == 0)
            {
               _loc12_ = "    " + Language.L["今天"] + _loc10_ + ":" + _loc11_;
            }
            else if(_loc13_ == 1)
            {
               _loc12_ = "    " + Language.L["昨天"] + _loc10_ + ":" + _loc11_;
            }
            else if(_loc13_ == 2)
            {
               _loc12_ = "    " + Language.L["前天"] + _loc10_ + ":" + _loc11_;
            }
            else
            {
               _loc12_ = this.twoData(_loc9_.getMonth() + 1) + "-" + this.twoData(_loc9_.getDate()) + " " + _loc10_ + ":" + _loc11_;
            }
         }
         else
         {
            _loc12_ = this.twoData(_loc9_.getMonth() + 1) + "-" + this.twoData(_loc9_.getDate()) + " " + _loc10_ + ":" + _loc11_;
         }
         return "<b>" + _loc12_ + "</b>  " + _loc4_ + "<br>";
      }
      
      private function twoData(param1:int) : String
      {
         if(param1 < 10)
         {
            return "0" + param1.toString();
         }
         return param1.toString();
      }
      
      private function compareDate(param1:Date, param2:Date) : int
      {
         param1 = new Date(param1.getFullYear(),param1.getMonth(),param1.getDate());
         param2 = new Date(param2.getFullYear(),param2.getMonth(),param2.getDate());
         var _loc3_:int = Math.abs(param2.getTime() - param1.getTime());
         return _loc3_ / 86400000;
      }
   }
}

