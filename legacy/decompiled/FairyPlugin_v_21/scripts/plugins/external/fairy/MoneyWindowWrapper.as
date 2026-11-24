package plugins.external.fairy
{
   import com.greensock.TweenLite;
   import common.Settings;
   import events.CommonEvent;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.DisplayObjectContainer;
   import flash.display.InteractiveObject;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Matrix;
   import flash.geom.Rectangle;
   import flash.system.ApplicationDomain;
   import flash.utils.getTimer;
   import flash.xml.XMLNode;
   import flash.xml.XMLNodeType;
   
   public class MoneyWindowWrapper
   {
      
      internal static var REWARDS:Array;
      
      private var _rewardCls:Class = MoneyWindowWrapper__rewardCls;
      
      private var _donateList:Array;
      
      private var _requestStamp:int;
      
      private var _inviteWin:InviteFriendWindowWrapper;
      
      private var _Class:Class = MoneyWindowWrapper__Class;
      
      private var _win:MovieClip;
      
      private var _control:FairyPlugin;
      
      private var _donateListRequest:Boolean;
      
      private var _rewards:Sprite;
      
      private var _listCls:Class = MoneyWindowWrapper__listCls;
      
      private var _rewardWindow:MovieClip;
      
      private var _list:Sprite;
      
      public function MoneyWindowWrapper(param1:FairyPlugin)
      {
         super();
         this._control = param1;
         this._requestStamp = 0;
         this._donateList = null;
         this._donateListRequest = false;
      }
      
      public function show(param1:Boolean) : void
      {
         if(this._win == null)
         {
            this._win = new this._Class() as MovieClip;
            this._win["star"].stop();
            this._win["mcFairy"].stop();
            this._win["mcTitle"].stop();
            this._win["money"].stop();
            this._win["btnList"].stop();
            this._win["btnList"].buttonMode = true;
            this._win["btnList"].mouseChildren = false;
            this._win["money"].addEventListener(Event.ENTER_FRAME,this.onPlayMoney,false,0,true);
            this._win["btnList"].addEventListener(Event.ENTER_FRAME,this.onPlayOpenBook,false,0,true);
            this._win.addEventListener(MouseEvent.CLICK,this.onMouseEvent,false,0,true);
            this._win.addEventListener(MouseEvent.MOUSE_OVER,this.onMouseEvent,false,0,true);
            this._win.addEventListener(MouseEvent.MOUSE_OUT,this.onMouseEvent,false,0,true);
         }
         if(this._win != null)
         {
            this._control.model.getMoney();
            this._control.model.addEventListener(FairyModel.DATA_MONEY,this.onGetMoney,false,0,true);
            this._win.gotoAndStop(param1 == true ? 1 : 2);
            this.update(param1);
            this._control.api.showPopUp(this._win,true);
         }
      }
      
      private function onDonated(param1:CommonEvent) : void
      {
         var _loc4_:String = null;
         var _loc2_:Object = param1.data;
         if(_loc2_["error"] != undefined)
         {
            this._control.api.popFloatTip(0,_loc2_["error"],this._win);
            if(param1.data["error"].indexOf("已经供奉") != -1)
            {
               this._control.enableMc(this._win["btnDonate"] as InteractiveObject,false);
               this._control.updateFriendStatus();
            }
            return;
         }
         if(_loc2_["item"] != undefined && _loc2_["type"] != undefined && _loc2_["item"] != 0 && _loc2_["type"] != 0)
         {
            _loc2_["xian"] = this._control.model.fairyName;
            _loc4_ = this._control.callProxy(2003,_loc2_) as String;
            if(_loc4_ != null && _loc4_ != "")
            {
               this.popRewardWindow(_loc2_["item"],_loc2_["type"],_loc4_);
            }
         }
         else
         {
            this.popEmptyRewardWindow();
         }
         this._control.callProxy(2002,param1.data["cost"]);
         this._control.updateFriendStatus();
         this._control.enableMc(this._win["btnDonate"] as InteractiveObject,false);
         if(this._donateList == null)
         {
            this._donateList = [];
         }
         var _loc3_:String = this._control.model.myName;
         if(this._donateList.indexOf(_loc3_) == -1)
         {
            this._donateList.push(_loc3_);
         }
         this.onGetMoney(null);
         this._win["money"].gotoAndPlay(1);
      }
      
      public function get container() : DisplayObjectContainer
      {
         return this._win;
      }
      
      private function update(param1:Boolean) : void
      {
         var _loc5_:Boolean = false;
         var _loc6_:uint = 0;
         if(this._win["tfLeft"] != undefined && this._win["tfLeft"] != null)
         {
            this._win["tfLeft"].text = "";
            this._win["mcClock"].visible = false;
         }
         var _loc2_:Object = this._control.model.fairyItem;
         if(_loc2_ == null)
         {
            return;
         }
         var _loc3_:int = int(_loc2_["lv"]);
         if(param1 == true)
         {
            this._win["btnCharge"].visible = true;
            this._win["btnDonate"].visible = false;
            if(Settings.getInstance().mode != "qzone")
            {
               this._win["btnInvite"].visible = false;
            }
            this.updateExpireTime();
         }
         else
         {
            this._win["btnCharge"].visible = false;
            this._win["btnDonate"].visible = true;
            this.updateRewards();
            _loc5_ = false;
            _loc6_ = this._control.model.currentUserIdByUinMode;
            if(this._control.model.queryDonate(_loc6_) == false)
            {
               _loc5_ = true;
            }
            this._control.enableMc(this._win["btnDonate"],!_loc5_);
         }
         this._win["tfDesc"].text = "金币：" + this._control.model.money + "/" + FairyPlugin.MAX_DONATE[_loc3_];
         this._win["star"].gotoAndStop(_loc3_);
         var _loc4_:int = _loc2_["itemId"] - FairyPlugin.BASE_ID + 1;
         this._win["mcFairy"].gotoAndStop(_loc4_);
         this._win["mcTitle"].gotoAndStop(_loc4_);
      }
      
      private function onPlayMoney(param1:Event) : void
      {
         var _loc2_:MovieClip = param1.target as MovieClip;
         if(_loc2_ == null)
         {
            return;
         }
         if(_loc2_.currentFrame == _loc2_.totalFrames)
         {
            _loc2_.gotoAndStop(1);
         }
      }
      
      private function onGetMoney(param1:CommonEvent) : void
      {
         var _loc4_:Array = null;
         if(param1 != null)
         {
            param1.target.removeEventListener(FairyModel.DATA_MONEY,this.onGetMoney);
            _loc4_ = param1.data as Array;
            if(_loc4_ != null && _loc4_.indexOf(this._control.friends.hostId) != -1)
            {
               this._control.enableMc(this._win["btnDonate"],false);
            }
         }
         var _loc2_:Object = this._control.model.fairyItem;
         if(_loc2_ == null)
         {
            return;
         }
         var _loc3_:int = int(_loc2_["lv"]);
         this._win["tfDesc"].text = "金币：" + this._control.model.money + "/" + FairyPlugin.MAX_DONATE[_loc3_];
      }
      
      private function popInviteWindow() : void
      {
         if(this._inviteWin == null)
         {
            this._inviteWin = new InviteFriendWindowWrapper(this._control);
         }
         this._control.friends.loadExclude();
         this._control.friends.loadFriends();
         this._inviteWin.loading = true;
         this._inviteWin.show(this._win);
      }
      
      private function onCloseList(param1:MouseEvent) : void
      {
         if(this._list != null && this._list.parent != null)
         {
            this._list.parent.removeChild(this._list);
            this._list = null;
         }
         this._win["btnList"].gotoAndStop(1);
         param1.stopImmediatePropagation();
      }
      
      private function updateRewards() : void
      {
         var _loc6_:String = null;
         var _loc7_:String = null;
         if(this._rewards != null)
         {
            return;
         }
         this._rewards = new Sprite();
         this._rewards.x = 83;
         this._rewards.y = 445;
         this._win.addChild(this._rewards);
         var _loc1_:int = 74;
         var _loc2_:Class = null;
         var _loc3_:Sprite = null;
         var _loc4_:int = this._control.model.fairyItem["itemId"] - FairyPlugin.BASE_ID;
         var _loc5_:int = 0;
         while(_loc5_ < REWARDS[_loc4_].length)
         {
            _loc3_ = null;
            if(REWARDS[_loc4_][_loc5_]["type"] == 6)
            {
               _loc2_ = ApplicationDomain.currentDomain.getDefinition("GoldCardsGame") as Class;
               if(_loc2_ != null)
               {
                  _loc3_ = new _loc2_() as Sprite;
               }
            }
            else if(REWARDS[_loc4_][_loc5_]["type"] == 7)
            {
               _loc2_ = ApplicationDomain.currentDomain.getDefinition("ExpIcon") as Class;
               if(_loc2_ != null)
               {
                  _loc3_ = new _loc2_() as Sprite;
               }
            }
            else if(REWARDS[_loc4_][_loc5_]["type"] == 3)
            {
               _loc6_ = this._control.callProxy(2005,REWARDS[_loc4_][_loc5_]["id"]) as String;
               this._control.callProxy(2004,{
                  "name":_loc6_,
                  "callback":this.onIconLoaded,
                  "param":_loc5_
               });
            }
            else if(REWARDS[_loc4_][_loc5_]["type"] == 24)
            {
               _loc7_ = "FishFood_" + REWARDS[_loc4_][_loc5_]["id"];
               this._control.callProxy(2004,{
                  "name":_loc7_,
                  "callback":this.onIconLoaded,
                  "param":_loc5_
               });
            }
            else if(REWARDS[_loc4_][_loc5_]["type"] == 909090)
            {
               this._control.callProxy(2004,{
                  "name":"ShopDogFood",
                  "callback":this.onIconLoaded,
                  "param":_loc5_
               });
            }
            else if(REWARDS[_loc4_][_loc5_]["type"] == 31)
            {
               if(this._win["fIcon"] != undefined)
               {
                  this._win["fIcon"].gotoAndStop(_loc4_ + 1);
               }
            }
            if(_loc3_ != null)
            {
               _loc3_.name = "_" + _loc5_;
               _loc3_.x = _loc1_ * _loc5_ + (65 - _loc3_.width) * 0.5;
               _loc3_.y = (65 - _loc3_.height) * 0.5;
               _loc3_.mouseChildren = false;
               this._rewards.addChild(_loc3_);
            }
            _loc5_++;
         }
      }
      
      private function onCharged(param1:CommonEvent) : void
      {
         var _loc3_:int = 0;
         if(param1.data["error"] != undefined)
         {
            this._control.api.popFloatTip(0,param1.data["error"],this._win);
            return;
         }
         var _loc2_:int = param1.data["money"] as int;
         if(_loc2_ > 0)
         {
            this._control.api.popFloatTip(0,"共收到好友供奉的" + _loc2_ + "金币",this._win);
            _loc3_ = int(this._control.model.fairyItem["lv"]);
            this._win["tfDesc"].text = "金币：" + this._control.model.money + "/" + FairyPlugin.MAX_DONATE[_loc3_];
            this._control.callProxy(2002,_loc2_);
         }
         else
         {
            this._control.api.popFloatTip(0,"尚未收到好友的供奉哦~",this._win);
         }
      }
      
      private function popEmptyRewardWindow() : void
      {
         var y:int;
         if(this._rewardWindow == null)
         {
            this._rewardWindow = new this._rewardCls() as MovieClip;
            this._rewardWindow.gotoAndStop(2);
         }
         this._rewardWindow["tfDesc"].htmlText = "<b>太悲剧了！" + this._control.model.fairyName + "没有感觉到您的诚意，没有道具赏赐给您。</b>";
         this._rewardWindow.alpha = 0;
         this._win.mouseChildren = false;
         this._win.mouseEnabled = false;
         this._rewardWindow.x = (this._win.stage.stageWidth - this._rewardWindow.width) * 0.5;
         y = (this._win.stage.stageHeight - this._rewardWindow.height) * 0.5;
         this._rewardWindow.y = y - 20;
         this._win.stage.addChild(this._rewardWindow);
         TweenLite.to(this._rewardWindow,0.6,{
            "alpha":1,
            "y":y
         });
         this._rewardWindow["btnOK"].addEventListener(MouseEvent.CLICK,function(param1:MouseEvent):void
         {
            _win.stage.removeChild(_rewardWindow);
            _rewardWindow = null;
            _win.mouseChildren = true;
            _win.mouseEnabled = true;
         });
      }
      
      private function onIconLoaded(param1:int) : void
      {
         var _loc2_:int = 74;
         var _loc3_:Class = null;
         var _loc4_:Sprite = null;
         var _loc5_:String = "";
         var _loc6_:int = this._control.model.fairyItem["itemId"] - FairyPlugin.BASE_ID;
         if(REWARDS[_loc6_][param1]["type"] == 3)
         {
            _loc5_ = this._control.callProxy(2005,REWARDS[_loc6_][param1]["id"]) as String;
         }
         else if(REWARDS[_loc6_][param1]["type"] == 24)
         {
            _loc5_ = "FishFood_" + REWARDS[_loc6_][param1]["id"];
         }
         else if(REWARDS[_loc6_][param1]["type"] == 909090)
         {
            _loc5_ = "ShopDogFood";
         }
         if(_loc5_ != "")
         {
            _loc3_ = ApplicationDomain.currentDomain.getDefinition(_loc5_) as Class;
         }
         if(_loc3_ != null)
         {
            _loc4_ = new _loc3_() as Sprite;
         }
         if(_loc4_ != null)
         {
            _loc4_.name = "_" + param1;
            _loc4_.x = _loc2_ * param1 + (65 - _loc4_.width) * 0.5;
            _loc4_.y = (65 - _loc4_.height) * 0.5;
            _loc4_.mouseChildren = false;
            this._rewards.addChild(_loc4_);
         }
      }
      
      private function onDonateList(param1:CommonEvent) : void
      {
         var _loc3_:int = 0;
         if(this._list == null)
         {
            this._list = new this._listCls() as Sprite;
            this._list.x = this._win["btnList"].x;
            this._list.y = this._win["btnList"].y + 20;
            this._list.alpha = 0;
            this._win.addChild(this._list);
         }
         var _loc2_:int = 0;
         while(_loc2_ < 10)
         {
            this._list["name" + _loc2_].htmlText = "";
            _loc2_++;
         }
         if(param1 != null && param1.data != null && param1.data["error"] != undefined)
         {
            this._list["tfDesc"].text = param1.data["error"];
         }
         else
         {
            if(param1 != null && param1.data != null)
            {
               this._donateList = param1.data as Array;
            }
            if(this._donateList != null && this._donateList.length > 0)
            {
               _loc3_ = Math.min(this._donateList.length,10);
               _loc2_ = 0;
               while(_loc2_ < _loc3_)
               {
                  this._list["name" + _loc2_].htmlText = this.htmlEscape(this._donateList[_loc2_]);
                  _loc2_++;
               }
               this._list["tfDesc"].text = "前来供奉的好友";
            }
            else
            {
               this._list["tfDesc"].text = "没有供奉的好友";
            }
         }
         TweenLite.to(this._list,0.6,{
            "alpha":1,
            "scaleX":1,
            "scaleY":1,
            "y":this._win["btnList"].y
         });
      }
      
      private function htmlEscape(param1:String) : String
      {
         return XML(new XMLNode(XMLNodeType.TEXT_NODE,param1)).toXMLString();
      }
      
      private function popRewardWindow(param1:int, param2:int, param3:String) : void
      {
         var icon:Sprite;
         var y:int;
         var i:int;
         var index:int;
         var r:Rectangle = null;
         var m:Matrix = null;
         var bd:BitmapData = null;
         var bmp:Bitmap = null;
         var id:int = param1;
         var type:int = param2;
         var msg:String = param3;
         if(this._rewardWindow == null)
         {
            this._rewardWindow = new this._rewardCls() as MovieClip;
            this._rewardWindow.gotoAndStop(1);
         }
         this._rewardWindow["tfDesc"].htmlText = msg;
         this._rewardWindow.alpha = 0;
         icon = null;
         index = this._control.model.fairyItem["itemId"] - FairyPlugin.BASE_ID;
         i = 0;
         while(i < REWARDS[index].length)
         {
            if(REWARDS[index][i]["type"] == type)
            {
               if(!(REWARDS[index][i]["id"] != undefined && REWARDS[index][i]["id"] != id))
               {
                  if(i != 4)
                  {
                     icon = this._rewards.getChildByName("_" + i) as Sprite;
                  }
                  else
                  {
                     icon = this._win["fIcon"];
                  }
                  if(icon != null)
                  {
                     break;
                  }
               }
            }
            i++;
         }
         if(icon != null)
         {
            r = null;
            m = null;
            if(icon == this._win["fIcon"])
            {
               r = new Rectangle(0,0,56,56);
               m = new Matrix(1,0,0,1,28,-5);
            }
            else
            {
               r = new Rectangle(0,0,icon.width,icon.height);
            }
            bd = new BitmapData(r.width,r.height,false,3546638);
            bd.draw(icon,m,null,null,r,true);
            bmp = new Bitmap(bd,"auto",true);
            bmp.x = 155 + (65 - bmp.width) * 0.5;
            bmp.y = 50 + (65 - bmp.height) * 0.5;
            this._rewardWindow.addChild(bmp);
         }
         this._win.mouseChildren = false;
         this._win.mouseEnabled = false;
         this._rewardWindow.x = (this._win.stage.stageWidth - this._rewardWindow.width) * 0.5;
         y = (this._win.stage.stageHeight - this._rewardWindow.height) * 0.5;
         this._rewardWindow.y = y - 20;
         this._win.stage.addChild(this._rewardWindow);
         TweenLite.to(this._rewardWindow,0.6,{
            "alpha":1,
            "y":y
         });
         this._rewardWindow["btnOK"].addEventListener(MouseEvent.CLICK,function(param1:MouseEvent):void
         {
            _win.stage.removeChild(_rewardWindow);
            _rewardWindow = null;
            _win.mouseChildren = true;
            _win.mouseEnabled = true;
         });
      }
      
      private function onMouseEvent(param1:MouseEvent) : void
      {
         var _loc5_:uint = 0;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc2_:String = param1.type;
         var _loc3_:String = param1.target.name;
         var _loc4_:int = getTimer();
         switch(_loc2_)
         {
            case MouseEvent.CLICK:
               if(this._list != null && this._list.visible == true)
               {
                  if(this._list.hitTestPoint(param1.stageX,param1.stageY) == false)
                  {
                     this.onCloseList(param1);
                  }
                  else if(_loc3_ == "btnClose")
                  {
                     this.onCloseList(param1);
                  }
                  return;
               }
               if(_loc3_ == "btnDonate")
               {
                  if(_loc4_ - this._requestStamp > 3000)
                  {
                     this._requestStamp = _loc4_;
                     this._control.model.donate(10000);
                     this._control.api.reportSuccessError("160567",null);
                     this._control.model.addEventListener(FairyModel.MSG_DONATE_MONEY,this.onDonated,false,0,true);
                  }
               }
               if(_loc3_ == "btnCharge")
               {
                  if(_loc4_ - this._requestStamp > 3000)
                  {
                     this._requestStamp = _loc4_;
                     this._control.model.charge();
                     this._control.api.reportSuccessError("160566",null);
                     this._control.model.addEventListener(FairyModel.MSG_CHARGE_MONEY,this.onCharged,false,0,true);
                  }
               }
               else if(_loc3_ == "btnRenew")
               {
                  this._control.confirmBuySprite(this._control.model.fairyItem["itemId"] - FairyPlugin.BASE_ID,0);
                  this._control.model.addEventListener(FairyModel.MSG_PAIRY_BOUGHT,this.onFairyRenew,false,0,true);
               }
               else if(_loc3_ == "btnList")
               {
                  this._control.api.hideMouseTip();
                  this._win["btnList"].play();
                  if(this._donateListRequest == false)
                  {
                     this._donateListRequest = true;
                     _loc5_ = uint(this._control.model.player._uId);
                     if(this._control.model.player.me == true)
                     {
                        _loc5_ = 0;
                     }
                     this._control.model.getDonateList(_loc5_);
                     this._control.model.addEventListener(FairyModel.DATA_DONATE_LIST,this.onDonateList,false,0,true);
                  }
                  else
                  {
                     this.onDonateList(null);
                  }
               }
               else if(_loc3_ == "btnClose")
               {
                  this.close();
               }
               else if(_loc3_ == "btnInvite")
               {
                  this.popInviteWindow();
               }
               break;
            case MouseEvent.MOUSE_OVER:
               if(_loc3_ == "btnDonate")
               {
                  this._control.api.popMouseTip("供奉花费10000金币");
               }
               else if(_loc3_ == "btnCharge")
               {
                  this._control.api.popMouseTip("领取好友供奉的金币");
               }
               else if(this._control.model.fairyItem != null)
               {
                  _loc6_ = this._control.model.fairyItem["itemId"] - FairyPlugin.BASE_ID;
                  if(_loc3_.length == 2 && _loc3_.charAt(0) == "_")
                  {
                     _loc7_ = parseInt(_loc3_.charAt(1));
                     if(_loc7_ >= 0 && _loc7_ < 5)
                     {
                        this._control.api.popMouseTip(REWARDS[_loc6_][_loc7_]["tip"]);
                     }
                  }
                  else if(_loc3_ == "fIcon")
                  {
                     this._control.api.popMouseTip(REWARDS[_loc6_][4]["tip"]);
                  }
               }
               break;
            case MouseEvent.MOUSE_OUT:
               this._control.api.hideMouseTip();
         }
      }
      
      private function updateExpireTime() : void
      {
         var _loc1_:Date = null;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         if(this._control.model.myExpireTime > 0)
         {
            _loc1_ = new Date();
            _loc2_ = this._control.model.myExpireTime - _loc1_.time / 1000;
            if(_loc2_ <= 0)
            {
               this._win["tfLeft"].text = "此小仙已经过期";
               return;
            }
            _loc3_ = _loc2_ / (24 * 60 * 60);
            _loc4_ = _loc2_ % (24 * 60 * 60) / 3600;
            if(_loc3_ == 0 && _loc4_ == 0)
            {
               this._win["tfLeft"].text = "剩余时间：不足一小时";
            }
            else if(_loc3_ == 0)
            {
               this._win["tfLeft"].text = "剩余时间：" + _loc4_ + "小时";
            }
            else
            {
               this._win["tfLeft"].text = "剩余时间：" + _loc3_ + "天" + _loc4_ + "小时";
            }
            this._win["mcClock"].visible = true;
         }
      }
      
      private function onFairyRenew(param1:CommonEvent) : void
      {
         this._control.model.removeEventListener(FairyModel.MSG_PAIRY_BOUGHT,this.onFairyRenew);
         var _loc2_:Object = param1.data;
         if(_loc2_ != null && _loc2_["succ"] == true)
         {
            this._control.api.popFloatTip(0,"续费小仙" + _loc2_["month"] + "个月成功！",this._win);
            this.updateExpireTime();
         }
      }
      
      private function onPlayOpenBook(param1:Event) : void
      {
         var _loc2_:MovieClip = param1.target as MovieClip;
         if(_loc2_ == null)
         {
            return;
         }
         if(_loc2_.currentFrame == _loc2_.totalFrames)
         {
            _loc2_.stop();
         }
      }
      
      private function close() : void
      {
         if(this._rewards != null && this._rewards.parent != null)
         {
            this._rewards.parent.removeChild(this._rewards);
            this._rewards = null;
         }
         this._control.api.hidePopUp(this._win);
         this._control.callProxy(2009,false);
         this._donateList = null;
         this._donateListRequest = false;
      }
   }
}

