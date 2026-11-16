package mc.view.main.shield
{
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.TextEvent;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import mc.control.Command;
   import mc.model.MData;
   import mc.model.MainData;
   import mc.view.common.DataLoading;
   
   public class UserChanging extends Sprite
   {
      
      private var dataLoading:DataLoading;
      
      private var modeSprite:Sprite;
      
      private var _textField:TextField;
      
      public function UserChanging()
      {
         super();
         addEventListener(Event.ADDED_TO_STAGE,this.toStage);
      }
      
      private function linkClick(param1:TextEvent) : void
      {
         Command.getInstance().mainCommand.userReload();
         this._textField.visible = false;
         this.dataLoading.visible = true;
      }
      
      private function toStage(param1:Event) : void
      {
         removeEventListener(Event.ADDED_TO_STAGE,this.toStage);
         this.modeSprite = new Sprite();
         this.modeSprite.graphics.beginFill(16777215,0.6);
         this.modeSprite.graphics.drawRect(0,0,stage.stageWidth,stage.stageHeight);
         this.modeSprite.graphics.endFill();
         this.modeSprite.visible = false;
         addChild(this.modeSprite);
         this.dataLoading = new DataLoading();
         this.dataLoading.x = stage.stageWidth / 2;
         this.dataLoading.y = stage.stageHeight / 2;
         this.dataLoading.visible = false;
         addChild(this.dataLoading);
         this._textField = new TextField();
         this._textField.addEventListener(TextEvent.LINK,this.linkClick);
         this._textField.defaultTextFormat = new TextFormat("Verdana",14,8999699);
         this._textField.width = 200;
         this._textField.height = 25;
         this._textField.x = stage.stageWidth / 2 - 50;
         this._textField.y = stage.stageHeight / 2;
         this._textField.text = "";
         this._textField.selectable = false;
         this._textField.visible = false;
         addChild(this._textField);
         MData.getInstance().mainData.addEventListener(MainData.USER_CHANGING,this.userChanging);
         MData.getInstance().mainData.addEventListener(MainData.SET_USER_ERROR,this.setUserError);
      }
      
      private function setUserError(param1:Event) : void
      {
         this._textField.htmlText = MData.getInstance().mainData.setUserError;
         this._textField.visible = true;
         this.dataLoading.visible = false;
      }
      
      private function userChanging(param1:Event) : void
      {
         this.dataLoading.visible = this.modeSprite.visible = MData.getInstance().mainData.userChanging;
      }
   }
}

