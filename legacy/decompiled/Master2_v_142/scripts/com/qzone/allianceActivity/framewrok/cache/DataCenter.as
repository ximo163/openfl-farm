package com.qzone.allianceActivity.framewrok.cache
{
   import com.qzone.allianceActivity.framewrok.events.CacheEvent;
   import flash.events.EventDispatcher;
   import flash.utils.Dictionary;
   
   public class DataCenter extends EventDispatcher implements IBindableCache
   {
      
      private var _bindable:Boolean = false;
      
      private var _bindingMap:Object = {};
      
      public function DataCenter()
      {
         super();
         this.bindable = true;
      }
      
      private function setValueToTargetChain(param1:Object, param2:Array, param3:*) : void
      {
         var _loc4_:String = null;
         var _loc5_:Array = null;
         var _loc6_:Object = null;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         if(param1)
         {
            for each(_loc4_ in param2)
            {
               if(_loc4_ != null)
               {
                  if(_loc4_ != "")
                  {
                     if(_loc4_.indexOf(".") > 0)
                     {
                        _loc5_ = _loc4_.split(".");
                        _loc6_ = param1;
                        _loc7_ = int(_loc5_.length);
                        _loc8_ = 0;
                        while(_loc8_ < _loc7_ - 1)
                        {
                           _loc6_ = _loc6_[_loc5_[_loc8_]];
                           _loc8_++;
                        }
                        _loc6_[_loc5_[_loc7_ - 1]] = param3;
                     }
                     else
                     {
                        param1[_loc4_] = param3;
                     }
                  }
               }
            }
         }
      }
      
      public function get bindable() : Boolean
      {
         return this._bindable;
      }
      
      public function isTargetBinded(param1:Object) : Boolean
      {
         var _loc2_:String = null;
         var _loc3_:Dictionary = null;
         var _loc4_:* = undefined;
         for(_loc2_ in this._bindingMap)
         {
            _loc3_ = this._bindingMap[_loc2_];
            for(_loc4_ in _loc3_)
            {
               if(param1 === _loc4_)
               {
                  return true;
               }
            }
         }
         return false;
      }
      
      private function isTargetsDicContains(param1:Object, param2:Dictionary) : Boolean
      {
         var _loc3_:* = undefined;
         if(param2)
         {
            for(_loc3_ in param2)
            {
               if(param1 === _loc3_)
               {
                  return true;
               }
            }
         }
         return false;
      }
      
      public function isPropertyBinding(param1:String) : Boolean
      {
         return this._bindingMap.hasOwnProperty(param1);
      }
      
      public function isTargetBindedToProperty(param1:Object, param2:String) : Boolean
      {
         var _loc3_:Dictionary = null;
         var _loc4_:* = undefined;
         if(this.isPropertyBinding(param2))
         {
            _loc3_ = this._bindingMap[param2];
            for(_loc4_ in _loc3_)
            {
               if(param1 === _loc4_)
               {
                  return true;
               }
            }
         }
         return false;
      }
      
      public function removeBinding(param1:String, param2:Object, param3:String) : void
      {
         var _loc4_:Dictionary = null;
         var _loc5_:Array = null;
         var _loc6_:Boolean = false;
         var _loc7_:int = 0;
         if(this.isPropertyBinding(param1))
         {
            _loc4_ = this._bindingMap[param1];
            _loc6_ = this.isTargetsDicContains(param2,_loc4_);
            if(_loc6_)
            {
               _loc5_ = _loc4_[param2];
            }
            if(_loc5_)
            {
               _loc7_ = _loc5_.indexOf(param3);
               while(_loc7_ >= 0)
               {
                  _loc5_.splice(_loc7_,1);
                  _loc7_ = _loc5_.indexOf(param3);
               }
               if(_loc5_.length == 0)
               {
                  _loc4_[param2] = null;
                  delete _loc4_[param2];
               }
            }
            else
            {
               delete _loc4_[param2];
            }
         }
      }
      
      public function addBinding(param1:String, param2:Object, param3:String, param4:Boolean = false) : void
      {
         var _loc5_:Dictionary = null;
         var _loc6_:Array = null;
         var _loc7_:Boolean = false;
         param3 = param3.replace(/\s/g,"");
         if(this.isPropertyBinding(param1))
         {
            _loc5_ = this._bindingMap[param1];
            _loc7_ = this.isTargetsDicContains(param2,_loc5_);
            if(_loc7_)
            {
               _loc6_ = _loc5_[param2];
            }
            else
            {
               _loc6_ = [];
               _loc5_[param2] = _loc6_;
            }
            if(_loc6_.indexOf(param3) >= 0)
            {
               return;
            }
            _loc6_.push(param3);
         }
         else
         {
            _loc5_ = new Dictionary(true);
            this._bindingMap[param1] = _loc5_;
            _loc6_ = [];
            _loc5_[param2] = _loc6_;
            _loc6_.push(param3);
         }
         if(param4)
         {
            this.setValueToTargetChain(param2,_loc6_,this[param1]);
         }
      }
      
      public function set bindable(param1:Boolean) : void
      {
         this._bindable = param1;
         if(this._bindable)
         {
            addEventListener(CacheEvent.PROPERTY_CHANGE,this.propertyChangeHandler);
         }
         else
         {
            removeEventListener(CacheEvent.PROPERTY_CHANGE,this.propertyChangeHandler);
         }
      }
      
      protected function dispatchChangeEvent(param1:String, param2:*) : void
      {
         var _loc3_:CacheEvent = CacheEvent.createChangeEvent(param1,param2);
         dispatchEvent(_loc3_);
      }
      
      public function removeBindedTarget(param1:Object) : void
      {
         var _loc2_:String = null;
         var _loc3_:Dictionary = null;
         var _loc4_:* = undefined;
         for(_loc2_ in this._bindingMap)
         {
            _loc3_ = this._bindingMap[_loc2_];
            for(_loc4_ in _loc3_)
            {
               if(param1 === _loc4_)
               {
                  _loc3_[_loc4_] = null;
                  delete _loc3_[_loc4_];
               }
            }
         }
      }
      
      protected function propertyChangeHandler(param1:CacheEvent) : void
      {
         var _loc4_:Dictionary = null;
         var _loc5_:Array = null;
         var _loc6_:String = null;
         var _loc7_:Array = null;
         var _loc8_:Object = null;
         var _loc2_:String = param1.propertyName;
         var _loc3_:* = param1.value;
         if(this._bindingMap.hasOwnProperty(_loc2_))
         {
            _loc4_ = this._bindingMap[_loc2_];
            for(_loc8_ in _loc4_)
            {
               if(_loc8_)
               {
                  _loc5_ = _loc4_[_loc8_];
                  this.setValueToTargetChain(_loc8_,_loc5_,_loc3_);
               }
            }
         }
      }
   }
}

