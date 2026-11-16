package mc.view.main.window.profile
{
   import com.minutes.ui.collections.LipiListChild;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.text.TextFormatAlign;
   import mc.view.ViewEvent;
   import mc.view.common.MaterialLoaderProxy;
   
   public class HistoryItem extends LipiListChild
   {
      
      public static var CHILD_OVER:String = "childOver";
      
      public static var CHILD_OUT:String = "childOut";
      
      public static var CHILD_MOVE:String = "childMove";
      
      private var _material:MaterialLoaderProxy;
      
      private var _data:Object;
      
      private var text:TextField;
      
      public function HistoryItem()
      {
         super();
         this.init();
      }
      
      override public function get data() : Object
      {
         return this._data;
      }
      
      private function onOut(param1:MouseEvent) : void
      {
         var _loc2_:ViewEvent = new ViewEvent(ViewEvent.CHILD_OUT,true);
         _loc2_.data = this.data;
         dispatchEvent(_loc2_);
      }
      
      private function init() : void
      {
         this._material = new MaterialLoaderProxy();
         addChild(this._material);
         this.text = new TextField();
         this.text.selectable = false;
         this.text.width = 60;
         this.text.height = 22;
         this.text.defaultTextFormat = new TextFormat("Arial",16,16737792,true,null,null,null,null,TextFormatAlign.CENTER);
         this.text.x = 0;
         this.text.y = 60;
         this.text.text = "0";
         addChild(this.text);
         addEventListener(MouseEvent.ROLL_OVER,this.onOver);
         addEventListener(MouseEvent.ROLL_OUT,this.onOut);
      }
      
      private function onLoadCompete(param1:Event) : void
      {
      }
      
      private function onOver(param1:MouseEvent) : void
      {
         var _loc2_:ViewEvent = new ViewEvent(ViewEvent.CHILD_OVER,true);
         _loc2_.data = this.data;
         dispatchEvent(_loc2_);
      }
      
      override public function set data(param1:Object) : void
      {
         this._data = param1;
         this._material.setContent("2",param1["cId"]);
         this.text.text = String(int(param1["harvest"]) + int(param1["scrounge"]));
      }
   }
}

