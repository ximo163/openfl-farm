package common.view.window
{
   import com.qzone.utils.AlignUtil;
   import flash.display.DisplayObjectContainer;
   import flash.text.TextField;
   import interfaces.IMsgCenter;
   
   public class ContentWindow extends AddButtonWindow
   {
      
      private var _customContent:DisplayObjectContainer;
      
      private var _spaceHeight:int;
      
      public function ContentWindow(param1:IMsgCenter, param2:String, param3:DisplayObjectContainer, param4:int = 0, param5:Boolean = false)
      {
         super(param1);
         windowName = param2;
         autoLayout = false;
         this._customContent = param3;
         this.name = param3.name;
         if(param5)
         {
            windowName = param3.name;
         }
         this._spaceHeight = param4;
      }
      
      public function get disableAnimation() : Boolean
      {
         return true;
      }
      
      override protected function addedToLayer() : void
      {
         if(this._customContent != null)
         {
            this._customContent.scaleX = 1;
            this._customContent.scaleY = 1;
            this._customContent.y = super.panelTitle.height - this._spaceHeight;
            addChild(this._customContent);
         }
      }
      
      override protected function setSize() : void
      {
         super.setSize();
         if(panelTitle != null)
         {
            panelTitle.x = AlignUtil.middle(width,panelTitle.width);
         }
      }
      
      override protected function setData() : void
      {
         var _loc1_:Object = super.data;
         if(_loc1_ == null)
         {
            return;
         }
         if(_loc1_["width"] != undefined)
         {
            this.width = _loc1_["width"] as int;
         }
         if(_loc1_["height"] != undefined)
         {
            this.height = _loc1_["height"] as int;
         }
         if(_loc1_["title"] != undefined)
         {
            this.title = _loc1_["title"] as String;
         }
         if(_loc1_["yellowTip"] != undefined && _loc1_["yellowTip"] is TextField)
         {
            TextField(_loc1_["yellowTip"]).width = this.width - 4;
            TextField(_loc1_["yellowTip"]).x = 1;
         }
      }
   }
}

