package module.warehouse.house
{
   import com.greensock.TweenLite;
   import com.qzone.farm.api.interfaces.IPluginProxy;
   import common.CommonData;
   import common.Consts;
   import common.Language;
   import common.Session;
   import entities.WarehouseCrop;
   import events.CommonEvent;
   import flash.display.Stage;
   import flash.events.Event;
   import framework.api.PluginManager;
   import framework.base.BasePage;
   import framework.base.Controller;
   import interfaces.IMsgCenter;
   import module.warehouse.house.widgets.CardsPage;
   import module.warehouse.house.widgets.FlowerCard;
   import module.warehouse.house.widgets.SendFlowerWindow;
   import module.warehouse.house.widgets.WarehouseFishPage;
   
   public class WarehouseController extends Controller
   {
      
      private var _tempID:int;
      
      public function WarehouseController()
      {
         super(null);
      }
      
      private function onSellSeedSuccess(param1:CommonEvent) : void
      {
         var e:CommonEvent = param1;
         module.app.dispatchEvent(new Event(Consts.DATA_BAG_RELOAD_FLAG));
         Session.getInstance().updateHostAccount(e.data["money"],0,0);
         openFloat(Consts.FLOAT_TYPE_TEXTTIP,{
            "text":e.data["direction"],
            "parent":this.view.currentPage
         });
         this.model.seedDirty = true;
         TweenLite.delayedCall(0.5,function():void
         {
            model.loadSeeds();
         });
      }
      
      private function onSendFlower(param1:CommonEvent) : void
      {
         if(param1 == null || param1.data == null)
         {
            return;
         }
         if(this.model != null)
         {
            this.model.sendFlower(param1.data["uin"],param1.data["word"],param1.data["flower"]);
         }
      }
      
      private function onSellPlantSuccess(param1:CommonEvent) : void
      {
         var c:WarehouseCrop = null;
         var x:int = 0;
         var y:int = 0;
         var stg:Stage = null;
         var pp:IPluginProxy = null;
         var e:CommonEvent = param1;
         module.app.dispatchEvent(new CommonEvent(Consts.MSG_CHECK_TASK,{"sale":e.data}));
         Session.getInstance().updateHostAccount(e.data["money"],0,0);
         if(this.view.parent == null)
         {
            x = 0;
            y = 0;
            stg = CommonData._root["stage"] as Stage;
            if(stg != null)
            {
               x = (stg.stageWidth - 313) * 0.5;
               y = (stg.stageHeight - 87) * 0.5;
            }
            openFloat(Consts.FLOAT_TYPE_TEXTTIP,{
               "text":e.data["direction"],
               "parent":null,
               "x":x,
               "y":y
            });
         }
         else
         {
            openFloat(Consts.FLOAT_TYPE_TEXTTIP,{
               "text":e.data["direction"],
               "parent":this.view.currentPage || this.view
            });
         }
         module.app.dispatchEvent(new CommonEvent(Consts.DATA_CROP_RELOAD_FLAG,null));
         this.model.cropDirty = true;
         TweenLite.delayedCall(0.5,function():void
         {
            model.loadCrops();
         });
         for each(c in this.model.crops)
         {
            if(c._id == e.data["cId"])
            {
               pp = PluginManager.getInstance().getPluginByID(3);
               if(pp != null)
               {
                  pp.executeCommand(2001,{
                     "cId":c._id,
                     "left":c._amount - e.data["num"]
                  });
               }
               break;
            }
         }
      }
      
      private function showWarehouseSellEx(param1:int) : void
      {
         var wc:WarehouseCrop = null;
         var id:int = param1;
         if(id == 0)
         {
            return;
         }
         wc = null;
         if(this.model.cropDirty == false)
         {
            for each(wc in this.model.crops)
            {
               if(wc._id == id)
               {
                  this.view.showSellSeedWindow(wc);
                  return;
               }
            }
            m_module.app.dispatchEvent(new CommonEvent(Consts.MSG_NO_CROP_WAREHOUSE,id));
            return;
         }
         this.model.loadCrops();
         this._tempID = id;
         this.model.addEventListener(WarehouseModel.EVENT_DATA_CHANGED,function(param1:CommonEvent):void
         {
            if(param1.data["index"] != 0)
            {
               return;
            }
            param1.currentTarget.removeEventListener(param1.type,arguments.callee);
            for each(wc in model.crops)
            {
               if(wc._id == _tempID)
               {
                  view.showSellSeedWindow(wc);
                  return;
               }
            }
            m_module.app.dispatchEvent(new CommonEvent(Consts.MSG_NO_CROP_WAREHOUSE,_tempID));
         });
      }
      
      private function onBuyItemSuccess(param1:CommonEvent) : void
      {
         if(param1 == null || param1.data == null)
         {
            return;
         }
         if(param1.data["cId"] != undefined && param1.data["type"] == Consts.ITEM_TYPE_SEED)
         {
            this.model.seedDirty = true;
         }
      }
      
      private function onSellAllSuccess(param1:CommonEvent) : void
      {
         module.app.dispatchEvent(new CommonEvent(Consts.MSG_CHECK_TASK,{"sale":param1.data}));
         var _loc2_:String = Language.replaceText("saleAllFnText",{"money":param1.data["money"]});
         openFloat(Consts.FLOAT_TYPE_TEXTTIP,{
            "text":_loc2_,
            "parent":this.view.currentPage
         });
         Session.getInstance().updateHostAccount(param1.data["money"],0,0);
         this.model.cropDirty = true;
         this.model.loadCrops();
      }
      
      private function onDataModelChanged(param1:CommonEvent) : void
      {
         if(param1 == null || param1.data == null)
         {
            return;
         }
         if(param1.data["index"] == 2)
         {
            module.app.dispatchEvent(new Event(Consts.MY_FLOWER_LOADED));
         }
      }
      
      private function onNeedReloadFishData(param1:CommonEvent) : void
      {
         if(this.model != null)
         {
            this.model.fishDirty = true;
         }
      }
      
      private function onWarehouseItemRemoved(param1:CommonEvent) : void
      {
         if(param1 == null || param1.data == null || param1.data["id"] == undefined)
         {
            return;
         }
         var _loc2_:int = param1.data["id"] as int;
         var _loc3_:String = param1.data["type"].toString();
         if(_loc3_ != Consts.ITEM_TYPE_SEED)
         {
            return;
         }
         if(this.model.removeSeed(_loc2_) == true)
         {
            useSystemCursor(true);
         }
      }
      
      private function onShowWarehouseSell(param1:CommonEvent) : void
      {
         if(param1 == null || param1.data == null)
         {
            return;
         }
         if(param1.data is WarehouseCrop)
         {
            this.view.showSellSeedWindow(param1.data as WarehouseCrop);
         }
         else
         {
            this.showWarehouseSellEx(param1.data["id"] as int);
         }
      }
      
      private function onCropPriceChanged(param1:CommonEvent) : void
      {
         var _loc2_:WarehouseCrop = null;
         if(param1 == null || param1.data == null)
         {
            return;
         }
         for each(_loc2_ in this.model.crops)
         {
            if(_loc2_._id == param1.data["cId"])
            {
               _loc2_._price = (param1.data["times"] as int) * (param1.data["price"] as int);
               break;
            }
         }
      }
      
      private function onSellAllFishSuccess(param1:CommonEvent) : void
      {
         var _loc2_:String = Language.replaceText("saleAllFishFnText",{"money":param1.data["money"]});
         openFloat(Consts.FLOAT_TYPE_TEXTTIP,{
            "text":_loc2_,
            "parent":this.view.currentPage
         });
         Session.getInstance().updateHostAccount(param1.data["money"],0,0);
         this.model.fishDirty = true;
         this.model.loadFishs();
      }
      
      private function registerListeners() : void
      {
         if(m_module == null || m_module.app == null)
         {
            return;
         }
         if(m_model != null)
         {
            m_model.addEventListener(WarehouseModel.EVENT_SELLALL_SUCCESS,this.onSellAllSuccess,false,0,true);
            m_model.addEventListener(WarehouseModel.EVENT_SELLPLANT_SUCCESS,this.onSellPlantSuccess,false,0,true);
            m_model.addEventListener(WarehouseModel.EVENT_SELLSEED_SUCCESS,this.onSellSeedSuccess,false,0,true);
            m_model.addEventListener(WarehouseModel.EVENT_SELLALLSEEDS_SUCCESS,this.onSellAllSeedsSuccess,false,0,true);
            m_model.addEventListener(WarehouseModel.EVENT_DATA_CHANGED,this.onDataModelChanged,false,0,true);
            m_model.addEventListener(WarehouseModel.EVENT_NET_TRANSACTION_ERROR,this.onNetTransactionFailed,false,0,true);
            m_model.addEventListener(WarehouseModel.EVENT_SELLALLFISHS_SUCCESS,this.onSellAllFishSuccess,false,0,true);
            m_model.addEventListener(WarehouseModel.EVENT_SELLFISH_SUCCESS,this.onSellFishSuccess,false,0,true);
         }
         var _loc1_:IMsgCenter = m_module.app as IMsgCenter;
         if(_loc1_ != null)
         {
            _loc1_.addEventListener(Consts.MSG_SHOW_WAREHOUSE,this.onShowWarehouse,false,0,true);
            _loc1_.addEventListener(Consts.MSG_SHOW_WAREHOUSE_SELL,this.onShowWarehouseSell,false,0,true);
            _loc1_.addEventListener(Consts.DATA_BUY_ITEM_ADD,this.onBuyItemSuccess,false,0,true);
            _loc1_.addEventListener(Consts.DATA_BAG_DATA_REMOVE,this.onWarehouseItemRemoved,false,0,true);
            _loc1_.addEventListener(Consts.DATA_CROP_RELOAD_FLAG,this.onNeedReloadData,false,0,true);
            _loc1_.addEventListener(Consts.DATA_FISH_RELOAD_FLAG,this.onNeedReloadFishData,false,0,true);
            _loc1_.addEventListener(Consts.MSG_FLOWER_DELETED,this.onFlowerDeleted,false,0,true);
            _loc1_.addEventListener(Consts.MSG_FLOWER_SEND,this.onSendFlower,false,0,true);
            _loc1_.addEventListener("__PLUGIN_3_PRICE__",this.onCropPriceChanged,false,0,true);
         }
      }
      
      private function onNetTransactionFailed(param1:CommonEvent) : void
      {
         if(param1 != null && param1.data != null)
         {
            openWindow(Consts.WINDOW_NAME_ALERT,{
               "type":Consts.ALERT_TYPE_ERROR,
               "text":param1.data["error"]
            });
         }
      }
      
      override public function finalize() : void
      {
         super.finalize();
      }
      
      private function onNeedReloadData(param1:CommonEvent) : void
      {
         if(this.model != null)
         {
            this.model.cropDirty = true;
            this.model.seedDirty = true;
         }
      }
      
      public function get view() : WarehouseView
      {
         return m_view as WarehouseView;
      }
      
      private function onFlowerDeleted(param1:CommonEvent) : void
      {
         if(param1 == null || param1.data == null)
         {
            return;
         }
         if(this.model != null)
         {
            this.model.removeMyFlower(param1.data);
         }
      }
      
      private function onShowWarehouse(param1:CommonEvent) : void
      {
         var _loc2_:BasePage = null;
         if(param1.data == null)
         {
            m_module.app.farmView.winCtrl.open(m_view);
            this.model.cropDirty = true;
            this.model.loadCrops();
            _loc2_ = this.view.currentPage;
            if(_loc2_ != null && _loc2_ is WarehouseFishPage)
            {
               this.model.loadFishs();
            }
            if(_loc2_ != null && _loc2_ is CardsPage)
            {
               this.model.loadCrystal();
            }
         }
         else if(param1.data["openWithSeeds"] == true)
         {
            m_module.app.farmView.winCtrl.open(m_view);
            this.view.switchTab(4);
            this.model.loadSeeds();
         }
         else if(param1.data["openWithFlower"] == true)
         {
            m_module.app.farmView.winCtrl.open(m_view);
            this.view.switchTab(3);
            this.model.loadMyFlowers();
         }
         else if(param1.data["openWithCrystal"] == true)
         {
            m_module.app.farmView.winCtrl.open(m_view);
            this.view.switchTab(5);
            this.model.loadCrystal();
         }
      }
      
      public function get model() : WarehouseModel
      {
         return m_model as WarehouseModel;
      }
      
      override public function initialze() : void
      {
         super.initialze();
         if(m_model == null)
         {
            m_model = new WarehouseModel();
         }
         this.registerListeners();
         if(m_view == null)
         {
            m_view = new WarehouseView(this);
         }
         if(m_module != null)
         {
            m_module.app.farmView.winCtrl.register(Consts.WINDOW_NAME_SENDFLOWER,SendFlowerWindow);
            m_module.app.farmView.winCtrl.register(Consts.WINDOW_NAME_FLOWER_CARD,FlowerCard);
         }
      }
      
      private function onSellAllSeedsSuccess(param1:CommonEvent) : void
      {
         this.onSellSeedSuccess(param1);
      }
      
      private function onSellFishSuccess(param1:CommonEvent) : void
      {
         var _loc2_:String = Language.replaceText("saleFishText",{
            "money":param1.data["money"],
            "num":param1.data["number"],
            "name":param1.data["name"]
         });
         openFloat(Consts.FLOAT_TYPE_TEXTTIP,{
            "text":_loc2_,
            "parent":this.view.currentPage
         });
         Session.getInstance().updateHostAccount(param1.data["money"],0,0);
         this.model.fishDirty = true;
         this.model.loadFishs();
      }
   }
}

