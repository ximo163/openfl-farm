package mc.view.main.shield
{
   import flash.display.Sprite;
   import flash.events.TextEvent;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import mc.control.Command;
   import mc.view.common.DataLoading;
   
   public class InitLoading extends Sprite
   {
      
      private var dataLoading:DataLoading;
      
      private var _textField:TextField;
      
      public function InitLoading()
      {
         super();
         this.dataLoading = new DataLoading();
         this.dataLoading.x = 250;
         this.dataLoading.y = 10;
         this.dataLoading.visible = true;
         addChild(this.dataLoading);
         this._textField = new TextField();
         this._textField.addEventListener(TextEvent.LINK,this.linkClick);
         this._textField.defaultTextFormat = new TextFormat("Verdana",14,8999699,null,null,null,null,null,"center");
         this._textField.text = "数据初始化中...";
         this._textField.width = 700;
         this._textField.height = 20;
         this._textField.selectable = false;
         addChild(this._textField);
      }
      
      public function set errorText(param1:String) : void
      {
         this._textField.htmlText = param1;
         this.dataLoading.visible = false;
      }
      
      private function linkClick(param1:TextEvent) : void
      {
         if(param1.text == "reload")
         {
            this._textField.text = "数据初始化中...";
            this.dataLoading.visible = true;
            Command.getInstance().mainCommand.run();
         }
         if(param1.text == "noreg")
         {
            Command.getInstance().mainCommand.register();
         }
      }
   }
}

