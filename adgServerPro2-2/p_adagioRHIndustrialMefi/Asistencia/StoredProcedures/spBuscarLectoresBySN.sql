USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**************************************************************************************************** 
** Descripción		: PROCEDIMIENTO PARA OBTENER LOS LECTORES POR SERIAL
** Autor			: DENZEL OVANDO	
** Email			: debzel.ovando@adagio.com.mx
** FechaCreacion	: 2021-11-26
** Paremetros		:              
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------

***************************************************************************************************/

CREATE PROCEDURE [Asistencia].[spBuscarLectoresBySN]
(
	 @SerialNumber varchar(50)
)
AS
BEGIN

 DECLARE
		@IDIdioma varchar(20)
	;

	select @IDIdioma=App.fnGetPreferencia('Idioma', 1, 'esmx')

	SELECT 
		L.IDLector
		,L.Lector
		,L.CodigoLector
		,L.PasswordLector
		,L.IDTipoLector
		,TL.TipoLector
		,isnull(L.IDZonaHoraria,0) as IDZonaHoraria
		,isnull(z.Name,'SIN DEFINIR') as ZonaHoraria
		,l.IP as IP
		,l.Puerto as Puerto
		,l.Estatus as Estatus
		,isnull(l.EsComedor,0) as EsComedor
		,isnull(l.Comida,0) as Comida
		,isnull(L.IDCliente,0) IDCliente
		,isnull(JSON_VALUE(c.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'NombreComercial')),'Sin cliente asignado') as Cliente
		,L.Master as [Master]
		,l.NumeroSerial as [NumeroSerial]
		,[DevSN]
		,[DeviceName]
		,[AttLogStamp]
		,[OperLogStamp]
		,[AttPhotoStamp]
		,[ErrorDelay]
		,[Delay]
		,[TransFlag]
		,[Realtime]
		,[TransInterval]
		,[TransTimes]
		,[Encrypt]
		,isnull([LastRequestTime], '1990-01-01 00:00:00.000') as [LastRequestTime]
		,[IPAddress]
		,[MAC]
		,[FWVersion]
		,isnull([UserCount], 0 ) as [UserCount]
		,isnull([FpCount], 0 ) as [FpCount]
		,isnull([AttCount], 0 ) as [AttCount]	
		,[TimeZone]
		,isnull([Timeout], 0 ) as [Timeout]
		,isnull([SyncTime], 0 ) as [SyncTime]
		,[OEMVendoR]
		,[IRTempDetectionFunOn]
		,[MaskDetectionFunOn]
		,[UserPicURLFunOn]
		,[MultiBioDataSupport]
		,[MultiBioPhotoSupport]
		,[MultiBioVersion]
		,[MultiBioCount]
		,[MaxMultiBioDataCount]
		,[MaxMultiBioPhotoCount]
		,ROW_NUMBER()OVER(ORDER BY L.IDLECTOR ASC) AS ROWNUMBER
	from Asistencia.tblLectores L
		INNER JOIN Asistencia.tblCatTiposLectores TL
			on L.IDTipoLector = TL.IDTipoLector
		LEFT JOIN RH.tblCatClientes c on c.IDCliente = L.IDCliente
		LEFT JOIN Tzdb.Zones Z
			on Z.Id = L.IDZonaHoraria
		LEFT JOIN [Asistencia].[tblLectoresOpciones] LO
				ON l.IDLector = LO.IDLector
	WHERE l.NumeroSerial = @SerialNumber
	
END
GO
