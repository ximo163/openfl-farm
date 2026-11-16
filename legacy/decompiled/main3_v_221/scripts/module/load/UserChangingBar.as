package module.load
{
   import common.Consts;
   import common.view.DataLoading;
   import events.CommonEvent;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.TextEvent;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import interfaces.IMsgCenter;
   
   public class UserChangingBar extends Sprite
   {
      
      private var m_dataLoading:DataLoading;
      
      private var m_textField:TextField;
      
      private var m_mask:Sprite;
      
      private var m_app:IMsgCenter;
      
      public function UserChangingBar(param1:IMsgCenter)
      {
         super();
         this.m_app = param1;
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage);
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         removeEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage);
         this.m_mask = new Sprite();
         this.m_mask.graphics.beginFill(16777215,0.6);
         this.m_mask.graphics.drawRect(0,0,stage.stageWidth,stage.stageHeight);
         this.m_mask.graphics.endFill();
         this.m_mask.visible = false;
         addChild(this.m_mask);
         this.m_dataLoading = new DataLoading();
         this.m_dataLoading.x = stage.stageWidth / 2;
         this.m_dataLoading.y = stage.stageHeight / 2;
         this.m_dataLoading.visible = false;
         addChild(this.m_dataLoading);
         this.m_textField = new TextField();
         this.m_textField.addEventListener(TextEvent.LINK,this.onLinkClicked);
         this.m_textField.defaultTextFormat = new TextFormat("Verdana",14,3355443);
         this.m_textField.width = 200;
         this.m_textField.height = 25;
         this.m_textField.x = stage.stageWidth / 2 - 50;
         this.m_textField.y = stage.stageHeight / 2;
         this.m_textField.text = "";
         this.m_textField.selectable = false;
         this.m_textField.visible = false;
         addChild(this.m_textField);
         this.m_app.addEventListener(Consts.MSG_USER_SWITCH_FLAG,this.onUserSwitchResult);
      }
      
      private function onUserSwitchResult(param1:CommonEvent) : void
      {
         if(param1 == null || param1.data == null)
         {
            return;
         }
         if(param1.data["error"] == undefined || param1.data["error"] == "")
         {
            this.m_dataLoading.visible = param1.data["showLoading"] as Boolean;
            this.m_mask.visible = param1.data["showLoading"] as Boolean;
         }
         else
         {
            this.m_textField.htmlText = param1.data["error"];
            this.m_textField.visible = true;
            this.m_dataLoading.visible = false;
         }
      }
      
      private function onLinkClicked(param1:TextEvent) : void
      {
         this.m_app.dispatchEvent(new CommonEvent(Consts.MSG_USER_SWITCH_FLAG,{"__reload__":true}));
         this.m_textField.visible = false;
         this.m_dataLoading.visible = true;
      }
   }
}

