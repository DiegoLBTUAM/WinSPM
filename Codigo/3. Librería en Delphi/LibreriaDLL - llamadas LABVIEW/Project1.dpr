library Project1;

{ Important note about DLL memory management: ShareMem must be the
  first unit in your library's USES clause AND your project's (select
  Project-View Source) USES clause if your DLL exports any procedures or
  functions that pass strings as parameters or function results. This
  applies to all strings passed to and from your DLL--even those that
  are nested in records and classes. ShareMem is the interface unit to
  the BORLNDMM.DLL shared memory manager, which must be deployed along
  with your DLL. To avoid using BORLNDMM.DLL, pass string information
  using PChar or ShortString parameters. }

{

  ==============================================================================
  Librer�a para programa LINER.exe bas�ndose en librer�a TAKE_DILUCION.dpr.
  Versi�n 1.5 liberada en Febrero de 2015, Javier Blanco, SEGAINVEX
  ==============================================================================

  - Cambios realizados desde 1.0: las funciones cambian de nombre (+2) para ser
    llamadas desde servidor realizado en LABView.
  - Traducci�n de rutinas desde VB6 bas�ndose en c�digo de JAHR.
  - Gesti�n de errores seg�n c�digo en TAKE_DILUCION.dpr
  - Los m�dulos FT2232CSPIUnit, SPIDLLFuncUnit,D2XXUnit se han modificado seg�n
    necesidades del proyecto.


  ==============================================================================
  INSTRUCCIONES

  Construir el proyecto (build) y copiar la librer�a resultante en la ruta y
  con el nombre de archivo definido en la variable de entorno del sistema "TAKE_DLL".
  Ejecutar el programa "LINER.EXE".


  PRECAUCIONES

  Si se cambia el m�dulo FT2232H, hay que actualizar las propiedades: DeviceName,
  DeviceChannel y LocationID.

  Los n�s de DAC van del 0 al 7
  Los n�s de ADC van del 0 al 5   (el canal n� 3 est� desplazado en PCB rev. A):

  F�sico: 0 1 2 3 4 5   (conectores)
  L�gico: 0 1 2 5 3 4   (lectura ADC)

  Es decir, para leer el canal n� 3  f�sico, hay que hacerlo en el canal 5 l�gico.
  Adem�s, los canales 3 y 4 est�n tambi�n descolocados.

  Para habilitar mostrar informaci�n sobre el proceso del programa, asignar el
  valor "true" a la variable TRAZAS


  ==============================================================================


  CONTRATO DE LICENCIA PARA EL USUARIO FINAL DE "librer�a Delphi para Liner.exe" Y EQUIPO INSTRUMENTAL ASOCIADO

  Lea detenidamente este contrato antes de completar el proceso de instalaci�n del programa. La instalaci�n de
  este programa supone la aceptaci�n de todos los t�rminos y condiciones de este contrato.

- Este programa y los instrumentos asociados han sido desarrollados en el Servicio General de Apoyo a la
  Investigaci�n Experimental (SEGAINVEX) de la Universidad Aut�noma de Madrid (U.A.M.) con fines experimentales.

- Ambito: Este programa es un prototipo desarrollado para uso interno de los departamentos de la Universidad
  Aut�noma de Madrid. El autor o autores declinan toda responsabilidad de hechos derivados de un uso diferente
  al mencionado.

- Derechos de autor: El programa es propiedad de la Universidad Aut�noma de Madrid y est� protegido por leyes
  sobre la propiedad intelectual y disposiciones de tratados internacionales aplicables. No obstante, podr�
  copiar el programa �nicamente como copia de seguridad o para su archivo. Todos los derechos que este Contrato
  no le otorgue expresamente quedan reservados a la U.A.M.

- Prohibici�n de distribuci�n: Est� prohibido redistribuir, alquilar o sub-licenciar el programa y sus copias o
  componentes en cualquier sentido.

- Limitaciones en materia de ingenier�a inversa, descompilaci�n y desensamblaje: Usted no podr� utilizar t�cnicas
  de ingenier�a inversa, descompilar ni desensamblar el programa, excepto y �nicamente en la medida en que dicha
  actividad est� expresamente permitida por la legislaci�n aplicable, a pesar de la presente limitaci�n.

- Advertencia: Este producto no est� dise�ado con piezas ni comprobadores de nivel de fiabilidad adecuados que
  garanticen evitar da�os a la propiedad o a las personas incluyendo el riesgo de da�os personales y muerte.
  A f�n de evitar da�os personales el usuario deber� tomar las medidas razonablemente prudentes para protegerse
  contra fallos del sistema.

- Seguridad instrumental: En el interior del equipo no existen piezas reparables por el usuario. Para efectuar
  reparaciones, consulte a personal cualificado. Para protecci�n permanente contra incendio, sustituya los fusibles
  s�lo por otros que tengan las mismas especificaciones t�cnicas.

- Limitaci�n de responsabilidad: Hasta el l�mite permitido por ley, en ning�n caso ser�n la Universidad Aut�noma
  de Madrid o sus proveedores (incluyendo autores, empleados y directivos) responsables de los da�os incluyendo,
  sin limitaci�n, cualesquiera da�os especiales, directos, indirectos, incidentales, gastos, lucro cesante o
  cualesquiera otros da�os que surjan del uso o incapacidadde utilizar el programa o el instrumental asociado.

  ======================FIN NOTAS===============================================

  }

