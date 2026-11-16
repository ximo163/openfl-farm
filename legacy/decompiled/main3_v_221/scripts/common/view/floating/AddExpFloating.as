package common.view.floating
{
   import common.Consts;
   import common.Session;
   import interfaces.IMsgCenter;
   
   public class AddExpFloating extends AddMoneyFloating
   {
      
      public function AddExpFloating(param1:IMsgCenter)
      {
         super(param1);
         super.floatName = Consts.FLOAT_TYPE_EXP;
      }
      
      override public function start(param1:Object) : void
      {
         super.start(param1);
         var _loc2_:int = super._data["value"] as Number;
         var _loc3_:Object = Session.getInstance().myFairy;
         if(_loc2_ > 2 && _loc2_ < 100 && _loc3_ != null && (_loc3_["itemId"] == Consts.FAIRY_LADY || _loc3_["itemId"] == Consts.FAIRY_GOD))
         {
            _addAddAnimation.addValueBox.addValue.text += "(↑" + _loc3_["rate"] + "%)";
         }
      }
   }
}

