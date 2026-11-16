package common.view.window
{
   import com.qzone.corelib.net.RSLManager;
   import com.qzone.qui.controls.Button;
   import com.qzone.utils.AlignUtil;
   import common.Consts;
   import common.GetCropID;
   import common.Settings;
   import common.misc.Utils;
   import events.CommonEvent;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.events.TextEvent;
   import flash.events.TimerEvent;
   import flash.external.ExternalInterface;
   import flash.text.TextField;
   import flash.utils.Timer;
   import interfaces.IMsgCenter;
   import module.FarmApplication;
   
   public class PickupGiftWindow extends BaseWindow
   {
      
      private var _ui:Sprite;
      
      private var _txtInfo:TextField;
      
      private var _img:Sprite;
      
      private var _gift:Object;
      
      private var _tip:String;
      
      private var _txtDesc:TextField;
      
      private var _txtName:TextField;
      
      private var _cropsInfo:String;
      
      public function PickupGiftWindow(param1:IMsgCenter)
      {
         super(param1);
         title = "";
         width = 393;
         height = 363;
         mode = true;
         windowName = Consts.WINDOW_NAME_REGIFT;
         this._tip = "作物类型：@harvestTimes季作物<br/>成熟时间：<font color=\'#339933\'> <b>@growTime</b> </font>小时<br/>预计产量：<font color=\'#339933\'> <b>@output</b> </font>个<br/>果实售价：金币<font color=\'#FF6600\'> <b>@sale</b> </font><br/>预计收入：金币<font color=\'#FF6600\'> <b>@outputMoney</b> </font><br/>收获经验：<font color=\'#FF6600\'> <b>@exp</b> </font>/季<br/>种植等级：<font color=\'#339933\'> <b>@level</b> </font> 级";
         this._ui = Utils.getMaterial("REWindowContentCrops") as Sprite;
         this._txtInfo = this._ui.getChildByName("txtInfo") as TextField;
         this._txtName = this._ui.getChildByName("txtName") as TextField;
         this._txtDesc = this._ui.getChildByName("txtDesc") as TextField;
         this._img = this._ui.getChildByName("mcImg") as Sprite;
         this._img.mouseChildren = false;
         this._gift = null;
         this._ui.y = 30;
         this._txtName.mouseEnabled = this._txtDesc.mouseEnabled = false;
         this._txtInfo.addEventListener(TextEvent.LINK,this.onNavigateToURL);
         this._txtInfo.mouseEnabled = true;
         this._txtInfo.selectable = false;
         this._txtDesc.mouseWheelEnabled = false;
         this._ui.visible = false;
         addChild(this._ui);
         var _loc2_:Button = new Button();
         _loc2_.defaultSkin = Utils.getClass("ButtonBlue");
         _loc2_.width = 64;
         _loc2_.height = 25;
         _loc2_.x = width / 2 - 32;
         _loc2_.y = height - 45;
         _loc2_.text = "确定";
         _loc2_.addEventListener(MouseEvent.CLICK,this.onOk);
         addChild(_loc2_);
      }
      
      private function onDelayAction(param1:TimerEvent) : void
      {
         var _loc3_:Object = null;
         this._ui.visible = true;
         var _loc2_:FarmApplication = this.m_msgCenter as FarmApplication;
         if(_loc2_ != null)
         {
            _loc3_ = {
               "cId":this._gift["id"],
               "cName":this._gift["name"],
               "type":1,
               "amount":this._gift["num"],
               "level":this._gift["level"],
               "lifecycle":0
            };
            _loc2_.dispatchEvent(new CommonEvent(Consts.DATA_BAG_DATA_ADD,_loc3_));
         }
      }
      
      override protected function setSize() : void
      {
         super.setSize();
         panelTitle.x = AlignUtil.middle(_width,panelTitle.width);
      }
      
      private function onOk(param1:MouseEvent) : void
      {
         onClose(param1);
      }
      
      private function onNavigateToURL(param1:TextEvent) : void
      {
         var _loc2_:String = param1.text;
         ExternalInterface.call("window.open",_loc2_);
      }
      
      private function onMouseOut(param1:MouseEvent) : void
      {
         var _loc2_:FarmApplication = this.m_msgCenter as FarmApplication;
         if(_loc2_ != null)
         {
            _loc2_.hideTip();
         }
      }
      
      override protected function setData() : void
      {
         var _loc7_:String = null;
         var _loc1_:Object = super.data["send"];
         if(_loc1_ == null)
         {
            return;
         }
         this.graphics.clear();
         var _loc2_:Boolean = super.data.hasOwnProperty("dig");
         if(_loc2_ == true)
         {
            title = "神秘种子";
            this._cropsInfo = "翻地翻到宝啦！恭喜您，翻地时挖到<font color = \'#ff0000\'>@num" + "</font>个@name种子，它的果实可在加工坊加工神秘绚丽的“多彩葫芦套装”。<U><font color=\'#0075C4\'>" + "<a href=\'http://blog.qq.com/qzone/1006666001/1309419519.htm\' target=\'_blank\'>点击查看套装搭配样例</a></font></U>";
            this._txtInfo.width = 373;
            this._txtInfo.x = 11;
         }
         else if(_loc1_["id"] == "169" || _loc1_["id"] == "170" || _loc1_["id"] == "171")
         {
            this._cropsInfo = Settings.getInstance().getStringAttribute("pickupGiftFunny");
            this._txtInfo.width = 373;
            this._txtInfo.x = 11;
            title = "农场趣味种子";
         }
         else
         {
            this._cropsInfo = Settings.getInstance().getStringAttribute("pickupgift");
            this._txtInfo.width = 346;
            this._txtInfo.x = 20;
            title = "神秘礼包";
         }
         if(this._cropsInfo == "")
         {
            this._cropsInfo = "哇！居然在地里捡到<font color=\"#339933\"><b>&nbsp;@num&nbsp;</b></font>个在商店尚不公开出售的隐藏种子。千载难逢的事情都让您给碰上了，真是天道酬勤哪！";
         }
         this._gift = _loc1_;
         if(_loc1_.type == 1)
         {
            this._cropsInfo = this._cropsInfo.replace(/@num/g,_loc1_["num"]);
            this._cropsInfo = this._cropsInfo.replace(/@name/g,_loc1_["name"]);
            this._txtInfo.htmlText = this._cropsInfo;
            _loc1_["growTime"] /= 3600;
            for(_loc7_ in _loc1_)
            {
               this._tip = this._tip.replace("@" + _loc7_,_loc1_[_loc7_]);
            }
            this._tip = this._tip.replace(/@outputMoney/,_loc1_["harvestTimes"] * _loc1_["output"] * _loc1_["sale"]);
         }
         this._txtName.htmlText = "<font color=\'#339933\'>" + _loc1_["name"] + "</font><font color=\'#FF6600\'><b> " + _loc1_["num"] + " </b></font>个";
         this._txtDesc.htmlText = _loc1_["desc"];
         var _loc3_:RSLManager = RSLManager.getInstance();
         var _loc4_:Settings = Settings.getInstance();
         var _loc5_:String = GetCropID.getSeedUrl(_loc1_["id"]);
         _loc3_.requestClass(_loc4_.getSeedName(_loc1_["id"]),this.onCropLoaded,_loc5_);
         var _loc6_:Timer = new Timer(200,1);
         _loc6_.addEventListener(TimerEvent.TIMER,this.onDelayAction,false,0,true);
         _loc6_.start();
         this.setSize();
      }
      
      private function onCropLoaded() : void
      {
         if(this._gift == null || this._gift["id"] == undefined)
         {
            return;
         }
         var _loc1_:String = Settings.getInstance().getSeedName(this._gift["id"]);
         if(_loc1_ == null || _loc1_ == "")
         {
            return;
         }
         var _loc2_:DisplayObject = Utils.getMaterial(_loc1_) as DisplayObject;
         if(_loc2_ != null)
         {
            _loc2_.scaleX = 2;
            _loc2_.scaleY = 2;
            _loc2_.x = AlignUtil.middle(120,_loc2_.width);
            _loc2_.y = AlignUtil.middle(120,_loc2_.height);
            if(this._img.numChildren > 0)
            {
               this._img.removeChildAt(0);
            }
            this._img.addChild(_loc2_);
            this._img.addEventListener(MouseEvent.ROLL_OVER,this.onMouseOver,false,0,true);
            this._img.addEventListener(MouseEvent.ROLL_OUT,this.onMouseOut,false,0,true);
         }
      }
      
      private function onMouseOver(param1:MouseEvent) : void
      {
         var _loc2_:FarmApplication = this.m_msgCenter as FarmApplication;
         if(_loc2_ != null)
         {
            _loc2_.showTip(Consts.TIP_NAME_CROPINFO_MOUSE,this._tip);
         }
      }
      
      public function get disableAnimation() : Boolean
      {
         return true;
      }
   }
}

