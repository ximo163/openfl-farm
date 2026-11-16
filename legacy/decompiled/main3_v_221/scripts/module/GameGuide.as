package module
{
   import common.misc.Utils;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.filters.GlowFilter;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import flash.utils.clearTimeout;
   import flash.utils.setTimeout;
   
   public class GameGuide
   {
      
      private static var _instance:GameGuide;
      
      public static var toggle_water:Boolean = false;
      
      public static const WATER_SHOP_ICON:int = 0;
      
      public static const WATER_FISH_TAB:int = 1;
      
      public static const WATER_FISH_ITEM:int = 2;
      
      public static const WATER_UNLOCK_FISH:int = 3;
      
      public static const WATER_FISH_ITEM_AGAIN:int = 4;
      
      public static const WATER_BUY_FISH:int = 5;
      
      public static const WATER_BAG_ICON_FISH:int = 6;
      
      public static const WATER_BAG_FISH_ITEM:int = 7;
      
      public static const WATER_POOL_CENTER:int = 8;
      
      private static const OFFSET_BIG_MODE:int = 60;
      
      private static const OFFSET_SMALL_MODE:int = -50;
      
      private static const fishGuideStep:Array = [{
         "id":0,
         "x":710,
         "y":55,
         "dir":0
      },{
         "id":1,
         "x":235,
         "y":120,
         "dir":1
      },{
         "id":2,
         "x":183,
         "y":220,
         "dir":3
      },{
         "id":3,
         "x":515,
         "y":362,
         "dir":1
      },{
         "id":4,
         "x":183,
         "y":220,
         "dir":3
      },{
         "id":5,
         "x":365,
         "y":458,
         "dir":0
      },{
         "id":6,
         "x":322,
         "y":510,
         "dir":1
      },{
         "id":7,
         "x":215,
         "y":436,
         "dir":3
      },{
         "id":8,
         "x":-1,
         "y":-1,
         "dir":1
      }];
      
      private var _stop:Boolean;
      
      private var _container:DisplayObjectContainer;
      
      private var _tip:TextField;
      
      private var _timeout:uint;
      
      private var _arrow:MovieClip;
      
      private var _step:int;
      
      private var _normalView:Boolean;
      
      private var _bigMode:Boolean;
      
      public function GameGuide()
      {
         super();
         this._arrow = Utils.getMaterial("Arrow") as MovieClip;
         this._container = null;
         this._step = -1;
         this._bigMode = false;
         this._timeout = 0;
         this._stop = false;
         this._tip = null;
      }
      
      public static function instance() : GameGuide
      {
         if(_instance != null)
         {
            return _instance;
         }
         _instance = new GameGuide();
         return _instance;
      }
      
      public function autoHide(param1:int) : void
      {
         var sec:int = param1;
         if(sec <= 0)
         {
            this.hide();
            return;
         }
         this.resetTimeout();
         this._timeout = setTimeout(function():void
         {
            hide();
            _stop = true;
         },sec * 1000);
      }
      
      public function get currentStep() : int
      {
         return this._step;
      }
      
      public function hide() : void
      {
         if(this._container != null)
         {
            if(this._arrow != null && this._container.contains(this._arrow) == true)
            {
               this._container.removeChild(this._arrow);
            }
            if(this._tip != null && this._container.contains(this._tip) == true)
            {
               this._container.removeChild(this._tip);
            }
         }
      }
      
      public function showStep(param1:int, param2:int = 0, param3:int = 0, param4:String = "") : void
      {
         var _loc5_:int = 0;
         if(toggle_water == false || this._stop == true)
         {
            return;
         }
         if(this._arrow == null)
         {
            return;
         }
         if(param1 <= this._step)
         {
            return;
         }
         this._step = param1;
         if(this._step >= fishGuideStep.length)
         {
            return;
         }
         if(this._container != null)
         {
            this._arrow.x = fishGuideStep[this._step]["x"];
            this._arrow.y = fishGuideStep[this._step]["y"];
            this._container.addChild(this._arrow);
            if(this._bigMode == true)
            {
               this._arrow.x += OFFSET_BIG_MODE;
               if(param1 == WATER_SHOP_ICON)
               {
                  this._arrow.x += 68;
               }
            }
            else if(this._normalView == true)
            {
               this._arrow.x += OFFSET_SMALL_MODE;
               if(param1 == WATER_SHOP_ICON)
               {
                  this._arrow.x += -50;
               }
            }
            if(fishGuideStep[this._step]["x"] == -1 && fishGuideStep[this._step]["y"] == -1)
            {
               this._arrow.x = param2;
               this._arrow.y = param3;
            }
            _loc5_ = int(fishGuideStep[this._step]["dir"]);
            if(_loc5_ == 0)
            {
               this._arrow.scaleX = 1;
               this._arrow.scaleY = 1;
               this._arrow.rotation = 0;
            }
            else if(_loc5_ == 1)
            {
               this._arrow.scaleX = 1;
               this._arrow.scaleY = -1;
               this._arrow.rotation = 0;
            }
            else if(_loc5_ == 2)
            {
               this._arrow.scaleX = 1;
               this._arrow.scaleY = 1;
               this._arrow.rotation = -90;
            }
            else if(_loc5_ == 3)
            {
               this._arrow.scaleX = 1;
               this._arrow.scaleY = 1;
               this._arrow.rotation = 90;
            }
            if(param4 != null && param4 != "")
            {
               if(this._tip == null)
               {
                  this._tip = new TextField();
                  this._tip.defaultTextFormat = new TextFormat("SimSun",14,16750848,true,false,false,null,null,"left",0,0,0,0);
                  this._tip.selectable = false;
                  this._tip.autoSize = TextFieldAutoSize.RIGHT;
                  this._tip.filters = [new GlowFilter(10053171,1,3,3,5,1)];
               }
               if(param1 == WATER_FISH_ITEM)
               {
                  this._tip.text = param4;
                  this._tip.x = this._arrow.x - this._tip.width - 10;
                  this._tip.y = this._arrow.y - this._tip.height - 20;
                  this._container.addChild(this._tip);
               }
            }
            else if(this._tip != null && this._tip.parent != null)
            {
               this._tip.parent.removeChild(this._tip);
            }
            this.resetTimeout();
            return;
         }
         throw new Error("Container property must be set first!");
      }
      
      private function resetTimeout() : void
      {
         if(this._timeout >= 0)
         {
            clearTimeout(this._timeout);
            this._timeout = 0;
         }
      }
      
      public function set container(param1:DisplayObjectContainer) : void
      {
         this._container = param1;
         if(this._container != null && this._container.stage != null)
         {
            this._bigMode = this._container.stage.stageWidth > 820;
            this._normalView = this._container.stage.stageWidth < 720;
         }
      }
   }
}

