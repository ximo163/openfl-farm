package framework.api.beast
{
   import common.Settings;
   import flash.events.EventDispatcher;
   import module.FarmApplication;
   
   public class WildCommand extends EventDispatcher
   {
      
      private static var instance:WildCommand;
      
      public var api:BeastAPI;
      
      private var commURL:String;
      
      public var farmApp:FarmApplication;
      
      private var wildData:WildData;
      
      public function WildCommand()
      {
         super();
         this.commURL = Settings.getInstance().mcCommUrl;
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
            this.api.alertWindow("error",param1["direction"]);
         }
         else
         {
            this.api.alertWindow("error","系统繁忙,请重试。");
         }
      }
      
      public function saleCrystal(param1:int, param2:int) : void
      {
         this.api.postRequest(this.commURL + "cgi_farm_sell_crystal",{
            "id":param1,
            "num":param2
         },this.saleCrystalFn);
      }
      
      private function saleCrystalFn(param1:Object) : void
      {
         if(param1["ecode"] == 0)
         {
            this.farmApp.farmView.floatCtrl;
            this.api.floatWindow(param1["direction"]);
            WildData.reloadCrystal = true;
            this.farmApp.dispatchEvent(new EvtAPI(EvtAPI.REFRESH_CRYSTAL));
            this.farmApp.farmView.floatCtrl;
            this.api.addMoney(param1);
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
            this.farmApp.dispatchEvent(new EvtAPI(EvtAPI.REFRESH_CRYSTAL));
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

