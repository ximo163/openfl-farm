package mc.view.common
{
   import common.INI;
   
   public class Language
   {
      
      public static const CN:String = "cn";
      
      public static const EN:String = "en";
      
      private static var _l:Object = {"cn":{
         "buySeedFnText":"领养成功，共花费金币<font color=\"#FF6600\"> <b>{money}</b> </font>，领养<font color=\"#047D20\"> <b>{num}</b> </font>个<font color=\"#047D20\"> <b>{cName}</b> </font>幼仔。",
         "buySeedFnTextNew":"购买成功，共花费金币<font color=\"#FF6600\"> <b>{money}</b> </font>，<font color=\"#047D20\"> <b>{num}</b> </font>个<font color=\"#047D20\"> <b>{cName}</b> </font>幼仔已放入包裹。",
         "saleAllFnText":"成功卖出和捐赠仓库里的所有产品和动物，共获得收入和感谢金<font color=\"#FF6600\"> <b>{money}</b> </font>金币。",
         "reclaimPayText":"需要牧场等级<font color=\'#047D20\'> {level} </font>级和金币<font color=\'#FF6600\'> {money}</font>。",
         "reclaimPayText2":"扩建效果：可饲养住{house}动物+{num},{house}样式变更。",
         "cropSeedName":"{cName}种子",
         "buyNum":"输入数量（{minNum}~{maxNum}）",
         "sellNum":"输入数量（{minNum}~{maxNum}）",
         "allSellText":"当前动物产品的总价值（不包含锁定）：<font color=\'#FF6600\'>{goldValue}</font><br>是否全部卖出或捐赠？",
         "lovesallSellText":"<font color=\'#FF0000\'>注：情人节活动9倍收购产物“情果”默认不锁定</font><br>当前动物产品的总价值（不包含锁定）：<font color=\'#FF6600\'>{goldValue}</font><br>是否全部卖出或捐赠？",
         "allSellTextMaterial":"当前材料的总价值（不包含锁定）：<br><font color=\'#FF6600\'>{goldValue}</font><br>是否全部卖出？<br><font color=\'#FF6600\'size=\'12\'>提示：农场和牧场的材料都统一存放在材料专区里，若全部卖出，所有材料（不包含锁定）均将被卖出</font>",
         "saleAllMaterialFnText":"成功卖出仓库里所有未锁定材料，得到金币 <font color=\"#FF6600\"> <b>{money}</b> </font>。"
      }};
      
      private static var _currentLang:String = "";
      
      public function Language()
      {
         super();
      }
      
      public static function replaceText(param1:String, param2:Object) : String
      {
         var _loc4_:String = null;
         var _loc5_:RegExp = null;
         var _loc3_:String = "";
         _loc3_ = Language.L[param1];
         for(_loc4_ in param2)
         {
            _loc5_ = new RegExp("{" + _loc4_ + "}","g");
            _loc3_ = _loc3_.replace(_loc5_,param2[_loc4_]);
            _loc3_ = _loc3_.replace("#1#","1st").replace("#2#","2nd").replace("#3#","3rd").replace("#4#","4th");
         }
         return _loc3_;
      }
      
      public static function get L() : Object
      {
         return _l[lang];
      }
      
      public static function get lang() : String
      {
         if(_currentLang != "")
         {
            return _currentLang;
         }
         var _loc1_:XML = INI.getInstance().data;
         var _loc2_:String = _loc1_.version.@language;
         if(_loc2_ == "" || _loc2_ == null)
         {
            _currentLang = "cn";
         }
         else
         {
            _currentLang = _loc2_;
         }
         return _currentLang;
      }
   }
}

