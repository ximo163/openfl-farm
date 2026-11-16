package module.messages.widgets
{
   import com.qzone.qui.controls.Button;
   import com.qzone.utils.HtmlUtil;
   import common.Language;
   import common.Session;
   import common.Settings;
   import common.misc.QzoneJSAPI;
   import common.misc.Utils;
   import common.view.MoneyIcon;
   import entities.Player;
   import flash.display.DisplayObjectContainer;
   import flash.display.Loader;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.MouseEvent;
   import flash.net.URLRequest;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import report.UserActionRecorder;
   
   public class ProfileHead extends Sprite
   {
      
      private var nameText:TextField;
      
      private var assets1Text:TextField;
      
      private var assets2Text:TextField;
      
      private var assets3Text:TextField;
      
      private var gradeText:TextField;
      
      private var _photoLoader:Loader;
      
      private var expText:TextField;
      
      private var _homePage:String;
      
      private var homeLink:Button;
      
      private var _photoHolder:DisplayObjectContainer;
      
      public function ProfileHead()
      {
         super();
         this._homePage = "";
         this._photoHolder = null;
         this._photoLoader = new Loader();
         this._photoLoader.contentLoaderInfo.addEventListener(Event.COMPLETE,this.onLoaded);
         this._photoLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,this.onLoadError);
         this.createView();
      }
      
      private function createView() : void
      {
         var _loc1_:Sprite = null;
         var _loc3_:TextField = null;
         var _loc5_:TextField = null;
         _loc1_ = new Sprite();
         _loc1_.graphics.beginFill(15658734);
         _loc1_.graphics.drawRect(0,0,100,100);
         _loc1_.graphics.endFill();
         _loc1_.x = 39;
         _loc1_.y = 16;
         addChild(_loc1_);
         this._photoHolder = _loc1_;
         _loc1_.addChild(this._photoLoader);
         var _loc2_:Sprite = new Sprite();
         _loc2_.graphics.beginFill(15658734);
         _loc2_.graphics.drawRoundRect(0,0,100,100,10,10);
         _loc2_.graphics.endFill();
         _loc2_.x = 39;
         _loc2_.y = 16;
         addChild(_loc2_);
         _loc1_.mask = _loc2_;
         this.nameText = new TextField();
         this.nameText.selectable = false;
         this.nameText.x = 163;
         this.nameText.y = 26;
         this.nameText.width = 300;
         this.nameText.height = 22;
         this.nameText.defaultTextFormat = new TextFormat("Verdana",14,3355443,true);
         this.nameText.text = "";
         addChild(this.nameText);
         _loc3_ = new TextField();
         _loc3_.selectable = false;
         _loc3_.x = 163;
         _loc3_.y = 65;
         _loc3_.width = 100;
         _loc3_.height = 22;
         _loc3_.defaultTextFormat = new TextFormat("Verdana",14,3355443);
         _loc3_.text = Language.L["等级:"];
         addChild(_loc3_);
         this.gradeText = new TextField();
         this.gradeText.selectable = false;
         this.gradeText.x = 210;
         this.gradeText.y = 63;
         this.gradeText.width = 100;
         this.gradeText.height = 22;
         this.gradeText.defaultTextFormat = new TextFormat("embedFontA",18,39423);
         this.gradeText.embedFonts = true;
         this.gradeText.text = "";
         addChild(this.gradeText);
         var _loc4_:TextField = new TextField();
         _loc4_.selectable = false;
         _loc4_.x = 263;
         _loc4_.y = 65;
         _loc4_.width = 100;
         _loc4_.height = 22;
         _loc4_.defaultTextFormat = new TextFormat("Verdana",14,3355443);
         _loc4_.text = Language.L["经验:"];
         addChild(_loc4_);
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
         _loc5_ = new TextField();
         _loc5_.selectable = false;
         _loc5_.x = 163;
         _loc5_.y = 90;
         _loc5_.width = 100;
         _loc5_.height = 22;
         _loc5_.defaultTextFormat = new TextFormat("Verdana",14,3355443);
         _loc5_.text = Language.L["现金:"];
         addChild(_loc5_);
         var _loc6_:MoneyIcon = new MoneyIcon();
         _loc6_.x = 210;
         _loc6_.y = 92;
         addChild(_loc6_);
         this.assets1Text = new TextField();
         this.assets1Text.selectable = false;
         this.assets1Text.x = 248;
         this.assets1Text.y = 90;
         this.assets1Text.width = 100;
         this.assets1Text.height = 24;
         this.assets1Text.defaultTextFormat = new TextFormat("embedFontA",16,16737792);
         this.assets1Text.embedFonts = true;
         this.assets1Text.text = "";
         addChild(this.assets1Text);
         this.homeLink = new Button();
         this.homeLink.textDefaultFormat.font = "verdana";
         this.homeLink.defaultSkin = Utils.getClass("ButtonGreen");
         this.homeLink.visible = false;
         this.homeLink.clickFn = this.onClick;
         this.homeLink.x = 330;
         this.homeLink.y = 26;
         this.homeLink.width = 150;
         this.homeLink.height = 24;
         addChild(this.homeLink);
         var _loc7_:TextField = new TextField();
         _loc7_.selectable = false;
         _loc7_.x = 338;
         _loc7_.y = 92;
         _loc7_.width = 100;
         _loc7_.height = 22;
         _loc7_.defaultTextFormat = new TextFormat("embedFontA",14,3355443);
         _loc7_.text = "人品：";
         addChild(_loc7_);
         this.assets3Text = new TextField();
         this.assets3Text.selectable = false;
         this.assets3Text.x = 378;
         this.assets3Text.y = 90;
         this.assets3Text.width = 100;
         this.assets3Text.height = 24;
         this.assets3Text.defaultTextFormat = new TextFormat("embedFontA",16,4160774);
         this.assets3Text.embedFonts = true;
         this.assets3Text.text = "";
         addChild(this.assets3Text);
      }
      
      private function onLoaded(param1:Event) : void
      {
         this._photoLoader.width = 100;
         this._photoLoader.height = 100;
      }
      
      public function showPhotoPic(param1:Boolean) : void
      {
         if(this._photoHolder == null || this._photoLoader == null)
         {
            return;
         }
         if(param1 == true)
         {
            this._photoLoader.visible = param1;
            if(this._photoHolder.contains(this._photoLoader) == false)
            {
               this._photoHolder.addChild(this._photoLoader);
            }
         }
         else
         {
            this._photoLoader.visible = param1;
            if(this._photoHolder.contains(this._photoLoader) == true)
            {
               this._photoHolder.removeChild(this._photoLoader);
            }
         }
      }
      
      private function onLoadError(param1:IOErrorEvent) : void
      {
      }
      
      private function onClick(param1:MouseEvent) : void
      {
         QzoneJSAPI.openWindow(this._homePage);
         UserActionRecorder.recordAction(UserActionRecorder.HF_HOMELINK_CLICKED);
      }
      
      public function set data(param1:Object) : void
      {
         if(param1 == null)
         {
            return;
         }
         var _loc2_:Player = Session.getInstance().host;
         var _loc3_:String = param1["uName"];
         if(_loc3_ == null || _loc3_ == "")
         {
            if(param1.uId == _loc2_._uId)
            {
               _loc3_ = _loc2_._userName;
            }
            else
            {
               _loc3_ = Session.getInstance().currentUser._userName;
            }
         }
         if(_loc3_ == null || _loc3_ == "")
         {
            _loc3_ = "农场用户";
         }
         this.nameText.htmlText = HtmlUtil.escHTML(_loc3_) || "农场用户";
         this.homeLink.text = "去" + HtmlUtil.escHTML(_loc3_) + "的首页";
         this.assets1Text.text = param1["money"].toString();
         this.assets3Text.text = param1["moralexp"].toString();
         this.gradeText.text = param1["uLevel"].toString();
         if(this.assets2Text != null)
         {
            this.assets2Text.text = param1["FB"].toString();
         }
         var _loc4_:int = parseInt(param1["uLevel"]);
         this.expText.text = (param1["uExp"] - 100 * _loc4_ * (_loc4_ + 1)).toString();
         var _loc5_:String = param1["headPicBig"] as String;
         if(_loc5_ == null || _loc5_ == "")
         {
            if(QzoneJSAPI.WB == true)
            {
               if(param1.uId == _loc2_._uId)
               {
                  _loc5_ = _loc2_._headPic;
               }
               else
               {
                  _loc5_ = Session.getInstance().currentUser._headPic;
               }
               if(_loc5_ == null || _loc5_ == "")
               {
                  _loc5_ = "http://mat1.gtimg.com/www/mb/images/head_100.jpg";
               }
               else
               {
                  _loc5_ += "/100";
               }
            }
            else if(Settings.getInstance().mode == "qzone" || Settings.getInstance().mode == "qplus")
            {
               if(param1["uId"] == _loc2_._uId)
               {
                  _loc5_ = QzoneJSAPI.getHead(_loc2_.uin.toString(),100);
               }
               else
               {
                  _loc5_ = QzoneJSAPI.getHead(Session.getInstance().currentUser.uin.toString(),100);
               }
            }
         }
         if(_loc5_ != null && _loc5_ != "")
         {
            if(_loc5_ != this._photoLoader.contentLoaderInfo.url)
            {
               this._photoLoader.load(new URLRequest(_loc5_));
            }
         }
         this.homeLink.visible = param1["uId"] == _loc2_._uId ? false : true;
         this._homePage = param1["homePage"] as String;
      }
   }
}

