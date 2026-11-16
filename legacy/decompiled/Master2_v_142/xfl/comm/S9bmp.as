package comm
{
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.Sprite;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   
   public class S9bmp extends Sprite
   {
      
      private var bg:*;
      
      private var bm1:Bitmap;
      
      private var bm2:Bitmap;
      
      private var bm3:Bitmap;
      
      private var bm4:Bitmap;
      
      private var bm6:Bitmap;
      
      private var bm8:Bitmap;
      
      private var bm5:Bitmap;
      
      private var bm7:Bitmap;
      
      private var bm9:Bitmap;
      
      private var _x1:Number;
      
      private var _x2:Number;
      
      private var bmpClass:*;
      
      private var _y1:Number;
      
      private var _y2:Number;
      
      public function S9bmp(param1:Class, param2:Rectangle)
      {
         super();
         if(!param2)
         {
            addChild(new param1());
            return;
         }
         this.bmpClass = param1;
         var _loc3_:Number = param2.x;
         var _loc4_:Number = param2.width;
         var _loc5_:Number = param2.y;
         var _loc6_:Number = param2.height;
         this._x1 = _loc3_;
         this._x2 = _loc4_;
         this._y1 = _loc5_;
         this._y2 = _loc6_;
         this.bg = new this.bmpClass();
         var _loc7_:BitmapData = new BitmapData(this.bg.width,this.bg.height,true,0);
         _loc7_.draw(this.bg,null,null,null,null,true);
         var _loc8_:BitmapData = new BitmapData(_loc3_,_loc5_);
         _loc8_.copyPixels(_loc7_,new Rectangle(0,0,_loc3_,_loc5_),new Point(0,0));
         var _loc9_:BitmapData = new BitmapData(_loc4_,_loc5_);
         _loc9_.copyPixels(_loc7_,new Rectangle(_loc3_,0,_loc4_,_loc5_),new Point(0,0));
         var _loc10_:BitmapData = new BitmapData(this.bg.width - _loc3_ - _loc4_,_loc5_);
         _loc10_.copyPixels(_loc7_,new Rectangle(_loc3_ + _loc4_,0,this.bg.width - _loc3_ - _loc4_,_loc5_),new Point(0,0));
         var _loc11_:BitmapData = new BitmapData(_loc3_,_loc6_);
         _loc11_.copyPixels(_loc7_,new Rectangle(0,_loc5_,_loc3_,_loc6_),new Point(0,0));
         var _loc12_:BitmapData = new BitmapData(_loc4_,_loc6_);
         _loc12_.copyPixels(_loc7_,new Rectangle(_loc3_,_loc5_,_loc4_,_loc6_),new Point(0,0));
         var _loc13_:BitmapData = new BitmapData(this.bg.width - _loc3_ - _loc4_,_loc6_);
         _loc13_.copyPixels(_loc7_,new Rectangle(_loc3_ + _loc4_,_loc5_,this.bg.width - _loc3_ - _loc4_,_loc6_),new Point(0,0));
         var _loc14_:BitmapData = new BitmapData(_loc3_,this.bg.height - _loc5_ - _loc6_);
         _loc14_.copyPixels(_loc7_,new Rectangle(0,_loc5_ + _loc6_,_loc3_,this.bg.height - _loc5_ - _loc6_),new Point(0,0));
         var _loc15_:BitmapData = new BitmapData(_loc4_,this.bg.height - _loc5_ - _loc6_);
         _loc15_.copyPixels(_loc7_,new Rectangle(_loc3_,_loc5_ + _loc6_,_loc4_,this.bg.height - _loc5_ - _loc6_),new Point(0,0));
         var _loc16_:BitmapData = new BitmapData(this.bg.width - _loc3_ - _loc4_,this.bg.height - _loc5_ - _loc6_);
         _loc16_.copyPixels(_loc7_,new Rectangle(_loc3_ + _loc4_,_loc5_ + _loc6_,this.bg.width - _loc3_ - _loc4_,this.bg.height - _loc5_ - _loc6_),new Point(0,0));
         this.bm1 = new Bitmap(_loc8_);
         this.bm2 = new Bitmap(_loc9_);
         this.bm3 = new Bitmap(_loc10_);
         this.bm4 = new Bitmap(_loc11_);
         this.bm5 = new Bitmap(_loc12_);
         this.bm6 = new Bitmap(_loc13_);
         this.bm7 = new Bitmap(_loc14_);
         this.bm8 = new Bitmap(_loc15_);
         this.bm9 = new Bitmap(_loc16_);
         addChild(this.bm1);
         addChild(this.bm2);
         this.bm2.x = _loc3_;
         this.bm2.y = 0;
         addChild(this.bm3);
         this.bm3.x = _loc3_ + _loc4_;
         this.bm3.y = 0;
         addChild(this.bm4);
         this.bm4.x = 0;
         this.bm4.y = _loc5_;
         addChild(this.bm5);
         this.bm5.x = _loc3_;
         this.bm5.y = _loc5_;
         addChild(this.bm6);
         this.bm6.x = _loc3_ + _loc4_;
         this.bm6.y = _loc5_;
         addChild(this.bm7);
         this.bm7.x = 0;
         this.bm7.y = _loc5_ + _loc6_;
         addChild(this.bm8);
         this.bm8.x = _loc3_;
         this.bm8.y = _loc5_ + _loc6_;
         addChild(this.bm9);
         this.bm9.x = _loc3_ + _loc4_;
         this.bm9.y = _loc5_ + _loc6_;
      }
      
      override public function set width(param1:Number) : void
      {
         this.bm2.width = param1 - this._x1 - (this.bg.width - this._x1 - this._x2);
         this.bm5.width = param1 - this._x1 - (this.bg.width - this._x1 - this._x2);
         this.bm8.width = param1 - this._x1 - (this.bg.width - this._x1 - this._x2);
         this.bm3.x = this._x1 + this.bm2.width;
         this.bm6.x = this._x1 + this.bm2.width;
         this.bm9.x = this._x1 + this.bm2.width;
      }
      
      override public function set height(param1:Number) : void
      {
         this.bm4.height = param1 - this._y1 - (this.bg.height - this._y1 - this._y2);
         this.bm5.height = param1 - this._y1 - (this.bg.height - this._y1 - this._y2);
         this.bm6.height = param1 - this._y1 - (this.bg.height - this._y1 - this._y2);
         this.bm7.y = this._y1 + this.bm4.height;
         this.bm8.y = this._y1 + this.bm4.height;
         this.bm9.y = this._y1 + this.bm4.height;
      }
   }
}

