package framework.base
{
   import common.misc.Utils;
   import common.view.MaterialProxy;
   import events.ViewEvent;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   
   public class BaseTileItem extends Sprite
   {
      
      public static const CHILD_CLICK:String = "childClick";
      
      public static const CHILD_OUT:String = "childOut";
      
      public static const CHILD_OVER:String = "childOver";
      
      protected var _material:MaterialProxy;
      
      protected var _bg:Sprite;
      
      protected var _item:Object;
      
      protected var _mask:Sprite;
      
      public function BaseTileItem(param1:Boolean = false)
      {
         super();
         buttonMode = true;
         useHandCursor = true;
         mouseChildren = false;
         if(param1 == true)
         {
            this._material = new MaterialProxy(MaterialProxy.BIG);
         }
         else
         {
            this._material = new MaterialProxy();
         }
         this._material.showLoading();
         addChild(this._material);
         this._bg = null;
         this._mask = null;
         this._item = null;
      }
      
      private function onOver(param1:MouseEvent) : void
      {
         var _loc2_:ViewEvent = new ViewEvent(CHILD_OVER,true);
         _loc2_.data = this._item;
         dispatchEvent(_loc2_);
      }
      
      private function onClick(param1:MouseEvent) : void
      {
         var _loc2_:ViewEvent = new ViewEvent(CHILD_CLICK,true);
         _loc2_.data = this._item;
         dispatchEvent(_loc2_);
      }
      
      protected function createBackground(param1:String, param2:int = 0, param3:int = 0) : void
      {
         if(this._bg != null)
         {
            return;
         }
         if(param1 == "")
         {
            return;
         }
         this._bg = Utils.getMaterial(param1) as Sprite;
         if(this._bg != null)
         {
            this._bg.x = 0;
            this._bg.y = 0;
            if(param2 > 0)
            {
               this._bg.width = param2;
            }
            if(param3 > 0)
            {
               this._bg.height = param3;
            }
            addChildAt(this._bg,0);
         }
      }
      
      protected function createMask(param1:String, param2:int = 0, param3:int = 0) : void
      {
         if(this._mask != null)
         {
            return;
         }
         if(param1 == "")
         {
            return;
         }
         this._mask = Utils.getMaterial(param1) as Sprite;
         if(this._mask != null)
         {
            if(param2 > 0)
            {
               this._mask.width = param2;
            }
            if(param3 > 0)
            {
               this._mask.height = param3;
            }
            addChild(this._mask);
         }
         this._material.mask = this._mask;
      }
      
      public function get data() : Object
      {
         return this._item;
      }
      
      public function set data(param1:Object) : void
      {
         if(this._item == param1)
         {
            return;
         }
         this._item = param1;
      }
      
      protected function registerListeners() : void
      {
         addEventListener(MouseEvent.CLICK,this.onClick,false,0,true);
         addEventListener(MouseEvent.ROLL_OVER,this.onOver,false,0,true);
         addEventListener(MouseEvent.ROLL_OUT,this.onOut,false,0,true);
      }
      
      private function onOut(param1:MouseEvent) : void
      {
         var _loc2_:ViewEvent = new ViewEvent(CHILD_OUT,true);
         _loc2_.data = this._item;
         dispatchEvent(_loc2_);
      }
   }
}

