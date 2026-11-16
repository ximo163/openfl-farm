package wild.com.Shell.model.beast
{
   import wild.com.Shell.model.crystal.CrystalDrop;
   
   public class BeastBase
   {
      
      public var bReturn:BeastReturn;
      
      public var info:BeastInfo;
      
      public var drop:CrystalDrop;
      
      public function BeastBase()
      {
         super();
         this.bReturn = new BeastReturn();
         this.info = new BeastInfo();
         this.drop = new CrystalDrop();
      }
   }
}

