package module.uitools.widgets.profile
{
   import com.qzone.qui.controls.Button;
   import common.Consts;
   import common.Language;
   import common.misc.Utils;
   import common.view.window.BaseWindow;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import interfaces.IMsgCenter;
   
   public class LevelAndExperience extends BaseWindow
   {
      
      private var m_actionBtn:Button;
      
      private var m_text:Sprite;
      
      public function LevelAndExperience(param1:IMsgCenter = null)
      {
         super(param1);
         this.width = 455;
         this.height = 300;
         title = Language.L["等级和经验"];
         windowName = Consts.WINDOW_NAME_LEVEL_EXP;
         this.m_actionBtn = null;
         this.m_text = null;
      }
      
      override protected function init() : void
      {
         if(this.m_actionBtn == null)
         {
            this.m_actionBtn = new Button();
            this.m_actionBtn.defaultSkin = Utils.getClass("ButtonOrange");
            this.m_actionBtn.text = Language.L["确定"];
            this.m_actionBtn.width = 60;
            this.m_actionBtn.height = 25;
            this.m_actionBtn.x = (this.width - this.m_actionBtn.width) * 0.5;
            this.m_actionBtn.y = this.height - this.m_actionBtn.height - 15;
            this.addChild(this.m_actionBtn);
            this.m_actionBtn.addEventListener(MouseEvent.CLICK,this.onActionBtn);
         }
         if(this.m_text == null)
         {
            this.m_text = Utils.getMaterial("LevelAndExperienss") as Sprite;
            this.m_text.y = 40;
            this.m_text.x = 20;
            this.m_text.mouseEnabled = false;
            addChild(this.m_text);
         }
      }
      
      private function onActionBtn(param1:Event) : void
      {
         super.close();
      }
   }
}

