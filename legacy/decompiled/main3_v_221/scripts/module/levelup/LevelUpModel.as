package module.levelup
{
   import com.qzone.qfa.events.CommandEvent;
   import common.Session;
   import common.Settings;
   import common.misc.Utils;
   import entities.Seed;
   import events.CommonEvent;
   import flash.events.EventDispatcher;
   import framework.net.CommandDefs;
   import framework.net.NetHelper;
   import report.EventRecorder;
   
   public class LevelUpModel extends EventDispatcher
   {
      
      public static const NORMAL_LAND_UPDATE_INFO:Array = [5,7,9,11,13,15,17,19,21,23,25,27,29,31,33,35,37,39];
      
      public static const RED_LAND_UPDATE_INFO:Array = [28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,47,49,51,53,55,57];
      
      public static const BLACK_LAND_UPDATE_INFO_NUM:Array = [40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,59,61,63,65,67,69];
      
      public static const EVENT_SEEDS_DATA_LOADED:String = "levelUpSeedsDataLoaded";
      
      private var m_seeds:Array;
      
      private var _notShowIdArr:Array;
      
      private var _loading:Boolean;
      
      public function LevelUpModel()
      {
         super();
      }
      
      public function getPanelURL() : String
      {
         return Utils.addPrefix(Settings.getInstance().getSecondUrl("levelUpUI"));
      }
      
      public function get seeds() : Array
      {
         return this.m_seeds;
      }
      
      public function getYellowURL() : String
      {
         return Settings.getInstance().getStringAttribute("vipSeedLink");
      }
      
      private function isNotShow(param1:String) : Boolean
      {
         var _loc2_:String = null;
         if(!this._notShowIdArr)
         {
            _loc2_ = Settings.getInstance().getStringAttribute("exclude_seeds");
            if(_loc2_ != null && _loc2_ != "")
            {
               this._notShowIdArr = _loc2_.split(",");
            }
         }
         if(this._notShowIdArr.indexOf(param1) != -1)
         {
            return true;
         }
         return false;
      }
      
      public function getLevelUpPicURL() : String
      {
         return Utils.addPrefix("module/ui/icons/levelUp.jpg");
      }
      
      public function loadSeedsInfo() : void
      {
         if(this.m_seeds != null || this._loading)
         {
            return;
         }
         this._loading = true;
         NetHelper.sendRequest(CommandDefs.CMD_GET_SHOP_SEED,null,this.onGetSeedsInfo,this.onGetSeedsInfoFail);
      }
      
      private function onGetSeedsInfoFail(param1:CommandEvent) : void
      {
         EventRecorder.recordErrorEvent("160848",null,4);
      }
      
      private function onGetSeedsInfo(param1:CommandEvent) : void
      {
         var _loc3_:Object = null;
         var _loc4_:Seed = null;
         this._loading = false;
         var _loc2_:Object = NetHelper.getVOData(param1);
         if(_loc2_ == null)
         {
            return;
         }
         this.m_seeds = [];
         for each(_loc4_ in _loc2_)
         {
            _loc3_ = Settings.getInstance().getCropByID(_loc4_._id.toString());
            if(_loc3_ != null)
            {
               if(!(_loc3_.hasOwnProperty("id") && this.isNotShow(_loc3_["id"])))
               {
                  if(!(_loc3_["isVIP"] != undefined && _loc3_["isVIP"] == "1" || _loc3_["isMill"] != undefined && _loc3_["isMill"] == "1"))
                  {
                     this.m_seeds.push(_loc4_);
                  }
               }
            }
         }
         dispatchEvent(new CommonEvent(EVENT_SEEDS_DATA_LOADED,null));
         EventRecorder.recordSueecssEvent("160848",null);
      }
      
      public function isYellow() : Boolean
      {
         return Session.getInstance().isMeVIP;
      }
   }
}

