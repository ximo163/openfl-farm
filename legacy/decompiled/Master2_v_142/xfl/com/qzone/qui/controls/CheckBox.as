package com.qzone.qui.controls
{
   import com.qzone.qui.skins.CheckBoxDefaultSkin;
   import com.qzone.qui.styles.Style;
   import com.qzone.utils.AlignUtil;
   
   public class CheckBox extends Button
   {
      
      public function CheckBox(param1:String = "CheckBox", param2:Function = null)
      {
         super(param1,param2);
         defaultSkin = CheckBoxDefaultSkin.skin;
         selectedSkin = CheckBoxDefaultSkin.selectedSkin;
         paddingH = Style.checkBoxPaddingH;
         textDefaultFormat = Style.getLabelFormat();
         textSelectedFormat = textDefaultFormat;
         textOverFormat = textDefaultFormat;
         _toggle = true;
      }
      
      override protected function setSelectedSkin() : void
      {
         super.setSelectedSkin();
         _skin.x = paddingH;
         _skin.y = AlignUtil.middle(_height,_skin.height);
      }
      
      override protected function setSize() : void
      {
         if(_skin)
         {
            if(!_resized)
            {
               _width = _textField.textWidth + 3 + paddingH * 2 + _skin.width;
            }
            _textField.width = _width - paddingH * 2 - _skin.width;
            _textField.height = Math.max(20,_textField.textHeight);
            _textField.x = _skin.width + paddingH * 2;
            _textField.y = Math.round(_height - _textField.height) / 2;
         }
      }
      
      override protected function setDefaultSkin() : void
      {
         super.setDefaultSkin();
         _skin.x = paddingH;
         _skin.y = AlignUtil.middle(_height,_skin.height);
      }
   }
}

