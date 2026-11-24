package plugins.external.fairy
{
   import common.CommonData;
   import common.misc.Cookies;
   import events.CommonEvent;
   import flash.display.MovieClip;
   import flash.events.EventDispatcher;
   import flash.events.MouseEvent;
   
   public class ReBuyWindowWrapper extends EventDispatcher
   {
      
      private var _selected:int;
      
      private var _showFlag:Object;
      
      private var _price:int;
      
      private var _winCls:Class = ReBuyWindowWrapper__winCls;
      
      private var _firstShow:Boolean;
      
      private var _win:MovieClip;
      
      private var _control:FairyPlugin;
      
      public function ReBuyWindowWrapper(param1:FairyPlugin)
      {
         super(null);
         this._control = param1;
         this._selected = 0;
         this._price = 600;
         this._firstShow = true;
         this._showFlag = null;
      }
      
      public function hide() : void
      {
         this._control.api.hidePopUp(this._win);
         this._control.callProxy(2009,false);
      }
      
      public function show(param1:int, param2:int, param3:String, param4:int) : void
      {
         if(param1 < 0 || param1 > 3)
         {
            return;
         }
         if(this.canShow == false)
         {
            return;
         }
         if(param3 == "" || param3 == null)
         {
            param3 = "农场玩家";
         }
         var _loc5_:int = param1 == 3 ? 750 : 600;
         if(param4 == 1)
         {
            this._price = _loc5_ * 0.4;
         }
         else if(param4 == 2)
         {
            this._price = _loc5_ * 0.5;
         }
         else if(param4 == 3)
         {
            this._price = _loc5_ * 0.6;
         }
         else if(param4 == 4)
         {
            this._price = _loc5_ * 0.8;
         }
         if(this._win == null)
         {
            this._win = new this._winCls() as MovieClip;
            this._win["btn0"].gotoAndStop(2);
            this._win["btn0"].mouseChildren = false;
            this._win["btn0"].buttonMode = true;
            this._selected = 0;
            this._win["tfPrice"].text = this._price.toString();
            this._win["tfPrice1"].text = int(this._price * 0.8).toString();
            this._win["btn1"].stop();
            this._win["btn1"].mouseChildren = false;
            this._win["btn1"].buttonMode = true;
            this._win["btn2"].stop();
            this._win["btn2"].mouseChildren = false;
            this._win["btn2"].buttonMode = true;
            this._win.addEventListener(MouseEvent.CLICK,this.onClicked,false,0,true);
         }
         this._win["tfDay"].text = param2.toString();
         this._win["tfUserName"].text = param3 + "：";
         this._win.gotoAndStop(param1 + 1);
         this._control.api.showPopUp(this._win,true);
         this._firstShow = false;
         var _loc6_:uint = this._control.friends.hostId;
         if(this._showFlag == null)
         {
            this._showFlag = {};
         }
         this._showFlag[_loc6_] = {"st":CommonData.serverTime};
         Cookies.setObject("ReBug_Flag",this._showFlag,0,true);
      }
      
      private function get canShow() : Boolean
      {
         if(this._showFlag == null)
         {
            this._showFlag = Cookies.getObject("ReBug_Flag") as Object;
         }
         var _loc1_:uint = this._control.friends.hostId;
         if(this._showFlag != null && this._showFlag[_loc1_] != undefined && this._control.model.isSameDay(this._showFlag[_loc1_]["st"] as Number) == true)
         {
            return false;
         }
         return this._firstShow;
      }
      
      private function onClicked(param1:MouseEvent) : void
      {
         var _loc2_:int = 0;
         if(param1.target.name == "btn0")
         {
            this._win["btn0"].gotoAndStop(2);
            this._win["btn1"].gotoAndStop(1);
            this._win["btn2"].gotoAndStop(1);
            this._selected = 0;
            this._win["tfPrice"].text = this._price.toString();
            this._win["tfPrice1"].text = int(this._price * 0.8).toString();
         }
         else if(param1.target.name == "btn1")
         {
            this._win["btn0"].gotoAndStop(1);
            this._win["btn1"].gotoAndStop(2);
            this._win["btn2"].gotoAndStop(1);
            this._selected = 1;
            this._win["tfPrice"].text = int(this._price * 6).toString();
            this._win["tfPrice1"].text = int(this._price * 6 * 0.8).toString();
         }
         else if(param1.target.name == "btn2")
         {
            this._win["btn0"].gotoAndStop(1);
            this._win["btn1"].gotoAndStop(1);
            this._win["btn2"].gotoAndStop(2);
            this._selected = 2;
            this._win["tfPrice"].text = int(this._price * 12).toString();
            this._win["tfPrice1"].text = int(this._price * 12 * 0.8).toString();
         }
         else if(param1.target.name == "btnOK")
         {
            this.hide();
            _loc2_ = 1;
            if(this._selected == 0)
            {
               _loc2_ = 1;
            }
            else if(this._selected == 1)
            {
               _loc2_ = 6;
            }
            else
            {
               _loc2_ = 12;
            }
            dispatchEvent(new CommonEvent("buy",{
               "index":this._win.currentFrame - 1,
               "month":_loc2_
            }));
         }
         else if(param1.target.name == "btnCancel")
         {
            this.hide();
         }
         param1.stopImmediatePropagation();
      }
   }
}

