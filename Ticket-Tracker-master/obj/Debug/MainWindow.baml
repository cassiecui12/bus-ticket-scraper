   M S B A M L   `   `   `  ����H  DTicketTracker, Version=1.0.0.0, Culture=neutral, PublicKeyToken=null-clr-namespace:TicketTrackerTicketTracker  5   	       TicketTracker.MainWindow   5   	   W SPresentationCore, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35R NWindowsBase, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35\ XPresentationFramework, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35D 9http://schemas.microsoft.com/winfx/2006/xaml/presentation    5   	   R NSystem.Xaml, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089:x,http://schemas.microsoft.com/winfx/2006/xaml     5   	   @d2http://schemas.microsoft.com/expression/blend/2008     5   	   Jmc;http://schemas.openxmlformats.org/markup-compatibility/2006     5   	   -localclr-namespace:TicketTracker     5   	     � Title$  
MainWindow��5   	   $	��450��6   $	��800��6)    � 	Resources 5	      -   'TicketTracker.DateTimeToStringConverter   dateTimeToStringConverter)   #TicketTracker.ValidToImageConverter  validToImageConverter��%:   &	        &	        5
   
   6*     5   
   6&   5      .��5      �  � ColumnDefinitions 5   
   �� 5      6!   �� 5      6!   �� 5      6!   �� 5      6!    � RowDefinitions 5   
   �� 5      $��20 �6   6*   �� 5      $��40 �6   6*   �� 5      6   �� 5      $��20 �6   6*   �� 5      $��20 �6   6*   .+�5   
   �� -   5         ��Name$ ComboBoxFrom��5      $��0��5       $��1��5!       �� 
IsEditable . ��5#      ��  �� Path$ ComboBoxCitiesList�5%      �� 5&   
   -   5        $ 
ComboBoxTo��5&      $��1��5'      $��1��5(       . ��5*      �� $ ComboBoxCitiesList�5,      �� 5-   
   -   5         ��Name$ buttonGo��5-      $��3��6#   $��1��63   .��6W   Go!6\   �� 51   
   -   5         ��Name$ ListBoxDates��51      $��2��6)   $��4��66   	 �� View	 52      �� 53      .P�54      �� $
��From��6%   
 �� Width$	
 150��65    �� DisplayMemberBinding 6B   �� *from+�� 55      $��To��6%   $	
 150��65    6A   �� *to+�� 56      $
��Date��6%   $	
 150��65    6A   �� *date+ �� 	Converter# [  �� 57      $��Status��6%    �� CellTemplate 58      �� 59      .R�5:   "   �� ��6(   �� *valid+# [ 5;      5=      5?      5A      �� 5C   
   -   5         ��Name$ CheckBoxNewDates��5D      $��0��6-   $��3��5E      .��6    Only search new dates67   �� 5F   
   -   5        $ CheckBoxInvalidDates��5F      $��1��5G      $��3��6   .��6*   Include invalid dates6A   �� 5H   
   -   5         ��Name$ LabelStatus��5H      $��2��6%   $��3��65   $��2��6B   .��6S   Status: TEST6a   �� 5I   
   -   5        $ ButtonSearch��5I      $��3��6(   $��3��68   .��6`   Search All!6m   o� 5K   
   $��0��6   $��4��6   $	��Top=�60   .@�5L      m� $��_File��6   .@�5M      m� $��_About��6   m� 5N      -	   5        $��_Close��5N      6+   5O      5P      5S      5T      