uses

  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, FT2232CSPIUnit, SPIDLLFuncUnit,D2XXUnit, StrUtils, WINSOCK ;


 Const

  FT_DLL_Name = 'ftd2xx.dll';
  TRAZAS = false;       // Para definir si se lanzan mensajes o no

var
  SupraSPI_Hdl:Dword;
  Buffer:String[50]; //En ppio. hay espacio de sobra con esta cantidad

// implementation

  Function SPI_OpenHiSpeedDevice( DeviceName:String;  LocationID:Integer;Channel: String; ftHandle:pointer):FTC_STATUS;     stdcall ; External FT2232CSPI_DLL_Name name 'SPI_OpenHiSpeedDevice';
  Function SPI_InitDevice  (ftHandle:dword; ClockDivisor:Dword ) : FTC_STATUS;    stdcall ; External FT2232CSPI_DLL_Name name 'SPI_InitDevice' ;
  Function SPI_SetDeviceLatencyTimer (ftHandle:dword; Timervalue:Dword)   : FTC_STATUS;    stdcall ; External FT2232CSPI_DLL_Name name 'SPI_SetDeviceLatencyTimer' ;
  Function SPI_SetHiSpeedDeviceGPIOs(fthandle: Dword; ChipSelectsDisableStates: PFtcChipSelectPins; HighInputOutputPins: PFtcInputOutputPins): FTC_STATUS; stdcall ; External FT2232CSPI_DLL_Name name 'SPI_SetHiSpeedDeviceGPIOs';
  Function SPI_Close (fthandle: Dword): FTC_STATUS; stdcall ; External FT2232CSPI_DLL_Name name 'SPI_Close';

  Function FT_Read ( lngHandle:dword; lpszBuffer: Pointer;  lngBufferSize:dword;lngBytesReturned:Pointer):FTC_STATUS ; stdcall ; External otra_DLL_Name name 'FT_Read';
  Function FT_GetQueueStatus (lngHandle:dword; lngRxBytes:pointer ):   FTC_STATUS ; stdcall ; External otra_DLL_Name name 'FT_GetQueueStatus';
  Function FT_Write(ftHandle:Dword; FTOutBuf : Pointer; BufferSize : LongInt; ResultPtr : Pointer ) : FTC_STATUS ; stdcall ; External otra_DLL_Name name 'FT_Write';
  Function FT_Purge(ftHandle:Dword; dwMask:Dword):  FTC_STATUS ; stdcall ; External otra_DLL_Name name 'FT_Purge';


