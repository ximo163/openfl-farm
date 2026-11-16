package common.view.window
{
   import com.qzone.qui.controls.Button;
   import common.Consts;
   import common.misc.Utils;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.TextEvent;
   import flash.net.URLRequest;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.utils.setTimeout;
   import interfaces.IMsgCenter;
   import report.EventRecorder;
   
   public class PostWindow extends AddButtonWindow
   {
      
      private var _btnCallback:Function;
      
      private var _postText:TextField;
      
      private var _text:String;
      
      private var _btn:Button;
      
      private var _defaultSkin:Boolean;
      
      private var _btnText:String;
      
      private var _loader:Loader;
      
      private var _fixSize:Boolean;
      
      private var _loading:MovieClip;
      
      public function PostWindow(param1:IMsgCenter = null, param2:String = "", param3:Function = null, param4:Boolean = false)
      {
         var _loc5_:Class = null;
         super(param1);
         this._defaultSkin = true;
         if(param4 == false)
         {
            _loc5_ = Utils.getClass("PostWindowBG");
            if(_loc5_ != null)
            {
               defaultSkin = _loc5_;
               this._defaultSkin = false;
               super.marginL = 10;
               super.marginR = 10;
               super.marginT = 35;
               super.marginB = 10;
            }
         }
         else
         {
            marginL = 3;
            marginR = 5;
            marginT = 27;
            marginB = 5;
         }
         _width = 442.1;
         _height = 435.8;
         mode = true;
         this._text = "";
         this._btn = null;
         this._btnText = param2;
         this._btnCallback = param3;
         windowName = Consts.WINDOW_NAME_SYS_POST_MSG;
         this._fixSize = true;
      }
      
      private function showLoadingAnimation() : void
      {
         if(this._loading == null)
         {
            this._loading = new FarmLoading();
            this._loading.x = width * 0.5;
            this._loading.y = height * 0.5;
            this._loading.mouseEnabled = false;
            this._loading.mouseChildren = false;
            addChild(this._loading);
         }
      }
      
      private function stopLoadingAnimation() : void
      {
         if(this._loading != null && this.contains(this._loading) == true)
         {
            this._loading.stop();
            removeChild(this._loading);
            this._loading = null;
         }
      }
      
      private function onLoaded(param1:Event) : void
      {
         var e:Event = param1;
         this.stopLoadingAnimation();
         if(this._fixSize == true)
         {
            super.autoLayout = false;
            super.content = this._loader;
            this._loader.scaleX = this._loader.scaleY = 1;
         }
         else
         {
            super.autoLayout = true;
            super.content = this._loader;
            setTimeout(function():void
            {
               if(stage != null)
               {
                  move((stage.stageWidth - (_loader.width + marginL + marginR)) * 0.5,(stage.stageHeight - (_loader.height + marginT + marginB)) * 0.5);
               }
            },500);
            if(panelTitle)
            {
               panelTitle.x = (_width - panelTitle.width) * 0.5;
            }
         }
      }
      
      override protected function init() : void
      {
         if(this._btnText != "")
         {
            this._btn = addButton(this._btnText,"ButtonGreen",65,25,this.confirmFn);
            super.init();
            this._btn.y -= 100;
         }
         this._postText = new TextField();
         this._postText.wordWrap = true;
         this._postText.multiline = true;
         var _loc1_:TextFormat = new TextFormat("Verdana");
         this._postText.defaultTextFormat = _loc1_;
         this._postText.x = 17;
         this._postText.y = 36;
         this._postText.width = 420;
         this._postText.height = 224;
         this._postText.htmlText = this.text || "";
         this._postText.addEventListener(TextEvent.LINK,this.onLinkClicked,false,0,true);
         addChild(this._postText);
      }
      
      public function enableBtn(param1:Boolean) : void
      {
         if(this._btn != null)
         {
            this._btn.enabled = param1;
         }
      }
      
      public function set text(param1:String) : void
      {
         this._text = param1;
         if(this._postText != null)
         {
            this._postText.htmlText = param1;
         }
         if(this._loader != null)
         {
            this._loader.unload();
         }
      }
      
      private function confirmFn() : void
      {
         super.close();
         if(this._btnCallback != null)
         {
            this._btnCallback();
         }
      }
      
      override public function onEffectEnd() : void
      {
         if(this._defaultSkin == false)
         {
            this.y += 80;
         }
         if(this._fixSize == false)
         {
            if(stage != null)
            {
               move((stage.stageWidth - (this._loader.width + marginL + marginR)) * 0.5,(stage.stageHeight - (this._loader.height + marginT + marginB)) * 0.5);
            }
         }
      }
      
      override protected function setData() : void
      {
         if(super.data != null)
         {
            this.text = super.data["text"];
         }
      }
      
      public function get text() : String
      {
         return this._text;
      }
      
      public function set imgUrl(param1:String) : void
      {
         if(param1 == null || param1 == "")
         {
            return;
         }
         if(this._loader == null)
         {
            this._loader = new Loader();
            this._loader.x = 0;
            this._loader.y = 0;
         }
         else if(this._loader.contentLoaderInfo != null && this._loader.contentLoaderInfo.url == param1)
         {
            return;
         }
         this._loader.unload();
         this._loader.load(new URLRequest(param1));
         this._loader.contentLoaderInfo.addEventListener(Event.COMPLETE,this.onLoaded);
         this.showLoadingAnimation();
         if(this._postText != null)
         {
            this._postText.htmlText = "";
         }
      }
      
      private function onLinkClicked(param1:TextEvent) : void
      {
         EventRecorder.recordSueecssEvent(EventRecorder.HF_POSTCLICK,0);
         super.close();
      }
      
      public function set fixSize(param1:Boolean) : void
      {
         this._fixSize = param1;
      }
   }
}

