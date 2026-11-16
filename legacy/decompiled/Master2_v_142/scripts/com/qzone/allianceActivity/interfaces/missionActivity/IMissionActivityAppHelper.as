package com.qzone.allianceActivity.interfaces.missionActivity
{
   import com.qzone.allianceActivity.interfaces.IAllianceAppHelper;
   import flash.display.DisplayObject;
   import flash.events.EventDispatcher;
   
   public interface IMissionActivityAppHelper extends IAllianceAppHelper
   {
      
      function getActivityItemsDataCenter() : EventDispatcher;
      
      function getActivityItems() : Array;
      
      function addToPane(param1:DisplayObject) : void;
      
      function getItemName(param1:int, param2:int) : String;
      
      function removeFromPane(param1:DisplayObject) : void;
      
      function loadActivityItemsHydra() : void;
      
      function reloadActivityItems() : void;
      
      function buyActivityItemHydra(param1:int, param2:int, param3:int, param4:int, param5:Function = null) : void;
      
      function getPic(param1:int, param2:int) : DisplayObject;
      
      function showBuyAnimalSeedWindow(param1:int) : void;
   }
}

