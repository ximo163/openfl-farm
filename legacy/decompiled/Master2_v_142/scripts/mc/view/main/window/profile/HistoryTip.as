package mc.view.main.window.profile
{
   import common.MaterialLib;
   import flash.display.Sprite;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import mc.view.main.tip.Tip;
   
   public class HistoryTip extends Tip
   {
      
      private var tipBg:Sprite;
      
      private var text1:TextField;
      
      private var text2:TextField;
      
      private var cName:TextField;
      
      private var label1:TextField = new TextField();
      
      private var label2:TextField = new TextField();
      
      public function HistoryTip()
      {
         super();
         this.tipBg = MaterialLib.getInstance().getMaterial("TipBg") as Sprite;
         this.tipBg.width = 140;
         this.tipBg.height = 70;
         this.tipBg.x = -20;
         this.tipBg.y = 15;
         addChild(this.tipBg);
         this.cName = new TextField();
         this.cName.x = -5;
         this.cName.y = 20;
         this.cName.width = 120;
         this.cName.height = 22;
         this.cName.defaultTextFormat = new TextFormat("Verdana",14,3355443,true);
         this.cName.text = "";
         addChild(this.cName);
         this.label1.autoSize = TextFieldAutoSize.LEFT;
         this.label1.x = -10;
         this.label1.y = 45;
         this.label1.height = 22;
         this.label1.defaultTextFormat = new TextFormat("Verdana",12,3355443);
         this.label1.text = "饲养收获:";
         addChild(this.label1);
         this.label2.autoSize = TextFieldAutoSize.LEFT;
         this.label2.x = -10;
         this.label2.y = 60;
         this.label2.width = 90;
         this.label2.height = 22;
         this.label2.defaultTextFormat = new TextFormat("Verdana",12,3355443);
         this.label2.text = "其他收获:";
         addChild(this.label2);
         this.text1 = new TextField();
         this.text1.x = this.label1.x + this.label1.width + 3;
         this.text1.y = 45;
         this.text1.width = 90;
         this.text1.height = 22;
         this.text1.defaultTextFormat = new TextFormat("Verdana",12,3355443);
         this.text1.text = "111";
         addChild(this.text1);
         this.text2 = new TextField();
         this.text2.x = this.label2.x + this.label2.width + 3;
         this.text2.y = 60;
         this.text2.width = 90;
         this.text2.height = 22;
         this.text2.defaultTextFormat = new TextFormat("Verdana",12,3355443);
         this.text2.text = "111";
         addChild(this.text2);
      }
      
      override public function set data(param1:Object) : void
      {
         if(param1 == null)
         {
            param1 = "";
         }
         this.cName.text = param1["cName"];
         this.text1.text = param1["harvest"];
         this.text2.text = param1["scrounge"];
         if(param1["cId"] == 1506)
         {
            this.label1.text = "便便数量:";
            this.label2.text = "";
            this.text2.text = "";
         }
         else
         {
            this.label1.text = "饲养收获:";
            this.label2.text = "其他收获:";
         }
      }
      
      override public function set mX(param1:Number) : void
      {
         super.mX = param1;
         x = param1 - 5;
      }
      
      override public function set mY(param1:Number) : void
      {
         super.mY = param1;
         y = param1 + 15;
      }
   }
}

