package mc.api
{
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.events.IEventDispatcher;
   import flash.filters.ColorMatrixFilter;
   import flash.utils.Dictionary;
   import mc.FBridge.EventRecorder;
   import mc.FBridge.FRequest;
   import mc.control.Command;
   import mc.control.MainCommand;
   import mc.control.ViewControl;
   import mc.view.main.tip.TipControl;
   
   public class AppHelper implements IAPIHelper
   {
      
      protected var _disableFilter:Array;
      
      protected var _mainCommand:MainCommand = Command.getInstance().mainCommand;
      
      protected var _fr:FRequest = FRequest.getInstance();
      
      protected var _cmds:Dictionary = new Dictionary();
      
      public function AppHelper()
      {
         super();
      }
      
      private static function centerPopUp(param1:DisplayObject, param2:DisplayObjectContainer) : void
      {
         var _loc3_:int = param2.stage.stageWidth / 2 - param1.width / 2;
         var _loc4_:int = param2.stage.stageHeight / 2 - param1.height / 2;
         if(_loc4_ < 0)
         {
            _loc4_ = 0;
         }
         param1.x = _loc3_;
         param1.y = _loc4_;
      }
      
      public function getDisableFilter() : Array
      {
         if(this._disableFilter == null)
         {
            this._disableFilter = [new ColorMatrixFilter([0.3,0.6,0.082,0,0,0.3,0.6,0.082,0,0,0.3,0.6,0.082,0,0,0,0,0,1,0])];
         }
         return this._disableFilter;
      }
      
      public function showPopUp(param1:DisplayObjectContainer) : void
      {
         if(param1)
         {
            ViewControl.getInstance().windowsLayer.addChild(param1);
            centerPopUp(param1,ViewControl.getInstance().windowsLayer);
         }
      }
      
      public function hideMouseTip() : void
      {
         TipControl.hide();
      }
      
      public function reportReturnCode(param1:String, param2:String) : void
      {
         EventRecorder.recordMultiValueInCode(param1,param2);
      }
      
      public function alert(param1:String, param2:String) : void
      {
         this._mainCommand.alertWindow(param1,param2);
      }
      
      public function sendRequest(param1:uint, param2:Object, param3:Function) : Boolean
      {
         this._fr.postRequest(this._cmds[param1],param2,param3);
         return true;
      }
      
      public function hidePopUp(param1:DisplayObjectContainer) : void
      {
         if(param1)
         {
            if(param1.parent)
            {
               param1.parent.removeChild(param1);
            }
         }
      }
      
      public function registerNetCommand(param1:uint, param2:String) : void
      {
         this._cmds[param1] = param2;
      }
      
      public function get messageCenter() : IEventDispatcher
      {
         return ViewControl.getInstance();
      }
      
      public function popMouseTip(param1:String) : void
      {
         TipControl.show("MouseTip",param1);
      }
   }
}

