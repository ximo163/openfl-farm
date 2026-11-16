package mc.view.main.tip
{
   import common.MaterialLib;
   import flash.display.Sprite;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   
   public class MouseTip extends Tip
   {
      
      private var tipBg:Sprite;
      
      private var tipText:TextField;
      
      public function MouseTip()
      {
         super();
         this.tipBg = MaterialLib.getInstance().getMaterial("TipBg") as Sprite;
         addChild(this.tipBg);
         this.tipText = new TextField();
         this.tipText.selectable = false;
         this.tipText.x = 5;
         this.tipText.y = 5;
         this.tipText.autoSize = TextFieldAutoSize.LEFT;
         this.tipText.defaultTextFormat = new TextFormat("Verdana",12,3355443);
         addChild(this.tipText);
      }
      
      override public function set data(param1:Object) : void
      {
         if(param1 == null)
         {
            param1 = "";
         }
         this.tipText.htmlText = param1.toString();
         this.tipBg.width = this.tipText.width + 10;
         this.tipBg.height = this.tipText.height + 10;
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

