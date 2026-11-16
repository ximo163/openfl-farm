package mc.view.farm.toolBar
{
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.errors.IllegalOperationError;
   import flash.filters.ColorMatrixFilter;
   
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
      
      public function AddNewIconMC() : void
      {
         throw new IllegalOperationError("AddNewIconMC not supported!");
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
            filters = [new ColorMatrixFilter([0.3086,0.6094,0.082,0,0,0.3086,0.6094,0.082,0,0,0.3086,0.6094,0.082,0,0,0,0,0,1,0])];
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

