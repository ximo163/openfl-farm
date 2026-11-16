package mc.api
{
   import common.INI;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import mc.FBridge.FRequest;
   import mc.control.Command;
   import mc.control.MainCommand;
   import mc.model.MData;
   import mc.model.MainData;
   import mc.view.farm.GetCropID;
   
   public class WildCommand extends EventDispatcher
   {
      
      private static var instance:WildCommand;
      
      private var commURL:String;
      
      private var mainData:MainData;
      
      private var fr:FRequest;
      
      private var iniData:XML;
      
      private var mainCommand:MainCommand;
      
      private var wildData:WildData;
      
      private var commURLnc:String;
      
      public function WildCommand(param1:IEventDispatcher = null)
      {
         super(param1);
         this.fr = FRequest.getInstance();
         this.mainData = MData.getInstance().mainData;
         this.commURL = GetCropID.getCommonUrlFarm();
         this.commURLnc = GetCropID.getCommonUrlNc();
         this.mainCommand = Command.getInstance().mainCommand;
         this.iniData = INI.getInstance().data;
      }
      
      public static function getInstance() : WildCommand
      {
         if(!instance)
         {
            instance = new WildCommand();
         }
         return instance;
      }
      
      private function showErr(param1:Object) : void
      {
         if(param1.hasOwnProperty("direction"))
         {
            this.mainCommand.alertWindow("error",param1["direction"]);
         }
         else
         {
            this.mainCommand.alertWindow("error","系统繁忙,请重试。");
         }
      }
      
      public function saleCrystal(param1:int, param2:int) : void
      {
         this.fr.postRequest(INI.getInstance().getPostUrl() + "cgi_farm_sell_crystal",{
            "id":param1,
            "num":param2
         },this.saleCrystalFn);
      }
      
      private function saleCrystalFn(param1:Object) : void
      {
         if(param1["ecode"] == 0)
         {
            this.mainCommand.floatWindow(param1["direction"]);
            WildData.reloadCrystal = true;
            this.mainCommand.getUserMaterial();
            this.mainCommand.addMoney(param1);
         }
         else
         {
            this.showErr(param1);
         }
      }
      
      public function getCrystals() : void
      {
         if(WildData.reloadCrystal)
         {
            this.wildData.crystalsLoading = true;
            this.fr.postRequest(this.commURL + "cgi_farm_get_usercrystal",{"type":9},this.crystalFn);
            return;
         }
         if(this.wildData.crystals)
         {
            this.wildData.crystals = this.wildData.crystals;
         }
      }
      
      private function crystalFn(param1:Object) : void
      {
         if(param1["ecode"] == 0)
         {
            WildData.reloadCrystal = false;
            this.wildData.crystalsLoading = false;
            this.wildData.crystals = param1["info"];
         }
         else
         {
            this.wildData.crystalsError = "请求超时，<a href=\'event:reload\'><u><font color=\'#ff6600\'>点击重试</font></u></a>";
         }
      }
   }
}

