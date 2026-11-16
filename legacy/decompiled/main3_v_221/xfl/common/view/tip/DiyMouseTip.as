package common.view.tip
{
   import com.qzone.utils.StringUtil;
   import common.Consts;
   import common.misc.Utils;
   import flash.display.Sprite;
   import flash.text.TextField;
   import flash.text.TextFormat;
   
   public class DiyMouseTip extends Tip
   {
      
      private var m_tipText2:TextField;
      
      private var m_tipBg:Sprite;
      
      private var m_tipText:TextField;
      
      public function DiyMouseTip()
      {
         super();
         super._tipName = Consts.TIP_NAME_DIY_MOUSE;
         this.m_tipBg = Utils.getMaterial("TipBg") as Sprite;
         addChild(this.m_tipBg);
         this.m_tipText = new TextField();
         this.m_tipText.x = 15;
         this.m_tipText.y = 5;
         this.m_tipText.defaultTextFormat = new TextFormat("Verdana",12,0);
         addChild(this.m_tipText);
         this.m_tipText2 = new TextField();
         this.m_tipText2.x = 5;
         this.m_tipText2.y = 25;
         this.m_tipText2.width = 140;
         this.m_tipText2.defaultTextFormat = new TextFormat("Verdana",12,0);
         addChild(this.m_tipText2);
      }
      
      override public function set mX(param1:Number) : void
      {
         super.mX = param1;
         x = param1 - 5;
      }
      
      override public function set data(param1:Object) : void
      {
         this.m_tipText.text = param1["itemName"];
         if(param1["validTime"] == 0)
         {
            this.m_tipText2.text = "到期时间：无限期";
         }
         else
         {
            this.m_tipText2.text = "到期时间：" + StringUtil.dateFormat(param1["validTime"]) + "11";
         }
         if(this.m_tipText.width > this.m_tipText2.width)
         {
            this.m_tipBg.width = this.m_tipText.width + 20;
         }
         else
         {
            this.m_tipBg.width = this.m_tipText2.width + 20;
         }
         this.m_tipBg.height = 50;
         super.data = param1;
      }
      
      override public function set mY(param1:Number) : void
      {
         super.mY = param1;
         y = param1 + 20;
      }
   }
}

