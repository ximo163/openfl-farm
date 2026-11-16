package module.friend
{
   import com.qzone.allianceActivity.AllianceActivityManager;
   import com.qzone.allianceActivity.interfaces.IAllianceActivityContext;
   import com.qzone.farm.api.interfaces.IPluginProxy;
   import com.qzone.qui.makers.ButtonMaker;
   import com.qzone.utils.StringUtil;
   import common.CommonData;
   import common.Session;
   import common.Settings;
   import common.misc.Cookies;
   import common.misc.QzoneJSAPI;
   import common.misc.Utils;
   import entities.Friend;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.Graphics;
   import flash.display.Loader;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.TimerEvent;
   import flash.geom.Matrix;
   import flash.net.URLRequest;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.utils.Timer;
   import framework.api.PluginManager;
   
   public class FriendItemRender extends Sprite
   {
      
      private var status_mc:Sprite;
      
      private var _friendData:Friend = null;
      
      private var _selected:Boolean = false;
      
      private var statusIcon:Sprite;
      
      private var _vipLevelMaterial:String = "VipL";
      
      private var vip:Sprite;
      
      private var _isme:Boolean = false;
      
      private var _preMode:Boolean;
      
      private var mc_btn:Sprite;
      
      private var highlight:Sprite;
      
      private var _tjTimer:Timer;
      
      private var _preTimer:Timer;
      
      private var _vipLevel:int = 0;
      
      private var leveBg:Sprite;
      
      private var listItem:Sprite;
      
      private var _icon:String;
      
      private var userIcon:Sprite;
      
      private var _preTime:int;
      
      private var leve:TextField;
      
      private var _vipStatus:int = 0;
      
      private var userName:TextField;
      
      private var _userLevel:int = 0;
      
      public function FriendItemRender()
      {
         super();
         this.buttonMode = true;
         this.listItem = Utils.getMaterial("List_Item") as Sprite;
         this.highlight = this.listItem.getChildByName("highLight_mc") as Sprite;
         this.userName = this.listItem.getChildByName("name_txt") as TextField;
         this.userIcon = this.listItem.getChildByName("head_mc") as Sprite;
         this.leve = this.listItem.getChildByName("level_txt") as TextField;
         this.leveBg = this.listItem.getChildByName("level_mc") as Sprite;
         this.vip = this.listItem.getChildByName("vip_mc") as Sprite;
         this.status_mc = this.listItem.getChildByName("status_mc") as Sprite;
         this.mc_btn = this.listItem.getChildByName("mc_btn") as Sprite;
         ButtonMaker.addTarget(this.mc_btn);
         this.highlight.mouseEnabled = false;
         this.leveBg.mouseEnabled = false;
         this.userIcon.mouseEnabled = false;
         this.userIcon.mouseChildren = false;
         this.leve.mouseEnabled = false;
         this.userName.mouseEnabled = false;
         this.userName.selectable = false;
         this.status_mc.mouseChildren = false;
         addChild(this.listItem);
      }
      
      public function changBg() : void
      {
         if(!this._selected)
         {
            this.highlight.alpha = 0.8;
         }
      }
      
      public function set fiendData(param1:Friend) : void
      {
         this._friendData = param1;
         this.vipLevel = this._friendData._yellowlevel;
         this.vipStatus = this._friendData._yellowstatus;
         this.icon = this._friendData._headPic;
         this.userlevel = this._friendData["sort"];
         this.updateStatusFlag();
         this.setMC(0);
         if(this._friendData._userName == "" || this._friendData._userName == null)
         {
            this._friendData._userName = "农场玩家";
         }
         this.user = this.formatName(this._friendData._userName);
         this.isMe = this._friendData["me"];
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
      
      private function onTjTimer(param1:TimerEvent) : void
      {
         if(this._friendData == null)
         {
            return;
         }
         var _loc2_:int = this.tujian;
         if(_loc2_ == 0)
         {
            return;
         }
         var _loc3_:IAllianceActivityContext = AllianceActivityManager.getInstance().getActivityContext("collecting");
         if(_loc3_ == null)
         {
            return;
         }
         var _loc4_:BitmapData = _loc3_.execute("10001",_loc2_) as BitmapData;
         if(_loc4_ == null)
         {
            return;
         }
         var _loc5_:Bitmap = new Bitmap(_loc4_,"auto",true);
         _loc5_.scaleX = 0.4;
         _loc5_.scaleY = 0.4;
         var _loc6_:Sprite = new Sprite();
         _loc6_.x = this.mc_btn.x - 2;
         _loc6_.y = this.mc_btn.y - 2;
         _loc6_.name = "tujian";
         _loc6_.mouseChildren = false;
         _loc6_.addChild(_loc5_);
         addChild(_loc6_);
         (param1.target as Timer).stop();
      }
      
      public function get fiendData() : Friend
      {
         return this._friendData;
      }
      
      public function backBg() : void
      {
         if(!this._selected)
         {
            this.highlight.alpha = 0;
         }
      }
      
      public function get preTime() : int
      {
         return this._preTime;
      }
      
      public function get userlevel() : int
      {
         return this._userLevel;
      }
      
      private function onHeadIconLoaded(param1:Event) : void
      {
         var _loc2_:Loader = Loader(param1.target.loader);
         _loc2_.scaleX = 25 / _loc2_.width;
         _loc2_.scaleY = 25 / _loc2_.height;
      }
      
      public function set user(param1:String) : void
      {
         var i:int = 0;
         var f:DisplayObject = null;
         var vipDataClass:Class = null;
         var vipData:BitmapData = null;
         var value:String = param1;
         this.userName.htmlText = StringUtil.htmlEscape(value);
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
               vipDataClass = Utils.getClass(this._vipLevelMaterial + this.vipLevel) as Class;
               if(vipDataClass != null)
               {
                  vipData = new vipDataClass(16,13);
                  this.vip.addChild(new Bitmap(vipData));
                  addChild(this.vip);
               }
            }
            catch(e:Error)
            {
            }
         }
      }
      
      public function updateStatusFlag() : void
      {
         var _loc9_:IPluginProxy = null;
         var _loc10_:int = 0;
         var _loc11_:int = 0;
         delete this.status_mc["s_name"];
         if(this.status_mc.numChildren > 0)
         {
            this.status_mc.removeChildAt(0);
         }
         this._preTime = 0;
         if(this._preTimer != null)
         {
            this._preTimer.removeEventListener(TimerEvent.TIMER,this.preTimerCom);
            this._preTimer.stop();
            this._preTimer = null;
         }
         var _loc1_:int = int(this._friendData._uId);
         var _loc2_:Boolean = Boolean(Settings.isQZoneUinMode);
         if(_loc2_ == true)
         {
            _loc1_ = int(this._friendData._uin);
         }
         var _loc3_:String = Settings.getInstance().getStringAttribute("preYellowlevel");
         if(_loc3_ == "")
         {
            _loc3_ = "7";
         }
         if(Session.getInstance().host._yellowlevel >= parseInt(_loc3_))
         {
            this._preMode = true;
         }
         if(this._friendData["status"] == "")
         {
            return;
         }
         var _loc4_:Object = this._friendData["status"];
         if(_loc4_ == null)
         {
            return;
         }
         var _loc5_:Number = Number(CommonData.serverTime);
         var _loc6_:Boolean = this._friendData["me"] as Boolean;
         var _loc7_:Class = null;
         var _loc8_:Boolean = false;
         if(_loc4_["7"] != undefined && _loc6_ == false && QzoneJSAPI.QPLUS == false && QzoneJSAPI.WB == false)
         {
            _loc9_ = PluginManager.getInstance().getPluginByID(2);
            if(_loc9_ != null && _loc9_.executeCommand(2101,_loc1_) == true)
            {
               _loc7_ = _loc9_.executeCommand(2102,null) as Class;
               this.status_mc["s_name"] = "Status_7";
            }
         }
         if(Boolean(Settings.getInstance().openZhaoHui()) && QzoneJSAPI.QPLUS == false && QzoneJSAPI.WB == false)
         {
            if(CommonData.BackHandTimeIsToday(_loc1_) == false)
            {
               Cookies.setObject("z_" + _loc1_,null);
               if(_loc4_["5"] == 1 || _loc4_["5"] == true)
               {
                  _loc7_ = Utils.getClass("Status_z") as Class;
                  this.status_mc["s_name"] = "Status_z";
               }
            }
         }
         if(_loc7_ == null)
         {
            if(_loc4_["1"] is Boolean)
            {
               if(_loc4_["1"] == true)
               {
                  _loc7_ = Utils.getClass("Status_1") as Class;
               }
            }
            else
            {
               _loc10_ = parseInt(_loc4_["1"]);
               if(_loc10_ != Cookies.getObject("t_" + _loc1_))
               {
                  if(this._preMode == true && (_loc10_ > _loc5_ && _loc10_ <= 600 + _loc5_))
                  {
                     _loc8_ = true;
                     if(this._preTimer == null)
                     {
                        this._preTimer = new Timer((_loc10_ - _loc5_) * 1000,1);
                        this._preTime = _loc10_;
                        this._preTimer.addEventListener(TimerEvent.TIMER,this.preTimerCom,false,0,true);
                        this._preTimer.start();
                     }
                  }
                  else if(_loc10_ > 0 && _loc10_ <= _loc5_)
                  {
                     _loc7_ = Utils.getClass("Status_1") as Class;
                  }
               }
            }
         }
         if(_loc7_ == null)
         {
            if(_loc4_["6"] as Boolean == true)
            {
               _loc7_ = Utils.getClass("Status_6") as Class;
               this.status_mc["s_name"] = "Status_6";
            }
         }
         if(_loc7_ == null)
         {
            if(_loc4_["4"] is Boolean)
            {
               if(_loc4_["4"] == true)
               {
                  _loc7_ = Utils.getClass("Status_u") as Class;
               }
            }
            else
            {
               _loc11_ = _loc4_["4"] as int;
               if(_loc11_ > Cookies.getObject("u_" + _loc1_))
               {
                  if(_loc11_ > 0 && _loc11_ >= _loc5_)
                  {
                     _loc7_ = Utils.getClass("Status_u") as Class;
                     this.status_mc["s_name"] = "Status_u";
                  }
               }
            }
         }
         if(_loc7_ == null)
         {
            if(_loc4_["2"] === 1 || _loc4_["2"] === true)
            {
               _loc7_ = Utils.getClass("Status_2") as Class;
            }
            else if(_loc4_["3"] === 1 || _loc4_["3"] === true)
            {
               _loc7_ = Utils.getClass("Status_3") as Class;
            }
         }
         if(_loc8_ == true && _loc7_ == null)
         {
            _loc7_ = Utils.getClass("Status_pre") as Class;
         }
         if(_loc7_ != null)
         {
            if(this.statusIcon != null && this.status_mc.contains(this.statusIcon))
            {
               this.status_mc.removeChild(this.statusIcon);
            }
            this.statusIcon = new _loc7_();
            if(this.statusIcon != null && this.status_mc != null && this.status_mc["s_name"] == "Status_7")
            {
               this.statusIcon.scaleX = 20 / this.statusIcon.width;
               this.statusIcon.scaleY = 20 / this.statusIcon.height;
               this.statusIcon.x = -6;
               this.statusIcon.y = -3;
            }
            this.status_mc.addChild(this.statusIcon);
         }
         if(_loc4_["8"] != undefined && _loc4_["8"] > 0 && QzoneJSAPI.WB == false && QzoneJSAPI.QPLUS == false)
         {
            this.setMC(_loc4_["8"]);
         }
         else
         {
            this.setMC(0);
         }
      }
      
      private function formatName(param1:String) : String
      {
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:String = null;
         var _loc7_:int = 0;
         var _loc2_:String = param1;
         var _loc3_:int = param1.length;
         if(_loc3_ > 7)
         {
            return param1.substr(0,7) + "..";
         }
         if(_loc3_ > 4)
         {
            _loc4_ = 0;
            _loc5_ = 0;
            _loc6_ = "";
            _loc7_ = 0;
            while(_loc7_ < _loc3_)
            {
               if(param1.charCodeAt(_loc7_) > 255)
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
               _loc6_ += param1.charAt(_loc7_);
               _loc7_++;
            }
            if(_loc4_ + _loc5_ / 2 > 4)
            {
               _loc2_ = _loc6_ + "..";
            }
         }
         return _loc2_;
      }
      
      public function set selected(param1:uint) : void
      {
         if(param1 == this._friendData._uId)
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
      
      public function get tujian() : int
      {
         var _loc1_:Object = null;
         if(this._friendData != null)
         {
            _loc1_ = this._friendData["status"];
            if(_loc1_ != null && _loc1_["8"] != undefined)
            {
               return _loc1_["8"];
            }
         }
         return 0;
      }
      
      private function preTimerCom(param1:Event) : void
      {
         this.updateStatusFlag();
      }
      
      public function set isMe(param1:Boolean) : void
      {
         this._isme = param1;
         if(this._isme)
         {
            this.userName.setTextFormat(new TextFormat("Verdana",12,13369344));
            this.userlevel = this._userLevel;
         }
         else
         {
            this.userName.setTextFormat(new TextFormat("Verdana",12,3355443));
            this.userlevel = this._userLevel;
         }
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
      
      public function clear() : void
      {
         if(this._preTimer != null)
         {
            this._preTimer.stop();
            this._preTimer = null;
         }
      }
      
      public function set vipLevel(param1:int) : void
      {
         this._vipLevel = param1;
      }
      
      public function get user() : String
      {
         return this.userName.text;
      }
      
      private function onHeadIconLoadFailed(param1:IOErrorEvent) : void
      {
         var _loc2_:int = 0;
         this.userIcon.graphics.clear();
         while(_loc2_ < this.userIcon.numChildren)
         {
            this.userIcon.removeChildAt(0);
            _loc2_++;
         }
      }
      
      public function set vipStatus(param1:int) : void
      {
         this._vipStatus = param1;
      }
      
      public function updateIcon() : void
      {
         if(this._friendData != null)
         {
            this.icon = this._friendData._headPic;
         }
      }
      
      public function setGray() : void
      {
         this.userName.setTextFormat(new TextFormat("Verdana",12,11184810));
         this.userIcon.alpha = 0.5;
         this.leveBg.alpha = 0.5;
      }
      
      public function get preMode() : Boolean
      {
         return this._preMode;
      }
      
      public function get vipLevel() : int
      {
         return this._vipLevel;
      }
      
      public function get isMe() : Boolean
      {
         return this._isme;
      }
      
      public function set icon(param1:String) : void
      {
         if(this.userIcon == null)
         {
            return;
         }
         this.userIcon.graphics.clear();
         var _loc2_:DisplayObject = null;
         while(this.userIcon.numChildren > 0)
         {
            _loc2_ = this.userIcon.removeChildAt(0);
            if(_loc2_ != null && _loc2_.loaderInfo != null && _loc2_.loaderInfo.loader != null)
            {
               if(_loc2_.loaderInfo.loader.hasOwnProperty("unloadAndStop") == true)
               {
                  _loc2_.loaderInfo.loader.unloadAndStop(true);
               }
            }
         }
         this._icon = param1;
         if(QzoneJSAPI.WB == true)
         {
            if(this._icon == "" || this._icon == null)
            {
               this._icon = "http://mat1.gtimg.com/www/mb/images/head_30.jpg";
            }
            else
            {
               this._icon += "/30";
            }
         }
         else if(this._icon == "" || this._icon == null)
         {
            return;
         }
         var _loc3_:Loader = new Loader();
         _loc3_.contentLoaderInfo.addEventListener(Event.COMPLETE,this.onHeadIconLoaded,false,0,true);
         _loc3_.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,this.onHeadIconLoadFailed,false,0,true);
         var _loc4_:URLRequest = new URLRequest(this._icon);
         _loc3_.load(_loc4_);
         this.userIcon.addChild(_loc3_);
      }
      
      private function setMC(param1:int) : void
      {
         var _loc2_:DisplayObjectContainer = null;
         this.mc_btn.visible = false;
         if(param1 > 0)
         {
            if(this._tjTimer == null)
            {
               this._tjTimer = new Timer(500,100);
               this._tjTimer.addEventListener(TimerEvent.TIMER,this.onTjTimer,false,0,true);
               this._tjTimer.start();
            }
            else
            {
               this._tjTimer.reset();
               this._tjTimer.start();
            }
         }
         else
         {
            _loc2_ = getChildByName("tujian") as DisplayObjectContainer;
            if(_loc2_ != null && contains(_loc2_) == true)
            {
               removeChild(_loc2_);
               _loc2_ = null;
            }
         }
      }
      
      public function get icon() : String
      {
         return this._icon;
      }
      
      public function updateName() : void
      {
         var _loc1_:String = this._friendData._userName;
         if(_loc1_ != null && _loc1_ != "")
         {
            this.user = this.formatName(_loc1_);
         }
      }
      
      public function isSelected() : Boolean
      {
         return this._selected;
      }
      
      public function get vipStatus() : int
      {
         return this._vipStatus;
      }
   }
}

