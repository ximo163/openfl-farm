package mc.control
{
   import com.adobe.serialization.json.JSON;
   import com.adobe.utils.StringUtil;
   import common.CommonData;
   import common.INI;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import module.weekendSale.WeekendSaleHelper;
   
   public class ModuleManager extends EventDispatcher
   {
      
      private static var _npcList:Object;
      
      private static var _xml:XML;
      
      public function ModuleManager(param1:IEventDispatcher = null)
      {
         super(param1);
      }
      
      public static function checkSubModule() : void
      {
         var _loc1_:XML = null;
         var _loc3_:int = 0;
         var _loc4_:XML = null;
         var _loc5_:String = null;
         var _loc6_:String = null;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc10_:MoudeLoader = null;
         if(_xml == null)
         {
            _xml = INI.getInstance().data;
         }
         _loc1_ = _xml.submodule[0];
         if(!_loc1_)
         {
            return;
         }
         var _loc2_:XMLList = _loc1_.module;
         if(Boolean(_loc2_) && _loc2_.length() > 0)
         {
            _loc3_ = 0;
            while(_loc3_ < _loc2_.length())
            {
               _loc4_ = _loc2_[_loc3_];
               _loc5_ = _loc4_.@start;
               _loc6_ = _loc4_.@end;
               _loc7_ = new Date(_loc5_).time;
               _loc8_ = new Date(_loc6_).time;
               _loc9_ = CommonData.serverTime * 1000;
               if(_loc7_ < _loc9_ && _loc9_ < _loc8_)
               {
                  if(_loc4_.@name == WeekendSaleHelper.activityName)
                  {
                     WeekendSaleHelper.ids = com.adobe.serialization.json.JSON.decode(StringUtil.trim(_loc4_.ids));
                  }
                  _loc10_ = new MoudeLoader();
                  _loc10_.addModule(_loc4_);
               }
               _loc3_++;
            }
         }
      }
   }
}

import com.qzone.qfa.managers.ResourceManager;
import common.CommonData;
import common.MaterialLib;
import flash.display.Loader;
import flash.display.Sprite;
import flash.events.Event;
import flash.net.URLRequest;
import flash.system.ApplicationDomain;
import mc.view.CropLoader;
import mc.view.farm.GetCropID;

class MoudeLoader
{
   
   private var cropsLoader:CropLoader;
   
   private var mainURL:String;
   
   public function MoudeLoader()
   {
      super();
   }
   
   private function onMainLoaded() : void
   {
      if(arguments.length != 1)
      {
         return;
      }
      var _loc2_:String = arguments[0];
      if(_loc2_ == null || _loc2_ == "")
      {
         return;
      }
      var _loc3_:Sprite = ResourceManager.gi().getClassInstance(_loc2_) as Sprite;
      if(_loc3_ == null)
      {
         return;
      }
   }
   
   private function compFn(param1:Event) : void
   {
      var _loc3_:* = undefined;
      var _loc4_:Loader = null;
      var _loc2_:Object = this.cropsLoader.contents;
      for each(_loc3_ in _loc2_)
      {
         if(_loc3_ is ApplicationDomain)
         {
            MaterialLib.getInstance().push(_loc3_);
         }
      }
      _loc4_ = new Loader();
      _loc4_.load(new URLRequest(this.mainURL));
   }
   
   public function addModule(param1:XML) : void
   {
      var _loc4_:String = null;
      var _loc5_:String = null;
      var _loc2_:Array = [];
      var _loc3_:XMLList = param1.material;
      for(_loc5_ in _loc3_)
      {
         _loc4_ = _loc3_[_loc5_].@url;
         _loc4_ = GetCropID.addPrefix(_loc4_);
         _loc2_.push(_loc4_);
      }
      if(_loc2_.length > 0)
      {
         this.cropsLoader = new CropLoader();
         this.cropsLoader.addEventListener(Event.COMPLETE,this.compFn);
         this.cropsLoader.load(_loc2_,true);
      }
      _loc4_ = param1.@url;
      _loc4_ = GetCropID.addPrefix(_loc4_);
      this.mainURL = _loc4_;
      if(param1.@className != undefined)
      {
         CommonData.rslManager.requestClass(param1.@className,null,this.mainURL);
      }
   }
   
   public function ModuleLoader() : void
   {
   }
}
