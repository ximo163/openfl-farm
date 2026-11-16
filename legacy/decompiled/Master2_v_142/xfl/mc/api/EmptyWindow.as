package mc.api
{
   import common.MaterialLib;
   import flash.display.Sprite;
   import mc.view.common.BaseWindow;
   
   public class EmptyWindow extends BaseWindow
   {
      
      private var _content:Sprite;
      
      public function EmptyWindow(param1:String, param2:int, param3:int)
      {
         super();
         titleIMG = MaterialLib.getInstance().getClass(param1);
         width = param2;
         height = param3;
      }
      
      override public function init() : void
      {
         addChild(this._content);
      }
      
      private function onScale(param1:EvtAPI) : void
      {
         width = param1.data["width"];
         height = param1.data["height"];
      }
      
      public function setContent(param1:Sprite) : void
      {
         this._content = param1;
         windowName = this._content.name;
      }
   }
}

