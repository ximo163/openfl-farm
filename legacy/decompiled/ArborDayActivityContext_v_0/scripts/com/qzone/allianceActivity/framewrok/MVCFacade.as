package com.qzone.allianceActivity.framewrok
{
   import com.qzone.allianceActivity.framewrok.controller.CommandController;
   import com.qzone.allianceActivity.framewrok.controller.EventController;
   import com.qzone.allianceActivity.framewrok.service.rpc.ServiceLocator;
   import flash.utils.Dictionary;
   
   public class MVCFacade
   {
      
      private static var _ins:MVCFacade;
      
      private var _eventController:EventController;
      
      private var _commandController:CommandController;
      
      private var _serviceLocator:ServiceLocator;
      
      private var _objectCollection:Dictionary;
      
      public function MVCFacade()
      {
         super();
         this._eventController = new EventController();
         this._commandController = new CommandController();
         this._serviceLocator = new ServiceLocator();
         this._objectCollection = new Dictionary();
      }
      
      public static function getInstance() : MVCFacade
      {
         if(_ins == null)
         {
            _ins = new MVCFacade();
         }
         return _ins;
      }
      
      public function get eventController() : EventController
      {
         return this._eventController;
      }
      
      public function get commandController() : CommandController
      {
         return this._commandController;
      }
      
      public function get serviceLocator() : ServiceLocator
      {
         return this._serviceLocator;
      }
      
      public function regObj(param1:String, param2:Object) : void
      {
         this._objectCollection[param1] = param2;
      }
      
      public function unRegObj(param1:String) : void
      {
         if(this._objectCollection.hasOwnProperty(param1))
         {
            this._objectCollection[param1] = null;
            delete this._objectCollection[param1];
         }
      }
      
      public function getObj(param1:String) : *
      {
         var _loc2_:* = undefined;
         if(this._objectCollection.hasOwnProperty(param1))
         {
            _loc2_ = this._objectCollection[param1];
            if(_loc2_ is Class)
            {
               this._objectCollection[param1] = new _loc2_();
            }
            return this._objectCollection[param1];
         }
         return null;
      }
   }
}

