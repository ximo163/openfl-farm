package mc.model
{
   import common.CommonData;
   import flash.events.EventDispatcher;
   
   public class MData extends EventDispatcher
   {
      
      private static var instance:MData;
      
      private var _tooldata:ToolData;
      
      private var _mainData:MainData;
      
      private var _tinData:TinItemsData = null;
      
      private var _productData:ProductData;
      
      private var _farmData:FarmData;
      
      public function MData()
      {
         if(instance == null)
         {
            super();
            return;
         }
         throw new Error("实例化单例类出错-LifeData");
      }
      
      public static function getInstance() : MData
      {
         if(instance == null)
         {
            instance = new MData();
         }
         return instance;
      }
      
      public function get farmData() : FarmData
      {
         if(this._farmData == null)
         {
            this._farmData = new FarmData();
         }
         return this._farmData;
      }
      
      public function get mainData() : MainData
      {
         if(this._mainData == null)
         {
            this._mainData = new MainData();
         }
         return this._mainData;
      }
      
      public function showYellowPackageTest() : String
      {
         var _loc1_:String = null;
         var _loc2_:int = int(CommonData.serverTime);
         var _loc3_:MainData = MData.getInstance().mainData;
         return "uIdx=" + _loc3_.getHostId;
      }
      
      public function get tinData() : TinItemsData
      {
         if(this._tinData != null)
         {
            return this._tinData;
         }
         this._tinData = new TinItemsData();
         return this._tinData;
      }
      
      public function get toolData() : ToolData
      {
         if(this._tooldata == null)
         {
            this._tooldata = new ToolData();
         }
         return this._tooldata;
      }
      
      public function get productData() : ProductData
      {
         if(this._productData == null)
         {
            this._productData = new ProductData();
         }
         return this._productData;
      }
   }
}

