package module.uitools.vo
{
   public final class ProfileData
   {
      
      public var m_userName:String;
      
      public var m_moral:uint;
      
      public var m_exp:uint;
      
      public var m_fb:uint;
      
      public var m_photoUrl:String;
      
      public var m_gold:Number;
      
      public function ProfileData()
      {
         super();
         this.m_userName = "";
         this.m_photoUrl = "";
         this.m_gold = 0;
         this.m_exp = 0;
         this.m_fb = 0;
         this.m_moral = 0;
      }
   }
}

