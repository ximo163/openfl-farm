package
{
   import adobe.utils.*;
   import flash.accessibility.*;
   import flash.display.*;
   import flash.errors.*;
   import flash.events.*;
   import flash.external.*;
   import flash.filters.*;
   import flash.geom.*;
   import flash.media.*;
   import flash.net.*;
   import flash.printing.*;
   import flash.profiler.*;
   import flash.sampler.*;
   import flash.system.*;
   import flash.text.*;
   import flash.ui.*;
   import flash.utils.*;
   import flash.xml.*;
   
   public dynamic class FarmInfoPlus extends MovieClip
   {
      
      public var growText:TextField;
      
      public var stepText:TextField;
      
      public var bg:MovieClip;
      
      public var healthBar:MovieClip;
      
      public var healthText:TextField;
      
      public var growBar:MovieClip;
      
      public var bg2:MovieClip;
      
      public var seedSprite:Sprite;
      
      public function FarmInfoPlus()
      {
         super();
      }
      
      public function setInfo(param1:Number, param2:String, param3:Number, param4:String, param5:String, param6:Sprite = null) : void
      {
         healthText.visible = true;
         healthBar.visible = true;
         bg.visible = true;
         bg2.visible = true;
         growBar.visible = true;
         growText.visible = true;
         if(seedSprite == null)
         {
            seedSprite = new Sprite();
            addChild(seedSprite);
            stepText.defaultTextFormat = growText.defaultTextFormat = healthText.defaultTextFormat = new TextFormat("Tahoma",12,3355443);
         }
         healthBar.width = param1 * 120;
         growBar.width = param3 * 120;
         healthText.text = param2;
         growText.htmlText = "<font size=\"12\" face=\"Tahoma\">" + param4 + "</font>";
         stepText.text = param5;
         stepText.y = 0;
         setInfoIcon(param6);
      }
      
      public function setStep7(param1:String, param2:Sprite = null) : *
      {
         healthText.visible = false;
         healthBar.visible = false;
         bg.visible = false;
         bg2.visible = false;
         growBar.visible = false;
         growText.visible = false;
         if(seedSprite == null)
         {
            seedSprite = new Sprite();
            addChild(seedSprite);
            stepText.defaultTextFormat = growText.defaultTextFormat = healthText.defaultTextFormat = new TextFormat("Tahoma",12,3355443);
         }
         stepText.text = param1;
         stepText.y = healthText.y + 10;
         setOutputIcon(param2);
      }
      
      public function setOutput(param1:Number, param2:String, param3:String, param4:Sprite = null) : void
      {
         healthText.visible = false;
         healthBar.visible = false;
         bg.visible = false;
         bg2.visible = true;
         growBar.visible = true;
         growText.visible = true;
         if(seedSprite == null)
         {
            seedSprite = new Sprite();
            addChild(seedSprite);
            stepText.defaultTextFormat = growText.defaultTextFormat = healthText.defaultTextFormat = new TextFormat("Tahoma",12,3355443);
         }
         growBar.width = param1 * 120;
         growText.defaultTextFormat = new TextFormat("Tahoma",12,3355443);
         growText.htmlText = "<font size=\"12\" face=\"Tahoma\">" + param2 + "</font>";
         stepText.text = param3;
         stepText.y = healthText.y + 10;
         setOutputIcon(param4);
      }
      
      public function setOutputIcon(param1:*) : *
      {
         if(seedSprite.numChildren > 0)
         {
            seedSprite.removeChildAt(0);
         }
         if(Boolean(param1))
         {
            param1.x = 36 - param1.width;
            param1.y = stepText.y - (param1.height - healthText.height);
            seedSprite.addChild(param1);
         }
      }
      
      public function setInfoIcon(param1:*) : *
      {
         if(seedSprite.numChildren > 0)
         {
            seedSprite.removeChildAt(0);
         }
         if(Boolean(param1))
         {
            param1.x = 36 - param1.width;
            param1.y = stepText.y - (param1.height - stepText.height);
            seedSprite.addChild(param1);
         }
      }
      
      internal function frame1() : *
      {
      }
   }
}

