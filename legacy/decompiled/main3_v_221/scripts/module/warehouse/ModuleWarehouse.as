package module.warehouse
{
   import common.Consts;
   import common.misc.Utils;
   import framework.base.BaseLayer;
   import framework.base.Controller;
   import framework.base.Module;
   import module.FarmApplication;
   
   public class ModuleWarehouse extends Module
   {
      
      private var _myBagCtrl:Controller;
      
      private var _warehouseCtrl:Controller;
      
      public function ModuleWarehouse(param1:FarmApplication)
      {
         super(param1);
         _reportID = "160592";
      }
      
      override public function load(param1:BaseLayer) : void
      {
      }
      
      override public function unload() : void
      {
         if(this._myBagCtrl != null)
         {
            this._myBagCtrl.finalize();
            this._myBagCtrl = null;
         }
         if(this._warehouseCtrl != null)
         {
            this._warehouseCtrl.finalize();
            this._warehouseCtrl = null;
         }
      }
      
      override protected function onModuleLoadSuccess() : void
      {
         var _loc1_:Class = Utils.getClass("module.warehouse.bag.MyBagController");
         if(_loc1_ != null)
         {
            this._myBagCtrl = new _loc1_();
            this._myBagCtrl.module = this;
            this._myBagCtrl.initialze();
         }
         _loc1_ = Utils.getClass("module.warehouse.house.WarehouseController");
         if(_loc1_ != null)
         {
            this._warehouseCtrl = new _loc1_();
            this._warehouseCtrl.module = this;
            this._warehouseCtrl.initialze();
         }
      }
      
      override public function get name() : String
      {
         return Consts.MODULE_WAREHOUSE;
      }
   }
}

