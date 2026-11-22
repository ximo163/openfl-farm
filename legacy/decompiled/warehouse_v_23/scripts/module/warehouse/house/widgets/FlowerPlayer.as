package module.warehouse.house.widgets
{
   import com.greensock.TweenLite;
   import com.qzone.qui.controls.Button;
   import common.misc.Utils;
   import flash.display.Loader;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.MouseEvent;
   import flash.net.URLRequest;
   import flash.utils.clearTimeout;
   import flash.utils.setTimeout;
   
   public class FlowerPlayer
   {
      
      private static var _root:Sprite;
      
      private static var _closeBtn:Button;
      
      private static var _border:Sprite;
      
      private static var _timer:int;
      
      private static var _swfContainer:Sprite;
      
      public function FlowerPlayer()
      {
         super();
      }
      
      private static function drawBorder() : void
      {
         if(_root == null)
         {
            return;
         }
         _border = new Sprite();
         _border.graphics.clear();
         _border.graphics.lineStyle(0,0,0);
         _border.graphics.beginFill(0,0.6);
         _border.graphics.drawRect(0,0,_root.stage.stageWidth,_root.stage.stageHeight);
         _border.graphics.endFill();
         _root.addChild(_border);
      }
      
      public static function play(param1:Sprite, param2:String, param3:int) : void
      {
         var ld:Loader;
         var swfUrl:String;
         var root:Sprite = param1;
         var flowerPath:String = param2;
         var fId:int = param3;
         _root = root;
         drawBorder();
         swfUrl = flowerPath + "/" + fId + ".swf";
         swfUrl = Utils.addPrefix(swfUrl);
         _timer = -1;
         ld = new Loader();
         ld.contentLoaderInfo.addEventListener(Event.COMPLETE,function():void
         {
            var _loc2_:Loader = null;
            _loc2_ = arguments[0].target.loader;
            _loc2_.contentLoaderInfo.removeEventListener(Event.COMPLETE,arguments.callee);
            _loc2_.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR,arguments.callee);
            _closeBtn = new Button();
            _closeBtn.defaultSkin = Utils.getClass("ButtonBlue");
            _closeBtn.width = 60;
            _closeBtn.height = 28;
            _closeBtn.text = "关闭";
            _closeBtn.mouseEnabled = true;
            _closeBtn.addEventListener(MouseEvent.CLICK,close);
            _border.addChild(_closeBtn);
            _closeBtn.x = (_border.width - _closeBtn.width) / 2;
            _closeBtn.y = _border.height - 70;
            _loc2_.x = (_border.width - _loc2_.width) / 2;
            _loc2_.y = (_border.height - _loc2_.height) / 2;
            _timer = setTimeout(close,2000);
         });
         ld.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,function():void
         {
            arguments[0].target.removeEventListener(Event.COMPLETE,arguments.callee);
            arguments[0].target.removeEventListener(IOErrorEvent.IO_ERROR,arguments.callee);
            close();
         });
         ld.load(new URLRequest(swfUrl));
         _border.addChild(ld);
      }
      
      private static function close(param1:* = null) : void
      {
         var e:* = param1;
         if(_border != null)
         {
            if(_timer != -1)
            {
               clearTimeout(_timer);
            }
            TweenLite.to(_border,0.3,{
               "alpha":0,
               "onComplete":function():void
               {
                  if(_border.parent != null)
                  {
                     _border.parent.removeChild(_border);
                  }
                  _border = null;
               }
            });
         }
      }
   }
}

