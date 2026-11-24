package
{
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.text.TextField;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol351")]
   public dynamic class List_Item extends Sprite
   {
      
      public var vip_mc:MovieClip;
      
      public var status_mc:MovieClip;
      
      public var highLight_mc:List_Highlight;
      
      public var name_txt:TextField;
      
      public var level_mc:Level_mc;
      
      public var mc_btn:Mc_btn;
      
      public var level_txt:TextField;
      
      public var head_mc:Head_mc;
      
      public function List_Item()
      {
         super();
      }
   }
}

