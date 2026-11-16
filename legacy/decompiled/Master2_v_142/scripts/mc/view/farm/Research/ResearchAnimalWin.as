package mc.view.farm.Research
{
   import com.minutes.ui.control.LipiButton;
   import com.minutes.ui.core.LipiSkin;
   import common.MaterialLib;
   import flash.display.DisplayObject;
   import flash.display.Loader;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.events.TextEvent;
   import flash.external.ExternalInterface;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import mc.control.ViewControl;
   import mc.events.WindowEvent;
   import mc.model.MData;
   import mc.view.common.BaseWindow;
   import mc.view.common.Language;
   import mc.view.common.MoneyIcon;
   import mc.view.farm.GetCropID;
   import mc.view.main.WindowControl.WControl;
   import mc.view.main.window.shop.ErrorText;
   
   public class ResearchAnimalWin extends BaseWindow
   {
      
      private var buyTipText:TextField;
      
      private var _shopSeedForm:Object;
      
      private var directionText:TextField;
      
      private var levelText:TextField;
      
      private var confirmButton:LipiButton;
      
      private var errorText:ErrorText;
      
      private var cropPrice:TextField;
      
      private var cLevel:int = 99;
      
      private var tipText:TextField;
      
      private var userMoney:Number = 0;
      
      public function ResearchAnimalWin()
      {
         super();
         width = 510;
         height = 420;
         titleIMG = MaterialLib.getInstance().getClass("ShopSeedWindowTitle");
         windowName = "ResearchAnimalWin";
         mode = true;
         this.init();
      }
      
      private function confirmButtonClick(param1:MouseEvent = null) : void
      {
         if(this.confirmButton.enable == true)
         {
            WControl.close(this);
         }
      }
      
      override public function init() : void
      {
         var _loc3_:LipiButton = null;
         var _loc1_:MoneyIcon = new MoneyIcon();
         this.cropPrice = new TextField();
         this.cropPrice.selectable = false;
         this.cropPrice.defaultTextFormat = new TextFormat("_sans",11,16737792,true);
         this.cropPrice.text = "300";
         this.cropPrice.width = 100;
         this.cropPrice.height = 22;
         _loc1_.x = 67;
         _loc1_.y = 155;
         this.cropPrice.x = 95;
         this.cropPrice.y = 155;
         this.directionText = new TextField();
         this.directionText.mouseEnabled = false;
         this.directionText.selectable = false;
         this.directionText.x = 15;
         this.directionText.y = 213;
         this.directionText.width = 180;
         this.directionText.autoSize = TextFieldAutoSize.CENTER;
         this.directionText.defaultTextFormat = new TextFormat("_sans",12,8999699);
         this.directionText.text = Language.replaceText("buyNum",{
            "minNum":1,
            "maxNum":99
         });
         this.errorText = new ErrorText(false);
         this.errorText.visible = false;
         this.errorText.y = 212;
         addChild(this.errorText);
         this.tipText = new TextField();
         this.tipText.width = 460;
         this.tipText.wordWrap = true;
         this.tipText.multiline = true;
         this.tipText.autoSize = TextFieldAutoSize.LEFT;
         this.tipText.x = (this.width - this.tipText.width) / 2;
         this.tipText.selectable = false;
         this.tipText.mouseWheelEnabled = false;
         addChild(this.tipText);
         this.tipText.y = 300;
         this.buyTipText = new TextField();
         this.buyTipText.wordWrap = false;
         this.buyTipText.multiline = false;
         this.buyTipText.autoSize = TextFieldAutoSize.CENTER;
         this.buyTipText.selectable = false;
         this.buyTipText.mouseWheelEnabled = false;
         this.buyTipText.defaultTextFormat = new TextFormat("_sans",12,16737792);
         this.buyTipText.x = 15;
         this.buyTipText.y = 235;
         this.buyTipText.width = 180;
         this.levelText = new TextField();
         this.levelText.wordWrap = false;
         this.levelText.multiline = false;
         this.levelText.autoSize = TextFieldAutoSize.LEFT;
         this.levelText.selectable = false;
         this.levelText.mouseWheelEnabled = false;
         this.levelText.defaultTextFormat = new TextFormat("_sans",12,16737792);
         var _loc2_:Sprite = this.createDashedLine(16103542,466,2,2,4);
         addChild(_loc2_);
         _loc2_.x = (this.width - _loc2_.width) / 2;
         _loc2_.y = 290;
         this.confirmButton = new LipiButton();
         this.confirmButton.bgAlpha = 0;
         this.confirmButton.bgSkin = new LipiSkin(MaterialLib.getInstance().getClass("ButtonOrange"));
         this.confirmButton.width = 64;
         this.confirmButton.height = 25;
         this.confirmButton.x = width / 2 - this.confirmButton.width - 10;
         this.confirmButton.y = height - 45;
         this.confirmButton.label = "确定";
         this.confirmButton.textColor = 16777215;
         this.confirmButton.addEventListener(MouseEvent.CLICK,this.confirmButtonClick);
         addChild(this.confirmButton);
         _loc3_ = new LipiButton();
         _loc3_.bgAlpha = 0;
         _loc3_.bgSkin = new LipiSkin(MaterialLib.getInstance().getClass("ButtonBlue"));
         _loc3_.width = 64;
         _loc3_.height = 25;
         _loc3_.x = width / 2 + 10;
         _loc3_.y = height - 45;
         _loc3_.label = "取消";
         _loc3_.textColor = 16777215;
         _loc3_.addEventListener(MouseEvent.CLICK,this.cancelButtonClick);
         addChild(_loc3_);
         this.setData();
      }
      
      override public function set data(param1:Object) : void
      {
         super.data = param1;
         this.setData();
      }
      
      private function cancelButtonClick(param1:MouseEvent) : void
      {
         var _loc2_:WindowEvent = new WindowEvent(WindowEvent.CLOSE);
         _loc2_.window = this;
         ViewControl.getInstance().dispatchEvent(_loc2_);
      }
      
      private function vipButtonClick(param1:MouseEvent = null) : void
      {
         navigateToURL(new URLRequest("tools.php?mod=vip"),"_blank");
      }
      
      private function canNotBuy() : void
      {
         this.cropPrice.text = "0";
      }
      
      private function createDashedLine(param1:Number, param2:Number, param3:Number, param4:Number, param5:Number) : Sprite
      {
         var _loc6_:Sprite = new Sprite();
         var _loc7_:Number = 0;
         var _loc8_:Number = Math.floor(param2 / (param4 + param5));
         var _loc9_:Number = 0;
         while(_loc9_ < _loc8_)
         {
            _loc6_.graphics.lineStyle(param3,param1,1);
            _loc6_.graphics.moveTo(_loc9_ * (param4 + param5),0);
            _loc6_.graphics.lineTo(_loc9_ * (param4 + param5) + param4,0);
            _loc9_++;
         }
         return _loc6_;
      }
      
      private function setData() : void
      {
         var _loc2_:String = null;
         var _loc3_:Loader = null;
         var _loc9_:String = null;
         var _loc1_:Object = data;
         if(_loc1_ == null)
         {
            return;
         }
         if(this._shopSeedForm == null)
         {
            _loc9_ = "";
            this._shopSeedForm = MaterialLib.getInstance().getMaterial("ResearchMsgForm") as Object;
            this._shopSeedForm.x = 225;
            this._shopSeedForm.y = 30;
            if(this._shopSeedForm["level"] != undefined)
            {
               this.levelText.x = this._shopSeedForm["level"].x;
               this.levelText.y = this._shopSeedForm["level"].y;
               this.levelText.width = this._shopSeedForm["level"].width;
               this._shopSeedForm.removeChild(this._shopSeedForm["level"] as DisplayObject);
               this._shopSeedForm.addChild(this.levelText);
            }
            addChild(this._shopSeedForm as DisplayObject);
         }
         this.initBuyNumber();
         this._shopSeedForm.time2.text = _loc1_["procreation"] / 3600;
         this._shopSeedForm.time.text = _loc1_["maturingTime"] / 3600;
         _loc2_ = GetCropID.getShopIconUrl(_loc1_["cId"],true);
         _loc3_ = new Loader();
         _loc3_.load(new URLRequest(_loc2_));
         addChild(_loc3_);
         _loc3_.x = 20;
         _loc3_.y = 100;
         if(_loc1_.hasOwnProperty("bsprice") && int(_loc1_["bsprice"]) > 0)
         {
            this._shopSeedForm.price.width += 120;
            if(Boolean(_loc1_.iscoinexp) && _loc1_.iscoinexp == 1)
            {
               this._shopSeedForm.price.htmlText = _loc1_["bsprice"] + "经验" + "<font color = \'#895313\'>（原价：经验" + _loc1_["byproductprice"] + "）</font>";
            }
            else
            {
               this._shopSeedForm.price.htmlText = _loc1_["bsprice"] + "金币" + "<font color = \'#895313\'>（原价：金币" + _loc1_["byproductprice"] + "）</font>";
            }
         }
         else if(Boolean(_loc1_.iscoinexp) && _loc1_.iscoinexp == 1)
         {
            this._shopSeedForm.price.text = _loc1_["byproductprice"] + "经验";
         }
         else
         {
            this._shopSeedForm.price.text = _loc1_["byproductprice"] + "金币";
         }
         this._shopSeedForm.cropName.text = _loc1_["cName"];
         this._shopSeedForm.cropName.width = 180;
         this._shopSeedForm.amount.text = int(_loc1_["output"]);
         this._shopSeedForm.consum.text = int(_loc1_["consum"]);
         this._shopSeedForm.cycle.text = int(_loc1_["cycle"]) / 3600;
         if(_loc1_.hasOwnProperty("msprice") && int(_loc1_["msprice"]) > 0)
         {
            this._shopSeedForm.productPrice.width += 120;
            this._shopSeedForm.productPrice.htmlText = _loc1_["msprice"] + "金币" + "<font color = \'#895313\'>（原价：金币" + _loc1_["productprice"] + "）</font>";
         }
         else
         {
            this._shopSeedForm.productPrice.text = int(_loc1_["productprice"]) + "金币";
         }
         if(int(_loc1_["cType"]) == 4)
         {
            this._shopSeedForm.productPrice.text += "×" + int(_loc1_["expect"]) + "份";
            this._shopSeedForm.productPrice.width += 40;
         }
         this.levelText.text = _loc1_["cLevel"];
         this._shopSeedForm.house.text = GetCropID.getHouse(_loc1_["cId"]);
         this._shopSeedForm.researchTime.text = _loc1_["researchtime"] / 60 / 60 + "小时";
         if(Boolean(_loc1_.iscoinexp) && (_loc1_.iscoinexp == 1 || _loc1_.iscoinexp == 2))
         {
            this._shopSeedForm.researchPrice.text = _loc1_["researchcost"] + "元宝";
         }
         else
         {
            this._shopSeedForm.researchPrice.text = _loc1_["researchcost"] + "金币";
         }
         var _loc4_:String = "小贴士：" + GetCropID.getTipInfo(_loc1_["cId"]);
         var _loc5_:TextFormat = new TextFormat();
         _loc5_.leading = 4;
         _loc5_.color = 8999699;
         this.tipText.htmlText = _loc4_;
         this.tipText.setTextFormat(_loc5_);
         this.tipText.addEventListener(TextEvent.LINK,this.linkHandler);
         var _loc6_:RegExp = /<a href.*?><u>/i;
         var _loc7_:int = 0;
         var _loc8_:Array = this.tipText.htmlText.match(_loc6_);
         if(_loc8_)
         {
            _loc7_ = (_loc8_[0] as String).length;
         }
      }
      
      private function linkHandler(param1:TextEvent) : void
      {
         ExternalInterface.call("window.open",param1.text);
      }
      
      override public function keyEnter() : void
      {
         this.confirmButtonClick();
      }
      
      private function initBuyNumber() : void
      {
         var _loc1_:Object = MData.getInstance().mainData;
         var _loc2_:Object = _loc1_.host;
         var _loc3_:int = int(_loc1_.expToGrade(_loc2_["exp"]));
         if(this.errorText.text == "")
         {
            if(_loc3_ < int(data["cLevel"]))
            {
               this.errorText.text = "对不起，您的等级不足。";
               this.errorText.visible = true;
               this.errorText.x = Math.floor(this.width - this.errorText.width) / 2 - 145;
               this.directionText.visible = false;
               this.canNotBuy();
               return;
            }
         }
         this.userMoney = parseInt(_loc2_["money"]);
         var _loc4_:int = parseInt(data["price"]);
         if(_loc4_ <= 0)
         {
            this.canNotBuy();
            return;
         }
         var _loc5_:int = Math.floor(this.userMoney / _loc4_);
         var _loc6_:int = 0;
         if(GetCropID.getHouse(data["cId"]) == "窝")
         {
            _loc6_ = int(_loc1_.getAnimalNum(_loc2_["house1"],"窝"));
            _loc6_ = _loc6_ - _loc2_["animal1"];
         }
         else if(_loc2_["house2"] == 0)
         {
            _loc6_ = 0;
         }
         else
         {
            _loc6_ = int(_loc1_.getAnimalNum(_loc2_["house2"],"棚"));
            _loc6_ = _loc6_ - _loc2_["animal2"];
         }
         if(this.errorText.text == "")
         {
            if(_loc5_ >= 1 && _loc6_ >= 1)
            {
               if(_loc5_ < _loc6_)
               {
                  this.buyTipText.text = "当前金币最多可买" + _loc5_ + "只";
                  this.buyTipText.visible = true;
                  if(_loc5_ == 1)
                  {
                     this.directionText.visible = false;
                     this.buyTipText.y = this.directionText.y;
                  }
                  else
                  {
                     this.directionText.visible = true;
                     this.directionText.text = Language.replaceText("buyNum",{
                        "minNum":1,
                        "maxNum":_loc5_
                     });
                     if(data["isvip"])
                     {
                        this.buyTipText.y = 270;
                     }
                     else
                     {
                        this.buyTipText.y = 235;
                     }
                  }
               }
               else if(_loc6_ == 1)
               {
                  this.directionText.visible = false;
                  this.buyTipText.y = this.directionText.y;
               }
               else
               {
                  this.directionText.text = Language.replaceText("buyNum",{
                     "minNum":1,
                     "maxNum":_loc6_
                  });
                  this.directionText.visible = true;
                  if(data["isvip"])
                  {
                     this.buyTipText.y = 270;
                  }
                  else
                  {
                     this.buyTipText.y = 235;
                  }
               }
               this.confirmButton.enable = true;
            }
            else
            {
               this.directionText.visible = false;
               this.buyTipText.visible = false;
               if(_loc5_ < 1)
               {
                  this.errorText.text = "您的金币不足";
                  this.errorText.x = Math.floor(this.width - this.errorText.width) / 2 - 145;
                  this.canNotBuy();
                  return;
               }
               if(_loc6_ < 1)
               {
                  this.errorText.x = Math.floor(this.width - this.errorText.width) / 2 - 157;
                  this.canNotBuy();
                  return;
               }
            }
         }
      }
   }
}

