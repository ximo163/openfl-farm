package module.decorate
{
   import com.qzone.qfa.events.CommandEvent;
   import common.Consts;
   import common.Language;
   import common.Session;
   import common.Settings;
   import entities.DecorateItem;
   import events.CommonEvent;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import flash.utils.Dictionary;
   import framework.net.CommandDefs;
   import framework.net.NetHelper;
   import report.EventRecorder;
   
   public class DecorateModel extends EventDispatcher
   {
      
      internal static const EVENT_DATA_LOADING:String = "WarehouseDataLoading";
      
      internal static const EVENT_DATA_LOADED:String = "WarehouseDataLoaded";
      
      internal static const EVENT_DATA_FAILED:String = "WarehouseDataFailed";
      
      internal static const EVENT_DATA_CHANGED:String = "DataChanged";
      
      internal static const EVENT_DATA_STATUS_CHANGED:String = "DataStatusChanged";
      
      internal static const EVENT_OPERATE_FAILED:String = "OperateFailed";
      
      internal static const NOTIFY_REFRESH_MAINSCENE:String = "RefreshMainScene";
      
      private var m_requesting:Boolean;
      
      private var m_dirty:Boolean;
      
      private var m_myDogID:int;
      
      private var m_myBoardID:int;
      
      private var m_boardArray:Array;
      
      private var m_loading:Boolean;
      
      private var m_decorGroup:Dictionary;
      
      public function DecorateModel(param1:IEventDispatcher = null)
      {
         super(param1);
         this.m_decorGroup = null;
         this.m_dirty = true;
         this.m_boardArray = null;
         this.m_myBoardID = -1;
         this.m_myDogID = -1;
         this.m_loading = false;
         this.m_requesting = false;
         this.setMyDecorate(Session.getInstance().sceneDecorates);
      }
      
      private function onDeSelectDecorateSuccess(param1:CommandEvent) : void
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:String = null;
         var _loc6_:Array = null;
         var _loc7_:DecorateItem = null;
         var _loc2_:* = NetHelper.getVOData(param1);
         if(_loc2_ == null)
         {
            return;
         }
         this.m_requesting = false;
         if(_loc2_["code"] == "1")
         {
            _loc3_ = int(_loc2_["id"]);
            _loc4_ = int(param1.body["__body"]["type"]);
            for(_loc5_ in this.m_decorGroup)
            {
               _loc6_ = this.m_decorGroup[_loc5_];
               for each(_loc7_ in _loc6_)
               {
                  if(_loc7_._id == _loc3_ && _loc7_._type == _loc4_)
                  {
                     _loc7_._status = 0;
                     break;
                  }
               }
            }
            if(_loc4_ == Consts.DECOR_BACKGROUND)
            {
               this.setDefaultBackground();
            }
            dispatchEvent(new CommonEvent(EVENT_DATA_STATUS_CHANGED,{
               "type":_loc4_,
               "id":_loc3_
            }));
            dispatchEvent(new CommonEvent(NOTIFY_REFRESH_MAINSCENE,{
               "type":_loc4_,
               "id":-1
            }));
         }
      }
      
      public function set myBoardID(param1:int) : void
      {
         var _loc3_:* = undefined;
         if(this.m_myBoardID == param1)
         {
            return;
         }
         var _loc2_:int = this.m_myBoardID;
         this.m_myBoardID = param1;
         if(this.m_boardArray != null)
         {
            for each(_loc3_ in this.m_boardArray)
            {
               if(this.m_myBoardID != -1)
               {
                  if(_loc3_["id"] == this.m_myBoardID)
                  {
                     _loc3_["status"] = 1;
                  }
                  else
                  {
                     _loc3_["status"] = 0;
                  }
               }
               else if(_loc3_["id"] == _loc2_)
               {
                  _loc3_["status"] = 0;
                  break;
               }
            }
            dispatchEvent(new CommonEvent(EVENT_DATA_CHANGED,{
               "index":1,
               "newItemId":this.m_myBoardID,
               "oldItemId":_loc2_
            }));
         }
      }
      
      public function get myDogID() : int
      {
         return this.m_myDogID;
      }
      
      private function setDefaultBackground() : void
      {
         var _loc1_:* = undefined;
         var _loc2_:DecorateItem = null;
         for(_loc1_ in this.m_decorGroup)
         {
            for each(_loc2_ in this.m_decorGroup[_loc1_])
            {
               if(_loc2_._type == Consts.DECOR_BACKGROUND)
               {
                  if(_loc2_._id == -1)
                  {
                     _loc2_._status = 1;
                  }
                  else
                  {
                     _loc2_._status = 0;
                  }
               }
            }
         }
      }
      
      public function get dirty() : Boolean
      {
         return this.m_dirty;
      }
      
      public function loadBoards() : void
      {
         var _loc4_:Object = null;
         if(this.m_boardArray != null)
         {
            return;
         }
         this.m_boardArray = Settings.getInstance().getBillBoardData();
         this.m_boardArray = this.m_boardArray.reverse();
         var _loc1_:* = null;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         for each(_loc4_ in this.m_boardArray)
         {
            if(_loc4_["id"] == this.m_myBoardID)
            {
               _loc4_["status"] = 1;
            }
            else
            {
               _loc4_["status"] = 0;
            }
            _loc2_++;
         }
         dispatchEvent(new CommonEvent(EVENT_DATA_LOADED,{
            "index":1,
            "data":this.m_boardArray
         }));
      }
      
      public function set myDogID(param1:int) : void
      {
         var _loc3_:* = undefined;
         var _loc4_:Array = null;
         var _loc5_:DecorateItem = null;
         if(this.m_myDogID == param1)
         {
            return;
         }
         var _loc2_:int = this.m_myDogID;
         this.m_myDogID = param1;
         for(_loc3_ in this.m_decorGroup)
         {
            _loc4_ = this.m_decorGroup[_loc3_];
            if(this.m_myDogID != -1)
            {
               for each(_loc5_ in _loc4_)
               {
                  if(_loc5_._type == Consts.DECOR_DOG)
                  {
                     if(_loc5_._id == this.m_myDogID)
                     {
                        _loc5_._status = 1;
                     }
                     else
                     {
                        _loc5_._status = 0;
                     }
                  }
               }
            }
            else
            {
               for each(_loc5_ in _loc4_)
               {
                  if(_loc5_._type == Consts.DECOR_DOG && _loc5_._id == _loc2_)
                  {
                     _loc5_._status = 0;
                     break;
                  }
               }
            }
            dispatchEvent(new CommonEvent(EVENT_DATA_CHANGED,{
               "index":0,
               "data":this.m_decorGroup
            }));
         }
      }
      
      public function selectBoard(param1:int) : void
      {
         if(this.m_requesting == true)
         {
            return;
         }
         if(param1 < 0)
         {
            return;
         }
         if(this.m_myBoardID == param1)
         {
            this.m_requesting = true;
            NetHelper.sendRequest(CommandDefs.CMD_DEACTIVE_DECORATE,{
               "id":param1,
               "type":1
            },this.onDeSelectBoardSuccess,this.onDeSelectFailed);
         }
         else
         {
            this.m_requesting = true;
            NetHelper.sendRequest(CommandDefs.CMD_ACTIVE_DECORATE,{
               "id":param1,
               "type":1
            },this.onSelectBoardSuccess,this.onSelectFailed);
         }
      }
      
      public function resetLoadingFlags() : void
      {
         if(this.m_loading == true)
         {
            this.m_loading = false;
         }
         if(this.m_requesting == true)
         {
            this.m_requesting = false;
         }
      }
      
      private function onDataLoadSuccess(param1:CommandEvent) : void
      {
         var _loc4_:String = null;
         var _loc5_:Array = null;
         var _loc6_:Array = null;
         var _loc7_:Array = null;
         var _loc8_:String = null;
         var _loc9_:DecorateItem = null;
         var _loc10_:DecorateItem = null;
         var _loc2_:Object = NetHelper.getVOData(param1);
         if(_loc2_ == null)
         {
            return;
         }
         this.m_loading = false;
         this.m_dirty = false;
         var _loc3_:Array = _loc2_ as Array;
         if(_loc3_ == null || _loc3_.length == 0)
         {
            if(this.m_decorGroup != null)
            {
               for(_loc4_ in this.m_decorGroup)
               {
                  delete this.m_decorGroup[_loc4_];
               }
               this.m_decorGroup = null;
            }
            dispatchEvent(new CommonEvent(EVENT_DATA_LOADING,{"show":false}));
            dispatchEvent(new CommonEvent(EVENT_DATA_LOADED,{
               "index":0,
               "data":this.m_decorGroup
            }));
            return;
         }
         if(this.m_decorGroup == null)
         {
            this.m_decorGroup = new Dictionary();
         }
         _loc5_ = null;
         _loc6_ = null;
         _loc7_ = null;
         for(_loc8_ in this.m_decorGroup)
         {
            _loc5_ = this.m_decorGroup[_loc8_] as Array;
            if(_loc5_ != null && _loc5_.length > 0)
            {
               _loc5_.splice(0);
            }
         }
         for each(_loc9_ in _loc3_[0])
         {
            if(_loc6_ == null)
            {
               _loc6_ = [];
            }
            _loc6_.push(_loc9_);
            if(_loc9_._type == Consts.DECOR_DOG && _loc9_._status == 1)
            {
               this.myDogID = _loc9_._id;
            }
         }
         for each(_loc10_ in _loc3_[1])
         {
            if(_loc7_ == null)
            {
               _loc7_ = [];
            }
            _loc7_.push(_loc10_);
            if(_loc10_._type == Consts.DECOR_DOG && _loc10_._status == 1)
            {
               this.myDogID = _loc10_._id;
            }
         }
         this.m_decorGroup[0] = _loc6_;
         this.m_decorGroup[1] = _loc7_;
         dispatchEvent(new CommonEvent(EVENT_DATA_LOADING,{"show":false}));
         dispatchEvent(new CommonEvent(EVENT_DATA_LOADED,{
            "index":0,
            "data":this.m_decorGroup
         }));
         EventRecorder.recordSueecssEvent(EventRecorder.HF_GET_DIY_ITEMS,null,"cgi_farm_show_useritems");
      }
      
      private function onSelectBoardSuccess(param1:CommandEvent) : void
      {
         var _loc3_:int = 0;
         var _loc2_:* = NetHelper.getVOData(param1);
         if(_loc2_ == null)
         {
            return;
         }
         if(_loc2_["code"] == "1")
         {
            _loc3_ = int(_loc2_["id"]);
            this.myBoardID = _loc3_;
            dispatchEvent(new CommonEvent(NOTIFY_REFRESH_MAINSCENE,{
               "type":Consts.DECOR_BILLBOARD,
               "id":_loc3_
            }));
         }
         this.m_requesting = false;
      }
      
      public function setMyDecorate(param1:Object) : void
      {
         if(param1 == null)
         {
            return;
         }
         var _loc2_:String = Consts.DECOR_BILLBOARD.toString();
         if(param1[_loc2_] != undefined && param1[_loc2_]["itemId"] != undefined)
         {
            this.myBoardID = param1[_loc2_]["itemId"] as int;
         }
         _loc2_ = Consts.DECOR_DOG.toString();
         if(param1[_loc2_] != undefined && param1[_loc2_]["itemId"] != undefined)
         {
            this.myDogID = Consts.DECOR_DOG_BASE_ID + param1[_loc2_]["itemId"] as int;
         }
      }
      
      public function set dirty(param1:Boolean) : void
      {
         this.m_dirty = param1;
      }
      
      private function onDeSelectFailed(param1:CommandEvent) : void
      {
         var _loc2_:* = NetHelper.getVOData(param1);
         if(_loc2_ == null)
         {
            return;
         }
         dispatchEvent(new CommonEvent(EVENT_OPERATE_FAILED,{"error":"取消设置装饰失败"}));
         this.m_requesting = false;
      }
      
      private function onSelectFailed(param1:CommandEvent) : void
      {
         var _loc2_:* = NetHelper.getVOData(param1);
         if(_loc2_ == null)
         {
            return;
         }
         dispatchEvent(new CommonEvent(EVENT_OPERATE_FAILED,{"error":"设置装饰失败"}));
         this.m_requesting = false;
      }
      
      public function selectDecorate(param1:DecorateItem) : void
      {
         if(this.m_requesting == true)
         {
            return;
         }
         var _loc2_:Boolean = param1._status == 1 ? true : false;
         if(_loc2_ == true)
         {
            this.m_requesting = true;
            NetHelper.sendRequest(CommandDefs.CMD_DEACTIVE_DECORATE,{
               "id":param1._id,
               "type":param1._type
            },this.onDeSelectDecorateSuccess,this.onDeSelectFailed);
         }
         else
         {
            this.m_requesting = true;
            NetHelper.sendRequest(CommandDefs.CMD_ACTIVE_DECORATE,{
               "id":param1._id,
               "type":param1._type
            },this.onSelectDecorateSuccess,this.onSelectFailed);
         }
      }
      
      private function onNetError(param1:CommandEvent) : void
      {
         var _loc2_:* = NetHelper.getVOData(param1);
         if(_loc2_ == null)
         {
            return;
         }
         this.m_loading = false;
         var _loc3_:String = Language.L["请求超时，"] + "<a href=\'event:reload\'><u><font color=\'#ff6600\'>" + Language.L["点击重试"] + "</font></u></a>";
         dispatchEvent(new CommonEvent(EVENT_DATA_FAILED,{"error":_loc3_}));
         EventRecorder.recordErrorEvent(EventRecorder.HF_GET_DIY_ITEMS,null,EventRecorder.FAULT_ERROR,"cgi_farm_show_useritems");
      }
      
      private function reportError(param1:int, param2:String) : void
      {
         var _loc3_:String = null;
         if(param2 == "IOError" || param2 == "httpStatus" || param2 == "timeOut" || param2 == "PHPError")
         {
            _loc3_ = Language.L["请求超时，"] + "<a href=\'event:reload\'><u><font color=\'#ff6600\'>" + Language.L["点击重试"] + "</font></u></a>";
            dispatchEvent(new CommonEvent(EVENT_DATA_FAILED,{
               "index":param1,
               "error":_loc3_
            }));
         }
      }
      
      public function get myBoardID() : int
      {
         return this.m_myBoardID;
      }
      
      private function onDeSelectBoardSuccess(param1:CommandEvent) : void
      {
         var _loc3_:int = 0;
         var _loc2_:* = NetHelper.getVOData(param1);
         if(_loc2_ == null)
         {
            return;
         }
         if(_loc2_["code"] == "1")
         {
            _loc3_ = int(_loc2_["id"]);
            if(this.m_myBoardID == _loc3_)
            {
               this.myBoardID = -1;
            }
            dispatchEvent(new CommonEvent(NOTIFY_REFRESH_MAINSCENE,{
               "type":Consts.DECOR_BILLBOARD,
               "id":-1
            }));
         }
         this.m_requesting = false;
      }
      
      public function loadItems() : void
      {
         if(this.m_dirty == false)
         {
            return;
         }
         if(this.m_loading == true)
         {
            return;
         }
         this.m_loading = true;
         NetHelper.sendRequest(CommandDefs.CMD_GET_DIY_ITEMS,null,this.onDataLoadSuccess,this.onNetError);
         dispatchEvent(new CommonEvent(EVENT_DATA_LOADING,{"show":true}));
      }
      
      private function onSelectDecorateSuccess(param1:CommandEvent) : void
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:DecorateItem = null;
         var _loc6_:Array = null;
         var _loc7_:DecorateItem = null;
         var _loc8_:DecorateItem = null;
         var _loc9_:Array = null;
         var _loc10_:int = 0;
         var _loc11_:Boolean = false;
         var _loc12_:int = 0;
         var _loc13_:int = 0;
         var _loc2_:* = NetHelper.getVOData(param1);
         if(_loc2_ == null)
         {
            return;
         }
         this.m_requesting = false;
         if(_loc2_["code"] == "1")
         {
            _loc3_ = int(_loc2_["id"]);
            _loc4_ = int(param1.body["__body"]["type"]);
            _loc5_ = null;
            _loc6_ = this.m_decorGroup[1];
            _loc7_ = null;
            for each(_loc5_ in _loc6_)
            {
               if(_loc5_._type == _loc4_)
               {
                  if(_loc5_._id == _loc3_)
                  {
                     _loc5_._status = 1;
                     _loc7_ = _loc5_;
                  }
                  else
                  {
                     _loc5_._status = 0;
                  }
               }
            }
            if(_loc7_ == null)
            {
               return;
            }
            _loc8_ = null;
            _loc9_ = this.m_decorGroup[0];
            _loc10_ = int(_loc9_.length);
            _loc11_ = false;
            _loc12_ = 0;
            _loc13_ = 0;
            while(_loc13_ < _loc10_)
            {
               _loc8_ = _loc9_[_loc13_];
               if(_loc8_._type == _loc4_)
               {
                  if(_loc8_._id == _loc3_)
                  {
                     _loc12_ = 1;
                     _loc9_[_loc13_]._status = _loc7_._status;
                  }
                  else
                  {
                     _loc9_[_loc13_] = _loc7_;
                  }
                  _loc11_ = true;
                  break;
               }
               _loc13_++;
            }
            if(_loc11_ == false)
            {
               _loc9_.push(_loc7_);
            }
            if(_loc12_ == 0)
            {
               dispatchEvent(new CommonEvent(EVENT_DATA_CHANGED,{
                  "index":0,
                  "data":this.m_decorGroup
               }));
            }
            else
            {
               dispatchEvent(new CommonEvent(EVENT_DATA_STATUS_CHANGED,{
                  "type":_loc4_,
                  "id":_loc3_
               }));
            }
            dispatchEvent(new CommonEvent(NOTIFY_REFRESH_MAINSCENE,{
               "type":_loc4_,
               "id":_loc3_
            }));
         }
      }
   }
}

