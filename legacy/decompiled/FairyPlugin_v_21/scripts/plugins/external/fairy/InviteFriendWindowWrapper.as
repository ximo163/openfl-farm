package plugins.external.fairy
{
   import com.greensock.TweenLite;
   import common.CommonData;
   import common.misc.Cookies;
   import common.misc.QzoneJSAPI;
   import entities.Friend;
   import events.CommonEvent;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.InteractiveObject;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.net.URLRequest;
   import flash.system.ApplicationDomain;
   
   public class InviteFriendWindowWrapper
   {
      
      private var _times:int = 0;
      
      private var _myFriends:Array;
      
      private var _Class:Class = InviteFriendWindowWrapper__Class;
      
      private var _win:Sprite;
      
      private var _control:FairyPlugin;
      
      public function InviteFriendWindowWrapper(param1:FairyPlugin)
      {
         var _loc3_:Number = NaN;
         super();
         this._control = param1;
         var _loc2_:Object = Cookies.getObject("INVITE_TIMES");
         if(_loc2_ != null && _loc2_.hasOwnProperty("ts") == true)
         {
            _loc3_ = parseInt(_loc2_["ts"]);
            if(param1.model.isSameDay(_loc3_) == true)
            {
               this._times = parseInt(_loc2_["count"]);
            }
         }
      }
      
      public function hide() : void
      {
         if(this._win != null && this._win.parent != null)
         {
            this._win.parent["btnClose"].mouseEnabled = true;
            this._win.parent["btnCharge"].mouseEnabled = true;
            this._win.parent["btnRenew"].mouseEnabled = true;
            this._win.parent.removeChild(this._win);
         }
         this._control.friends.removeEventListener(FriendsModel.EVENT_FRIEND_DATA,this.onFriendsLoaded);
      }
      
      private function onTipSent(param1:CommonEvent) : void
      {
         this._control.model.removeEventListener(FriendsModel.EVENT_TIP_SENT,this.onTipSent);
         if(param1.data != null)
         {
            this._control.friends.sendRequest(param1.data["uin_list"] as String,this._control.model.fairyName);
            this.hide();
         }
         else
         {
            this._control.api.alert(2,"系统错误","请求没有发送成功，请您稍后再试。",0,0,null);
         }
         ++this._times;
         if(this._times < 10)
         {
            Cookies.setObject("INVITE_TIMES",{
               "count":this._times,
               "ts":CommonData.serverTime
            },0,true);
            this._control.enableMc(this._win["btnInvite"],true);
         }
      }
      
      public function show(param1:DisplayObjectContainer) : void
      {
         var _loc2_:int = 0;
         if(param1 == null)
         {
            return;
         }
         if(this._win == null)
         {
            this._win = new this._Class() as Sprite;
            this._win["noFriendMask"].visible = false;
            this._win["noFriendMask"].mouseChildren = false;
            _loc2_ = 0;
            while(_loc2_ < 5)
            {
               this._win["item" + _loc2_].buttonMode = true;
               this._win["item" + _loc2_].mouseChildren = false;
               _loc2_++;
            }
            this._win.addEventListener(MouseEvent.CLICK,this.onClicked,false,0,true);
         }
         this._win.alpha = 0;
         this._win.x = (param1.width - this._win.width) * 0.5 + 20;
         this._win.y = (param1.height - this._win.height) * 0.5 - 20;
         param1.addChild(this._win);
         param1["btnClose"].mouseEnabled = false;
         param1["btnCharge"].mouseEnabled = false;
         param1["btnRenew"].mouseEnabled = false;
         TweenLite.to(this._win,0.33,{
            "alpha":1,
            "y":(param1.height - this._win.height) * 0.5
         });
         if(this._control.friends.loaded)
         {
            this.updateFriends();
         }
         else
         {
            this.loading = true;
            this._control.friends.addEventListener(FriendsModel.EVENT_FRIEND_DATA,this.onFriendsLoaded,false,0,true);
         }
      }
      
      private function updateFriends() : void
      {
         this.loading = false;
         this._myFriends = this._control.friends.pick5Friends();
         if(this._myFriends == null || this._myFriends.length == 0)
         {
            this._win["noFriendMask"].visible = true;
            this._control.enableMc(this._win["btnInvite"],false);
            return;
         }
         var _loc1_:uint = this._myFriends.length;
         if(_loc1_ == 1)
         {
            this.showFriendAt(0,null);
            this.showFriendAt(1,null);
            this.showFriendAt(2,this._myFriends[0] as Friend);
            this.showFriendAt(3,null);
            this.showFriendAt(4,null);
         }
         else if(_loc1_ == 2)
         {
            this.showFriendAt(0,null);
            this.showFriendAt(1,this._myFriends[0] as Friend);
            this.showFriendAt(2,null);
            this.showFriendAt(3,this._myFriends[1] as Friend);
            this.showFriendAt(4,null);
         }
         else if(_loc1_ == 3)
         {
            this.showFriendAt(0,null);
            this.showFriendAt(1,this._myFriends[0] as Friend);
            this.showFriendAt(2,this._myFriends[1] as Friend);
            this.showFriendAt(3,this._myFriends[2] as Friend);
            this.showFriendAt(4,null);
         }
         else if(_loc1_ == 4)
         {
            this.showFriendAt(0,this._myFriends[0] as Friend);
            this.showFriendAt(1,this._myFriends[1] as Friend);
            this.showFriendAt(2,this._myFriends[2] as Friend);
            this.showFriendAt(3,this._myFriends[3] as Friend);
            this.showFriendAt(4,null);
         }
         else if(_loc1_ == 5)
         {
            this.showFriendAt(0,this._myFriends[0] as Friend);
            this.showFriendAt(1,this._myFriends[1] as Friend);
            this.showFriendAt(2,this._myFriends[2] as Friend);
            this.showFriendAt(3,this._myFriends[3] as Friend);
            this.showFriendAt(4,this._myFriends[4] as Friend);
         }
      }
      
      private function onClicked(param1:MouseEvent) : void
      {
         param1.stopImmediatePropagation();
         var _loc2_:InteractiveObject = param1.target as InteractiveObject;
         if(_loc2_ == null)
         {
            return;
         }
         if(_loc2_.name == "item0" || _loc2_.name == "item1" || _loc2_.name == "item2" || _loc2_.name == "item3" || _loc2_.name == "item4")
         {
            this.toggleCheck(_loc2_ as MovieClip);
         }
         else if(_loc2_.name == "btnInvite")
         {
            this.sendInvite();
         }
         else if(_loc2_.name == "btnClose")
         {
            this.hide();
         }
      }
      
      private function toggleCheck(param1:MovieClip) : void
      {
         if(param1 == null)
         {
            return;
         }
         if(param1["gou"].visible == true)
         {
            param1["gou"].visible = false;
         }
         else
         {
            param1["gou"].visible = true;
         }
      }
      
      private function formatPhotoUrl50(param1:uint, param2:String) : String
      {
         var _loc5_:int = 0;
         var _loc3_:String = param2;
         var _loc4_:int = _loc3_.lastIndexOf("/30/30");
         if(_loc3_ == "")
         {
            _loc3_ = QzoneJSAPI.getHead(param1.toString(),50);
         }
         else if(_loc4_ == -1)
         {
            _loc5_ = _loc3_.lastIndexOf("/30");
            _loc3_ = _loc3_.substring(0,_loc5_) + "/50" + _loc3_.substring(_loc5_ + 3,_loc3_.length);
         }
         else
         {
            _loc3_ = _loc3_.substring(0,_loc4_) + "/50/30" + _loc3_.substring(_loc4_ + 6,_loc3_.length);
         }
         return _loc3_;
      }
      
      private function sendInvite() : void
      {
         if(this._myFriends == null)
         {
            return;
         }
         var _loc1_:uint = this._myFriends.length;
         if(_loc1_ == 0)
         {
            return;
         }
         var _loc2_:int = 0;
         var _loc3_:Array = [];
         var _loc4_:Array = [];
         var _loc5_:int = 0;
         while(_loc5_ < 5)
         {
            if(this._win["item" + _loc5_].visible != false)
            {
               if(this._win["item" + _loc5_]["gou"].visible == true)
               {
                  _loc3_.push((this._myFriends[_loc2_] as Friend)._uId);
                  _loc4_.push((this._myFriends[_loc2_] as Friend)._uin);
               }
               _loc2_++;
            }
            _loc5_++;
         }
         if(_loc3_.length == 0)
         {
            return;
         }
         this._control.friends.sendTip(_loc4_);
         this._control.friends.addEventListener(FriendsModel.EVENT_TIP_SENT,this.onTipSent,false,0,true);
         this._control.enableMc(this._win["btnInvite"],false);
      }
      
      private function showFriendAt(param1:int, param2:Friend) : void
      {
         var _loc5_:String = null;
         var _loc3_:MovieClip = this._win["item" + param1] as MovieClip;
         if(_loc3_ == null)
         {
            return;
         }
         var _loc4_:Loader = _loc3_.getChildByName("__photo__") as Loader;
         if(param2 == null)
         {
            _loc3_.visible = false;
            if(_loc4_ != null && _loc4_.hasOwnProperty("unloadAndStop") == true)
            {
               _loc4_["unloadAndStop"]();
            }
            if(_loc4_ != null)
            {
               _loc3_.removeChild(_loc4_);
            }
            _loc3_["tfName"].text = "";
         }
         else
         {
            _loc5_ = this.formatPhotoUrl50(param2._uin,param2._headPic);
            if(_loc4_ == null)
            {
               _loc4_ = new Loader();
               _loc4_.x = 15;
               _loc4_.y = 7;
               _loc4_.name = "__photo__";
               _loc3_.addChild(_loc4_);
            }
            if(_loc4_.contentLoaderInfo.url != _loc5_)
            {
               _loc4_.load(new URLRequest(_loc5_));
            }
            _loc3_["tfName"].text = param2._userName || "农场玩家";
            _loc3_["gou"].visible = true;
         }
      }
      
      public function set loading(param1:Boolean) : void
      {
         var _loc3_:Class = null;
         var _loc4_:MovieClip = null;
         if(this._win == null)
         {
            return;
         }
         this._win["item0"]["visible"] = !param1;
         this._win["item1"]["visible"] = !param1;
         this._win["item2"]["visible"] = !param1;
         this._win["item3"]["visible"] = !param1;
         this._win["item4"]["visible"] = !param1;
         this._control.enableMc(this._win["btnInvite"],!param1);
         var _loc2_:DisplayObject = this._win.getChildByName("__loading__");
         if(param1 == true)
         {
            if(_loc2_ == null)
            {
               _loc3_ = ApplicationDomain.currentDomain.getDefinition("DataLoading_mc") as Class;
               if(_loc3_ != null)
               {
                  _loc4_ = new _loc3_() as MovieClip;
                  _loc4_.x = 208;
                  _loc4_.y = 110;
                  _loc4_.mouseEnabled = false;
                  _loc4_.name = "__loading__";
                  this._win.addChild(_loc4_);
               }
            }
         }
         else if(_loc2_ != null)
         {
            this._win.removeChild(_loc2_);
         }
      }
      
      private function onFriendsLoaded(param1:CommonEvent) : void
      {
         if(param1 == null || param1.data == null)
         {
            return;
         }
         param1.target.removeEventListener(FriendsModel.EVENT_FRIEND_DATA,this.onFriendsLoaded);
         if(param1.data["success"] == true)
         {
            this.updateFriends();
         }
         else if(param1.data["noFriends"] == true)
         {
            this._win["noFriendMask"].visible = true;
            this.loading = false;
            this._control.enableMc(this._win["btnInvite"],false);
         }
         else
         {
            this._control.api.alert(2,"系统错误","拉取好友信息失败，请您稍后再试。",0,0,null);
            this._win["noFriendMask"].visible = false;
            this.loading = true;
         }
      }
   }
}

