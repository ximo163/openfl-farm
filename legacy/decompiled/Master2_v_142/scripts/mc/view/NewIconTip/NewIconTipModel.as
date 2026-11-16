package mc.view.NewIconTip
{
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import mc.view.ViewEvent;
   
   public class NewIconTipModel extends EventDispatcher
   {
      
      public static var intence:NewIconTipModel;
      
      private var _data:Object;
      
      public function NewIconTipModel(param1:IEventDispatcher = null)
      {
         super(param1);
      }
      
      public static function gi() : NewIconTipModel
      {
         if(intence == null)
         {
            intence = new NewIconTipModel();
         }
         return intence;
      }
      
      public function set Data(param1:Object) : void
      {
         this._data = param1;
         var _loc2_:ViewEvent = new ViewEvent("NewIconTip");
         _loc2_.data = param1;
         dispatchEvent(_loc2_);
      }
      
      public function get Data() : Object
      {
         return this._data;
      }
   }
}

