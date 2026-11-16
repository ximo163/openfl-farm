package mc.view.farm.packBar
{
   import com.qzone.qui.controls.listClasses.ListItemRenderer;
   import common.MaterialLib;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.MouseEvent;
   import flash.filters.ColorMatrixFilter;
   import flash.filters.GlowFilter;
   import flash.net.URLRequest;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import flash.text.TextFormatAlign;
   import mc.model.MainData;
   import mc.view.ViewEvent;
   import mc.view.common.MaterialLoaderProxy;
   import mc.view.common.MaterialProxy;
   import mc.view.common.WildMaterialLoaderProxy;
   import mc.view.farm.GetCropID;
   
   public class PackItem extends ListItemRenderer
   {
      
      private var house:MovieClip;
      
      private var lib:MaterialLib = MaterialLib.getInstance();
      
      private var amountText:TextField;
      
      private var childObjcet:MaterialLoaderProxy;
      
      private var wp:WildMaterialLoaderProxy;
      
      private var childObjcet2:MaterialProxy;
      
      public function PackItem(param1:int)
      {
         super(param1);
         buttonMode = true;
         useHandCursor = true;
         mouseChildren = false;
         addEventListener(MouseEvent.CLICK,this.childClick);
         addEventListener(MouseEvent.ROLL_OVER,this.childOver);
         addEventListener(MouseEvent.ROLL_OUT,this.childOut);
         this.childObjcet = new MaterialLoaderProxy();
         this.childObjcet2 = new MaterialProxy();
         this.wp = new WildMaterialLoaderProxy();
      }
      
      private function childOut(param1:MouseEvent) : void
      {
         var _loc2_:ViewEvent = new ViewEvent(ViewEvent.CHILD_OUT,true);
         _loc2_.data = _data;
         dispatchEvent(_loc2_);
      }
      
      override public function get data() : Object
      {
         return _data;
      }
      
      private function childClick(param1:MouseEvent) : void
      {
         var _loc2_:ViewEvent = new ViewEvent(ViewEvent.CHILD_CLICK,true);
         _loc2_.data = _data;
         dispatchEvent(_loc2_);
      }
      
      private function onMaterialLoadOk(param1:Event) : void
      {
         if(String(_data["type"]) == "9")
         {
            this.mouseChildren = true;
            this.mouseEnabled = true;
            if(GetCropID.getHouse(_data["tId"]) == "窝")
            {
               this.house = MaterialLib.getInstance().getMaterial("HouseIcon1") as MovieClip;
            }
            else
            {
               this.house = MaterialLib.getInstance().getMaterial("HouseIcon2") as MovieClip;
            }
            addChild(this.house);
            this.house.x = 1;
            this.house.y = 46;
         }
      }
      
      override protected function init() : void
      {
         this.removeEvent();
      }
      
      override public function set data(param1:Object) : void
      {
         var type:int;
         var id:int;
         var _mc:MovieClip = null;
         var cardMc:MovieClip = null;
         var loader:Loader = null;
         var value:Object = param1;
         _data = value;
         type = 0;
         id = 0;
         if(value.hasOwnProperty("type"))
         {
            type = int(value["type"]);
         }
         if(value.hasOwnProperty("cId"))
         {
            id = int(value["cId"]);
         }
         else if(value.hasOwnProperty("tId"))
         {
            id = int(value["tId"]);
         }
         if(Boolean(this.house) && contains(this.house))
         {
            removeChild(this.house);
         }
         if(value.hasOwnProperty("lock"))
         {
            removeEventListener(MouseEvent.CLICK,this.childClick);
            this.filters = MainData.lockFilter;
         }
         else
         {
            this.filters = null;
            addEventListener(MouseEvent.CLICK,this.childClick);
         }
         if(String(type) == "9")
         {
            this.childObjcet.addEventListener(Event.COMPLETE,this.onMaterialLoadOk);
            this.childObjcet.addEventListener("animal_error",this.onMaterialLoadError);
            this.childObjcet.setContent(String(type),id);
            addChild(this.childObjcet);
         }
         else if(String(type) == "12")
         {
            _mc = MaterialLib.getInstance().getMaterial("Tool_12_" + id) as MovieClip;
            addChild(_mc);
         }
         else if(String(type) == "2" || String(type) == "7" && id == 34)
         {
            cardMc = MaterialLib.getInstance().getMaterial("Tool_2_" + id) as MovieClip;
            addChild(cardMc);
            cardMc.filters = [new ColorMatrixFilter([0.3,0.6,0.082,0,0,0.3,0.6,0.082,0,0,0.3,0.6,0.082,0,0,0,0,0,1,0])];
         }
         else if(value.typeP == 1)
         {
            loader = new Loader();
            loader.load(new URLRequest(GetCropID.getSwfUrl() + "farm/tools/prop_" + value["cId"] + ".jpg"));
            addChild(loader);
         }
         else
         {
            this.childObjcet2.addEventListener(IOErrorEvent.IO_ERROR,function():void
            {
               this.mouseEnabled = false;
               this.mouseChildren = true;
            });
            this.childObjcet2.setContent(String(type),id);
            addChild(this.childObjcet2);
         }
         if(String(type) == "10" && value["appid"] == "353")
         {
            this.wp.setContent("weapon",value["tId"],{"type":"Small"});
            this.wp.hideBg();
            addChild(this.wp);
            this.filters = MainData.lockFilter;
         }
         if(value.hasOwnProperty("amount"))
         {
            this.setAmount(value["amount"]);
         }
      }
      
      public function setAmount(param1:int) : void
      {
         if(this.amountText == null)
         {
            this.amountText = new TextField();
            this.amountText.defaultTextFormat = new TextFormat("embedFontA",12,8999699,null,null,null,null,null,TextFormatAlign.RIGHT);
            this.amountText.embedFonts = true;
            this.amountText.width = 30;
            this.amountText.height = 16;
            this.amountText.autoSize = TextFieldAutoSize.LEFT;
            this.amountText.text = param1.toString();
            this.amountText.selectable = false;
            this.amountText.mouseEnabled = false;
         }
         this.amountText.text = param1.toString();
         this.amountText.x = 61 - this.amountText.textWidth - 5;
         this.amountText.y = 61 - this.amountText.height;
         addChild(this.amountText);
         this.amountText.filters = [new GlowFilter(16777215,1,2,2,10,2)];
      }
      
      private function onMaterialLoadError(param1:Event) : void
      {
         this.mouseChildren = false;
         this.mouseEnabled = false;
      }
      
      private function childOver(param1:MouseEvent) : void
      {
         var _loc2_:ViewEvent = new ViewEvent(ViewEvent.CHILD_OVER,true);
         _loc2_.data = _data;
         dispatchEvent(_loc2_);
      }
   }
}

