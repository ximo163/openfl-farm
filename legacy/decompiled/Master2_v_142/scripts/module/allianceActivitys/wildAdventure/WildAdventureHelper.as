package module.allianceActivitys.wildAdventure
{
   import com.qzone.corelib.js.JSProxy;
   import common.CommonData;
   import common.INI;
   import mc.FBridge.FRequest;
   import mc.api.AllianceAppHelper;
   import mc.control.Command;
   import mc.control.MainCommand;
   import mc.model.MData;
   import mc.model.MainData;
   import mc.view.NewIconTip.NewIconTipController;
   import module.allianceActivitys.ActivityTipManager;
   
   public class WildAdventureHelper extends AllianceAppHelper
   {
      
      public function WildAdventureHelper()
      {
         super();
      }
      
      override public function execute(param1:String, param2:Object = null) : Object
      {
         if(param1 == "sendRequest")
         {
            FRequest.getInstance().postRequest(param2.url,param2.params,param2.callBack);
         }
         else
         {
            if(param1 == "isYellow")
            {
               return MData.getInstance().mainData.host["yellowstatus"] >= 1;
            }
            if(param1 == "getServerTime")
            {
               return CommonData.serverTime;
            }
            if(param1 == "addJSCallBack")
            {
               JSProxy.addCallBackProxy(param2.funcName,param2.calBack);
            }
            else
            {
               if(param1 == "sandBox")
               {
                  return INI.getInstance().data.sanbox;
               }
               if(param1 == "addTip")
               {
                  ActivityTipManager.showMouseTip(param2.target,param2.tip);
               }
               else if(param1 == "removeTip")
               {
                  ActivityTipManager.removeMouseTip(param2.target);
               }
               else if(param1 == "setCursor")
               {
                  switchSystemCusror(param2.useSysCursor);
               }
               else if(param1 == "showNewTip")
               {
                  NewIconTipController.show(null,param2.tip,"newActivityTip",param2.target);
               }
            }
         }
         return null;
      }
      
      override public function acceptRewards(param1:Array) : void
      {
         var _loc4_:* = undefined;
         var _loc5_:Object = null;
         var _loc6_:int = 0;
         var _loc2_:MainData = MData.getInstance().mainData;
         var _loc3_:MainCommand = Command.getInstance().mainCommand;
         for each(_loc4_ in param1)
         {
            if(_loc4_["type"] == 1)
            {
               MData.getInstance().farmData.reloadUserSeed = true;
            }
            else if(_loc4_["type"] == 6 && _loc4_["id"] == 0)
            {
               _loc3_.addMoney({"money":_loc4_["cnt"]});
            }
            else if(_loc4_["type"] == 6)
            {
               _loc2_.reloadUserItems = true;
            }
            else if(_loc4_["type"] == 7 || _loc4_["type"] == 12)
            {
               MData.getInstance().farmData.reloadUserSeed = true;
            }
            else if(_loc4_["type"] == 20)
            {
               _loc2_.host["exp"] += _loc4_["cnt"] as int;
               _loc2_.addExp = _loc4_["cnt"] as int;
            }
            else if(_loc4_["type"] == 5)
            {
               if(_loc4_["id"] == 40)
               {
                  MData.getInstance().farmData.reloadUserSeed = true;
               }
               else
               {
                  _loc5_ = _loc2_.userFarmData;
                  if(_loc5_["guard"])
                  {
                     _loc5_["guard"]["striketime"] = int(_loc5_["guard"]["striketime"]) + 3600 * 24 * _loc4_["cnt"];
                     _loc2_.hunter = {
                        "id":_loc5_["guard"]["id"],
                        "name":_loc5_["guard"]["name"],
                        "t":_loc5_["guard"]["striketime"],
                        "used":1
                     };
                  }
                  else
                  {
                     _loc6_ = 3600 * 24 * _loc4_["cnt"];
                     if(_loc2_.hunter.hasOwnProperty("t"))
                     {
                        if(int(_loc2_.hunter["t"] <= 0))
                        {
                           _loc2_.hunter["t"] = 0;
                        }
                        _loc2_.hunter = {
                           "id":_loc2_.hunter["id"],
                           "name":_loc2_.hunter["name"],
                           "t":_loc2_.hunter["t"] + _loc6_,
                           "used":1
                        };
                     }
                     else
                     {
                        _loc2_.hunter = {
                           "id":1,
                           "name":"",
                           "t":_loc6_,
                           "used":1
                        };
                     }
                  }
               }
            }
         }
      }
   }
}

