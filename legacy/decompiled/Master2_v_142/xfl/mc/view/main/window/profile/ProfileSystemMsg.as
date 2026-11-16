package mc.view.main.window.profile
{
   import com.minutes.ui.control.LipiTextArea;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.text.TextFieldType;
   import mc.control.ViewControl;
   import mc.model.MainData;
   import mc.view.common.DataLoading;
   
   public class ProfileSystemMsg extends Sprite
   {
      
      private var mainData:MainData;
      
      private var _log:LipiTextArea;
      
      private var dataLoading:DataLoading;
      
      public function ProfileSystemMsg()
      {
         super();
         this._log = new LipiTextArea();
         this._log.bgAlpha = 0;
         this._log.width = 465;
         this._log.height = 190;
         this._log.x = 20;
         this._log.y = 2;
         this._log.type = TextFieldType.DYNAMIC;
         this._log.vLipiScrollBar.visible = false;
         addChild(this._log);
         this.dataLoading = new DataLoading();
         this.dataLoading.x = this._log.width / 2;
         this.dataLoading.y = this._log.height / 2;
         addChild(this.dataLoading);
         ViewControl.getInstance().addEventListener("SystemMsgLoadFailed",this.onLoadedFailed);
      }
      
      private function onLoadedFailed(param1:Event) : void
      {
         this.dataLoading.errorText = "请求超时，" + "<a href=\'event:reload\'><u><font color=\'#ff6600\'>点击重试</font></u></a>";
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
         if(this._log.textField.numLines > 9)
         {
            this._log.vLipiScrollBar.visible = true;
         }
         else
         {
            this._log.vLipiScrollBar.visible = false;
         }
      }
      
      private function genMsg(param1:Object) : String
      {
         var _loc9_:String = null;
         var _loc2_:String = "";
         var _loc3_:String = param1["words"] as String;
         var _loc4_:String = "";
         var _loc5_:String = "";
         var _loc6_:String = "";
         var _loc7_:String = param1["color"] || "#DD0000";
         if(param1.hasOwnProperty("opnick") && param1["opnick"] != "")
         {
            _loc6_ = "<font color=\'" + _loc7_ + "\'><b>" + param1["opnick"] + "</b></font>：";
         }
         _loc5_ = _loc6_ + _loc3_;
         var _loc8_:Date = new Date(Number(param1["time"]) * 1000);
         var _loc10_:String = this.twoData(_loc8_.getHours());
         var _loc11_:String = this.twoData(_loc8_.getMinutes());
         if(this.compareDate(_loc8_,new Date()) == 0)
         {
            _loc9_ = "    " + "今天" + _loc10_ + ":" + _loc11_;
         }
         else if(this.compareDate(_loc8_,new Date()) == 1)
         {
            _loc9_ = "    " + "昨天" + _loc10_ + ":" + _loc11_;
         }
         else if(this.compareDate(_loc8_,new Date()) == 2)
         {
            _loc9_ = "    " + "前天" + _loc10_ + ":" + _loc11_;
         }
         else
         {
            _loc9_ = this.twoData(_loc8_.getMonth() + 1) + "-" + this.twoData(_loc8_.getDate()) + " " + _loc10_ + ":" + _loc11_;
         }
         return "<b>" + _loc9_ + "</b>  " + _loc5_ + "<br>";
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
   }
}

