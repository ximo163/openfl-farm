package framework.layers
{
   import common.Consts;
   import common.view.floating.FloatControl;
   import common.view.floating.FloatingBase;
   import events.FloatingEvent;
   import flash.display.DisplayObject;
   import framework.base.BaseLayer;
   import interfaces.IMsgCenter;
   
   public class FloatingLayer extends BaseLayer
   {
      
      private var m_ctrl:FloatControl;
      
      public function FloatingLayer(param1:FloatControl)
      {
         if(param1 != null)
         {
            super(param1.getMsgControl());
            mouseEnabled = false;
            mouseChildren = false;
            this.name = Consts.LAYER_FLOATING;
            this.m_ctrl = param1;
            return;
         }
         throw new ArgumentError("Null parameter");
      }
      
      override protected function init() : void
      {
         super.init();
         m_msgCenter.addEventListener(FloatingEvent.FLOATING_OPEN,this.floatingOpen,false,0,true);
         m_msgCenter.addEventListener(FloatingEvent.FLOATING_CLOSE,this.floatingClose,false,0,true);
      }
      
      private function floatingClose(param1:FloatingEvent) : void
      {
         var _loc2_:String = param1.floating;
         if(_loc2_.length == 0)
         {
            return;
         }
         var _loc3_:FloatingBase = this.findFloat(_loc2_,param1.fid);
         if(_loc3_ != null)
         {
            this.removeChild(_loc3_ as DisplayObject);
         }
      }
      
      private function floatingOpen(param1:FloatingEvent) : void
      {
         if(param1.floating == null)
         {
            return;
         }
         var _loc2_:int = param1.fid;
         var _loc3_:FloatingBase = this.findFloat(param1.floating,_loc2_);
         if(_loc3_ != null)
         {
            _loc3_.start(param1.data);
            return;
         }
         if(this.m_ctrl == null || m_msgCenter == null)
         {
            return;
         }
         var _loc4_:Class = this.m_ctrl.getClass(param1.floating);
         if(_loc4_ == null)
         {
            return;
         }
         _loc3_ = new _loc4_(m_msgCenter);
         _loc3_.start(param1.data);
         addChild(_loc3_);
      }
      
      private function findFloat(param1:String, param2:int) : FloatingBase
      {
         if(param1 == "" || param2 < 0)
         {
            return null;
         }
         var _loc3_:FloatingBase = null;
         var _loc4_:int = 0;
         while(_loc4_ < numChildren)
         {
            if(getChildAt(_loc4_) is FloatingBase)
            {
               _loc3_ = getChildAt(_loc4_) as FloatingBase;
               if(_loc3_.floatName == param1)
               {
                  return _loc3_;
               }
            }
            _loc4_++;
         }
         return null;
      }
      
      public function getMsgCenter() : IMsgCenter
      {
         return m_msgCenter;
      }
   }
}

