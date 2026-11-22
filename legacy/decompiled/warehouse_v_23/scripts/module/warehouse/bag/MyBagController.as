package module.warehouse.bag
{
   import common.Consts;
   import entities.BagItem;
   import events.CommonEvent;
   import flash.events.Event;
   import framework.base.Controller;
   import interfaces.IMsgCenter;
   import module.GameGuide;
   
   public class MyBagController extends Controller
   {
      
      private var _buyType:String = "";
      
      private var _openLater:Boolean;
      
      public function MyBagController()
      {
         super(null);
         this._openLater = false;
      }
      
      public function get view() : MyBagView
      {
         return m_view as MyBagView;
      }
      
      private function showFishGuide() : void
      {
         var _loc1_:GameGuide = GameGuide.instance();
         if(_loc1_.currentStep == GameGuide.WATER_BAG_ICON_FISH)
         {
            this.view.switchTab(1);
            _loc1_.showStep(GameGuide.WATER_BAG_FISH_ITEM);
            _loc1_.autoHide(3);
         }
      }
      
      private function onShowMyPack(param1:CommonEvent) : void
      {
         if(param1.data != null && param1.data["close"] == true)
         {
            if(m_view != null)
            {
               m_view.show(false);
            }
         }
         else
         {
            if(m_view == null)
            {
               m_view = new MyBagView(this);
               if(m_module != null && m_module.container != null)
               {
                  m_module.container.addChild(m_view);
               }
            }
            if(this.model.dirty == false)
            {
               this.view.toggleVisible();
               this.showFishGuide();
            }
            else
            {
               this._openLater = true;
               this.model.reload();
               GameGuide.instance().hide();
            }
         }
      }
      
      private function onBagDirty(param1:Event) : void
      {
         if(this.model != null)
         {
            this.model.dirty = true;
         }
         if(Boolean(m_view) && Boolean(m_view.visible))
         {
            if(this._buyType == Consts.ITEM_TYPE_FISH || this._buyType == Consts.ITEM_TYPE_SEED)
            {
               this.model.reload();
            }
         }
      }
      
      private function onDataLoaded(param1:CommonEvent) : void
      {
         if(this._openLater == true)
         {
            this.view.show(true);
            this.showFishGuide();
         }
         else if(m_view)
         {
            m_view.updateBag(parseInt(this._buyType));
         }
         this._openLater = false;
      }
      
      override public function initialze() : void
      {
         super.initialze();
         if(m_module.container == null)
         {
            return;
         }
         if(m_model == null)
         {
            m_model = new MyBagModel();
         }
         this.registerListeners();
      }
      
      private function onBuyItemSuccess(param1:CommonEvent) : void
      {
         if(Boolean(param1) && Boolean(param1.data))
         {
            this._buyType = param1.data["type"];
         }
         else
         {
            this._buyType = "";
         }
         this.onBagDirty(param1);
      }
      
      private function onPoolOrLandIsFull(param1:Event) : void
      {
         if(m_view)
         {
            m_view.onPoolOrLandIsFull(param1);
         }
      }
      
      private function onBagRemoved(param1:CommonEvent) : void
      {
         if(param1 == null || param1.data == null)
         {
            return;
         }
         var _loc2_:int = param1.data["id"] as int;
         var _loc3_:int = param1.data["type"] as int;
         var _loc4_:BagItem = this.model.getItem(_loc2_,_loc3_);
         if(_loc4_ != null && _loc4_._amount > 0)
         {
            --_loc4_._amount;
            if(_loc4_._amount <= 0)
            {
               if(m_view)
               {
                  m_model.deleteItem(_loc2_,_loc3_);
                  m_view.updateBag(_loc3_);
               }
               setCursor(Consts.CURSOR_STYLE_ARROW,"");
            }
            else
            {
               m_view.updateBag(_loc3_);
            }
            this.onBagDirty(param1);
         }
      }
      
      public function get model() : MyBagModel
      {
         if(m_model != null)
         {
            return m_model as MyBagModel;
         }
         return null;
      }
      
      private function onBagAdded(param1:CommonEvent) : void
      {
         this.onBagDirty(param1);
      }
      
      private function registerListeners() : void
      {
         var _loc1_:IMsgCenter = m_module.app as IMsgCenter;
         if(_loc1_ != null)
         {
            _loc1_.addEventListener(Consts.MSG_SHOW_PACK,this.onShowMyPack,false,0,true);
            _loc1_.addEventListener(Consts.DATA_BUY_ITEM_ADD,this.onBuyItemSuccess,false,0,true);
            _loc1_.addEventListener(Consts.DATA_BAG_RELOAD_FLAG,this.onBagDirty,false,0,true);
            _loc1_.addEventListener(Consts.DATA_BAG_DATA_REMOVE,this.onBagRemoved,false,0,true);
            _loc1_.addEventListener(Consts.DATA_BAG_DATA_ADD,this.onBagAdded,false,0,true);
         }
         m_model.addEventListener(MyBagModel.EVENT_INITIALZED,this.onDataLoaded,false,0,true);
         m_module.app.addEventListener(Consts.CLOSE_MY_BAG,this.onPoolOrLandIsFull,false,0,true);
      }
      
      override public function finalize() : void
      {
         super.finalize();
      }
   }
}