{$R *.res}

// Funciones auxiliares

function HexToString(H: String): String;
var I: Integer;
begin
  Result:= '';
  for I := 1 to length (H) div 2 do
    Result:= Result+Char(StrToInt('$'+Copy(H,(I-1)*2+1,2)));
end;


Function Get_USB_Device_QueueStatus(ReceivesBytes: Dword): Dword;
//' return the number of bytes waiting to be read
begin
   Result:= FT_GetQueueStatus(SupraSPI_Hdl, @ReceivesBytes);
End;

// Fin funciones auxiliares





//////////////// FUNCI�N DAC_SET

function dac_set2(ndac,valor:integer) : byte ; stdcall ;
Var sTexto:String;
Var sTexto2:String;
var CadenaCS:integer;   var CadenaCS2:string; var CadenaValorstring:string;
var sele_dac:integer;     var cadena_sele_dac:string;
var BytesToWrite: Integer;
var BytesWritten:Integer;
var SPI_Ret:Integer;
var total:integer;


begin

 Result:=0 ;
 if (ndac<0) or (ndac>7) then Exit ;

// Se filtran los valores seg�n indicaciones de Isabel
 if valor>32767 then valor:=32767 ;
 if valor<-32768 then valor:=-32768 ;


 if (ndac  > 3) then CadenaCS:=223  //DF
                else CadenaCS:= 247;  //F7

    CadenaCS2:=  IntToHex( CadenaCS,1);
    CadenaCS2:=  HexToString(CadenaCS2) ;


 if (ndac  < 4)  then sele_dac:=ndac+4
                 else sele_dac:=ndac;

 cadena_sele_dac:=   HexToString(  IntToHex( sele_dac,2));

 //if (ndac> 4) then valor:=-valor;    // No est�n invertidos, as� que se puede hacer por SW para coherencia con las otras salidas del DAC
  if (ndac < 5) then valor:=-valor;    // Es mejor que un n� positivo ofrezca una salida positiva, de modo que se hace de este modo en vez de como estaba inicialmente previsto en la l�nea anterior



 // El valor ya viene en formato -32768..0..32767, de modo que la conversi�n es al valor hex del ascii

   CadenaValorstring:=    IntToHex(  valor,4) ;
   total:=  Length ( CadenaValorstring);

   CadenaValorstring:=   concat(   CadenaValorstring[(total-3)],CadenaValorstring[(total-2)],CadenaValorstring[(total-1)],CadenaValorstring[(total-0)]  );
   CadenaValorstring:=  HexToString(CadenaValorstring) ;

   Buffer:=      concat( HexToString('80'), CadenaCS2,HexToString('FB100200'),cadena_sele_dac,CadenaValorstring , HexToString('8780FFFB') );
   BytesToWrite:= Length (Buffer);
   SPI_Ret :=  FT_Write(SupraSPI_Hdl, @Buffer, BytesToWrite, @BytesWritten) ;
   If SPI_Ret <> 0
  then MessageDlg('error al escribir un valor en el DAC', mtError, [mbOk], 0);

//////////////////////Fin normal//////////////

 Str( ndac, sTexto );
 Str( valor, sTexto2 );
if TRAZAS then MessageDlg('DAC Set numero de dac:'+Stexto+ 'valor:'+sTexto2, mtError, [mbOk], 0);

   Result:=1 ;

end  ;

//FUNCI�N PID_HOLD

function PID1_hold2(b:byte) : Byte ; stdcall ;

var seleccion:byte;
var BytesToWrite: Integer;
var BytesWritten:Integer;
var SPI_Ret:Integer;
var sTexto: String;


begin
Result:=0 ;
seleccion:=b;

// Hay que dejar el reloj arriba (80FFFB), ya que si no las lecturas ADC no son correctas

