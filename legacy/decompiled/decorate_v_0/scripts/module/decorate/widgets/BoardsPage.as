package module.decorate.widgets
{
   import com.qzone.qui.controls.Label;
   import com.qzone.qui.controls.scrollClasses.ScrollPolicy;
   import common.view.window.WindowLabelMaker;
   import flash.display.DisplayObjectContainer;
   import framework.base.BasePage;
   import module.uitools.widgets.profile.PropertyText;
   
   public class BoardsPage extends BasePage
   {
      
      private var _sumPrice:PropertyText;
      
      public function BoardsPage(param1:DisplayObjectContainer, param2:int, param3:int)
      {
         super(param1,param2,param3);
         var _loc4_:Label = new Label();
         _loc4_.text = "特别说明：点击“已装饰”标签的告示牌即可隐藏告示牌。";
         _loc4_.x = 2;
         _loc4_.width = param2 - 5;
         WindowLabelMaker.addTarget(_loc4_);
         addChild(_loc4_);
      }
      
      override protected function onCreateTile() : void
      {
         if(_tile != null)
         {
            _tile.tileWidth = 100;
            _tile.tileHeight = 100;
            _tile.paddingH = 8;
            _tile.itemRenderer = BoardRenderItem;
            _tile.x = 25;
            _tile.y = 21;
            _tile.width = _preferedWidth - 30;
            _tile.height = _preferedHeight - 85;
            _tile.defaultSkin = null;
            _tile.horizontalScrollPolicy = ScrollPolicy.OFF;
         }
      }
      
      public function changeBoard(param1:int, param2:int) : void
      {
         var _loc4_:* = undefined;
         if(_tile == null)
         {
            return;
         }
         var _loc3_:Array = _tile.items;
         if(_loc3_ == null || _loc3_.length == 0)
         {
            return;
         }
         for each(_loc4_ in _loc3_)
         {
            if(_loc4_ is BoardRenderItem == false)
            {
               break;
            }
            if(_loc4_.data != null)
            {
               if(_loc4_.data["id"] == param1)
               {
                  _loc4_.toggleDecorated();
               }
               else if(_loc4_.data["id"] == param2)
               {
                  _loc4_.toggleDecorated();
               }
            }
         }
      }
   }
}

