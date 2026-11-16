package common.view.tip
{
   import common.Consts;
   import common.misc.Utils;
   import flash.display.Sprite;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   
   public class MouseTip extends Tip
   {
      
      protected var _tipBg:Sprite;
      
      protected var _tipText:TextField;
      
      public function MouseTip()
      {
         super();
         super._tipName = Consts.TIP_NAME_MOUSE;
         this._tipBg = Utils.getMaterial("TipBg") as Sprite;
         addChild(this._tipBg);
         this._tipText = new TextField();
         this._tipText.selectable = false;
         this._tipText.x = 5;
         this._tipText.y = 5;
         this._tipText.autoSize = TextFieldAutoSize.LEFT;
         this._tipText.defaultTextFormat = new TextFormat("Verdana",12,3355443);
         addChild(this._tipText);
      }
      
      override public function set data(param1:Object) : void
      {
         if(param1 == null)
         {
            param1 = "";
         }
         this._tipText.text = param1.toString();
         this._tipBg.width = this._tipText.width + 10;
         this._tipBg.height = this._tipText.height + 10;
         super.data = param1;
      }
      
      override public function set mX(param1:Number) : void
      {
         super.mX = param1;
         if(stage != null)
         {
            if(param1 - 5 <= 0)
            {
               param1 = 0;
            }
            else if(param1 - 5 + width > stage.stageWidth)
            {
               param1 = stage.stageWidth - width;
            }
            else
            {
               param1 -= 5;
            }
         }
         else
         {
            param1 -= 5;
         }
         x = param1;
      }
      
      override public function set mY(param1:Number) : void
      {
         super.mY = param1;
         if(stage != null)
         {
            if(param1 + height + 30 > stage.stageHeight)
            {
               param1 = param1 - height - 8;
            }
            else
            {
               param1 += 20;
            }
         }
         else
         {
            param1 += 20;
         }
         y = param1;
      }
   }
}

