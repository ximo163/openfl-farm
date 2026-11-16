package module.uitools.widgets
{
   import common.misc.Utils;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.display.Stage;
   import flash.events.MouseEvent;
   import flash.utils.clearTimeout;
   import wild.com.Shell.command.CmdAPI;
   
   public class Tool_Wild extends ToolBase
   {
      
      private static var _canReleaseNum:int;
      
      private var _timeout:uint;
      
      private var _bg:MovieClip;
      
      private var _hasViewNum:int;
      
      private var _txtMc:MovieClip;
      
      private var _myStage:Stage;
      
      private var _t:*;
      
      public function Tool_Wild()
      {
         super();
         this._t = Utils.getMaterial("Wild_Animal_Icon") as SimpleButton;
         this._t.x = 8;
         this._bg = Utils.getMaterial("WildTaskBg") as MovieClip;
         this._bg.x = 9;
         addChild(this._bg);
         addChild(this._t);
         CmdAPI.getInstance().addEventListener("canReleaseNum",this.onNumChanged);
         this._timeout = 0;
      }
      
      public function removeText() : void
      {
         if(this._timeout > 0)
         {
            clearTimeout(this._timeout);
            this._timeout = 0;
         }
         if(this._txtMc != null)
         {
            this._txtMc.stop();
            this._myStage.removeChild(this._txtMc);
            this._txtMc = null;
         }
         this._hasViewNum = 0;
      }
      
      private function onNumChanged(param1:EvtAPI) : void
      {
         if(param1.data != null)
         {
            if(param1.data["value"] != null)
            {
               _canReleaseNum = int(param1.data["value"]);
            }
         }
      }
      
      public function set actived(param1:String) : void
      {
         var b:String = param1;
         if(this.stage != null && this._myStage == null)
         {
            this._myStage = this.stage;
         }
         this.removeText();
         removeChild(this._t);
         if(b == null)
         {
            this._t = Utils.getMaterial("Wild_Animal_Icon") as SimpleButton;
            this._t.x = 8;
            addChild(this._t);
            return;
         }
         if(b == "")
         {
            this._t = Utils.getMaterial("Wild_Animal_Icon") as SimpleButton;
            this._t.x = 8;
            addChild(this._t);
         }
         else if(b == "1")
         {
            this._t = Utils.getMaterial("Wild_Animal_Icon_Active_2") as MovieClip;
            this._t.x = 8;
            addChild(this._t);
            _canReleaseNum = _canReleaseNum == 0 ? 1 : _canReleaseNum;
            this._t.num_txt.gotoAndStop(_canReleaseNum);
            this._t.buttonMode = true;
            this._t.addEventListener(MouseEvent.ROLL_OVER,function(param1:MouseEvent):void
            {
               _t.scaleX = 1.1;
               _t.scaleY = 1.1;
               _t.x -= 2;
               _t.y -= 2;
            });
            this._t.addEventListener(MouseEvent.ROLL_OUT,function(param1:MouseEvent):void
            {
               _t.scaleX = 1;
               _t.scaleY = 1;
               _t.x += 2;
               _t.y += 2;
            });
         }
         else if(b == "3")
         {
            this._t = Utils.getMaterial("Wild_Animal_Icon_Active_1") as MovieClip;
            this._t.x = 8;
            addChild(this._t);
         }
      }
   }
}

