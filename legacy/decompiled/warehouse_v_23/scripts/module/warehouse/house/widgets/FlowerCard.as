package module.warehouse.house.widgets
{
   import com.qzone.qfa.events.CommandEvent;
   import com.qzone.qui.controls.Button;
   import common.Consts;
   import common.Language;
   import common.Session;
   import common.misc.Utils;
   import common.view.window.BaseWindow;
   import events.CommonEvent;
   import events.ViewEvent;
   import flash.display.Bitmap;
   import flash.display.Loader;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TextEvent;
   import flash.filters.GlowFilter;
   import flash.net.URLRequest;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import framework.net.CommandDefs;
   import framework.net.NetHelper;
   import framework.net.vo.ServiceResultVO;
   import interfaces.IMsgCenter;
   import module.FarmApplication;
   
   public class FlowerCard extends BaseWindow
   {
      
      private var _txtView:TextField;
      
      private var _parent:Sprite;
      
      private var _imgBorder:Sprite;
      
      private const _imgWH:uint = 96;
      
      private var _ld:Loader;
      
      private var _txtFriendName:TextField;
      
      private var _txtWord:TextField;
      
      private var _txtMasterName:TextField;
      
      private var _txtDesc:TextField;
      
      public function FlowerCard(param1:IMsgCenter)
      {
         super(param1);
         width = 400;
         height = 250;
         mode = true;
         title = "鲜花卡片";
         windowName = Consts.WINDOW_NAME_FLOWER_CARD;
         this._parent = null;
         addEventListener(TextEvent.LINK,this.onLinkClicked);
      }
      
      private function onImageClicked(param1:MouseEvent) : void
      {
         var _loc2_:ViewEvent = null;
         if(this._parent != null)
         {
            _loc2_ = new ViewEvent("preview",true);
            _loc2_.data = super.data["flower"];
            this._parent.dispatchEvent(_loc2_);
         }
      }
      
      override protected function setData() : void
      {
         this.graphics.clear();
         this._parent = super.data["parent"];
         var _loc1_:Object = super.data["flower"];
         if(_loc1_["pic"] != undefined && _loc1_["pic"] != "")
         {
            this._ld.load(new URLRequest(_loc1_["pic"]));
         }
         this._txtMasterName.htmlText = Session.getInstance().host._userName;
         this._txtFriendName.text = "好友：" + _loc1_["friendName"];
         this._txtDesc.text = "花语：" + _loc1_["desc"];
         var _loc2_:* = {
            "uid":_loc1_["fromId"],
            "time":_loc1_["time"]
         };
         NetHelper.sendRequest(CommandDefs.CMD_GET_FLOWER_WORDS,_loc2_,this.onFlowerWords,this.onNetError);
      }
      
      private function onFlowerDeleted(param1:CommandEvent) : void
      {
         var _loc3_:FarmApplication = null;
         var _loc4_:* = undefined;
         if(param1 == null || param1.result == null)
         {
            return;
         }
         var _loc2_:ServiceResultVO = param1.result as ServiceResultVO;
         if(_loc2_ != null)
         {
            _loc3_ = m_msgCenter as FarmApplication;
            _loc4_ = {
               "iconType":"success",
               "text":"成功删除花束！",
               "parent":_loc3_.farmView.getLayerByName(Consts.LAYER_TOPMOST)
            };
            _loc3_.farmView.floatCtrl.open(Consts.FLOAT_TYPE_TEXTTIP,0,_loc4_);
            _loc3_.dispatchEvent(new CommonEvent(Consts.MSG_FLOWER_DELETED,super.data["flower"]));
         }
      }
      
      private function onDeleteFlower(param1:MouseEvent) : void
      {
         var _loc2_:* = {
            "text":"删除的花束无法恢复。\n是否删除？",
            "confirmFn":this.deleteFlower
         };
         var _loc3_:FarmApplication = m_msgCenter as FarmApplication;
         _loc3_.openWindowByName(Consts.WINDOW_NAME_CONFIRM,_loc2_);
         super.close();
      }
      
      private function deleteFlower() : void
      {
         var _loc1_:* = super.data["flower"];
         var _loc2_:* = {
            "uid":_loc1_["fromId"],
            "time":_loc1_["time"]
         };
         NetHelper.sendRequest(CommandDefs.CMD_DEL_MYFLOWER,_loc2_,this.onFlowerDeleted,this.onNetError);
      }
      
      private function onFlowerWords(param1:CommandEvent) : void
      {
         if(param1 == null || param1.result == null)
         {
            return;
         }
         var _loc2_:ServiceResultVO = param1.result as ServiceResultVO;
         if(_loc2_ != null)
         {
            this._txtWord.text = _loc2_.m_extra["word"] as String;
         }
      }
      
      private function onNetError(param1:CommandEvent) : void
      {
         var _loc2_:FarmApplication = null;
         var _loc3_:* = undefined;
         if(param1 == null || param1.body == null)
         {
            return;
         }
         if(param1.body["cmdID"] == CommandDefs.CMD_GET_FLOWER_WORDS)
         {
            this._txtWord.text = "好友没有留言哦。";
         }
         else if(param1.body["cmdID"] == CommandDefs.CMD_DEL_MYFLOWER)
         {
            _loc2_ = m_msgCenter as FarmApplication;
            _loc3_ = {
               "iconType":"error",
               "text":"删除花束失败！",
               "parent":_loc2_.farmView.getLayerByName(Consts.LAYER_TOPMOST)
            };
            _loc2_.farmView.floatCtrl.open(Consts.FLOAT_TYPE_TEXTTIP,0,_loc3_);
         }
      }
      
      private function onLinkClicked(param1:TextEvent) : void
      {
         var _loc2_:ViewEvent = null;
         param1.stopPropagation();
         if(param1.text == "view")
         {
            if(this._parent != null)
            {
               _loc2_ = new ViewEvent("preview",true);
               _loc2_.data = super.data["flower"];
               this._parent.dispatchEvent(_loc2_);
            }
         }
      }
      
      override protected function addedToLayer() : void
      {
         var tf:TextFormat;
         var delButton:Button;
         var okButton:Button = null;
         var ui:Sprite = Utils.getMaterial("FlowerCardUI") as Sprite;
         this._txtDesc = ui.getChildByName("txtDesc") as TextField;
         this._txtMasterName = ui.getChildByName("txtMasterName") as TextField;
         this._txtWord = ui.getChildByName("txtWord") as TextField;
         this._txtFriendName = ui.getChildByName("txtFriendName") as TextField;
         addChild(ui);
         tf = new TextFormat("Verdana",12,6514536);
         tf.leading = 5;
         this._txtWord.setTextFormat(tf);
         this._imgBorder = Utils.getMaterial("ItemBg") as Sprite;
         this._imgBorder.name = "ItemBg";
         this._imgBorder.width = this._imgWH;
         this._imgBorder.height = this._imgWH;
         this._imgBorder.x = 20;
         this._imgBorder.y = 45;
         addChild(this._imgBorder);
         this._imgBorder.addEventListener(MouseEvent.CLICK,this.onImageClicked,false,0,true);
         this._ld = new Loader();
         this._ld.mouseChildren = this._ld.mouseEnabled = false;
         this._ld.contentLoaderInfo.addEventListener(Event.COMPLETE,function():void
         {
            var _loc2_:Loader = arguments[0].target.loader;
            _loc2_.width = _loc2_.height = _imgWH - 4;
            _loc2_.x = _imgBorder.x + 2;
            _loc2_.y = _imgBorder.y + 2;
            Bitmap(_loc2_.content).smoothing = true;
            _loc2_.contentLoaderInfo.removeEventListener(Event.COMPLETE,arguments.callee);
         });
         addChild(this._ld);
         this._txtView = new TextField();
         this._txtView.selectable = false;
         this._txtView.defaultTextFormat = new TextFormat("Verdana",12,16777215);
         this._txtView.filters = [new GlowFilter(30148,1,3,3)];
         this._txtView.autoSize = "left";
         addChild(this._txtView);
         this._txtView.htmlText = "<a href=\'event:view\'>" + "点击查看" + "</a>";
         this._txtView.x = this._imgBorder.x + this._imgWH - this._txtView.width - 2;
         this._txtView.y = this._imgBorder.y + this._imgWH - this._txtView.height - 2;
         okButton = new Button();
         okButton.defaultSkin = ButtonOrange;
         okButton.width = 64;
         okButton.height = 25;
         okButton.x = width / 2 - 62;
         okButton.y = height - 35;
         okButton.text = Language.L["确定"];
         okButton.clickFn = this.onOK;
         addChild(okButton);
         delButton = new Button();
         delButton.defaultSkin = ButtonBlue;
         delButton.width = 64;
         delButton.height = 25;
         delButton.x = width / 2 + 22;
         delButton.y = height - 35;
         delButton.text = "删除花束";
         delButton.clickFn = this.onDeleteFlower;
         addChild(delButton);
      }
      
      private function onOK(param1:MouseEvent) : void
      {
         super.close();
      }
   }
}

