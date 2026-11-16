package com.minutes.ui.control
{
   import com.minutes.ui.core.LipiSkin;
   
   public class ToggleButton extends LipiButton
   {
      
      private var _selectedSkin:LipiSkin;
      
      private var _selected:Boolean = false;
      
      private var _defaultSkin:LipiSkin;
      
      public function ToggleButton()
      {
         super();
      }
      
      public function get defaultSkin() : LipiSkin
      {
         return this._defaultSkin;
      }
      
      public function set selectedSkin(param1:LipiSkin) : void
      {
         this._selectedSkin = param1;
         if(this.selected)
         {
            bgSkin = this.selectedSkin;
         }
         else
         {
            bgSkin = this.defaultSkin;
         }
      }
      
      public function set selected(param1:Boolean) : void
      {
         this._selected = param1;
         if(param1)
         {
            bgSkin = this.selectedSkin;
         }
         else
         {
            bgSkin = this.defaultSkin;
         }
      }
      
      public function get selectedSkin() : LipiSkin
      {
         return this._selectedSkin;
      }
      
      public function get selected() : Boolean
      {
         return this._selected;
      }
      
      public function set defaultSkin(param1:LipiSkin) : void
      {
         this._defaultSkin = param1;
         if(this.selected)
         {
            bgSkin = this.selectedSkin;
         }
         else
         {
            bgSkin = this.defaultSkin;
         }
      }
   }
}

