package mc.control
{
   import common.LocalData;
   import common.MaterialLib;
   import flash.events.Event;
   import mc.FBridge.EventRecorder;
   import mc.FBridge.FRequest;
   import mc.model.FarmData;
   import mc.model.MData;
   import mc.view.common.ConfirmWindow;
   import mc.view.farm.GetCropID;
   import mc.view.farm.animals.Animal;
   import mc.view.farm.land.Pasturelands;
   import mc.view.main.WindowControl.WControl;
   
   public final class DonateAnimalCommand
   {
      
      private static var _instance:DonateAnimalCommand = null;
      
      private var _targetAnimal:Animal;
      
      private var _donate_confirm:ConfirmWindow;
      
      private var _fr:FRequest;
      
      private var _isDonating:Boolean;
      
      private var _farmData:FarmData;
      
      public function DonateAnimalCommand()
      {
         super();
         this._donate_confirm = null;
         this._fr = FRequest.getInstance();
         this._isDonating = false;
         this._targetAnimal = null;
         this._farmData = MData.getInstance().farmData;
      }
      
      public static function getInstance() : DonateAnimalCommand
      {
         if(_instance != null)
         {
            return _instance;
         }
         _instance = new DonateAnimalCommand();
         return _instance;
      }
      
      private function donateRequest(param1:int) : void
      {
         if(this._isDonating)
         {
            return;
         }
         var _loc2_:* = {"serial":param1};
         this._fr.postRequest("cgi_donate_animal",_loc2_,this.donateResponse);
         this._isDonating = true;
      }
      
      public function donateAnimal(param1:Animal) : void
      {
         var _loc3_:String = null;
         var _loc4_:* = undefined;
         if(param1 == null || param1.data == null)
         {
            return;
         }
         this._targetAnimal = param1;
         var _loc2_:int = int(param1.data.status);
         if(_loc2_ == FarmData.ANIMAL_SHENGCHAN)
         {
            this._farmData.farmOperate = {
               "text":"生产中动物不能操作！",
               "type":"animal",
               "serial":param1.data["serial"]
            };
         }
         else if(_loc2_ == FarmData.ANIMAL_SHOUHUO)
         {
            this._farmData.farmOperate = {
               "text":"成熟动物请收获！",
               "type":"animal",
               "serial":param1.data["serial"]
            };
         }
         else
         {
            _loc4_ = GetCropID.getAnimalInfo(param1.data["cId"]);
            _loc3_ = "动物还没有成熟，爱心捐赠将获得感谢金<b><font color=\"#4DA337\">" + GetCropID.getAnimalInfo(param1.data["cId"]).@price / 2 + "</font></b>金币。<BR/>您确定要这么做吗？<BR/>温馨提示：爱心捐赠不获得经验。";
            if(this._donate_confirm == null)
            {
               this._donate_confirm = new ConfirmWindow();
               this._donate_confirm.width = 440;
               this._donate_confirm.titleIMG = MaterialLib.getInstance().getClass("DonateTitle");
            }
            this._donate_confirm.data = {"text":_loc3_};
            this._donate_confirm.confirmFn = this.onConfirmDonate;
            this._donate_confirm.confirmEnable = true;
            WControl.open(this._donate_confirm);
         }
      }
      
      private function donateResponse(param1:Object) : void
      {
         this._isDonating = false;
         if(param1 == null)
         {
            return;
         }
         var _loc2_:MainCommand = Command.getInstance().mainCommand;
         if(param1["errorCode"] != undefined && param1["errorContent"] != undefined)
         {
            _loc2_.floatWindow(param1["errorContent"]);
            EventRecorder.recordErrorEvent("160934",0,14);
            return;
         }
         if(param1["cId"] != undefined && param1["direction"] != undefined && param1["money"] != undefined)
         {
            EventRecorder.recordSueecssEvent("160934",0);
            _loc2_.addMoney(param1);
            _loc2_.floatWindow(param1["direction"]);
            this.onDonateSuccess(param1["cId"],param1["serial"]);
         }
      }
      
      private function onConfirmDonate() : void
      {
         if(this._donate_confirm == null)
         {
            return;
         }
         if(this._targetAnimal == null || this._targetAnimal.data == null)
         {
            return;
         }
         this.donateRequest(this._targetAnimal.data["serial"]);
      }
      
      private function onDonateSuccess(param1:int, param2:int) : void
      {
         if(param1 == 0 || param2 == 0)
         {
            return;
         }
         if(this._targetAnimal == null || this._targetAnimal.data == null)
         {
            return;
         }
         if(param1 != this._targetAnimal.data["cId"] || param2 != this._targetAnimal.data["serial"])
         {
            return;
         }
         var _loc3_:Pasturelands = LocalData.plands as Pasturelands;
         if(_loc3_ != null)
         {
            _loc3_.removeAnimal(this._targetAnimal);
         }
         ViewControl.getInstance().dispatchEvent(new Event("animal_change"));
      }
   }
}