// Se elige si se escribe un 0 o un 1
if    (seleccion=1) then  Buffer:=HexToString('80FEFB8200FF110200400A01878208FF80FFFB')
                  else  Buffer:=HexToString('80FEFB8200FF110200400A00878208FF80FFFB');



// y luego se escribe en el dispositivo

 BytesToWrite:= Length (Buffer);
 SPI_Ret :=  FT_Write(SupraSPI_Hdl, @Buffer, BytesToWrite, @BytesWritten) ;

 str( SPI_Ret, sTexto );

 If SPI_Ret <> 0  then

 MessageDlg('No se puede escribir HOLD: ' +Stexto, mtError, [mbOk], 0);


// If SPI_Ret <> 0
 // then MessageDlg('error en el write del PID_HOLD', mtError, [mbOk], 0);



//////////////////////Fin normal//////////////
if TRAZAS then MessageDlg('PID_hold', mtError, [mbOk], 0);
  Result:=1;

  end ;



  /////////FUNCI�N TAKE_finalize

  function take_finalize2 : byte ; stdcall ;

  var SPI_Ret:Integer;

  begin
  Result:=0 ;
  SPI_Ret:=  SPI_Close(SupraSPI_Hdl);

  If SPI_Ret <> 0
   then MessageDlg('Error al cerrar', mtError, [mbOk], 0);
  //  else  MessageDlg('Cerrado correctamente', mtError, [mbOk], 0);


    Result:=1 ;
end  ;


  //////// FUNCIONES ADC y DAC init ////////////////

  function adc_init2 : byte ; stdcall ;
begin

if TRAZAS then  MessageDlg('adc_init', mtError, [mbOk], 0);

  Result:=1 ;
end ;


  function dac_init2 : byte ; stdcall ;
begin

if TRAZAS then  MessageDlg('DAC Init', mtError, [mbOk], 0);

  Result:=1 ;
end ;

//////// FUNCI�N bit_modula. Sin funcionalidad conocida

function Bit_Modula2(b:byte) : byte ; stdcall ;
begin
Result:=0 ;
if TRAZAS then MessageDlg('Bitmodula', mtError, [mbOk], 0);

  Result:=1 ;
end ;


////////////  FUNCI�N ADC_take    ///////////

function adc_take2(chn,mux,n:integer) : double ; stdcall ;


Var sTexto:String;
Var sTexto2:String;
Var sTexto3:String;

var SPI_Ret:Integer;
var BytesToWrite: Integer;
var BytesWritten:Integer;
var BytesToReceive:Integer;
var numADCChannels:Integer;
var ReceivesBytes:Integer;
var FT_In_Buffer:String[14]; //En ppio. tama�o suficiente para esta versi�n
var BytesReturned:Integer;
var numres:longint;
var resultadoooo:extended;
var i:integer;
var datosum: double ;
var   f : double ;

begin

// En el original, hab�a estas limitaciones:
// if (n<1) or (chn<0) or (chn>7) or (mux<0) or (mux>31) then Exit ; ;
// Las cuales se adaptan a:


