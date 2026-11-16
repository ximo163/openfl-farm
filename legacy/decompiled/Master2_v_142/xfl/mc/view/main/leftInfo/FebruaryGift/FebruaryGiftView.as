package mc.view.main.leftInfo.FebruaryGift
{
   import cn.snowkit.containers.Pane;
   import common.CommonData;
   import common.INI;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import mc.view.NewIconTip.NewIconTipController;
   import mc.view.farm.toolBar.ToolBase;
   import mc.view.main.tip.TipControl;
   
   public class FebruaryGiftView extends Sprite
   {
      
      private var _febIcon2:FebruaryGiftIcon2;
      
      private var _febData:FebruaryGiftModel;
      
      private var _febIcon1:FebruaryGiftIcon1;
      
      private var _contain:Pane;
      
      private var _febControl:FebruaryGiftControl;
      
      public function FebruaryGiftView()
      {
         super();
         this._febData = FebruaryGiftModel.gi();
         this._febControl = new FebruaryGiftControl();
      }
      
      private function febIcon() : void
      {
         var _loc1_:Point = null;
         if(this._febIcon1 == null)
         {
            this._febIcon1 = new FebruaryGiftIcon1();
            this._febIcon1.tipText = "买礼包送牧草+道具";
            this._febIcon1.name = "__febicon1__";
            this._febIcon1.y = 6;
            this._febIcon1.addEventListener(MouseEvent.CLICK,this.febClick,false,0,true);
            this._febIcon1.addEventListener(MouseEvent.ROLL_OVER,this.febOver,false,0,true);
            this._febIcon1.addEventListener(MouseEvent.MOUSE_OUT,this.febOut,false,0,true);
            this._contain.appendChild(this._febIcon1);
            _loc1_ = this._febIcon1.localToGlobal(new Point(this._febIcon1.stage.x,this._febIcon1.stage.y));
            _loc1_ = new Point(_loc1_.x - 15,_loc1_.y + 30);
            NewIconTipController.show(_loc1_,"超值回馈");
         }
         if(this._febIcon2 == null)
         {
            this._febIcon2 = new FebruaryGiftIcon2();
            this._febIcon2.tipText = "买礼包送金币+道具";
            this._febIcon2.name = "__febicon2__";
            this._febIcon2.y = 6;
            this._febIcon2.addEventListener(MouseEvent.CLICK,this.febClick,false,0,true);
            this._febIcon2.addEventListener(MouseEvent.ROLL_OVER,this.febOver,false,0,true);
            this._febIcon2.addEventListener(MouseEvent.MOUSE_OUT,this.febOut,false,0,true);
            this._contain.appendChild(this._febIcon2);
            _loc1_ = this._febIcon2.localToGlobal(new Point(this._febIcon2.stage.x,this._febIcon2.stage.y));
            _loc1_ = new Point(_loc1_.x + 20,_loc1_.y + 30);
            NewIconTipController.show(_loc1_,"买一赠五");
         }
      }
      
      private function febClick(param1:MouseEvent) : void
      {
         this._febData.febIconClick(param1.currentTarget.name);
         this._febData.canClickIcon = false;
      }
      
      private function febOut(param1:MouseEvent) : void
      {
         TipControl.hide();
      }
      
      public function init(param1:Pane) : void
      {
         this._contain = param1;
         var _loc2_:String = INI.getInstance().data.february.@start;
         var _loc3_:String = INI.getInstance().data.february.@end;
         var _loc4_:Number = new Date(_loc2_).time;
         var _loc5_:Number = new Date(_loc3_).time;
         var _loc6_:Number = CommonData.serverTime * 1000;
         if(_loc4_ < _loc6_ && _loc6_ < _loc5_)
         {
            this.febIcon();
         }
      }
      
      private function febOver(param1:MouseEvent) : void
      {
         TipControl.show("MouseTip",(param1.currentTarget as ToolBase).tipText);
      }
   }
}

