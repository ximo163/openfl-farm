package mc.view.main.friend
{
   import common.MaterialLib;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.Graphics;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.*;
   import flash.filters.ColorMatrixFilter;
   import flash.geom.Matrix;
   import flash.net.URLRequest;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import mc.api.BeastAPI;
   import mc.control.Command;
   import mc.control.ViewControl;
   import mc.events.TipEvent;
   import mc.model.MData;
   import mc.model.MainData;
   import mc.view.ViewEvent;
   import mc.view.main.cursor.Cursor;
   import wild.com.Shell.command.CmdAPI;
   
   public class Friend extends Sprite
   {
      
      private var status_mc:MovieClip;
      
      private var _selected:Boolean = false;
      
      private var mainData:MainData;
      
      private var _friendData:Object = null;
      
      private var loader:Loader;
      
      private var _vipLevelMaterial:String = "VipL";
      
      private var vip:Sprite;
      
      private var _isme:Boolean = false;
      
      private var highlight:Sprite;
      
      private var hasMC:Boolean = true;
      
      private var _vipLevel:int = 0;
      
      private var leveBg:Sprite;
      
      private var listItem:Sprite;
      
      private var nc_btn:Sprite;
      
      private var _icon:String;
      
      private var userIcon:Sprite;
      
      private var leve:TextField;
      
      private var _vipStatus:int = 0;
      
      private var userName:TextField;
      
      private var _userLevel:int = 0;
      
      public function Friend()
      {
         super();
         this.buttonMode = true;
         this.listItem = MaterialLib.getInstance().getMaterial("List_Item") as Sprite;
         this.highlight = this.listItem.getChildByName("highLight_mc") as Sprite;
         this.userName = this.listItem.getChildByName("name_txt") as TextField;
         this.userIcon = this.listItem.getChildByName("head_mc") as Sprite;
         this.leve = this.listItem.getChildByName("level_txt") as TextField;
         this.leveBg = this.listItem.getChildByName("level_mc") as Sprite;
         this.vip = this.listItem.getChildByName("vip_mc") as Sprite;
         this.status_mc = this.listItem.getChildByName("status_mc") as MovieClip;
         this.nc_btn = this.listItem.getChildByName("nc_btn") as Sprite;
         this.mainData = MData.getInstance().mainData;
         this.highlight.mouseEnabled = false;
         this.leveBg.mouseEnabled = false;
         this.userIcon.mouseEnabled = false;
         this.userIcon.mouseChildren = false;
         this.leve.mouseEnabled = false;
         this.userName.mouseEnabled = false;
         this.userName.selectable = false;
         this.status_mc.mouseChildren = false;
         this.addChild(this.listItem);
         this.addEventListener(MouseEvent.MOUSE_OVER,this._MOUSE_OVER);
         this.addEventListener(MouseEvent.MOUSE_OUT,this._MOUSE_OUT);
         this.addEventListener(MouseEvent.CLICK,this.dispatchData);
         this.mainData.addEventListener(MainData.HEAD_UPDATE,this.onHeadChange);
         this.mainData.addEventListener(MainData.MARK_UPDATE,this.onMarkUpdate);
      }
      
      private function changBg(param1:MouseEvent) : void
      {
         if(!this._selected)
         {
            this.highlight.alpha = 0.5;
         }
      }
      
      public function get fiendData() : Object
      {
         return this._friendData;
      }
      
      public function get vipStatus() : int
      {
         return this._vipStatus;
      }
      
      private function drawG(param1:Graphics, param2:BitmapData, param3:Matrix = null) : void
      {
         param1.clear();
         param1.beginBitmapFill(param2,param3,false,true);
         if(param3)
         {
            param1.drawRect(0,0,param2.width * param3.a,param2.height * param3.d);
         }
         else
         {
            param1.drawRect(0,0,param2.width,param2.height);
         }
         param1.endFill();
      }
      
      public function set user(param1:String) : void
      {
         var i:int = 0;
         var f:DisplayObject = null;
         var vipDataClass:Class = null;
         var vipData:BitmapData = null;
         var value:String = param1;
         if(value == null)
         {
            value = " ";
         }
         this.userName.text = value;
         if(this.vip != null && this.vip.numChildren > 0)
         {
            i = 0;
            while(i < this.vip.numChildren)
            {
               f = this.vip.removeChildAt(0);
               f = null;
               i++;
            }
         }
         if(this.vipStatus != 0)
         {
            try
            {
               this.vip.y = 10;
               this.vip.x = this.userName.x + this.userName.textWidth + 4;
               vipDataClass = MaterialLib.getInstance().getClass(this._vipLevelMaterial + this.vipLevel) as Class;
               vipData = new vipDataClass(16,13);
               this.vip.addChild(new Bitmap(vipData));
               addChild(this.vip);
            }
            catch(e:Error)
            {
            }
         }
      }
      
      public function get userlevel() : int
      {
         return this._userLevel;
      }
      
      private function backBg(param1:MouseEvent) : void
      {
         if(!this._selected)
         {
            this.highlight.alpha = 0;
         }
      }
      
      private function hideVipTip() : void
      {
         var _loc1_:TipEvent = new TipEvent(TipEvent.TIP_HIDE);
         _loc1_.tipType = "MouseTip";
         ViewControl.getInstance().dispatchEvent(_loc1_);
      }
      
      public function setStatus() : void
      {
         var _loc1_:int = 0;
         var _loc2_:Object = null;
         var _loc3_:Sprite = null;
         if(this.status_mc.numChildren > 0)
         {
            this.status_mc.removeChildAt(0);
         }
         if(this.mainData.friendStatus)
         {
            if(!this._friendData.hasOwnProperty("pf") || this._friendData["pf"] == 0)
            {
               return;
            }
            _loc1_ = int(this._friendData["uId"]);
            _loc2_ = this.mainData.friendStatus[_loc1_];
            if(Boolean(_loc2_) && _loc2_["zdo"] == 1)
            {
               _loc3_ = MaterialLib.getInstance().getMaterial("Status_z") as Sprite;
               if(_loc3_)
               {
                  this.status_mc.addChild(_loc3_);
                  this.status_mc.ID = "Status_z";
               }
               this.mainData.friendStatusRelate[this._friendData.uId] = this;
               return;
            }
            if(Boolean(_loc2_) && _loc2_["tdo"] == 1)
            {
               _loc3_ = MaterialLib.getInstance().getMaterial("Status_t") as Sprite;
               if(_loc3_)
               {
                  this.status_mc.addChild(_loc3_);
                  this.status_mc.ID = "Status_t";
               }
               this.mainData.friendStatusRelate[this._friendData.uId] = this;
               return;
            }
            if(Boolean(_loc2_) && Boolean(_loc2_["gdo"]))
            {
               _loc3_ = MaterialLib.getInstance().getMaterial("Status_g") as Sprite;
               if(_loc3_)
               {
                  this.status_mc.addChild(_loc3_);
                  this.status_mc.ID = "Status_g";
               }
               this.mainData.friendStatusRelate[this._friendData.uId] = this;
               return;
            }
            if(Boolean(_loc2_) && Boolean(_loc2_["udo"]))
            {
               _loc3_ = MaterialLib.getInstance().getMaterial("Status_u") as Sprite;
               if(_loc3_)
               {
                  this.status_mc.addChild(_loc3_);
                  this.status_mc.ID = "Status_u";
               }
               this.mainData.friendStatusRelate[this._friendData.uId] = this;
               return;
            }
            if(Boolean(_loc2_) && Boolean(_loc2_["pdo"]))
            {
               _loc3_ = MaterialLib.getInstance().getMaterial("Status_p") as Sprite;
               if(_loc3_)
               {
                  this.status_mc.addChild(_loc3_);
                  this.status_mc.ID = "Status_p";
               }
               this.mainData.friendStatusRelate[this._friendData.uId] = this;
               return;
            }
            if(Boolean(_loc2_) && Boolean(_loc2_["bdo"]))
            {
               _loc3_ = MaterialLib.getInstance().getMaterial("Status_b") as Sprite;
               if(_loc3_)
               {
                  this.status_mc.addChild(_loc3_);
                  this.status_mc.ID = "Status_b";
               }
               this.mainData.friendStatusRelate[this._friendData.uId] = this;
               return;
            }
         }
      }
      
      private function showMcTip() : void
      {
         var _loc1_:TipEvent = new TipEvent(TipEvent.TIP_SHOW);
         _loc1_.tipType = "MouseTip";
         _loc1_.tipArgument = "点击进入好友农场";
         ViewControl.getInstance().dispatchEvent(_loc1_);
      }
      
      public function set userlevel(param1:int) : void
      {
         this._userLevel = param1;
         this.leve.text = param1.toString();
         var _loc2_:int = 39423;
         if(this.isMe)
         {
            _loc2_ = 13369344;
         }
         if(param1 < 10)
         {
            if(param1 <= 3)
            {
               _loc2_ = 16777215;
               if(this.isMe)
               {
                  _loc2_ = 13369344;
               }
               this.leve.setTextFormat(new TextFormat("embedFontA",16,_loc2_,true));
            }
            else
            {
               this.leve.setTextFormat(new TextFormat("embedFontA",16,_loc2_,true));
            }
            this.leve.y = 5;
         }
         else if(param1 >= 10 && param1 < 100)
         {
            this.leve.setTextFormat(new TextFormat("embedFontA",13,_loc2_,true));
            this.leve.y = 7;
         }
         else if(param1 >= 100 && param1 < 1000)
         {
            this.leve.setTextFormat(new TextFormat("embedFontA",10,_loc2_,true));
            this.leve.y = 8;
         }
         else if(param1 >= 1000 && param1 < 10000)
         {
            this.leve.setTextFormat(new TextFormat("embedFontA",8,_loc2_,false));
            this.leve.y = 9;
         }
         else
         {
            this.leve.setTextFormat(new TextFormat("embedFontA",6,_loc2_,false));
            this.leve.y = 10;
         }
         this.leve.embedFonts = true;
      }
      
      private function onMarkUpdate(param1:Event) : void
      {
         var uplist:Object = null;
         var e:Event = param1;
         try
         {
            uplist = this.mainData.updateMark;
            if(uplist[this._friendData["uin"]])
            {
               this.fiendData["userName"] = uplist[this._friendData["uin"]];
               this.friendData = this.fiendData;
            }
         }
         catch(e:Error)
         {
         }
      }
      
      public function set selected(param1:String) : void
      {
         if(param1 == this._friendData.uId)
         {
            this._selected = true;
            this.highlight.alpha = 0.8;
         }
         else
         {
            this._selected = false;
            this.highlight.alpha = 0;
         }
      }
      
      public function set isMe(param1:Boolean) : void
      {
         this._isme = param1;
         if(this._isme)
         {
            this.userName.setTextFormat(new TextFormat(null,12,13369344));
            this.userlevel = this._userLevel;
         }
         else
         {
            this.userName.setTextFormat(new TextFormat(null,12,3355443));
            this.userlevel = this._userLevel;
         }
      }
      
      public function get user() : String
      {
         return this.userName.text;
      }
      
      public function set vipLevel(param1:int) : void
      {
         this._vipLevel = param1;
      }
      
      private function showNameTip() : void
      {
         var _loc1_:TipEvent = new TipEvent(TipEvent.TIP_SHOW);
         _loc1_.tipType = "MouseTip";
         if(!this._friendData.hasOwnProperty("pf") || this._friendData["pf"] == 0)
         {
            _loc1_.tipArgument = "该好友未开通牧场";
            ViewControl.getInstance().dispatchEvent(_loc1_);
         }
      }
      
      public function clear() : void
      {
         this.mainData.removeEventListener(MainData.HEAD_UPDATE,this.onHeadChange);
         this.mainData.removeEventListener(MainData.MARK_UPDATE,this.onMarkUpdate);
      }
      
      public function set friendData(param1:Object) : void
      {
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:String = null;
         var _loc7_:int = 0;
         this._friendData = param1;
         var _loc2_:String = "";
         if(param1.yellowlevel == null)
         {
            this.vipLevel = 0;
         }
         else
         {
            this.vipLevel = param1.yellowlevel;
         }
         if(param1.yellowstatus == null)
         {
            this.vipStatus = 0;
         }
         else
         {
            this.vipStatus = param1.yellowstatus;
         }
         this.icon = param1.headPic;
         this.userlevel = param1.sort;
         if(!param1.userName)
         {
            param1.userName = "牧场玩家";
         }
         var _loc3_:int = int(param1.userName.length);
         if(_loc3_ > 4)
         {
            _loc4_ = 0;
            _loc5_ = 0;
            _loc6_ = "";
            _loc7_ = 0;
            while(_loc7_ < _loc3_)
            {
               if(param1.userName.charCodeAt(_loc7_) > 255)
               {
                  _loc4_ += 1;
               }
               else
               {
                  _loc5_ += 1;
               }
               if(_loc4_ + _loc5_ / 2 > 4)
               {
                  break;
               }
               _loc6_ += param1.userName.charAt(_loc7_);
               _loc7_++;
            }
            if(_loc4_ + _loc5_ / 2 > 4)
            {
               _loc2_ = _loc6_ + "..";
            }
            else
            {
               _loc2_ = param1.userName;
            }
         }
         else
         {
            _loc2_ = param1.userName;
         }
         this.user = _loc2_;
         this.isMe = param1.me;
         this.setStatus();
         this.setMC(param1);
      }
      
      private function showFlagTip(param1:String) : void
      {
         var _loc2_:TipEvent = new TipEvent(TipEvent.TIP_SHOW);
         _loc2_.tipType = "MouseTip";
         _loc2_.tipArgument = param1;
         ViewControl.getInstance().dispatchEvent(_loc2_);
      }
      
      private function dispatchData(param1:MouseEvent) : void
      {
         var _loc2_:ViewEvent = null;
         if(param1.target.ID == "Status_z")
         {
            Command.getInstance().mainCommand.floatWindow("召回邀请发送成功，经验值加");
         }
         else if(param1.target.ID == "Status_u")
         {
            CmdAPI.getInstance().api.showWildStage();
            if(this.fiendData["uId"] == this.mainData.currentUserId)
            {
               return;
            }
         }
         else
         {
            CmdAPI.getInstance().api.showFarmStage();
         }
         if(param1.target == this.nc_btn)
         {
            Command.getInstance().mainCommand.setExpressUser(this.fiendData);
            return;
         }
         if(this.hasMC)
         {
            _loc2_ = new ViewEvent("friend",true);
            _loc2_.data = this._friendData;
            this.dispatchEvent(_loc2_);
         }
         BeastAPI.cmdSetupClassObj.removeText();
      }
      
      public function set vipStatus(param1:int) : void
      {
         this._vipStatus = param1;
      }
      
      public function set levelBg(param1:BitmapData) : void
      {
         if(param1 != null)
         {
            this.drawG(this.leveBg.graphics,param1);
            this.leveBg.width = param1.width;
            this.leveBg.height = param1.height;
         }
      }
      
      public function get isMe() : Boolean
      {
         return this._isme;
      }
      
      public function get vipLevel() : int
      {
         return this._vipLevel;
      }
      
      private function completeHandler(param1:Event) : void
      {
         var _loc2_:Loader = Loader(param1.target.loader);
         _loc2_.width = 25;
         _loc2_.height = 25;
      }
      
      private function _MOUSE_OVER(param1:MouseEvent) : void
      {
         this.changBg(param1);
         if(param1.target == this.status_mc)
         {
            if(this.status_mc.hasOwnProperty("ID"))
            {
               switch(this.status_mc.ID)
               {
                  case "Status_z":
                     this.showFlagTip("点击可召回好友并获取经验值");
                     break;
                  case "Status_u":
                     this.showFlagTip("驱赶野生动物");
                     break;
                  default:
                     this.showFlagTip("该用户牧场可以操作");
               }
            }
         }
         else if(param1.target == this.nc_btn)
         {
            this.showMcTip();
         }
         else
         {
            this.showNameTip();
         }
         Cursor.useSystem();
      }
      
      public function set icon(param1:String) : void
      {
         var _loc4_:int = 0;
         var _loc2_:int = this.userIcon.numChildren;
         this.userIcon.graphics.clear();
         if(_loc2_ > 0)
         {
            while(_loc4_ < _loc2_)
            {
               this.userIcon.removeChildAt(_loc4_);
               _loc4_++;
            }
         }
         if(param1 == null)
         {
            return;
         }
         this._icon = param1;
         if(Boolean(this.loader) && this.userIcon.contains(this.loader))
         {
            this.loader.contentLoaderInfo.removeEventListener(Event.COMPLETE,this.completeHandler);
            this.loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR,this.ioErrorHandler);
            this.loader.unload();
            this.userIcon.removeChild(this.loader);
            this.loader = null;
         }
         param1 ||= "";
         this.loader = new Loader();
         this.loader.contentLoaderInfo.addEventListener(Event.COMPLETE,this.completeHandler);
         this.loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,this.ioErrorHandler);
         var _loc3_:URLRequest = new URLRequest(param1);
         this.loader.load(_loc3_);
         this.userIcon.addChild(this.loader);
      }
      
      private function _MOUSE_OUT(param1:MouseEvent) : void
      {
         this.backBg(param1);
         this.hideVipTip();
      }
      
      private function ioErrorHandler(param1:IOErrorEvent) : void
      {
         var _loc2_:URLRequest = null;
         if(this.loader)
         {
            _loc2_ = new URLRequest("");
            this.loader.load(_loc2_);
         }
      }
      
      public function get icon() : String
      {
         return this._icon;
      }
      
      private function onHeadChange(param1:Event) : void
      {
         var uplist:Object = null;
         var e:Event = param1;
         try
         {
            uplist = this.mainData.updateHead;
            this.fiendData["headPic"] = uplist[this._friendData["uin"]][0];
            this.friendData = this.fiendData;
         }
         catch(e:Error)
         {
         }
      }
      
      private function setMC(param1:Object) : void
      {
         var _loc2_:Array = null;
         if(!param1.hasOwnProperty("pf") || param1["pf"] == 0)
         {
            _loc2_ = [new ColorMatrixFilter([0.3,0.59,0.11,0,0,0.3,0.59,0.11,0,0,0.3,0.59,0.11,0,0,0,0,0,1,0])];
            this.userName.filters = _loc2_;
            this.userIcon.filters = _loc2_;
            this.leveBg.filters = _loc2_;
            this.leve.filters = _loc2_;
            this.hasMC = false;
            this.userName.alpha = 0.5;
            this.useHandCursor = false;
            this.mouseEnabled = false;
            this.nc_btn.alpha = 0.6;
            this.vip.alpha = 0.6;
         }
      }
   }
}

