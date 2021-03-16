ZeosLib components for FastReport 6.0

Created by: Juliomar Marchetti
E-mail: juliomarmarchetti@gmail.com

Note: ZeosLib needs to be in the latest version and enabled on Zeos.inc {$ DEFINE DISABLE_ZPARAM} and I also noticed that I had to disable {$ DEFINE ZEOS_DISABLE_OLEDB}


Install
=======

Copy (Folder Root FastReport)\LibDXX where XX corresponds to the version of delphi, the files downloaded from this repository
Open frxZeosN.dpk, where N corresponds to your Delphi version and compile it.
Open dclfrxZeosN.dpk, compile and install it.

Getting started
===============
To get started with usage ZeosLib FR plug-in:
1)  after installing the plugin open Example project
2)  set up ZConnection1 component to connect to your database
3)  ensure ZConnection1 is selected as DefaultDatabase in frxZeosComponents1
4)  right click frxReport1 component at design-time and click Edit report... to open the component editor
5)  after the editor is opened select Data page among Code, Data, Page1 ones 
6)  the left most palette allows you to create data components: ZEOSDatabase, ZEOSTable, ZEOSQuery
    that match corresponding ZeosLib components: TZConnection, TZTable, TZQuery
7)  if you want to select data from a table you can choose ZeosTable or ZeosQuery components
8)  click the chosen one on the palette and then click on the data area next to Report Tree 
9)  after that you’ll be able to set up all the required component properties in the Object Inspector (next to the palette) 
    similarly to how you would do that in Delphi
10) then you’ll be able to work with the data component and its fields: all the data components get available in the Data Tree