if (n<1) or (chn<0) or (chn>5)  then Exit ;


  datosum:=0 ;    // Se pone a 0 al principio del bucle

  for i:=1 to n do begin

  Buffer:=' ';
  ReceivesBytes:=0;
  Buffer:=HexToString('807FFB80FFFB80FFFB80FFFB80EFFB200b008780FFFB');

  BytesToWrite:= Length (Buffer);
  SPI_Ret :=  FT_Write(SupraSPI_Hdl, @Buffer, BytesToWrite, @BytesWritten) ;
  If SPI_Ret <> 0
   then MessageDlg('Error al preparar los datos para escribir ', mtError, [mbOk], 0);


  numADCChannels:=6;
  ReceivesBytes:=0;
  BytesToReceive := 2 * numADCChannels ;   //   Por cada canal A/D debo recibir 2 bytes, 6Ch x 2 =12bytes


  Repeat
        SPI_Ret:=  FT_GetQueueStatus(SupraSPI_Hdl, @ReceivesBytes);
  Until (ReceivesBytes >= BytesToReceive) Or (SPI_Ret <> FT_OK)  ;

  If SPI_Ret <> 0
   then MessageDlg('error al leer ', mtError, [mbOk], 0);

  BytesReturned:=0;


  // LECTURA DE DATOS ADC RECIBIDOS

   SPI_Ret := FT_Read(SupraSPI_Hdl, @FT_In_Buffer, ReceivesBytes, @BytesReturned);

   If SPI_Ret <> 0
        then MessageDlg('error al leer los datos ADC ', mtError, [mbOk], 0);


   numres:=ord(FT_In_Buffer[(chn*2)])*256 +  ( ord(FT_In_Buffer[(chn*2+1)]));
   if  numres > 32768             then    numres:=numres - 65536;      //Conversi�n (condicional) a n�s negativos
   resultadoooo:=numres/3276.8;

  Str( resultadoooo, sTexto2 );
  Str( n, sTexto3 );

 if TRAZAS then   MessageDlg('El valor es :'+Stexto2+ 'y n es:'+sTexto3, mtError, [mbOk], 0);

   datosum:=datosum + resultadoooo ;

 end;   // Del for

  f:=datosum/n ;
  Str( f, sTexto2 );
  if TRAZAS then   MessageDlg('El valor medio es :'+Stexto2, mtError, [mbOk], 0);
  Result:=f;


//////////////////////////// fin normal
 Str( chn, sTexto );
 Str( mux, sTexto2 );
 Str( n, sTexto3 );

if TRAZAS then  MessageDlg('ADC TAKE chn:'+Stexto+ 'mux:'+sTexto2+'n:' +sTexto3, mtError, [mbOk], 0);

end;


   ////////////  FUNCI�N take_initialize    ///////////


   function take_initialize2 : byte ; stdcall ;

 var LocationID:Integer;
 var DeviceName: String; DeviceChannel: String;
 var SPI_Ret:Integer;    SPI_Hdl:Dword;
 var sTexto: String;

 var BytesToWrite: Integer;
 var BytesWritten:Integer;
 var novalido:Double;

 var miestructura2:FtcChipSelectPins;
 var entradassalidas:FtcInputOutputPins;


begin

 SPI_Ret :=0    ;
 DeviceName:='FT2232H MiniModule A' ;
 DeviceChannel:='A';
 LocationID:=1313;
 Result:=0;

 SPI_Ret := SPI_OpenHiSpeedDevice(DeviceName, LocationID, DeviceChannel, @SPI_Hdl) ;
 Str( SPI_Ret, sTexto );

 SupraSPI_Hdl:=  SPI_Hdl;

 If SPI_Ret <> 0  then
 begin
 MessageDlg('No se puede abrir: ' +Stexto, mtError, [mbOk], 0);
 exit;
 end ;
 // else  MessageDlg('Abierto correctamente', mtError, [mbOk], 0);

 SPI_Ret :=  SPI_InitDevice(  SPI_Hdl,2);
 Str( SPI_Ret, sTexto );

 If SPI_Ret <> 0  then
 begin
 MessageDlg('No se puede iniciar: ' +Stexto, mtError, [mbOk], 0) ;
 exit;
 end;
