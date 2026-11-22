package module.decorate
{
   import com.qzone.qui.containers.ViewStack;
   import com.qzone.qui.controls.Button;
   import com.qzone.qui.controls.TabBar;
   import common.Consts;
   import common.Language;
   import common.Session;
   import common.view.window.BaseWindow;
   import common.view.window.WindowControl;
   import common.view.window.WindowTabBarMaker;
   import entities.DecorateItem;
   import events.CommonEvent;
   import events.ViewEvent;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.text.TextFormat;
   import flash.utils.Dictionary;
   import framework.api.PluginManager;
   import framework.base.BaseTileItem;
   import interfaces.IMsgCenter;
   import module.decorate.widgets.*;
   
   public class DecorateView extends BaseWindow
   {
      
      private var m_decorPage:DecorsPage;
      
      private var m_boardPage:BoardsPage;
      
      private var m_viewStack:ViewStack;
      
      private var m_deselectDogCache:DecorateItem;
      
      private var m_tabNav:TabBar;
      
      private const WIDTH:uint = 400;
      
      private const HEIGHT:uint = 420;
      
      private var m_controller:DecorateController;
      
      public function DecorateView(param1:DecorateController)
      {
         super(param1.module.app as IMsgCenter);
         width = this.WIDTH;
         height = this.HEIGHT;
         title = Language.L["农场装饰"];
         windowName = Consts.WINDOW_NAME_DIY;
         mode = true;
         autoLayout = true;
         titleDefautFormat = new TextFormat("Verdana",16,16777215,true);
         this.m_deselectDogCache = null;
         this.m_controller = param1;
      }
      
      public function switchTab(param1:int) : void
      {
         if(param1 < 0 || param1 > this.m_tabNav.tabNum)
         {
            param1 = 0;
         }
         if(param1 == this.m_tabNav.selectedIndex)
         {
            return;
         }
         this.m_tabNav.selectedIndex = param1;
         this.onTabSwitched(null);
      }
      
      private function onTileItemClick(param1:ViewEvent) : void
      {
         var _loc3_:BoardRenderItem = null;
         var _loc4_:DecorRenderItem = null;
         var _loc5_:DecorateItem = null;
         var _loc6_:Boolean = false;
         if(param1 == null || param1.data == null)
         {
            return;
         }
         var _loc2_:WindowControl = this.m_controller.module.app.farmView.winCtrl;
         if(_loc2_ == null)
         {
            return;
         }
         if(param1.target is BoardRenderItem)
         {
            _loc3_ = param1.target as BoardRenderItem;
            this.m_controller.model.selectBoard(_loc3_.data["id"]);
         }
         else if(param1.target is DecorRenderItem)
         {
            _loc4_ = param1.target as DecorRenderItem;
            _loc5_ = _loc4_.data as DecorateItem;
            _loc6_ = _loc5_._status == 1 ? true : false;
            if(_loc5_._id > Consts.DECOR_DOG_BASE_ID)
            {
               if(_loc6_ == true)
               {
                  if(Session.getInstance().m_isDogHungry == false)
                  {
                     this.m_deselectDogCache = _loc5_;
                     this.m_controller.openWindow(Consts.WINDOW_NAME_CONFIRM,{
                        "width":380,
                        "height":270,
                        "title":"温馨提示",
                        "confirmFn":this.unUseDogComfirmFn,
                        "text":"您当前还有剩余狗粮，隐藏狗后，狗将不再抓摘取果实的好友。是否现在隐藏？\n 特别说明：隐藏狗后，还是会正常消耗狗粮。"
                     });
                     return;
                  }
               }
            }
            else if(_loc5_._id == -1)
            {
               if(_loc6_ == true)
               {
                  return;
               }
            }
            this.m_controller.model.selectDecorate(_loc5_);
         }
      }
      
      private function onLoadFailed(param1:CommonEvent) : void
      {
         if(param1 == null || param1.data == null)
         {
            return;
         }
         var _loc2_:String = param1.data["error"];
         var _loc3_:int = int(this.m_tabNav.selectedIndex);
         if(_loc3_ == 0)
         {
            this.m_decorPage.errText = _loc2_;
         }
      }
      
      private function onDataChanged(param1:CommonEvent) : void
      {
         var _loc3_:Dictionary = null;
         if(param1 == null || param1.data == null)
         {
            return;
         }
         var _loc2_:int = param1.data["index"] as int;
         if(_loc2_ == 0)
         {
            _loc3_ = param1.data["data"] as Dictionary;
            if(this.m_decorPage != null)
            {
               this.m_decorPage.refresh(_loc3_);
            }
         }
         else if(_loc2_ == 1)
         {
            if(this.m_boardPage != null)
            {
               this.m_boardPage.changeBoard(param1.data["newItemId"],param1.data["oldItemId"]);
            }
         }
      }
      
      private function onLinkClick(param1:ViewEvent) : void
      {
         if(param1 == null || param1.data == null)
         {
            return;
         }
         if(param1.data == "reload")
         {
            this.m_controller.model.dirty = true;
            this.m_controller.model.loadItems();
         }
      }
      
      override protected function init() : void
      {
         super.init();
         this.createTabs();
         var _loc1_:DecorateModel = this.m_controller.model;
         if(_loc1_ != null)
         {
            _loc1_.addEventListener(DecorateModel.EVENT_DATA_LOADED,this.onDataLoaded,false,0,true);
            _loc1_.addEventListener(DecorateModel.EVENT_DATA_CHANGED,this.onDataChanged,false,0,true);
            _loc1_.addEventListener(DecorateModel.EVENT_DATA_STATUS_CHANGED,this.onDataStatusChanged,false,0,true);
            _loc1_.addEventListener(DecorateModel.EVENT_DATA_LOADING,this.onDataLoading,false,0,true);
            _loc1_.addEventListener(DecorateModel.EVENT_DATA_FAILED,this.onLoadFailed,false,0,true);
            _loc1_.addEventListener(DecorateModel.EVENT_OPERATE_FAILED,this.onOperateFailed,false,0,true);
         }
      }
      
      private function onDataLoading(param1:CommonEvent) : void
      {
         if(param1 == null || param1.data == null)
         {
            return;
         }
         var _loc2_:Boolean = Boolean(param1.data["show"]);
         this.m_decorPage.loadingVisible = _loc2_;
      }
      
      private function onTileItemOver(param1:ViewEvent) : void
      {
         if(param1 == null || param1.data == null)
         {
            return;
         }
         var _loc2_:DecorateItem = param1.data as DecorateItem;
         if(_loc2_ == null)
         {
            return;
         }
         var _loc3_:Object = {
            "itemName":_loc2_._name,
            "validTime":_loc2_._validTime
         };
         this.m_controller.showTip(Consts.TIP_NAME_DIY_MOUSE,_loc3_);
      }
      
      private function unUseDogComfirmFn() : void
      {
         if(this.m_deselectDogCache == null)
         {
            return;
         }
         this.m_controller.model.selectDecorate(this.m_deselectDogCache);
         this.m_deselectDogCache = null;
      }
      
      private function createTabs() : void
      {
         this.m_viewStack = new ViewStack();
         this.m_tabNav = new TabBar();
         this.m_tabNav.viewStack = this.m_viewStack;
         WindowTabBarMaker.addTarget(this.m_tabNav);
         this.m_tabNav.x = 0;
         this.m_tabNav.y = 30;
         this.m_tabNav.width = this.WIDTH - 2;
         this.m_viewStack.y = this.m_tabNav.y + this.m_tabNav.height;
         this.m_viewStack.width = this.WIDTH - 2;
         this.m_viewStack.height = this.HEIGHT - this.m_viewStack.y;
         this.m_tabNav.addEventListener(Event.CHANGE,this.onTabSwitched);
         var _loc1_:DecorateModel = this.m_controller.model;
         if(_loc1_ == null)
         {
            return;
         }
         this.m_decorPage = new DecorsPage(this,this.WIDTH,this.HEIGHT);
         this.m_decorPage.addEventListener(ViewEvent.LINK_CLICK,this.onReloadDecors,false,0,true);
         this.m_decorPage.addEventListener(BaseTileItem.CHILD_CLICK,this.onTileItemClick,false,0,true);
         this.m_decorPage.addEventListener(BaseTileItem.CHILD_OVER,this.onTileItemOver,false,0,true);
         this.m_decorPage.addEventListener(BaseTileItem.CHILD_OUT,this.onTileItemOut,false,0,true);
         this.m_tabNav.addTab("装饰",NaN,24);
         this.m_viewStack.addView(this.m_decorPage);
         this.m_boardPage = new BoardsPage(this,this.WIDTH,this.HEIGHT);
         this.m_boardPage.addEventListener(BaseTileItem.CHILD_CLICK,this.onTileItemClick,false,0,true);
         this.m_boardPage.addEventListener(BaseTileItem.CHILD_OVER,this.onTileItemOver,false,0,true);
         this.m_boardPage.addEventListener(BaseTileItem.CHILD_OUT,this.onTileItemOut,false,0,true);
         this.m_tabNav.addTab("告示牌",NaN,24);
         this.m_viewStack.addView(this.m_boardPage);
         PluginManager.getInstance().amountPlugins(Consts.PLUGIN_AMOUNT_DECORATE,this.m_tabNav,{
            "width":NaN,
            "height":24,
            "index":2
         });
         addChild(this.m_viewStack);
         addChild(this.m_tabNav);
      }
      
      private function onDataLoaded(param1:CommonEvent) : void
      {
         var _loc3_:Dictionary = null;
         var _loc4_:Array = null;
         if(param1 == null || param1.data == null)
         {
            return;
         }
         var _loc2_:int = param1.data["index"] as int;
         if(_loc2_ == 0)
         {
            _loc3_ = param1.data["data"] as Dictionary;
            this.m_decorPage.buildDecorateList(_loc3_);
         }
         else if(_loc2_ == 1)
         {
            _loc4_ = param1.data["data"] as Array;
            this.m_boardPage.dataList = _loc4_;
         }
      }
      
      public function switchTabByName(param1:String) : void
      {
         var _loc5_:Button = null;
         if(param1 == null || param1 == "")
         {
            return;
         }
         var _loc2_:int = int(this.m_tabNav.tabNum);
         var _loc3_:Sprite = this.m_tabNav.content as Sprite;
         if(_loc3_ == null)
         {
            return;
         }
         var _loc4_:int = 0;
         while(_loc4_ < _loc2_)
         {
            _loc5_ = _loc3_.getChildAt(_loc4_) as Button;
            if(_loc5_ != null && _loc5_.text == param1)
            {
               if(this.m_tabNav.selectedIndex == _loc4_)
               {
                  return;
               }
               this.m_tabNav.selectedIndex = _loc4_;
               this.onTabSwitched(null);
               break;
            }
            _loc4_++;
         }
      }
      
      private function onOperateFailed(param1:CommonEvent) : void
      {
         if(param1 == null || param1.data == null)
         {
            return;
         }
         var _loc2_:String = param1.data["error"];
         this.m_controller.openWindow(Consts.WINDOW_NAME_ALERT,{
            "type":Consts.ALERT_TYPE_ERROR,
            "text":_loc2_
         });
      }
      
      private function onTabSwitched(param1:Event) : void
      {
         if(this.m_tabNav == null)
         {
            return;
         }
         var _loc2_:int = int(this.m_tabNav.selectedIndex);
         if(_loc2_ == 0)
         {
            this.m_controller.model.loadItems();
         }
         else if(_loc2_ == 1)
         {
            this.m_controller.model.loadBoards();
         }
         else if(_loc2_ == 2)
         {
            PluginManager.getInstance().onTabSwitched(Consts.PLUGIN_AMOUNT_DECORATE,2);
         }
         if(_loc2_ == 2)
         {
            this.height = this.HEIGHT - 100;
         }
         else
         {
            this.height = this.HEIGHT;
         }
      }
      
      private function onReloadDecors(param1:ViewEvent) : void
      {
         if(param1 == null || param1.data == null)
         {
            return;
         }
         if(param1.data == "reload")
         {
            if(param1.target == this.m_decorPage)
            {
               this.m_controller.model.dirty = true;
               this.m_controller.model.loadItems();
            }
         }
      }
      
      private function onTileItemOut(param1:ViewEvent) : void
      {
         this.m_controller.hideTip();
      }
      
      private function onDataStatusChanged(param1:CommonEvent) : void
      {
         if(param1 == null || param1.data == null)
         {
            return;
         }
         if(this.m_decorPage != null)
         {
            this.m_decorPage.forceRefresh(param1.data["type"],param1.data["id"]);
         }
      }
   }
}

