package mc.view.main.window.diy.Diy
{
   import com.minutes.ui.collections.LipiTile2;
   import common.MaterialLib;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.utils.setTimeout;
   import mc.model.DiyData;
   import mc.view.main.window.diy.DiyItem;
   
   public class CurrentDiy extends Sprite implements IDiy
   {
      
      private var _data:Array;
      
      private var tFormat:TextFormat;
      
      private var tile:LipiTile2;
      
      private var tipTxt:TextField;
      
      private var _diySubscript:MovieClip;
      
      public function CurrentDiy()
      {
         super();
         this.init();
      }
      
      private function addText() : void
      {
         this.tFormat = new TextFormat("Verdana",12,8999699,null,null,null,null,null,"center");
         this.tipTxt = new TextField();
         this.tipTxt.backgroundColor = 15721156;
         this.tipTxt.background = true;
         this.tipTxt.width = 478;
         this.tipTxt.height = 18;
         this.tipTxt.selectable = false;
         addChild(this.tipTxt);
         this.tipTxt.defaultTextFormat = this.tFormat;
         this.tipTxt.htmlText = "当前装饰";
      }
      
      public function setLVDiy(param1:Boolean = false) : void
      {
         if(param1)
         {
            this.addSubscript();
         }
         else if(this._diySubscript)
         {
            removeChild(this._diySubscript);
         }
      }
      
      private function init() : void
      {
         DiyData.getInstance().currentDiy = true;
         this.addDiy();
         this.addText();
      }
      
      private function addSubscript() : void
      {
         this._diySubscript = MaterialLib.getInstance().getMaterial("DiySubscript") as MovieClip;
         this._diySubscript.x = this.tile.leftSpace;
         this._diySubscript.y = this.tile.topSpace + this.tile.y;
         addChild(this._diySubscript);
      }
      
      public function set data(param1:Array) : void
      {
         this.tile.dataList = param1;
         this._data = this.tile.dataList;
         setTimeout(this.tile.resetSize,200);
      }
      
      public function get data() : Array
      {
         return this._data;
      }
      
      private function addDiy() : void
      {
         this.tile = new LipiTile2(DiyItem,1,10,10,140,5);
         this.tile.y = 18;
         this.tile.width = 473;
         this.tile.height = 155;
         this.tile.bgAlpha = 0;
         addChild(this.tile);
      }
   }
}

