package mc.view.main.window.profile
{
   import com.minutes.ui.control.LipiButton;
   import com.minutes.ui.core.LipiSkin;
   import com.qzone.corelib.js.JSProxy;
   import common.LocalData;
   import common.MaterialLib;
   import flash.display.Loader;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.MouseEvent;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import mc.control.Command;
   import mc.control.Version;
   import mc.model.MData;
   import mc.model.MainData;
   
   public class ProfileHead extends Sprite
   {
      
      private var gradeText:TextField;
      
      private var photoLoader:Loader;
      
      private var loadbg:Sprite;
      
      private var _homePage:String = "";
      
      private var expText:TextField;
      
      private var homeLink:LipiButton;
      
      private var assets1Text:TextField;
      
      private var assets2Text:TextField;
      
      private var assets3Text:TextField;
      
      private var nameText:TextField;
      
      public function ProfileHead()
      {
         var _loc4_:TextField = null;
         super();
         this.loadbg = MaterialLib.getInstance().getMaterial("DefaultHead") as Sprite;
         this.loadbg.width = 100;
         this.loadbg.height = 100;
         this.loadbg.x = 39;
         this.loadbg.y = 18;
         addChild(this.loadbg);
         this.photoLoader = new Loader();
         this.photoLoader.contentLoaderInfo.addEventListener(Event.COMPLETE,this.onComp);
         this.photoLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,this.ioError);
         this.photoLoader.x = 39;
         this.photoLoader.y = 18;
         addChild(this.photoLoader);
         var _loc1_:Sprite = new Sprite();
         _loc1_.graphics.beginFill(15658734);
         _loc1_.graphics.drawRoundRect(0,0,100,100,10,10);
         _loc1_.graphics.endFill();
         _loc1_.x = 39;
         _loc1_.y = 18;
         addChild(_loc1_);
         this.photoLoader.mask = _loc1_;
         this.nameText = new TextField();
         this.nameText.selectable = false;
         this.nameText.x = 163;
         this.nameText.y = 26;
         this.nameText.width = 150;
         this.nameText.height = 22;
         this.nameText.defaultTextFormat = new TextFormat("Verdana",14,3355443,true);
         this.nameText.text = "";
         addChild(this.nameText);
         var _loc2_:TextField = new TextField();
         _loc2_.selectable = false;
         _loc2_.x = 163;
         _loc2_.y = 65;
         _loc2_.width = 100;
         _loc2_.height = 22;
         _loc2_.defaultTextFormat = new TextFormat("Verdana",14,3355443);
         _loc2_.text = "牧场等级:";
         addChild(_loc2_);
         this.gradeText = new TextField();
         this.gradeText.selectable = false;
         this.gradeText.x = 230;
         this.gradeText.y = 63;
         this.gradeText.width = 100;
         this.gradeText.height = 22;
         this.gradeText.defaultTextFormat = new TextFormat("embedFontA",18,15886653);
         this.gradeText.embedFonts = true;
         this.gradeText.text = "";
         addChild(this.gradeText);
         var _loc3_:TextField = new TextField();
         _loc3_.selectable = false;
         _loc3_.x = 263;
         _loc3_.y = 65;
         _loc3_.width = 100;
         _loc3_.height = 22;
         _loc3_.defaultTextFormat = new TextFormat("Verdana",14,3355443);
         _loc3_.text = "经验:";
         addChild(_loc3_);
         this.expText = new TextField();
         this.expText.selectable = false;
         this.expText.x = 303;
         this.expText.y = 63;
         this.expText.width = 100;
         this.expText.height = 22;
         this.expText.defaultTextFormat = new TextFormat("embedFontA",18,39423);
         this.expText.embedFonts = true;
         this.expText.text = "";
         addChild(this.expText);
         _loc4_ = new TextField();
         _loc4_.selectable = false;
         _loc4_.x = 163;
         _loc4_.y = 90;
         _loc4_.width = 100;
         _loc4_.height = 22;
         _loc4_.defaultTextFormat = new TextFormat("embedFontA",14,3355443);
         _loc4_.text = "金币:";
         addChild(_loc4_);
         _loc4_ = new TextField();
         _loc4_.selectable = false;
         _loc4_.x = 290;
         _loc4_.y = 90;
         _loc4_.width = 100;
         _loc4_.height = 22;
         _loc4_.defaultTextFormat = new TextFormat("embedFontA",14,3355443);
         _loc4_.text = "人品:";
         addChild(_loc4_);
         this.assets1Text = new TextField();
         this.assets1Text.selectable = false;
         this.assets1Text.x = 200;
         this.assets1Text.y = 88;
         this.assets1Text.width = 100;
         this.assets1Text.height = 24;
         this.assets1Text.defaultTextFormat = new TextFormat("embedFontA",18,16737792);
         this.assets1Text.embedFonts = true;
         this.assets1Text.text = "";
         addChild(this.assets1Text);
         this.assets3Text = new TextField();
         this.assets3Text.selectable = false;
         this.assets3Text.x = 330;
         this.assets3Text.y = 88;
         this.assets3Text.width = 100;
         this.assets3Text.height = 24;
         this.assets3Text.defaultTextFormat = new TextFormat("embedFontA",18,4160774);
         this.assets3Text.embedFonts = true;
         this.assets3Text.text = "";
         addChild(this.assets3Text);
         this.homeLink = new LipiButton();
         this.homeLink.bgAlpha = 0;
         this.homeLink.bgSkin = new LipiSkin(MaterialLib.getInstance().getClass("ButtonGreen"));
         this.homeLink.visible = false;
         this.homeLink.addEventListener(MouseEvent.CLICK,this.onClick);
         this.homeLink.x = 330;
         this.homeLink.y = 26;
         this.homeLink.width = 100;
         this.homeLink.height = 24;
         this.homeLink.label = "去TA的首页";
         this.homeLink.textColor = 16777215;
         addChild(this.homeLink);
      }
      
      private function ioError(param1:IOErrorEvent) : void
      {
         trace("profile头像加载错误");
         this.loadbg.visible = true;
      }
      
      public function set data(param1:Object) : void
      {
         var homePageStr:String;
         var uLevel:int;
         var headURL:String = null;
         var url:String = null;
         var value:Object = param1;
         var mainData:MainData = MData.getInstance().mainData;
         this.nameText.htmlText = String(value["uName"]);
         this.assets1Text.text = String(value["money"]);
         this.assets3Text.text = String(value["moralexp"]);
         this._homePage = String(value["homePage"]);
         this.gradeText.text = String(value["uLevel"]);
         Command.getInstance().mainCommand.getMarkListFromJs(function(param1:String):void
         {
            nameText.htmlText = param1;
         },mainData.currentUserUin);
         if(this.assets2Text != null)
         {
            this.assets2Text.text = String(value["FB"]);
         }
         uLevel = int(value["uLevel"]);
         this.expText.text = String(MData.getInstance().mainData.gradeToExp(value["uLevel"]) - value["uExp"]);
         if(LocalData.isMe)
         {
            headURL = mainData.host.headPic;
         }
         else
         {
            headURL = mainData.currentUser.headPic;
         }
         this.photoLoader.unload();
         this.photoLoader.visible = false;
         if(Version.value == "qzone")
         {
            if(LocalData.isMe)
            {
               url = JSProxy.getHead(mainData.host["uin"],100);
            }
            else
            {
               url = JSProxy.getHead(mainData.currentUserUin,100);
            }
            this.photoLoader.load(new URLRequest(url));
            this.photoLoader.visible = true;
            this.loadbg.visible = true;
         }
         else if(headURL)
         {
            this.photoLoader.load(new URLRequest(headURL.replace(/\/30$/,"/100")));
            this.photoLoader.visible = true;
            this.loadbg.visible = true;
         }
         homePageStr = String(value["homePage"]);
         if(MData.getInstance().mainData.me == true || homePageStr.substring(homePageStr.lastIndexOf("/") + 1,homePageStr.length) == mainData.host["uin"])
         {
            this.homeLink.visible = false;
         }
         else
         {
            this.homeLink.visible = true;
         }
      }
      
      private function onClick(param1:MouseEvent) : void
      {
         if(this._homePage != "")
         {
            navigateToURL(new URLRequest(this._homePage));
         }
      }
      
      private function onComp(param1:Event) : void
      {
         this.photoLoader.width = 100;
         this.photoLoader.height = 100;
         this.loadbg.visible = false;
      }
   }
}

