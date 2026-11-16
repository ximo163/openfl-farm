package mc.view.main.window.diy.Diy
{
   import com.minutes.ui.collections.LipiTile2;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.utils.setTimeout;
   import mc.control.Command;
   import mc.model.DiyData;
   import mc.view.ViewEvent;
   import mc.view.main.WindowControl.WControl;
   import mc.view.main.window.diy.DiyItem;
   
   public class MyDiy extends Sprite implements IDiy
   {
      
      private const _height:Number = 175;
      
      private var _data:Array;
      
      private var tFormat:TextFormat;
      
      private var tile:LipiTile2;
      
      private var alertTxt:TextField;
      
      private var tipTxt:TextField;
      
      public function MyDiy()
      {
         super();
         this.init();
      }
      
      private function tileChildClick(param1:ViewEvent) : void
      {
         if(param1.data["status"] != 1)
         {
            Command.getInstance().mainCommand.activeItem(param1.data["itemId"]);
         }
      }
      
      public function setLVDiy(param1:Boolean = false) : void
      {
      }
      
      private function init() : void
      {
         DiyData.getInstance().currentDiy = false;
         this.addDiy();
         this.addText();
      }
      
      public function get data() : Array
      {
         return this._data;
      }
      
      private function openShopWindow(param1:MouseEvent) : void
      {
         WControl.openForName("shop",{"tabSelected":3});
         setTimeout(WControl.closeForName,0,"diy");
      }
      
      private function addDiy() : void
      {
         this.tile = new LipiTile2(DiyItem,2,240,this._height,10,5);
         this.tile.y = 36;
         this.tile.width = 473;
         this.tile.bgAlpha = 0;
         this.tile.addEventListener(ViewEvent.CHILD_CLICK,this.tileChildClick);
         addChild(this.tile);
      }
      
      public function set data(param1:Array) : void
      {
         this.tile.dataList = param1;
         if(this._data != null)
         {
            this._data.splice(0);
         }
         this._data = this.tile.dataList;
         this.tile.height = Math.ceil(this._data.length / 2) * this._height;
         setTimeout(this.tile.resetSize,200);
      }
      
      private function addText() : void
      {
         this.tFormat = new TextFormat("Verdana",12,8999699,null,null,null,null,null,"center");
         this.alertTxt = new TextField();
         this.alertTxt.backgroundColor = 15721156;
         this.alertTxt.background = true;
         this.alertTxt.width = 478;
         this.alertTxt.height = 18;
         this.alertTxt.selectable = false;
         addChild(this.alertTxt);
         this.alertTxt.defaultTextFormat = this.tFormat;
         this.alertTxt.htmlText = "已购买装饰";
         this.tipTxt = new TextField();
         this.tipTxt.backgroundColor = 16777176;
         this.tipTxt.background = true;
         this.tipTxt.width = 478;
         this.tipTxt.height = 18;
         this.tipTxt.y = 18;
         this.tipTxt.selectable = false;
         addChild(this.tipTxt);
         this.tipTxt.defaultTextFormat = this.tFormat;
         this.tipTxt.htmlText = "<font color=\'#895313\'>点击即可立即换上装饰。</font><font color=\'#00ff00\'><a href=\'event:a\'><u><b>商店购买更多</b></u></a></font>";
         this.tipTxt.addEventListener(MouseEvent.CLICK,this.openShopWindow);
      }
   }
}

