package mc.view.common
{
   import common.MaterialLib;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.filters.ColorMatrixFilter;
   import mc.view.farm.GetCropID;
   
   public class MaterialProxy extends Sprite
   {
      
      public static const BIG:String = "big";
      
      public static const SMALL:String = "small";
      
      protected var currentType:String = "";
      
      protected var _size:String;
      
      protected var _enable:Boolean = true;
      
      protected var _h:int = 60;
      
      protected var currentId:int = 0;
      
      protected var childObjcet:DisplayObject;
      
      protected var _w:int = 60;
      
      public function MaterialProxy()
      {
         super();
         this._w = this._h = 61;
      }
      
      protected function remove() : void
      {
         if(this.childObjcet != null)
         {
            removeChild(this.childObjcet);
            this.childObjcet = null;
         }
      }
      
      private function setCrop(param1:int) : void
      {
         var _loc2_:String = "Seed" + param1.toString();
         this.remove();
         if(_loc2_ == "")
         {
            return;
         }
         var _loc3_:MaterialLib = MaterialLib.getInstance();
         this.childObjcet = _loc3_.getMaterial(_loc2_) as DisplayObject;
         if(!this.childObjcet)
         {
            return;
         }
         this.childObjcet.x = (this._w - this.childObjcet.width) / 2;
         this.childObjcet.y = (this._h - this.childObjcet.height) / 2;
         if(this._enable)
         {
            this.childObjcet.filters = [];
         }
         else
         {
            this.childObjcet.filters = [new ColorMatrixFilter([0.3086,0.6094,0.082,0,0,0.3086,0.6094,0.082,0,0,0.3086,0.6094,0.082,0,0,0,0,0,1,0])];
         }
         addChild(this.childObjcet);
      }
      
      private function setTool2(param1:int) : void
      {
         var _loc2_:String = "Food" + param1;
         this.remove();
         if(_loc2_ == "")
         {
            return;
         }
         var _loc3_:MaterialLib = MaterialLib.getInstance();
         this.childObjcet = _loc3_.getMaterial(_loc2_) as DisplayObject;
         this.childObjcet.x = (this._w - this.childObjcet.width) / 2;
         this.childObjcet.y = (this._h - this.childObjcet.height) / 2;
         if(this._enable)
         {
            this.childObjcet.filters = [];
         }
         else
         {
            this.childObjcet.filters = [new ColorMatrixFilter([0.3086,0.6094,0.082,0,0,0.3086,0.6094,0.082,0,0,0.3086,0.6094,0.082,0,0,0,0,0,1,0])];
         }
         addChild(this.childObjcet);
      }
      
      protected function setTool(param1:int, param2:String) : void
      {
         var _loc3_:String = GetCropID.idToToolName(param1.toString(),param2);
         this.remove();
         if(_loc3_ == "")
         {
            return;
         }
         var _loc4_:MaterialLib = MaterialLib.getInstance();
         this.childObjcet = _loc4_.getMaterial(_loc3_) as DisplayObject;
         if(this.childObjcet == null)
         {
            return;
         }
         this.childObjcet.x = (this._w - this.childObjcet.width) / 2;
         this.childObjcet.y = (this._h - this.childObjcet.height) / 2;
         if(this._enable)
         {
            this.childObjcet.filters = [];
         }
         else
         {
            this.childObjcet.filters = [new ColorMatrixFilter([0.3086,0.6094,0.082,0,0,0.3086,0.6094,0.082,0,0,0.3086,0.6094,0.082,0,0,0,0,0,1,0])];
         }
         addChild(this.childObjcet);
      }
      
      private function setExp(param1:int) : void
      {
         this.setChildObject("ExpIcon");
      }
      
      private function setWareHouse(param1:int) : void
      {
         var _loc2_:String = GetCropID.idToWareName(param1.toString());
         this.remove();
         if(_loc2_ == "")
         {
            return;
         }
         var _loc3_:MaterialLib = MaterialLib.getInstance();
         this.childObjcet = _loc3_.getMaterial(_loc2_) as DisplayObject;
         if(this.childObjcet == null)
         {
            return;
         }
         this.childObjcet.x = (this._w - this.childObjcet.width) / 2;
         this.childObjcet.y = (this._h - this.childObjcet.height) / 2;
         if(this._enable)
         {
            this.childObjcet.filters = [];
         }
         else
         {
            this.childObjcet.filters = [new ColorMatrixFilter([0.3086,0.6094,0.082,0,0,0.3086,0.6094,0.082,0,0,0.3086,0.6094,0.082,0,0,0,0,0,1,0])];
         }
         addChild(this.childObjcet);
      }
      
      private function setTool2x(param1:int) : void
      {
         var _loc2_:String = "Food" + param1 + "Big";
         this.remove();
         if(_loc2_ == "")
         {
            return;
         }
         var _loc3_:MaterialLib = MaterialLib.getInstance();
         this.childObjcet = _loc3_.getMaterial(_loc2_) as DisplayObject;
         if(this._enable)
         {
            this.childObjcet.filters = [];
         }
         else
         {
            this.childObjcet.filters = [new ColorMatrixFilter([0.3086,0.6094,0.082,0,0,0.3086,0.6094,0.082,0,0,0.3086,0.6094,0.082,0,0,0,0,0,1,0])];
         }
         addChild(this.childObjcet);
      }
      
      private function setCrop2(param1:int) : void
      {
         var _loc2_:String = "Seed" + param1.toString() + "Big";
         this.remove();
         if(_loc2_ == "")
         {
            return;
         }
         var _loc3_:MaterialLib = MaterialLib.getInstance();
         this.childObjcet = _loc3_.getMaterial(_loc2_) as DisplayObject;
         if(!this.childObjcet)
         {
            return;
         }
         this.childObjcet.x = (this._w - this.childObjcet.width) / 2;
         this.childObjcet.y = (this._h - this.childObjcet.height) / 2;
         if(this._enable)
         {
            this.childObjcet.filters = [];
         }
         else
         {
            this.childObjcet.filters = [new ColorMatrixFilter([0.3086,0.6094,0.082,0,0,0.3086,0.6094,0.082,0,0,0.3086,0.6094,0.082,0,0,0,0,0,1,0])];
         }
         addChild(this.childObjcet);
      }
      
      private function setGold(param1:int) : void
      {
         this.setChildObject("GoldBigIcon");
      }
      
      private function setChildObject(param1:String) : void
      {
         this.remove();
         this.childObjcet = MaterialLib.getInstance().getMaterial(param1) as DisplayObject;
         if(this.childObjcet == null)
         {
            return;
         }
         this.childObjcet.x = (this._w - this.childObjcet.width) / 2;
         this.childObjcet.y = (this._h - this.childObjcet.height) / 2;
         if(this._enable)
         {
            this.childObjcet.filters = [];
         }
         else
         {
            this.childObjcet.filters = [new ColorMatrixFilter([0.3086,0.6094,0.082,0,0,0.3086,0.6094,0.082,0,0,0.3086,0.6094,0.082,0,0,0,0,0,1,0])];
         }
         addChild(this.childObjcet);
      }
      
      public function setContent(param1:String, param2:int, param3:Boolean = true) : void
      {
         if(this.currentType == param1 && this.currentId == param2 && param3 == this._enable)
         {
            return;
         }
         this._enable = param3;
         if(param1 == "1")
         {
            this.setCrop(param2);
         }
         else if(param1 == "11")
         {
            this.setCrop2(param2);
         }
         else if(param1 == "4")
         {
            this.setTool(param2,param1);
         }
         else if(param1 != "2")
         {
            if(param1 == "5")
            {
               this.setWareHouse(param2);
            }
            else if(param1 == "6_6")
            {
               this.setGold(param2);
            }
            else if(param1 == "7")
            {
               this.setTool(param2,param1);
            }
            else if(param1 == "7_7")
            {
               this.setExp(param2);
            }
            else if(param1 == "25")
            {
               this.setTool2(param2);
            }
            else if(param1 == "2525")
            {
               this.setTool2x(param2);
            }
            else if(param1 == "5_5")
            {
               this.setTool(param2,"5");
            }
         }
         this.currentType = param1;
         this.currentId = param2;
      }
   }
}

