package mc.view.main.friend
{
   import com.adobe.utils.StringUtil;
   import common.LocalData;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.utils.getTimer;
   import flash.utils.setTimeout;
   import mc.FBridge.FeartureManager;
   import mc.control.Command;
   import mc.control.ViewControl;
   import mc.events.WindowEvent;
   import mc.model.MData;
   import mc.model.MainData;
   import mc.view.ViewEvent;
   
   public class FriendLayer extends Sprite
   {
      
      private var hideRight:Number = 24;
      
      private var mainData:MainData;
      
      private var getFriend:Boolean = false;
      
      private var getFriendListClick:int;
      
      private var paginationFriend:PaginationFriend;
      
      private var showRight:Number = 206;
      
      private var offsetValue:int = 0;
      
      private var easing:Number = 0.4;
      
      private var getFriendListTime:int = getTimer();
      
      public function FriendLayer()
      {
         super();
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage);
         this.mainData = MData.getInstance().mainData;
      }
      
      private function alertWindow(param1:String, param2:String) : void
      {
         var _loc3_:WindowEvent = null;
         if(StringUtil.trim(param2) != "")
         {
            _loc3_ = new WindowEvent(WindowEvent.OPEN);
            _loc3_.windowName = "AlertWindow";
            _loc3_.windowArgument = {
               "type":param1,
               "text":param2
            };
            ViewControl.getInstance().dispatchEvent(_loc3_);
         }
      }
      
      private function effHandler(param1:Event) : void
      {
         var _loc2_:Number = NaN;
         if(this.offsetValue > 0)
         {
            _loc2_ = stage.stageWidth - this.hideRight;
         }
         else
         {
            _loc2_ = stage.stageWidth - this.showRight;
         }
         var _loc3_:Number = Math.floor((_loc2_ - this.paginationFriend.x) * this.easing);
         this.paginationFriend.x += _loc3_;
         if(_loc3_ == 0)
         {
            removeEventListener(Event.ENTER_FRAME,this.effHandler);
         }
      }
      
      private function sortByExp(param1:Event) : void
      {
         Command.getInstance().mainCommand.sortBy("exp");
      }
      
      private function refurbish(param1:Event) : void
      {
         if(this.getFriendListTime + LocalData.getFriendListDelay < getTimer())
         {
            if(this.getFriendListClick < LocalData.limitedTimes)
            {
               if(param1.type == PaginationFriend.REFURBISH)
               {
                  Command.getInstance().mainCommand.getFriendList(true);
               }
               else if(param1.type == PaginationFriend.REFURBISH2)
               {
                  Command.getInstance().mainCommand.getFriendStatus();
               }
               ++this.getFriendListClick;
            }
            else
            {
               this.getFriendListTime = getTimer();
               this.getFriendListClick = 0;
            }
         }
      }
      
      private function shrinkage(param1:ViewEvent) : void
      {
         var is403:String = null;
         var e:ViewEvent = param1;
         try
         {
            is403 = FeartureManager.friendListMod();
            if(is403)
            {
               setTimeout(this.alertWindow,120,"tip",is403);
               return;
            }
         }
         catch(e:Error)
         {
         }
         if(e.data == true)
         {
            if(this.getFriend == false)
            {
               Command.getInstance().mainCommand.getFriendList(false,true);
               this.getFriend = true;
            }
            this.effStart(-1);
         }
         else
         {
            this.effStart(1);
         }
      }
      
      private function friend(param1:ViewEvent) : void
      {
         Command.getInstance().mainCommand.setUser(param1.data);
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         removeEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage);
         this.createPaginationFriend();
         this.addEventListener(MouseEvent.MOUSE_WHEEL,this.MOUSE_WHEEL_);
      }
      
      private function back(param1:ViewEvent) : void
      {
         Command.getInstance().mainCommand.friendBackPage(param1.data.toString());
      }
      
      private function friendChange(param1:Event) : void
      {
         var _loc2_:int = this.mainData.showFriendPage;
         var _loc3_:int = this.mainData.showFriendSum;
         this.paginationFriend.show(MData.getInstance().mainData.showFriendList,_loc2_,_loc3_);
      }
      
      private function nextEnd(param1:ViewEvent) : void
      {
         Command.getInstance().mainCommand.friendNextEndPage(param1.data.toString());
      }
      
      private function next(param1:ViewEvent) : void
      {
         Command.getInstance().mainCommand.friendNextPage(param1.data.toString());
      }
      
      private function backEnd(param1:ViewEvent) : void
      {
         Command.getInstance().mainCommand.friendBackEndPage(param1.data.toString());
      }
      
      private function search(param1:ViewEvent) : void
      {
         Command.getInstance().mainCommand.searchFriend(param1.data.toString());
      }
      
      private function createPaginationFriend() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         if(this.paginationFriend == null)
         {
            this.paginationFriend = new PaginationFriend();
            this.paginationFriend.addEventListener(PaginationFriend.SHRINKAGE,this.shrinkage);
            this.paginationFriend.addEventListener(PaginationFriend.BACK,this.back);
            this.paginationFriend.addEventListener(PaginationFriend.NEXT,this.next);
            this.paginationFriend.addEventListener("backEnd",this.backEnd);
            this.paginationFriend.addEventListener("nextEnd",this.nextEnd);
            this.paginationFriend.addEventListener(PaginationFriend.SEARCH,this.search);
            this.paginationFriend.addEventListener(PaginationFriend.REFURBISH,this.refurbish);
            this.paginationFriend.addEventListener(PaginationFriend.REFURBISH2,this.refurbish);
            this.paginationFriend.addEventListener(PaginationFriend.FRIEND,this.friend);
            this.paginationFriend.addEventListener(PaginationFriend.SORT_BY_EXP,this.sortByExp);
            this.paginationFriend.x = stage.stageWidth - this.hideRight;
            this.paginationFriend.y = 80;
            addChild(this.paginationFriend);
            if(MData.getInstance().mainData.showFriendList != null)
            {
               _loc1_ = this.mainData.showFriendPage;
               _loc2_ = this.mainData.showFriendSum;
               this.paginationFriend.show(MData.getInstance().mainData.showFriendList,_loc1_,_loc2_);
            }
            this.mainData.addEventListener(MainData.FRIEND_CHANGE,this.friendChange);
         }
      }
      
      private function effStart(param1:int) : void
      {
         this.offsetValue = param1;
         addEventListener(Event.ENTER_FRAME,this.effHandler);
      }
      
      private function MOUSE_WHEEL_(param1:MouseEvent) : void
      {
         if(param1.delta > 0)
         {
            this.paginationFriend.back(null);
         }
         else
         {
            this.paginationFriend.next(null);
         }
      }
   }
}

