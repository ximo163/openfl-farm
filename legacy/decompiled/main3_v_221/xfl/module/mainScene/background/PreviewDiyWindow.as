package module.mainScene.background
{
   import common.Consts;
   import common.Language;
   import common.view.window.AddButtonWindow;
   import events.CommonEvent;
   import flash.events.Event;
   import interfaces.IMsgCenter;
   
   public class PreviewDiyWindow extends AddButtonWindow
   {
      
      public function PreviewDiyWindow(param1:IMsgCenter)
      {
         super(param1);
         width = 200;
         height = 100;
         mode = false;
         title = Language.L["取消预览"];
         windowName = Consts.WINDOW_NAME_PREVIEWDIY;
         addButton(Language.L["取消预览"],"ButtonOrange",100,25,this.onCancel);
      }
      
      private function onCancel() : void
      {
         super.close();
         this.recover();
      }
      
      override protected function onClose(param1:Event) : void
      {
         super.onClose(param1);
         this.recover();
      }
      
      private function recover() : void
      {
         m_msgCenter.dispatchEvent(new CommonEvent(Consts.MSG_EXIT_PREVIEW,null));
      }
   }
}

