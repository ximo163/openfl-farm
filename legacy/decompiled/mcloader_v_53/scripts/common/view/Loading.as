package common.view
{
   import common.LocalData;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.ProgressEvent;
   import flash.net.URLRequest;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   
   public class Loading extends Sprite
   {
      
      private var _percent:int;
      
      private var _indexTxt:int;
      
      private var _errorText:String = "";
      
      private var _showText:String = "";
      
      private var _totalTxt:int;
      
      private var _url:String;
      
      private var _loader:Loader;
      
      private var _loadContent:MovieClip;
      
      private var _isLoadComp:Boolean = false;
      
      public function Loading()
      {
         super();
         addEventListener(Event.ADDED_TO_STAGE,this.addedToStage);
         this._url = LocalData.parameters.loadingUrl;
         if(Boolean(LocalData.parameters.appImgPrefix) && this._url.indexOf(".appimg") == -1)
         {
            this._url = this._url.replace("appimg.",LocalData.parameters.appImgPrefix + ".appimg.");
            this._url = this._url.replace("appimg1.",LocalData.parameters.appImgPrefix + ".appimg1.");
         }
      }
      
      private function ioError(param1:IOErrorEvent = null) : void
      {
         var _loc2_:TextField = new TextField();
         _loc2_.autoSize = TextFieldAutoSize.LEFT;
         _loc2_.defaultTextFormat = new TextFormat("Verdana",30);
         _loc2_.text = "加载失败 \n ERROR";
         _loc2_.x = (stage.stageWidth - _loc2_.width) / 2;
         _loc2_.y = (stage.stageHeight - _loc2_.height) / 2;
         addChild(_loc2_);
      }
      
      public function set materIndex(param1:int) : void
      {
         this._indexTxt = param1;
      }
      
      public function loadBar() : void
      {
         this._loader = new Loader();
         this._loader.contentLoaderInfo.addEventListener(Event.COMPLETE,this.onComplete);
         this._loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS,this.onProgress);
         this._loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,this.ioError);
         this._loader.load(new URLRequest(this._url));
      }
      
      public function set percent(param1:int) : void
      {
         this._percent = param1;
         if(this._loadContent)
         {
            this._loadContent.gotoAndStop(this._percent);
            this._loadContent.progressText.text = this._percent + "%";
            this._loadContent.sText.text = this._showText;
            this._loadContent.pText.text = this._indexTxt + "/" + this._totalTxt;
         }
      }
      
      public function set showText(param1:String) : void
      {
         this._showText = param1;
         if(this._loadContent)
         {
            this._loadContent.sText.text = this._showText;
         }
      }
      
      public function get errorText() : String
      {
         return this._errorText;
      }
      
      public function get showText() : String
      {
         return this._showText;
      }
      
      private function addedToStage(param1:Event) : void
      {
         removeEventListener(Event.ADDED_TO_STAGE,this.addedToStage);
         if(this._isLoadComp)
         {
            this.addBar();
         }
         else
         {
            this.loadBar();
         }
      }
      
      public function set errorText(param1:String) : void
      {
         this._errorText = param1;
         if(this._loadContent != null)
         {
            this._loadContent.errorText.htmlText = param1;
         }
      }
      
      private function onProgress(param1:ProgressEvent) : void
      {
         if(this._loader.content)
         {
            this._loadContent = this._loader.content as MovieClip;
            this._loader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS,this.onProgress);
         }
      }
      
      public function set materTotal(param1:int) : void
      {
         this._totalTxt = param1;
      }
      
      private function onComplete(param1:Event) : void
      {
         this._isLoadComp = true;
         if(stage == null)
         {
            return;
         }
         this.addBar();
         this.percent = this._percent;
         this.showText = this._showText;
         this.errorText = this._errorText;
      }
      
      private function addBar() : void
      {
         if(this._loadContent == null)
         {
            this._loadContent = this._loader.contentLoaderInfo.content as MovieClip;
            this._loader.x = (stage.stageWidth - this._loader.contentLoaderInfo.width) / 2;
            this._loader.y = (stage.stageHeight - this._loader.contentLoaderInfo.height) / 2;
         }
         addChild(this._loader);
      }
   }
}

