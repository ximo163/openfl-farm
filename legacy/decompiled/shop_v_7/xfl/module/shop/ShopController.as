package module.shop
{
   import com.qzone.utils.StringUtil;
   import common.CommonData;
   import common.Consts;
   import common.Language;
   import common.Session;
   import entities.Dog;
   import entities.Item;
   import entities.Seed;
   import events.CommonEvent;
   import flash.display.Stage;
   import framework.api.beast.BeastAPI;
   import framework.base.Controller;
   import interfaces.IMsgCenter;
   import module.GameGuide;
   
   public class ShopController extends Controller
   {
      
      private var _tempID:int;
      
      public function ShopController()
      {
         super(null);
      }
      
      private function registerListeners() : void
      {
         if(m_module == null || m_module.app == null)
         {
            return;
         }
         var _loc1_:IMsgCenter = m_module.app as IMsgCenter;
         if(_loc1_ != null)
         {
            _loc1_.addEventListener(Consts.MSG_SHOW_SHOP,this.onShowShop,false,0,true);
            _loc1_.addEventListener(Consts.MSG_SHOW_BUY_DOG_FOOD,this.onShowBuyDogFood,false,0,true);
            _loc1_.addEventListener(Consts.MSG_SHOW_BUY_SEED,this.onShowBuySeed,false,0,true);
         }
         this.model.addEventListener(ShopModel.EVENT_BUY_SEED_SUCCESS,this.onBuySeedSuccess,false,0,true);
         this.model.addEventListener(ShopModel.EVENT_BUY_SEED_FAIL,this.onReportError,false,0,true);
         this.model.addEventListener(ShopModel.EVENT_BUY_FISH_SUCCESS,this.onBuyFishSuccess,false,0,true);
         this.model.addEventListener(ShopModel.EVENT_BUY_FISH_FAIL,this.onReportError,false,0,true);
         this.model.addEventListener(ShopModel.EVENT_BUY_TOOL_SUCCESS,this.onBuyToolSuccess,false,0,true);
         this.model.addEventListener(ShopModel.EVENT_BUY_TOOL_FAIL,this.onReportError,false,0,true);
         this.model.addEventListener(ShopModel.EVENT_BUY_DIY_SUCCESS,this.onBuyDiySuccess,false,0,true);
         this.model.addEventListener(ShopModel.EVENT_BUY_DIY_FAIL,this.onReportError,false,0,true);
         this.model.addEventListener(ShopModel.EVENT_UNLOCK_FISH_SUCCESS,this.onUnlockFishSuccess,false,0,true);
         this.model.addEventListener(ShopModel.EVENT_NORMAL_ERROR,this.onReportError,false,0,true);
      }
      
      private function onBuyFishSuccess(param1:CommonEvent) : void
      {
         if(param1 == null || param1.data == null)
         {
            return;
         }
         var _loc2_:* = param1.data;
         Session.getInstance().updateHostAccount(parseInt(_loc2_["money"]),0,0);
         var _loc3_:Object = {
            "money":Math.abs(_loc2_["money"]),
            "num":_loc2_["num"],
            "name":_loc2_["name"]
         };
         var _loc4_:String = Language.replaceText("buyFishFnText",_loc3_);
         this.openFloat(Consts.FLOAT_TYPE_TEXTTIP,{
            "text":_loc4_,
            "parent":this.view.currentPage
         });
         _loc2_["type"] = Consts.ITEM_TYPE_FISH;
         var _loc5_:IMsgCenter = m_module.app as IMsgCenter;
         _loc5_.dispatchEvent(new CommonEvent(Consts.DATA_BUY_ITEM_ADD,_loc2_));
         this.view.showArrowOnClose = 1;
      }
      
      public function get view() : ShopView
      {
         return m_view as ShopView;
      }
      
      private function onBuyToolSuccess(param1:CommonEvent) : void
      {
         var _loc4_:Dog = null;
         if(param1 == null || param1.data == null)
         {
            return;
         }
         var _loc2_:* = param1.data;
         var _loc3_:IMsgCenter = m_module.app as IMsgCenter;
         _loc3_.dispatchEvent(new CommonEvent(Consts.DATA_BUY_ITEM_ADD,_loc2_));
         if(_loc2_["type"] == Consts.ITEM_TYPE_DOG)
         {
            _loc4_ = new Dog(null);
            _loc4_._dogId = _loc2_["tId"];
            _loc4_._isHungry = 0;
            _loc3_.dispatchEvent(new CommonEvent(Consts.DATA_DOG_CHANGED,_loc4_));
            _loc3_.dispatchEvent(new CommonEvent(Consts.MSG_SWITCH_USER,null));
            _loc3_.dispatchEvent(new CommonEvent(Consts.DATA_DECORATE_RELOAD_FLAG,null));
         }
         if(_loc2_["__buyType"] == 2)
         {
            this.openWindow(Consts.WINDOW_NAME_ALERT,{
               "type":Consts.ALERT_TYPE_SUCCESS,
               "text":"购买成功"
            });
         }
         else if(_loc2_["__buyType"] == 1 || _loc2_["__buyType"] == 0)
         {
            Session.getInstance().updateHostAccount(parseInt(_loc2_["money"]),0,_loc2_["FB"]);
            this.openWindow(Consts.WINDOW_NAME_ALERT,{
               "type":Consts.ALERT_TYPE_SUCCESS,
               "text":"购买成功"
            });
         }
      }
      
      private function onUnlockFishSuccess(param1:CommonEvent) : void
      {
         var xml:XML;
         var msg:String;
         var data:Object;
         var crystalName:String = null;
         var e:CommonEvent = param1;
         if(e == null || e.data == null)
         {
            return;
         }
         data = e.data;
         Session.getInstance().updateHostAccount(parseInt(data["money"]),0,0);
         xml = BeastAPI.getInstance().iniData;
         msg = "鱼苗解锁成功，共花费金币<font color=\'#FF6600\'>" + Math.abs(data["money"]) + "</font>";
         if(data.hasOwnProperty("crystal_num") && data.hasOwnProperty("crystal_id"))
         {
            crystalName = xml.crystal.info.(@id == data["crystal_id"].toString()).@name;
            msg += "，" + crystalName + "<font color=\'#FF6600\'>" + data["crystal_num"] + "</font>个";
         }
         this.openFloat(Consts.FLOAT_TYPE_TEXTTIP,{
            "text":msg,
            "parent":this.view.currentPage
         });
         GameGuide.instance().showStep(GameGuide.WATER_FISH_ITEM_AGAIN);
         GameGuide.instance().autoHide(5);
      }
      
      public function get model() : ShopModel
      {
         return m_model as ShopModel;
      }
      
      private function onBuySeedSuccess(param1:CommonEvent) : void
      {
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:Stage = null;
         if(param1 == null || param1.data == null)
         {
            return;
         }
         var _loc2_:* = param1.data;
         Session.getInstance().updateHostAccount(parseInt(_loc2_["money"]),0,0);
         var _loc3_:Object = {
            "money":Math.abs(_loc2_["money"]),
            "num":_loc2_["num"],
            "cName":_loc2_["cName"]
         };
         var _loc4_:String = Language.replaceText("buySeedFnText",_loc3_);
         if(this.view.parent == null)
         {
            _loc6_ = 0;
            _loc7_ = 0;
            _loc8_ = CommonData._root["stage"] as Stage;
            if(_loc8_ != null)
            {
               _loc6_ = (_loc8_.stageWidth - 313) * 0.5;
               _loc7_ = (_loc8_.stageHeight - 87) * 0.5;
            }
            this.openFloat(Consts.FLOAT_TYPE_TEXTTIP,{
               "text":_loc4_,
               "parent":null,
               "x":_loc6_,
               "y":_loc7_
            });
         }
         else
         {
            this.openFloat(Consts.FLOAT_TYPE_TEXTTIP,{
               "text":_loc4_,
               "parent":this.view.currentPage || this.view
            });
         }
         _loc2_["type"] = Consts.ITEM_TYPE_SEED;
         var _loc5_:IMsgCenter = m_module.app as IMsgCenter;
         _loc5_.dispatchEvent(new CommonEvent(Consts.DATA_BUY_ITEM_ADD,_loc2_));
      }
      
      private function showBuySeedEx(param1:int, param2:String) : void
      {
         var seed:Seed = null;
         var it:Item = null;
         var id:int = param1;
         var type:String = param2;
         if(id == 0)
         {
            return;
         }
         if(type == null || type == "" || type == "seed")
         {
            for each(seed in this.model.seeds)
            {
               if(seed._id == id)
               {
                  this.view.showBuySeedWindow(seed);
                  return;
               }
            }
            this.model.loadSeedsInfo();
         }
         else if(type == "item")
         {
            for each(it in this.model.items)
            {
               if(it._id == id)
               {
                  this.view.showBuyItemWindow(it,false);
                  break;
               }
            }
            this.model.loadItemsInfo();
         }
         this._tempID = id;
         this.model.addEventListener(ShopModel.EVENT_SHOP_DATA_LOADED,function(param1:CommonEvent):void
         {
            var _loc3_:Seed = null;
            var _loc4_:Item = null;
            param1.currentTarget.removeEventListener(param1.type,arguments.callee);
            if(param1.data["index"] == 0)
            {
               for each(_loc3_ in model.seeds)
               {
                  if(_loc3_._id == _tempID)
                  {
                     view.showBuySeedWindow(_loc3_);
                     break;
                  }
               }
            }
            else if(param1.data["index"] == 2)
            {
               for each(_loc4_ in model.items)
               {
                  if(_loc4_._id == _tempID)
                  {
                     view.showBuyItemWindow(_loc4_,false);
                     break;
                  }
               }
            }
         });
      }
      
      override public function initialze() : void
      {
         super.initialze();
         if(m_model == null)
         {
            m_model = new ShopModel();
         }
         this.registerListeners();
         if(m_view == null)
         {
            m_view = new ShopView(this);
         }
      }
      
      private function onShowBuyDogFood(param1:CommonEvent) : void
      {
         if(param1 == null || param1.data == null)
         {
            return;
         }
         this.view.showBuyItemWindow(param1.data as Item,true);
      }
      
      private function onShowShop(param1:CommonEvent) : void
      {
         var _loc2_:int = 0;
         if(param1.data == null)
         {
            _loc2_ = this.view.currentPageIndex;
            if(_loc2_ == -1)
            {
               _loc2_ = 0;
            }
            if(this.model.isEmpty(_loc2_) == true)
            {
               if(_loc2_ == 0)
               {
                  this.model.loadSeedsInfo();
               }
               else if(_loc2_ == 1)
               {
                  this.model.loadFishInfo();
               }
               else if(_loc2_ == 2)
               {
                  this.model.loadItemsInfo();
               }
               else if(_loc2_ == 3)
               {
                  this.model.loadDecorsInfo();
               }
            }
            m_module.app.farmView.winCtrl.open(m_view);
         }
         else
         {
            m_module.app.farmView.winCtrl.open(m_view);
            _loc2_ = int(param1.data["tabIndex"]);
            if(this.model.isEmpty(_loc2_) == true)
            {
               if(_loc2_ == 0)
               {
                  this.model.loadSeedsInfo();
               }
               else if(_loc2_ == 1)
               {
                  this.model.loadFishInfo();
               }
               else if(_loc2_ == 2)
               {
                  this.model.loadItemsInfo();
               }
               else if(_loc2_ == 3)
               {
                  this.model.loadDecorsInfo();
               }
            }
            (m_view as ShopView).currentPageIndex = _loc2_;
         }
         if(_loc2_ == 1)
         {
            GameGuide.instance().showStep(GameGuide.WATER_FISH_ITEM);
            GameGuide.instance().autoHide(5);
         }
         else
         {
            GameGuide.instance().showStep(GameGuide.WATER_FISH_TAB);
            GameGuide.instance().autoHide(5);
         }
      }
      
      private function onReportError(param1:CommonEvent) : void
      {
         var _loc3_:String = null;
         if(param1 == null || param1.data == null)
         {
            return;
         }
         var _loc2_:* = param1.data;
         if(_loc2_.hasOwnProperty("direction") == true && StringUtil.trim(_loc2_["direction"]) != "")
         {
            this.openWindow(Consts.WINDOW_NAME_ALERT,{
               "type":Consts.ALERT_TYPE_ERROR,
               "text":_loc2_["direction"]
            });
         }
         else if(_loc2_.hasOwnProperty("errorType") == true)
         {
            _loc3_ = _loc2_["errorType"];
            if(_loc3_ == "IOError" || _loc3_ == "httpStatus" || _loc3_ == "timeOut" || _loc3_ == "PHPError")
            {
               this.openWindow(Consts.WINDOW_NAME_ALERT,{
                  "type":Consts.ALERT_TYPE_ERROR,
                  "text":Language.L["请求超时，稍后再试"]
               });
            }
         }
      }
      
      private function onBuyDiySuccess(param1:CommonEvent) : void
      {
         var _loc4_:String = null;
         if(param1 == null || param1.data == null)
         {
            return;
         }
         var _loc2_:IMsgCenter = m_module.app as IMsgCenter;
         _loc2_.dispatchEvent(new CommonEvent(Consts.DATA_DECORATE_RELOAD_FLAG,null));
         var _loc3_:* = param1.data;
         if(_loc3_["__buyType"] == 1)
         {
            if(_loc3_["__exp"] > 0)
            {
               _loc2_.dispatchEvent(new CommonEvent(Consts.MSG_CHECK_LEVELUP,_loc3_["__exp"] as int));
               Session.getInstance().updateHostAccount(0,_loc3_["__exp"] as int,0);
               openWindow(Consts.WINDOW_NAME_ALERT,{
                  "type":Consts.ALERT_TYPE_SUCCESS,
                  "text":Language.L["购买装饰成功"]
               });
            }
         }
         else if(_loc3_["__buyType"] == 2)
         {
            openWindow(Consts.WINDOW_NAME_ALERT,{
               "type":Consts.ALERT_TYPE_SUCCESS,
               "text":"购买成功"
            });
         }
         else if(_loc3_["__buyType"] == 3)
         {
            if(_loc3_["__exp"] > 0)
            {
               _loc2_.dispatchEvent(new CommonEvent(Consts.MSG_CHECK_LEVELUP,_loc3_["__exp"] as int));
               Session.getInstance().updateHostAccount(0,_loc3_["__exp"] as int,0);
            }
         }
         else
         {
            Session.getInstance().updateHostAccount(_loc3_["money"],_loc3_["exp"],_loc3_["FB"]);
            _loc4_ = StringUtil.replaceText("购买成功，花费金币<font color=\"#FF6600\"> <b>{money}</b> </font>，获得经验<font color=\"#FF6600\"> <b>{exp}</b> </font>",{
               "money":Math.abs(_loc3_["money"]),
               "exp":_loc3_["exp"]
            });
            this.openFloat(Consts.FLOAT_TYPE_TEXTTIP,{
               "text":_loc4_,
               "parent":this.view.currentPage
            });
            _loc2_.dispatchEvent(new CommonEvent(Consts.MSG_LEVELUP,_loc3_));
         }
         this.view.setDiyBought(_loc3_["itemId"]);
      }
      
      private function onShowBuySeed(param1:CommonEvent) : void
      {
         if(param1 == null || param1.data == null)
         {
            return;
         }
         if(param1.data is Seed)
         {
            this.view.showBuySeedWindow(param1.data as Seed);
         }
         else
         {
            this.showBuySeedEx(param1.data["id"] as int,param1.data["type"]);
         }
      }
      
      override public function finalize() : void
      {
         super.finalize();
      }
   }
}

