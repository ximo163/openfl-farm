package mc.view.common
{
   import common.MaterialLib;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.events.MouseEvent;
   import mc.api.BeastAPI;
   import mc.view.farm.toolBar.ToolBase;
   import wild.com.Tools.DataTools;
   
   public class Tool_Wild extends ToolBase
   {
      
      public static var _canReleaseNum:int;
      
      private var _t:*;
      
      public function Tool_Wild()
      {
         super();
         this._t = MaterialLib.getInstance().getMaterial("Wild_Animal_Icon") as SimpleButton;
         addChild(this._t);
      }
      
      public function set actived(param1:String) : void
      {
         var b:String = param1;
         BeastAPI.cmdSetupClassObj.removeText();
         removeChild(this._t);
         if(b == null)
         {
            this._t = MaterialLib.getInstance().getMaterial("Wild_Animal_Icon") as SimpleButton;
            addChildAt(this._t,0);
            return;
         }
         if(b == "")
         {
            this._t = MaterialLib.getInstance().getMaterial("Wild_Animal_Icon") as SimpleButton;
            addChildAt(this._t,0);
         }
         else if(b == "1")
         {
            this._t = MaterialLib.getInstance().getMaterial("Wild_Animal_Icon_Active_2") as MovieClip;
            DataTools.getInstance().canReleaseNum = DataTools.getInstance().canReleaseNum == 0 ? 1 : DataTools.getInstance().canReleaseNum;
            this._t.wild_mc.wild.num_txt.gotoAndStop(DataTools.getInstance().canReleaseNum);
            BeastAPI.cmdSetupClassObj.showText(this,"num",DataTools.getInstance().canReleaseNum);
            this._t.buttonMode = true;
            this._t.wild_mc.addEventListener(MouseEvent.ROLL_OVER,function(param1:MouseEvent):void
            {
               param1.currentTarget.gotoAndStop(2);
            });
            this._t.wild_mc.addEventListener(MouseEvent.ROLL_OUT,function(param1:MouseEvent):void
            {
               param1.currentTarget.gotoAndStop(1);
            });
            addChildAt(this._t,0);
         }
         else if(b == "3")
         {
            this._t = MaterialLib.getInstance().getMaterial("Wild_Animal_Icon_Active_1") as MovieClip;
            addChildAt(this._t,0);
            BeastAPI.cmdSetupClassObj.showText(this,"back");
         }
      }
   }
}

