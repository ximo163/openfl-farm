package module.monthBegin
{
   import mc.view.main.WindowControl.WControl;
   
   public class MonthBeginController
   {
      
      private var _monthBeginWin:MonthBeginWin;
      
      private var _monthBeginGreat:MonthEndGift;
      
      public function MonthBeginController()
      {
         super();
      }
      
      public function createGreatBox() : void
      {
         if(!this._monthBeginGreat)
         {
            this._monthBeginGreat = new MonthEndGift();
         }
         WControl.open(this._monthBeginGreat);
      }
      
      public function createBox() : void
      {
         if(!this._monthBeginWin)
         {
            this._monthBeginWin = new MonthBeginWin();
         }
         WControl.open(this._monthBeginWin);
      }
   }
}