// else  MessageDlg('Inicializado correctamente', mtError, [mbOk], 0);


 SPI_Ret := SPI_SetDeviceLatencyTimer  (  SPI_Hdl,2);
 Str( SPI_Ret, sTexto );

 If SPI_Ret <> 0 then
 begin
 MessageDlg('No se puede configurar la latencia: ' + Stexto, mtError, [mbOk], 0) ;
 exit;
 end;
  // else  MessageDlg('Latencia correcta', mtError, [mbOk], 0);


   // Configurar entradas y salidas y estado inicial

   entradassalidas.bPin1InputOutputState:=true;
   entradassalidas.bPin2InputOutputState:=true;
   entradassalidas.bPin3InputOutputState:=true;
   entradassalidas.bPin4InputOutputState:=true;
   entradassalidas.bPin5InputOutputState:=true;
   entradassalidas.bPin6InputOutputState:=true;
   entradassalidas.bPin7InputOutputState:=true;
   entradassalidas.bPin8InputOutputState:=true;

   entradassalidas.bPin1LowHighState:=false;
   entradassalidas.bPin2LowHighState:=false;
   entradassalidas.bPin3LowHighState:=false;
   entradassalidas.bPin4LowHighState:=true;
   entradassalidas.bPin5LowHighState:=false;
   entradassalidas.bPin6LowHighState:=false;
   entradassalidas.bPin8LowHighState:=false;


 SPI_Ret :=  SPI_SetHiSpeedDeviceGPIOs (  SPI_Hdl, @miestructura2,  @entradassalidas);
 Str( SPI_Ret, sTexto );

 If SPI_Ret <> 0 then
 begin
 MessageDlg('No se pueden configurar las E/S: '+Stexto, mtError, [mbOk], 0);
 exit;
 end;
 //  else  MessageDlg('Puertos correctos', mtError, [mbOk], 0);         // Da error, ignoro el motivo


  Buffer:=' ';

  //  No necesaria esta parte de la configuraci�n.
  //  Buffer:=HexToString('80FFFB8208FF');
  //  BytesToWrite:= Length (Buffer);
  /////////////////////////////////////////////////////////////////////////
  //SPI_Ret :=  FT_Write(SPI_Hdl, @Buffer, BytesToWrite, @BytesWritten) ;

  //  If SPI_Ret <> 0
  //  then MessageDlg('error en el write config', mtError, [mbOk], 0);


  //Escritura de valor m�ximo en el atenuador por posibles problemas tras reset (va a la mitad del FS)

 Buffer:=HexToString('80BEFB11020003FFFF8780FEFB');
 BytesToWrite:= Length (Buffer);
 SPI_Ret :=  FT_Write(SPI_Hdl, @Buffer, BytesToWrite, @BytesWritten) ;
 If SPI_Ret <> 0  then
 begin
 MessageDlg('error al escribir el valor del filtro dig: ', mtError, [mbOk], 0);
 exit;
 end;


  // Configuraci�n de la salidas digitales

 Buffer:=HexToString('80FEFB8200FF110200400000878208FF80FFFB');
 BytesToWrite:= Length (Buffer);

 SPI_Ret :=  FT_Write(SPI_Hdl, @Buffer, BytesToWrite, @BytesWritten) ;
 If SPI_Ret <> 0  then
 begin
 MessageDlg  ('error al configurar las DIO: ', mtError, [mbOk], 0);
 exit;
 end;

// Realizar lecturas ADC para estabilizar datos

  novalido:= adc_take2(0,1,5);    // 5 es experimental

// Purgar lectura y escritura en el buffer

   SPI_Ret:=FT_Purge(   SupraSPI_Hdl,1);
   SPI_Ret:=FT_Purge(   SupraSPI_Hdl,2);
   If SPI_Ret <> 0  then
   begin
   MessageDlg  ('error al purgar el buffer: ', mtError, [mbOk], 0);
   exit;
   end;




if (TRAZAS) then MessageDlg('take_initialize', mtError, [mbOk], 0);

Result:=1 ;
end  ;



   exports
  dac_init2 name 'dac_init2',
  dac_set2 name 'dac_set2',
  adc_init2 name 'adc_init2' ,
  adc_take2 name 'adc_take2',
  PID1_hold2 name 'PID1_hold2',
  Bit_Modula2 name 'Bit_Modula2',
  take_initialize2 name 'take_initialize2',
  take_finalize2 name 'take_finalize2';

end.
