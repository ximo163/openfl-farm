package module.uitools.widgets
{
   import com.qzone.qui.styles.Style;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   
   public class ToolBase extends Sprite
   {
      
      private var _enabled:Boolean = true;
      
      private var _tipText:String = "";
      
      private var _forbiddenMc:MovieClip;
      
      public function ToolBase()
      {
         super();
      }
      
      public function get enabled() : Boolean
      {
         return this._enabled;
      }
      
      public function get tipText() : String
      {
         return this._tipText;
      }
      
      public function set tipText(param1:String) : void
      {
         this._tipText = param1;
      }
      
      public function set enabled(param1:Boolean) : void
      {
         this._enabled = param1;
         if(!this._enabled)
         {
            filters = Style.getDisableFilter();
         }
         else
         {
            filters = null;
         }
      }
      
      public function forbidden(param1:Boolean, param2:MovieClip = null) : void
      {
         if(param1)
         {
            if(!this._forbiddenMc)
            {
               this._forbiddenMc = param2;
               this._forbiddenMc.x = this.width - this._forbiddenMc.width + 5;
               this._forbiddenMc.y = this.height - this._forbiddenMc.height;
            }
            addChild(this._forbiddenMc);
         }
         else if(Boolean(this._forbiddenMc) && contains(this._forbiddenMc))
         {
            removeChild(this._forbiddenMc);
         }
      }
   }
}

