package common.view
{
   import com.qzone.qfa.managers.ResourceManager;
   import events.ViewEvent;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.TextEvent;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   
   public class DataLoading extends Sprite
   {
      
      private var _errorTextField:TextField;
      
      private var _dataLoading:MovieClip;
      
      private var _errorText:String;
      
      public function DataLoading()
      {
         super();
         this._dataLoading = ResourceManager.gi().getClassInstance("DataLoading_mc");
         if(this._dataLoading != null)
         {
            this._dataLoading.stop();
         }
         this._errorText = "";
      }
      
      public function set errorText(param1:String) : void
      {
         if(param1 == null || param1 == "")
         {
            return;
         }
         this._errorText = param1;
         if(this._errorTextField == null)
         {
            this.createTextField();
         }
         this._errorTextField.htmlText = param1;
         this._errorTextField.visible = true;
         this._errorTextField.x = -this._errorTextField.textWidth / 2;
         this._errorTextField.y = -this._errorTextField.textHeight / 2;
         if(this._dataLoading != null)
         {
            this._dataLoading.visible = false;
         }
      }
      
      override public function set visible(param1:Boolean) : void
      {
         super.visible = param1;
         if(this._errorTextField != null)
         {
            this._errorTextField.visible = false;
         }
         if(param1 == true)
         {
            if(this._dataLoading != null)
            {
               if(contains(this._dataLoading) == false)
               {
                  addChild(this._dataLoading);
               }
               this._dataLoading.play();
               this._dataLoading.visible = true;
            }
         }
         else if(this._dataLoading != null)
         {
            this._dataLoading.stop();
            if(contains(this._dataLoading) == true)
            {
               removeChild(this._dataLoading);
            }
         }
      }
      
      private function linkClick(param1:TextEvent) : void
      {
         var _loc2_:ViewEvent = new ViewEvent(ViewEvent.LINK_CLICK);
         _loc2_.data = param1.text;
         dispatchEvent(_loc2_);
      }
      
      private function createTextField() : void
      {
         this._errorTextField = new TextField();
         this._errorTextField.defaultTextFormat = new TextFormat("Verdana");
         this._errorTextField.autoSize = TextFieldAutoSize.LEFT;
         this._errorTextField.visible = false;
         addChild(this._errorTextField);
         this._errorTextField.addEventListener(TextEvent.LINK,this.linkClick);
      }
      
      public function get errorText() : String
      {
         return this._errorText;
      }
   }
}

