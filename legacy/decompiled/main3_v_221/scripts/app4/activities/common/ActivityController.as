package app4.activities.common
{
   import app4.activities.CollectingActivity;
   import com.qzone.allianceActivity.AllianceActivityController;
   import com.qzone.farm.api.interfaces.IFarmAPI;
   import common.Session;
   import entities.Player;
   
   public class ActivityController extends AllianceActivityController
   {
      
      private var _api:IFarmAPI;
      
      public function ActivityController(param1:IFarmAPI)
      {
         this._api = param1;
         super();
      }
      
      override protected function onPreloadCustomize(param1:XML) : Boolean
      {
         var _loc2_:Player = null;
         if(param1 == null)
         {
            return false;
         }
         if(param1.@id == "collecting")
         {
            if(param1.@gray == undefined || param1.@gray == 0)
            {
               return true;
            }
            _loc2_ = Session.getInstance().host;
            if(_loc2_._yellowstatus > 0 && _loc2_._yellowlevel >= param1.@gray)
            {
               return true;
            }
            return false;
         }
         return super.onPreloadCustomize(param1);
      }
      
      override protected function initActivityHelpers() : void
      {
         super.initActivityHelpers();
         _helperMap["collecting"] = new CollectingActivity("collecting",this._api);
      }
   }
}

