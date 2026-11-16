package mc.view.farm
{
   import common.MaterialLib;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.filters.ColorMatrixFilter;
   import flash.filters.GlowFilter;
   import mc.control.Command;
   import mc.control.ViewControl;
   import mc.model.FarmData;
   import mc.model.MData;
   import mc.model.MainData;
   import mc.view.farm.land.FarmOperateFloating;
   import mc.view.main.cursor.Cursor;
   import mc.view.main.floating.Float;
   
   public class BBScene extends Sprite
   {
      
      private var farmData:FarmData;
      
      private var mainData:MainData;
      
      private var rollOverFilter:Array;
      
      private var _mx:Number = 0;
      
      private var _my:Number = 0;
      
      private var mouseE:MouseEvent;
      
      public function BBScene()
      {
         super();
         this.farmData = MData.getInstance().farmData;
         this.mainData = MData.getInstance().mainData;
         this.farmData.addEventListener(FarmData.BB_DATA_CHANGE,this.setCount,false,0,true);
         this.farmData.addEventListener(FarmData.FARM_OPERATE,this.farmOperate,false,0,true);
         this.farmData.addEventListener(FarmData.CLEAR_BB,this.clearBBPos);
         ViewControl.getInstance().addEventListener("clearBBError",this.onError);
         ViewControl.getInstance().addEventListener("clearAllBB",this.clear);
         this.creatRollOverFilter();
      }
      
      private function onMouseOut(param1:MouseEvent) : void
      {
         if(Cursor.name == "Cursor_Donate")
         {
            return;
         }
         var _loc2_:MovieClip = param1.currentTarget as MovieClip;
         _loc2_.filters = [];
      }
      
      private function clearbb(param1:MouseEvent) : void
      {
         var _loc2_:MovieClip = null;
         if(Cursor.name == "Cursor_ClearBB")
         {
            _loc2_ = param1.currentTarget as MovieClip;
            _loc2_.mouseEnabled = false;
            Command.getInstance().farmCommand.clearBB(_loc2_.index);
            this.mouseE = param1;
            this._mx = param1.stageX;
            this._my = param1.stageY;
         }
      }
      
      private function clearBBPos(param1:Event) : void
      {
         var _loc3_:MovieClip = null;
         var _loc2_:int = 0;
         while(_loc2_ < this.numChildren)
         {
            _loc3_ = this.getChildAt(_loc2_) as MovieClip;
            if(_loc3_.index == this.farmData.clearBBPos)
            {
               if(FarmData.totalBB)
               {
                  _loc3_.num = 0;
               }
               _loc3_.play();
               _loc3_.filters = this.rollOverFilter;
               _loc3_.removeEventListener(MouseEvent.ROLL_OVER,this.onMouseOver);
               _loc3_.removeEventListener(MouseEvent.ROLL_OUT,this.onMouseOut);
               _loc3_.removeEventListener(MouseEvent.CLICK,this.clearbb);
               return;
            }
            _loc2_++;
         }
      }
      
      private function onError(param1:Event) : void
      {
         var _loc2_:int = 0;
         while(_loc2_ < this.numChildren)
         {
            (this.getChildAt(_loc2_) as MovieClip).mouseEnabled = true;
            _loc2_++;
         }
      }
      
      private function creatRollOverFilter() : void
      {
         var _loc1_:Array = new Array();
         _loc1_ = _loc1_.concat([1.1,0,0,0,0]);
         _loc1_ = _loc1_.concat([0,1.1,0,0,0]);
         _loc1_ = _loc1_.concat([0,0,1.1,0,0]);
         _loc1_ = _loc1_.concat([0,0,0,1,0]);
         this.rollOverFilter = [new GlowFilter(13434624,1,10,10),new ColorMatrixFilter(_loc1_)];
      }
      
      private function clear(param1:Event = null) : void
      {
         var _loc2_:MovieClip = null;
         while(this.numChildren > 0)
         {
            _loc2_ = this.getChildAt(0) as MovieClip;
            _loc2_.removeEventListener(MouseEvent.ROLL_OVER,this.onMouseOver);
            _loc2_.removeEventListener(MouseEvent.ROLL_OUT,this.onMouseOut);
            _loc2_.removeEventListener(MouseEvent.CLICK,this.clearbb);
            removeChild(_loc2_);
         }
      }
      
      private function farmOperate(param1:Event) : void
      {
         var _loc2_:FarmOperateFloating = new FarmOperateFloating();
         _loc2_.text = this.farmData.farmOperate["text"];
         var _loc3_:String = this.farmData.farmOperate["type"];
         if(Boolean(this.mouseE) && _loc3_ == "bb")
         {
            _loc2_.x = this._mx;
            _loc2_.y = this._my;
            Float.open(_loc2_);
            this.mouseE = null;
         }
      }
      
      private function onMouseOver(param1:MouseEvent) : void
      {
         if(Cursor.name == "Cursor_Donate")
         {
            return;
         }
         var _loc2_:MovieClip = param1.currentTarget as MovieClip;
         _loc2_.filters = this.rollOverFilter;
      }
      
      private function setCount(param1:Event) : void
      {
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:MovieClip = null;
         this.clear();
         var _loc2_:Number = Number(this.farmData.bbData["num"]);
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_)
         {
            _loc4_ = 300 + Math.random() * 420;
            _loc5_ = 380 + Math.random() * 200;
            _loc6_ = MaterialLib.getInstance().getMaterial("BB") as MovieClip;
            _loc6_.index = _loc3_;
            _loc6_.x = _loc4_;
            _loc6_.y = _loc5_;
            addChild(_loc6_);
            _loc6_.mouseEnabled = true;
            _loc6_.addEventListener(MouseEvent.CLICK,this.clearbb);
            _loc6_.addEventListener(MouseEvent.ROLL_OVER,this.onMouseOver);
            _loc6_.addEventListener(MouseEvent.ROLL_OUT,this.onMouseOut);
            _loc6_.mouseChildren = false;
            _loc3_++;
         }
      }
   }
}

