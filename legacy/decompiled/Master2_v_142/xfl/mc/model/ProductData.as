package mc.model
{
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import mc.view.farm.GetCropID;
   
   public class ProductData extends EventDispatcher
   {
      
      public static const ANIMAL_FOOD:String = "animalFood_Change";
      
      public static const PRODUCT_CHANGES:String = "product_change";
      
      public static const PRODUCT_CANDO:String = "product_cando";
      
      public static const PRODUCT_INIT:String = "product_init";
      
      public static const PRODUCT_ADD:String = "product_addproduct";
      
      private var _products:Object;
      
      public function ProductData()
      {
         super();
      }
      
      public function init(param1:Object) : void
      {
         var _loc3_:String = null;
         this._products = {};
         var _loc2_:Array = param1["animal"];
         for(_loc3_ in _loc2_)
         {
            this._products[_loc2_[_loc3_].cId] = {
               "cName":GetCropID.getProductName2(_loc2_[_loc3_].cId),
               "amount":0,
               "cando":0
            };
         }
         dispatchEvent(new Event(ProductData.PRODUCT_INIT));
      }
      
      public function get products() : Object
      {
         return this._products;
      }
      
      public function set products(param1:Object) : void
      {
         this._products = param1;
      }
      
      public function getProduct(param1:String) : Object
      {
         return this.products[param1];
      }
      
      public function addCando(param1:String, param2:Number) : void
      {
         this._products[param1].cando = param2;
      }
      
      public function addProduct(param1:String, param2:Number, param3:Boolean = false, param4:Boolean = false) : void
      {
         var _loc5_:ModelEvent = null;
         if(!this._products[param1])
         {
            this._products[param1] = {
               "cName":GetCropID.getProductName2(param1),
               "amount":0,
               "cando":0
            };
            _loc5_ = new ModelEvent(ProductData.PRODUCT_ADD);
            _loc5_.data = param1;
            dispatchEvent(_loc5_);
         }
         this._products[param1].amount += param2;
         if(param3)
         {
            this._products[param1].amount = 0;
         }
         if(param4)
         {
            this._products[param1].cando = 3;
         }
         dispatchEvent(new Event(ProductData.PRODUCT_CHANGES));
      }
   }
}

