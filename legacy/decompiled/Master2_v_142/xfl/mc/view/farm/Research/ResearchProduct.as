package mc.view.farm.Research
{
   import common.CommonData;
   import common.MaterialLib;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import mc.view.farm.GetCropID;
   
   public class ResearchProduct extends MovieClip
   {
      
      private var _num:int;
      
      private var content:MovieClip = new MovieClip();
      
      private var _id:String;
      
      private var endY:int;
      
      public function ResearchProduct(param1:String, param2:int)
      {
         super();
         this._id = param1;
         this._num = param2;
         var _loc3_:String = GetCropID.getSwfUrl() + "farm/aswf/a" + this._id + "_1.swf";
         CommonData.rslManager.requestClass("Animal_" + this._id + "_6",this.getMaterial,_loc3_);
      }
      
      override public function stop() : void
      {
         this.content.stop();
      }
      
      override public function gotoAndPlay(param1:Object, param2:String = null) : void
      {
         this.content.gotoAndPlay(param1);
      }
      
      private function enterframe(param1:Event) : void
      {
         var _loc2_:Sprite = param1.currentTarget as Sprite;
         _loc2_.y += (this.endY - _loc2_.y) / 4;
         if(Math.abs(this.endY - _loc2_.y) <= 2)
         {
            _loc2_.y = this.endY;
            _loc2_.removeEventListener(Event.ENTER_FRAME,this.enterframe);
         }
      }
      
      override public function gotoAndStop(param1:Object, param2:String = null) : void
      {
         this.content.gotoAndStop(param1);
      }
      
      override public function play() : void
      {
         this.content.play();
      }
      
      private function getMaterial() : void
      {
         var _loc1_:Sprite = new Sprite();
         this.addChild(_loc1_);
         _loc1_.y = 40;
         this.content = MaterialLib.getInstance().getMaterial("Animal_" + this._id + "_6") as MovieClip;
         var _loc2_:MovieClip = this.content.getChildAt(4) as MovieClip;
         _loc1_.addChild(_loc2_);
         _loc2_.gotoAndStop(1);
         var _loc3_:TextField = new TextField();
         _loc3_.defaultTextFormat = new TextFormat("Verdana",25,16711680);
         _loc3_.text = "X" + this._num.toString();
         _loc3_.x = 25;
         _loc3_.y = -20;
         _loc1_.addChild(_loc3_);
         this.endY = _loc1_.y - 70;
         _loc1_.addEventListener(Event.ENTER_FRAME,this.enterframe);
      }
   }
}

