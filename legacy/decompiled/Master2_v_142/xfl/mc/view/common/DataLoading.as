package mc.view.common
{
   import common.MaterialLib;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.TextEvent;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import mc.view.ViewEvent;
   
   public class DataLoading extends Sprite
   {
      
      private var errorTextField:TextField;
      
      private var _dataLoading:MovieClip;
      
      private var _errorText:String = "";
      
      public function DataLoading()
      {
         super();
         this._dataLoading = MaterialLib.getInstance().getMaterial("DataLoading") as MovieClip;
         this._dataLoading.stop();
      }
      
      override public function set visible(param1:Boolean) : void
      {
         super.visible = param1;
         if(this.errorTextField != null)
         {
            this.errorTextField.visible = false;
         }
         if(param1)
         {
            if(!contains(this._dataLoading))
            {
               addChild(this._dataLoading);
            }
            this._dataLoading.play();
            this._dataLoading.visible = true;
         }
         else
         {
            this._dataLoading.stop();
            if(contains(this._dataLoading))
            {
               removeChild(this._dataLoading);
            }
         }
      }
      
      public function set errorText(param1:String) : void
      {
         this._errorText = param1;
         if(this.errorTextField == null)
         {
            this.createTextField();
         }
         this.errorTextField.htmlText = param1;
         this._dataLoading.visible = false;
         this.errorTextField.visible = true;
         this.errorTextField.selectable = false;
         this.errorTextField.x = 0;
         this.errorTextField.x = -this.width / 2;
         this.errorTextField.y = -10;
      }
      
      private function linkClick(param1:TextEvent) : void
      {
         var _loc2_:ViewEvent = new ViewEvent(ViewEvent.LINK_CLICK);
         _loc2_.data = param1.text;
         dispatchEvent(_loc2_);
      }
      
      private function createTextField() : void
      {
         this.errorTextField = new TextField();
         this.errorTextField.defaultTextFormat = new TextFormat("Verdana");
         this.errorTextField.autoSize = TextFieldAutoSize.LEFT;
         this.errorTextField.visible = false;
         addChild(this.errorTextField);
         this.errorTextField.addEventListener(TextEvent.LINK,this.linkClick);
      }
      
      public function get errorText() : String
      {
         return this._errorText;
      }
   }
}

